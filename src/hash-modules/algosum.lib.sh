#@IgnoreInspection BashAddShebang
k_hash_op_algosum() {
	# shellcheck disable=SC2039
	local op algo tmpFile ALGOS='sha1 sha224 sha256 sha384 sha512 blake2 md5'

	k_requires_args k_hash_op_algosum "$#"

	get_supported_algos() {
		local algo
		for algo in ${ALGOS}; do
	    	if command -v "$(get_cmd_name "$algo")" > /dev/null; then
				printf -- '%s ' "$algo"
	    	fi
		done
	}


	get_cmd_name() {
		if [ "$1" = 'blake2' ]; then
			printf -- 'b2sum'
			return 0
		fi
		printf -- '%ssum' "$1"
	}

	op="$1"
	shift

	case "${op}" in
		(avail)
			k_requires_args k_hash_op_algosum $(( $# + 1 )) 2

			case "${1}" in
				(whoami|algos)
					return 0
				;;

				(verify|generate)
					command -v "$(get_cmd_name "${2}")" > /dev/null
					return "$?"
				;;
			esac

			return 1
		;;

		(whoami)
			for algo in $(get_supported_algos); do
				command "$(get_cmd_name "${algo}")" --version
				return "$?"
			done
		;;

		(algos)
			get_supported_algos
		;;

		(verify)
			k_requires_args k_hash_op_algosum $(( $# + 1 )) 4
			tmpFile="$(k_fs_temp_file)"
			printf -- '%s  %s\n' "$3" "$2" > "${tmpFile}"

			command "$(get_cmd_name "${1}")" -c "${tmpFile}" >/dev/null 2>&1
		;;

		(generate)
			k_requires_args k_hash_op_algosum $(( $# + 1 )) 3

			command "$(get_cmd_name "${1}")" "$2" | cut -f 1 -d ' '
		;;

		(*)
			false
		;;

	esac
}
