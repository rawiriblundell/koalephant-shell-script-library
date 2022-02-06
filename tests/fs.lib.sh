#!/bin/sh -eu

. ../base.lib.sh
. ../fs.lib.sh
. ../bool.lib.sh
. ../string.lib.sh
. ../number.lib.sh

debugMode() {
	k_bool_test "${DEBUG_TESTS:-}"
}

oneTimeSetUp() {
	if debugMode; then
		k_log_level "${KOALEPHANT_LOG_LEVEL_DEBUG}" >/dev/null
	fi
}

test_k_fs_basename (){
	assertEquals "basename of /root/mid/end" end "$(k_fs_basename /root/mid/end)"
	assertEquals "basename of /root/mid/end/" end "$(k_fs_basename /root/mid/end)"
	assertEquals "basename of /root/mid/end.ext" end.ext "$(k_fs_basename /root/mid/end.ext)"
	assertEquals "basename of /root/mid/end.ext/" end.ext "$(k_fs_basename /root/mid/end.ext)"
	assertEquals "basename without .ext of /root/mid/end.ext" end "$(k_fs_basename /root/mid/end.ext .ext)"
	assertEquals "basename without .ext of /root/mid/end.ext/" end "$(k_fs_basename /root/mid/end.ext/ .ext)"
	assertEquals "basename without any ext of /root/mid/end.ext" end "$(k_fs_basename /root/mid/end.ext '.*')"
	assertEquals "basename without any ext of /root/mid/end.ext/" end "$(k_fs_basename /root/mid/end.ext/ '.*')"
	assertEquals "basename without .ex?t of /root/mid/end.ext" end.ext "$(k_fs_basename /root/mid/end.ext '.ex?t')"
	assertEquals "basename without .ex?t of /root/mid/end.ext/" end.ext "$(k_fs_basename /root/mid/end.ext/ '.ex?t')"
	assertEquals "basename without .ex?t of /root/mid/end.exit" end "$(k_fs_basename /root/mid/end.exit '.ex?t')"
	assertEquals "basename without .ex?t of /root/mid/end.exit/" end "$(k_fs_basename /root/mid/end.exit/ '.ex?t')"
	assertEquals "basename without .ex*t of /root/mid/end.ext" end "$(k_fs_basename /root/mid/end.ext '.ex*t')"
	assertEquals "basename without .ex*t of /root/mid/end.ext/" end "$(k_fs_basename /root/mid/end.ext/ '.ex*t')"
	assertEquals "basename without .ex*t of /root/mid/end.exit" end "$(k_fs_basename /root/mid/end.exit '.ex*t')"
	assertEquals "basename without .ex*t of /root/mid/end.exit/" end "$(k_fs_basename /root/mid/end.exit/ '.ex*t')"
	assertEquals "basename without .bar of /root/mid/end" end "$(k_fs_basename /root/mid/end .bar)"
	assertEquals "basename without .bar of /root/mid/end/" end "$(k_fs_basename /root/mid/end/ .bar)"


	assertEquals "basename of /root/mid/end.foo.ext" end.foo.ext "$(k_fs_basename /root/mid/end.foo.ext)"
	assertEquals "basename of /root/mid/end.foo.ext/" end.foo.ext "$(k_fs_basename /root/mid/end.foo.ext)"
	assertEquals "basename without .ext of /root/mid/end.foo.ext" end.foo "$(k_fs_basename /root/mid/end.foo.ext/ .ext)"
	assertEquals "basename without .ext of /root/mid/end.foo.ext/" end.foo "$(k_fs_basename /root/mid/end.foo.ext/ .ext)"
	assertEquals "basename without any ext of /root/mid/end.foo.ext" end.foo "$(k_fs_basename /root/mid/end.foo.ext/ '.*')"
	assertEquals "basename without any ext of /root/mid/end.foo.ext/" end.foo "$(k_fs_basename /root/mid/end.foo.ext/ '.*')"
	assertEquals "basename without any double ext of /root/mid/end.foo.ext" end "$(k_fs_basename /root/mid/end.foo.ext/ '.*.*')"
	assertEquals "basename without any double ext of /root/mid/end.foo.ext/" end "$(k_fs_basename /root/mid/end.foo.ext/ '.*.*')"
	assertEquals "basename without .ex?t of /root/mid/end.foo.ext" end.foo.ext "$(k_fs_basename /root/mid/end.foo.ext/ '.ex?t')"
	assertEquals "basename without .ex?t of /root/mid/end.foo.ext/" end.foo.ext "$(k_fs_basename /root/mid/end.foo.ext/ '.ex?t')"
	assertEquals "basename without .ex?t of /root/mid/end.foo.exit" end.foo "$(k_fs_basename /root/mid/end.foo.exit/ '.ex?t')"
	assertEquals "basename without .ex?t of /root/mid/end.foo.exit/" end.foo "$(k_fs_basename /root/mid/end.foo.exit/ '.ex?t')"
	assertEquals "basename without .ex*t of /root/mid/end.foo.ext" end.foo "$(k_fs_basename /root/mid/end.foo.ext/ '.ex*t')"
	assertEquals "basename without .ex*t of /root/mid/end.foo.ext/" end.foo "$(k_fs_basename /root/mid/end.foo.ext/ '.ex*t')"
	assertEquals "basename without .ex*t of /root/mid/end.foo.exit" end.foo "$(k_fs_basename /root/mid/end.foo.exit/ '.ex*t')"
	assertEquals "basename without .ex*t of /root/mid/end.foo.exit/" end.foo "$(k_fs_basename /root/mid/end.foo.exit/ '.ex*t')"
	assertEquals "basename without .bar of /root/mid/end.foo" end.foo "$(k_fs_basename /root/mid/end.foo .bar)"
	assertEquals "basename without .bar of /root/mid/end.foo/" end.foo "$(k_fs_basename /root/mid/end.foo/ .bar)"
}


test_k_fs_extension (){
	assertEquals "extension of /root/mid/end" "" "$(k_fs_extension /root/mid/end)"
	assertEquals "extension of /root/mid/end.ext" ext "$(k_fs_extension /root/mid/end.ext)"
	assertEquals "extension of /root/mid/end/" "" "$(k_fs_extension /root/mid/end)"
	assertEquals "extension of /root/mid/end.ext/" ext "$(k_fs_extension /root/mid/end.ext)"
	assertEquals "extension of /root/mid/end.foo" foo "$(k_fs_extension /root/mid/end.foo)"
	assertEquals "last extension of /root/mid/end.foo.ext" ext "$(k_fs_extension /root/mid/end.foo.ext)"
	assertEquals "full extension of /root/mid/end.foo.ext" foo.ext "$(k_fs_extension /root/mid/end.foo.ext true)"
	assertEquals "last extension of /root/mid/end.foo/" foo "$(k_fs_extension /root/mid/end.foo)"
	assertEquals "full extension of /root/mid/end.foo.ext/" foo.ext "$(k_fs_extension /root/mid/end.foo.ext true)"
	:;
}

test_k_fs_dirname (){
	assertEquals "dirname of /root/mid/end" /root/mid "$(k_fs_dirname /root/mid/end)"
	assertEquals "dirname of /root/mid/end.ext" /root/mid "$(k_fs_dirname /root/mid/end.ext)"
	assertEquals "dirname of /root/mid/end.ext/" /root/mid "$(k_fs_dirname /root/mid/end.ext/)"
}

test_k_fs_resolve (){
	# shellcheck disable=SC2039
	local parent nonExPath nonExPathTraversal

	parent="$(cd "${TMPDIR:-/tmp}" && pwd -P)/"

	dirName="$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | dd ibs=1 count=20 2>/dev/null)"
	dir="${parent}${dirName}"
	original="$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | dd ibs=1 count=20 2>/dev/null)"
	link1="$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | dd ibs=1 count=20 2>/dev/null)"
	link2="$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | dd ibs=1 count=20 2>/dev/null)"
	link3="$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | dd ibs=1 count=20 2>/dev/null)"
	link4="$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | dd ibs=1 count=20 2>/dev/null)"

	mkdir "${dir}"
	touch "${dir}/${original}"
	ln -sf "${dir}" "${parent}${link1}"
	ln -sf "${original}" "${dir}/${link2}"
	(cd "$dir"; ln -sf "${original}" "${link3}")
	ln -sf "${dir}/../${dirName}" "${dir}/${link4}"

	assertEquals "Dir Symlink resolves" "${dir}" "$(k_fs_resolve "${parent}${link1}")"
	assertEquals "Dir Symlink to File resolves" "${dir}/${original}" "$(k_fs_resolve "${parent}${link1}/${original}")"
	assertEquals "File Symlink resolves" "${dir}/${original}" "$(k_fs_resolve "${dir}/${link2}")"
	assertEquals "Dir+File Symlink resolves" "${dir}/${original}" "$(k_fs_resolve "${parent}${link1}/${link2}")"
	assertEquals "Relative-location Symlink resolves" "${dir}/${original}" "$(k_fs_resolve "${dir}/${link3}")"
	assertEquals "Traversing Symlink resolves dir" "${dir}" "$(k_fs_resolve "${dir}/${link4}")"
	assertEquals "Traversing Symlink resolves file" "${dir}/${original}" "$(k_fs_resolve "${dir}/${link4}/${original}")"
	assertEquals "Dir resolves to self" "${dir}" "$(k_fs_resolve "${dir}")"

	rm -rf "${dir}"

	nonExPath='/foo/bar/baz/fbz.file'
	nonExRelPath="bar/baz/fbz.file"
	nonExPathTraversal="/foo/bar/baz2/../baz3/.././baz/./fbz.file"

	assertEquals 'Non-existent file path resolves to self' "$nonExPath" "$(k_fs_resolve "$nonExPath")"
	assertEquals 'Non-existent file path with trailing slash resolves to self' "$nonExPath" "$(k_fs_resolve "${nonExPath}/")"
	assertEquals 'Non-existent relative path resolves to file' "${PWD}/$nonExRelPath" "$(k_fs_resolve "$nonExRelPath")"
	assertEquals 'Non-existent relative path with trailing slash resolves to file' "${PWD}/$nonExRelPath" "$(k_fs_resolve "${nonExRelPath}/")"
	assertEquals 'Non-existent path with traversal resolves to file' "$nonExPath" "$(k_fs_resolve "$nonExPathTraversal")"
	assertEquals 'Non-existent path with trailing slash and traversal resolves to file' "$nonExPath" "$(k_fs_resolve "${nonExPathTraversal}/")"
}

test_k_fs_predictable_dir (){
	# shellcheck disable=SC2039
	local dir message status

	dir="$(k_fs_predictable_dir)"
	[ -d "${dir}" ]
	assertTrue "Predictable Dir is a dir" $?

	[ -w "${dir}" ]
	assertTrue "Predictable Dir is writable" $?

	assertEquals "Predictable Dir is predictable" "${dir}" "$(k_fs_predictable_dir)"

	[ -d "${dir}" ] && rmdir "${dir}"

	KOALEPHANT_TMP_USE_MEM=true

	dir="$(k_fs_predictable_dir)"
	[ -d "${dir}" ]
	assertTrue "Predictable Dir is a dir" $?

	[ -w "${dir}" ]
	assertTrue "Predictable Dir is writable" $?

	assertEquals "Predictable Dir is predictable" "${dir}" "$(k_fs_predictable_dir)"

	[ -d "${dir}" ] && rmdir "${dir}"

	KOALEPHANT_TMP_REQ_MEM=true
	if [ "$(uname -s)" != 'Linux' ]; then
		message="$(k_fs_predictable_dir 2>&1 1>/dev/null)" && status="$?" || status="$?"
		assertFalse 'Return is error when no tmp fs is available' "$status"
		assertEquals 'Error message is shown when no tmp fs is available' 'No writable memory filesystem found for temp' "$message"
		startSkipping
	fi

	dir="$(k_fs_predictable_dir 2>/dev/null)"
	[ -d "${dir}" ]
	assertTrue "Predictable Dir is a dir" $?

	[ -w "${dir}" ]
	assertTrue "Predictable Dir is writable" $?

	assertEquals "Predictable Dir is predictable" "${dir}" "$(k_fs_predictable_dir 2>/dev/null)"

	df -t swap -t tmpfs --output=target "${dir}" > /dev/null 2>&1
	assertTrue 'Predictable Dir is stored in memory' $?

	[ -d "${dir}" ] && rmdir "${dir}"

	unset KOALEPHANT_TMP_USE_MEM KOALEPHANT_TMP_REQ_MEM
}

test_k_fs_predictable_file (){
	# shellcheck disable=SC2039
	local file message status

	file="$(k_fs_predictable_file)"
	k_log_debug 'test_k_fs_predictable_file file is "%s"' "${file}"
	[ -f "${file}" ]
	assertTrue "Predictable File is a file '${file}'" $?

	[ -w "${file}" ]
	assertTrue "Predictable File is writable" $?

	assertEquals "Predictable File is predictable" "${file}" "$(k_fs_predictable_file)"
	[ -f "$file" ] && rm -f "${file}"

	KOALEPHANT_TMP_USE_MEM=true

	file="$(k_fs_predictable_file)"
	k_log_debug 'test_k_fs_predictable_file file is "%s"' "${file}"
	[ -f "${file}" ]
	assertTrue "Predictable File is a file '${file}'" $?

	[ -w "${file}" ]
	assertTrue "Predictable File is writable" $?

	assertEquals "Predictable File is predictable" "${file}" "$(k_fs_predictable_file)"
	[ -f "$file" ] && rm -f "${file}"

	KOALEPHANT_TMP_REQ_MEM=true
	if [ "$(uname -s)" != 'Linux' ]; then
		message="$(k_fs_predictable_file 2>&1 1>/dev/null)" && status="$?" || status="$?"
		assertFalse 'Return is error when no tmp fs is available' "$status"
		assertEquals 'Error message is shown when no tmp fs is available' 'No writable memory filesystem found for temp' "$message"
		startSkipping
	fi

	file="$(k_fs_predictable_file 2>/dev/null)"
	k_log_debug 'test_k_fs_predictable_file file is "%s"' "${file}"
	[ -f "${file}" ]
	assertTrue "Predictable File is a file '${file}'" $?

	[ -w "${file}" ]
	assertTrue "Predictable File is writable" $?

	assertEquals "Predictable File is predictable" "${file}" "$(k_fs_predictable_file 2>/dev/null)"

	df -t swap -t tmpfs --output=target "${file}" > /dev/null 2>&1
	assertTrue 'Predictable File is stored in memory' $?

	[ -f "$file" ] && rm -f "${file}"

	unset KOALEPHANT_TMP_USE_MEM KOALEPHANT_TMP_REQ_MEM
}

test_k_fs_register_temp_file (){
	k_fs_register_temp_file "tmp-foo-barbaz.check"

	file="$(dirname "$(mktemp -u)")/k-fs-temp-files.$$"

	matching="$(sed -n -e '/tmp-foo-barbaz.check/p' "${file}")"
	assertEquals "String is registered as-is" 'tmp-foo-barbaz.check' "${matching}"
}

test_k_fs_temp_dir (){
	# shellcheck disable=SC2039
	local dir

	dir="$(k_fs_temp_dir)"

	[ -d "${dir}" ]
	assertTrue "Temp dir is created" $?

	# shellcheck disable=SC2012
	[ "$(ls -qAL -- "${dir}" | wc -l)" -eq 0 ]
	assertTrue "Temp dir is empty" $?

	[ -w "${dir}" ]
	assertTrue "Temp Dir is writable" $?

	k_fs_temp_dir > /dev/null
	assertTrue "Temp Dir return is success" $?

	[ -d "${dir}" ] && rmdir "${dir}"

	KOALEPHANT_TMP_USE_MEM=true

	dir="$(k_fs_temp_dir)"

	[ -d "${dir}" ]
	assertTrue "Temp dir is created" $?

	# shellcheck disable=SC2012
	[ "$(ls -qAL -- "${dir}" | wc -l)" -eq 0 ]
	assertTrue "Temp dir is empty" $?

	[ -w "${dir}" ]
	assertTrue "Temp Dir is writable" $?

	k_fs_temp_dir > /dev/null
	assertTrue "Temp Dir return is success" $?

	[ -d "${dir}" ] && rmdir "${dir}"

	if [ "$(uname -s)" != 'Linux' ]; then
		startSkipping
	fi

	KOALEPHANT_TMP_REQ_MEM=true
	if [ "$(uname -s)" != 'Linux' ]; then
		message="$(k_fs_predictable_dir 2>&1 1>/dev/null)" && status="$?" || status="$?"
		assertFalse 'Return is error when no tmp fs is available' "$status"
		assertEquals 'Error message is shown when no tmp fs is available' 'No writable memory filesystem found for temp' "$message"
		startSkipping
	fi


	dir="$(k_fs_temp_dir 2>/dev/null)"

	[ -d "${dir}" ]
	assertTrue "Temp dir is created" $?

	# shellcheck disable=SC2012
	[ "$(ls -qAL -- "${dir}" 2>/dev/null | wc -l)" -eq 0 ]
	assertTrue "Temp dir is empty" $?

	[ -w "${dir}" ]
	assertTrue "Temp Dir is writable" $?

	k_fs_temp_dir > /dev/null 2>&1
	assertTrue "Temp Dir return is success" $?

	df -t swap -t tmpfs --output=target "${dir}" > /dev/null 2>&1
	assertTrue 'Temp Dir is stored in memory' $?

	[ -d "${dir}" ] && rmdir "${dir}"

	unset KOALEPHANT_TMP_USE_MEM KOALEPHANT_TMP_REQ_MEM

}

test_k_fs_temp_file (){
	# shellcheck disable=SC2039
	local file

	file="$(k_fs_temp_file)"

	[ -f "${file}" ]
	assertTrue "Temp file is created" $?

	[ -f "${file}" ] && [ ! -s "${file}" ]
	assertTrue "Temp file is 0 bytes" $?

	[ -w "${file}" ]
	assertTrue "Temp file is writable" $?

	k_fs_temp_file > /dev/null
	assertTrue "Temp File return is success" $?

	[ -f "$file" ] && rm -f "${file}"

	KOALEPHANT_TMP_USE_MEM=true

	file="$(k_fs_temp_file)"

	[ -f "${file}" ]
	assertTrue "Temp file is created" $?

	[ -f "${file}" ] && [ ! -s "${file}" ]
	assertTrue "Temp file is 0 bytes" $?

	[ -w "${file}" ]
	assertTrue "Temp file is writable" $?

	k_fs_temp_file > /dev/null
	assertTrue "Temp File return is success" $?

	[ -f "$file" ] && rm -f "${file}"

	if [ "$(uname -s)" != 'Linux' ]; then
		startSkipping
	fi

	KOALEPHANT_TMP_REQ_MEM=true

	if [ "$(uname -s)" != 'Linux' ]; then
		message="$(k_fs_temp_file 2>&1 1>/dev/null)" && status="$?" || status="$?"
		assertFalse 'Return is error when no tmp fs is available' "$status"
		assertEquals 'Error message is shown when no tmp fs is available' 'No writable memory filesystem found for temp' "$message"
		startSkipping
	fi

	file="$(k_fs_temp_file 2>/dev/null)"

	[ -f "${file}" ]
	assertTrue "Temp file is created" $?

	[ -f "${file}" ] && [ ! -s "${file}" ]
	assertTrue "Temp file is 0 bytes" $?

	[ -w "${file}" ]
	assertTrue "Temp file is writable" $?

	k_fs_temp_file > /dev/null 2>&1
	assertTrue "Temp File return is success" $?

	df -t swap -t tmpfs --output=target "${file}" > /dev/null 2>&1
	assertTrue 'Temp File is stored in memory' $?

	[ -f "$file" ] && rm -f "${file}"
	unset KOALEPHANT_TMP_USE_MEM KOALEPHANT_TMP_REQ_MEM

}

test_k_fs_temp_cleanup (){
	# shellcheck disable=SC2039
	local filesTempFile
	k_fs_temp_file > /dev/null
	k_fs_temp_dir > /dev/null

	filesTempFile="/tmp/kss-fs-test.$$.tmp"
	cat "$(k_fs_predictable_file "${K_FS_TEMP_FILES_FILENAME}")" > "${filesTempFile}"
	k_fs_temp_cleanup

	while read -r file; do
		[ ! -e "${file}" ]
		assertTrue "File '${file}' is removed" $?
	done < "${filesTempFile}"

	rm -f "${filesTempFile}"
}

trap_signal_test() {
	# shellcheck disable=SC2039
	local files="" dirs="" file i

	# shellcheck disable=SC2034
	for i in 1 2 3 4 5 6; do
		files="${files} $(mktemp)"
		dirs="${dirs} $(mktemp -d)"
	done

	for file in ${files}; do
		if [ ! -f "${file}" ]; then
			printf -- 'Temp file does not exist: "%s"\n' "${file}"
			exit 1
		fi
	done

	for dir in ${dirs}; do
		if [ ! -d "${dir}" ]; then
			printf -- 'Temp dir does not exist: "%s"\n' "${dir}"
			exit 1
		fi
	done

	# shellcheck disable=SC2086
	sh -eu ./fs-cleanup-signals.sh "$@" ${files} ${dirs}
	assertEquals "Return code matches" "$3" $?

	for file in ${files}; do
		[ ! -f "${file}" ]
		assertTrue "Temp file does not exist: ${file}" $?
	done

	for dir in ${dirs}; do
		[ ! -d "${dir}" ]
		assertTrue "Temp dir does not exist: ${dir}" $?
	done
}

test_k_fs_temp_exit (){
	trap_signal_test exit INT 0
	trap_signal_test exit TERM 0
	trap_signal_test exit QUIT 0
	trap_signal_test exit HUP 0
	trap_signal_test exit INT 1
	trap_signal_test exit TERM 1
	trap_signal_test exit QUIT 1
	trap_signal_test exit HUP 1
	trap_signal_test exit INT 2
	trap_signal_test exit TERM 2
	trap_signal_test exit QUIT 2
	trap_signal_test exit HUP 2

}

test_k_fs_temp_abort (){
	trap_signal_test abort ABRT 0
}

test_k_fs_perms_useronly (){
	# shellcheck disable=SC2039
	local uid gid file1="/tmp/perms.file1.$$" file1Result python
	python="$(command -v python || command -v python2 || command -v python3)"
	uid="$(id -u)"
	gid="$(id -g)"

	(umask 0000; touch "${file1}")
	k_fs_perms_useronly "${file1}"
	file1Result="$("${python}" perms.py "${file1}")"
	assertEquals "Owner is correct" "${uid}" "$(printf -- '%s' "${file1Result}" | cut -d ' ' -f 2)"
	assertEquals "Group is correct" "${gid}" "$(printf -- '%s' "${file1Result}" | cut -d ' ' -f 3)"
	assertEquals "Perms are correct" "0600" "$(printf -- '%s' "${file1Result}" | cut -d ' ' -f 1)"

	rm -f "${file1}"
}


test_k_fs_dir_empty (){
	# shellcheck disable=SC2039
	local dir

	dir="$(mktemp -d)"

	k_fs_dir_empty "${dir}"
	assertTrue 'Directory is empty' $?

	touch "${dir}/file1"
	k_fs_dir_empty "${dir}"
	assertFalse 'Directory is not empty' $?
}

worker_k_fs_temp_get_raw() {
	# shellcheck disable=SC2039
	local file dir parent

	file="$(k_fs_temp_get_raw file)"
	assertTrue 'File mode returns success' $?
	[ -f "${file}" ]
	assertTrue 'File mode creates a file' $?

	dir="$(k_fs_temp_get_raw dir)"
	assertTrue 'Dir mode returns success' $?
	[ -d "${dir}" ]
	assertTrue 'Dir mode creates a dir' $?

	assertNotEquals 'Dir mode returns a name without trailing slash' '' "${dir##*/}"


	parent="$(k_fs_temp_get_raw parent)"
	assertTrue 'Parent mode returns success' $?
	[ -d "${parent}" ]
	assertTrue 'Parent mode creates a dir' $?
	assertEquals 'Parent Dir of file is parent' "${parent}" "$(dirname "${file}")"
	assertEquals 'Parent Dir of Dir is parent' "${parent}" "$(dirname "${dir}")"
	assertNotEquals 'Parent mode returns a name without trailing slash' '' "${parent##*/}"
}

test_k_fs_temp_get_raw() {
	worker_k_fs_temp_get_raw
}

test_k_fs_temp_get_raw_fallback() {
	command() {
			if [ "$2" = 'mktemp' ]; then
				return 1
			fi
			(
				unset -f command
				command "$@"
			)
			return $?
	}
	worker_k_fs_temp_get_raw
	unset -f command
}
