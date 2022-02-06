#!/bin/sh

install_deps() {

	# shellcheck disable=SC2039
	local devDeps=false packages

	while [ $# -gt 0 ]; do
		case "$1" in

			(--dev)
				devDeps=true
				shift
			;;

			(--extras)
				packages="${packages} ${2}"
				shift 2
			;;

			(--)
				shift
				break
			;;

			(*)
				break
			;;
		esac
	done

	case "$(uname -s)" in
		(Linux)
			if [ -f /etc/debian_version ]; then
				apt-get update
				packages="${packages} help2man build-essential"

				if ! command -v php > /dev/null && ! command -v python2 > /dev/null && ! command -v python3 > /dev/null; then
					packages="${packages} python3"
				fi

				if [ ${devDeps} = true ]; then
					packages="${packages} shellcheck shunit2 python python3 php-cli php-dba sudo gnupg dirmngr bash dash mksh haveged"
				fi

				# shellcheck disable=SC2086
				apt-get install --yes ${packages}
			fi
		;;

		(Darwin)

		;;

	esac

}

install_deps "$@"
