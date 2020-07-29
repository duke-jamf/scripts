#!/bin/sh

##
# Duke JAMF Package Workflow Utility
# https://github.com/duke-jamf-utilities/macos-pkgbuild
#
# Takes the name of a valid Homebrew Cask and creates a .pkg
##

# Check dependencies
if [ $# -lt 1 ]; then
    echo "Usage: cask2pkg.sh {cask_token} [pkgbuild_options]"
    exit 1
fi
if [ ! "`which brew`" ]; then
    echo "ERROR: Homebrew not found!"
    exit 2
fi
TOKEN=$1
shift

# Verify the Cask
brew cask info $TOKEN
RESULT=$?
if [ $RESULT -ne 0 ]; then
	exit $RESULT
fi

# Load attributes
CASKNAME=`brew cask _stanza name $TOKEN | tr -d '["]'`
CASKVERSION=`brew cask _stanza version $TOKEN`

# Install/update the Cask
brew cask install $TOKEN
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo "Installation failed! Quitting..."
	exit $RESULT
fi

# Stage resources
TMPDIR=`mktemp -d -t cask2pkg`
PKGDIR=`brew cask info $TOKEN | awk 'NR==3 { print $1 }'`

for LINK in "$PKGDIR/*"; do
	FILE=`readlink $LINK`
	rsync --archive --relative "$FILE" "$TMPDIR"
done

PKGNAME="$CASKNAME $CASKVERSION.pkg"
pkgbuild "$@" --root "$TMPDIR" "./$PKGNAME"
RESULT=$?

if [ $RESULT -ne 0 ]; then
	echo "Failed to create package!"
	rm -rf "$TMPDIR"
	exit $RESULT
fi

echo "Package build successful:"
echo `pwd`"/$PKGNAME"

# Generate the manifest
MANIFEST=`pwd`"/.manifest"

date > "$MANIFEST"
echo "$TOKEN" >> "$MANIFEST"
echo "$CASKVERSION" >> "$MANIFEST"
echo "$PKGNAME" >> "$MANIFEST"

exit 0
