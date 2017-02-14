#!/bin/sh

IM_SURE="--i-know-what-im-doing"
if [ "$1" != "$IM_SURE" ]; then
	echo "Please execute $0 $IM_SURE"
	exit 1
fi

set -euf #o pipefail

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
		echo -e "Error! Too many users available: $USER_LIST_COUNT, expected $EXPECTED_COUNT. Users found:\n$USER_LIST"
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

INVALID_REPO_NAME_ERROR_MSG="Error! Disallowed characters in repo name. Allowed: a-z, A-Z, 0-9, _, -"
INVALID_USER_NAME_ERROR_MSG="Error! Disallowed characters in user name. Allowed: a-z, A-Z, 0-9, _, -"
INVALID_SSH_KEY_ERROR_MSG="Error! Not a valid public key! SSH public keys must start with 'ssh-'"

repos_list_count_must_equal "0"
repo_create "test" # should not fail
repos_list_count_must_equal "1"
repo_create "test2" # should not fail
repos_list_count_must_equal "2"
repo_create "test3" # should not fail
repos_list_count_must_equal "3"
repo_create "test2" "Error! Repo 'test2' already exists" # create test a second time, should fail
repos_list_count_must_equal "3"
repo_create "my test" "$INVALID_REPO_NAME_ERROR_MSG"
repo_create "my.test" "$INVALID_REPO_NAME_ERROR_MSG"
repo_create "my–test" "$INVALID_REPO_NAME_ERROR_MSG" # endash
repo_create 'my\\test' "$INVALID_REPO_NAME_ERROR_MSG"
repo_create "my+test" "$INVALID_REPO_NAME_ERROR_MSG"
repo_create "my/test" "$INVALID_REPO_NAME_ERROR_MSG"
repos_list_count_must_equal "3"

repo_delete "test"
repos_list_count_must_equal "2"
repo_delete "test" "Error! Repo 'test' does not exist"
repos_list_count_must_equal "2"
repo_delete "my/test" "$INVALID_REPO_NAME_ERROR_MSG" # just to make sure slash never works
repos_list_count_must_equal "2"

repo_info "test2" "Users with read access:
  leon
Users with write access:
  leon"
repo_access "test2" "-rw" "blubb" "User 'blubb' now has read access
User 'blubb' now has write access"
repo_info "test2" "Users with read access:
  leon
  blubb
Users with write access:
  leon
  blubb"
repo_access "test2" "-r" "blubb" "User 'blubb' already has read access
User 'blubb' no longer has write access"
repo_info "test2" "Users with read access:
  leon
  blubb
Users with write access:
  leon"
repo_access "test2" "-rm" "blubb" "User 'blubb' no longer has read access
User 'blubb' no longer has write access"
repo_info "test2" "Users with read access:
  leon
Users with write access:
  leon"

repo_info "test-lala" "Error! Repo 'test-lala' does not exist"

users_list_count_must_equal "1"
user_create "test" "ssh-rsa"
users_list_count_must_equal "2"
user_create "test2" "ssh-ed25519"
users_list_count_must_equal "3"
user_create "invalid-ssh" "invalid-ssh" "$INVALID_SSH_KEY_ERROR_MSG"
user_create "invalid-ssh" "ssh" "$INVALID_SSH_KEY_ERROR_MSG"
users_list_count_must_equal "3"

user_delete "test2"
users_list_count_must_equal "2"
user_delete "test2" "Error! User 'test2' does not exist"
users_list_count_must_equal "2"
user_delete "/" "$INVALID_USER_NAME_ERROR_MSG"
user_delete "=" "$INVALID_USER_NAME_ERROR_MSG"
users_list_count_must_equal "2"

# TODO(leon): Fix this test
user_info "leon" "User 'leon' has read access to:
  leon/test2
  leon/test3
User 'leon' has write access to:
  leon/test2
  leon/test3"
# TODO(leon): Fix this test
#user_info "test4" "Error! User 'test4' does not exist"

echo "Yay! Everything works fine :)"
