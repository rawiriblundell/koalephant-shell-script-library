#@IgnoreInspection BashAddShebang
# GPG functionality (Koalephant Shell Script Library)
# Version: PACKAGE_VERSION
# Copyright: 2014, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Path to gpg binary
readonly KOALEPHANT_GPG_PATH="GPG_BIN"

# List GPG Public Key ID's
#
# Input:
# $1...n - query key id/name/email to query for, if set
#
# Output:
# the public key ID, if one or more keys are found
k_gpg_list_keys_public() {
	"${KOALEPHANT_GPG_PATH}" --batch --no-tty --with-colons --list-public-keys -- "$@" 2>/dev/null | grep "^pub:" | cut -d ":" -f 5
}

# List GPG Secret Key ID's
#
# Input:
# $1...n - query key id/name/email to query for, if set
#
# Output:
# the secret key ID, if one or more keys are found
k_gpg_list_keys_secret() {
	"${KOALEPHANT_GPG_PATH}" --batch --no-tty --with-colons --list-secret-keys -- "$@" 2>/dev/null | grep "^sec:" | cut -d ":" -f 5
}

# Generate a new GPG Key
#
# Input:
# $1 - the name for the key
# $2 - the email for the key
# $3 - optional comment for the key
# $4 - optional passphrase for the key. If not supplied, the key will not be protected with a passphrase!
#
# Output:
# the new Key ID
#
# Return:
# the exit code from gpg, usually 0 for success and 1 for error
k_gpg_create() {
	# shellcheck disable=SC2039
	local name email comment passphraseLine gpgOut

	k_requires_args k_gpg_create $# 2


	name="${1}"
	email="${2}"
	comment="${3:-}"
	commentLine=""
	passphrase="${4:-}"
	passphraseLine=""

	if [ -n "${comment}" ]; then
		commentLine="Name-Comment: ${comment}"
	fi

	if [ -n "${passphrase}" ]; then
		passphraseLine="Passphrase: ${passphrase}"
	else
		passphraseLine="%no-protection"
	fi

	if gpgOut="$("${KOALEPHANT_GPG_PATH}" --no-tty --batch --generate-key 2>&1 <<-EOT
		Key-Type: RSA
		Key-Length: 2048
		Name-Real: ${name}
		${commentLine}
		Name-Email: ${email}
		${passphraseLine}
		Expire-Date: 0
		%commit
EOT
)"; then
		printf -- '%s\n' "${gpgOut}" | sed -n '/^gpg: key /p' | cut -d " " -f 3
	fi
}

# Prompt for a new GPG Key Passphrase
#
# Input:
# $1 - the ID of the Key to set a passphrase for
#
# Return:
# the exit code from gpg, usually 0 for success and 1 for error
k_gpg_password_prompt() {
	# shellcheck disable=SC2039
	local gpgKey

	k_requires_args k_gpg_create $#

	gpgKey="${1}"

	"${KOALEPHANT_GPG_PATH}" --no-tty --batch --edit-key -- "${gpgKey}" passwd save 2>/dev/null
}

# Export an ascii-armored GPG Key
#
# Input
# $1 - the ID of the Key to export
# $2 - the destination to export the key to. If a directory is given, a file named with the Key ID and a ".asc" extension will be created in the directory
#
# Return:
# the exit code from gpg, usually 0 for success and 1 for error
k_gpg_export_armored() {
	# shellcheck disable=SC2039
	local key destination

	k_requires_args k_gpg_export_armored $# 2

	key="${1}"
	destination="${2}"

	if [ -d "${destination}" ]; then
		destination="${destination}/${key}.asc"
	fi

	"${KOALEPHANT_GPG_PATH}" --no-tty --armor --export -- "${key}" > "${destination}"
}

# Export a binary GPG key
#
# Input
# $1 - the ID of the Key to export
# $2 - the destination to export the key to. If a directory is given, a file named with the Key ID and a ".gpg" extension will be created in the directory
#
# Return:
# the exit code from gpg, usually 0 for success and 1 for error
k_gpg_export() {
	# shellcheck disable=SC2039
	local key destination

	k_requires_args k_gpg_export $# 2

	key="${1}"
	destination="${2}"

	if [ -d "${destination}" ]; then
		destination="${destination}/${key}.gpg"
	fi

	"${KOALEPHANT_GPG_PATH}" --batch --no-tty --export -- "${key}" > "${destination}"
}

# Search for public keys on the configured keyserver(s)
#
# Input:
# $1 - the query term - usually a key ID, email or name.
#
# Output:
# The
k_gpg_search_keys() {
	# shellcheck disable=SC2039
	local query

	k_requires_args k_gpg_search_keys $#

	query="$1"

	"${KOALEPHANT_GPG_PATH}" --no-tty --with-colons --batch --search-keys -- "${query}" 2>/dev/null
}

# Add a public key from the configured keyserver(s)
#
# Input:
# $1...n - the key IDs to add
#
# Output:
# The GPG message
k_gpg_receive_keys() {
	k_requires_args k_gpg_receive_keys $#

	"${KOALEPHANT_GPG_PATH}" --no-tty --batch --receive-keys -- "$@" 2>&1 | sed -n '/^gpg: key /p' | cut -c 6-
}

# Check if a variable is in a valid key-id format
#
# Input:
# $1 - the variable to check
#
# Return:
# 0 if valid, 1 if not
k_gpg_keyid_valid() {
	# shellcheck disable=SC2039
	local keyId

	k_requires_args k_gpg_keyid_valid $#

	keyId="$1"

	if k_string_starts_with "0x" "${keyId}" && { [ ${#keyId} -eq 10 ] || [ ${#keyId} -eq 18 ]; }; then
		keyId="$(k_string_remove_start "0x" "${keyId}")"
	fi

	{ [ ${#keyId} -eq 8 ] || [ ${#keyId} -eq 16 ]; } && [ "${keyId}" = "$(printf -- '%s\n' "${keyId}" | LC_CTYPE='C' tr -c -d 'ABCDEFabcdef0123456789')" ]
}
