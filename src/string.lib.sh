#@IgnoreInspection BashAddShebang
# String functionality (Koalephant Shell Script Library)
# Version: PACKAGE_VERSION
# Copyright: 2014-2017, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Get a line from a multiline variable
#
# Input:
# $1 - the line number to fetch, starting from 1
# $2...n - all remaining arguments are treated as the text to search. If `$2` is `-` or arg count is < 2, reads from STDIN.
#
# Output:
# The text on the specified line
k_string_get_line() {
	# shellcheck disable=SC2039
	local lineNo

	k_requires_args k_string_get_line "$#"

	lineNo="$(k_int_parse_error "${1}")" || return "$?"
	shift

	get_line() {
		sed -E -n -e "${lineNo}p"
	}

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		get_line
	else
		k_requires_args k_string_get_line "$(( $# + 1 ))" 2
		printf -- '%s\n' "$@" | get_line
	fi
}

# Get multiple lines from a multiline variable
#
# Input:
# $1 - the first line number to fetch, starting from 1
# $2 - the number of lines to fetch
# $3...n - all remaining arguments are treated as the text to search. If `$3` is `-` or arg count is < 3, reads from STDIN.
#
# Output:
# The text on the specified lines
k_string_get_lines() {
	# shellcheck disable=SC2039
	local start lines

	k_requires_args k_string_get_line "$#" 2

	start="$(k_int_parse_error "${1}")" || return "$?"
	lines="$(k_int_parse_error "${2}")" || return "$?"
	shift 2

	get_lines() {
		sed -E -n -e "${start},$(( start + lines - 1 ))p"
	}

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		get_lines
	else
		k_requires_args k_string_get_line "$(( $# + 1 ))" 2
		printf -- '%s\n' "$@" | get_lines
	fi
}

# Right Pad a string to the given length
#
# Input:
# $1 - the length to pad to
# $2...n - all remaining arguments are treated as the text to pad. If `$2` is `-` or arg count is < 2, reads from STDIN.

# Output:
# The string, with padding applied
k_string_pad_right() {
	# shellcheck disable=SC2039
	local length string

	k_requires_args k_string_pad_right "$#"

	length="$(k_int_parse_error "${1}")"  || return "$?"
	shift

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		string="$(cat -)"
	else
		k_requires_args k_string_pad_right "$(( $# + 1 ))" 2
		string="$*"
	fi

	printf -- "%-${length}s" "${string}"
}

# Left Pad a string to the given length
#
# Input:
# $1 - the length to pad to
# $2...n - all remaining arguments are treated as the text to pad. If `$2` is `-` or arg count is < 2, reads from STDIN.

# Output:
# The string, with padding applied
k_string_pad_left() {
	# shellcheck disable=SC2039
	local length string

	k_requires_args k_string_pad_left "$#"

	length="$(k_int_parse_error "${1}")" || return "$?"
	shift

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		string="$(cat -)"
	else
		k_requires_args k_string_pad_left "$(( $# + 1 ))" 2
		string="$*"
	fi

	printf -- "%+${length}s" "${string}"
}

# Convert a string to lower case
#
# Input:
# $1...n - all arguments are treated as the text to convert. If `$1` is `-` or arg count is < 1, reads from STDIN.
#
# Output:
# The string, converted to lower case
k_string_lower() {
	lower() {
		LC_CTYPE=C tr '[:upper:]' '[:lower:]'
	}

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		lower
	else
		k_requires_args k_string_lower "$(( $# + 1 ))"
		printf -- '%s\n' "$*" | lower
	fi
}

# Convert a string to upper case
#
# Input:
# $1...n - all arguments are treated as the text to convert. If `$1` is `-` or arg count is < 1, reads from STDIN.
#
# Output:
# The string, converted to upper case
k_string_upper() {
	upper() {
		LC_CTYPE=C tr '[:lower:]' '[:upper:]'
	}

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		upper
	else
		k_requires_args k_string_upper "$(( $# + 1 ))"
		printf -- '%s\n' "$*" | upper
	fi
}

# Test if a string contains the given substring
#
# Input:
# $1 - the substring to check for
# $2...n - all arguments are treated as the string to check in. If `$2` is `-` or arg count is < 2, reads from STDIN.
#
# Return:
# 0 if substring is found, 1 if not
k_string_contains() {
	# shellcheck disable=SC2039
	local substring string

	k_requires_args k_string_contains "$#"

	substring="${1}"
	shift

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		string="$(cat -)"
	else
		k_requires_args k_string_contains "$(( $# + 1 ))" 2
		string="$*"
	fi

	if [ "${#string}" -gt 0 ] && [ "${string%*${substring}*}" != "${string}" ]; then
		return 0
	fi

	return 1
}

# Test if a string starts with the given substring
#
# Input:
# $1 - the substring to check for
# $2...n - all arguments are treated as the string to check in. If `$2` is `-` or arg count is < 2, reads from STDIN.
#
# Return:
# 0 if the string starts with substring, 1 if not
k_string_starts_with() {
	# shellcheck disable=SC2039
	local substring string

	k_requires_args k_string_starts_with "$#"

	substring="${1}"
	shift

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		string="$(cat -)"
	else
		k_requires_args k_string_starts_with "$(( $# + 1 ))" 2
		string="$*"
	fi

	if [ "${#string}" -gt 0 ] && [ "${string%%${substring}*}" = "" ]; then
		return 0
	fi

	return 1
}

# Test if a string ends with the given substring
#
# Input:
# $1 - the substring to check for
# $2...n - all arguments are treated as the string to check in. If `$2` is `-` or arg count is < 2, reads from STDIN.
#
# Return:
# 0 if the string ends with substring, 1 if not
k_string_ends_with() {
	# shellcheck disable=SC2039
	local substring string

	k_requires_args k_string_ends_with "$#" 2

	substring="${1}"
	shift

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		string="$(cat -)"
	else
		k_requires_args k_string_ends_with "$(( $# + 1 ))" 2

		string="$*"
	fi

	if [ "${#string}" -gt 0 ] && [ "${string##*${substring}}" = "" ]; then
		return 0
	fi

	return 1
}

# Remove a substring from the start of a string
#
# Input:
# $1 - the substring to remove
# $2...n - all arguments are treated as the string to operate on. If `$2` is `-` or arg count is < 2, reads from STDIN.
# $REMOVE_GREEDY flag to enable greedy removal if the substring contains the '*' character
#
# Output:
# The string with substring removed from the start
k_string_remove_start() {
	# shellcheck disable=SC2039
	local substring string

	k_requires_args k_string_remove_start "$#"

	substring="${1}"
	shift

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		string="$(cat -)"
	else
		k_requires_args k_string_remove_start "$(( $# + 1 ))" 2
		string="$*"
	fi

	if [ "${REMOVE_GREEDY:-false}" = true ]; then
		printf -- '%s\n' "${string##${substring}}"
	else
		printf -- '%s\n' "${string#${substring}}"
	fi
}

# Remove a substring from the end of a string
#
# Input:
# $1 - the substring to remove
# $2...n - all arguments are treated as the string to operate on. If `$2` is `-` or arg count is < 2, reads from STDIN.
# $REMOVE_GREEDY flag to enable greedy removal if the substring contains the '*' character
#
# Output:
# The string with substring removed from the end
k_string_remove_end() {
	# shellcheck disable=SC2039
	local substring string

	k_requires_args k_string_remove_end "$#"

	substring="${1}"
	shift
	# shellcheck disable=SC2235

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		string="$(cat -)"
	else
		k_requires_args k_string_remove_end "$(( $# + 1 ))" 2
		string="$*"
	fi

	if [ "${REMOVE_GREEDY:-false}" = true ]; then
		printf -- '%s\n' "${string%%${substring}}"
	else
		printf -- '%s\n' "${string%${substring}}"
	fi

}

# Join strings with an optional separator
#
# Input:
# $1 - the separator string
# $2...n - the strings to join
#
# Output:
# the strings joined by the separator
#
# Example:
# k_string_join "-" this is a nice day # "this-is-a-nice-day"
k_string_join() {
	# shellcheck disable=SC2039
	local separator

	k_requires_args k_string_join "$#"

	separator="${1}"
	shift
	if [ "$#" -eq 1 ]; then
		printf -- '%s' "${1}"
	elif [ "$#" -gt 1 ]; then
		printf -- '%s' "${1}"
		shift
		printf -- "${separator}%s" "$@"
	fi
}

# Remove leading and trailing whitespace from strings
#
# Input:
# $1...n - the strings to trim. If `$1` is `-` or arg count is < 1, reads from STDIN.
#
# Output:
# the strings with leading/trailing whitespace removed
k_string_trim() {
	trim() {
		sed -e "s/^[[:space:]]*//g; s/[[:space:]]*$//g;"
	}

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		trim
	else
		k_requires_args k_string_trim "$(( $# + 1 ))"
		printf -- '%s\n' "$*" | trim
	fi
}

# Check if the given keyword is in the list of valid keywords, or error
#
# Input:
# $1 - the input to check
# $2...n - the list of valid keywords
#
# Output:
# the keyword if valid
#
# Return:
# 0 if keyword is valid, 1 if not
k_string_keyword_error() {
	# shellcheck disable=SC2039
	local input
	k_requires_args k_string_keyword_error "$#" 2

	input="${1}"
	shift
	while [ "$#" -gt 0 ]; do
		if [ "${input}" = "${1}" ]; then
			printf -- '%s\n' "${1}"
			return 0
		fi
		shift
	done

	return 1
}

# Get the selected keyword from a list, or default
#
# Input:
# $1 - the input to check
# $2...n - the list of valid keywords. The last value is used as the default if none match
#
# Output:
# the valid keyword or default
k_string_keyword() {
	# shellcheck disable=SC2039
	local value

	k_requires_args k_string_keyword "$#" 2

	if value="$(k_string_keyword_error "$@")"; then
		printf -- '%s\n' "${value}"
	else
		shift $(( $# - 1 ))
		printf -- '%s\n' "${1}"
	fi
}

# Prefix lines of text with a given string
#
# Input:
# $1 - the string to prefix each string with.
# $2...n - The strings to indent. Args are joined by newline character. If `$2` is `-` or arg count is < 2, reads from STDIN.
k_string_prefix() {
	# shellcheck disable=SC2039
	local prefix

	k_requires_args k_string_prefix "$#" 1

	prefix="$1"
	shift

	prefix() {
		sed -e "s/^/${prefix}/"
	}

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$*" = '-' ]); then
		prefix
	else
		k_requires_args k_string_prefix "$(( $# + 1 ))" 2
		printf -- '%s\n' "$@" | prefix
	fi
}

# Indent lines of text by given number of spaces
#
# Input:
# $1 - the indent level to apply.
# $2...n - The strings to indent. Args are joined by newline character. If `$2` is `-` or arg count is < 2, reads from STDIN.
#
# Output:
# the indented lines of text
#
# Return:
# 1 if indent level cannot be parsed as an integer, 0 otherwise.
k_string_indent() {
	# shellcheck disable=SC2039
	local indent

	k_requires_args k_string_indent "$#"

	indent="$(k_int_parse_error "${1}")" || return "$?"
	shift

	k_string_prefix "$(printf -- "%${indent}s" '')" "$@"
}

# Wrap lines of text to a given length, splitting by words when possible
#
# Input:
# $1 - the maximum line length to allow. If < 1, disables wrapping.
# $2...n - the strings to wrap. Args are joined by newline character. If `$2` is `-` or arg count is < 2, reads from STDIN.
k_string_wrap() {
	# shellcheck disable=SC2039
	local width

	k_requires_args k_string_wrap "$#"
	width="$(k_int_parse "${1}")" || return "$?"
	shift

	if [ "${width}" -gt 0 ]; then
		wrap() {
			fold -w "${width}" -s
		}
	else
		wrap() {
			cat
		}
	fi

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "$#" -eq 0 ] || [ "$1" = '-' ]); then
		wrap
	else
		k_requires_args k_string_wrap "$(( $# + 1 ))" 2
		printf -- '%s\n' "$@" | wrap
	fi
}
