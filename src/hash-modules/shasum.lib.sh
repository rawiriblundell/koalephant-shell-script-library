#@IgnoreInspection BashAddShebang
k_hash_op_shasum() {
	# shellcheck disable=SC2039
	local op algo tmpFile ALGOS

	readonly ALGOS='sha1 sha224 sha256 sha384 sha512 sha512224 sha512256'

	k_requires_args k_hash_op_shasum "$#"

	op="$1"
	shift

	case "${op}" in
		(avail)
			k_requires_args k_hash_op_shasum $(( $# + 1 )) 2

			if command -v shasum >/dev/null; then

				case "${1}" in
					(whoami|algos)
						return 0
					;;

					(verify|generate)
						for algo in ${ALGOS}; do
							if [ "${algo}" = "$2" ]; then
								return 0
							fi
						done
					;;
				esac

			fi
			return 1
		;;

		(whoami)
			shasum --version
		;;

		(algos)
			# shellcheck disable=SC2086
			printf -- '%s ' ${ALGOS}
		;;

		(verify)
			k_requires_args k_hash_op_shasum $(( $# + 1 )) 4
			algo="${1#sha}"
			shift

			tmpFile="$(k_fs_temp_file)"
			printf -- '%s  %s\n' "$2" "$1" > "${tmpFile}"

			shasum -a "${algo}" -c "${tmpFile}" >/dev/null 2>&1
		;;

		(generate)
			k_requires_args k_hash_op_shasum $(( $# + 1 )) 3
			algo="${1#sha}"
			shift

			shasum -a "${algo}" "$@" | cut -f 1 -d ' '
		;;

		(*)
			false
		;;

	esac
}
