#!/bin/sh
# Compare two version strings
# Version: PACKAGE_VERSION
# Copyright: 2019, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Process shell source (.) statements into absolute references or inline the script
k_version_compare_tool () {

	set -eu

	. ./base.lib.sh
	. ./bool.lib.sh
	. ./fs.lib.sh
	. ./string.lib.sh
	. ./number.lib.sh

	# shellcheck disable=SC2039
	local KOALEPHANT_TOOL_DESCRIPTION KOALEPHANT_TOOL_VERSION KOALEPHANT_TOOL_ARGUMENTS \
		showVersion=false verbose=false quiet=false debug=false

	readonly KOALEPHANT_TOOL_VERSION='PACKAGE_VERSION'
	readonly KOALEPHANT_TOOL_DESCRIPTION='Compare two version strings'
	readonly KOALEPHANT_TOOL_ARGUMENTS='versionString1 versionString2 [operator=gte] '

	k_tool_usage_init () {
		# shellcheck disable=SC2119
		k_tool_description_add <<-'EOT'
			Valid operators are eq/= (equal), neq/!= (not equal), gt/> (greater than), lt/<  (less than), gte/>= (greater or equal), lte/<= (less or equal)

			Version suffixes (e.g. 'alpha', 'rc1' etc) should use a tilde (~), e.g.: '1.2.0~alpha' to ensure proper handling
		EOT
		k_tool_options_add 'debug' 'D' '' 'Show debug output'
		k_tool_options_add 'help' 'h' '' 'Show this help'
		k_tool_options_add 'quiet' 'q' '' 'Suppress all output except errors'
		k_tool_options_add 'verbose' 'V' '' 'Show verbose output'
		k_tool_options_add 'version' 'v' '' 'Show the version'
	}

	k_log_level "${KOALEPHANT_LOG_LEVEL_NOTICE}" > /dev/null

	read_options() {
		# shellcheck disable=SC2039
		local originalCount="$#"

		while k_options_split "$@"; do
			case "$OPTION_NAME" in

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

		return $(( originalCount - $# ))
	}

	read_options "$@" || shift "$?"

	k_version_helper "${showVersion}" "${quiet}" "${verbose}" && return 0

	k_requires_args "$(k_tool_name)" "$#" 2

	k_version_compare "$@"
}

k_version_compare_tool "$@"
