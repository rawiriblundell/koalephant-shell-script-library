#@IgnoreInspection BashAddShebang
# Hashing functionality (Koalephant Shell Script Library)
# Version: PACKAGE_VERSION
# Copyright: 2019, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# List of loaded Hash modules
KOALEPHANT_HASH_MODULES_LOADED=''

# Perform a hash operation
#
# Input:
# $1 - the operation to perform, one of 'verify', 'generate', 'avail' and 'whoami' or 'load'
# $2...n - extra arguments for the operation
# $KOALEPHANT_HASH_MODULE an override to use a specific hash module
#
# Output:
# The result from the hash module
#
# Return:
# 0 unless error, then 1, or no hash module is usable, then 2.
k_hash_op() {
	# shellcheck disable=SC2039
	local file moduleOp moduleName

	k_requires_args k_hash_op "$#" 1

	fix_module_name() {
		printf -- '%s' "$1" | sed -e 's/-/_/g'
	}

	module_op_func() {
		printf -- 'k_hash_op_%s' "${1}"
	}

	if [ -z "${KOALEPHANT_HASH_MODULES_LOADED}" ]; then
		k_log_debug 'Loading hash modules'
		for file in "${KOALEPHANT_LIB_PATH}/hash-modules/"*.lib.sh; do
			if [ -f "${file}" ]; then
				# shellcheck disable=SC1090
				. "${file}" #K_SCRIPT_BUILD_IGNORE_ALWAYS
				moduleName="$(fix_module_name "$(k_fs_basename "${file}" .lib.sh)")"
				moduleOp="$(module_op_func "${moduleName}")"
				if command -v "${moduleOp}" > /dev/null; then
					KOALEPHANT_HASH_MODULES_LOADED="${KOALEPHANT_HASH_MODULES_LOADED}${moduleName} "
				fi
			fi
		done

		readonly KOALEPHANT_HASH_MODULES
	fi

	if [ "${1}" = 'load' ]; then
		return 0
	fi

	override_module() {
		[ -z "${KOALEPHANT_HASH_MODULE:-}" ] || [ "$(fix_module_name "${KOALEPHANT_HASH_MODULE}")" = "${1}" ]
	}

	for moduleName in ${KOALEPHANT_HASH_MODULES_LOADED}; do
		moduleOp="$(module_op_func "${moduleName}")"
		if "${moduleOp}" avail "$@" && override_module "${moduleName}"; then
			"${moduleOp}" "$@"
			return "$?"
		fi
	done

	k_log_err 'No hash module available'
	return 2
}

# Print a list of loaded hash modules
#
# Output:
# The module names
k_hash_modules() {
	k_hash_op load
	# shellcheck disable=SC2086
	printf -- '%s\n' ${KOALEPHANT_HASH_MODULES_LOADED}
}

# Print a list of hash algorithms supported by the loaded modules
#
# Output:
# The algorithm names
k_hash_algos() {
	# shellcheck disable=SC2039
	local moduleName algos=''

	k_hash_op load

	for moduleName in ${KOALEPHANT_HASH_MODULE:-$KOALEPHANT_HASH_MODULES_LOADED}; do
		algos="${algos}$(KOALEPHANT_HASH_MODULE=${moduleName} k_hash_op algos) "
	done

	# shellcheck disable=SC2086
	printf -- '%s\n' ${algos} | sort -u
}

# Verify a file against a hash/checksum
#
# Input:
# $1 - the hash/checksum algorithm. Use `k_hash_alogs()` to get a list of supported algorithms
# $2 - the file to verify the hash against, or `-` to use stdin
# $3 - the known hash/checksum
#
# Return:
# 0 if the hash is verified, 1 if not
k_hash_verify() {
	k_requires_args k_hash_verify "$#" 3

	k_hash_op verify "$@"
}

# Verify a file against a hash/checksum
#
# Input:
# $1 - the hash/checksum algorithm. Use `k_hash_alogs()` to get a list of supported algorithms
# $2 - the file to generate the hash for, or `-` to use stdin
#
# Return:
# 0 if the hash is verified, 1 if not
k_hash_generate() {
	k_requires_args k_hash_generate "$#" 2

	k_hash_op generate "$@"
}
