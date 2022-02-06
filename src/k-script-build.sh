#!/bin/sh
# Process shell source (.) statements into absolute references or inline the script
# Version: PACKAGE_VERSION
# Copyright: 2017, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Process shell source (.) statements into absolute references or inline the script
k_script_build() {

	set -eu

	. ./base.lib.sh
	. ./bool.lib.sh
	. ./fs.lib.sh
	. ./string.lib.sh
	. ./number.lib.sh

	# shellcheck disable=SC2039,SC2016,SC1003
	local KOALEPHANT_TOOL_VERSION='' KOALEPHANT_TOOL_DESCRIPTION='' \
		INCLUDE_SOURCE_LINES='' FIND_SOURCE_LINES='' FIND_DEPENDENCY_LINES='' \
		infile='' stdInput='false' outfile=/dev/stdout executable='false' report='false' reportReplaced='false' makeDeps='false' \
		workingDir='' sourcePathsFile='' definitionsFile='' sedGlobalOpts='' \
		showVersion='false' verbose='false' quiet='false' debug='false' showHelp='false'

	readonly KOALEPHANT_TOOL_VERSION='PACKAGE_VERSION'
	readonly KOALEPHANT_TOOL_DESCRIPTION='Process shell source (.) statements into absolute references or inline the script'

	readonly INCLUDE_SOURCE_LINES='/#K_SCRIPT_BUILD_IGNORE/n; s/^([[:space:]]*)\.[[:space:]]+/K_SCRIPT_BUILD_INCLUDE\1/g'
	readonly FIND_SOURCE_LINES='/#K_SCRIPT_BUILD_IGNORE/n; s/^[[:space:]]*\.[[:space:]]+/K_SCRIPT_BUILD_REPORT /p'
	readonly FIND_DEPENDENCY_LINES='/#K_SCRIPT_BUILD_IGNORE/n; s/^[[:space:]]*\.[[:space:]]+/K_SCRIPT_BUILD_DEPENDENCY /p'

	sourcePathsFile="$(k_fs_temp_file)"
	definitionsFile="$(k_fs_temp_file)"

	workingDir="$(pwd -P)/"

	k_tool_usage_init () {
		k_tool_description_add <<-'STR'
			Reads the input file specified by -f, --file, or STDIN line-by-line, looking for source (.) statements matching the prefixes specified by either the -i, --inline, --static or -l, --link, --dynamic options.

			Source lines containing the string `#K_SCRIPT_BUILD_IGNORE` (typically an end-of-line comment) will be ignored by the build process, and output almost as-is, with `#K_SCRIPT_BUILD_IGNORE` stripped from the end of the line.

			Output is written to the output file specified by -o, --output or stdout, and depends on the mode of operation:

			build (default):
		STR

		k_tool_description_add 4 <<-'STR'
			Non-matching lines are written out unmodified.

			For source statements matching prefixes specified with the -l, --link option, a new source is written out with the replacement path substituted for the path prefix.

			For source statements matching prefixes specified with the -i, --inline option, the result of running the referenced file through the same build process, and prefixing each line with the same whitespace indent as the original source statement is writen out.
		STR

		k_tool_description_add <<-'STR'
			report (-r, --report, -R, --report-replaced):
		STR

		k_tool_description_add 4 <<-'STR'
			The target pathname of source statements (i.e. the path/filename after the source (.) statment) are written out.
			If -R or --replace-replaced is specified, prefix replacements are applied before each path is written out.
		STR

		k_tool_description_add <<-'STR'
			generate dependencies (-M, --make-deps):
		STR
		k_tool_description_add 4 <<-'STR'
			A Make compatible rule is written out, listing the input file as the target and any directly sourced files as it's dependencies.
			The output of this mode is intended to be included in a Makefile, similar to the CC `-M` option. This project's own Makefile shows an example of how this can be used.
		STR

		k_tool_options_add 'debug' 'D' '' 'Show debug output'
		k_tool_options_add 'define' 'd' 'var=val' 'Define simple replacements to be performed while processing, e.g. LIB_PATH=/foo'
		k_tool_options_alias 'dynamic' '' '--link'
		k_tool_options_add 'executable' 'x' '' 'Mark the resulting file (if not stdout) executable'
		k_tool_options_alias 'exec' '' '--executable'
		k_tool_options_add 'file' 'f' 'file' 'The source to read. If not specified, defaults to stdin'
		k_tool_options_add 'help' 'h' '' 'Show this help'
		k_tool_options_add 'inline' 'i' 'prefix' 'Dir or file path prefix of sources to explicitly inline. Can be specified multiple times'
		k_tool_options_add 'link' 'l' 'prefix=replacement' 'Dir or file path prefix to explicitly link to using the replacement (usually absolute) path. Can be specified multiple times.'
		k_tool_options_add 'make-deps' 'M' '' 'Process input and output a rule suitable for Make, listing the dependencies'
		k_tool_options_add 'output' 'o' 'file' 'The file to write to. If not specified, defaults to stdout'
		k_tool_options_add 'quiet' 'q' '' 'Suppress all output except errors'
		k_tool_options_add 'report' 'r' '' 'Process input and report all sourced files.'
		k_tool_options_add 'report-replaced' 'R' '' 'Report the sourced files after applying prefix replacements. Implies --report.'
		k_tool_options_alias 'static' '' '--inline'
		k_tool_options_add 'version' 'v' '' 'Show the version'
		k_tool_options_add 'verbose' 'V' '' 'Show verbose output'
		k_tool_options_add 'cd' 'c' '' 'Removed option. No longer necessary, has no effect.'
	}

	add_source_path() {
		# shellcheck disable=SC2039
		local type="$1" source="$2" value="${3:-}"
		printf -- '%s#%s#%s\n' "${type}" "${source}" "${value}" >> "${sourcePathsFile}"
	}

	add_dynamic_mapping() {
		# shellcheck disable=SC2039
		local find target

		find="$1"
		target="$2"

		k_log_info 'Adding dynamic mapping for "%s" => "%s"' "${find}" "${target}'"
		add_source_path dynamic "${find}" "${target}"
	}

	add_static_path() {
		# shellcheck disable=SC2039
		local path

		path="$1"
		k_log_info 'Adding static path for "%s"' "${path}"
		add_source_path static "${path}"
	}

	add_definition() {
		# shellcheck disable=SC2039
		local definition value

		definition="$1"
		value="$2"

		k_log_info 'Adding definition for "%s" with value "%s"' "${definition}" "${value}"

		printf -- '%s %s\n' "${definition}" "${value}" >> "${definitionsFile}"
	}

	get_definition_pattern() {
		while IFS=" " read -r key value; do
			if [ -z "${key}" ]; then
				continue
			fi
			k_log_debug 'Using definition: "%s" = "%s"' "${key}" "${value}"
			printf -- 's#(^|[^A-Za-z0-9_])%s([^A-Za-z0-9_]|$)#\\1%s\\2#g; ' "${key}" "${value}"
		done < "${definitionsFile}"
	}

	get_include_def() {
		# shellcheck disable=SC2039
		local includePath line=0

		k_requires_args get_include_def "$#"

		includePath="${1}"

		while IFS="#" read -r type source value; do
			line=$(( line + 1 ))
			case "${includePath}" in
				(${source}*)
					printf -- '%d\n' "${line}"
					return 0
				;;
			esac
		done < "${sourcePathsFile}"

		return 1
	}

	get_include_type() {
		# shellcheck disable=SC2039
		local line

		k_requires_args get_include_type "$#"

		line="${1}"

		sed -n -e "${line}p" < "${sourcePathsFile}" | while IFS="#" read -r type source value; do
			printf -- '%s\n' "${type}"
		done
	}

	get_include_value() {
		# shellcheck disable=SC2039
		local line

		k_requires_args get_include_type "$#"

		line="${1}"

		sed -n -e "${line}p" < "${sourcePathsFile}" | while IFS="#" read -r type source value; do
			printf -- '%s\n' "${value}"
		done
	}

	get_include_pattern() {
		# shellcheck disable=SC2039
		local line

		k_requires_args get_include_type "$#"

		line="${1}"

		sed -n -e "${line}p" < "${sourcePathsFile}" | while IFS="#" read -r type source value; do
			printf -- '%s\n' "${source}"
		done
	}

	check_file_ending() {
		# shellcheck disable=SC2039
		local file count
		file="$1"
		count="$(tail -n 1 "${file}" | wc -l)"

		[ "${count}" -gt 0 ]
	}

	process_file() {
		# shellcheck disable=SC2039
		local currentFile currentDir pattern parentPrefix sedOpts defPattern

		restore_directory() {
			k_log_debug 'Changing to source directory "%s"' "${currentDir}"
			unset CDPATH && cd "${currentDir}"
		}

		currentFile="${1}"
		currentDir="$(pwd)"

		if ! check_file_ending "${currentFile}"; then
			k_log_crit 'No newline found at end of file "%s", aborting' "${currentFile}"
			return 2
		fi

		if [ ! "${stdInput}" = true ] && [ -f "${currentFile}" ]; then
			currentFile="$(k_fs_resolve "${currentFile}")"
			k_log_debug 'Current file is "%s"' "${currentFile}"
			currentDir="$(k_fs_dirname "${currentFile}")"
			k_log_debug 'Current dir is "%s"' "${currentDir}"
			currentFile="$(k_string_remove_start "${currentDir}/" "${currentFile}")"
			k_log_debug 'Current file is actually "%s"' "${currentFile}"

			restore_directory
		fi

		pattern="$2"
		parentPrefix="${3:-}"

		if [ "$#" -ge 2 ]; then
			shift 2
		else
			shift
		fi
		sedOpts="$*"
		defPattern="$(get_definition_pattern)"

		k_log_debug 'Processing stream using pattern: "%s", definition pattern: "%s"' "${pattern}" "${defPattern}"

		# shellcheck disable=SC2086
		sed -E ${sedOpts} ${sedGlobalOpts} -e "s/^/${parentPrefix}/g" -e "${defPattern}" -e "${pattern}" < "${currentFile}" | while IFS= read -r raw; do
			# shellcheck disable=SC2039
			local line="${raw}" prefix="${parentPrefix}" sourcePattern='' includeValue=''

			case "${line}" in
				(*K_SCRIPT_BUILD_IGNORE)
					k_log_debug 'Ignored line: "%s"' "${line}"
					printf -- '%s\n' "$(k_string_remove_end '#K_SCRIPT_BUILD_IGNORE' "${line}")"
				;;

				(K_SCRIPT_BUILD_INCLUDE*)
					k_log_debug 'Processing "include" line: "%s"' "${line}"
					line="$(k_string_remove_start "K_SCRIPT_BUILD_INCLUDE" "${line}")"
					trimmed="$(k_string_trim "${line}")"
					prefix="${prefix}$(k_string_remove_end "${trimmed}" "${line}")"


					if includeDef=$(get_include_def "${trimmed}"); then
						includeValue="$(get_include_value "${includeDef}")"
						sourcePattern="$(get_include_pattern "${includeDef}")"

						case "$(get_include_type "${includeDef}")" in
							(static)
								k_log_debug 'Including file statically: "%s"' "${line}"
								printf -- '%s#K_SCRIPT_BUILD: include(%s)\n' "${prefix}" "${trimmed}"
								process_file "${trimmed}" "${pattern}" "${prefix}" ${sedOpts}
							;;

							(dynamic)
								k_log_debug 'Including file dynamically: "%s"' "${line}"
								printf -- '%s. %s%s\n' "${prefix}" "${includeValue}" "$(k_string_remove_start "${sourcePattern}" "${trimmed}")"
							;;
						esac
					else
						k_log_debug 'Ignoring include: "%s"' "${line}"
						printf -- '%s. %s\n' "${prefix}" "${trimmed}"
					fi
				;;

				(K_SCRIPT_BUILD_REPORT*)
					k_log_debug 'Processing "report" line: "%s"' "${line}"
					line="$(k_string_remove_start "K_SCRIPT_BUILD_REPORT[\ ]*" "${line}")"
					trimmed="$(k_string_trim "${line}")"

					if [ "${reportReplaced}" = true ]; then
						if includeDef=$(get_include_def "${trimmed}") && [ "$(get_include_type "${includeDef}")" = dynamic ]; then
							printf -- '%s%s\n' "$(get_include_value "${includeDef}")" "$(k_string_remove_start "$(get_include_pattern "${includeDef}")" "${trimmed}")"
							continue
						fi
					fi

					printf -- '%s\n' "${line}"
				;;

				(K_SCRIPT_BUILD_DEPENDENCY*)
					k_log_debug 'Processing "dependency" line: "%s"' "${line}"
					line="$(k_string_remove_start "K_SCRIPT_BUILD_DEPENDENCY[\ ]*" "${line}")"
					trimmed="$(k_string_trim "${line}")"

					if includeDef=$(get_include_def "${trimmed}"); then
						includeValue="$(get_include_value "${includeDef}")"
						sourcePattern="$(get_include_pattern "${includeDef}")"

						case "$(get_include_type "${includeDef}")" in
							(static)
								k_log_debug 'Declaring source dependency: "%s"' "${line}"
								printf -- '%s\n' "$(k_string_remove_start "${workingDir}" "$(k_fs_resolve "${trimmed}")")"
							;;

							(dynamic)
								if k_string_starts_with / "${includeValue}"; then
									k_log_debug 'Skipping dynamic dependency: "%s"' "${line}"
								else
									k_log_debug 'Declaring dynamic dependency: "%s"' "${line}"
									printf -- '%s%s\n' "${includeValue}" "$(k_string_remove_start "${sourcePattern}" "${trimmed}")"
								fi
							;;
						esac
					else
						k_log_debug 'Ignoring dependency: "%s"' "${line}"
					fi
				;;

				(*)
					k_log_debug 'Regular line: "%s"' "${line}"
					printf -- '%s\n' "${line}"
				;;
			esac
		done
		restore_directory
	}

	handle_executable() {
		if [ "${executable}" = true ]; then
			if [ -f "${outfile}" ] && [ "${outfile}" != '/dev/stdout' ]; then
				chmod +x "${outfile}"
			else
				k_log_err 'Cannot set executable bit when output is stdout'
				return 2
			fi
		fi
	}

	read_options() {
		# shellcheck disable=SC2039
		local originalCount="$#"

		while k_options_split "$@"; do
			case "$OPTION_NAME" in

				(-h|--help)
					showHelp='true'
					shift
				;;

				(-c|--cd)
					if k_options_arg_optional; then
						shift
					fi
					shift

					k_log_notice "The -c/--cd option is no longer supported or necessary. It has no effect."
				;;

				(-f|--file)
				# shellcheck disable=SC2119
					k_options_arg_required
					infile="${OPTION_VALUE}"
					shift 2
				;;

				(-d|--define)
				# shellcheck disable=SC2119
					k_options_arg_required
					add_definition "$(printf -- '%s\n' "${OPTION_VALUE}" | cut -d = -f 1)" "$(printf -- '%s\n' "${OPTION_VALUE}" | cut -d = -f 2)"
					shift 2
				;;

				(-o|--output)
				# shellcheck disable=SC2119
					k_options_arg_required
					outfile="$(k_fs_resolve "${OPTION_VALUE}")"
					shift 2
				;;

				(-i|--inline|--static)
					if k_options_arg_optional; then
						add_static_path "${OPTION_VALUE}"
						shift 2
					else
						add_static_path './'
						shift
					fi
				;;

				(-l|--link|--dynamic)
				# shellcheck disable=SC2119
					k_options_arg_required
					add_dynamic_mapping "$(printf -- '%s\n' "${OPTION_VALUE}" | cut -d = -f 1)" "$(printf -- '%s\n' "${OPTION_VALUE}" | cut -d = -f 2)"
					shift 2
				;;

				(-r|--report)
					report='true'
					shift
				;;

				(-R|--report-replaced)
					report='true'
					reportReplaced='true'
					shift
				;;

				(-M|--make-deps)
					makeDeps='true'
					shift
				;;

				(-x|--exec|--executable)
					executable='true'
					shift
				;;

				(-V|--verbose)
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

		return $(( originalCount - $# ))
	}

	k_log_level "${KOALEPHANT_LOG_LEVEL_NOTICE}" > /dev/null

	read_options "$@" || shift "$?"

	if [ "${debug}" = 'false' ]; then
		k_fs_temp_exit
	fi

	if [ "${showHelp}" = 'true' ]; then
		k_usage
		return 0
	fi

	k_version_helper "${showVersion}" "${quiet}" "${verbose}" && return 0

	# shellcheck disable=SC2235
	if [ ! -t 0 ] && ([ "${infile}" = '-' ] || [ -z "${infile}" ]); then
		infile="$(k_fs_temp_file)"
		k_log_debug 'Reading script from STDIN, using temporary file %s' "${infile}"
		stdInput='true'
		cat - > "${infile}"
	fi

	k_log_debug 'Source Mappings stored in "%s"' "${sourcePathsFile}"
	k_log_debug 'Source Definitions stored in "%s"' "${definitionsFile}"
	k_log_debug 'Working from base dir "%s"' "${workingDir}"
	k_log_debug 'Input file is "%s"' "${infile}"
	k_log_debug 'Output file is "%s"' "${outfile}"

	if [ "${makeDeps}" = true ]; then
		printf -- '%s: ' "$(k_string_remove_start "${workingDir}" "${infile}")" > "${outfile}"
		# shellcheck disable=SC2046
		printf -- '%s ' $(process_file "${infile}" "${FIND_DEPENDENCY_LINES}" '' -n | LC_CTYPE='C' tr '\n' ' ') >> "${outfile}"
		printf -- '\n' >> "${outfile}"
		return
	fi

	if [ "${report}" = true ]; then
		process_file "${infile}" "${FIND_SOURCE_LINES}" '' -n > "${outfile}"
		return
	fi

	process_file "${infile}" "${INCLUDE_SOURCE_LINES}" > "${outfile}"

	handle_executable
}

k_script_build "$@"
