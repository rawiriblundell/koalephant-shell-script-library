#!/bin/sh

. ../base.lib.sh
. ../environment.lib.sh
. ../bool.lib.sh
. ../number.lib.sh
. ../fs.lib.sh
. ../string.lib.sh
. ../hash.lib.sh


debugMode() {
	k_bool_test "${DEBUG_TESTS:-}"
}

oneTimeSetUp() {
	if debugMode; then
		k_log_level "${KOALEPHANT_LOG_LEVEL_DEBUG}" >/dev/null
	fi

	k_hash_op load
}

worker_k_hash_algos() {
	# shellcheck disable=SC2039
	local algos expected="$1"

	algos="$(k_hash_algos)"
	assertTrue "(hash module=${KOALEPHANT_HASH_MODULE}) Listing algos returns success" $?
	assertEquals "(hash module=${KOALEPHANT_HASH_MODULE}) Known hash algos are available" "${expected}" "${algos}"
}

test_k_hash_algos (){
	# shellcheck disable=SC2039
	local phpAlgos='' shasumAlgos='' algosumAlgos=''

	if command -v php > /dev/null && php -r 'exit(function_exists("hash_algos") ? 0 : 1);'; then
		phpAlgos="$(php -r 'echo implode(PHP_EOL, hash_algos());' | sort -u)"
	fi
	KOALEPHANT_HASH_MODULE=php worker_k_hash_algos "${phpAlgos}"

	if command -v shasum > /dev/null; then
		shasumAlgos="$(printf -- '%s\n' sha1 sha224 sha256 sha384 sha512 sha512224 sha512256 | sort -u)"
	fi
	KOALEPHANT_HASH_MODULE=shasum worker_k_hash_algos "${shasumAlgos}"

	if command -v sha1sum > /dev/null; then
		algosumAlgos="$(printf -- '%s\n' blake2 md5 sha1 sha224 sha256 sha384 sha512 | sort -u)"
	fi
	KOALEPHANT_HASH_MODULE=algosum worker_k_hash_algos "${algosumAlgos}"

	unset KOALEPHANT_HASH_MODULE
	worker_k_hash_algos "$(printf -- '%s\n' "${phpAlgos}" "${shasumAlgos}" "${algosumAlgos}" | sort -u | sed '/^$/d')"
}


test_k_hash_modules (){
	# shellcheck disable=SC2039
	local modules expected

	expected="$(printf '%s\n' php shasum algosum | sort)"
	modules="$(k_hash_modules)"
	assertTrue 'Listing hash modules returns success' $?
	assertEquals 'Known hash modules are loaded' "${expected}" "${modules}"
}

worker_k_hash_generate() {
	# shellcheck disable=SC2039
	local algo string hash generated tempFile
	KOALEPHANT_HASH_MODULE="$1"

	while IFS=';' read -r algo string hash; do
		if ! k_hash_op avail "${algo}" 2>/dev/null; then
			k_log_debug 'Skipping test of k_hash_generate using module "%s" and algo "%s", not available' "$KOALEPHANT_HASH_MODULE" "$algo"
			continue
		fi
		tempFile="$(mktemp)"
		generated="$(printf -- '%s' "${string}" | tee "${tempFile}" | k_hash_generate "${algo}" - 2>/dev/null)"
		assertTrue "(hash module=${KOALEPHANT_HASH_MODULE}) Generating ${algo} hash for string '${string}' returns success" $?
		assertEquals "(hash module=${KOALEPHANT_HASH_MODULE}) ${algo} Hash for '$string' generated correctly" "${hash}" "${generated}"

		generated="$(k_hash_generate "${algo}" "${tempFile}" 2>/dev/null)"
		assertTrue "(hash module=${KOALEPHANT_HASH_MODULE}) Generating ${algo} hash for contents of '${tempFile}' returns success" $?
		assertEquals "(hash module=${KOALEPHANT_HASH_MODULE}) ${algo} Hash for contents of '${tempFile}' generated correctly" "${hash}" "${generated}"
		rm -f "${tempFile}"

	done < ./hashes.txt
}

test_k_hash_generate (){
	worker_k_hash_generate ''
	if command -v php > /dev/null && php -r 'exit(function_exists("hash_algos") ? 0 : 1);'; then
		worker_k_hash_generate php
	fi

	if command -v shasum > /dev/null; then
		worker_k_hash_generate shasum
	fi

	if command -v sha1sum > /dev/null; then
		worker_k_hash_generate algosum
	fi
}

worker_k_hash_verify() {
	# shellcheck disable=SC2039
	local algo string hash generated tempFile
	KOALEPHANT_HASH_MODULE="$1"

	while IFS=';' read -r algo string hash; do
		if ! k_hash_op avail "${algo}" 2>/dev/null; then
			k_log_debug 'Skipping test of k_hash_verify using module "%s" and algo "%s", not available' "$KOALEPHANT_HASH_MODULE" "$algo"
			continue
		fi
		tempFile="$(mktemp)"
		printf -- '%s' "${string}" | tee "$tempFile" | k_hash_verify "${algo}" - "${hash}" 2>/dev/null
		assertTrue "(hash module=${KOALEPHANT_HASH_MODULE}) Verifying ${algo} hash for string '${string}' returns success" $?

		k_hash_verify "${algo}" "${tempFile}" "${hash}" 2>/dev/null
		assertTrue "(hash module=${KOALEPHANT_HASH_MODULE}) Verifying ${algo} hash for contents of '${tempFile}' returns success" $?
		rm -f "${tempFile}"
	done < ./hashes.txt
}

test_k_hash_verify (){
	worker_k_hash_verify ''
	if command -v php > /dev/null && php -r 'exit(function_exists("hash_algos") ? 0 : 1);'; then
		worker_k_hash_verify php
	fi

	if command -v shasum > /dev/null; then
		worker_k_hash_verify shasum
	fi

	if command -v sha1sum > /dev/null; then
		worker_k_hash_verify algosum
	fi
}

test_k_hash_op (){

	KOALEPHANT_HASH_MODULE='none'
	output="$(k_hash_op 'whoami' 2>&1 1>/dev/null)"
	assertFalse 'Return is error when no hash modules can run' $?
	assertEquals 'Output is error message when no hash modules can run' 'No hash module available' "${output}"

	if command -v php > /dev/null && php -r 'exit(function_exists("hash_algos") ? 0 : 1);'; then
		KOALEPHANT_HASH_MODULE=php
		output="$(k_hash_op 'whoami')"
		assertTrue 'Return is success when php hash module can run' $?
		assertEquals 'Output is php Version info' "$(php --version)" "${output}"
	fi

	if command -v shasum > /dev/null; then
		KOALEPHANT_HASH_MODULE=shasum
		output="$(k_hash_op 'whoami' '')"
		assertTrue 'Return is success when shasum hash module can run' $?
		assertEquals 'Output is shasum Version info' "$(shasum --version)" "${output}"
	fi

	if command -v sha1sum  > /dev/null; then
		KOALEPHANT_HASH_MODULE=algosum
		output="$(k_hash_op 'whoami' '')"
		assertTrue 'Return is success when algosum hash module can run' $?
		assertEquals 'Output is algosum Version info' "$(sha1sum --version)" "${output}"
	fi
}
