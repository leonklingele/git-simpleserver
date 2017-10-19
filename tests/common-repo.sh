#!/bin/sh

. "$TESTSDIR/common.sh"

repos_list_count_must_equal() {
	local EXPECTED_COUNT="$1"
	local REPO_LIST
	local EXIT_CODE

	set +e
	REPO_LIST=$(git ss repo list)
	EXIT_CODE=$?
	set -e

	if [ $EXIT_CODE -ne 0 ]; then
		if [ "$EXPECTED_COUNT" = "0" ]; then
			# Everything is fine
			return 0
		fi
		echo "Error code $EXIT_CODE :: $REPO_LIST"
		exit 1
	fi
	local REPO_LIST_COUNT=$(echo "$REPO_LIST" | wc -l)
	if [ "$REPO_LIST_COUNT" != "$EXPECTED_COUNT" ]; then
		echo "Error! Too many repos available: $REPO_LIST_COUNT, expected $EXPECTED_COUNT. Found repos:\n$REPO_LIST"
		exit 1
	fi
}

repo_create() {
	local NAME="$1"
	set +u
	local EXPECTED_ERROR_STRING="$2"
	set -u
	local OUT
	local EXIT_CODE

	set +e
	OUT=$(git ss repo create -y "$NAME")
	EXIT_CODE=$?
	set -e

	if [ $EXIT_CODE -ne 0 ]; then
		if [ -n "$EXPECTED_ERROR_STRING" ] && [ "$EXPECTED_ERROR_STRING" = "$OUT" ]; then
			# Everything is fine
			return 0
		fi
		echo "Error code $EXIT_CODE :: $OUT, name: '$NAME'"
		exit 1
	fi
}

repo_delete() {
	local NAME="$1"
	set +u
	local EXPECTED_ERROR_STRING="$2"
	set -u
	local OUT
	local EXIT_CODE

	set +e
	OUT=$(git ss repo delete -y "$NAME")
	EXIT_CODE=$?
	set -e

	if [ $EXIT_CODE -ne 0 ]; then
		if [ -n "$EXPECTED_ERROR_STRING" ] && [ "$EXPECTED_ERROR_STRING" = "$OUT" ]; then
			# Everything is fine
			return 0
		fi
		echo "Error code $EXIT_CODE :: $OUT, name: '$NAME'"
		exit 1
	fi
}

repo_access() {
	local REPO_NAME="$1"
	local ACCESS_MODE="$2"
	local USER_NAME="$3"
	local EXPECTED_STRING="$4"
	local OUT
	local EXIT_CODE

	set +e
	OUT=$(git ss repo access "$REPO_NAME" "$ACCESS_MODE" "$USER_NAME")
	EXIT_CODE=$?
	set -e

	if [ $EXIT_CODE -ne 0 ]; then
		if [ -n "$EXPECTED_STRING" ] && [ "$EXPECTED_STRING" = "$OUT" ]; then
			# Everything is fine
			return 0
		fi
		echo "Error code $EXIT_CODE :: $OUT, name: '$REPO_NAME', access mode: '$ACCESS_MODE', user name: '$USER_NAME'"
		exit 1
	else
		if [ -n "$EXPECTED_STRING" ] && [ "$EXPECTED_STRING" = "$OUT" ]; then
			# Everything is fine
			return 0
		fi
		echo "Error, didn't get expected result for repo '$REPO_NAME', access mode '$ACCESS_MODE', user '$USER_NAME': '$OUT'"
		exit 1
	fi
}

repo_info() {
	local NAME="$1"
	local EXPECTED_STRING="$2"
	local OUT
	local EXIT_CODE

	set +e
	OUT=$(git ss repo info "$NAME")
	EXIT_CODE=$?
	set -e

	if [ $EXIT_CODE -ne 0 ]; then
		if [ -n "$EXPECTED_STRING" ] && [ "$EXPECTED_STRING" = "$OUT" ]; then
			# Everything is fine
			return 0
		fi
		echo "Error code $EXIT_CODE :: $OUT, name: '$NAME'"
		exit 1
	else
		if [ -n "$EXPECTED_STRING" ] && [ "$EXPECTED_STRING" = "$OUT" ]; then
			# Everything is fine
			return 0
		fi
		echo "Error, didn't get expected info for repo with name '$NAME': '$OUT'"
		exit 1
	fi
}
