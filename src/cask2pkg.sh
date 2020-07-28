#!/bin/sh

##
# Duke JAMF Package Workflow Utility
# https://github.com/duke-jamf-utilities/macos-pkgbuild
#
# Takes the name of a valid Homebrew Cask and creates a .pkg
##

# Check dependencies
if [ $# -lt 1 ]; then
    echo "Usage: cask2pkg.sh {cask_token}"
    exit 1
fi
if [ ! "`which brew`" ]; then
    echo "ERROR: Homebrew not found!"
    exit 2
fi
TOKEN=$1

# Verify the Cask
brew cask info $TOKEN
RESULT=$?
if [ $RESULT -ne 0 ]; then
	exit $RESULT
fi

# Load attributes
PKGNAME=`brew cask _stanza name $TOKEN`
PKGVERSION=`brew cask _stanza version $TOKEN`

# Install/update the Cask
brew cask install $TOKEN
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo "Installation failed! Quitting..."
	exit $RESULT
fi

# Stage resources
TMPDIR=`mktemp -d -t cask2pkg`
PKGDIR=`brew cask info cyberduck | awk 'NR==3 { print $1 }'`

for LINK in "$PKGDIR/*"; do
	FILE=`readlink $LINK`
	rsync --archive --relative "$FILE" "$TMPDIR"
done

echo $TMPDIR
