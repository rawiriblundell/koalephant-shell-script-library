#!/bin/sh -eu

. ../base.lib.sh
. ../fs.lib.sh
. ../string.lib.sh
. ../bool.lib.sh
. ../number.lib.sh

debugMode() {
	k_bool_test "${DEBUG_TESTS:-}"
}

oneTimeSetUp() {
	if debugMode; then
		k_log_level "${KOALEPHANT_LOG_LEVEL_DEBUG}" >/dev/null
	fi
}


test_k_library_version (){
	assertEquals "Lib name is correct" "$(printf -- '%s version %s \nCopyright (c) %s, %s' "${KOALEPHANT_LIB_NAME}" "${KOALEPHANT_LIB_VERSION}" "${KOALEPHANT_LIB_YEAR}" "${KOALEPHANT_LIB_OWNER}")" "$(k_library_version)"
}

test_k_tool_name() {
	assertEquals "Tool name auto detect is correct" "$(basename "$0")" "$(k_tool_name)"
	assertEquals "Tool name variable is correct" "sometoolname" "$(KOALEPHANT_TOOL_NAME=sometoolname k_tool_name)"
}

test_k_tool_version() {
	assertEquals "Tool version defaults to 1.0.0" "1.0.0" "$(k_tool_version)"
	assertEquals "Tool version variable is correct" "2.3.1" "$(KOALEPHANT_TOOL_VERSION=2.3.1 k_tool_version)"
}

test_k_tool_year (){
	assertEquals "Tool year auto detect is correct" "$(date +%Y)" "$(k_tool_year)"
	assertEquals "Tool year variable is correct" "1992" "$(KOALEPHANT_TOOL_YEAR=1992 k_tool_year)"
}

test_k_tool_owner (){
	assertEquals "Tool owner default is correct" "Koalephant Co., Ltd" "$(k_tool_owner)"
	assertEquals "Tool owner variable is correct" "sometoolowner" "$(KOALEPHANT_TOOL_OWNER=sometoolowner k_tool_owner)"
}

test_k_tool_description (){
	assertEquals "Tool description variable is correct" "description foo" "$(KOALEPHANT_TOOL_DESCRIPTION="description foo" k_tool_description)"
}

test_k_tool_options (){
	assertEquals "Tool options variable is correct" "options foo" "$(KOALEPHANT_TOOL_OPTIONS="options foo" k_tool_options)"
}

test_k_tool_options_arguments (){
	assertEquals "Tool options arguments default is correct" " [OPTION]..." "$(KOALEPHANT_TOOL_OPTIONS=options k_tool_options_arguments)"
	assertEquals "Tool options arguments variable is correct" " args" "$(KOALEPHANT_TOOL_OPTIONS=options KOALEPHANT_TOOL_OPTIONS_ARGUMENTS="args" k_tool_options_arguments)"
}

test_k_tool_arguments (){
	assertEquals "Tool arguments variable is correct" " args" "$(KOALEPHANT_TOOL_ARGUMENTS=args k_tool_arguments)"
}

test_k_tool_environment (){
	assertEquals "Environment default is correct" '' "$(k_tool_environment)"
	assertEquals "Environment variable is correct" "$(printf -- 'Environment: \n\n%s\n' 'TEST - test argument name')" "$(KOALEPHANT_TOOL_ENVIRONMENT="TEST - test argument name" k_tool_environment)"
}


test_k_version (){
	assertEquals "Version default is correct" "$(printf -- "%s version %s \nCopyright (c) %s, %s" "$(basename "$0")" "1.0.0" "$(date +%Y)" "Koalephant Co., Ltd")" "$(k_version)"
	assertEquals "Version variable is correct" "$(printf -- "%s version %s \nCopyright (c) %s, %s" "sometoolname" "2.3.1" "1992" "sometoolowner")" "$(KOALEPHANT_TOOL_NAME=sometoolname KOALEPHANT_TOOL_VERSION=2.3.1 KOALEPHANT_TOOL_YEAR=1992 KOALEPHANT_TOOL_OWNER=sometoolowner k_version)"
}

test_k_version_compare (){

	k_version_compare "1.0.0" "1.0.0" eq
	assertTrue "1.0.0 = 1.0.0" $?

	k_version_compare "1.0.0" "2.0.0" eq
	assertFalse "1.0.0 = 2.0.0" $?

	k_version_compare "1.0.0" "1.0.0" neq
	assertFalse "1.0.0 != 1.0.0" $?

	k_version_compare "1.0.0" "2.0.0" neq
	assertTrue "1.0.0 != 2.0.0" $?

	k_version_compare "1.0.0" "1.0.0" gte
	assertTrue "1.0.0 >= 1.0.0" $?

	k_version_compare "1.0.1" "1.0.0" gte
	assertTrue "1.0.1 >= 1.0.0" $?

	k_version_compare "1.0.1" "2.0.0" gte
	assertFalse "1.0.1 >= 2.0.0" $?

	k_version_compare "1.0.1" "1.0.0" lte
	assertFalse "1.0.1 <= 1.0.0" $?

	k_version_compare "0.0.1" "1.0.0" lte
	assertTrue "0.0.1 <= 1.0.0" $?

	k_version_compare "1.0.1" "1.0.2" lt
	assertTrue "1.0.1 < 1.0.2" $?

	k_version_compare "1.0.0" "1.0.0" gt
	assertFalse "1.0.0 > 1.0.0" $?

	k_version_compare "1.0.0" "0.9.9" gt
	assertTrue "1.0.0 > 0.9.9" $?

	k_version_compare "1.0.0" "1.0.0~alpha" gt
	assertTrue "1.0.0 > 1.0.0~alpha" $?
}

worker_k_log_levels() {
	# shellcheck disable=SC2039
	local setLevel output='' logFunc="$1" msgLevel="$2" msgLevelName setLevelName allLevels="${KOALEPHANT_LOG_LEVEL_EMERG} ${KOALEPHANT_LOG_LEVEL_ALERT} ${KOALEPHANT_LOG_LEVEL_CRIT} ${KOALEPHANT_LOG_LEVEL_ERR} ${KOALEPHANT_LOG_LEVEL_WARNING} ${KOALEPHANT_LOG_LEVEL_NOTICE} ${KOALEPHANT_LOG_LEVEL_INFO} ${KOALEPHANT_LOG_LEVEL_DEBUG}"

	msgLevelName="$(k_log_level_name "${msgLevel}")"

	for setLevel in ${allLevels}; do
		KOALEPHANT_LOG_LEVEL_ACTIVE=${setLevel}
		setLevelName="$(k_log_level_name "${setLevel}")"
		output="$(${logFunc} "foo bar" 2>&1 1>/dev/null)"
		assertTrue 'Message is logged without error' $?
		if [ "${msgLevel}" -le "${setLevel}" ]; then
			assertEquals "${msgLevelName} is logged at level ${setLevelName}" "foo bar" "${output}"
		else
			assertEquals "${msgLevelName} is not logged at level ${setLevelName}" "" "${output}"
		fi
	done
}

test_k_log_emerg (){
	worker_k_log_levels k_log_emerg "${KOALEPHANT_LOG_LEVEL_EMERG}"
}

test_k_log_alert (){
	worker_k_log_levels k_log_alert "${KOALEPHANT_LOG_LEVEL_ALERT}"
}


test_k_log_crit (){
	worker_k_log_levels k_log_crit "${KOALEPHANT_LOG_LEVEL_CRIT}"
}


test_k_log_err (){
	worker_k_log_levels k_log_err "${KOALEPHANT_LOG_LEVEL_ERR}"
}


test_k_log_warning (){
	worker_k_log_levels k_log_warning "${KOALEPHANT_LOG_LEVEL_WARNING}"
}


test_k_log_notice (){
	worker_k_log_levels k_log_notice "${KOALEPHANT_LOG_LEVEL_NOTICE}"
}


test_k_log_info (){
	worker_k_log_levels k_log_info "${KOALEPHANT_LOG_LEVEL_INFO}"
}


test_k_log_debug (){
	worker_k_log_levels k_log_debug "${KOALEPHANT_LOG_LEVEL_DEBUG}"
}


test_k_log_deprecated (){
	KOALEPHANT_LOG_SYSLOG=false
	KOALEPHANT_LOG_LEVEL_ACTIVE="${KOALEPHANT_LOG_LEVEL_DEBUG}"

	output="$(k_log_deprecated foo_func 2.0 2>&1 1>/dev/null)"
	assertEquals 'Output is standard error message with 2 arguments' 'foo_func is deprecated as of v2.0' "${output}"

	output="$(k_log_deprecated foo_func 2.0 'foobar_func' 2>&1 1>/dev/null)"
	assertEquals 'Output is extended error message with 3 arguments' 'foo_func is deprecated as of v2.0, consider using foobar_func instead' "${output}"
}

# shellcheck disable=SC2039
test_k_log_message (){
	local output msgLevel allLevels="${KOALEPHANT_LOG_LEVEL_EMERG} ${KOALEPHANT_LOG_LEVEL_ALERT} ${KOALEPHANT_LOG_LEVEL_CRIT} ${KOALEPHANT_LOG_LEVEL_ERR} ${KOALEPHANT_LOG_LEVEL_WARNING} ${KOALEPHANT_LOG_LEVEL_NOTICE} ${KOALEPHANT_LOG_LEVEL_INFO} ${KOALEPHANT_LOG_LEVEL_DEBUG}"

	for msgLevel in ${allLevels}; do
		worker_k_log_levels "k_log_message ${msgLevel}" "${msgLevel}"
	done

	output="$(k_log_message "${KOALEPHANT_LOG_LEVEL_EMERG}" 'foo %s' bar  2>&1 1>/dev/null)"
	assertEquals 'Custom format log message is rendered correctly' 'foo bar' "${output}"

	output="$(k_log_message "${KOALEPHANT_LOG_LEVEL_EMERG}" 'foo bar baz' 2>&1 1>/dev/null)"
	assertEquals 'Default format log message is rendered correctly' 'foo bar baz' "${output}"

	k_log_message 9 foo 2>/dev/null
	assertFalse 'Invalid log level returns error' $?

	k_log_message 0 foo 2>/dev/null
	assertFalse 'Invalid log level returns error' $?

	k_log_message warn foo 2>/dev/null
	assertFalse 'Invalid log level returns error' $?
}

test_k_log_syslog (){
	unset KOALEPHANT_LOG_SYSLOG

	k_log_syslog
	assertFalse "Syslog defaults to off" $?

	KOALEPHANT_LOG_SYSLOG=true k_log_syslog
	assertTrue "Syslog explicitly on" $?

	KOALEPHANT_LOG_SYSLOG=false k_log_syslog
	assertFalse "Syslog explicitly off" $?
}

test_k_log_level (){
	unset KOALEPHANT_LOG_LEVEL_ACTIVE
	assertEquals "Default log level is Error" "${KOALEPHANT_LOG_LEVEL_ERR}" "$(k_log_level)"

	KOALEPHANT_LOG_LEVEL_ACTIVE="${KOALEPHANT_LOG_LEVEL_DEBUG}"
	assertEquals "Previously set log level is read" "${KOALEPHANT_LOG_LEVEL_DEBUG}" "$(k_log_level)"

	result1="$(k_log_level "${KOALEPHANT_LOG_LEVEL_NOTICE}")"
	assertTrue "Setting valid log level succeeds" $?
	assertEquals "Setting log level outputs same on success" "${KOALEPHANT_LOG_LEVEL_NOTICE}" "${result1}"

	before2="$(k_log_level)"
	result2="$(k_log_level 9 2>/dev/null)"
	assertFalse "Setting invalid log level fails" $?
	assertEquals "Setting invalid log level outputs current level" "${before2}" "${result2}"
}



test_k_log_level_name (){
	assertEquals "Log level name is Emerg" "emerg" "$(k_log_level_name "${KOALEPHANT_LOG_LEVEL_EMERG}")"
	assertEquals "Log level name is Alert" "alert" "$(k_log_level_name "${KOALEPHANT_LOG_LEVEL_ALERT}")"
	assertEquals "Log level name is Crit" "crit" "$(k_log_level_name "${KOALEPHANT_LOG_LEVEL_CRIT}")"
	assertEquals "Log level name is Err" "err" "$(k_log_level_name "${KOALEPHANT_LOG_LEVEL_ERR}")"
	assertEquals "Log level name is Warning" "warning" "$(k_log_level_name "${KOALEPHANT_LOG_LEVEL_WARNING}")"
	assertEquals "Log level name is Notice" "notice" "$(k_log_level_name "${KOALEPHANT_LOG_LEVEL_NOTICE}")"
	assertEquals "Log level name is Info" "info" "$(k_log_level_name "${KOALEPHANT_LOG_LEVEL_INFO}")"
	assertEquals "Log level name is Debug" "debug" "$(k_log_level_name "${KOALEPHANT_LOG_LEVEL_DEBUG}")"

	result="$(k_log_level_name 0 2>/dev/null)"
	assertFalse "Invalid log level name fails"
	assertNull "Invalid Log level name is null" "${result}"
}

test_k_log_level_valid (){
	k_log_level_valid "${KOALEPHANT_LOG_LEVEL_EMERG}"
	assertTrue "Log Level Emerg is valid" $?

	k_log_level_valid "${KOALEPHANT_LOG_LEVEL_ALERT}"
	assertTrue "Log Level Alert is valid" $?

	k_log_level_valid "${KOALEPHANT_LOG_LEVEL_CRIT}"
	assertTrue "Log Level Crit is valid" $?

	k_log_level_valid "${KOALEPHANT_LOG_LEVEL_ERR}"
	assertTrue "Log Level Err is valid" $?

	k_log_level_valid "${KOALEPHANT_LOG_LEVEL_WARNING}"
	assertTrue "Log Level Warning is valid" $?

	k_log_level_valid "${KOALEPHANT_LOG_LEVEL_NOTICE}"
	assertTrue "Log Level Notice is valid" $?

	k_log_level_valid "${KOALEPHANT_LOG_LEVEL_INFO}"
	assertTrue "Log Level Info is valid" $?

	k_log_level_valid "${KOALEPHANT_LOG_LEVEL_DEBUG}"
	assertTrue "Log Level Debug is valid" $?

	k_log_level_valid 0
	assertFalse "Log Level 0 is invalid" $?

	k_log_level_valid 9
	assertFalse "Log Level 9 is invalid" $?

	k_log_level_valid alert
	assertFalse "Log Level 'alert' is invalid" $?
}

test_k_log_level_parse (){
	# on success, return 0 and output new level to stdout
	result="$(k_log_level_parse "${KOALEPHANT_LOG_LEVEL_EMERG}")"
	assertTrue "Log Level Emerg is valid" $?
	assertEquals "Log Level Emerg is output" "${KOALEPHANT_LOG_LEVEL_EMERG}" "${result}"

	result="$(k_log_level_parse "${KOALEPHANT_LOG_LEVEL_ALERT}")"
	assertTrue "Log Level Alert is valid" $?
	assertEquals "Log Level Alert is output" "${KOALEPHANT_LOG_LEVEL_ALERT}" "${result}"

	result="$(k_log_level_parse "${KOALEPHANT_LOG_LEVEL_CRIT}")"
	assertTrue "Log Level Crit is valid" $?
	assertEquals "Log Level Crit is output" "${KOALEPHANT_LOG_LEVEL_CRIT}" "${result}"

	result="$(k_log_level_parse "${KOALEPHANT_LOG_LEVEL_ERR}")"
	assertTrue "Log Level Err is valid" $?
	assertEquals "Log Level Err is output" "${KOALEPHANT_LOG_LEVEL_ERR}" "${result}"

	result="$(k_log_level_parse "${KOALEPHANT_LOG_LEVEL_WARNING}")"
	assertTrue "Log Level Warning is valid" $?
	assertEquals "Log Level Warning is output" "${KOALEPHANT_LOG_LEVEL_WARNING}" "${result}"

	result="$(k_log_level_parse "${KOALEPHANT_LOG_LEVEL_NOTICE}")"
	assertTrue "Log Level Notice is valid" $?
	assertEquals "Log Level Notice is output" "${KOALEPHANT_LOG_LEVEL_NOTICE}" "${result}"

	result="$(k_log_level_parse "${KOALEPHANT_LOG_LEVEL_INFO}")"
	assertTrue "Log Level Info is valid" $?
	assertEquals "Log Level Info is output" "${KOALEPHANT_LOG_LEVEL_INFO}" "${result}"

	result="$(k_log_level_parse "${KOALEPHANT_LOG_LEVEL_DEBUG}")"
	assertTrue "Log Level Debug is valid" $?
	assertEquals "Log Level Debug is output" "${KOALEPHANT_LOG_LEVEL_DEBUG}" "${result}"



	result="$(k_log_level_parse 0 2>&1 1>/dev/null)"
	assertFalse "Log Level 0 is invalid" $?
	assertEquals "Error message is output" 'Invalid log level specified: "0"' "${result}"

	result="$(k_log_level_parse 9 2>&1 1>/dev/null)"
	assertFalse "Log Level 9 is invalid" $?
	assertEquals "Error message is output" 'Invalid log level specified: "9"' "${result}"

	result="$(k_log_level_parse alert 2>&1 1>/dev/null)"
	assertFalse "Log Level 'alert' is invalid" $?
	assertEquals "Error message is output" 'Invalid log level specified: "alert"' "${result}"
}


test_k_option_requires_arg (){
	# shellcheck disable=SC2039
	local output=''

	KOALEPHANT_LOG_SYSLOG=false
	KOALEPHANT_LOG_LEVEL_ACTIVE="${KOALEPHANT_LOG_LEVEL_ERR}"

	output="$(k_option_requires_arg --my-opt 2>&1 1>/dev/null)"
	assertFalse 'Unset option value results in error code' $?
	assertEquals 'Unset option value outputs error message' 'Error, --my-opt requires an argument' "${output}"

	output="$(k_option_requires_arg --my-opt foo)"
	assertTrue '"foo" is a valid required option arg value' $?
	assertEquals 'Output is option value with a valid option arg value' foo "${output}"

	output="$(k_option_requires_arg --my-opt -foo 2>&1 1>/dev/null)"
	assertFalse '"-foo" is not a valid required option arg value' $?
	assertEquals 'Invalid option arg value (-foo) outputs error message' 'Error, --my-opt requires an argument' "${output}"

	output="$(k_option_requires_arg --my-opt ' -foo')"
	assertTrue '" -foo" is a valid required option arg value' $?
	assertEquals 'Output is option value with a valid option arg value' ' -foo' "${output}"

	output="$(k_option_requires_arg --my-opt '' 2>&1 1>/dev/null)"
	assertFalse '"" is not a valid required option arg value' $?
	assertEquals 'Invalid option arg value () outputs error message' 'Error, --my-opt requires an argument' "${output}"

	output="$(k_option_requires_arg --my-opt 2>&1 1>/dev/null)"
	assertFalse '(unset) is not a valid required option arg value' $?
	assertEquals 'Invalid option arg value (unset) outputs error message' 'Error, --my-opt requires an argument' "${output}"
}


test_k_option_optional_arg (){
	# shellcheck disable=SC2039
	local output=""

	output="$(k_option_optional_arg '' foo)"
	assertEquals 'Output is option value with a valid option arg value' foo "${output}"

	output="$(k_option_optional_arg '' -foo)"
	assertNull '"-foo" is not a valid optional option arg value' "${output}"

	output="$(k_option_optional_arg '' ' -foo')"
	assertEquals 'Output is option value with a valid option arg value' ' -foo' "${output}"

	output="$(k_option_optional_arg '' '')"
	assertNull  '"" is not a valid optional option arg value' "${output}"

	output="$(k_option_optional_arg)"
	assertNull  '(unset) is not a valid optional option arg value' "${output}"
}

test_k_options_arg_optional (){
	k_options_split --foo foo
	k_options_arg_optional
	assertTrue '"foo" is a valid optional option arg value' $?

	k_options_split --foo -foo
	k_options_arg_optional
	assertFalse '"-foo" is not a valid optional option arg value' $?

	k_options_split --foo ' -foo'
	k_options_arg_optional
	assertTrue '" -foo" is a valid optional option arg value' $?

	k_options_split --foo ''
	k_options_arg_optional
	assertTrue '"" is a valid optional option arg value' $?
}



test_k_options_arg_required (){
	# shellcheck disable=SC2039
	local output=''
	unset OPTION_NAME

	KOALEPHANT_LOG_SYSLOG=false

	output="$(k_options_arg_required 2>&1 1>/dev/null)"
	assertEquals 'Unset OPTION_NAME results in error code 2' 2 $?
	assertEquals 'Unset OPTION_NAME outputs error message' 'Error, no option name set. Must be used with k_options_split()' "${output}"

	output="$(k_options_split --my-opt foo; k_options_arg_required 2>&1 1>/dev/null)"
	assertTrue '"foo" is a valid required option arg value' $?
	assertNull 'Output is empty with a valid option arg value' "${output}"


	output="$(k_options_split --my-opt -foo; k_options_arg_required 2>&1 1>/dev/null)"
	assertFalse '"-foo" is not a valid required option arg value' $?
	assertEquals 'Invalid option arg value (-foo) outputs error message' 'Error, --my-opt requires an argument' "${output}"

	output="$(k_options_split --my-opt ' -foo'; k_options_arg_required 2>&1 1>/dev/null)"
	assertTrue '" -foo" is a valid required option arg value' $?
	assertNull 'Output is empty with a valid option arg value' "${output}"

	output="$(k_options_split --my-opt ''; k_options_arg_required 2>&1 1>/dev/null)"
	assertFalse '"" is not a valid required option arg value' $?
	assertEquals 'Invalid option arg value () outputs error message' 'Error, --my-opt requires an argument' "${output}"

	output="$(k_options_split --my-opt ''; k_options_arg_required '' true 2>&1 1>/dev/null)"
	assertTrue '"" is a valid required option arg value when allowEmpty is true' $?
	assertNull 'Output is empty with a valid option arg value' "${output}"

	output="$(k_options_split --my-opt; k_options_arg_required 'You must supply "%s"' 2>&1 1>/dev/null)"
	assertFalse '(unset) is not a valid required option arg value' $?
	assertEquals 'Invalid option arg value (unset) outputs error message' 'You must supply "--my-opt"' "${output}"

}


test_k_options_split (){
	options_split_worker() {
		KOALEPHANT_OPTIONS_ALLOW_DASH='-d --dashed'
		while k_options_split "$@"; do
			case "$OPTION_NAME" in
				(-a|--arg)
					assertEquals '-a/--arg value is Foo' 'Foo' "${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(-o|--opt)
					if k_options_arg_optional; then
						[ "${OPTION_VALUE}" = 'false' ] || [ "${OPTION_VALUE}" = '' ]
						assertTrue '-o/--opt value is false or empty string' $?
						shift "${OPTION_ARG_COUNT}"
					else
						assertEquals '-o/--opt value is empty string' '' "${OPTION_VALUE}"
						shift 1
					fi
				;;

				(-d|--dashed)
					assertEquals '-d/--dashed value is -dashing' '-dashing' "${OPTION_VALUE}"
					shift "${OPTION_ARG_COUNT}"
				;;

				(--)
					shift 1
					break
				;;

				(*)
					break
				;;
			esac
		done

		if [ $# -gt 0 ]; then
			assertEquals 'Arg1 is HELLO' 'HELLO' "$1"
			shift 1
		fi

		if [ $# -gt 0 ]; then
			assertEquals 'Arg2 is --foo' '--foo' "$1"
			shift 1
		fi

		if [ $# -gt 0 ]; then
			assertEquals 'Arg3 is -BAR' '-BAR' "$1"
			shift 1
		fi
	}


	options_split_worker -a Foo
	options_split_worker -a Foo HELLO
	options_split_worker -a Foo -- HELLO --foo
	options_split_worker -a Foo -- HELLO --foo -BAR
	options_split_worker -aFoo
	options_split_worker -aFoo HELLO
	options_split_worker -aFoo -- HELLO --foo
	options_split_worker -aFoo -- HELLO --foo -BAR
	options_split_worker --arg Foo
	options_split_worker --arg Foo HELLO
	options_split_worker --arg Foo -- HELLO --foo
	options_split_worker --arg Foo -- HELLO --foo -BAR
	options_split_worker --arg=Foo
	options_split_worker --arg=Foo HELLO
	options_split_worker --arg=Foo -- HELLO --foo
	options_split_worker --arg=Foo -- HELLO --foo -BAR
	options_split_worker -o
	options_split_worker -o ''
	options_split_worker -o -- HELLO
	options_split_worker -o -- HELLO --foo
	options_split_worker -o -- HELLO --foo -BAR
	options_split_worker -o false
	options_split_worker -o false HELLO
	options_split_worker -o false -- HELLO --foo
	options_split_worker -o false -- HELLO --foo -BAR
	options_split_worker -ofalse
	options_split_worker -ofalse HELLO
	options_split_worker -ofalse -- HELLO --foo
	options_split_worker -ofalse -- HELLO --foo -BAR
	options_split_worker --opt
	options_split_worker --opt -- HELLO
	options_split_worker --opt -- HELLO --foo
	options_split_worker --opt -- HELLO --foo -BAR
	options_split_worker --opt false
	options_split_worker --opt false HELLO
	options_split_worker --opt false -- HELLO --foo
	options_split_worker --opt false -- HELLO --foo -BAR
	options_split_worker --opt=false
	options_split_worker --opt=false HELLO
	options_split_worker --opt=false -- HELLO --foo
	options_split_worker --opt=false -- HELLO --foo -BAR
	options_split_worker -a Foo -o
	options_split_worker -a Foo -o -- HELLO
	options_split_worker -a Foo -o -- HELLO --foo
	options_split_worker -a Foo -o -- HELLO --foo -BAR
	options_split_worker -a Foo -o false
	options_split_worker -a Foo -o false HELLO
	options_split_worker -a Foo -o false -- HELLO --foo
	options_split_worker -a Foo -o false -- HELLO --foo -BAR
	options_split_worker -a Foo -ofalse
	options_split_worker -a Foo -ofalse HELLO
	options_split_worker -a Foo -ofalse -- HELLO --foo
	options_split_worker -a Foo -ofalse -- HELLO --foo -BAR
	options_split_worker -a Foo --opt
	options_split_worker -a Foo --opt -- HELLO
	options_split_worker -a Foo --opt -- HELLO --foo
	options_split_worker -a Foo --opt -- HELLO --foo -BAR
	options_split_worker -a Foo --opt false
	options_split_worker -a Foo --opt false HELLO
	options_split_worker -a Foo --opt false -- HELLO --foo
	options_split_worker -a Foo --opt false -- HELLO --foo -BAR
	options_split_worker -a Foo --opt=false
	options_split_worker -a Foo --opt=false HELLO
	options_split_worker -a Foo --opt=false -- HELLO --foo
	options_split_worker -a Foo --opt=false -- HELLO --foo -BAR
	options_split_worker -aFoo -o
	options_split_worker -aFoo -o -- HELLO
	options_split_worker -aFoo -o -- HELLO --foo
	options_split_worker -aFoo -o -- HELLO --foo -BAR
	options_split_worker -aFoo -o false
	options_split_worker -aFoo -o false HELLO
	options_split_worker -aFoo -o false -- HELLO --foo
	options_split_worker -aFoo -o false -- HELLO --foo -BAR
	options_split_worker -aFoo -ofalse
	options_split_worker -aFoo -ofalse HELLO
	options_split_worker -aFoo -ofalse -- HELLO --foo
	options_split_worker -aFoo -ofalse -- HELLO --foo -BAR
	options_split_worker -aFoo --opt
	options_split_worker -aFoo --opt -- HELLO
	options_split_worker -aFoo --opt -- HELLO --foo
	options_split_worker -aFoo --opt -- HELLO --foo -BAR
	options_split_worker -aFoo --opt false
	options_split_worker -aFoo --opt false HELLO
	options_split_worker -aFoo --opt false -- HELLO --foo
	options_split_worker -aFoo --opt false -- HELLO --foo -BAR
	options_split_worker -aFoo --opt=false
	options_split_worker -aFoo --opt=false HELLO
	options_split_worker -aFoo --opt=false -- HELLO --foo
	options_split_worker -aFoo --opt=false -- HELLO --foo -BAR
	options_split_worker --arg Foo -o
	options_split_worker --arg Foo -o -- HELLO
	options_split_worker --arg Foo -o -- HELLO --foo
	options_split_worker --arg Foo -o -- HELLO --foo -BAR
	options_split_worker --arg Foo -o false
	options_split_worker --arg Foo -o false HELLO
	options_split_worker --arg Foo -o false -- HELLO --foo
	options_split_worker --arg Foo -o false -- HELLO --foo -BAR
	options_split_worker --arg Foo -ofalse
	options_split_worker --arg Foo -ofalse HELLO
	options_split_worker --arg Foo -ofalse -- HELLO --foo
	options_split_worker --arg Foo -ofalse -- HELLO --foo -BAR
	options_split_worker --arg Foo --opt
	options_split_worker --arg Foo --opt -- HELLO
	options_split_worker --arg Foo --opt -- HELLO --foo
	options_split_worker --arg Foo --opt -- HELLO --foo -BAR
	options_split_worker --arg Foo --opt false
	options_split_worker --arg Foo --opt false HELLO
	options_split_worker --arg Foo --opt false -- HELLO --foo
	options_split_worker --arg Foo --opt false -- HELLO --foo -BAR
	options_split_worker --arg Foo --opt=false
	options_split_worker --arg Foo --opt=false HELLO
	options_split_worker --arg Foo --opt=false -- HELLO --foo
	options_split_worker --arg Foo --opt=false -- HELLO --foo -BAR
	options_split_worker --arg=Foo -o
	options_split_worker --arg=Foo -o -- HELLO
	options_split_worker --arg=Foo -o -- HELLO --foo
	options_split_worker --arg=Foo -o -- HELLO --foo -BAR
	options_split_worker --arg=Foo -o false
	options_split_worker --arg=Foo -o false HELLO
	options_split_worker --arg=Foo -o false -- HELLO --foo
	options_split_worker --arg=Foo -o false -- HELLO --foo -BAR
	options_split_worker --arg=Foo -ofalse
	options_split_worker --arg=Foo -ofalse HELLO
	options_split_worker --arg=Foo -ofalse -- HELLO --foo
	options_split_worker --arg=Foo -ofalse -- HELLO --foo -BAR
	options_split_worker --arg=Foo --opt
	options_split_worker --arg=Foo --opt -- HELLO
	options_split_worker --arg=Foo --opt -- HELLO --foo
	options_split_worker --arg=Foo --opt -- HELLO --foo -BAR
	options_split_worker --arg=Foo --opt false
	options_split_worker --arg=Foo --opt false HELLO
	options_split_worker --arg=Foo --opt false -- HELLO --foo
	options_split_worker --arg=Foo --opt false -- HELLO --foo -BAR
	options_split_worker --arg=Foo --opt=false
	options_split_worker --arg=Foo --opt=false HELLO
	options_split_worker --arg=Foo --opt=false -- HELLO --foo
	options_split_worker --arg=Foo --opt=false -- HELLO --foo -BAR
	options_split_worker --arg=Foo -d -dashing --opt false
	options_split_worker --arg=Foo --dashed -dashing --opt false HELLO
	options_split_worker --arg=Foo --opt false --dashed -dashing -- HELLO --foo
	options_split_worker --arg=Foo --opt false -- HELLO --foo -BAR
	options_split_worker --arg=Foo --opt=false -d -dashing
	options_split_worker --arg=Foo --opt=false HELLO
	options_split_worker --arg=Foo --opt=false -- HELLO --foo
	options_split_worker --arg=Foo --opt=false -- HELLO --foo -BAR
}

test_k_require_root (){
	not_root() {
		# shellcheck disable=SC2039
		local output
		id () {
			printf -- '%d\n' 1
		}

		output="$(k_require_root 2>&1 1>/dev/null)"
		assertFalse 'UID other than 0 fails' $?
		assertEquals 'Output is an error message' "$(k_tool_name) must be run as root" "${output}"

		output="$(k_require_root 'Foo is a Bar' 2>&1 1>/dev/null)"
		assertEquals 'Output is a custom + error message' "$(printf -- '%s\n' 'Foo is a Bar' "$(k_tool_name) must be run as root")" "${output}"
	}

	is_root() {
		id () {
			printf -- '%d\n' 0
		}

		k_require_root
		assertTrue 'UID 0 passes' $?
	}
	is_root
	not_root
}



test_k_requires_args (){
	# shellcheck disable=SC2039
	local output tmplate='%s requires at least %d arguments, %d given\n'

	output="$(k_requires_args 2>&1 1>/dev/null)"
	assertFalse 'Return is error without arguments' $?
	# shellcheck disable=SC2059
	assertEquals 'Output is an error message' "$(printf -- "${tmplate}" k_requires_args 2 0)" "${output}"

	output="$(k_requires_args foo_func 2>&1 1>/dev/null)"
	assertFalse 'Return is error with 1 argument' $?
	# shellcheck disable=SC2059
	assertEquals 'Output is an error message' "$(printf -- "${tmplate}" k_requires_args 2 1)" "${output}"

	output="$(k_requires_args foo_func 0 2>&1 1>/dev/null)"
	assertFalse 'Return is error with 2 arguments if second is < 1' $?
	# shellcheck disable=SC2059
	assertEquals 'Output is an error message with 2 argument if second is < 1' "$(printf -- "${tmplate}" foo_func 1 0)" "${output}"

	output="$(k_requires_args foo_func 1 2 2>&1 1>/dev/null)"
	assertFalse 'Return is error with 3 arguments if second is < third' $?
	# shellcheck disable=SC2059
	assertEquals 'Output is an error message with 2 argument if second is < third' "$(printf -- "${tmplate}" foo_func 2 1)" "${output}"

	output="$(k_requires_args foo_func 1 2>&1 1>/dev/null)"
	assertTrue 'Return is success with 2 arguments if second is >= 1' $?

	output="$(k_requires_args foo_func 2 2  2>&1 1>/dev/null)"
	assertTrue 'Return is success with 3 arguments if second is >= third' $?

	output="$(k_requires_args foo_func 3 2  2>&1 1>/dev/null)"
	assertTrue 'Return is success with 3 arguments if second is >= third' $?
}



test_k_tool_usage (){
	assertEquals 'Output is correct format' "$(printf -- 'Usage: %s%s%s\n' "$(k_tool_name)" "$(k_tool_options_arguments)" "$(k_tool_arguments)")" "$(k_tool_usage)"
}

test_k_usage (){
	assertEquals 'Output is correct format' "$(printf -- '%s\n%s\n\n%s\n\n%s\n' "$(k_tool_usage)" "$(k_tool_description)" "$(k_tool_options)" "$(k_tool_environment)")" "$(k_usage)"
}

test_k_version_helper (){
	# shellcheck disable=SC2039
	local output

	k_version_helper false false false
	assertFalse 'Return is error when first arg is false' $?

	output="$(k_version_helper true false false)"
	assertTrue 'Return is success when first arg is true' $?
	assertEquals 'Output is full tool version info when args 2 and 3 are false' "$(k_version)" "${output}"

	output="$(k_version_helper true false true )"
	assertTrue 'Return is success when first and last args are true' $?
	assertEquals 'Output is full tool + lib version info when args are true false true' "$(k_version; k_library_version)" "${output}"

	output="$(k_version_helper true true false)"
	assertTrue 'Return is success when first two args are true' $?
	assertEquals 'Output is basic tool version info when args are true true false' "$(k_tool_version)" "${output}"

	output="$(k_version_helper true true true)"
	assertTrue 'Return is success when all args are true' $?
	assertEquals 'Output is basic tool + lib version info when args are true true true' "$(k_tool_version; printf -- '%s\n' "${KOALEPHANT_LIB_VERSION}")" "${output}"
}


test_k_tool_has_options (){
	unset KOALEPHANT_TOOL_OPTIONS KOALEPHANT_TOOL_OPTIONS_OPTS

	(
		# shellcheck disable=SC2034
		KOALEPHANT_TOOL_OPTIONS='foo'
		k_tool_has_options
		# shellcheck disable=SC2016
		assertTrue 'Tool has options when $KOALEPHANT_TOOL_OPTIONS is set' $?
	)
	(
		# shellcheck disable=SC2030
		KOALEPHANT_TOOL_OPTIONS_OPTS='foo'
		k_tool_has_options
		# shellcheck disable=SC2016
		assertTrue 'Tool has options when $KOALEPHANT_TOOL_OPTIONS_OPTS is set' $?
	)
}

test_k_tool_options_add (){
	unset KOALEPHANT_TOOL_OPTIONS_LONGEST KOALEPHANT_TOOL_OPTIONS_OPTS KOALEPHANT_TOOL_OPTIONS_DESCRIPTIONS KOALEPHANT_TOOL_OPTIONS_DESCRIPTION_LINES
	k_tool_options_add 'foo' 'f' 'arg' 'This is option foo' 'This is the second line for foo'
	k_tool_options_add 'bar' 'b' '' 'This is option bar'
	k_tool_options_add 'baz' '' 'argument-one' 'This is option baz' 'This is also a second line'

	assertEquals 'Longest option value is calculated correctly' '23' "${KOALEPHANT_TOOL_OPTIONS_LONGEST}"
	# shellcheck disable=SC2031
	assertEquals 'Correct number of option lines are stored' '3' "$(printf -- '%s\n' "${KOALEPHANT_TOOL_OPTIONS_OPTS}" | wc -l | sed -e "s/^[[:space:]]*//g; s/[[:space:]]*$//g;")"
	assertEquals 'Correct number of descriptions lines are stored' '5' "$(( KOALEPHANT_TOOL_OPTIONS_DESCRIPTION_LINES - 1 ))"

	# shellcheck disable=SC2031
	assertEquals 'Correct option descriptions are stored' "$(printf -- '%s\n' 'This is option foo' 'This is the second line for foo' 'This is option bar' 'This is option baz' 'This is also a second line')" "${KOALEPHANT_TOOL_OPTIONS_DESCRIPTIONS}"

	# shellcheck disable=SC2031
	assertEquals 'Correct option values are stored' "$(printf -- '%s;%s;%s;%d;%d\n' 'foo' 'f' 'arg' 1 2  'bar' 'b' '' 3 1 'baz' '' 'argument-one' 4 2)" "${KOALEPHANT_TOOL_OPTIONS_OPTS}"
}

test_k_tool_options_alias (){
	unset KOALEPHANT_TOOL_OPTIONS_OPTS KOALEPHANT_TOOL_OPTIONS_LONGEST KOALEPHANT_TOOL_OPTIONS_DESCRIPTIONS KOALEPHANT_TOOL_OPTIONS_DESCRIPTION_LINES
	k_tool_options_alias 'foo' 'f' '--bar'
	k_tool_options_alias 'baz' 'b' '--bazza'

	# shellcheck disable=SC2031
	assertEquals 'Alias description is set' "$(printf -- '%s\n' 'Alias for --bar' 'Alias for --bazza')" "${KOALEPHANT_TOOL_OPTIONS_DESCRIPTIONS}"

	# shellcheck disable=SC2031
	assertEquals 'Alias option values are stored' "$(printf -- '%s;%s;%s;%d;%d\n' 'foo' 'f' '' 1 1 'baz' 'b' '' 2 1)" "${KOALEPHANT_TOOL_OPTIONS_OPTS}"
}

test_k_tool_options_code (){
	# shellcheck disable=SC2039
	local expected

	expected="$(printf -- '   # %s\n' 'This ' 'is ' 'line ' 'one' 'This ' 'is ' 'line ' 'two' 'This ' 'is ' 'line ' 'three')"

	assertEquals 'Code lines are wrapped and indented' "${expected}" "$(KOALEPHANT_TTY_WIDTH_OVERRIDE=10 k_tool_options_code 3 '# ' 'This is line one' 'This is line two' 'This is line three')"
}


test_k_tool_options_text (){
	# shellcheck disable=SC2039
	local expected

	expected="$(printf -- '   > %s\n' 'This is line one which ' 'should wrap.' 'This is line 2 which wont' 'This is line three')"
	assertEquals 'Code lines are wrapped and indented' "${expected}" "$(KOALEPHANT_TTY_WIDTH_OVERRIDE=30 k_tool_options_text 3 '> ' 'This is line one which should wrap.' 'This is line 2 which wont' 'This is line three')"

	expected="$(printf -- '   > %s\n' 'This is line one which should wrap.' 'This is line 2 which wont' 'This is line three')"
	assertEquals 'Code lines are not wrapped when producing help2man output' "${expected}" "$(KOALEPHANT_TTY_WIDTH_OVERRIDE=30 K_HELP2MAN_BUILD=1 k_tool_options_text 3 '> ' 'This is line one which should wrap.' 'This is line 2 which wont' 'This is line three')"
}

test_k_tool_options_print (){

	unset KOALEPHANT_TOOL_OPTIONS_LONGEST KOALEPHANT_TOOL_OPTIONS_OPTS KOALEPHANT_TOOL_OPTIONS_DESCRIPTIONS KOALEPHANT_TOOL_OPTIONS_DESCRIPTION_LINES
	k_tool_options_add 'foo' 'f' 'arg' 'This is option foo' 'This is the second line for foo'
	k_tool_options_add 'bar' 'b' '' 'This is option bar'
	k_tool_options_add 'baz' '' 'argument-one' 'This is option baz' 'This is also a second line'

	expected="$(printf -- 'Options:\n\n'; printf -- '%4s %5s %-14s%s\n' \
		'-f,' '--foo' 'arg' 'This is option foo' \
		''   ''      ''    '  This is the second line for foo' \
		'-b,' '--bar' ''    'This is option bar' \
		''   '--baz' 'argument-one' 'This is option baz' \
		''   ''      ''    '  This is also a second line')"

	assertEquals 'Formatted options help output is displayed correctly' "$expected" "$(k_tool_options_print)"
}

test_k_tty_width (){
	unset KOALEPHANT_TTY_WIDTH_DEFAULT KOALEPHANT_TTY_WIDTH_MAX KOALEPHANT_TTY_WIDTH_OVERRIDE

	[ ! -t 0 ] && startSkipping
	# shellcheck disable=SC2046
	assertEquals 'Actual TTY width or max(160) is returned when a TTY is available' "$(k_int_min 160 $(stty size 2>/dev/null | cut -f 2 -d ' '))" "$(k_tty_width)"
	export KOALEPHANT_TTY_WIDTH_MAX=0
	assertEquals 'Actual TTY width is returned when a TTY is available and max is 0' "$(stty size 2>/dev/null | cut -f 2 -d ' ')" "$(k_tty_width)"
	unset KOALEPHANT_TTY_WIDTH_MAX
	endSkipping

	stty(){ :; }
	export KOALEPHANT_TTY_WIDTH_DEFAULT=100
	assertEquals 'TTY width uses default when detection fails' "$KOALEPHANT_TTY_WIDTH_DEFAULT" "$(k_tty_width)"

	export KOALEPHANT_TTY_WIDTH_MAX=90
	assertEquals 'TTY width limited to max' "$KOALEPHANT_TTY_WIDTH_MAX" "$(k_tty_width)"

	export KOALEPHANT_TTY_WIDTH_OVERRIDE=140
	assertEquals 'TTY width overridden' "$KOALEPHANT_TTY_WIDTH_OVERRIDE" "$(k_tty_width)"

	unset KOALEPHANT_TTY_WIDTH_OVERRIDE
}

test_k_function_exists (){
	function_123456() { :; }

	k_function_exists 'function_123456'
	assertTrue 'Function identified as existing' "$?"

	k_function_exists 'function_123456_nope'
	assertFalse 'Function identified as not existing' "$?"

	k_function_exists 'echo'
	assertFalse 'Builtin not identified as function' $?

	k_function_exists 'tee'
	assertFalse 'Standard binary not identified as function' $?
}

test_k_tool_usage_text (){
	# shellcheck disable=SC2039
	local input longInput longInputWrapped longInputWrappedPrefixed longInputWrappedIndented longInputWrappedIndentedPrefixed

	error="$(k_tool_usage_text 2>&1 < /dev/tty)"
	assertFalse 'Calling without arguments returns error'
	assertEquals 'Calling without arguments outputs error' 'k_tool_usage_text requires at least 3 arguments, 0 given' "${error}"


	input="this is a line "
	longInput="Ut enim ad minim veniam, quis nostrud exercitation. Vivamus sagittis lacus vel augue laoreet rutrum faucibus. Cum sociis natoque penatibus et magnis dis parturient."
	longInputWrapped="$(printf -- '%s\n' \
		'Ut enim ad minim veniam, quis nostrud ' \
		'exercitation. Vivamus sagittis lacus ' \
		'vel augue laoreet rutrum faucibus. Cum ' \
		'sociis natoque penatibus et magnis dis ' \
		'parturient.' \
	)"

	longInputWrappedPrefixed="$(printf -- 'foo%s\n' \
		'Ut enim ad minim veniam, quis ' \
		'nostrud exercitation. Vivamus ' \
		'sagittis lacus vel augue laoreet ' \
		'rutrum faucibus. Cum sociis natoque ' \
		'penatibus et magnis dis parturient.' \
	)"

	longInputWrappedIndented="$(printf -- '    %s\n' \
		'Ut enim ad minim veniam, quis ' \
		'nostrud exercitation. Vivamus ' \
		'sagittis lacus vel augue laoreet ' \
		'rutrum faucibus. Cum sociis natoque ' \
		'penatibus et magnis dis parturient.' \
	)"

	longInputWrappedIndentedPrefixed="$(printf -- '    foo%s\n' \
		'Ut enim ad minim veniam, quis ' \
		'nostrud exercitation. Vivamus ' \
		'sagittis lacus vel augue laoreet ' \
		'rutrum faucibus. Cum sociis ' \
		'natoque penatibus et magnis dis ' \
		'parturient.' \
	)"


	assertEquals "Short line is not changed" "${input}" "$(k_tool_usage_text 0 '' "$input")"
	assertEquals "Short line is not changed via stdin" "${input}" "$(printf -- '%s' "$input" | k_tool_usage_text)"
	assertEquals "Short line is not changed via stdin with 1 arg" "${input}" "$(printf -- '%s' "$input" | k_tool_usage_text 0)"
	assertEquals "Short line is not changed via stdin with 2 args" "${input}" "$(printf -- '%s' "$input" | k_tool_usage_text 0 '')"
	assertEquals "Short line is not changed via stdin with 3 args" "${input}" "$(printf -- '%s' "$input" | k_tool_usage_text 0 '' -)"

	assertEquals "Prefixed short line is prefixed" "foo${input}" "$(k_tool_usage_text 0 'foo' "$input")"
	assertEquals "Prefixed short line is prefixed via stdin with 2 args" "foo${input}" "$(printf -- '%s' "$input" | k_tool_usage_text 0 'foo')"
	assertEquals "Prefixed short line is prefixed via stdin with 3 args" "foo${input}" "$(printf -- '%s' "$input" | k_tool_usage_text 0 'foo' -)"

	assertEquals "Indented short line is indented" "    ${input}" "$(k_tool_usage_text 4 '' "$input")"
	assertEquals "Indented short line is indented via stdin with 1 arg" "    ${input}" "$(printf -- '%s' "$input" | k_tool_usage_text 4)"
	assertEquals "Indented short line is indented via stdin with 2 args" "    ${input}" "$(printf -- '%s' "$input" | k_tool_usage_text 4 '')"
	assertEquals "Indented short line is indented via stdin with 3 args" "    ${input}" "$(printf -- '%s' "$input" | k_tool_usage_text 4 '' -)"

	export KOALEPHANT_TTY_WIDTH_OVERRIDE=40

	assertEquals "Long line is wrapped" "${longInputWrapped}" "$(k_tool_usage_text 0 '' "$longInput")"
	assertEquals "Long line is wrapped via stdin" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_text)"
	assertEquals "Long line is wrapped via stdin with 1 arg" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_text 0)"
	assertEquals "Long line is wrapped via stdin with 2 args" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_text 0 '')"
	assertEquals "Long line is wrapped via stdin with 3 args" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_text 0 '' -)"

	assertEquals "Long line is wrapped & prefixed" "${longInputWrappedPrefixed}" "$(k_tool_usage_text 0 'foo' "$longInput")"
	assertEquals "Long line is wrapped & prefixed via stdin" "${longInputWrappedPrefixed}" "$(printf -- '%s' "$longInput" | k_tool_usage_text 0 'foo')"
	assertEquals "Long line is wrapped & prefixed via stdin with 3 args" "${longInputWrappedPrefixed}" "$(printf -- '%s' "$longInput" | k_tool_usage_text 0 'foo' -)"

	assertEquals "Long line is wrapped & indented" "${longInputWrappedIndented}" "$(k_tool_usage_text 4 '' "$longInput")"
	assertEquals "Long line is wrapped & indented via stdin with 1 arg" "${longInputWrappedIndented}" "$(printf -- '%s' "$longInput" | k_tool_usage_text 4)"
	assertEquals "Long line is wrapped & indented via stdin with 2 args" "${longInputWrappedIndented}" "$(printf -- '%s' "$longInput" | k_tool_usage_text 4 '')"
	assertEquals "Long line is wrapped & indented via stdin with 3 args" "${longInputWrappedIndented}" "$(printf -- '%s' "$longInput" | k_tool_usage_text 4 '' -)"

	assertEquals "Long line is wrapped prefixed & indented" "${longInputWrappedIndentedPrefixed}" "$(k_tool_usage_text 4 'foo' "$longInput")"
	assertEquals "Long line is wrapped prefixed & indented via stdin" "${longInputWrappedIndentedPrefixed}" "$(printf -- '%s' "$longInput" | k_tool_usage_text 4 'foo')"
	unset KOALEPHANT_TTY_WIDTH_OVERRIDE
}




test_k_tool_usage_code (){
	# shellcheck disable=SC2039
	local input longInput longInputWrapped longInputWrappedPrefixed longInputWrappedIndented longInputWrappedIndentedPrefixed

	error="$(k_tool_usage_code 2>&1 < /dev/tty)"
	assertFalse 'Calling without arguments returns error'
	assertEquals 'Calling without arguments outputs error' 'k_tool_usage_code requires at least 3 arguments, 0 given' "${error}"


	input="this is a line "
	longInput="Ut enim ad minim veniam, quis nostrud exercitation. Vivamus sagittis lacus vel augue laoreet rutrum faucibus. Cum sociis natoque penatibus et magnis dis parturient."
	longInputWrapped="$(printf -- '%s\n' \
		'Ut enim ad minim veniam, quis nostrud ' \
		'exercitation. Vivamus sagittis lacus ' \
		'vel augue laoreet rutrum faucibus. Cum ' \
		'sociis natoque penatibus et magnis dis ' \
		'parturient.' \
	)"

	longInputWrappedPrefixed="$(printf -- 'foo%s\n' \
		'Ut enim ad minim veniam, quis ' \
		'nostrud exercitation. Vivamus ' \
		'sagittis lacus vel augue laoreet ' \
		'rutrum faucibus. Cum sociis natoque ' \
		'penatibus et magnis dis parturient.' \
	)"

	longInputWrappedIndented="$(printf -- '    %s\n' \
		'Ut enim ad minim veniam, quis ' \
		'nostrud exercitation. Vivamus ' \
		'sagittis lacus vel augue laoreet ' \
		'rutrum faucibus. Cum sociis natoque ' \
		'penatibus et magnis dis parturient.' \
	)"

	longInputWrappedIndentedPrefixed="$(printf -- '    foo%s\n' \
		'Ut enim ad minim veniam, quis ' \
		'nostrud exercitation. Vivamus ' \
		'sagittis lacus vel augue laoreet ' \
		'rutrum faucibus. Cum sociis ' \
		'natoque penatibus et magnis dis ' \
		'parturient.' \
	)"


	assertEquals "Short line is not changed" "${input}" "$(k_tool_usage_code 0 '' "$input")"
	assertEquals "Short line is not changed via stdin" "${input}" "$(printf -- '%s' "$input" | k_tool_usage_code)"
	assertEquals "Short line is not changed via stdin with 1 arg" "${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0)"
	assertEquals "Short line is not changed via stdin with 2 args" "${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0 '')"
	assertEquals "Short line is not changed via stdin with 3 args" "${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0 '' -)"

	assertEquals "Prefixed short line is prefixed" "foo${input}" "$(k_tool_usage_code 0 'foo' "$input")"
	assertEquals "Prefixed short line is prefixed via stdin with 2 args" "foo${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0 'foo')"
	assertEquals "Prefixed short line is prefixed via stdin with 3 args" "foo${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0 'foo' -)"

	assertEquals "Indented short line is indented" "    ${input}" "$(k_tool_usage_code 4 '' "$input")"
	assertEquals "Indented short line is indented via stdin with 1 arg" "    ${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 4)"
	assertEquals "Indented short line is indented via stdin with 2 args" "    ${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 4 '')"
	assertEquals "Indented short line is indented via stdin with 3 args" "    ${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 4 '' -)"

	export KOALEPHANT_TTY_WIDTH_OVERRIDE=40

	assertEquals "Long line is wrapped" "${longInputWrapped}" "$(k_tool_usage_code 0 '' "$longInput")"
	assertEquals "Long line is wrapped via stdin" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_code)"
	assertEquals "Long line is wrapped via stdin with 1 arg" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0)"
	assertEquals "Long line is wrapped via stdin with 2 args" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0 '')"
	assertEquals "Long line is wrapped via stdin with 3 args" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0 '' -)"

	assertEquals "Long line is wrapped & prefixed" "${longInputWrappedPrefixed}" "$(k_tool_usage_code 0 'foo' "$longInput")"
	assertEquals "Long line is wrapped & prefixed via stdin" "${longInputWrappedPrefixed}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0 'foo')"
	assertEquals "Long line is wrapped & prefixed via stdin with 3 args" "${longInputWrappedPrefixed}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0 'foo' -)"

	assertEquals "Long line is wrapped & indented" "${longInputWrappedIndented}" "$(k_tool_usage_code 4 '' "$longInput")"
	assertEquals "Long line is wrapped & indented via stdin with 1 arg" "${longInputWrappedIndented}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 4)"
	assertEquals "Long line is wrapped & indented via stdin with 2 args" "${longInputWrappedIndented}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 4 '')"
	assertEquals "Long line is wrapped & indented via stdin with 3 args" "${longInputWrappedIndented}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 4 '' -)"

	assertEquals "Long line is wrapped prefixed & indented" "${longInputWrappedIndentedPrefixed}" "$(k_tool_usage_code 4 'foo' "$longInput")"
	assertEquals "Long line is wrapped prefixed & indented via stdin" "${longInputWrappedIndentedPrefixed}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 4 'foo')"

	unset KOALEPHANT_TTY_WIDTH_OVERRIDE
	
	export K_HELP2MAN_BUILD=1


	input="this is a line "
	longInput="Ut enim ad minim veniam, quis nostrud exercitation. Vivamus sagittis lacus vel augue laoreet rutrum faucibus. Cum sociis natoque penatibus et magnis dis parturient."
	longInputWrapped="$(printf -- '%% |%s\n' \
		'Ut enim ad minim veniam, quis nostrud exercitation. ' \
		'Vivamus sagittis lacus vel augue laoreet rutrum ' \
		'faucibus. Cum sociis natoque penatibus et magnis dis ' \
		'parturient.' \
	)"

	longInputWrappedPrefixed="$(printf -- '%% |foo%s\n' \
		'Ut enim ad minim veniam, quis nostrud exercitation. ' \
		'Vivamus sagittis lacus vel augue laoreet rutrum ' \
		'faucibus. Cum sociis natoque penatibus et magnis dis ' \
		'parturient.' \
	)"

	longInputWrappedIndented="$(printf -- '    %% |%s\n' \
		'Ut enim ad minim veniam, quis nostrud exercitation. ' \
		'Vivamus sagittis lacus vel augue laoreet rutrum ' \
		'faucibus. Cum sociis natoque penatibus et magnis dis ' \
		'parturient.' \
	)"

	longInputWrappedIndentedPrefixed="$(printf -- '    %% |foo%s\n' \
		'Ut enim ad minim veniam, quis nostrud ' \
		'exercitation. Vivamus sagittis lacus vel augue ' \
		'laoreet rutrum faucibus. Cum sociis natoque ' \
		'penatibus et magnis dis parturient.' \
	)"


	assertEquals "Short line is adpted to code output" "% |${input}" "$(k_tool_usage_code 0 '' "$input")"
	assertEquals "Short line is adpted to code output via stdin" "% |${input}" "$(printf -- '%s' "$input" | k_tool_usage_code)"
	assertEquals "Short line is adpted to code output via stdin with 1 arg" "% |${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0)"
	assertEquals "Short line is adpted to code output via stdin with 2 args" "% |${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0 '')"
	assertEquals "Short line is adpted to code output via stdin with 3 args" "% |${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0 '' -)"

	assertEquals "Prefixed short line is adpted to code output & prefixed" "% |foo${input}" "$(k_tool_usage_code 0 'foo' "$input")"
	assertEquals "Prefixed short line is adpted to code output & prefixed via stdin with 2 args" "% |foo${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0 'foo')"
	assertEquals "Prefixed short line is adpted to code output & prefixed via stdin with 3 args" "% |foo${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 0 'foo' -)"

	assertEquals "Indented short line is adpted to code output & indented" "    % |${input}" "$(k_tool_usage_code 4 '' "$input")"
	assertEquals "Indented short line is adpted to code output & indented via stdin with 1 arg" "    % |${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 4)"
	assertEquals "Indented short line is adpted to code output & indented via stdin with 2 args" "    % |${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 4 '')"
	assertEquals "Indented short line is adpted to code output & indented via stdin with 3 args" "    % |${input}" "$(printf -- '%s' "$input" | k_tool_usage_code 4 '' -)"

	assertEquals "Long line is adpted to code output & wrapped" "${longInputWrapped}" "$(k_tool_usage_code 0 '' "$longInput")"
	assertEquals "Long line is adpted to code output & wrapped via stdin" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_code)"
	assertEquals "Long line is adpted to code output & wrapped via stdin with 1 arg" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0)"
	assertEquals "Long line is adpted to code output & wrapped via stdin with 2 args" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0 '')"
	assertEquals "Long line is adpted to code output & wrapped via stdin with 3 args" "${longInputWrapped}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0 '' -)"

	assertEquals "Long line is adpted to code output & wrapped & prefixed" "${longInputWrappedPrefixed}" "$(k_tool_usage_code 0 'foo' "$longInput")"
	assertEquals "Long line is adpted to code output & wrapped & prefixed via stdin" "${longInputWrappedPrefixed}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0 'foo')"
	assertEquals "Long line is adpted to code output & wrapped & prefixed via stdin with 3 args" "${longInputWrappedPrefixed}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 0 'foo' -)"

	assertEquals "Long line is adpted to code output & wrapped & indented" "${longInputWrappedIndented}" "$(k_tool_usage_code 4 '' "$longInput")"
	assertEquals "Long line is adpted to code output & wrapped & indented via stdin with 1 arg" "${longInputWrappedIndented}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 4)"
	assertEquals "Long line is adpted to code output & wrapped & indented via stdin with 2 args" "${longInputWrappedIndented}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 4 '')"
	assertEquals "Long line is adpted to code output & wrapped & indented via stdin with 3 args" "${longInputWrappedIndented}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 4 '' -)"

	assertEquals "Long line is adpted to code output & wrapped prefixed & indented" "${longInputWrappedIndentedPrefixed}" "$(k_tool_usage_code 4 'foo' "$longInput")"
	assertEquals "Long line is adpted to code output & wrapped prefixed & indented via stdin" "${longInputWrappedIndentedPrefixed}" "$(printf -- '%s' "$longInput" | k_tool_usage_code 4 'foo')"
}

test_k_tool_description_code_add (){
	error="$(k_tool_description_code_add 2>&1 < /dev/tty)"
	assertFalse 'Calling without arguments returns error'
	assertEquals 'Calling without arguments outputs error' 'k_tool_description_code_add requires at least 3 arguments, 0 given' "${error}"


	unset KOALEPHANT_TOOL_DESCRIPTION_EXTENDED

	k_tool_description_code_add 0 '' 'Foo bar'
	assertEquals '1 Description code block is stored' "$(k_tool_usage_code 0 '' 'Foo bar')" "${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:-}"
	k_tool_description_code_add 0 '' 'Foo bar 2'
	assertEquals \
		'2 Description code blocks are stored' \
		 "$(printf -- '%s\n\n' "$(k_tool_usage_code 0 '' 'Foo bar')" "$(k_tool_usage_code 0 '' 'Foo bar 2')")" \
		  "${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:-}"

	k_tool_description_code_add 0 '' 'Cum sociis natoque penatibus et magnis dis parturient. Quam temere in vitiis, legem sancimus haerentia. Quisque ut dolor gravida, placerat libero vel, euismod.'
	assertEquals \
		'3 Description code blocks are stored' \
		 "$(printf -- '%s\n\n' "$(k_tool_usage_code 0 '' 'Foo bar')" "$(k_tool_usage_code 0 '' 'Foo bar 2')" "$(k_tool_usage_code 0 '' 'Cum sociis natoque penatibus et magnis dis parturient. Quam temere in vitiis, legem sancimus haerentia. Quisque ut dolor gravida, placerat libero vel, euismod.')")" \
		 "${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:-}"
}



test_k_tool_description_text_add (){
	error="$(k_tool_description_add 2>&1 < /dev/tty)"
	assertFalse 'Calling without arguments returns error'
	assertEquals 'Calling without arguments outputs error' 'k_tool_description_add requires at least 3 arguments, 0 given' "${error}"


	unset KOALEPHANT_TOOL_DESCRIPTION_EXTENDED

	k_tool_description_add 0 '' 'Foo bar'
	assertEquals '1 Description text block is stored' "$(k_tool_usage_text 0 '' 'Foo bar')" "${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:-}"
	k_tool_description_add 0 '' 'Foo bar 2'
	assertEquals \
		'2 Description text blocks are stored' \
		 "$(printf -- '%s\n\n' "$(k_tool_usage_text 0 '' 'Foo bar')" "$(k_tool_usage_text 0 '' 'Foo bar 2')")" \
		  "${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:-}"

	k_tool_description_add 0 '' 'Cum sociis natoque penatibus et magnis dis parturient. Quam temere in vitiis, legem sancimus haerentia. Quisque ut dolor gravida, placerat libero vel, euismod.'
	assertEquals \
		'3 Description text blocks are stored' \
		 "$(printf -- '%s\n\n' "$(k_tool_usage_text 0 '' 'Foo bar')" "$(k_tool_usage_text 0 '' 'Foo bar 2')" "$(k_tool_usage_text 0 '' 'Cum sociis natoque penatibus et magnis dis parturient. Quam temere in vitiis, legem sancimus haerentia. Quisque ut dolor gravida, placerat libero vel, euismod.')")" \
		 "${KOALEPHANT_TOOL_DESCRIPTION_EXTENDED:-}"
}



test_k_tool_environment_add (){
	unset KOALEPHANT_TOOL_ENVIRONMENT_LONGEST KOALEPHANT_TOOL_ENVIRONMENT_NAMES KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTIONS KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTION_LINES
	k_tool_environment_add 'FOO' 'This is envvar FOO' 'This is the second line for FOO'
	k_tool_environment_add 'BAR' 'This is envvar BAR'
	k_tool_environment_add 'BAZ' 'This is envvar BAZ' 'This is also a second line'

	assertEquals 'Longest env var is calculated correctly' '8' "${KOALEPHANT_TOOL_ENVIRONMENT_LONGEST}"
	assertEquals 'Correct number of env var lines are stored' '3' "$(printf -- '%s\n' "${KOALEPHANT_TOOL_ENVIRONMENT_NAMES}" | wc -l | sed -e "s/^[[:space:]]*//g; s/[[:space:]]*$//g;")"
	assertEquals 'Correct number of descriptions lines are stored' '5' "$(( KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTION_LINES - 1 ))"
	# shellcheck disable=SC2031
	assertEquals 'Correct envvar values are stored' "$(printf -- '%s;%d;%d\n' 'FOO' 1 2  'BAR' 3 1 'BAZ' 4 2)" "${KOALEPHANT_TOOL_ENVIRONMENT_NAMES}"
}



test_k_tool_environment_alias (){
	unset KOALEPHANT_TOOL_ENVIRONMENT_LONGEST KOALEPHANT_TOOL_ENVIRONMENT_NAMES KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTIONS KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTION_LINES
	k_tool_environment_alias 'FOO' 'FOO_VAR'
	k_tool_environment_alias 'BAR' 'BAR_VAR'

	assertEquals 'Alias description is set' "$(printf -- '%s\n' 'Alias for FOO_VAR' 'Alias for BAR_VAR')" "${KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTIONS}"
	assertEquals 'Correct envvar values are stored' "$(printf -- '%s;%d;%d\n' 'FOO' 1 1 'BAR' 2 1)" "${KOALEPHANT_TOOL_ENVIRONMENT_NAMES}"
}



test_k_tool_environment_print (){
	unset KOALEPHANT_TOOL_ENVIRONMENT_LONGEST KOALEPHANT_TOOL_ENVIRONMENT_NAMES KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTIONS KOALEPHANT_TOOL_ENVIRONMENT_DESCRIPTION_LINES
	k_tool_environment_add 'FOO' 'This is envvar FOO' 'This is the second line for FOO'
	k_tool_environment_alias 'FOO2' 'FOO'
	k_tool_environment_add 'BAR' 'This is envvar BAR'
	k_tool_environment_alias 'BAR2' 'BAR'
	k_tool_environment_add 'BAZ' 'This is envvar BAZ' 'This is also a second line'


	expected="$(printf -- 'Environment:\n\n'; printf -- '  %-9s%s\n' \
		'FOO' 'This is envvar FOO' \
		'' '  This is the second line for FOO' \
		'FOO2' 'Alias for FOO' \
		'BAR' 'This is envvar BAR' \
		'BAR2' 'Alias for BAR' \
		'BAZ' 'This is envvar BAZ' \
		''   '  This is also a second line')"

	assertEquals 'Formatted env var help output is displayed correctly' "$expected" "$(k_tool_environment_print)"
}


test_k_tool_description_add (){
	printf -- 'Empty test for "%s"\n' 'k_tool_description_add' >&2
}

