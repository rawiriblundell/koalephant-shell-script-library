#!/bin/sh -eu

fs_cleanup_signals() {
	# shellcheck disable=SC2039
	local signal mode

	. ../base.lib.sh
	. ../fs.lib.sh
	. ../bool.lib.sh
	. ../string.lib.sh
	. ../number.lib.sh

	k_requires_args "$0" "$#" 3

	mode="$1"
	signal="$2"
	return="${3:-0}"

	shift 2

	k_fs_register_temp_file "$@"

#	printf -- 'Temp File Register: %s' "$(k_fs_predictable_file "${K_FS_TEMP_FILES_FILENAME}")"

#	set -x

	if [ "${mode}" = "exit" ]; then
		k_fs_temp_exit
	elif [ "${mode}" = "abort" ]; then
		k_fs_temp_abort
	fi

	if [ "${signal}" != 'EXIT' ] && [ "${return}" -eq 0 ]; then
		kill -s "${signal}" $$
	fi

	return "${return}"
}

fs_cleanup_signals "$@"
