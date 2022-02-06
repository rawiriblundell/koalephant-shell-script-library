# Python2 based Config Module
#
# Input:
# $1 - the operation to perform, one of 'avail', 'sections', 'keys', and 'read'
# $2 - the file to operate on
# $3...n - any additional operation-specific arguments
#
# Output:
# the result from the php script
#
# Return:
# 0 or 1 for success or failure, depending on operation being performed
k_config_op_python2() {
	# shellcheck disable=SC2039
	local op pythonLib="${KOALEPHANT_LIB_PATH}/config-modules/config2.py"
	k_requires_args k_config_op_python2 "$#" 2

	op="$1"
	shift

	case "${op}" in
		(avail)
			command -v python >/dev/null && python "${pythonLib}" "${op}"
		;;

		(whoami)
			python --version 2>&1
		;;

		(sections|keys|read)
			if ! k_config_file_check_readable "$@"; then
				return 1
			fi

			python "${pythonLib}" "${op}" "$@"
		;;

		(write)
			k_requires_args k_config_op_php $(( $# + 1 )) 3

			if ! k_config_file_check_writable "$@"; then
				return 1
			fi

			python "${pythonLib}" "${op}" "$@"
		;;

		(*)
			false
		;;
	esac
}
