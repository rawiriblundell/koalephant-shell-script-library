#@IgnoreInspection BashAddShebang
# Environment handling functionality (Koalephant Shell Script Library)
# Version: PACKAGE_VERSION
# Copyright: 2014, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Prefix to use when setting environment variables
KOALEPHANT_ENVIRONMENT_PREFIX=""

# Make sure a name is safe for use as a variable name
#
# Input:
# $1 - the name to make safe
#
# Output:
# The save variable name
k_env_safename() {
	k_requires_args k_env_safename "$#"
	printf -- '%s\n' "${KOALEPHANT_ENVIRONMENT_PREFIX}${1}"  | LC_CTYPE='C' tr -cd A-Za-z0-9_
}

# Set a local variable
# Useful to set a variable using a generated name, i.e. variable variables.
#
# Input:
# $1 - the name of the variable to set
# $2 - the value to set
k_env_set() {
	# shellcheck disable=SC2039
	local name value

	k_requires_args k_env_set "$#" 2

	name=$(k_env_safename "${1}")
	value="$(printf -- '%s' "$2" | sed -E -e 's/"/\\x22/g; s/`/\\x60/g')"

	k_log_debug 'Setting "%s" environment variable to "%s"' "${name}" "${value}"

	# shellcheck disable=2086
	eval "${name}=\"${value}\""
}

# Unset one or more environment variables
#
# Input:
# $1...n variables to unset from the environment
k_env_unset() {
	# shellcheck disable=SC2039
	local name

	k_requires_args k_env_unset "$#"

	for name in "$@"; do
		k_log_debug 'Unsetting "%s" environment variable' "${name}"
		eval unset -v "$(k_env_safename "${name}")"
	done
}

# Export one or more environment variables
#
# Input:
# $1...n variables to export for child processes
k_env_export() {
	# shellcheck disable=SC2039
	local name

	k_requires_args k_env_export "$#"

	for name in "$@"; do
		eval export "$(k_env_safename "${name}")"
	done
}

# Un-Export one or more environment variables
#
# Input:
# $1...n - variables to un-export
k_env_unexport() {
	k_env_unset "$@"
}

# Import environment variables from the GECOS field
#
# Input:
# $1 the user to import from. Defaults to the current logged in user.
k_env_import_gecos() {
	# shellcheck disable=SC2039
	local userName gecos i=1 name value

	k_log_debug 'Importing Environment Variables from GECOS field'

	# If no argument is provided, use $USER
	userName="${1:-${USER}}"


	gecos="$(getent passwd "${userName}" | cut -d ":" -f 5)"

	for name in NAME ROOM TELEPHONE_WORK TELEPHONE_HOME EMAIL; do
		k_env_set "${name}" "$(printf -- '%s\n' "${gecos}" | cut -d "," -f "${i}")"

		if ! k_string_contains "${name}" "${KOALEPHANT_ENV_NS_GECOS}"; then
			KOALEPHANT_ENV_NS_GECOS="${KOALEPHANT_ENV_NS_GECOS} ${name}"
		fi

		i=$(( i + 1 ))
	done

	export KOALEPHANT_ENV_NS_GECOS
}

# Export environment variables previously imported with (#k_env_import_gecos)
k_env_export_gecos() {
	# shellcheck disable=SC2086
	k_env_export ${KOALEPHANT_ENV_NS_GECOS}
}

# Unset environment variables previously imported with {k_env_import_gecos}
k_env_unset_gecos() {
	# shellcheck disable=SC2086
	k_env_unset ${KOALEPHANT_ENV_NS_GECOS} KOALEPHANT_ENV_NS_GECOS
}


# Import environment variables from an apache config file
#
# Input:
# $1 - the apache config file to set environment variables from
k_env_import_apache() {
	# shellcheck disable=SC2039
	local name value file tmpFile

	k_requires_args k_env_import_apache "$#"
	file="${1}"

	if [ ! -r "${file}" ]; then
		k_log_err 'Invalid file supplied: %s' "${file}"
		return 1
	fi

	k_log_debug 'Importing Environment Variables from Apache Config: "%s"' "${file}"

	tmpFile="$(k_fs_predictable_file k_env_import_apache)"

	sed -n -E -e 's#^[[:space:]]*SetEnv[[:space:]](.*)[[:space:]]"?([^"]+)"?#\1 \2#gp' "${file}" > "${tmpFile}"

	while IFS=' ' read -r name value; do
		k_env_set "${name}" "${value}"

		if ! k_string_contains "${name}" "${KOALEPHANT_ENV_NS_APACHE}"; then
			KOALEPHANT_ENV_NS_APACHE="${KOALEPHANT_ENV_NS_APACHE} ${name}"
		fi
	done < "${tmpFile}"

	export KOALEPHANT_ENV_NS_APACHE
}

# Export environment variables previously imported with (#k_env_import_apache)
k_env_export_apache() {
	# shellcheck disable=SC2086
	k_env_export ${KOALEPHANT_ENV_NS_APACHE}
}

# Unset environment variables previously imported with @link k_env_import_apache @/link
k_env_unset_apache() {
	# shellcheck disable=SC2086
	k_env_unset ${KOALEPHANT_ENV_NS_APACHE} KOALEPHANT_ENV_NS_APACHE
}

# Un-Export environment variables previously exported with @link k_env_import_apache @/link
k_env_unexport_apache() {
	# shellcheck disable=SC2086
	k_env_unexport ${KOALEPHANT_ENV_NS_APACHE} KOALEPHANT_ENV_NS_APACHE
}

# Import environment variables from an LDAP object as environment variables
#
# Input:
# $1 - filter the mode to operate in, set or unset
# $2...n - the attributes to fetch
k_env_import_ldap() {
	# shellcheck disable=SC2039
	local filter i name longName value tmpFile

	filter="${1}"
	shift

	if [ -z "${filter}" ]; then
		k_log_err "No filter supplied"
		return 1
	fi

	k_log_debug 'Importing Environment Variables from LDAP with Filter: "%s"' "${filter}"

	# attribute renaming maps:
	if [ -d "${KOALEPHANT_LIB_PATH}/ldap-attr-maps" ]; then
		for i in "${KOALEPHANT_LIB_PATH}/ldap-attr-maps/"*.attrs; do
			if [ -r "${i}" ]; then
				# shellcheck disable=SC1090
				. "${i}" #K_SCRIPT_BUILD_IGNORE_ALWAYS
			fi
		done
	fi

	tmpFile="$(k_fs_predictable_file k_env_import_ldap)"

	ldapsearch -x -LLL -o ldif-wrap='no' "(${filter})" "$@" > "${tmpFile}"

	split_camelcase() {
		printf -- '%s' "$1" | sed -E -e 's#([A-Z][^A-Z])#_\1#g'
	}

	while IFS=: read -r name value; do
		if [ -z "${name}" ]; then
			break
		fi

		longName="$(eval printf -- '%s' "\${ATTR_${name}:-}")"
		if [ -n "${longName}" ]; then
			name="${longName}"
		fi

		name="$(k_string_upper "$(split_camelcase "${name}")")"


		k_env_set "${name}" "$(k_string_trim "${value}")"

		if ! k_string_contains "${name}" "${KOALEPHANT_ENV_NS_LDAP}"; then
			KOALEPHANT_ENV_NS_LDAP="${KOALEPHANT_ENV_NS_LDAP} ${name}"
		fi
	done < "${tmpFile}"

	export KOALEPHANT_ENV_NS_LDAP
}

# Export environment variables previously imported with @link k_env_import_ldap @/link
k_env_export_ldap() {
	# shellcheck disable=SC2086
	k_env_export ${KOALEPHANT_ENV_NS_LDAP}
}

# Unset environment variables previously imported with @link k_env_import_ldap @/link
k_env_unset_ldap() {
	# shellcheck disable=SC2086
	k_env_unset ${KOALEPHANT_ENV_NS_LDAP} KOALEPHANT_ENV_NS_LDAP
}
