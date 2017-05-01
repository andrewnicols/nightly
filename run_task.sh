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
echo "############################################################################"
echo "### Starting nightly (Version ${THISVERSION})"
echo "############################################################################"
echo "############################################################################"

# Perform setup.
. "${INCPATH}/setup"
