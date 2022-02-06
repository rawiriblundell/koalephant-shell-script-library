#@IgnoreInspection BashAddShebang
# Base app functionality (Koalephant Shell Script Library)
# Version: PACKAGE_VERSION
# Copyright: 2014, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Base Shell Library name
readonly KOALEPHANT_LIB_NAME='PACKAGE_VENDOR-PACKAGE_NAME'

# Base Shell library owner
readonly KOALEPHANT_LIB_OWNER='Koalephant Co., Ltd'

# Base Shell Library version
readonly KOALEPHANT_LIB_VERSION='PACKAGE_VERSION'

# Base Shell Library year
readonly KOALEPHANT_LIB_YEAR='2014-2020'

# Base directory for the installed Library
readonly KOALEPHANT_LIB_PATH="${KOALEPHANT_LIB_PATH:-PREFIX/LIBRARY_PATH}"

# Get the tool name
#
# Input:
# $KOALEPHANT_TOOL_NAME - explicit name used as-is if set
# $0 - the script name is stripped of directory components and any '.sh' suffix
#
# Output:
# the tool name
k_tool_name() {
	if [ -n "${KOALEPHANT_TOOL_NAME:-}" ]; then
		printf -- '%s\n' "${KOALEPHANT_TOOL_NAME}"
	else
		k_fs_basename "${0}" ".sh"
	fi
}

# Get the tool version
#
# Input:
# $KOALEPHANT_TOOL_VERSION - explicit version used as-is if set. Default is 1.0.0 if not set
#
# Output:
# the tool version
k_tool_version() {
	printf -- '%s\n' "${KOALEPHANT_TOOL_VERSION:-1.0.0}"
}

# Get the tool copyright years
#
# Input:
# $KOALEPHANT_TOOL_YEAR - explicit copyright year(s) used as-is if set. Default is current year if not set
#
# Output:
# the tool copyright year(s)
k_tool_year() {
	printf -- '%s\n' "${KOALEPHANT_TOOL_YEAR:-$(date +%Y)}"
}

# Get the tool copyright owner
#
# Input:
# $KOALEPHANT_TOOL_OWNER - explicit copyright owner used as-is if set. Default is 'Koalephant Co., Ltd' if not set
#
# Output:
# the tool copyright owner
k_tool_owner() {
	printf -- '%s\n' "${KOALEPHANT_TOOL_OWNER:-${KOALEPHANT_LIB_OWNER}}"
}

# Get the tool description
#
# Input:
# $KOALEPHANT_TOOL_DESCRIPTION - tool description used as-is
#
# Output:
# the tool description
k_tool_description() {
	printf -- '%s\n\n%s\n\n' "${KOALEPHANT_TOOL_DESCRIPTION:-}" "${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:-}"
}

# Add a block of descriptive text, wrapped and optionally indented for help output.
#
# Helps ensure proper formatting when using `k-help2man` to build `man` pages from help output
#
# Input:
# $1 - indent level. If not specified, no indent is applied
# $2 - string to pad and use for prefixing wrapped lines. e.g. `# ` for comment lines
# $3...n - text to output. Args are joined by newline character. If `$3` is `-` or arg count is < 3, reads from STDIN.
k_tool_description_add() {
	# shellcheck disable=SC2039
	local nl2

	nl2="$(printf -- '\n\n.')"
	nl2="${nl2%.}"

	if [ -t 0 ]; then
		k_requires_args k_tool_description_add "$#" 3 || return "$?"
	fi

	KOALEPHANT_TOOL_DESCRIPTION_EXTENDED="${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:-}${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:+${nl2}}$(k_tool_usage_text "$@")"
}

# Add a block of usage/code, wrapped and optionally indented for help output.
#
# Helps ensure proper formatting when using `k-help2man` to build `man` pages from help output
#
# Input:
# $1 - indent level. If not specified, no indent is applied
# $2 - string to pad and use for prefixing wrapped lines. e.g. `# ` for comment lines
# $3...n - text to output. Args are joined by newline character. If `$3` is `-` or arg count is < 3, reads from STDIN.
k_tool_description_code_add() {
	# shellcheck disable=SC2039
	local nl2

	nl2="$(printf -- '\n\n.')"
	nl2="${nl2%.}"

	if [ -t 0 ]; then
		k_requires_args k_tool_description_code_add "$#" 3 || return "$?"
	fi

	KOALEPHANT_TOOL_DESCRIPTION_EXTENDED="${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:-}${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:+${nl2}}$(k_tool_usage_code "$@")"
}

# Get the tool options descriptions
#
# Input:
# $KOALEPHANT_TOOL_OPTIONS - tool options descriptions used as-is
#
# Output:
# the tool options descriptions
k_tool_options() {
	if [ -n "${KOALEPHANT_TOOL_OPTIONS_OPTS:-}" ]; then
		k_tool_options_print
	else
		printf -- '%s\n' "${KOALEPHANT_TOOL_OPTIONS:-}"
	fi
}

# Check if the tool accepts options
#
# Input:
# $KOALEPHANT_TOOL_OPTIONS - checks if any pre-formatted options are set.
# $KOALEPHANT_TOOL_OPTIONS_OPTS - checks if any options have been set via k_tool_options_add
#
# Return:
# 0 if the tool has options, 1 otherwise
k_tool_has_options() {
	[ -n "${KOALEPHANT_TOOL_OPTIONS:-}" ] || [ -n "${KOALEPHANT_TOOL_OPTIONS_OPTS:-}" ]
}

# Add an options entry to be auto-formatted for help output
#
# Input:
# $1 - Option long name. If non-empty, will be prepended with '--'
# $2 - Option short name. If non-empty, will be prepended with '-'
# $3 - Option argument. Convention is to surround the name with square brackets if optional.
# $4...n - Option description. Multiple inputs will be joined by newlines. Multiple lines will be automatically indented.
#
# Return:
# 0 when all inputs are ok, 1 otherwise
k_tool_options_add() {
	# shellcheck disable=SC2039
	local longName shortName argName nl desc lines start

	k_requires_args k_tool_options_add "$#" 3

	longName="$1"
	shortName="$2"
	argName="$3"
	shift 3

	nl="$(printf -- '\n.')"
	nl="${nl%.}"

	desc="$(printf -- '%s\n' "$@")"
	lines="$(printf -- '%s\n' "$@" | wc -l)"
	start="${KOALEPHANT_TOOL_OPTIONS_DESCRIPTION_LINES:-1}"
	KOALEPHANT_TOOL_OPTIONS_DESCRIPTION_LINES="$(( start + lines ))"

	KOALEPHANT_TOOL_OPTIONS_LONGEST="$(k_int_max "${KOALEPHANT_TOOL_OPTIONS_LONGEST:-0}" "$(( 5 + ${longName:+3} + ${#longName} + ${#argName} ))")"
	KOALEPHANT_TOOL_OPTIONS_OPTS="${KOALEPHANT_TOOL_OPTIONS_OPTS:-}${KOALEPHANT_TOOL_OPTIONS_OPTS:+$nl}$(printf -- '%s;%s;%s;%d;%d' "${longName}" "${shortName}" "${argName}" "${start}" "${lines}")"
	KOALEPHANT_TOOL_OPTIONS_DESCRIPTIONS="${KOALEPHANT_TOOL_OPTIONS_DESCRIPTIONS:-}${KOALEPHANT_TOOL_OPTIONS_DESCRIPTIONS:+$nl}${desc}"
}

# Add an options alias entry to be auto formatted for help output
#
# Input
# $1 - Option long name. If non-empty, will be prepended with '--'
# $2 - Option short name. If non-empty, will be prepended with '-'
# $3 - Original name (the option this is an alias of). Will be used as-is in the descriptive text.
#
# 0 when all inputs are ok, 1 otherwise
k_tool_options_alias() {
	# shellcheck disable=SC2039
	local originalName longName shortName argName

	k_requires_args k_tool_options_alias "$#" 3
	longName="$1"
	shortName="$2"
	originalName="$3"

	k_tool_options_add "${longName}" "${shortName}" '' "$(printf -- 'Alias for %s\n' "${originalName}")"
}

# Display the entries added with k_tool_options_add and k_tool_options_alias
#
# Output:
# The rendered help options
k_tool_options_print() {
	# shellcheck disable=SC2039
	local longName shortName argName start lines optWidth descOffset descWidth

	option_name() {
		# shellcheck disable=SC2039
		local name

		name="$1"

		case "${#name}" in
			(0)
				return 0
			;;

			(1)
				printf -- '%s' "${name:+-}${name}"
			;;

			(*)
				printf -- '%s' "${name:+--}${name}"
			;;
		esac
	}

	print_entry_name_args() {
		# shellcheck disable=SC2039
		local longName shortName argName

		longName="$(option_name "$1")"
		shortName="$(option_name "${2:-}")"
		argName="${3:-}"

		if [ -n "${longName}" ] && [ -n "${shortName}" ]; then
			shortName="${shortName}, "
		fi

		printf -- '%5s%s%s' "${shortName}" "${longName}" "${argName:+ }${argName}"
	}

	optWidth="$((KOALEPHANT_TOOL_OPTIONS_LONGEST + 2))"
	descOffset="$((KOALEPHANT_TOOL_OPTIONS_LONGEST + 4))"
	descWidth="$(( $(k_tty_width) - descOffset ))"

	printf -- 'Options:\n\n'

	while IFS=';' read -r longName shortName argName start lines; do
		print_entry_name_args "${longName}" "${shortName}" "${argName}" | k_string_pad_right "${optWidth}"
		k_string_get_lines "${start}" "${lines}" "${KOALEPHANT_TOOL_OPTIONS_DESCRIPTIONS}" | k_string_wrap "${descWidth}" | k_string_indent "${descOffset}" | sed -E "1s/^[[:space:]]{${descOffset}}//"
	done <<-OPTS
		${KOALEPHANT_TOOL_OPTIONS_OPTS}
	OPTS
}

# Display a block of help text, wrapped and optionally indented.
#
# Deprecated:
# As of 2.8.0, use k_tool_description_add() or k_tool_usage_text() instead
k_tool_options_text () {
	k_log_deprecated 'k_tool_options_text' '2.8.0' 'k_tool_description_add() or k_tool_usage_text()'
	k_tool_usage_text "$@"
}


# Display a block of usage/code, wrapped and optionally indented.
# Deprecated:
# As of 2.8.0, use k_tool_description_code_add() or k_tool_usage_code() instead
k_tool_options_code () {
	k_log_deprecated 'k_tool_options_code' '2.8.0' 'k_tool_description_code_add() or k_tool_usage_code()'
	k_tool_usage_code "$@"
}

# Get the tool option(s) argument(s)
# Shows output if (#k_tool_options) returns non-empty content
#
# Input:
# $KOALEPHANT_TOOL_OPTIONS_ARGUMENTS - explicit tool option(s) argument(s) used as-is. Default is '[options]' if not set
#
# Output:
# the tool option(s) argument(s)
k_tool_options_arguments() {
	if k_tool_has_options; then
		printf -- ' %s\n' "${KOALEPHANT_TOOL_OPTIONS_ARGUMENTS:-[OPTION]...}"
	fi
}

# Get the tool arguments
#
# Input:
# $KOALEPHANT_TOOL_ARGUMENTS - tool arguments used as-is
#
# Output:
# the tool arguments
k_tool_arguments() {
	printf -- ' %s\n' "${KOALEPHANT_TOOL_ARGUMENTS:-}"
}

# Get the tool environment variables
#
# Input:
# $KOALEPHANT_TOOL_ENVIRONMENT - tool environment used as-is
#
# Output
# the tool environment variables
k_tool_environment() {
	if [ -n "${KOALEPHANT_TOOL_ENVIRONMENT_NAMES:-}" ]; then
		k_tool_environment_print
	elif [ -n "${KOALEPHANT_TOOL_ENVIRONMENT:-}" ]; then
		printf -- 'Environment: \n\n%s\n' "$(printf -- '%s' "${KOALEPHANT_TOOL_ENVIRONMENT:-None}" | sed 'G')"
	fi
}

# Add an environment entry to be auto-formatted for help output
#
# Input:
# $1 - Environment variable name
# $2...n - Environment variable description. Multiple inputs will be joined by newlines. Multiple lines will be automatically indented.
#
# Return:
# 0 when all inputs are ok, 1 otherwise
k_tool_environment_add() {
	# shellcheck disable=SC2039
	local name desc nl lines start

	k_requires_args k_tool_environment_add "$#" 2

	name="$1"
	shift

	nl="$(printf -- '\n.')"
	nl="${nl%.}"

	desc="$(printf -- '%s\n' "$@")"
	lines="$(printf -- '%s\n' "$@" | wc -l)"
	start="${KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTION_LINES:-1}"
	KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTION_LINES="$(( start + lines ))"

	KOALEPHANT_TOOL_ENVIRONMENT_LONGEST="$(k_int_max "${KOALEPHANT_TOOL_ENVIRONMENT_LONGEST:-0}" "$(( 5 + ${#name} ))")"
	KOALEPHANT_TOOL_ENVIRONMENT_NAMES="${KOALEPHANT_TOOL_ENVIRONMENT_NAMES:-}${KOALEPHANT_TOOL_ENVIRONMENT_NAMES:+$nl}$(printf -- '%s;%d;%d' "${name}" "${start}" "${lines}")"
	KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTIONS="${KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTIONS:-}${KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTIONS:+$nl}${desc}"
}

# Add an environment alias entry to be auto formatted for help output
#
# Input
# $1 - Environment variable name.
# $2 - Original name (the environment variable this is an alias of). Will be used as-is in the descriptive text.
#
# 0 when all inputs are ok, 1 otherwise
k_tool_environment_alias() {
	# shellcheck disable=SC2039
	local originalName longName name

	k_requires_args k_tool_environment_alias "$#" 2
	name="$1"
	originalName="$2"

	k_tool_environment_add "${name}" "$(printf -- 'Alias for %s\n' "${originalName}")"
}

# Display the entries added with k_tool_environment_add and k_tool_environment_alias
#
# Output:
# The rendered help options
k_tool_environment_print() {
	# shellcheck disable=SC2039
	local name start lines envWidth descOffset descWidth

	envWidth="$((KOALEPHANT_TOOL_ENVIRONMENT_LONGEST))"
	descOffset="$((KOALEPHANT_TOOL_ENVIRONMENT_LONGEST + 4))"
	descWidth="$(( $(k_tty_width) - descOffset ))"

	printf -- 'Environment:\n\n'

	while IFS=';' read -r name start lines; do
		k_string_pad_right "${envWidth}" "$name" | k_string_indent 2
		k_string_get_lines "${start}" "${lines}" "${KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTIONS}" | k_string_wrap "${descWidth}" | k_string_indent "${descOffset}" | sed -E "1s/^[[:space:]]{${descOffset}}//"
	done <<-ENV
		${KOALEPHANT_TOOL_ENVIRONMENT_NAMES}
	ENV
}

# Get the tool usage
# uses (#k_tool_name), (#k_tool_options_arguments) and (#k_tool_arguments)
#
# Output:
# the tool usage
k_tool_usage() {
	printf -- 'Usage: %s%s%s\n' "$(k_tool_name)" "$(k_tool_options_arguments)" "$(k_tool_arguments)"
}


# Display a block of help text, wrapped and optionally indented.
# Helps ensure proper formatting when using `k-help2man` to build `man` pages from help output
# Consider using (#k_tool_description_add) (which uses this function internally) for defining help output instead.
#
# Input:
# $1 - indent level. If not specified, no indent is applied
# $2 - string to pad and use for prefixing wrapped lines. e.g. `# ` for comment lines
# $3...n - text to output. Args are joined by newline character. If `$3` is `-` or arg count is < 3, reads from STDIN.
#
# Output:
# the formatted help text
k_tool_usage_text() {
	# shellcheck disable=SC2039
	local indent=0 prefix='' wrap

	if [ -t 0 ]; then
		k_requires_args k_tool_usage_text "$#" 3 || return "$?"
	fi

	if [ "$#" -gt 0 ]; then
		indent="$1"
		shift
	fi
	if [ "$#" -gt 0 ]; then
		prefix="$1"
		shift
	fi

	prefix="$(k_string_pad_left "$(( indent + ${#prefix} ))" "${prefix}")"

	wrap="$(( $(k_tty_width) - ${#prefix} ))"
	if [ "${K_HELP2MAN_BUILD:-}" = 1 ]; then
		wrap=0
	fi

	k_string_wrap "${wrap}" "$@" | k_string_prefix "${prefix}"
	printf -- '\n'
}


# Display a block of usage/code, wrapped and optionally indented.
# Helps ensure proper formatting when using `k-help2man` to build `man` pages from help output
# Consider using (#k_tool_description_code_add) (which uses this function internally) for defining help output instead.
#
# Input:
# $1 - indent level. If not specified, no indent is applied
# $2 - string to pad and use for prefixing wrapped lines. e.g. `# ` for comment lines
# $3...n - text to output. Args are joined by newline character. If `$3` is `-` or arg count is < 3, reads from STDIN.
#
# Output:
# the formatted help text
k_tool_usage_code() {
	# shellcheck disable=SC2039
	local indent=0 prefix='' wrap kH2M="${K_HELP2MAN_BUILD:-0}"

	if [ -t 0 ]; then
		k_requires_args k_tool_usage_code "$#" 3 || return "$?"
	fi


	if [ "$#" -gt 0 ]; then
		indent="$1"
		shift
	fi
	if [ "$#" -gt 0 ]; then
		prefix="$1"
		shift
	fi


	if [ "${kH2M}" = 1 ]; then
		prefix="% |${prefix}"
		KOALEPHANT_TTY_WIDTH_OVERRIDE=60
	fi

	K_HELP2MAN_BUILD=0
	k_tool_usage_text "${indent}" "${prefix}" "$@"
	K_HELP2MAN_BUILD="${kH2M}"

	printf -- '\n'
}


# Show the current tool version
# uses (#k_tool_name), (#k_tool_version) (#k_tool_year) and (#k_tool_owner)
#
# Output:
# the version information
k_version() {
	printf -- '%s version %s \nCopyright (c) %s, %s\n' "$(k_tool_name)" "$(k_tool_version)" "$(k_tool_year)" "$(k_tool_owner)"
}

# Show the current library version
#
# Input:
# $KOALEPHANT_LIB_NAME
# $KOALEPHANT_LIB_VERSION
# $KOALEPHANT_LIB_YEAR
# $KOALEPHANT_LIB_OWNER
#
# Output:
# the version information
k_library_version () {
	printf -- '%s version %s \nCopyright (c) %s, %s\n' "${KOALEPHANT_LIB_NAME}" "${KOALEPHANT_LIB_VERSION}" "${KOALEPHANT_LIB_YEAR}" "${KOALEPHANT_LIB_OWNER}"
}

# Show either the full or minimal tool version
# uses (#k_tool_version) and (#k_version)
#
# Input:
# $0 - flag indicating whether version info should be shown.
# $1 - flag indicating whether just the version number should be shown
# $2 - flag indicating whether the Library info/version should be shown as well
#
# Output:
# the version information/number
#
# Return:
# 0 if version info is shown, 1 otherwise
k_version_helper () {
	# shellcheck disable=SC2039
	local showVersion quiet verbose

	k_requires_args k_version_helper "$#" 3

	showVersion="${1}"
	quiet="${2}"
	verbose="${3}"

	if [ "${showVersion}" = true ]; then
		if [ "${quiet}" = true ]; then
			k_tool_version
			if [ "${verbose}" = true ]; then
				printf -- '%s\n' "${KOALEPHANT_LIB_VERSION}"
			fi
		else
			k_version
			if [ "${verbose}" = true ]; then
				k_library_version
			fi
		fi
		return 0
	fi

	return 1
}

# Show the Usage info for this script
# uses (#k_tool_usage), (#k_tool_description) and (#k_tool_options) and (#k_tool_environment)
#
# Output:
# the usage information
k_usage() {
	k_function_exists 'k_tool_usage_init' && k_tool_usage_init

	k_tool_usage

	k_tool_description

	k_tool_options

	k_tool_environment
}

# Check if the running (effective) user is root, and error if not
#
# Input:
# $1 - an extra error message to show if the current user is not root
#
# Output:
# Any additional message provided in `$1` plus a standard error message, if run by a non-root user.
#
# Return:
# 0 when effective user is root, 1 otherwise
k_require_root() {
	# shellcheck disable=SC2039
	local message="${1:-}"
	if [ "$(id -u)" -ne 0 ]; then
		if [ -n "${message}" ]; then
			k_log_err "${message}"
		fi
		k_log_err '%s must be run as root' "$(k_tool_name)"
		return 1
	fi
}

# Check that the function has n arguments specified
#
# Input:
# $1 - the name of the function
# $2 - the number of arguments provided
# $3 - the number of arguments required. Defaults to 1 if not specified
#
# Output:
# Error message written to stderr when applicable
#
# Return:
# 0 when required number of args passed, 1 otherwise
k_requires_args() {
	# shellcheck disable=SC2039
	local name provided req
	if [ "$#" -ge 2 ]; then
		name="$1"
		provided="$2"
		req="${3:-1}"
	else
		name='k_requires_args'
		provided="$#"
		req=2
	fi

	if [ "${provided}" -lt "${req}" ]; then
		printf -- '%s requires at least %d arguments, %d given\n' "${name}" "${req}" "${provided}" >&2
		return 1
	fi
}

# Check that an option has an argument specified.
#
# Input:
# $1 - the option name
# $2 - the next argument the tool was invoked with
#
# Output:
# the argument value if valid
#
# Return:
# 0 on success, 1 otherwise
#
# Deprecated:
# As of v2.5.0, use (#k_options_split) and (#k_options_arg_required) instead
k_option_requires_arg() {
	# shellcheck disable=SC2039
	local name
	k_requires_args k_option_requires_arg "$#"
	name="$1"

	k_log_deprecated k_option_requires_arg 2.5.0 'k_options_split() and k_options_arg_required()'

	if [ -n "${2:-}" ] && ! k_string_starts_with "-" "${2}"; then
		printf -- '%s\n' "${2}"
	else
		k_log_err 'Error, %s requires an argument' "${name}"
		k_usage
		return 1
	fi
}

# Check whether an option has an optional argument specified.
#
# Input:
# $1 - the option name
# $2 - the next argument the tool was invoked with
#
# Output:
# the argument value if specified
#
# Deprecated:
# As of v2.5.0, use (#k_options_split) and (#k_options_arg_optional) instead
k_option_optional_arg() {
	k_log_deprecated k_option_optional_arg 2.5.0 'k_options_split() and k_options_arg_optional()'

	if [ -n "${2:-}" ] && ! k_string_starts_with "-" "${2}"; then
		printf -- '%s\n' "${2}"
	fi
}

# Read options passed and split option/value pairs.
#
# Sets four variables to be used within the context of a `while` loop:
# $OPTION_NAME - the name of the current option
# $OPTION_VALUE - the (potentially) value of the current option
# $OPTION_VALUE_SET - hint as to whether an argument is set
# $OPTION_ARG_COUNT - a value indicating how many values should be shifted when a value has been read
#
# Input:
# $1...n - The options to parse and split
# $KOALEPHANT_OPTIONS_ALLOW_DASH - a space separated list of options that accept values with a leading dash as valid (e.g. `--foo -1` to pass '-1' as the value for '--foo').
#
# Output:
# the options in a space separated string
#
# Example:
# read_options() {
# 	local originalCount="$#"
#
# 	while k_options_split "$@"; do
# 		case "$OPTION_NAME" in
#
# 			(-a|--arg)
# 				k_options_arg_required 'You must supply "%s"'
# 				printf -- 'Opt with value "%s"\n' "${OPTION_VALUE}" >&2
# 				shift "${OPTION_ARG_COUNT}"
# 			;;
#
# 			(-b|--bool)
# 				if k_options_arg_optional; then
# 					printf -- 'Opt with optional value specified "%s"\n' "${OPTION_VALUE}" >&2
# 					shift "${OPTION_ARG_COUNT}"
# 				else
# 					printf -- 'Opt without value specified\n' >&2
# 					shift
# 				fi
# 			;;
#
# 			(--)
# 				shift
# 				break
# 			;;
#
# 			(*)
# 				break
# 			;;
# 		esac
# 	done
#
#
# 	return $(( originalCount - $# ))
# }
#
# read_options "$@" || shift $?
k_options_split() {
	# shellcheck disable=SC2039
	local rawOption

	if [ "$#" -lt 1 ]; then
		return 1
	fi

	dash_value_allowed() {
		# shellcheck disable=SC2039
		local n IFS=' '
		for n in ${KOALEPHANT_OPTIONS_ALLOW_DASH:-}; do
			if [ "${n}" = "${OPTION_NAME}" ]; then
				return 0
			fi
		done

		return 1
	}

	rawOption="${1}"
	OPTION_NAME="${rawOption}"
	OPTION_VALUE_SET=0
	OPTION_VALUE=''

	if [ "$#" -gt 1 ] && ( dash_value_allowed || ! k_string_starts_with "-" "${2}" ); then
		OPTION_VALUE="${2}"
		OPTION_VALUE_SET=1
		OPTION_ARG_COUNT=2
	fi

	case "${OPTION_NAME}" in
		(*=*)
			OPTION_NAME="${rawOption%%=*}"
			OPTION_VALUE="${rawOption#${OPTION_NAME}=}"
			OPTION_ARG_COUNT=1
			OPTION_VALUE_SET=1
		;;

		(-[a-zA-Z0-9]?*) # Cannot use [[:alnum:]] in posh or mksh
			OPTION_VALUE="${rawOption#-?}"
			OPTION_NAME="${rawOption%%${OPTION_VALUE}}"
			OPTION_VALUE_SET=1
			# shellcheck disable=SC2034
			OPTION_ARG_COUNT=1
		;;
	esac
}

# Check that an option has an argument specified.
# This function is designed to work with (#k_options_split)
#
# Input:
# $1 - optional printf template to use for the error message. Defaults to 'Error, %s requires an argument', and receives the option name as argument.
# $2 - flag to allow an empty string as the argument, defaults to false.
# $OPTION_NAME - the option name
# $OPTION_VALUE - the next argument the tool was invoked with
# $OPTION_VALUE_SET - flag indicating a value has been set
# $KOALEPHANT_OPTIONS_ALLOW_EMPTY - flag to allow an empty string as the argument, defaults to false. Alternative to param $2
# Return:
# 0 if the option is specified, 1 otherwise
k_options_arg_required() {
	# shellcheck disable=SC2039
	local template='Error, %s requires an argument' allowEmpty
	if [ -z "${OPTION_NAME:-}" ]; then
		k_log_err 'Error, no option name set. Must be used with k_options_split()'
		return 2
	fi

	if [ -n "${1:-}" ]; then
		template="$1"
	fi
	allowEmpty="${2:-${KOALEPHANT_OPTIONS_ALLOW_EMPTY:-}}"

	if [ "${OPTION_VALUE_SET:-0}" -eq 0 ] || ( ! k_bool_test "${allowEmpty}" false && [ -z "${OPTION_VALUE:-}" ] ); then
		k_log_err "${template}" "${OPTION_NAME}"
		k_usage
		exit 1
	fi
}

# Check whether an option has an optional argument specified.
# This function is designed to work with (#k_options_split)
#
# Input:
# $OPTION_VALUE_SET - flag indicating a value has been set
#
# Return:
# 0 if the option is specified, 1 otherwise
k_options_arg_optional() {
	[ "${OPTION_VALUE_SET:-0}" -eq 1 ]
}


# Log level EMERG - system is unusable
KOALEPHANT_LOG_LEVEL_EMERG=1
readonly KOALEPHANT_LOG_LEVEL_EMERG

# Log level ALERT - action must be taken immediately
KOALEPHANT_LOG_LEVEL_ALERT=2
readonly KOALEPHANT_LOG_LEVEL_ALERT

# Log level CRIT - critical conditions
KOALEPHANT_LOG_LEVEL_CRIT=3
readonly KOALEPHANT_LOG_LEVEL_CRIT

# Log level ERR - error conditions
KOALEPHANT_LOG_LEVEL_ERR=4
readonly KOALEPHANT_LOG_LEVEL_ERR

# Log level WARNING - warning conditions
KOALEPHANT_LOG_LEVEL_WARNING=5
readonly KOALEPHANT_LOG_LEVEL_WARNING

# Log level NOTICE - normal, but significant, condition
KOALEPHANT_LOG_LEVEL_NOTICE=6
readonly KOALEPHANT_LOG_LEVEL_NOTICE

# Log level INFO - informational message
KOALEPHANT_LOG_LEVEL_INFO=7
readonly KOALEPHANT_LOG_LEVEL_INFO

# Log level DEBUG - debug-level message
KOALEPHANT_LOG_LEVEL_DEBUG=8
readonly KOALEPHANT_LOG_LEVEL_DEBUG

# Parse a log level, check it's validity and output the integer value
#
# Input:
# $1 - log level value to parse
#
# Output:
# the parsed log level as an integer
#
# Return:
# 0 if the input can be parsed into a valid log level, 1 if not
k_log_level_parse() {
	# shellcheck disable=SC2039
	local level

	k_requires_args k_log_level_parse "$#"

	if level="$(printf -- '%d' "${1}" 2>/dev/null)" && [ -n "${level}" ]; then
		if [ "${level}" -ge "${KOALEPHANT_LOG_LEVEL_EMERG}" ] && [ "${level}" -le "${KOALEPHANT_LOG_LEVEL_DEBUG}" ]; then
			printf -- '%d' "${level}"
			return 0
		fi
	fi

	printf -- 'Invalid log level specified: "%s"\n' "$1" >&2
	return 1
}

# Check if a value is a valid log level
#
# Input:
# $1 - log level value to check
#
# Return:
# 0 if the input can be parsed into a valid log level, 1 if not
k_log_level_valid() {
	k_log_level_parse "$@" > /dev/null 2>&1
}

# Get/Set the current log level
#
# Input:
# $1 - if provided, set the active log level to this value
# $KOALEPHANT_LOG_LEVEL_ACTIVE - used as explicit log level if set. Default is ($#KOALEPHANT_LOG_LEVEL_ERR) if not set
#
# Output:
# the active log level
#
# Return:
# 0 if the log level is valid, 1 if not
# shellcheck disable=SC2120
k_log_level() {
	# shellcheck disable=SC2039
	local level retCode=0

	if [ "$#" -gt 0 ]; then
		if ! level="$(k_log_level_parse "$1")"; then
			retCode=1
		else
			KOALEPHANT_LOG_LEVEL_ACTIVE="$level"
		fi
	fi

	printf -- '%d\n' "${KOALEPHANT_LOG_LEVEL_ACTIVE:-${KOALEPHANT_LOG_LEVEL_ERR}}"

	return "${retCode}"
}

# Get the log level name from a log level value
k_log_level_name() {
	# shellcheck disable=SC2039
	local level

	k_requires_args k_log_level_name "$#"

	level="$(k_log_level_parse "${1}")" || return "$?"

	case "${level}" in
		(${KOALEPHANT_LOG_LEVEL_EMERG})
			printf -- '%s\n' 'emerg'
		;;

		(${KOALEPHANT_LOG_LEVEL_ALERT})
			printf -- '%s\n' 'alert'
		;;

		(${KOALEPHANT_LOG_LEVEL_CRIT})
			printf -- '%s\n' 'crit'
		;;

		(${KOALEPHANT_LOG_LEVEL_ERR})
			printf -- '%s\n' 'err'
		;;

		(${KOALEPHANT_LOG_LEVEL_WARNING})
			printf -- '%s\n' 'warning'
		;;

		(${KOALEPHANT_LOG_LEVEL_NOTICE})
			printf -- '%s\n' 'notice'
		;;

		(${KOALEPHANT_LOG_LEVEL_INFO})
			printf -- '%s\n' 'info'
		;;

		(${KOALEPHANT_LOG_LEVEL_DEBUG})
			printf -- '%s\n' 'debug'
		;;
	esac
}

# Check if logs should be set to syslog
#
# Input:
# $KOALEPHANT_LOG_SYSLOG - used as flag to enable syslog
#
# Return:
# 0 if syslog should be used, 1 otherwise
k_log_syslog() {
	[ "${KOALEPHANT_LOG_SYSLOG:-false}" = true ]
}

# Log a message according to a syslog level
#
# Input:
# $1 - the syslog level constant to use. One of the `KOALEPHANT_LOG_LEVEL_*` constants
# $2 - an optional printf template to use
# $3...n - the message to write
k_log_message() {
	# shellcheck disable=SC2039
	local level template='%s\n'
	k_requires_args k_log_message "$#" 2
	level="$(k_log_level_parse "${1}")" || return "$?"
	shift

	if [ "$#" -gt 1 ]; then
		template="${1}\n"
		shift
	fi

	# shellcheck disable=SC2119
	if [ "$(k_log_level)" -ge "${level}" ]; then
		if k_log_syslog; then
			# shellcheck disable=SC2059
			printf -- "${template}" "$@" >&2
			# shellcheck disable=SC2059
			printf -- "${template}" "$@" | logger -t "$(k_tool_name)" -p "user.$(k_log_level_name "${level}")"
		else
			# shellcheck disable=SC2059
			printf -- "${template}" "$@" >&2
		fi
	fi
}

# Log a message at syslog-level EMERG
#
# Input:
# $1 - an optional printf template to use
# $2...n - the message arguments/string
k_log_emerg() {
	k_log_message "${KOALEPHANT_LOG_LEVEL_EMERG}" "$@"
}

# Log a message at syslog-level ALERT
#
# Input:
# $1 - an optional printf template to use
# $2...n - the message arguments/string
k_log_alert() {
	k_log_message "${KOALEPHANT_LOG_LEVEL_ALERT}" "$@"
}

# Log a message at syslog-level CRIT
#
# Input:
# $1 - an optional printf template to use
# $2...n - the message arguments/string
k_log_crit() {
	k_log_message "${KOALEPHANT_LOG_LEVEL_CRIT}" "$@"
}

# Log a message at syslog-level ERR
#
# Input:
# $1 - an optional printf template to use
# $2...n - the message arguments/string
k_log_err() {
	k_log_message "${KOALEPHANT_LOG_LEVEL_ERR}" "$@"
}

# Log a message at syslog-level WARNING
#
# Input:
# $1 - an optional printf template to use
# $2...n - the message arguments/string
k_log_warning() {
	k_log_message "${KOALEPHANT_LOG_LEVEL_WARNING}" "$@"
}

# Log a message at syslog-level NOTICE
#
# Input:
# $1 - an optional printf template to use
# $2...n - the message arguments/string
k_log_notice() {
	k_log_message "${KOALEPHANT_LOG_LEVEL_NOTICE}" "$@"
}

# Log a message at syslog-level INFO
#
# Input:
# $1 - an optional printf template to use
# $2...n - the message arguments/string
k_log_info() {
	k_log_message "${KOALEPHANT_LOG_LEVEL_INFO}" "$@"
}

# Log a message at syslog-level DEBUG
#
# Input:
# $1 - an optional printf template to use
# $2...n - the message arguments/string
k_log_debug() {
	k_log_message "${KOALEPHANT_LOG_LEVEL_DEBUG}" "$@"
}

# Log a message indicating a function is deprecated
# Internally this logs as a DEBUG message
#
# Input:
# $1 - the function name that is deprecated
# $2 - the version the function was deprecated
# $3 - suggested replacement functions to include in the message. Defaults to empty
k_log_deprecated() {
	k_requires_args k_log_deprecated 2

	if [ "$#" -eq 2 ]; then
		k_log_debug '%s is deprecated as of v%s' "$@"
	elif [ "$#" -eq 3 ]; then
		k_log_debug '%s is deprecated as of v%s, consider using %s instead' "$@"
	fi
}

# Compare two version strings
#
# Version suffixes (e.g. 'alpha', 'rc1' etc) should use a tilde (~), e.g.: '1.2.0~alpha'
# Valid operators are eq/= (equal), neq/!= (not equal), gt/> (greater than), lt/<  (less than), gte/>= (greater or equal), lte/<= (less or equal)
#
# Input:
# $1 - the first version to compare
# $2 - the second version to compare
# $3 - the operator to use, defaults to 'gte'.
#
# Return:
# 0 if the version comparison passes, 1 if not
k_version_compare() {
	# shellcheck disable=SC2039
	local ver1 ver2 op

	k_requires_args k_version_compare "$#" 2

	ver1="$1"
	ver2="$2"
	op="${3:-gte}"

	log_action() {
		k_log_debug 'Comparing if "%s" is %s "%s".' "$@"
	}

	is_greater() {
		[ "$(printf -- '%s\n%s' "${1}" "${2}" | LC_ALL=C sort -Vr | head -n 1)" = "${1}" ]
	}

	is_less() {
		[ "$(printf -- '%s\n%s' "${1}" "${2}" | LC_ALL=C sort -V | head -n 1)" = "${1}" ]
	}

	is_equal() {
		[ "$(printf -- '%s\n%s' "${1}" "${2}" | LC_ALL=C sort -Vu | wc -l)" -eq 1 ]
	}

	case "${op}" in
		(gte|'>=')
			log_action "$1" 'greater than or equal to' "$2"
			if is_equal "${ver1}" "${ver2}" || is_greater "${ver1}" "${ver2}"; then
				return 0
			fi

			return 1
		;;

		(lte|'<=')
			log_action "$1" 'less than or equal to' "$2"
			if is_equal "${ver1}" "${ver2}" || is_less "${ver1}" "${ver2}"; then
				return 0
			fi

			return 1
		;;

		(neq|'!=')
			log_action "$1" 'not equal to' "$2"
			if is_equal "${ver1}" "${ver2}"; then
				return 1
			fi

			return 0
		;;

		(eq|'=')
			log_action "$1" 'equal to' "$2"
			if is_equal "${ver1}" "${ver2}"; then
				return 0
			fi

			return 1
		;;

		(gt|'>')
			log_action "$1" 'greater than' "$2"
			if ! is_equal "${ver1}" "${ver2}" && is_greater "${ver1}" "${ver2}" ; then
				return 0;
			fi

			return 1
		;;

		(lt|'<')
			log_action "$1" 'less than' "$2"
			if ! is_equal "${ver1}" "${ver2}" &&  is_less "${ver1}" "${ver2}" ; then
				return 0;
			fi

			return 1
		;;

		(*)
			k_log_err 'Unrecognised operator: %s' "${op}"
			return 2
		;;
	esac
}

# Get the negotiated "width" of the TTY in columns.
# Takes into account overrides, maximum width, and default width (e.g. when no TTY is available).
#
# Input:
# $KOALEPHANT_TTY_WIDTH_OVERRIDE - an override for ignoring current TTY width.
# $KOALEPHANT_TTY_WIDTH_DEFAULT - a fallback for the default width (eg when TTY width cannot be determined). If not set, default is 80.
# $KOALEPHANT_TTY_WIDTH_MAX - a maximum bounding width. If not set, maximum is 160. Ignored if 0 or less.
#
# Output:
# the negotiated TTY width.
k_tty_width() {
	# shellcheck disable=SC2039
	local detected=''

	if [ -n "${KOALEPHANT_TTY_WIDTH_OVERRIDE:-}" ]; then
		k_int_parse "${KOALEPHANT_TTY_WIDTH_OVERRIDE}" && return "$?"
	fi

	case "$(uname -s)" in
		(Linux)
			detected="$(stty -F /dev/tty size 2>/dev/null | cut -f 2 -d ' ')"
		;;

		(Darwin|*BSD*)
			detected="$(stty -f /dev/tty size 2>/dev/null | cut -f 2 -d ' ')"
		;;
	esac

	detected="${detected:-${KOALEPHANT_TTY_WIDTH_DEFAULT:-80}}"

	if [ "${KOALEPHANT_TTY_WIDTH_MAX:-160}" -gt 0 ]; then
		k_int_min "${detected}" "${KOALEPHANT_TTY_WIDTH_MAX:-160}"
	else
		printf -- '%d' "${detected}"
	fi
}

# Check if a function exists with the given name
#
# Input:
# $1 - the function name to check for
#
# Return:
# 0 if the function exists, 1 if not.
k_function_exists() {
	# shellcheck disable=SC2039
	local name definition
	k_requires_args k_function_exists "$#"

	name="$1"

	if definition="$(command -V "$name" 2>/dev/null)" && printf -- '%s' "$definition" | grep -q 'function'; then
		return 0
	fi

	return 1
}
