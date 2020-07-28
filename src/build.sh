#!/bin/sh

##
# Duke JAMF Package Workflow Utility
# https://github.com/duke-jamf-utilities/macos-pkgbuild
#
# Takes a package definition as input and builds a .pkg
##

if [ $# -lt 1 ]; then
    echo "Usage: build.sh {path_to_definition}"
    exit 1
fi

# Load variables from the definition
. "$1"

echo "Installing $PKGNAME via $PKGTYPE"

case $PKGTYPE in
	cask)
		brew cask install $PKGSLUG $BREWARGS
		break
		;;
esac
