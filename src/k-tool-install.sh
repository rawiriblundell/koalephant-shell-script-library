#!/bin/sh
# Install a tool following the Koalephant standard for setup
# Version: PACKAGE_VERSION
# Copyright: 2019, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Install a tool following the Koalephant standard for setup
k_tool_install () {

	set -eu

	. ./base.lib.sh
	. ./bool.lib.sh
	. ./fs.lib.sh
	. ./string.lib.sh
	. ./number.lib.sh
	. ./hash.lib.sh

	# shellcheck disable=SC2039
	local KOALEPHANT_TOOL_DESCRIPTION KOALEPHANT_TOOL_VERSION KOALEPHANT_TOOL_ARGUMENTS KOALEPHANT_LOG_SYSLOG \
		showVersion=false verbose=false tarOpts='' quiet=false debug=false dryRun=false useLocal=false \
		defaultVendorName defaultMakeTarget defaultVersionBefore \
		name='' version='' vendor='' \
		sudoInstall=true sudoDetect=true versionOption='--version --quiet' versionOffset=3 allowDowngrade=false \
		localBase='' localPath='_vendor_-_name_/' localSuffix='' \
		urlBase='https://bitbucket.org/_vendor_/' urlPath='_name_/' urlSuffix='downloads/' \
		archiveName='_vendor_-_name_-_version_.tar.gz' archivePath='' archiveHash='' archiveAlgo='sha1'

	readonly defaultMakeTarget='install'
	readonly defaultVendorName='PACKAGE_VENDOR'
	readonly defaultVersionBefore=''
	readonly KOALEPHANT_LOG_SYSLOG=true
	readonly KOALEPHANT_TOOL_VERSION='PACKAGE_VERSION'
	readonly KOALEPHANT_TOOL_DESCRIPTION='Install a tool following the Koalephant standard for setup'
	readonly KOALEPHANT_TOOL_ARGUMENTS='tool-name version bin-names...'

	k_fs_temp_exit

	k_tool_usage_init () {
		# shellcheck disable=SC2119
		k_tool_description_add <<-'EOT'
			If none of the executables named after [version] exist and pass the required version check, the tool will be installed from either a local source using --path-base or from a remote location (customisable using --url-base, --url-suffix and --archive-pattern)

			The options set by --local-base, --local-path, --local-suffix, --url-base, --url-path, --url-suffix, and --archive-name will all be treated as patterns, with _vendor_, _name_, and _version_ substrings being replaced by appropriate values.
		EOT


		# shellcheck disable=SC2016
		k_tool_options_add 'allow-downgrade' '' '' \
			'Allow the tool to install a lower version of the package specified, if the version installed is greater than $VERSION_BEFORE'
		# shellcheck disable=SC2016
		k_tool_options_add 'archive-algo' '' 'algo' \
			'The algorithm to hash the archive with when comparing to the option set by `--archive-hash`.' \
			'Defaults to sha1, accepts md5, sha1, sha225, sha256, sha384, sha512.'
		k_tool_options_add 'archive-hash' '' 'hash' 'A known hash of the original archive, to compare to the downloaded archive.'
		k_tool_options_add 'archive-name' '' 'pattern' "Pattern to calculate archive filename. Defaults to '${archiveName}'."
		k_tool_options_add 'archive-path' '' 'pattern' 'Pattern to calculate the path to the sources inside the archive. Defaults to empty.'
		k_tool_options_add 'debug' 'D' '' 'Show debug output'
		k_tool_options_add 'dry-run' '' '' 'Show the commands that would be run, do not run them'
		k_tool_options_add 'help' 'h' '' 'Show this help'
		k_tool_options_add 'local-base' '' 'path' 'Local prefix to use when finding sources to install'
		k_tool_options_add 'local-path' '' 'path' 'Local path to use when finding sources to install.'
		k_tool_options_add 'local-suffix' '' 'suffix' 'Local suffix to use when finding sources to install.'
		# shellcheck disable=SC2016
		k_tool_options_add 'no-sudo-detect' '' '' 'Do not use `sudo` when detecting dependencies.'
		# shellcheck disable=SC2016
		k_tool_options_add 'no-sudo-install' '' '' \
			'Do not use `sudo` when running `install-deps.sh` or `make install` (or whatever target is specified by MAKE_TARGET).'
		k_tool_options_add 'quiet' 'q' '' 'Suppress all output except errors'
		k_tool_options_add 'url-base' '' 'url' "URL prefix to use when finding sources to install. Defaults to '${urlBase}'."
		k_tool_options_add 'url-path' '' 'path' "URL path to use when finding sources to install. Defaults to '${urlPath}'."
		k_tool_options_add 'url-suffix' '' 'suffix' "URL suffix to use when downloading sources. Defaults to '${urlSuffix}'."
		k_tool_options_add 'verbose' 'V' '' 'Show verbose output'
		k_tool_options_add 'version' 'v' '' 'Show the version'
		k_tool_options_add 'version-opt' '' 'option' "The option/argument to pass to the tool to identify the version. Defaults to '${versionOption}'."
		k_tool_options_add 'version-offset' '' 'offset' \
			'The nth position in space separated tokens output by --version-offset, to read as the version number.' \
			"Defaults to '${versionOffset}'."

		k_tool_environment_add 'VENDOR_NAME' "The prefix applied to the project name. Defaults to '${defaultVendorName}'"
		k_tool_environment_add 'MAKE_TARGET' "The target to call to perform the install. Defaults to '${defaultMakeTarget}'"
		# shellcheck disable=SC2016
		k_tool_environment_add 'DEPS_OPTIONS' 'Options/arguments to pass to the `install-deps.sh` script(s)'
		# shellcheck disable=SC2016
		k_tool_environment_add 'CONFIG_OPTIONS' 'Options/arguments to pass to the `configure` script(s)'
		k_tool_environment_add 'VERSION_BEFORE' 'Version number to remain lower than'
	}

	run_command() {
		k_requires_args run_command $#
		if [ ${dryRun} = true ]; then
			printf -- '%s\n' "$*" > /dev/tty
		else
			# shellcheck disable=SC2016
			k_log_debug 'Running command `%s`' "$*"
			command "$@"
		fi
	}

	run_command_redirect_output() {
		# shellcheck disable=SC2039
		local output
		k_requires_args run_command_redirect_output $# 2
		output="$1"
		shift

		if [ ${dryRun} = true ]; then
			printf -- '%s > %s\n' "$*" "${output}" > /dev/tty
		else
			# shellcheck disable=SC2016
			k_log_debug 'Running command `%s > %s`' "$*" "${output}'"
			command "$@" > "${output}"
		fi
	}

	check_binary_root() {
		PATH="$(printf -- '%s\n' "$PATH" | sed -E 's#([^:]+)/bin:#\1/sbin:\1/bin:#g')"
		export PATH

		check_binary "$@"
	}

	apply_template_vars() {
		sed -e "s#_vendor_#${vendor}#g; s#_name_#${name}#g; s#_version_#${version}#g"
	}

	check_binary() {
		# shellcheck disable=SC2039
		local binTry

		k_requires_args check_binary "$#"

		for binTry in "$@"; do
			k_log_info 'Checking for %s binary: %s' "${name}" "${binTry}"
			if command -v "${binTry}" > /dev/null; then
				k_log_notice 'Found %s: %s' "${name}" "${binTry}"
				printf -- '%s' "${binTry}"
				return 0
			fi
		done

		k_log_notice '%s not detected, cannot find %s' "${name}" "$*"
		return 1
	}

	check_installed() {
		# shellcheck disable=SC2039
		local foundBin='' foundVersion='' versionMax="${VERSION_BEFORE:-${defaultVersionBefore}}"

		k_requires_args check_installed "$#"

		if [ "${sudoDetect}" = true ]; then
			foundBin=$(check_binary_root "$@") || return 1
		else
			foundBin=$(check_binary "$@") || return 1
		fi


		# shellcheck disable=SC2086
		foundVersion="$(k_string_trim "$(${foundBin} ${versionOption} | head -n 1)")" || return 1

		if k_string_contains ' ' "${foundVersion}"; then
			foundVersion="$(k_string_remove_start v "$(printf -- '%s' "${foundVersion}" | cut -f "${versionOffset}" -d ' ')")"
		fi

		if [ -n "${versionMax}" ] && ! k_version_compare "${foundVersion}" "${versionMax}" 'lt'; then
			if ! [ "${allowDowngrade}" = true ]; then
				k_log_err 'Requested version %s is lower than installed version %s, use --allow-downgrade if you wish to install the lower version' "${version}" "${foundVersion}"
				exit 1
			fi
			k_log_notice '%s version mismatch. Required: >= %s & < %s, found: %s' "${name}" "${version}" "${versionMax}" "${foundVersion}"
			k_log_warning 'Downgrading %s from %s to %s' "${name}" "${foundVersion}" "${version}"
			return 1
		fi


		if ! k_version_compare "${foundVersion}" "${version}" 'gte'; then
			if [ -n "${versionMax}" ]; then
				k_log_notice '%s version mismatch. Required: >= %s & < %s, found: %s' "${name}" "${version}" "${versionMax}" "${foundVersion}"
			else
				k_log_notice '%s version mismatch. Required: >= %s, found: %s' "${name}" "${version}" "${foundVersion}"
			fi
			return 1
		fi

		if [ -n "${versionMax}" ]; then
			k_log_notice '%s installed with adequate version. Required: >= %s & < %s, found: %s' "${name}" "${version}" "${versionMax}" "${foundVersion}"
		else
			k_log_notice '%s installed with adequate version. Required: >= %s, found: %s' "${name}" "${version}" "${foundVersion}"
		fi

	}

	download_library_source() {
		# shellcheck disable=SC2039
		local name version url tmpFile

		k_requires_args download_library_source "$#"

		url="$1"
		tmpFile="$(k_fs_temp_file)"

		k_log_info 'Downloading %s from %s' "${name}" "${url}"
		k_log_debug 'Temporary file is: %s' "${tmpFile}"

		if command -v curl > /dev/null; then
		# shellcheck disable=SC2086
			run_command curl --fail --location --silent --show-error --output "${tmpFile}" --url "${url}"
		elif command -v wget >/dev/null; then
			run_command wget --no-verbose --progress=bar --show-progress --output-document "${tmpFile}" "${url}"
		else
			# shellcheck disable=SC2016
			k_log_err 'No downloader available, %s requires one of `curl` or `wget`' "$(k_tool_name)"
			exit 2
		fi

		extract_library_source "${tmpFile}"
	}

	extract_library_source() {
		# shellcheck disable=SC2039
		local file tmpDir subPath

		k_requires_args extract_library_source "$#"

		file="$1"
		tmpDir="$(k_fs_temp_dir)"
		subPath="$(printf -- '%s' "${archivePath}" | apply_template_vars)"

		if [ -n "${archiveHash}" ] && [ -n "${archiveAlgo}" ]; then
			if ! k_hash_verify "${archiveAlgo}" "${file}" "${archiveHash}"; then
				k_log_err 'Failed to verify hash %s:%s against archive %s' "${archiveAlgo}" "${archiveHash}" "${file}"
				return 2
			fi
		fi

		run_command tar -C "${tmpDir}" ${tarOpts} -xvf "${file}"
		unset CDPATH
		run_command cd "${tmpDir}/${subPath}"
	}

	collect_source() {
		# shellcheck disable=SC2039
		local localFilePath

		localFilePath="$(printf -- '%s' "${localBase}" "${localPath}" "${localSuffix}" "${archiveName}" | apply_template_vars)"
		if [ "${useLocal}" = true ] && [ -f "${localFilePath}" ]; then
			extract_library_source "${localFilePath}"
		else
			download_library_source "$(printf -- '%s' "${urlBase}" "${urlPath}" "${urlSuffix}" "${archiveName}" | apply_template_vars)"
		fi
	}

	build_install() {
		# shellcheck disable=SC2039
		local sudoCmd=''

		skip_notice () {
			k_log_notice 'Skipping %s, not found or not executable' "$@"
		}

		if [ "${sudoInstall}" = true ]; then
			sudoCmd='sudo'
		fi

		if [ -x install-deps.sh ]; then
			# shellcheck disable=SC2086
			run_command "${sudoCmd}" ./install-deps.sh ${DEPS_OPTIONS:-}
		else
			skip_notice ./install-deps.sh
		fi

		if [ -x configure ]; then
			# shellcheck disable=SC2086
			run_command ./configure ${CONFIG_OPTIONS:-}
		else
			skip_notice ./configure
		fi

		run_command make
		run_command ${sudoCmd} make "${MAKE_TARGET:-${defaultMakeTarget}}"
	}

	read_options() {
		# shellcheck disable=SC2039
		local originalCount="$#"

		while k_options_split "$@"; do
			case "$OPTION_NAME" in
				(--local-base)
					# shellcheck disable=SC2119
					k_options_arg_required
					localBase="${OPTION_VALUE}"
					useLocal=true
					shift "${OPTION_ARG_COUNT}"
				;;

				(--local-path)
					# shellcheck disable=SC2119
					k_options_arg_required '' true
					localPath="${OPTION_VALUE}"
					useLocal=true
					shift "${OPTION_ARG_COUNT}"
				;;

				(--local-suffix)
					# shellcheck disable=SC2119
					k_options_arg_required '' true
					localSuffix="${OPTION_VALUE}"
					useLocal=true
					shift "${OPTION_ARG_COUNT}"
				;;

				(--url-base)
					# shellcheck disable=SC2119
					k_options_arg_required
					urlBase="${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(--url-path)
					# shellcheck disable=SC2119
					k_options_arg_required '' true
					urlPath="${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(--url-suffix)
					# shellcheck disable=SC2119
					k_options_arg_required '' true
					urlSuffix="${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(--archive-name)
					# shellcheck disable=SC2119
					k_options_arg_required
					archiveName="${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(--archive-path)
					# shellcheck disable=SC2119
					k_options_arg_required
					archivePath="${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(--archive-hash)
					# shellcheck disable=SC2119
					k_options_arg_required
					archiveHash="${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(--archive-algo)
					# shellcheck disable=SC2119
					k_options_arg_required
					archiveAlgo="${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(--no-sudo-detect)
					sudoDetect=false
					shift
				;;

				(--no-sudo-install)
					sudoInstall=false
					shift
				;;

				(--allow-downgrade)
					allowDowngrade=true
					shift
				;;

				(--version-opt)
					# shellcheck disable=SC2119
					k_options_arg_required
					versionOption="${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(--version-offset)
					# shellcheck disable=SC2119
					k_options_arg_required
					versionOffset="${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(-h|--help)
					k_usage
					exit
				;;

				(-V|--verbose)
					k_log_level "${KOALEPHANT_LOG_LEVEL_INFO}" > /dev/null
					verbose=true
					tarOpts='--verbose'
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

				(--dry-run)
					dryRun=true
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

	k_log_level "${KOALEPHANT_LOG_LEVEL_NOTICE}" > /dev/null
	k_fs_temp_exit

	read_options "$@" || shift "$?"

	k_version_helper "${showVersion}" "${quiet}" "${verbose}" && return 0

	k_requires_args "$(k_tool_name)" "$#" 3

	vendor="${VENDOR_NAME-${defaultVendorName}}"
	name="${1}"
	version="${2}"
	shift 2

	if ! check_installed "$@"; then
		collect_source
		build_install
	fi
}

k_tool_install "$@"
