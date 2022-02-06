#!/bin/sh
# Create a manpage from the help/version output of an executable/script
# Version: PACKAGE_VERSION
# Copyright: 2014, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Create a manpage from the help/version output of an executable/script
#
# Input:
# $1 - the executable or script
#
# Output:
# The rendered manpage, unless `--output` is given
k_help2man() {

	set -eu

	. ./base.lib.sh
	. ./bool.lib.sh
	. ./fs.lib.sh
	. ./number.lib.sh
	. ./string.lib.sh

	# shellcheck disable=SC2039
	local KOALEPHANT_TOOL_VERSION KOALEPHANT_TOOL_DESCRIPTION KOALEPHANT_TOOL_ARGUMENTS \
		helpCommand='--help' description='' section='1' source='' versionCommand='--version' output=/dev/stdout \
		changeDir='false' alternativeName='' executable executableName dir includeFile tmpIncludeFile \
		showVersion='false' verbose='false' quiet='false' debug='false'

	readonly KOALEPHANT_TOOL_VERSION='PACKAGE_VERSION'
	readonly KOALEPHANT_TOOL_DESCRIPTION='Create a manpage from the help/version output of a executable/script'
	readonly KOALEPHANT_TOOL_ARGUMENTS='executable'

	k_tool_usage_init () {
		# shellcheck disable=SC2016,SC2119
		k_tool_description_add <<-'STR'
			This tool works hand-in-hand with the `k_tool_options_*`, `k_tool_description_*` and `k_tool_environment_*` functions to allow generation of better `man` pages from help output.
		STR
		k_tool_options_add 'alt-name' 'N' 'name' 'set an alternate name for the tool'
		k_tool_options_add 'debug' 'D' '' 'Show debug output'
		k_tool_options_add 'help' 'h' '' 'Show this help'
		k_tool_options_add 'help-command' 'H' 'command' 'set the help argument/option to use'
		k_tool_options_add 'name' 'n' 'name' 'set the name to use for the tool'
		k_tool_options_add 'output' 'o' 'file' 'set the filename to output to (defaults to stdout)'
		k_tool_options_add 'quiet' 'q' '' 'Suppress all output except errors'
		k_tool_options_add 'section' 's' 'section' 'set the manpage section'
		k_tool_options_add 'source' 'S' 'source' 'set the program source (i.e. a company, organisation, project or package name)'
		k_tool_options_add 'verbose' '' '' 'Show verbose output'
		k_tool_options_add 'version' 'v' '' 'Show the version'
		k_tool_options_add 'version-command' 'V' 'command' 'set the version argument/option to use'
	}

	k_log_level "${KOALEPHANT_LOG_LEVEL_NOTICE}" > /dev/null

	k_fs_temp_exit

	while k_options_split "$@"; do
		case "$OPTION_NAME" in

			(-h|--help)
				k_usage
				exit
			;;

			(-c|--cd)
				changeDir='true'
				shift
			;;

			(-H|--help-command)
				# shellcheck disable=SC2119
				k_options_arg_required
				helpCommand="${OPTION_VALUE}"
				shift 2
			;;

			(-d|--description)
				# shellcheck disable=SC2119
				k_options_arg_required
				description="${OPTION_VALUE}"
				shift 2
			;;

			(-N|--alt-name)
				# shellcheck disable=SC2119
				k_options_arg_required
				alternativeName="${OPTION_VALUE}"
				shift 2
			;;

			(-o|--output)
				output="$2"
				shift 2
			;;

			(-s|--section)
				# shellcheck disable=SC2119
				k_options_arg_required
				section="${OPTION_VALUE}"
				shift 2
			;;

			(-S|--source)
				# shellcheck disable=SC2119
				k_options_arg_required
				source="${OPTION_VALUE}"
				shift 2
			;;

			(-V|--version-command)
				# shellcheck disable=SC2119
				k_options_arg_required
				versionCommand="${OPTION_VALUE}"
				shift 2
			;;

			(--verbose)
				k_log_level "${KOALEPHANT_LOG_LEVEL_INFO}" > /dev/null
				verbose='true'
				shift
			;;

			(-D|--debug)
				k_log_level "${KOALEPHANT_LOG_LEVEL_DEBUG}" > /dev/null
				# shellcheck disable=SC2034
				debug='true'
				shift
			;;

			(-q|--quiet)
				k_log_level "${KOALEPHANT_LOG_LEVEL_ERR}" > /dev/null
				quiet='true'
				shift
			;;

			(-v|--version)
				showVersion='true'
				shift
			;;

			(--)
				shift
				break
			;;

			(-*)
				k_log_err 'Unknown option: %s' "${OPTION_NAME}"
				k_usage
				return 1
			;;

			(*)
				break
			;;
		esac
	done


	k_version_helper "${showVersion}" "${quiet}" "${verbose}" && return 0

	export K_HELP2MAN_BUILD=1

	executable="$(k_fs_resolve "${1:-}")"
	executableName="$(k_fs_basename "${executable}" .sh)"
	dir="$(k_fs_dirname "${executable}")"
	includeFile="${dir}/${executableName}.${section}.man"
	tmpIncludeFile="$(k_fs_temp_file)"

	if [ -z "${executable}" ]; then
		k_log_err 'Executable (%s) not provided\n' "${executable}";
		k_usage;
		exit 1
	elif [ ! -f "${executable}" ] || [ ! -x "${executable}" ]; then
		k_log_err 'Executable (%s) not an executable file\n' "${executable}";
		k_usage;
		exit 1
	fi

	if [ "${changeDir}" = true ]; then
		# Adjust output if file
		unset CDPATH && cd "${dir}"
		executable="./$(k_fs_basename "${executable}")"
	fi

	if [ -z "${description}" ]; then
		# shellcheck disable=SC2086
		description="$("${executable}" "${helpCommand}" | sed -E -n -e '/^\s*(Usage|\s*or):/!p' | head -n 1)"
	fi

	if [ -z "${alternativeName}" ]; then
		# shellcheck disable=SC2086
		alternativeName="$(${executable} "${helpCommand}" | perl -ne 'print if s/\s*(usage|or):\s*([^\s]+).+/\2/i' | sed -n -e "/${executableName}/!p")"
	fi

	# shellcheck disable=SC2086
	printf -- '[NAME]\n%s - %s\n\n' "$(k_string_join ", " "${executableName}" "${alternativeName}")" "${description}" > "${tmpIncludeFile}"
	if [ -f "${includeFile}" ]; then
		cat "${includeFile}" >> "${tmpIncludeFile}"
	fi

	help2man \
		--section "${section}" \
		--no-info \
		--include "${tmpIncludeFile}" \
		--help-option "${helpCommand}" \
		--version-option "${versionCommand}" \
		--source "${source}" "${executable}" \
		| sed -e 's/% |//g' > "${output}"

}

k_help2man "$@"
