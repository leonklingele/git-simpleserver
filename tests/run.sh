#!/bin/sh

IM_SURE="--i-know-what-im-doing"
if [ "$1" != "$IM_SURE" ]; then
	echo "Please execute $0 $IM_SURE"
	exit 1
fi

export TESTSDIR=$(dirname "$0")

. "$TESTSDIR/common.sh"

export USER_NAME="$(whoami)"

FAILED=false
# TODO(leon): Don't use for loop
for FILE in $(find . -name "*.test" | LC_ALL=C sort); do
	set +e
	OUT=$("$FILE")
	EXIT_CODE=$?
	set -e
	if [ $EXIT_CODE -ne 0 ]; then
		FAILED=true
		echo "Test '$FILE' failed with exit code $EXIT_CODE: $OUT"
	fi
done

if [ $FAILED = true ]; then
	echo "Some tests failed. :("
	exit 1
fi
echo "Yay! Everything works fine :)"
