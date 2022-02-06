#!/bin/sh -eu

. ../base.lib.sh
. ../gpg.lib.sh
. ../string.lib.sh
. ../fs.lib.sh
. ../number.lib.sh
. ../bool.lib.sh

debugMode() {
	k_bool_test "${DEBUG_TESTS:-}"
}

oneTimeSetUp() {
	if debugMode; then
		k_log_level "${KOALEPHANT_LOG_LEVEL_DEBUG}" >/dev/null
	fi
}

setUp () {
	# shellcheck disable=SC2039
	local gpgHome
	gpgHome="/tmp/gpghome-$(random_helper)"
	mkdir -m 0700 "${gpgHome}"
	cp ./gpg.conf "${gpgHome}"
	export GNUPGHOME="${gpgHome}"
	if debugMode; then
		printf 'Using GPG Home Dir: "%s"\n' "${gpgHome}" >&2
	fi
}

run_gpg() {
	command "${KOALEPHANT_GPG_PATH}" "$@"
}

random_helper() {
	# shellcheck disable=SC2039
	local count="5"
	LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | dd ibs=1 count="${count}" 2>/dev/null
}

tearDown() {
	if ! debugMode; then
		rm -rf "${GNUPGHOME}"
	fi
	unset GNUPGHOME
}

test_k_gpg_create (){
	# shellcheck disable=SC2039
	local name="test-key" email="test-email@example.com" id

	id="$(k_gpg_create "${name}" "${email}" "Some key you got there")"

	assertEquals "found key by id matches created" "${id}" "$(k_gpg_list_keys_public "${id}")"
	assertEquals "found key by name matches created" "${id}" "$(k_gpg_list_keys_public "${name}")"
	assertEquals "found key by email" "${id}" "$(k_gpg_list_keys_public "${email}")"
}

test_k_gpg_export (){
	# shellcheck disable=SC2039
	local id tmpDir found filetype

	id="$(k_gpg_create "Example" "example@example.com" "Some key you got there")"

	tmpDir="$(k_fs_temp_dir)"

	k_gpg_export "${id}" "${tmpDir}/foo.gpg"
	assertTrue "Export returns success" $?

	[ -f "${tmpDir}/foo.gpg" ]
	assertTrue "Exported file exists" $?

	filetype="$(file -b "${tmpDir}/foo.gpg" | cut -d , -f 1)"
	assertEquals "Exported file looks like GPG" '' "${filetype##*GPG key public ring*}"

	found="$(run_gpg --no-default-keyring --keyring "${tmpDir}/foo.gpg" --batch --no-tty --with-colons --list-public-keys 2>/dev/null | grep "^pub:" | cut -d ":" -f 5)"
	assertEquals "Exported keyring contains generated key" "${id}" "${found}"

	k_gpg_export "${id}" "${tmpDir}/"
	assertTrue "Export returns success" $?

	[ -f "${tmpDir}/${id}.gpg" ]
	assertTrue "Exported file exists" $?

	filetype="$(file -b "${tmpDir}/${id}.gpg" | cut -d , -f 1)"
	assertEquals "Exported file looks like GPG" '' "${filetype##*GPG key public ring*}"

	found="$(run_gpg --no-default-keyring --keyring "${tmpDir}/${id}.gpg" --batch --no-tty --with-colons --list-public-keys 2>/dev/null | grep "^pub:" | cut -d ":" -f 5)"
	assertEquals "Exported keyring contains generated key" "${id}" "${found}"
}



test_k_gpg_export_armored (){
	# shellcheck disable=SC2039
	local id tmpDir found

	id="$(k_gpg_create "Example" "example@example.com" "Some key you got there")"

	tmpDir="$(k_fs_temp_dir)"

	k_gpg_export_armored "${id}" "${tmpDir}/foo.asc"
	assertTrue "Export returns success" $?

	[ -f "${tmpDir}/foo.asc" ]
	assertTrue "Exported file exists" $?

	assertEquals "Exported file looks like GPG block" 'PGP public key block Public-Key (old)' "$(file -b "${tmpDir}/foo.asc" | cut -d , -f 1)"

	foundKey="$(run_gpg --no-default-keyring  --batch --no-tty --list-packets "${tmpDir}/foo.asc" | sed -n 's/^[[:space:]]*keyid: //p')"
	assertEquals "Exported file has same Key ID" "${id}" "${foundKey}"
}



test_k_gpg_keyid_valid (){
	k_gpg_keyid_valid 81647E48
	assertTrue "valid key ID (short)" $?

	k_gpg_keyid_valid 0x81647E48
	assertTrue "valid key ID (short, 0x prefix)" $?

	k_gpg_keyid_valid B0ADB128B5340C03
	assertTrue "valid key ID (long)" $?

	k_gpg_keyid_valid 0xB0ADB128B5340C03
	assertTrue "valid key ID (long, 0x prefix)" $?

	k_gpg_keyid_valid ""
	assertFalse "invalid key ID (empty string)"

	k_gpg_keyid_valid "DEEE E19F 8C95 75DC E594  C892 1832 8A7E 8164 7E48"
	assertFalse "invalid key ID (fingerprint)"

	k_gpg_keyid_valid "example@foo.com"
	assertFalse "invalid key ID (email)"
}


test_k_gpg_list_keys_public () {
	# shellcheck disable=SC2039
	local generated known='18328A7E81647E48' found

	generated="$(k_gpg_create "Some person" "someone@example.com" "Some key you got there")"
	k_gpg_receive_keys "${known}" > /dev/null

	found="$(k_gpg_list_keys_public)"
	assertEquals "Found Public keys are what's created/received" "$(printf '%s\n' "${generated}" "${known}")" "${found}"
}

test_k_gpg_list_keys_secret (){
	# shellcheck disable=SC2039
	local generated known='18328A7E81647E48' found

	generated="$(k_gpg_create "Some person" "someone@example.com" "Some key you got there")"
	k_gpg_receive_keys "${known}" > /dev/null

	found="$(k_gpg_list_keys_secret)"
	assertEquals "Found Secret keys are what's created" "${generated}" "${found}"
}


test_k_gpg_password_prompt (){
	# shellcheck disable=SC2039
	local id response

	id="$(k_gpg_create "Some name" "some@example.com" "Some key you got there")"

	if [ -t 0 ]; then
		k_gpg_password_prompt "${id}"
		printf -- 'Did GPG prompt appear? y/n: '
		read -r response
		response="$(k_string_lower "${response}")"
	else
		startSkipping
	fi

	assertEquals "GPG prompt was shown" "y" "${response}"
}


test_k_gpg_receive_keys (){
	# shellcheck disable=SC2039
	local output

	output="$(k_gpg_receive_keys 18328A7E81647E48)"
	assertEquals "GPG Key Received" 'key 18328A7E81647E48: public key "Koalephant Packaging Team <packages@koalephant.com>" imported' "${output}"
}

test_k_gpg_search_keys (){

	result="$(k_gpg_search_keys "packages@koalephant.com")"
	expected="$(cat <<EOT
info:1:1
pub:DEEEE19F8C9575DCE594C89218328A7E81647E48:1:4096:1517249727:1643480127:
uid:Koalephant Packaging Team <packages@koalephant.com>:1517249727::
EOT
)"
	assertEquals "Found correct record" "${expected}" "${result}"
}

