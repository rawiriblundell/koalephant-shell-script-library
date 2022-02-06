#@IgnoreInspection BashAddShebang
# String functionality (Koalephant Shell Script Library)
# Version: PACKAGE_VERSION
# Copyright: 2014-2019, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>


# Parse a string into an integer
# Accepts decimal or hex values, any precision (right of the decimal point) is lost
#
# Input:
# $1 - the string to parse
# $2 - the default value to return if the string is not an integer
#
# Output:
# an integer or the default value if specified
#
# Return:
# 0 if either the first or second argument can be parsed to int, 1 if not
k_int_parse() {
	# shellcheck disable=SC2039
	local string int default
	k_requires_args k_int_parse "$#"

	string="${1}"
	default="${2:-}"

	if ! k_int_parse_error "${string}" 2>/dev/null && [ -n "${default}" ] && ! k_int_parse_error "${default}" 2>/dev/null; then
		k_log_err 'Invalid default integer value: "%s"' "${default}"
		return 1
	fi
}

# Parse a string into an integer or error
# Accepts decimal or hex values, any precision (right of the decimal point) is lost
#
# Input:
# $1 - the string to parse
#
# Output:
# an integer
#
# Return:
# 0 if the string can be parsed to an integer 1 if not
k_int_parse_error() {
	# shellcheck disable=SC2039
	local string int
	k_requires_args k_int_parse_error "$#"

	string="$(k_string_trim "$(k_string_remove_end ".[0-9]*" "$1")")" # Cannot use [[:digit:]] in posh or mksh

	if [ -n "${string}" ]; then
		if int="$(printf -- '%d' "${string}" 2>/dev/null)"; then
			printf -- '%d' "${int}"
			return 0
		fi
	fi

	k_log_err 'Cannot parse "%s" as integer' "${1}"
	return 1
}

# Get the lowest of a series of integers
#
# Input:
# $1...n - the integers to get the lowest of
#
# Output:
# the lowest value
#
# Return
# 1 if any of the numbers cannot be parsed to an integer
k_int_min() {
	# shellcheck disable=SC2039
	local min='' i

	k_requires_args k_int_min "$#"

	while [ "$#" -gt 0 ]; do
		i="$(k_int_parse_error "$1")" || return "$?"
		if [ -z "${min}" ] || [ "$i" -lt "$min" ]; then
			min="$i"
		fi
		shift
	done

	printf -- '%d' "$min"
}

# Get the highest of a series of integers
#
# Input:
# $1...n - the integers to get the highest of
#
# Output:
# the highest value
#
# Return
# 1 if any of the numbers cannot be parsed to an integer
k_int_max() {
	# shellcheck disable=SC2039
	local max='' i

	k_requires_args k_int_max "$#"

	while [ "$#" -gt 0 ]; do
		i="$(k_int_parse_error "$1")" || return "$?"
		if [ -z "${max}" ] || [ "$i" -gt "${max}" ]; then
			max="$i"
		fi
		shift
	done

	printf -- '%d' "$max"
}

# Get the sum of a series of integers
#
# Input:
# $1...n - the integers to get sum average of
#
# Output:
# the sum of the values
#
# Return
# 1 if any of the numbers cannot be parsed to an integer
k_int_sum() {
	# shellcheck disable=SC2039
	local sum i

	while [ "$#" -gt 0 ]; do
		i="$(k_int_parse_error "$1")" || return "$?"
		sum=$(( sum + i ))
		shift
	done

	printf -- '%d' "${sum}"
}

# Get the average of a series of integers
#
# Input:
# $1...n - the integers to get the average of
#
# Output:
# the average value
#
# Return
# 1 if any of the numbers cannot be parsed to an integer
k_int_avg() {
	printf -- '%d' $(( $(k_int_sum "$@") / $# ))
}
