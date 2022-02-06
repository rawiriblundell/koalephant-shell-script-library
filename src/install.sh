#!/bin/sh
# Generated Install script for PACKAGE_VENDOR-PACKAGE_NAME PACKAGE_VERSION
(
	set -eu
	url="https://bitbucket.org/PACKAGE_VENDOR/PACKAGE_NAME/downloads/PACKAGE_VENDOR-PACKAGE_NAME-PACKAGE_VERSION.tar.gz"
	printf -- 'Attempting to download and install %s-%s v%s from %s\n' 'PACKAGE_VENDOR' 'PACKAGE_NAME' 'PACKAGE_VERSION' "${url}" >&2
	dl_file="$(mktemp)"
	build_dir="$(mktemp -d)"
	if command -v curl >/dev/null; then
		curl --fail --location --silent --show-error --output "${dl_file}" --url "${url}"
	elif command -v wget >/dev/null; then
		wget --no-verbose --progress=bar --show-progress --output-document "${dl_file}" "${url}"
	else
		printf -- 'Neither curl nor wget is available, cannot download %s-%s v%s\n' 'PACKAGE_VENDOR' 'PACKAGE_NAME' 'PACKAGE_VERSION' >&2
		exit 2
	fi

	tar -C "${build_dir}" -xvf "${dl_file}"
	cd "${build_dir}"/
	sudo ./install-deps.sh
	./configure
	make
	sudo make install
)
