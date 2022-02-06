#@IgnoreInspection BashAddShebang
# Boolean functionality (Koalephant Shell Script Library)
# Version: PACKAGE_VERSION
# Copyright: 2014, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Parse a string into 'true' or 'false'
# 'true' values are 'on', 'true', 'yes', 'y' and '1', regardless of case
# 'false' values are 'off', 'false' 'no', 'n' and '0', regardless of case
#
# Input:
# $1 - the string to parse
# $2 - the default value to return if neither true or false is matched
#
# Output:
# either 'true' or 'false' or the default value if specified
k_bool_parse() {
	# shellcheck disable=SC2039
	local value default

	k_requires_args k_bool_parse "$#"

	if value="$(k_bool_keyword "$1")"; then
		printf -- '%s\n' "${value}"
	elif default="$(k_bool_keyword "${2:-false}")"; then
		printf -- '%s\n' "${default}"
	fi
}

# Parse a string into 'true' or 'false' or error
# 'true' values are 'on', 'true', 'yes', 'y' and '1', regardless of case
# 'false' values are 'off', 'false' 'no', 'n' and '0', regardless of case
#
# Input:
# $1 - the string to parse
#
# Output:
# either 'true' or 'false'
#
# Return:
# 0 if a valid bool value is given, 1 if not
k_bool_keyword() {
	# shellcheck disable=SC2039
	local res=0

	k_requires_args k_bool_keyword "$#"
	k_bool_status "$1" && res="$?" || res="$?"

	if [ "${res}" -eq 0 ]; then
		printf -- '%s\n' true
		return 0
	elif [ "${res}" -eq 1 ]; then
		printf -- '%s\n' false
		return 0
	else
		return "${res}"
	fi
}

# Parse a string into a return code representing true, false or error
#
# 'true' values are 'on', 'true', 'yes', 'y' and '1', regardless of case
# 'false' values are 'off', 'false' 'no', 'n' and '0', regardless of case
#
# Input:
# $1 - the string to parse
#
# Return:
# 0 if the string parsed as true, 1 if parsed as false, 2 otherwise
k_bool_status() {
	k_requires_args k_bool_status "$#"

	case "$(k_string_lower "${1}")" in
		(on|true|yes|y|1)
			return 0
		;;

		(off|false|no|n|0)
			return 1
		;;

		(*)
			k_log_debug "Cannot parse '${1}' as bool"
			return 2
		;;

	esac
}

# Test a variable for truthiness.
# Uses (#k_bool_parse) to parse input
#
# Input:
# $1 - the variable to test
# $2 - the default value to test if neither true or false is matched
#
# Return:
# 0 if true, 1 if not
#
# Example:
# if k_string_test_bool "${optionValue}"; then
# 	do_something
# fi
k_bool_test() {
	# shellcheck disable=SC2039
	local res=''

	k_requires_args k_bool_test "$#"
	k_bool_status "$1"

	res="$?"

	case "${res}" in
		(0|1)
			return "${res}"
		;;

		(*)
			k_bool_status "${2:-false}"
		;;
	esac
}

# Test a variable for booelan-ness
# Uses (#k_bool_parse) to parse input
#
# Input:
# $1 - the variable to test
#
# Return:
# 0 if a valid boolean value, 1 if not
k_bool_valid() {
	# shellcheck disable=SC2039
	local res
	k_requires_args k_bool_valid "$#"
	k_bool_status "$1" && res="$?" || res="$?"
	[ "${res}" -le 1 ]
}
