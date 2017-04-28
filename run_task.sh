#!/bin/bash

set -e

echo "############################################################################"

# Grab the script directory.
# We need this to form reliable paths to our libraries.
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null
INCPATH="${SCRIPTPATH}/inc"

# Perform setup
. "${INCPATH}/setup"

echo "# Running job '${UNIQID}'"
echo "# Requested target ${TARGET} ${TARGET_ARGS}"
echo "# Requested database ${DB} ${DBVERSION}"

# Setup database
. "${INCPATH}/database"

# Setup the codebase to be tested.
. "${INCPATH}/codebase"

# Perform setup for the specified target.
. "${INCPATH}/target"

# TODO
PHP_SERVER_DOCKER='rajeshtaneja/php:7.0'

echo "# Starting ${UNIQID} run for ${TARGET} ${TARGET_ARGS}"
echo "# Database: ${DB}"
echo "# PHP Image: ${PHP_SERVER_DOCKER}"
echo "############################################################################"

cd "${TEMPDIR}"
DOCKER_MOODLE_PATH=/var/www/html/moodle

echo "# Starting docker run"
DOCKER_RUN_ARGS_VOLS="-v ${WORKSPACE}:${DOCKER_MOODLE_PATH}:rw -v ${CACHEDIR}/composer:/.composer/cache:rw"
DOCKER_RUN_ARGS_ENTRY="--entrypoint ${ENTRYPOINT}"
DOCKER_RUN_ARGS_DB="--dbtype=${DBTYPE} --dbhost=${HOST_DB} --dbname=${DBNAME} --phpunitdbprefix=${DBPREFIX} --dbuser=${DBUSER} --dbpass=${DBPASS}"
DOCKER_RUN_ARGS=" ${DOCKER_RUN_ARGS_VOLS} ${DOCKER_RUN_ARGS_ENTRY} ${PHP_SERVER_DOCKER} ${DOCKER_RUN_ARGS_DB} $EXTRA_OPT --forcedrop"
docker run -i --rm -u `id -u $USER` -e "COMPOSER_CACHE_DIR=/.composer/cache" --name ${HOST_PHP} --network "${NETWORK}" ${DOCKER_RUN_ARGS}
EXITCODE=$?

echo "# Run completed with exit code of ${EXITCODE}"

exit $EXITCODE
