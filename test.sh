#!/bin/sh

IM_SURE="--i-know-what-im-doing"
if [ "$1" != "$IM_SURE" ]; then
	echo "Please execute $0 $IM_SURE"
	exit 1
fi

set -euf #o pipefail

list_repos_count_must_equal() {
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

create_repo() {
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
		echo "Error code $EXIT_CODE :: $OUT"
		exit 1
	fi
}

delete_repo() {
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
		echo "Error code $EXIT_CODE :: $OUT"
		exit 1
	fi
}

list_repos_count_must_equal "0"
create_repo "test" # should not fail
list_repos_count_must_equal "1"
create_repo "test2" # should not fail
list_repos_count_must_equal "2"
create_repo "test3" # should not fail
list_repos_count_must_equal "3"
create_repo "test2" "Error! Repo 'test2' already exists" # create test a second time, should fail
list_repos_count_must_equal "3"

delete_repo "test"
list_repos_count_must_equal "2"
delete_repo "test" "Error! Repo 'test' does not exist"
list_repos_count_must_equal "2"

echo "Yay! Everything works fine :)"
