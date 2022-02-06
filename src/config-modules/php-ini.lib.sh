
# PHP (readonly) Config Module using parse_ini_file()
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
k_config_op_php_ini() {
	# shellcheck disable=SC2039
	local op realOp phpLib="${KOALEPHANT_LIB_PATH}/config-modules/config-ini.php"
	k_requires_args k_config_op_php "$#" 2

	op="$1"
	shift

	case "${op}" in
		(avail)
			if command -v php >/dev/null && php "${phpLib}" "${op}"; then
				realOp="$1"
				case "${realOp}" in
					(avail|whoami|sections|keys|read)
						return 0
					;;
				esac
			fi
			return 1
		;;

		(whoami)
			php --version
		;;

		(sections|keys|read)
			if ! k_config_file_check_readable "$@"; then
				return 1
			fi

			php "${phpLib}" "${op}" "$@"
		;;

		(*)
			false
		;;

	esac
}
