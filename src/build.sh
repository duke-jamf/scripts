#!/bin/sh

##
# Duke JAMF Package Workflow Utility
# https://github.com/duke-jamf-utilities/macos-pkgbuild
#
# Takes a package definition as input and builds a .pkg
##

if [ $# -lt 1 ]; then
    echo "Usage: build.sh {path/to/definition}"
    exit 1
fi

SCRIPTS=`dirname "$0"`
DEFINITION="$1"

# Load variables from the definition
. "$DEFINITION/variables.sh"

echo "Installing $PKGNAME via $PKGTYPE"

case $PKGTYPE in
	cask)
		"$SCRIPTS/build-cask.sh" $PKGSLUG $PKGARGS
		RESULT=$?
		if [ $RESULT -ne 0 ]; then
			echo "Unable to convert Cask to package: $PKGSLUG"
			exit $RESULT
		fi
		
		# Move the package and manifest into the definitions directory
		PKGNAME=`tail -n 1 ".manifest"`
		mv "$PKGNAME" "$DEFINITION/"
		mv ".manifest" "$DEFINITION/"

		break
		;;
esac

echo "Build of $PKGNAME succeeded!"

exit 0
