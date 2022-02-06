#!/bin/sh
# Generated Install script for koalephant-shell-script-library 2.8.1
(
	set -eu
	url="https://bitbucket.org/koalephant/shell-script-library/downloads/koalephant-shell-script-library-2.8.1.tar.gz"
	printf -- 'Attempting to download and install %s-%s v%s from %s\n' 'koalephant' 'shell-script-library' '2.8.1' "${url}" >&2
	dl_file="$(mktemp)"
	build_dir="$(mktemp -d)"
	if command -v curl >/dev/null; then
		curl --fail --location --silent --show-error --output "${dl_file}" --url "${url}"
	elif command -v wget >/dev/null; then
		wget --no-verbose --progress=bar --show-progress --output-document "${dl_file}" "${url}"
	else
		printf -- 'Neither curl nor wget is available, cannot download %s-%s v%s\n' 'koalephant' 'shell-script-library' '2.8.1' >&2
		exit 2
	fi

	tar -C "${build_dir}" -xvf "${dl_file}"
	cd "${build_dir}"/
	sudo ./install-deps.sh
	./configure
	make
	sudo make install
)
