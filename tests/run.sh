##
# Duke JAMF Package Workflow Definition
#
# https://github.com/duke-jamf-utilities/macos-pkgbuild
##

TESTS=`dirname "$0"`
SCRIPTS="$TESTS/../src"

tear_down()
{
	rm -rf "$TESTS/witch"
	rm -rf "$TESTS/cyberduck/*.pkg"
	rm -f "$TESTS/cyberduck/.manifest"
}

echo "************************************"
echo "* SOURCE (CASK)                    *"
echo "************************************"

"$SCRIPTS/source-cask.sh" "witch" "$TESTS"
RESULT=$?; if [ $RESULT -ne 0 ]; then tear_down; exit $RESULT; fi
if [ ! -f "$TESTS/witch/variables.sh" ]; then echo "FAIL!"; tear_down; exit 1; fi
echo "	PASS!"

echo "************************************"
echo "* CHECK (CASK)                     *"
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
echo "	PASS!"

echo "************************************"
echo "* CHECK (CASK)                     *"
echo "************************************"

printf "Current..."
RESULT=`"$SCRIPTS/check-cask.sh" "$TESTS/cyberduck"`
if [ "$RESULT" != "current" ]; then echo "	FAIL ($RESULT)"; tear_down; exit 1; fi
echo "	PASS!"

echo "************************************"
echo "* VERIFY (BASIC)                   *"
echo "************************************"

sudo "$SCRIPTS/verify.sh" "$TESTS/seashore"
RESULT=$?; if [ $RESULT -ne 0 ]; then tear_down; exit $RESULT; fi
echo "	PASS!"

echo "************************************"
echo "* VERIFY (CUSTOM)                  *"
echo "************************************"

sudo "$SCRIPTS/verify.sh" "$TESTS/cyberduck"
RESULT=$?; if [ $RESULT -ne 0 ]; then tear_down; exit $RESULT; fi
echo "	PASS!"

echo "All tests passed!"

tear_down
exit 0
