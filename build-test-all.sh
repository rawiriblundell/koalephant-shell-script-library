#!/bin/sh -eu

build_test_all() {
	local ALL_SHELLS shell tmpdir
	readonly ALL_SHELLS='dash bash mksh'

	cd "${0%/*}"

	tmpdir="$(mktemp -d)"

	version_shell() {
		case "$1" in
			(bash)
				command "$1" <<-EOT
					printf -- '%s %s' '$1' "\$BASH_VERSION"
				EOT
			;;

			(mksh|ksh)
				command "$1" <<-EOT
					printf -- '%s %s' '$1' "\$KSH_VERSION"
				EOT
			;;

			(dash)
				printf -- '%s %s' "$1" "$(dpkg -s dash | sed -n 's/Version: //p')"
			;;
		esac
	}

	check_sums() {
		local first second error=0
		shift
		for first in "$@"; do
			for second in "$@"; do
				if [ "$first" = "$second" ]; then
					continue
				fi

				printf -- 'Checking %s hash matches %s\n' "$first" "$second" >&2
				if ! diff "$first" "$second"; then
					printf -- '%s does not match %s\n' "$first" "$second" >&2
					error=1
				fi
			done
		done

		return "$error"
	}

	process_shell() {
		make distclean || true
		./configure --shell "$1"
		make
		if [ "$(basename "$1")" = "sh" ]; then
			make test-runs < /dev/null
		else
			make test < /dev/null
		fi
		make checksums
		make distclean
	}

	for shell in ${ALL_SHELLS}; do
		if ! command -v "${shell}" > /dev/null; then
			printf -- 'Skipping non-existent shell "%s"\n' "${shell}"
			continue
		fi

		printf -- 'Running tests against "%s" at "%s"\n' "$(version_shell "$shell")" "$(command -v "$shell")"
		process_shell "${shell}"

		printf -- 'Running tests against "%s" at "%s" via `sh` symlink\n' "$(version_shell "$shell")" "$(command -v "$shell")"
		ln -sf "$(command -v "${shell}")" "${tmpdir}/sh"

		process_shell "${tmpdir}/sh"
	done

	check_sums ./*.SHA1SUMS

}

build_test_all
