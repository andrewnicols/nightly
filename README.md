Nightly Runner
==============

Note: This is still a work-in-progress.

Setup
-----
Create `config` file with contents:

    BASEDIR="/your/preferred/workspace/dir"

If you do not provide a basedir, then the default of /store will be used.

Perform initialisation. This creates a clone of integration.git as a seed.

    ./init.sh

Running tasks
-------------

To run a task:

    ./run_task.sh

To specify a specific DB or DB version:

    export DB=mysqli
    export DB_VERSION=5.6

To specify a specific version of PHP:

    export PHP=56

To run a different task:

    export TASK=behat

Status
------

Currently supported PHP versions:
* 5.6
* 7.0

Currently supported Databases:
* mariadb
* pgsql
* mysqli

Currently supported tasks:
* phpunit

Remaining to-do items:
* Add support for additional PHP versions
* Add support for Oracle
** Oracle support is part-way through implementation but the phpunit setup is not completing
* Add support for MSSQL
* Add support for Behat
* Add support for DB server tuning specific to the host machine
