#@IgnoreInspection BashAddShebang
# Filesystem functionality (Koalephant Shell Script Library)
# Version: PACKAGE_VERSION
# Copyright: 2017, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

readonly K_FS_TEMP_FILES_FILENAME='k-fs-temp-files'

# Resolve a given filesystem path to an absolute path
#
# Input:
# $1 - the path to resolve
#
# Output:
# the resolved path
k_fs_resolve() {
	# shellcheck disable=SC2039
	local path dir='' base='' segment

	k_requires_args k_fs_resolve "$#"

	path="${1%/}"

	if [ -d "${path}" ]; then
		dir="${path}"
	else
		dir="$(k_fs_dirname "${path}")"
		base="$(k_fs_basename "${path}")"
	fi

	if [ -z "${dir}" ]; then
		dir="."
	fi

	if [ -d "${dir}" ]; then
		dir="$(unset CDPATH && cd "${dir}" && pwd -P)"
	else
		if ! k_string_starts_with '/' "$dir"; then
			# Prefix relative paths with current path
			dir="${PWD}/${dir}"
		fi

		filter_traversal() {
			# shellcheck disable=SC2039
			local raw="${1#/}" dir='' segment=''
			while [ -n "$raw" ]; do
				segment="${raw%%/*}"
				raw="${raw#${segment}/*}"
				if [ "${raw}" = "${segment}" ]; then
					raw=''
				fi
				case "$segment" in
					(..)
						dir="${dir%/*}"
					;;

					(.)
					;;

					(*)
						dir="${dir}/${segment}"
					;;
				esac
			done

			printf -- '%s' "${dir}"
		}

		dir="$(filter_traversal "${dir}")"
	fi

	dir="${dir%/}"

	if [ -L "${dir}/${base}" ]; then
		# shellcheck disable=SC2012,SC2046
		base="$(unset CDPATH && cd "${dir}" && printf '%s\t' $(ls -l -d "${base}") | cut -f 11)"
		if k_string_starts_with '/' "${base}"; then
			k_fs_resolve "${base}"
			return "$?"
		fi
	fi

	printf -- '%s' "${dir}${base:+/}${base}"
}

# Get the base name of a filesystem path, optionally with an extension removed
#
# Input:
# $1 - the path to get the basename of
# $2 - the extension to remove if found
#
# Output:
# the base name of the given path
k_fs_basename() {
	# shellcheck disable=SC2039
	local path extension

	k_requires_args k_fs_basename "$#"

	path="${1%/}"
	extension="${2:-}"

	path="${path##*/}"

	if [ -n "${extension}" ]; then
		path="${path%$extension}"
	fi

	printf -- '%s\n' "${path:-/}"
}

# Get the extension of a filesystem path
#
# Input:
# $1 - the path to get the extension of
# $2 - flag to get all extension parts, rather than just the last part. Defaults to false.
#
# Output:
# the extension of the given path, if it has one
#
# Example:
# k_fs_extension foo.bar.baz [false] // baz
# k_fs_extension foo.bar.baz true // bar.baz
k_fs_extension() {
	# shellcheck disable=SC2039
	local path extension

	k_requires_args k_fs_extension "$#"

	path="$(k_fs_basename "${1}")"

	if [ "${2:-false}" = true ]; then
		extension="${path#*.}"
	else
		extension="${path##*.}"
	fi

	if [ "${extension}" != "${path}" ]; then
		printf -- '%s\n' "${extension}"
	fi
}


# Get the parent directory path of a filesystem path
#
# Input:
# $1 - the path to get the parent directory path of
#
# Output:
# the parent directory name of the given path
k_fs_dirname() {
	# shellcheck disable=SC2039
	local path dirPath

	k_requires_args k_fs_dirname "$#"

	path="${1%/}"
	dirPath="${path%/*}"

	if [ -n "${path}" ] && [ "${path}" = "${dirPath}" ]; then
		dirPath="."
	fi

	printf -- '%s\n' "${dirPath:-/}"
}

# Low level function to create a temporary file or directory, or lookup the system temp dir.
# Note, this does *not* register the created files/directories for cleanup.
# Generally you should not use this, it's used by (#k_fs_temp_dir) and (#k_fs_temp_file)
#
# Input:
# $0 - the type to create: either 'file', 'dir' or 'parent'
# $KOALEPHANT_TMP_USE_MEM - flag to try to use a memory-based filesystem if possible
# $KOALEPHANT_TMP_REQ_MEM - flag to require a memory-based filesystem, and error if not possible
#
# Output:
# the generated file or directory name.
#
# Return:
# 0 if the temp file/dir was created, 2 if neither `mktemp` nor `/dev/urandom` is available
k_fs_temp_get_raw() {
	# shellcheck disable=SC2039
	local type tmpName tmpDir="${TMPDIR:-/tmp}" useMktemp='true'

	k_requires_args k_fs_temp_get_raw "$#"

	type="$1"

	get_random() {
		LC_CTYPE='C' tr -dc A-Za-z0-9 < /dev/urandom | dd ibs=1 count=20 2>/dev/null
	}

	get_memory_dir() {
		case "$(uname -s | k_string_lower)" in
			(linux)
				for path in $(df -t swap -t tmpfs --output='target'); do
					if [ -d "${path}" ] && [ -w "${path}" ]; then
						k_log_debug 'Found writable memory filesystem for temp: "%s"' "${path}"
						tmpDir="${path}"
						return 0
					fi
				done
			;;
		esac

		return 1
	}

	if k_bool_test "${KOALEPHANT_TMP_REQ_MEM:-false}"; then
		if ! get_memory_dir; then
			k_log_err 'No writable memory filesystem found for temp'
			return 2
		fi
		useMktemp='false'
	elif k_bool_test "${KOALEPHANT_TMP_USE_MEM:-false}" && get_memory_dir; then
		useMktemp='false'
	fi

	if [ "${useMktemp}" = 'true' ] && command -v mktemp > /dev/null; then
		case "${type}" in
			(file)
				mktemp
			;;

			(dir)
				mktemp -d
			;;

			(parent)
				k_fs_dirname "$(mktemp -u)"
			;;
		esac
	elif [ -c /dev/urandom ]; then
		case "${type}" in
			(file)
				while true; do
					tmpName="${tmpDir}/$(get_random)"
					if (umask 077; set -C; printf -- '' 2>/dev/null > "${tmpName}"); then
						printf -- '%s' "${tmpName}"
						break
					fi
				done
			;;

			(dir)
				while true; do
					tmpName="${tmpDir}/$(get_random)"
					if mkdir -m 0700 "${tmpName}" 2>/dev/null; then
						printf -- '%s' "${tmpName}"
						break
					fi
				done
			;;

			(parent)
				printf -- '%s' "${tmpDir%/}"
			;;
		esac
	else
		# shellcheck disable=SC2016
		k_log_err 'No `mktemp` or `/dev/urandom` found, cannot generate temporary %s' "${type}"
		return 2
	fi
}

# Get a temp directory
#
# Input:
# $KOALEPHANT_TMP_USE_MEM - flag to try to use a memory-based filesystem if possible
# $KOALEPHANT_TMP_REQ_MEM - flag to require a memory-based filesystem, and error if not possible
#
# Output:
# the temp directory path
k_fs_temp_dir() {
	# shellcheck disable=SC2039
	local tmpDir

	tmpDir="$(k_fs_temp_get_raw dir)"

	k_log_debug 'Created temporary directory: "%s"' "${tmpDir}"

	k_fs_register_temp_file "${tmpDir}"

	printf -- '%s\n' "${tmpDir}"
}

# Get a temp file
#
# Input:
# $KOALEPHANT_TMP_USE_MEM - flag to try to use a memory-based filesystem if possible
# $KOALEPHANT_TMP_REQ_MEM - flag to require a memory-based filesystem, and error if not possible
#
# Output:
# the temp file path
k_fs_temp_file() {
	# shellcheck disable=SC2039
	local tmpFile

	tmpFile="$(k_fs_temp_get_raw file)"

	k_log_debug 'Created temporary file: "%s"' "${tmpFile}"

	k_fs_register_temp_file "${tmpFile}"

	printf -- '%s\n' "${tmpFile}"
}

# Register a file as temporary, for automatic cleanup
#
# Input:
# $1...n the filename(s) to register as temporary files
k_fs_register_temp_file() {
	printf -- '%s\n' "$@" >> "$(KOALEPHANT_TMP_REQ_MEM=false KOALEPHANT_TMP_USE_MEM=false k_fs_predictable_file "${K_FS_TEMP_FILES_FILENAME}")"
}

# Get a 'predictable' temporary directory
# The directory path is generated using constants for this process, so they can be retrieved within a trap callback
#
# Input:
# $1 - the basename for the directory. If not specified, the output of (#k_tool_name) is used
# $2 - the optional suffix for the directory
# $KOALEPHANT_TMP_USE_MEM - flag to try to use a memory-based filesystem if possible
# $KOALEPHANT_TMP_REQ_MEM - flag to require a memory-based filesystem, and error if not possible
#
# Output:
# the temporary directory name
# Return:
# 0 if the directory is usable, 1 if it cannot be used due to a file existing with the same name.
k_fs_predictable_dir() {
	# shellcheck disable=SC2039
	local name suffix tmpDir

	name="${1:-$(k_tool_name)}"
	suffix="${2:-}"
	tmpDir="$(k_fs_temp_get_raw parent)/${name}.${$}${suffix}" || return "$?"

	if ! mkdir -p "${tmpDir}"; then
		if [ -f "${tmpDir}" ]; then
			k_log_err 'Cannot create predictable directory, file exists already: "%s"' "${tmpDir}"
			return 1
		fi
	fi

	k_log_debug 'Using predictable temporary directory: "%s"' "${tmpDir}"

	k_fs_register_temp_file "${tmpDir}"

	printf -- '%s\n' "${tmpDir}"
}

# Get a 'predictable' temporary file
# The file path is generated using constants for this process, so they can be retrieved within a trap callback
#
# Input:
# $1 - the basename for the file. If not specified, the output of (#k_tool_name) is used
# $2 - the optional suffix for the filename
# $KOALEPHANT_TMP_USE_MEM - flag to try to use a memory-based filesystem if possible
# $KOALEPHANT_TMP_REQ_MEM - flag to require a memory-based filesystem, and error if not possible
#
# Output:
# the temporary file name
#
# Return:
# 0 if the file is usable, 1 if it cannot be used due to a directory existing with the same name.
k_fs_predictable_file() {
	# shellcheck disable=SC2039
	local name suffix tmpFile initialFormat=''

	name="${1:-$(k_tool_name)}"
	suffix="${2:-}"
	tmpFile="$(k_fs_temp_get_raw parent)/${name}.${$}${suffix}" || return "$?"

	if [ "${name}" = "${K_FS_TEMP_FILES_FILENAME}" ] && [ -z "${suffix}" ]; then
		initialFormat='%s\n'
	fi

	k_log_debug 'Using predictable temporary file: "%s"' "${tmpFile}"

	# shellcheck disable=SC2059
	if ! (set -C; printf -- "${initialFormat}" "${tmpFile}" 2>/dev/null > "${tmpFile}"); then
		if [ -d "${tmpFile}" ]; then
			k_log_err 'Cannot create predictable file, directory exists already: "%s"' "${tmpFile}"
			return 1
		else
			k_log_debug 'Using existing predictable temp file "%s"' "${tmpFile}"
		fi
	fi

	if [ -z "${initialFormat}" ]; then
		k_fs_register_temp_file "${tmpFile}"
	fi

	printf -- '%s\n' "${tmpFile}"
}

# Cleanup temp files and directories
k_fs_temp_cleanup() {
	# shellcheck disable=SC2039
	local tempFilesFile

	tempFilesFile="$(k_fs_predictable_file "${K_FS_TEMP_FILES_FILENAME}")"
	k_log_info "Cleaning up temp files"

	while IFS= read -r file; do
		k_log_debug 'Removing "%s"' "${file}"
		rm -rf "${file}"
	done < "${tempFilesFile}"
}

# Make a file/directory accessible only by the named or current user
# Changes user/group ownership and sets read/write (+executable if a directory or already executable) permission to user only
#
# Input:
# $1 - the path to set ownership/permissions on
# $2 - the username to set ownership to. If omitted, uses the current user
# $3 - the group to set ownership to. If omitted, uses the current user's primary group
k_fs_perms_useronly() {
	# shellcheck disable=SC2039
	local path user group

	k_requires_args k_fs_perms_useronly "$#"

	path="${1}"
	user="${2:-$(id -n -u)}"
	group="${3:-$(id -n -g)}"

	k_log_debug 'Setting ownership of "%s"' "${path}"
	chown -R "${user}:${group}" "${path}"

	k_log_debug 'Setting permissions on "%s"' "${path}"
	chmod -R 'u=rwX,go=' "${path}"
}

# Run (#k_fs_temp_cleanup) when the program exits.
# This uses trap to listen for the signals INT TERM QUIT EXIT HUP
# This should handle most causes of exit:
# Regular program close, Ctrl-C, SIGHUP, etc.
# Note: This does NOT cleanup temp files if the program receives the ABRT signal.
# Use (#k_fs_temp_abort) to cleanup on ABRT.
k_fs_temp_exit() {
	cleanup_exit() {
		k_log_debug "Caught exit Signal"
		trap - INT TERM QUIT EXIT HUP
		k_fs_temp_cleanup
	}

	trap cleanup_exit INT TERM QUIT EXIT HUP
}

# Run (#k_fs_temp_cleanup) when the program is killed.
# This uses trap to listen for the signal ABRT
# Note: This will ONLY cleanup temp files if the program receives the ABRT signal.
# Use (#k_fs_temp_exit) to cleanup on INT TERM QUIT EXIT HUP.
k_fs_temp_abort() {
	cleanup_abort() {
		k_log_debug "Caught abort Signal"
		trap - ABRT
		k_fs_temp_cleanup
	}

	trap cleanup_abort ABRT
}

# Checks if a path is an empty directory
#
# Input:
# $1 - the path to check
#
# Return:
# 0 if the path is an empty directory, 1 if not empty, 2 if not a directory
k_fs_dir_empty() {
	# shellcheck disable=SC2039
	local path

	k_requires_args k_fs_dir_empty "$#"

	path="$1"

	if [ -d "${path}" ]; then
		# shellcheck disable=SC2012
		[ "$(ls -qAL -- "${path}" | wc -l)" -eq 0 ]
	else
		k_log_debug 'Not a directory: "%s"' "${path}"
		return 2
	fi
}
