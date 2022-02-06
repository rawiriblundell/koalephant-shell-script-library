#@IgnoreInspection BashAddShebang
k_hash_op_php() {
	# shellcheck disable=SC2039
	local op

	k_requires_args k_hash_op_php "$#"

	op="$1"
	shift

	case "${op}" in
		(avail)
			k_requires_args k_hash_op_php $(( $# + 1 )) 2

			if command -v php >/dev/null; then
				case "${1}" in
					(whoami|algos)
						return 0
					;;

					(verify|generate)
						php "${KOALEPHANT_LIB_PATH}/hash-modules/hash.php" "${op}" "$2"
					;;
				esac

				return 0
			fi
			return 1
		;;

		(whoami)
			php --version
		;;

		(algos)
			php "${KOALEPHANT_LIB_PATH}/hash-modules/hash.php" "${op}"
		;;

		(verify)
			k_requires_args k_hash_op_php $(( $# + 1 )) 4

			php "${KOALEPHANT_LIB_PATH}/hash-modules/hash.php" "${op}" "$@"
		;;

		(generate)
			k_requires_args k_hash_op_php $(( $# + 1 )) 3

			php "${KOALEPHANT_LIB_PATH}/hash-modules/hash.php" "${op}" "$@"
		;;

		(*)
			false
		;;

	esac
}
