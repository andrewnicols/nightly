#!/bin/bash
#
# Common functions.

SCRIPTS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CONFIG_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../config
PERMISSIONS=775
DOCKERIP=$(ip addr | grep global | awk '{print substr($2,1,length($2)-3)}')
PHPVERSION=$(php -v | grep cli | awk '{print $1" " substr($2,1,6)}')

## Default params releated to docker container.
HOMEDIR=/
MOODLE_DIR=/var/www/html/moodle
CONFIG_TEMPLATE=/templates/config.php.template
SHARED_DIR=/shared
SHARED_DATA_DIR=/shared_data

# Load the runlib.
. /entry/runlib.sh

################################################
# Checks that last command was successfully executed
# otherwise exits showing an error.
#
# Arguments:
#   * $1 => The error message
#
################################################
function throw_error() {
    local errorcode=$?
    if [ "$errorcode" -ne "0" ]; then

        # Print the provided error message.
        if [ ! -z "$1" ]; then
            echo "Error: $1" >&2
        fi

        # Exit using the last command error code.
        exit $errorcode
    fi
}

################################################
# Set default variables if not set
################################################
function set_default_variables() {
    if [[ -z ${DB_TYPE} ]]; then
        DB_TYPE=pgsql
    fi
    if [[ -z ${DB_NAME} ]]; then
        DB_NAME=moodle
    fi
    if [[ -z ${DB_USER} ]]; then
        DB_USER=moodle
    fi
    if [[ -z ${DB_PASS} ]]; then
        DB_PASS=moodle
    fi
    if [[ -z ${DB_PREFIX} ]]; then
        DB_PREFIX=mdl_
    fi
    if [[ -z ${DB_PORT} ]]; then
        DB_PORT=''
    fi
    if [[ -z ${PHPUNIT_DB_PREFIX} ]]; then
        PHPUNIT_DB_PREFIX="p_"
    fi
    if [[ -z ${BEHAT_DB_PREFIX} ]]; then
        BEHAT_DB_PREFIX="b_"
    fi
    if [[ -z ${BEHAT_PROFILE} ]]; then
        BEHAT_PROFILE=firefox
    fi
    if [[ -z ${BEHAT_RUN} ]]; then
        BEHAT_RUN="0" # Process number
    fi
    if [[ -z ${BEHAT_TOTAL_RUNS} ]]; then
        BEHAT_TOTAL_RUNS="1" # Total number of processes
    fi
    if [[ -z ${SHARED_DIR} ]]; then
        SHARED_DIR=/shared
    fi
    if [[ -z ${SHARED_DATA_DIR} ]]; then
        SHARED_DATA_DIR=/shared_data
    fi
}

################################################
# Setup mssql
################################################
function set_db() {
    if [ "${DB_TYPE}" == "mssql" ]; then
        sudo sed -i "s/host = .*/host = ${DB_HOST}/g" /etc/freetds/freetds.conf
    fi
}

################################################
# Deletes the files
#
# Arguments:
#   * $1 => The file/directories to delete
#   * $2 => Set $2 will make the function exit if it is an unexisting file
#
# Accepts dir/*.extension format like ls or rm does.
#
################################################
function delete_files() {
    # Checking that the provided value is not empty or it is a "dangerous" value.
    # We can not prevent anything, just a few of them.
    if [ -z "$1" ] || \
            [ "$1" == "." ] || \
            [ "$1" == ".." ] || \
            [ "$1" == "/" ] || \
            [ "$1" == "./" ] || \
            [ "$1" == "../" ] || \
            [ "$1" == "*" ] || \
            [ "$1" == "./*" ] || \
            [ "$1" == "../*" ]; then
        echo "Error: delete_files() does not accept \"$1\" as something to delete" >&2
        exit 1
    fi

    # Checking that the directory exists. Exiting as it is a development issue.
    if [ ! -z "$2" ]; then
        test -e "$1" || \
            throw_error "The provided \"$1\" file or directory does not exist or is not valid."
    fi

    # Kill them all (ok, yes, we don't always require that options).
    rm -rf $1
}

################################################
# Checks that the provided cmd commands are properly set.
#
################################################
function check_cmds() {
    local readonly genericstr=" has a valid value or overwrite the default one using webserver_config.properties"

    php -v > /dev/null || \
        throw_error 'Ensure $phpcmd'$genericstr

    curl -V > /dev/null || \
        throw_error 'Ensure $curlcmd'$genericstr
}

# Check if required params are set
function check_required_params() {
    # DB_HOST should be set.
    if [[ -n ${DB_PORT_5432_TCP_ADDR} ]]; then
        DB_HOST=$DB_PORT_5432_TCP_ADDR
        DB_NAME=$DB_ENV_POSTGRES_USER
        DB_USER=$DB_ENV_POSTGRES_USER
        DB_PASS=$DB_ENV_POSTGRES_PASSWORD
    elif [[ -n ${DB_PORT_3306_TCP_ADDR} ]]; then
        DB_HOST=$DB_PORT_3306_TCP_ADDR
        DB_NAME=$DB_ENV_MYSQL_DATABASE
        DB_USER=$DB_ENV_MYSQL_USER
        DB_PASS=$DB_ENV_MYSQL_PASSWORD
    elif [[ -z "$DB_HOST" ]]; then
        echo "DB_HOST is not set."
        usage 1
    fi

    check_cmds
}

################################################
# Set config file
#
################################################
function set_moodle_config() {
    # If behat running then set ip to
    if [[ -z ${RUNNING_TEST} ]]; then
        if [[ -z ${MAP_WEB_SERVER_PORT} ]]; then
            DOCKERIPWEB=$DOCKERIP
        else
            DOCKERIPWEB="localhost:${MAP_WEB_SERVER_PORT}"
        fi
        DOCKERIPBEHAT='127.0.0.1'
    elif [[ ${RUNNING_TEST} = 'phpunit' ]]; then
        if [[ -z ${MAP_WEB_SERVER_PORT} ]]; then
            DOCKERIPWEB=$DOCKERIP
        else
            DOCKERIPWEB="localhost:${MAP_WEB_SERVER_PORT}"
        fi
        DOCKERIPBEHAT='127.0.0.1'
    else
        DOCKERIPWEB='127.0.0.1'
        if [[ -z ${MAP_WEB_SERVER_PORT} ]]; then
            DOCKERIPBEHAT=$DOCKERIP
        else
            DOCKERIPBEHAT="localhost:${MAP_WEB_SERVER_PORT}"
        fi
    fi

  # Copying from config template.
 replacements="%%DbType%%#${DB_TYPE}
%%DbHost%%#${DB_HOST}
%%DbName%%#${DB_NAME}
%%DbUser%%#${DB_USER}
%%DbPwd%%#${DB_PASS}
%%SiteDbPrefix%%#${DB_PREFIX}
%%DbPort%%#${DB_PORT}
%%DataDir%%#${MOODLE_DATA_DIR}
%%PhpUnitDataDir%%#${MOODLE_PHPUNIT_DATA_DIR}
%%PhpunitDbPrefix%%#${PHPUNIT_DB_PREFIX}
%%BehatDataDir%%#${MOODLE_BEHAT_DATA_DIR}
%%BehatDbPrefix%%#${BEHAT_DB_PREFIX}
%%SiteId%%#${BRANCH}
%%FailDumpDir%%#${MOODLE_FAIL_DUMP_DIR}
%%BehatTimingFile%%#${BEHAT_TIMING_FILE}
%%DockerContainerIp%%#${DOCKERIPWEB}
%%DockerContainerIpBehat%%#${DOCKERIPBEHAT}
%%Seleniumurls%%#${SELENIUM_URLS}
%%fromrun%%#${BEHAT_RUN}
%%totalrun%%#${BEHAT_TOTAL_RUNS}"


    # Apply template transformations.
    text="$( cat $CONFIG_TEMPLATE )"
    for i in ${replacements}; do
        text=$( echo "${text}" | sed "s#${i}#g" )
    done

    # Save the config.php into destination.
    echo "${text}" > $MOODLE_DIR/config.php
}

set_default_variables
