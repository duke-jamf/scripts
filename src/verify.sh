#!/bin/sh

##
# Duke JAMF Package Workflow Utility
# https://github.com/duke-jamf-utilities/macos-pkgbuild
#
# Tests a package build against its definition.
##

if [ $# -lt 1 ]; then
    echo "Usage: verify.sh {path/to/definition} [target_volume]"
    exit 1
fi

DEFINITION="$1"
SCRIPTS=`dirname "$0"`
MANIFEST="$1/.manifest"
TARGET="$2"
if [ ! "$TARGET" ]; then
	TARGET="/"
fi

# Load variables from the definition
. "$DEFINITION/variables.sh"

# Get the package from the manifest
if [ ! -f "$MANIFEST" ]; then
	echo "Unable to locate the build manifest: $MANIFEST"
	exit 2
fi

PKGNAME=`tail -n 1 "$MANIFEST"`
PKGFILE="$DEFINITION/$PKGNAME"
if [ ! -f "$PKGFILE" ]; then
	echo "Unable to locate the package: $PKGFILE"
	exit 2
fi

# Verify it's a legit package
installer -pkginfo -pkg "$PKGFILE"
RESULT=$?
if [ $RESULT -ne 0 ]; then
	exit $RESULT
fi

# Attempt installation
installer -target / -pkg "$PKGFILE"
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo "Package failed to install"
	exit $RESULT
fi

# Check for a custom verification script
if [ -x "$DEFINITION/verify.sh" ]; then
	sh "$DEFINITION/verify.sh"
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		exit $RESULT
	fi

	echo "Verified (custom) package: $PKGFILE"
	exit 0
fi

# Try to launch any apps specified by the payload
for APP in `pkgutil --payload-files "$PKGFILE" | awk '/.\.app$/{ print $0 }'`; do
	if [ -d "$TARGET$APP" ]; then
		echo "Attempting to launch $APP..."
		open "$TARGET$APP"
		RESULT=$?
		if [ $RESULT -ne 0 ]; then
			echo "Unable to launch application: $TARGET$APP"
			exit $RESULT
		fi
	fi
done

echo "Verified (basic) package: $PKGFILE"
exit 0
