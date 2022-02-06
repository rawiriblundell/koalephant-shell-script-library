#!/bin/sh
# Generate Markdown documentation from a 'shelldoc' documented shell script
# Version: PACKAGE_VERSION
# Copyright: 2017, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
# Todo: Configurable header format. YAML (current), INI, JSON, XML?

# Generate Markdown documentation from a 'shelldoc' documented shell script
#
# Input:
# $1 - file to process
#
# Output:
# Markdown formatted documentation
#
# Example:
# k_shell_doc file1.sh > file1.md
k_shell_doc() {

	set -eu

	. ./base.lib.sh
	. ./bool.lib.sh
	. ./fs.lib.sh
	. ./number.lib.sh
	. ./string.lib.sh

	# shellcheck disable=SC2039
	local KOALEPHANT_TOOL_DESCRIPTION KOALEPHANT_TOOL_VERSION \
		TMP_FUNC_DESCRIPTION TMP_FUNC_INPUT TMP_FUNC_OUTPUT TMP_FUNC_RETURN TMP_FUNC_EXAMPLE TMP_FUNC_DEPRECATED \
		TMP_HEADER_BLOCK TMP_HEADER_DESCRIPTION \
		showVersion=false verbose=false quiet=false debug=false \
		tmpDir headerMode=true funcMode=false prevFuncMode=false mdExtraHeaderIds=true functionSegment='description'


	# shellcheck disable=SC2016
	readonly KOALEPHANT_TOOL_DESCRIPTION='Generate Markdown documentation from a `shelldoc` documented shell script'
	readonly KOALEPHANT_TOOL_VERSION='PACKAGE_VERSION'
	readonly KOALEPHANT_TOOL_ARGUMENTS='file'
	readonly TMP_FUNC_DESCRIPTION='func-description'
	readonly TMP_FUNC_INPUT='func-input'
	readonly TMP_FUNC_OUTPUT='func-output'
	readonly TMP_FUNC_RETURN='func-return'
	readonly TMP_FUNC_EXAMPLE='func-example'
	readonly TMP_FUNC_DEPRECATED='func-deprecated'
	readonly TMP_HEADER_BLOCK='header-block'
	readonly TMP_HEADER_DESCRIPTION='header-desc'
	readonly tmpDir="$(k_fs_temp_dir)"

	k_tool_usage_init () {
		# shellcheck disable=SC2119
		k_tool_description_add <<-'STR'
			Comment blocks at the beginning of the file, and immediately preceding a function or variable declaration are parsed, reading the following sections: Description, Input, Output, Example, Return and Deprecated.

			The initial lines of the comment block form the description. The other sections must be prefixed with a section delimiter line, e.g. 'Input:' or 'Return:'

			The follow example is from the `k_version_compare` function:

		STR

		k_tool_description_code_add 4 '# ' <<-'EXAMPLE'
			Compare two version strings

			Version suffixes (e.g. 'alpha', 'rc1' etc) should use a tilde (~), e.g.: '1.2.0~alpha'
			Valid operators are eq/= (equal), neq/!= (not equal), gt/> (greater than), lt/<  (less than), gte/>= (greater or equal), lte/<= (less or equal)

			Input:
			$1 - the first version to compare
			$2 - the second version to compare
			$3 - the operator to use, defaults to 'gte'.

			Return:
			0 if the version comparison passes, 1 if not
		EXAMPLE

		# shellcheck disable=SC2119
		k_tool_description_add <<-'STR'

			The above Shelldoc comment block produces the following Markdown:

		STR

		k_tool_description_code_add 4 <<-'STR'
			### `k_version_compare`

			Compare two version strings
			Version suffixes (e.g. 'alpha', 'rc1' etc) should use a tilde (~), e.g.: '1.2.0~alpha'
			Valid operators are eq/= (equal), neq/!= (not equal), gt/> (greater than), lt/<  (less than), gte/>= (greater or equal), lte/<= (less or equal)

			#### Input:
			 * `$1` - the first version to compare
			 * `$2` - the second version to compare
			 * `$3` - the operator to use, defaults to 'gte'.

			#### Return:
			0 if the version comparison passes, 1 if not
		STR

		k_tool_options_add 'debug' 'D' '' 'Show debug output'
		k_tool_options_add 'help' 'h' '' 'Show this help'
		k_tool_options_add 'md-extra-ids' '' 'bool' 'Output Markdown Extra compatible syntax to generate ID attributes on Header elements.' \
 													'Defaults to on in v2.x.x. Will default to off in the next major version.'
		k_tool_options_add 'quiet' 'q' '' 'Suppress all output except errors'
		k_tool_options_add 'verbose' 'V' '' 'Show verbose output'
		k_tool_options_add 'version' 'v' '' 'Show the version'
	}


	tmp_string_file() {
		# shellcheck disable=SC2039
		local name

		name="$1"
		printf -- '%s/%s' "${tmpDir}" "${name}"
	}

	tmp_string_get() {
		# shellcheck disable=SC2039
		local name

		name="$1"
		cat "$(tmp_string_file "${name}")"
	}

	tmp_string_append() {
		# shellcheck disable=SC2039
		local name string

		name="$1"
		string="$2"
		printf -- '%s\n' "${string}" >> "$(tmp_string_file "${name}")"
	}

	tmp_string_set() {
		# shellcheck disable=SC2039
		local name string

		name="$1"
		string="$2"
		printf -- '%s\n' "${string}" > "$(tmp_string_file "${name}")"
	}

	tmp_string_clear() {
		# shellcheck disable=SC2039
		local name

		name="$1"
		printf -- '' > "$(tmp_string_file "${name}")"
	}

	tmp_string_exists() {
		# shellcheck disable=SC2039
		local name

		name="$1"
		[ -s "$(tmp_string_file "${name}")" ]
	}


	parse_header_description() {
		tmp_string_append "${TMP_HEADER_DESCRIPTION}" "$(k_string_trim "$1")"
	}

	parse_header_property() {
		tmp_string_append "${TMP_HEADER_BLOCK}" "$(format_header_property "$1")"
	}

	add_header_property() {
		tmp_string_append "${TMP_HEADER_BLOCK}" "$(printf -- '%s: %s' "$@")"
	}

	format_header_property() {
		# shellcheck disable=SC2039
		local line property value

		line="$1"
		property="$(k_string_remove_end ':*' "${line}")"
		value="$(k_string_trim "$(k_string_remove_start "${property}:" "${line}")")"

		printf -- '%s: %s' "$(k_string_lower "$(k_string_trim "${property}")")" "${value}"
	}

	print_function_output() {
		if tmp_string_exists "${TMP_FUNC_OUTPUT}"; then
			printf -- '#### Output:\n%s\n\n' "$(tmp_string_get "${TMP_FUNC_OUTPUT}")"
		fi
	}


	print_headers() {
		# shellcheck disable=SC2039
		local block

		block='---'
		printf -- '%s\n%s\n' "${block}" "$(tmp_string_get "${TMP_HEADER_BLOCK}")"

		if tmp_string_exists "${TMP_HEADER_DESCRIPTION}"; then
			printf -- '%s: %s\n' description  "$(tmp_string_get "${TMP_HEADER_DESCRIPTION}")"
		fi

		printf -- '%s\n\n' "${block}"
	}


	parse_header_line() {
		# shellcheck disable=SC2039
		local line property value

		line="$1"

		if ! k_string_starts_with '#' "${line}"; then
			k_log_info 'End of file header detected'
			print_headers
			headerMode=false
			return
		fi

		line="$(k_string_remove_start '#' "${line}")"

		case "$line" in

			@Ignore*|!*)
			;;

			*:*)
				parse_header_property "${line}"
			;;

			*)
				parse_header_description "${line}"
			;;
		esac
	}


	parse_function_input() {
		tmp_string_append "${TMP_FUNC_INPUT}" "$(format_function_input "$1")"
	}
	parse_function_output() {
		tmp_string_append "${TMP_FUNC_OUTPUT}" "$(format_function_links "$1")"
	}

	parse_function_return() {
		tmp_string_append "${TMP_FUNC_RETURN}" "$(format_function_links "$1")"
	}

	parse_function_description() {
		tmp_string_append "${TMP_FUNC_DESCRIPTION}" "$(format_function_links "$(k_string_trim "${1}")")"
	}

	parse_function_example() {
		tmp_string_append "${TMP_FUNC_EXAMPLE}" "$(format_function_links "$1")"
	}

	parse_function_deprecated() {
		tmp_string_append "${TMP_FUNC_DEPRECATED}" "$(format_function_links "$1")"
	}

	format_function_input() {
		# shellcheck disable=SC2039
		local line name description

		line="$1"
		name="$(k_string_remove_end ' - *' "${line}")"
		description="$(k_string_trim "$(k_string_remove_start "${name} - " "${line}")")"

		# shellcheck disable=SC2016
		printf -- ' * `%s` - %s\n' "$(k_string_trim "$name")" "$(format_function_links "$description")"
	}

	format_function_links() {
		# shellcheck disable=SC2016
		printf -- '%s\n' "$1" | sed -E -e 's/\(([^#]*)#([A-Za-z_]{1,})\)/[`\2`](\1#\2)/g'
	}

	print_function_title() {
		# shellcheck disable=SC2039
		local flags=''

		if [ -n "${3}" ]; then
			#shellcheck disable=SC2016,SC2086
			flags="$(printf -- '`%s` ' "$3")"
		fi

		if [ "${mdExtraHeaderIds}" = true ]; then
			#shellcheck disable=SC2016,SC2086
			printf -- '### `%s` {#%s}\n%s%s\n\n' "$1" "${2:-${1}}" "${flags}" "$(tmp_string_get "${TMP_FUNC_DESCRIPTION}")"
		else
			#shellcheck disable=SC2016,SC2086
			printf -- '### `%s`\n%s%s\n\n' "$1" "${flags}" "$(tmp_string_get "${TMP_FUNC_DESCRIPTION}")"
		fi

	}

	print_function_input() {
		if tmp_string_exists "${TMP_FUNC_INPUT}"; then
			printf -- '#### Input:\n%s\n\n' "$(tmp_string_get "${TMP_FUNC_INPUT}")"
		fi
	}

	print_function_output() {
		if tmp_string_exists "${TMP_FUNC_OUTPUT}"; then
			printf -- '#### Output:\n%s\n\n' "$(tmp_string_get "${TMP_FUNC_OUTPUT}")"
		fi
	}

	print_function_return() {
		if tmp_string_exists "${TMP_FUNC_RETURN}"; then
			printf -- '#### Return:\n%s\n\n' "$(tmp_string_get "${TMP_FUNC_RETURN}")"
		fi
	}

	print_function_deprecated() {
		if tmp_string_exists "${TMP_FUNC_DEPRECATED}"; then
			printf -- '#### Deprecated:\n%s\n\n' "$(tmp_string_get "${TMP_FUNC_DEPRECATED}")"
		fi
	}

	print_function_example() {
		if tmp_string_exists "${TMP_FUNC_EXAMPLE}"; then
			printf -- '#### Example:\n~~~sh\n%s\n~~~\n\n' "$(tmp_string_get "${TMP_FUNC_EXAMPLE}")"
		fi
	}

	parse_body_line() {
		# shellcheck disable=SC2039
		local line paddedLine name identifier='' flags=''

		line="$1"

		if [ "${#line}" -eq 0 ]; then
			return
		fi

		if ! k_string_starts_with '#' "${line}"; then
			if [ "${funcMode}" != true ]; then
				return
			fi

			if k_string_contains '()' "${line}"; then
				name="$(k_string_remove_end '()*' "${line}")"
			else
				identifier="$(k_string_remove_end '=*' "${line}")"
				if k_string_starts_with 'readonly ' "${identifier}"; then
					identifier="$(k_string_remove_start 'readonly ' "${identifier}")"
					flags='readonly'
				elif k_string_starts_with 'local ' "${identifier}"; then
					identifier="$(k_string_remove_start 'local ' "${identifier}")"
				fi

				name="\$${identifier}"
			fi

			print_function_title "${name}" "${identifier}" "${flags}"

			print_function_input
			print_function_output
			print_function_return
			print_function_deprecated
			print_function_example

			prevFuncMode="${funcMode}"
			funcMode=false
			functionSegment=description

			tmp_string_clear "${TMP_FUNC_DESCRIPTION}"
			tmp_string_clear "${TMP_FUNC_INPUT}"
			tmp_string_clear "${TMP_FUNC_OUTPUT}"
			tmp_string_clear "${TMP_FUNC_RETURN}"
			tmp_string_clear "${TMP_FUNC_DEPRECATED}"
			tmp_string_clear "${TMP_FUNC_EXAMPLE}"

		else
			prevFuncMode="${funcMode}"
			funcMode=true
			paddedLine="$(k_string_remove_start '#' "${line}")"
			line="$(k_string_trim "${paddedLine}")"

			if [ "${#line}" -eq 0 ]; then
				return
			fi

			case "${line}" in
				shellcheck*)
					funcMode="${prevFuncMode}"
					return
				;;

				@Ignore*|@TODO*|@Todo*)
					return
				;;

				Input:*)
					tmp_string_clear "${TMP_FUNC_INPUT}"
					functionSegment='input'
					return
				;;

				Output:*)
					tmp_string_clear "${TMP_FUNC_OUTPUT}"
					functionSegment='output'
					return
				;;

				Return:*)
					tmp_string_clear "${TMP_FUNC_RETURN}"
					functionSegment='return'
					return
				;;

				Deprecated:*)
					tmp_string_clear "${TMP_FUNC_DEPRECATED}"
					functionSegment='deprecated'
					return
				;;

				Example:*)
					tmp_string_clear "${TMP_FUNC_EXAMPLE}"
					functionSegment='example'
					return
				;;
			esac
			k_log_info 'Found function segment type: "%s" for "%s"' "${functionSegment}" "${line}"

			case "${functionSegment}" in
				description)
					parse_function_description "${line}"
				;;

				input)
					parse_function_input "${line}"
				;;

				output)
					parse_function_output "${line}"
				;;

				return)
					parse_function_return "${line}"
				;;

				deprecated)
					parse_function_deprecated "${line}"
				;;

				example)
					parse_function_example "$(k_string_remove_start ' ' "${paddedLine}")"
				;;
			esac
		fi
	}

	parse_file() {
		# shellcheck disable=SC2039
		local file line

		file="$1"

		add_header_property 'title' "${file##*/}"

		while read -r line; do
			if [ "${headerMode}" = true ]; then
				parse_header_line "${line}"
			else
				parse_body_line "${line}"
			fi
		done < "${file}"
	}

	k_log_level "${KOALEPHANT_LOG_LEVEL_NOTICE}" > /dev/null
	k_fs_temp_exit

	while k_options_split "$@"; do
		case "$OPTION_NAME" in

			(--md-extra-ids)
				# shellcheck disable=SC2119
				k_options_arg_required
				mdExtraHeaderIds="$(k_bool_parse "${OPTION_VALUE}" true)"
				shift 2
			;;

			(-h|--help)
				k_usage
				exit
			;;

			(-V|--verbose)
				k_log_level "${KOALEPHANT_LOG_LEVEL_INFO}" > /dev/null
				verbose=true
				shift
			;;

			(-D|--debug)
				k_log_level "${KOALEPHANT_LOG_LEVEL_DEBUG}" > /dev/null
				# shellcheck disable=SC2034
				debug=true
				shift
			;;

			(-q|--quiet)
				k_log_level "${KOALEPHANT_LOG_LEVEL_ERR}" > /dev/null
				quiet=true
				shift
			;;

			(-v|--version)
				showVersion=true
				shift
			;;

			(--)
				shift
				break
			;;

			(-*)
				k_log_err 'Unknown option: "%s"' "${OPTION_NAME}"
				k_usage
				return 1
			;;

			(*)
				break
			;;
		esac
	done


	k_version_helper "${showVersion}" "${quiet}" "${verbose}" && return 0

	if [ -z "${1:-}" ]; then
		k_log_err 'No file specified'
		k_usage
		return 1
	fi

	parse_file "$@"
}

k_shell_doc "$@"
