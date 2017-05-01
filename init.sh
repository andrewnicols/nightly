#!/bin/bash

set -e

# Grab the script directory.
# We need this to form reliable paths to our libraries.
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null
INCPATH="${SCRIPTPATH}/inc"

pushd "${SCRIPTPATH}" > /dev/null
THISVERSION=`git rev-parse HEAD`
popd > /dev/null

echo "############################################################################"
echo "###"
echo "### Initialising nightly script caches (${THISVERSION})"
echo "###"
echo "############################################################################"
echo

# Load the config file if present.
CONFIGPATH="${SCRIPTPATH}/config"
if [ -f "${CONFIGPATH}" ]
then
  echo -n "# Loading host configuration read from ${CONFIGPATH}"
  . "${CONFIGPATH}"
  echo ". done."
fi

echo -n "# Performing pre-job setup"

# Load defaults.
. "${INCPATH}/defaults"
echo -n "."

# Load the include functions.
. "${INCPATH}/functions"
echo -n "."
echo " done."

git clone --bare "${TESTREPO}" "${SEEDREPO}"
