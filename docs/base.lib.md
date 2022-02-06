---
title: base.lib.sh
version: 2.8.1
copyright: 2014, Koalephant Co., Ltd
author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
description: Base app functionality (Koalephant Shell Script Library)
---

### `$KOALEPHANT_LIB_NAME`
`readonly` Base Shell Library name

### `$KOALEPHANT_LIB_OWNER`
`readonly` Base Shell library owner

### `$KOALEPHANT_LIB_VERSION`
`readonly` Base Shell Library version

### `$KOALEPHANT_LIB_YEAR`
`readonly` Base Shell Library year

### `$KOALEPHANT_LIB_PATH`
`readonly` Base directory for the installed Library

### `k_tool_name`
Get the tool name

#### Input:
 * `$KOALEPHANT_TOOL_NAME` - explicit name used as-is if set
 * `$0` - the script name is stripped of directory components and any '.sh' suffix

#### Output:
the tool name

### `k_tool_version`
Get the tool version

#### Input:
 * `$KOALEPHANT_TOOL_VERSION` - explicit version used as-is if set. Default is 1.0.0 if not set

#### Output:
the tool version

### `k_tool_year`
Get the tool copyright years

#### Input:
 * `$KOALEPHANT_TOOL_YEAR` - explicit copyright year(s) used as-is if set. Default is current year if not set

#### Output:
the tool copyright year(s)

### `k_tool_owner`
Get the tool copyright owner

#### Input:
 * `$KOALEPHANT_TOOL_OWNER` - explicit copyright owner used as-is if set. Default is 'Koalephant Co., Ltd' if not set

#### Output:
the tool copyright owner

### `k_tool_description`
Get the tool description

#### Input:
 * `$KOALEPHANT_TOOL_DESCRIPTION` - tool description used as-is

#### Output:
the tool description

### `k_tool_description_add`
Add a block of descriptive text, wrapped and optionally indented for help output.
Helps ensure proper formatting when using `k-help2man` to build `man` pages from help output

#### Input:
 * `$1` - indent level. If not specified, no indent is applied
 * `$2` - string to pad and use for prefixing wrapped lines. e.g. `# ` for comment lines
 * `$3...n` - text to output. Args are joined by newline character. If `$3` is `-` or arg count is < 3, reads from STDIN.

### `k_tool_description_code_add`
Add a block of usage/code, wrapped and optionally indented for help output.
Helps ensure proper formatting when using `k-help2man` to build `man` pages from help output

#### Input:
 * `$1` - indent level. If not specified, no indent is applied
 * `$2` - string to pad and use for prefixing wrapped lines. e.g. `# ` for comment lines
 * `$3...n` - text to output. Args are joined by newline character. If `$3` is `-` or arg count is < 3, reads from STDIN.

### `k_tool_options`
Get the tool options descriptions

#### Input:
 * `$KOALEPHANT_TOOL_OPTIONS` - tool options descriptions used as-is

#### Output:
the tool options descriptions

### `k_tool_has_options`
Check if the tool accepts options

#### Input:
 * `$KOALEPHANT_TOOL_OPTIONS` - checks if any pre-formatted options are set.
 * `$KOALEPHANT_TOOL_OPTIONS_OPTS` - checks if any options have been set via k_tool_options_add

#### Return:
0 if the tool has options, 1 otherwise

### `k_tool_options_add`
Add an options entry to be auto-formatted for help output

#### Input:
 * `$1` - Option long name. If non-empty, will be prepended with '--'
 * `$2` - Option short name. If non-empty, will be prepended with '-'
 * `$3` - Option argument. Convention is to surround the name with square brackets if optional.
 * `$4...n` - Option description. Multiple inputs will be joined by newlines. Multiple lines will be automatically indented.

#### Return:
0 when all inputs are ok, 1 otherwise

### `k_tool_options_alias`
Add an options alias entry to be auto formatted for help output
Input
$1 - Option long name. If non-empty, will be prepended with '--'
$2 - Option short name. If non-empty, will be prepended with '-'
$3 - Original name (the option this is an alias of). Will be used as-is in the descriptive text.
0 when all inputs are ok, 1 otherwise

### `k_tool_options_print`
Display the entries added with k_tool_options_add and k_tool_options_alias

#### Output:
The rendered help options

### `k_tool_options_text `
Display a block of help text, wrapped and optionally indented.

#### Deprecated:
As of 2.8.0, use k_tool_description_add() or k_tool_usage_text() instead

### `k_tool_options_code `
Display a block of usage/code, wrapped and optionally indented.

#### Deprecated:
As of 2.8.0, use k_tool_description_code_add() or k_tool_usage_code() instead

### `k_tool_options_arguments`
Get the tool option(s) argument(s)
Shows output if [`k_tool_options`](#k_tool_options) returns non-empty content

#### Input:
 * `$KOALEPHANT_TOOL_OPTIONS_ARGUMENTS` - explicit tool option(s) argument(s) used as-is. Default is '[options]' if not set

#### Output:
the tool option(s) argument(s)

### `k_tool_arguments`
Get the tool arguments

#### Input:
 * `$KOALEPHANT_TOOL_ARGUMENTS` - tool arguments used as-is

#### Output:
the tool arguments

### `k_tool_environment`
Get the tool environment variables

#### Input:
 * `$KOALEPHANT_TOOL_ENVIRONMENT` - tool environment used as-is
 * `Output` - Output
 * `the tool environment variables` - the tool environment variables

### `k_tool_environment_add`
Add an environment entry to be auto-formatted for help output

#### Input:
 * `$1` - Environment variable name
 * `$2...n` - Environment variable description. Multiple inputs will be joined by newlines. Multiple lines will be automatically indented.

#### Return:
0 when all inputs are ok, 1 otherwise

### `k_tool_environment_alias`
Add an environment alias entry to be auto formatted for help output
Input
$1 - Environment variable name.
$2 - Original name (the environment variable this is an alias of). Will be used as-is in the descriptive text.
0 when all inputs are ok, 1 otherwise

### `k_tool_environment_print`
Display the entries added with k_tool_environment_add and k_tool_environment_alias

#### Output:
The rendered help options

### `k_tool_usage`
Get the tool usage
uses [`k_tool_name`](#k_tool_name), [`k_tool_options_arguments`](#k_tool_options_arguments) and [`k_tool_arguments`](#k_tool_arguments)

#### Output:
the tool usage

### `k_tool_usage_text`
Display a block of help text, wrapped and optionally indented.
Helps ensure proper formatting when using `k-help2man` to build `man` pages from help output
Consider using [`k_tool_description_add`](#k_tool_description_add) (which uses this function internally) for defining help output instead.

#### Input:
 * `$1` - indent level. If not specified, no indent is applied
 * `$2` - string to pad and use for prefixing wrapped lines. e.g. `# ` for comment lines
 * `$3...n` - text to output. Args are joined by newline character. If `$3` is `-` or arg count is < 3, reads from STDIN.

#### Output:
the formatted help text

### `k_tool_usage_code`
Display a block of usage/code, wrapped and optionally indented.
Helps ensure proper formatting when using `k-help2man` to build `man` pages from help output
Consider using [`k_tool_description_code_add`](#k_tool_description_code_add) (which uses this function internally) for defining help output instead.

#### Input:
 * `$1` - indent level. If not specified, no indent is applied
 * `$2` - string to pad and use for prefixing wrapped lines. e.g. `# ` for comment lines
 * `$3...n` - text to output. Args are joined by newline character. If `$3` is `-` or arg count is < 3, reads from STDIN.

#### Output:
the formatted help text

### `k_version`
Show the current tool version
uses [`k_tool_name`](#k_tool_name), [`k_tool_version`](#k_tool_version) [`k_tool_year`](#k_tool_year) and [`k_tool_owner`](#k_tool_owner)

#### Output:
the version information

### `k_library_version `
Show the current library version

#### Input:
 * `$KOALEPHANT_LIB_NAME` - $KOALEPHANT_LIB_NAME
 * `$KOALEPHANT_LIB_VERSION` - $KOALEPHANT_LIB_VERSION
 * `$KOALEPHANT_LIB_YEAR` - $KOALEPHANT_LIB_YEAR
 * `$KOALEPHANT_LIB_OWNER` - $KOALEPHANT_LIB_OWNER

#### Output:
the version information

### `k_version_helper `
Show either the full or minimal tool version
uses [`k_tool_version`](#k_tool_version) and [`k_version`](#k_version)

#### Input:
 * `$0` - flag indicating whether version info should be shown.
 * `$1` - flag indicating whether just the version number should be shown
 * `$2` - flag indicating whether the Library info/version should be shown as well

#### Output:
the version information/number

#### Return:
0 if version info is shown, 1 otherwise

### `k_usage`
Show the Usage info for this script
uses [`k_tool_usage`](#k_tool_usage), [`k_tool_description`](#k_tool_description) and [`k_tool_options`](#k_tool_options) and [`k_tool_environment`](#k_tool_environment)

#### Output:
the usage information

### `k_require_root`
Check if the running (effective) user is root, and error if not

#### Input:
 * `$1` - an extra error message to show if the current user is not root

#### Output:
Any additional message provided in `$1` plus a standard error message, if run by a non-root user.

#### Return:
0 when effective user is root, 1 otherwise

### `k_requires_args`
Check that the function has n arguments specified

#### Input:
 * `$1` - the name of the function
 * `$2` - the number of arguments provided
 * `$3` - the number of arguments required. Defaults to 1 if not specified

#### Output:
Error message written to stderr when applicable

#### Return:
0 when required number of args passed, 1 otherwise

### `k_option_requires_arg`
Check that an option has an argument specified.

#### Input:
 * `$1` - the option name
 * `$2` - the next argument the tool was invoked with

#### Output:
the argument value if valid

#### Return:
0 on success, 1 otherwise

#### Deprecated:
As of v2.5.0, use [`k_options_split`](#k_options_split) and [`k_options_arg_required`](#k_options_arg_required) instead

### `k_option_optional_arg`
Check whether an option has an optional argument specified.

#### Input:
 * `$1` - the option name
 * `$2` - the next argument the tool was invoked with

#### Output:
the argument value if specified

#### Deprecated:
As of v2.5.0, use [`k_options_split`](#k_options_split) and [`k_options_arg_optional`](#k_options_arg_optional) instead

### `k_options_split`
Read options passed and split option/value pairs.
Sets four variables to be used within the context of a `while` loop:
$OPTION_NAME - the name of the current option
$OPTION_VALUE - the (potentially) value of the current option
$OPTION_VALUE_SET - hint as to whether an argument is set
$OPTION_ARG_COUNT - a value indicating how many values should be shifted when a value has been read

#### Input:
 * `$1...n` - The options to parse and split
 * `$KOALEPHANT_OPTIONS_ALLOW_DASH` - a space separated list of options that accept values with a leading dash as valid (e.g. `--foo -1` to pass '-1' as the value for '--foo').

#### Output:
the options in a space separated string

#### Example:
~~~sh
read_options() {
	local originalCount="$#"
	while k_options_split "$@"; do
		case "$OPTION_NAME" in
			(-a|--arg)
				k_options_arg_required 'You must supply "%s"'
				printf -- 'Opt with value "%s"\n' "${OPTION_VALUE}" >&2
				shift "${OPTION_ARG_COUNT}"
			;;
			(-b|--bool)
				if k_options_arg_optional; then
					printf -- 'Opt with optional value specified "%s"\n' "${OPTION_VALUE}" >&2
					shift "${OPTION_ARG_COUNT}"
				else
					printf -- 'Opt without value specified\n' >&2
					shift
				fi
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
	return $(( originalCount - $# ))
}
read_options "$@" || shift $?
~~~

### `k_options_arg_required`
Check that an option has an argument specified.
This function is designed to work with [`k_options_split`](#k_options_split)

#### Input:
 * `$1` - optional printf template to use for the error message. Defaults to 'Error, %s requires an argument', and receives the option name as argument.
 * `$2` - flag to allow an empty string as the argument, defaults to false.
 * `$OPTION_NAME` - the option name
 * `$OPTION_VALUE` - the next argument the tool was invoked with
 * `$OPTION_VALUE_SET` - flag indicating a value has been set
 * `$KOALEPHANT_OPTIONS_ALLOW_EMPTY` - flag to allow an empty string as the argument, defaults to false. Alternative to param $2

#### Return:
0 if the option is specified, 1 otherwise

### `k_options_arg_optional`
Check whether an option has an optional argument specified.
This function is designed to work with [`k_options_split`](#k_options_split)

#### Input:
 * `$OPTION_VALUE_SET` - flag indicating a value has been set

#### Return:
0 if the option is specified, 1 otherwise

### `$KOALEPHANT_LOG_LEVEL_EMERG`
Log level EMERG - system is unusable

### `$KOALEPHANT_LOG_LEVEL_ALERT`
Log level ALERT - action must be taken immediately

### `$KOALEPHANT_LOG_LEVEL_CRIT`
Log level CRIT - critical conditions

### `$KOALEPHANT_LOG_LEVEL_ERR`
Log level ERR - error conditions

### `$KOALEPHANT_LOG_LEVEL_WARNING`
Log level WARNING - warning conditions

### `$KOALEPHANT_LOG_LEVEL_NOTICE`
Log level NOTICE - normal, but significant, condition

### `$KOALEPHANT_LOG_LEVEL_INFO`
Log level INFO - informational message

### `$KOALEPHANT_LOG_LEVEL_DEBUG`
Log level DEBUG - debug-level message

### `k_log_level_parse`
Parse a log level, check it's validity and output the integer value

#### Input:
 * `$1` - log level value to parse

#### Output:
the parsed log level as an integer

#### Return:
0 if the input can be parsed into a valid log level, 1 if not

### `k_log_level_valid`
Check if a value is a valid log level

#### Input:
 * `$1` - log level value to check

#### Return:
0 if the input can be parsed into a valid log level, 1 if not

### `k_log_level`
Get/Set the current log level

#### Input:
 * `$1` - if provided, set the active log level to this value
 * `$KOALEPHANT_LOG_LEVEL_ACTIVE` - used as explicit log level if set. Default is [`KOALEPHANT_LOG_LEVEL_ERR`]($#KOALEPHANT_LOG_LEVEL_ERR) if not set

#### Output:
the active log level

#### Return:
0 if the log level is valid, 1 if not

### `k_log_level_name`
Get the log level name from a log level value

### `k_log_syslog`
Check if logs should be set to syslog

#### Input:
 * `$KOALEPHANT_LOG_SYSLOG` - used as flag to enable syslog

#### Return:
0 if syslog should be used, 1 otherwise

### `k_log_message`
Log a message according to a syslog level

#### Input:
 * `$1` - the syslog level constant to use. One of the `KOALEPHANT_LOG_LEVEL_*` constants
 * `$2` - an optional printf template to use
 * `$3...n` - the message to write

### `k_log_emerg`
Log a message at syslog-level EMERG

#### Input:
 * `$1` - an optional printf template to use
 * `$2...n` - the message arguments/string

### `k_log_alert`
Log a message at syslog-level ALERT

#### Input:
 * `$1` - an optional printf template to use
 * `$2...n` - the message arguments/string

### `k_log_crit`
Log a message at syslog-level CRIT

#### Input:
 * `$1` - an optional printf template to use
 * `$2...n` - the message arguments/string

### `k_log_err`
Log a message at syslog-level ERR

#### Input:
 * `$1` - an optional printf template to use
 * `$2...n` - the message arguments/string

### `k_log_warning`
Log a message at syslog-level WARNING

#### Input:
 * `$1` - an optional printf template to use
 * `$2...n` - the message arguments/string

### `k_log_notice`
Log a message at syslog-level NOTICE

#### Input:
 * `$1` - an optional printf template to use
 * `$2...n` - the message arguments/string

### `k_log_info`
Log a message at syslog-level INFO

#### Input:
 * `$1` - an optional printf template to use
 * `$2...n` - the message arguments/string

### `k_log_debug`
Log a message at syslog-level DEBUG

#### Input:
 * `$1` - an optional printf template to use
 * `$2...n` - the message arguments/string

### `k_log_deprecated`
Log a message indicating a function is deprecated
Internally this logs as a DEBUG message

#### Input:
 * `$1` - the function name that is deprecated
 * `$2` - the version the function was deprecated
 * `$3` - suggested replacement functions to include in the message. Defaults to empty

### `k_version_compare`
Compare two version strings
Version suffixes (e.g. 'alpha', 'rc1' etc) should use a tilde (~), e.g.: '1.2.0~alpha'
Valid operators are eq/= (equal), neq/!= (not equal), gt/> (greater than), lt/<  (less than), gte/>= (greater or equal), lte/<= (less or equal)

#### Input:
 * `$1` - the first version to compare
 * `$2` - the second version to compare
 * `$3` - the operator to use, defaults to 'gte'.

#### Return:
0 if the version comparison passes, 1 if not

### `k_tty_width`
Get the negotiated "width" of the TTY in columns.
Takes into account overrides, maximum width, and default width (e.g. when no TTY is available).

#### Input:
 * `$KOALEPHANT_TTY_WIDTH_OVERRIDE` - an override for ignoring current TTY width.
 * `$KOALEPHANT_TTY_WIDTH_DEFAULT` - a fallback for the default width (eg when TTY width cannot be determined). If not set, default is 80.
 * `$KOALEPHANT_TTY_WIDTH_MAX` - a maximum bounding width. If not set, maximum is 160. Ignored if 0 or less.

#### Output:
the negotiated TTY width.

### `k_function_exists`
Check if a function exists with the given name

#### Input:
 * `$1` - the function name to check for

#### Return:
0 if the function exists, 1 if not.

