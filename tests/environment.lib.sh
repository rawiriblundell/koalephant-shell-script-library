#!/bin/sh

. ../base.lib.sh
. ../environment.lib.sh
. ../bool.lib.sh
. ../number.lib.sh
. ../fs.lib.sh
. ../string.lib.sh

write_exp_test_worker() {
	# shellcheck disable=SC2039
	local var file mode

	mode="$1"
	shift
	file="$(mktemp)"

	printf -- '#!/bin/sh -e\n\n' > "${file}"
	chmod +x "${file}"

	for var in "$@"; do
		if [ "${mode}" = "export" ]; then
			# shellcheck disable=SC2016
			printf -- 'test_export_%s() {\n\tprintf -- "%%s\\n" "${%s}"\n}\n\n' "$var" "$var" >> "${file}"
		elif [ "${mode}" = "unexport" ]; then
			# shellcheck disable=SC2016
			printf -- 'test_unexport_%s() {\n\tprintf -- "%%s\\n" "${%s+unset}"\n}\n\n' "$var" "$var" >> "${file}"
		fi
	done

	# shellcheck disable=SC2016
	printf -- '\ncase "$1" in\n' >> "${file}"

	for var in "$@"; do
		if [ "${mode}" = "export" ]; then
			printf -- '\t(%s)\n\t\ttest_export_%s\n\t;;\n\n' "${var}" "${var}" >> "${file}"
		elif [ "${mode}" = "unexport" ]; then
			printf -- '\t(%s)\n\t\ttest_unexport_%s\n\t;;\n\n' "${var}" "${var}" >> "${file}"
		fi
	done

	printf -- 'esac\n\n' >> "${file}"

	printf -- '%s' "${file}"
}

write_export_tester() {
	write_exp_test_worker export "$@"
}

write_unexport_tester() {
	write_exp_test_worker unexport "$@"
}

test_k_env_export (){
	# shellcheck disable=SC2039
	local file
	file="$(write_export_tester TEST_VAR)"
	TEST_VAR='foo'
	k_env_export TEST_VAR
	assertEquals 'TEST_VAR is foo' "$TEST_VAR" "$(${file} TEST_VAR)"
}

test_k_env_unexport (){
	# shellcheck disable=SC2039
	local file
	file="$(write_unexport_tester TEST_VAR)"
	export TEST_VAR='foo'
	k_env_unexport TEST_VAR
	assertEquals 'TEST_VAR is foo' "" "$(${file} TEST_VAR)"
}

test_k_env_safename (){
	assertEquals "cannot have spaces" "cannothavespaces" "$(k_env_safename "cannot have spaces")"
}

test_k_env_set (){
	k_env_set FOO bar
	assertTrue 'Set env returns success' $?
	assertEquals 'FOO is bar' 'bar' "${FOO}"

	KOALEPHANT_ENVIRONMENT_PREFIX=PREFIX_ k_env_set FOO bar
	assertTrue 'Set env with prefix returns success' $?
	assertEquals 'PREFIX_FOO is bar' 'bar' "${PREFIX_FOO}"

	k_env_set F.OO bar
	assertTrue 'Set env with invalid name returns success' $?
	assertEquals 'F.OO is bar' 'bar' "${FOO}"

	{
		KOALEPHANT_ENVIRONMENT_PREFIX=PREFIX_ k_env_set F.OO bar
	}
	assertTrue 'Set env with prefix and invalid name returns success' $?
	assertEquals 'PREFIX_F.OO is bar' 'bar' "${PREFIX_FOO}"
}

test_k_env_unset () {
	unset -v KOALEPHANT_ENVIRONMENT_PREFIX

	FOO=bar
	PREFIX_FOO=pbar

	k_env_unset FOO
	assertTrue 'Unset env returns success' $?
	assertEquals 'FOO is ""' '' "${FOO}"

	k_env_unset F.OO
	assertTrue 'Unset env returns success' $?
	assertEquals 'F.OO is ""' '' "${FOO}"

	KOALEPHANT_ENVIRONMENT_PREFIX=PREFIX_

	k_env_unset FOO

	assertTrue 'Unset env with prefix returns success' $?
	assertEquals 'PREFIX_FOO is ""' '' "${PREFIX_FOO}"

	k_env_unset F.OO
	assertTrue 'Unset env with prefix returns success' $?
	assertEquals 'PREFIX_F.OO is ""' '' "${PREFIX_FOO}"

	unset -v KOALEPHANT_ENVIRONMENT_PREFIX
}


test_k_env_import_apache (){
	unset FOO
	unset BAZ
	k_env_import_apache ./test-apache.conf

	assertEquals "FOO is BAR" "BAR" "${FOO}"
	assertEquals "BAZ is BOO" "BOO" "${BAZ}"
}

test_k_env_export_apache (){
	file="$(write_export_tester FOO BAZ)"
	k_env_import_apache ./test-apache.conf
	k_env_export_apache

	assertEquals "FOO is BAR" "BAR" "$(${file} FOO)"
	assertEquals "BAZ is BOO" "BOO" "$(${file} BAZ)"
}

test_k_env_unset_apache (){
	k_env_import_apache ./test-apache.conf
	k_env_unset_apache

	assertEquals "FOO is unset" "" "${FOO+unset}"
	assertEquals "BAZ is unset" "" "${BAZ+unset}"
}

test_k_env_unexport_apache (){
	# shellcheck disable=SC2039
	local file

	file="$(write_unexport_tester FOO BAZ)"
	k_env_import_apache ./test-apache.conf
	k_env_export_apache
	k_env_unexport_apache

	assertEquals "FOO is BAR" "" "$(${file} FOO)"
	assertEquals "BAZ is BOO" "" "$(${file} BAZ)"
}

gecos_set_known() {
	sudo chfn --other shell-script-lib-test@koalephant.com --full-name "KSSL User" --home-phone 1234567890 --work-phone 9876543210 --room 9876 "${USER}"
}

test_k_env_import_gecos (){
	if ! command -v getent > /dev/null; then
		startSkipping
	else
		gecos_set_known
		k_env_import_gecos
	fi
	assertEquals "NAME is KSSL User" "KSSL User" "${NAME}"
	assertEquals "ROOM is 9876" "9876" "${ROOM}"
	assertEquals "TELEPHONE_WORK is 9876543210" "9876543210" "${TELEPHONE_WORK}"
	assertEquals "TELEPHONE_HOME is 1234567890" "1234567890" "${TELEPHONE_HOME}"
	assertEquals "EMAIL is shell-script-lib-test@koalephant.com" "shell-script-lib-test@koalephant.com" "${EMAIL}"
}

test_k_env_export_gecos (){
	# shellcheck disable=SC2039
	local file

	file="$(write_export_tester NAME ROOM TELEPHONE_WORK TELEPHONE_HOME EMAIL)"

	if ! command -v getent > /dev/null; then
		startSkipping
	else
		gecos_set_known
		k_env_import_gecos
		k_env_export_gecos
	fi
	assertEquals "NAME is KSSL User" "KSSL User" "$(${file} NAME)"
	assertEquals "ROOM is 9876" "9876" "$(${file} ROOM)"
	assertEquals "TELEPHONE_WORK is 9876543210" "9876543210" "$(${file} TELEPHONE_WORK)"
	assertEquals "TELEPHONE_HOME is 1234567890" "1234567890" "$(${file} TELEPHONE_HOME)"
	assertEquals "EMAIL is shell-script-lib-test@koalephant.com" "shell-script-lib-test@koalephant.com" "$(${file} EMAIL)"
}

test_k_env_unset_gecos (){
	if ! command -v getent > /dev/null; then
		startSkipping
	else
		gecos_set_known
		k_env_import_gecos
		k_env_unset_gecos
	fi
	assertEquals "NAME is unset" "" "${NAME+unset}"
	assertEquals "ROOM is unset" "" "${ROOM+unset}"
	assertEquals "TELEPHONE_WORK is unset" "" "${TELEPHONE_WORK+unset}"
	assertEquals "TELEPHONE_HOME is unset" "" "${TELEPHONE_HOME+unset}"
	assertEquals "EMAIL is unset" "" "${EMAIL+unset}"
}

test_k_env_unexport_gecos (){
	# shellcheck disable=SC2039
	local file

	file="$(write_unexport_tester NAME ROOM TELEPHONE_WORK TELEPHONE_HOME EMAIL)"

	if ! command -v getent > /dev/null; then
		startSkipping
	else
		gecos_set_known
		k_env_import_gecos
		k_env_export_gecos
		k_env_unset_gecos
	fi

	assertEquals "NAME is unset" "" "$(${file} NAME)"
	assertEquals "ROOM is unset" "" "$(${file} ROOM)"
	assertEquals "TELEPHONE_WORK is unset" "" "$(${file} TELEPHONE_WORK)"
	assertEquals "TELEPHONE_HOME is unset" "" "$(${file} TELEPHONE_HOME)"
	assertEquals "EMAIL is unset" "" "$(${file} EMAIL)"
}


test_k_env_import_ldap (){
	if ! command -v ldapsearch > /dev/null || ! ldapwhoami > /dev/null 2>&1; then
		startSkipping
	else
		k_env_import_ldap 'uid=testing' 'cn' 'sn' 2>/dev/null
	fi

	assertEquals 'COMMON_NAME is Tester' 'Tester' "${COMMON_NAME}"
	assertEquals 'SURNAME is McTesting' 'McTesting' "${SURNAME}"
}


test_k_env_export_ldap (){
	printf -- 'Empty Test\n' >&2
}

test_k_env_unset_ldap (){
	printf -- 'Empty Test\n' >&2
}
