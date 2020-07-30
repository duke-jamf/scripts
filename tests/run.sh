##
# Duke JAMF Package Workflow Definition
#
# https://github.com/duke-jamf-utilities/macos-pkgbuild
##

TESTS=`dirname "$0"`
SCRIPTS="$TESTS/../src"

tear_down()
{
	rm -f "$TESTS/cyberduck/.manifest"
	rm -f "$TESTS/cyberduck/*.pkg"
}

echo "************************************"
echo "* CHECK (CASK)                       *"
echo "************************************"

printf "Missing..."
RESULT=`"$SCRIPTS/check-cask.sh" "$TESTS/cyberduck"`
if [ "$RESULT" != "missing" ]; then echo "	FAIL ($RESULT)"; tear_down; exit 1; fi
echo "	PASS!"

printf "Outdated..."
RESULT=`"$SCRIPTS/check-cask.sh" "$TESTS/seashore"`
if [ "$RESULT" != "outdated" ]; then echo "	FAIL ($RESULT)"; tear_down; exit 1; fi
echo "	PASS!"

echo "************************************"
echo "* BUILD                            *"
echo "************************************"

"$SCRIPTS/build.sh" "$TESTS/cyberduck"
RESULT=$?; if [ $RESULT -ne 0 ]; then tear_down; exit $RESULT; fi

echo "************************************"
echo "* CHECK (CASK)                       *"
echo "************************************"

printf "Current..."
RESULT=`"$SCRIPTS/check-cask.sh" "$TESTS/cyberduck"`
if [ "$RESULT" != "current" ]; then echo "	FAIL ($RESULT)"; tear_down; exit 1; fi
echo "	PASS!"

echo "************************************"
echo "* VERIFY (BASIC) ***"
echo "************************************"

sudo "$SCRIPTS/verify.sh" "$TESTS/seashore"
RESULT=$?; if [ $RESULT -ne 0 ]; then tear_down; exit $RESULT; fi

echo "************************************"
echo "* VERIFY (CUSTOM) ***"
echo "************************************"

sudo "$SCRIPTS/verify.sh" "$TESTS/cyberduck"
RESULT=$?; if [ $RESULT -ne 0 ]; then tear_down; exit $RESULT; fi

echo "All tests passed!"

tear_down
exit 0
