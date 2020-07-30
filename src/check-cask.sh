#!/bin/sh

##
# Duke JAMF Package Workflow Utility
# https://github.com/duke-jamf-utilities/macos-pkgbuild
#
# Checks a manifest against available versions.
# Outputs one of the following: missing, outdated, current
##

if [ $# -lt 1 ]; then
    echo "Usage: check-cask.sh {path/to/definition}"
    exit 1
fi

SCRIPTS=`dirname "$0"`
DEFINITION="$1"
MANIFEST="$DEFINITION/.manifest"

# Load variables from the definition
. "$DEFINITION/variables.sh"

# Check for a manifest
if [ ! -f "$MANIFEST" ]; then
	echo "missing"
	exit 0
fi

# Compare the versions
TOKEN=`awk 'NR==2' $DEFINITION/.manifest`
CURRENT=`awk 'NR==3' $DEFINITION/.manifest`
LATEST=`brew cask _stanza version $TOKEN`
if [ "$CURRENT" != "$LATEST" ]; then
	echo "outdated"
	exit 0
fi

echo "current"
exit 0
