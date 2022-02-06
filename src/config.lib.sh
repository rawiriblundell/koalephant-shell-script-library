#@IgnoreInspection BashAddShebang
# Config file functionality (Koalephant Shell Script Library)
# Version: PACKAGE_VERSION
# Copyright: 2017, Koalephant Co., Ltd
# Author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>

# Path to cfget binary
readonly KOALEPHANT_CFGET_PATH="CFGET_BIN"

# List of loaded Config modules
KOALEPHANT_CONFIG_MODULES_LOADED=''

# Run a cfget command
#
# Input:
# $1 - the config file
# $2...n - extra arguments for cfget
#
# Output:
# The result from cfget
#
# Return:
# The cfget return code
#
# Deprecated
# As of v2.5.0, use (#k_config_op) instead
k_config_command() {
	# shellcheck disable=SC2039
	local file

	k_requires_args k_config_command "$#"
	file="$1"
	shift

	k_log_deprecated k_config_command 2.5.0 'k_config_op() or k_config_op_cfget()'

	"${KOALEPHANT_CFGET_PATH}" --plugin "${KOALEPHANT_LIB_PATH}/cfget-plugins/" --format nestedini --cfg "${file}" --quiet "$@"
}

# Perform a config file operation
#
# Input:
# $1 - the operation to perform, one of 'sections', 'keys', 'read', 'write', 'avail', 'whoami' or 'load'
# $2 - the config file
# $3...n - extra arguments for the operation
# $KOALEPHANT_CONFIG_MODULE an override to use a specific config moduleName
#
# Output:
# The result from the config moduleName
#
# Return:
# 0 unless attempting to read a non-existent key, then 1, or no config moduleName is usable, then 2.
k_config_op() {
	# shellcheck disable=SC2039
	local file moduleName moduleOp

	fix_module_name() {
		printf -- '%s' "$1" | sed -e 's/-/_/g'
	}

	if [ -z "${KOALEPHANT_CONFIG_MODULES_LOADED}" ]; then
		for file in "${KOALEPHANT_LIB_PATH}/config-modules/"*.lib.sh; do
			if [ -f "${file}" ]; then
				KOALEPHANT_CONFIG_MODULES_LOADED="${KOALEPHANT_CONFIG_MODULES_LOADED}$(fix_module_name "$(k_fs_basename "${file}" .lib.sh)") "
				# shellcheck disable=SC1090
				. "${file}" #K_SCRIPT_BUILD_IGNORE_ALWAYS
			fi
		done
		readonly KOALEPHANT_CONFIG_MODULES
	fi

	override_module() {
		[ -z "${KOALEPHANT_CONFIG_MODULE:-}" ] || [ "$(fix_module_name "${KOALEPHANT_CONFIG_MODULE}")" = "${1}" ]
	}

	if [ "${1}" = 'load' ]; then
		return 0
	fi

	for moduleName in ${KOALEPHANT_CONFIG_MODULES_LOADED}; do
		moduleOp="k_config_op_${moduleName}"
		if command -v "${moduleOp}" > /dev/null && "${moduleOp}" avail "$@" && override_module "${moduleName}"; then
			"${moduleOp}" "$@"
			return "$?"
		fi
	done

	k_log_err 'No config module available'
	return 2
}

# Print a list of loaded config modules
#
# Output:
# The moduleName names
k_config_modules() {
	k_config_op load
	# shellcheck disable=SC2086
	printf -- '%s\n' ${KOALEPHANT_CONFIG_MODULES_LOADED}
}


# Get config sections
#
# Input:
# $1 - the config file
# $2 - the config root to work from, defaults to empty
#
# Output:
# the section names, one per line
k_config_sections() {
	k_requires_args k_config_sections "$#"

	k_config_op sections "$@"
}

# Get config keys
#
# Input:
# $1 - the config file
# $2 - the config root to work from
#
# Output:
# the key names, one per line
k_config_keys() {
	k_requires_args k_config_keys "$#"

	k_config_op keys "$@"
}

# Read a Config Value
# Unlike (#k_config_read_error), this function will not error if the config key is not found
#
# Input:
# $1 - the config file
# $2 - the key to read
# $3 - the config root to work from
#
# Output:
# the value of the key, if it exists
k_config_read() {
	k_config_read_error "$@" || true
}

# Read a Config Value, or error
#
# Input:
# $1 - the config file
# $2 - the key to read
# $3 - the config root to work from
#
# Output:
# the value of the key, if it exists
#
# Return:
# 0 on success, 1 on error
k_config_read_error() {
	k_requires_args k_config_read_error "$#" 2

	k_config_op read "$@"
}

# Get a Config value or a default value
#
# Input:
# $1 - the config file
# $2 - the key to read
# $3 - the default value (defaults to empty string)
# $4 - the config root to work from
#
# Output:
# the value of the key, or the default value
k_config_read_string() {
	# shellcheck disable=SC2039
	local file key root default value

	k_requires_args k_config_read_string "$#" 2

	file="$1"
	key="$2"
	default="${3:-}"
	root="${4:-}"
	value="$(k_config_read "$file" "$key" "${root}")"

	printf -- '%s\n' "${value:-${default}}"
}

# Get a 'Boolean' Config value or a default value
#
# Input:
# $1 - the config file
# $2 - the key to read
# $3 - the default value (defaults to empty string)
# $4 - the config root to work from
#
# Output:
# `true`, `false` or the default value given if the config value cannot be parsed using (bool.lib#k_bool_parse)
k_config_read_bool() {
	# shellcheck disable=SC2039
	local file key root default

	k_requires_args k_config_read_bool "$#" 2

	file="$1"
	key="$2"
	default="${3:-}"
	root="${4:-}"

	k_bool_parse "$(k_config_read "${file}" "${key}" "${root}")" "${default}"
}

# Test a 'Boolean' Config value or a default value
#
# Input:
# $1 - the config file
# $2 - the key to read
# $3 - the default value (defaults to empty string)
# $4 - the config root to work from
#
# Return:
# 0 if either the config value or the default value is true, 1 otherwise
k_config_test_bool() {
	# shellcheck disable=SC2039
	local file key root default

	k_requires_args k_config_test_bool "$#" 2

	file="$1"
	key="$2"
	default="${3:-}"
	root="${4:-}"

	k_bool_test "$(k_config_read_string "${file}" "${key}" "$(k_bool_parse "${default}")" "${root}")"
}

# Get a 'keyword' Config value or a default value
#
# Input:
# $1 - the config file
# $2 - the key to read
# $3 - the default value
# $4 - the config root to work from
# $5...n - the list of valid keyword values
#
# Output:
# the valid keyword or default value
k_config_read_keyword() {
	# shellcheck disable=SC2039
	local file key root default

	k_requires_args k_config_read_keyword "$#" 2

	file="$1"
	key="$2"
	default="${3:-}"
	root="${4:-}"

	shift 4

	k_string_keyword "$(k_config_read_string "${file}" "${key}" "${default}" "${root}")" "$@" "$default"
}

# Write a Config Value, or error
#
# Input:
# $1 - the config file
# $2 - the key to write to
# $3 - the value to write
# $4 - the config root to work from
#
# Return:
# 0 on success, 1 on error
k_config_write_error() {
	k_requires_args k_config_write_error "$#" 3
	k_config_op write "$@"
}


# Check that a readable file has been provided
#
# Input:
# $1 - the file pathname to try to read
#
# Return:
# 0 if the file pathname is readable, 1 if not
k_config_file_check_readable() {
	# shellcheck disable=SC2039
	local file="${1:-}"

	if [ -z "${file}" ]; then
		k_log_err 'No config file specified for reading'
		return 1
	fi

	if [ ! -r "${file}" ]; then
		k_log_err 'Cannot open config file "%s" for reading' "${file}"
		return 1
	fi
}

# Check that a writable file has been provided
#
# Input:
# $1 - the file pathname to try to read
#
# Output:
# the file pathname, if readable.
#
# Return:
# 0 if the file pathname is readable, 1 if not
k_config_file_check_writable() {
	# shellcheck disable=SC2039
	local file="${1:-}"

	if [ -z "${file}" ]; then
		k_log_err 'No config file specified for writing'
		return 1
	fi

	if [ ! -f "${file}" ]; then
		touch "${file}" 2>/dev/null || true
	fi

	if [ ! -r "${file}" ] || [ ! -w "${file}" ]; then
		k_log_err 'Cannot open config file "%s" for writing' "${file}"
		return 1
	fi
}





