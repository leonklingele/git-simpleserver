#!/bin/sh

. "$TESTSDIR/common.sh"

users_list_count_must_equal() {
	local EXPECTED_COUNT="$1"
	local USER_LIST
	local EXIT_CODE

	set +e
	USER_LIST=$(git ss user list)
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
	local USER_LIST_COUNT=$(echo "$USER_LIST" | wc -l)
	if [ "$USER_LIST_COUNT" != "$EXPECTED_COUNT" ]; then
		echo "Error! Too many users available: $USER_LIST_COUNT, expected $EXPECTED_COUNT. Users found:\n$USER_LIST"
		exit 1
	fi
}

user_create() {
	local NAME="$1"
	local PUBLIC_KEY="$2"
	set +u
	local EXPECTED_ERROR_STRING="$3"
	set -u
	local OUT
	local EXIT_CODE

	set +e
	OUT=$(git ss user create -y "$NAME" "$PUBLIC_KEY")
	EXIT_CODE=$?
	set -e

	if [ $EXIT_CODE -ne 0 ]; then
		if [ -n "$EXPECTED_ERROR_STRING" ] && [ "$EXPECTED_ERROR_STRING" = "$OUT" ]; then
			# Everything is fine
			return 0
		fi
		echo "Error code $EXIT_CODE :: $OUT, name: '$NAME', public key: '$PUBLIC_KEY'"
		exit 1
	fi
}

user_delete() {
	local NAME="$1"
	set +u
	local EXPECTED_ERROR_STRING="$2"
	set -u
	local OUT
	local EXIT_CODE

	set +e
	OUT=$(git ss user delete -y "$NAME")
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

user_info() {
	local NAME="$1"
	set +u
	local EXPECTED_STRING="$2"
	set -u
	local OUT
	local EXIT_CODE

	set +e
	OUT=$(git ss user info "$NAME")
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
		echo "Error, didn't get expected info for user with name '$NAME': '$OUT'"
		exit 1
	fi
}
