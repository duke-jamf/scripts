##
# Duke JAMF Package Workflow Definition
#
# https://github.com/duke-jamf-utilities/macos-pkgbuild
##

APP="/Applications/Cyberduck.app"

# Confirm the app exists
if [ ! -d "$APP" ]; then
	echo "Application not found: $APP"
	exit 1
fi

# Try launching it
open "$APP"
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo "Unable to launch application: $APP"
	exit 2
fi

exit 0
