#!/bin/sh -eu

. ../base.lib.sh
. ../config.lib.sh
. ../bool.lib.sh
. ../number.lib.sh
. ../string.lib.sh
. ../fs.lib.sh

config_file1="./test-conf.conf"
config_file2="./test-conf2.conf"

worker_k_config_sections() {
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section Names" "$(printf -- 'section\nsection2\nSection3')" "$(k_config_sections "${config_file1}")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section Names under [section2]" "bar" "$(k_config_sections "${config_file1}" "section2")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section Names under [section3]" "" "$(k_config_sections "${config_file1}" "section3")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section Names under [Section3]" "$(printf -- 'sec3\nSec3')" "$(k_config_sections "${config_file1}" "Section3")"

	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 Section Names" "$(printf -- 'first\nsection\nsection2')" "$(k_config_sections "${config_file2}")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 Section Names under [section2]" "bar" "$(k_config_sections "${config_file2}" "section2")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 Section Names under [section3]" "" "$(k_config_sections "${config_file2}" "section3")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 Section Names under [first]" "" "$(k_config_sections "${config_file2}" "first")"

	k_config_sections "${config_file1}" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 Section Names" $?
	k_config_sections "${config_file1}" "section2" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 Section Names under [section2]" $?
	k_config_sections "${config_file1}" "section3" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 Section Names under [section3]" $?

	k_config_sections "${config_file2}" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 Section Names" $?
	k_config_sections "${config_file2}" "section2" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 Section Names under [section2]" $?
	k_config_sections "${config_file2}" "section3" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 Section Names under [section3]" $?
	k_config_sections "${config_file2}" "first" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 Section Names under [first]" $?
}

test_k_config_sections() {
	unset KOALEPHANT_CONFIG_MODULE
	worker_k_config_sections
}

test_k_config_sections_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	worker_k_config_sections
}

test_k_config_sections_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	worker_k_config_sections
}

test_k_config_sections_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	worker_k_config_sections
}

test_k_config_sections_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	worker_k_config_sections
}

worker_k_config_keys() {
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Key Names" "$(printf -- 'key\nkey2\nkey3\nkey4\nsection/foo\nsection/fooTrue\nsection2/bar/foo\nsection2/baz\nsection2/bazOff\nSection3/sec3/Off\nSection3/Sec3/On\nSection3/Sec3/Empty')" "$(k_config_keys "${config_file1}")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Key Names under [section2]" "$(printf -- 'bar/foo\nbaz\nbazOff')" "$(k_config_keys "${config_file1}" "section2")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Key Names under [section3]" "" "$(k_config_keys "${config_file1}" "section3")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Key Names under [Section3]" "$(printf -- 'sec3/Off\nSec3/On\nSec3/Empty')" "$(k_config_keys "${config_file1}" "Section3")"

	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 Key Names" "$(printf -- 'first/key\nfirst/key2\nsection/foo\nsection2/bar/foo\nsection2/baz')" "$(k_config_keys "${config_file2}")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 Key Names under [section2]" "$(printf -- 'bar/foo\nbaz')" "$(k_config_keys "${config_file2}" "section2")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 Key Names under [section3]" "" "$(k_config_keys "${config_file2}" "section3")"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 Key Names under [first]" "$(printf -- 'key\nkey2')" "$(k_config_keys "${config_file2}" "first")"

	k_config_keys "${config_file1}" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 Key Names" $?
	k_config_keys "${config_file1}" "section2" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 Key Names under [section2]" $?
	k_config_keys "${config_file1}" "section3" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 Section Names under [section3]" $?

	k_config_keys "${config_file2}" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 Key Names" $?
	k_config_keys "${config_file2}" "section2" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 Key Names under [section2]" $?
	k_config_keys "${config_file2}" "section3" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 Key Names under [section3]" $?
	k_config_keys "${config_file2}" "first" > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 Key Names under [first]" $?
}

test_k_config_keys() {
	unset KOALEPHANT_CONFIG_MODULE
	worker_k_config_keys
}

test_k_config_keys_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	worker_k_config_keys
}

test_k_config_keys_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	worker_k_config_keys
}

test_k_config_keys_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	worker_k_config_keys
}

test_k_config_keys_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	worker_k_config_keys
}

worker_k_config_read() {
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key value" "keyVal" "$(k_config_read "${config_file1}" key)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key2 value" "key2Val" "$(k_config_read "${config_file1}" key2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key3 value" "true" "$(k_config_read "${config_file1}" key3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key4 value" "False" "$(k_config_read "${config_file1}" key4)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" "fooVal" "$(k_config_read "${config_file1}" foo section)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" "fooVal" "$(k_config_read "${config_file1}" section/foo)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/fooTrue value" "On" "$(k_config_read "${config_file1}" fooTrue section)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/fooTrue value" "On" "$(k_config_read "${config_file1}" section/fooTrue)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" "bazVal" "$(k_config_read "${config_file1}" baz section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" "bazVal" "$(k_config_read "${config_file1}" section2/baz)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bazOff value" "No" "$(k_config_read "${config_file1}" bazOff section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bazOff value" "No" "$(k_config_read "${config_file1}" section2/bazOff)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read "${config_file1}" foo section2/bar)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read "${config_file1}" bar/foo section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read "${config_file1}" section2/bar/foo)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section3/nonexistent value" "" "$(k_config_read "${config_file1}" nonexistent section3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section3/sec3/Off value" "0" "$(k_config_read "${config_file1}" Off Section3/sec3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section3/sec3/Off value" "0" "$(k_config_read "${config_file1}" sec3/Off Section3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section3/sec3/Off value" "0" "$(k_config_read "${config_file1}" Section3/sec3/Off)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section3/Sec3/On value" "1" "$(k_config_read "${config_file1}" On Section3/Sec3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section3/Sec3/On value" "1" "$(k_config_read "${config_file1}" Sec3/On Section3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section3/Sec3/On value" "1" "$(k_config_read "${config_file1}" Section3/Sec3/On)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section3/Sec3/Empty value" "" "$(k_config_read "${config_file1}" Empty Section3/Sec3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section3/Sec3/Empty value" "" "$(k_config_read "${config_file1}" Sec3/Empty Section3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 Section3/Sec3/Empty value" "" "$(k_config_read "${config_file1}" Section3/Sec3/Empty)"

	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key value" "" "$(k_config_read "${config_file2}" key)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" "" "$(k_config_read "${config_file2}" key2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key value" "keyVal" "$(k_config_read "${config_file2}" key first)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" "key2Val" "$(k_config_read "${config_file2}" key2 first)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key value" "keyVal" "$(k_config_read "${config_file2}" first/key)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" "key2Val" "$(k_config_read "${config_file2}" first/key2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo value" "fooVal" "$(k_config_read "${config_file2}" foo section)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo value" "fooVal" "$(k_config_read "${config_file2}" section/foo)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz value" "bazVal" "$(k_config_read "${config_file2}" baz section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz value" "bazVal" "$(k_config_read "${config_file2}" section2/baz)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" "barFooVal" "$(k_config_read "${config_file2}" foo section2/bar)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" "barFooVal" "$(k_config_read "${config_file2}" bar/foo section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" "barFooVal" "$(k_config_read "${config_file2}" section2/bar/foo)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section3/nonexistent value" "" "$(k_config_read "${config_file2}" nonexistent section3)"

	k_config_read "${config_file1}" key > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key value" $?
	k_config_read "${config_file1}" key2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key2 value" $?
	k_config_read "${config_file1}" foo section > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" $?
	k_config_read "${config_file1}" section/foo > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" $?
	k_config_read "${config_file1}" baz section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" $?
	k_config_read "${config_file1}" section2/baz > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" $?
	k_config_read "${config_file1}" foo section2/bar > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" $?
	k_config_read "${config_file1}" bar/foo section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" $?
	k_config_read "${config_file1}" section2/bar/foo > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" $?
	k_config_read "${config_file1}" nonexistent section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section3/nonexistent value" $?

	k_config_read "${config_file2}" key > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key value" $?
	k_config_read "${config_file2}" key2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" $?
	k_config_read "${config_file2}" key first > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key value" $?
	k_config_read "${config_file2}" key2 first > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" $?
	k_config_read "${config_file2}" first/key > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key value" $?
	k_config_read "${config_file2}" first/key2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" $?
	k_config_read "${config_file2}" foo section > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo value" $?
	k_config_read "${config_file2}" section/foo > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo value" $?
	k_config_read "${config_file2}" baz section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz value" $?
	k_config_read "${config_file2}" section2/baz > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz value" $?
	k_config_read "${config_file2}" foo section2/bar > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" $?
	k_config_read "${config_file2}" bar/foo section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" $?
	k_config_read "${config_file2}" section2/bar/foo > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" $?
	k_config_read "${config_file2}" nonexistent section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section3/nonexistent value" $?

}

test_k_config_read() {
	unset KOALEPHANT_CONFIG_MODULE
	worker_k_config_read
}

test_k_config_read_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	worker_k_config_read
}

test_k_config_read_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	worker_k_config_read
}

test_k_config_read_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	worker_k_config_read
}

test_k_config_read_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	worker_k_config_read
}

worker_k_config_read_error() {
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key value" "keyVal" "$(k_config_read_error "${config_file1}" key)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key2 value" "key2Val" "$(k_config_read_error "${config_file1}" key2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" "fooVal" "$(k_config_read_error "${config_file1}" foo section)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" "fooVal" "$(k_config_read_error "${config_file1}" section/foo)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" "bazVal" "$(k_config_read_error "${config_file1}" baz section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" "bazVal" "$(k_config_read_error "${config_file1}" section2/baz)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read_error "${config_file1}" foo section2/bar)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read_error "${config_file1}" bar/foo section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read_error "${config_file1}" section2/bar/foo)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section3/nonexistent value" "" "$(k_config_keys "${config_file1}" nonexistent section3)"

	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key value" "" "$(k_config_read_error "${config_file2}" key)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" "" "$(k_config_read_error "${config_file2}" key2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key value" "keyVal" "$(k_config_read_error "${config_file2}" key first)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" "key2Val" "$(k_config_read_error "${config_file2}" key2 first)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key value" "keyVal" "$(k_config_read_error "${config_file2}" first/key)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" "key2Val" "$(k_config_read_error "${config_file2}" first/key2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo value" "fooVal" "$(k_config_read_error "${config_file2}" foo section)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo value" "fooVal" "$(k_config_read_error "${config_file2}" section/foo)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz value" "bazVal" "$(k_config_read_error "${config_file2}" baz section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz value" "bazVal" "$(k_config_read_error "${config_file2}" section2/baz)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" "barFooVal" "$(k_config_read_error "${config_file2}" foo section2/bar)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" "barFooVal" "$(k_config_read_error "${config_file2}" bar/foo section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" "barFooVal" "$(k_config_read_error "${config_file2}" section2/bar/foo)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section3/nonexistent value" "" "$(k_config_read_error "${config_file2}" nonexistent section3)"

	k_config_read_error "${config_file1}" key > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key return code" $?
	k_config_read_error "${config_file1}" key2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key2 return code" $?
	k_config_read_error "${config_file1}" foo section > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo return code" $?
	k_config_read_error "${config_file1}" section/foo > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo return code" $?
	k_config_read_error "${config_file1}" baz section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz return code" $?
	k_config_read_error "${config_file1}" section2/baz > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz return code" $?
	k_config_read_error "${config_file1}" foo section2/bar > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo return code" $?
	k_config_read_error "${config_file1}" bar/foo section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo return code" $?
	k_config_read_error "${config_file1}" section2/bar/foo > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo return code" $?
	k_config_read_error "${config_file1}" nonexistent section3 > /dev/null
	assertFalse "${KOALEPHANT_CONFIG_MODULE}: File1 section3/nonexistent return code" $?

	k_config_read_error "${config_file2}" key > /dev/null
	assertFalse "${KOALEPHANT_CONFIG_MODULE}: File2 key return code" $?
	k_config_read_error "${config_file2}" key2 > /dev/null
	assertFalse "${KOALEPHANT_CONFIG_MODULE}: File2 key2 return code" $?
	k_config_read_error "${config_file2}" key first > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key return code" $?
	k_config_read_error "${config_file2}" key2 first > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key2 return code" $?
	k_config_read_error "${config_file2}" first/key > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key return code" $?
	k_config_read_error "${config_file2}" first/key2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key2 return code" $?
	k_config_read_error "${config_file2}" foo section > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo return code" $?
	k_config_read_error "${config_file2}" section/foo > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo return code" $?
	k_config_read_error "${config_file2}" baz section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz return code" $?
	k_config_read_error "${config_file2}" section2/baz > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz return code" $?
	k_config_read_error "${config_file2}" foo section2/bar > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo return code" $?
	k_config_read_error "${config_file2}" bar/foo section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo return code" $?
	k_config_read_error "${config_file2}" section2/bar/foo > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo return code" $?
	k_config_read_error "${config_file2}" nonexistent section3 > /dev/null
	assertFalse "${KOALEPHANT_CONFIG_MODULE}: File2 section3/nonexistent returncode" $?

}

test_k_config_read_error() {
	unset KOALEPHANT_CONFIG_MODULE
	worker_k_config_read_error
}

test_k_config_read_error_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	worker_k_config_read_error
}

test_k_config_read_error_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	worker_k_config_read_error
}

test_k_config_read_error_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	worker_k_config_read_error
}

test_k_config_read_error_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	worker_k_config_read_error
}

worker_k_config_read_string() {
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key value" "keyVal" "$(k_config_read_string "${config_file1}" key keyDefault)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key2 value" "key2Val" "$(k_config_read_string "${config_file1}" key2 key2Default)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" "fooVal" "$(k_config_read_string "${config_file1}" foo fooDefault section)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" "fooVal" "$(k_config_read_string "${config_file1}" section/foo fooDefault2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" "bazVal" "$(k_config_read_string "${config_file1}" baz bazDefault section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" "bazVal" "$(k_config_read_string "${config_file1}" section2/baz bazDefault2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read_string "${config_file1}" foo barFooDefault section2/bar)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read_string "${config_file1}" bar/foo barFooDefault2 section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read_string "${config_file1}" section2/bar/foo barFooDefault3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section3/nonexistent value" "nonexistentDefault" "$(k_config_read_string "${config_file1}" nonexistent nonexistentDefault section3)"

	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key value" "keyDefault" "$(k_config_read_string "${config_file2}" key keyDefault)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" "key2Default" "$(k_config_read_string "${config_file2}" key2 key2Default)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key value" "keyVal" "$(k_config_read_string "${config_file2}" key firstKeyDefault first)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" "key2Val" "$(k_config_read_string "${config_file2}" key2 firstKeyDefault2 first)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key value" "keyVal" "$(k_config_read_string "${config_file2}" first/key firstKeyDefault3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 key2 value" "key2Val" "$(k_config_read_string "${config_file2}" first/key2 firstKey2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo value" "fooVal" "$(k_config_read_string "${config_file2}" foo fooDefault section)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo value" "fooVal" "$(k_config_read_string "${config_file2}" section/foo fooDefault2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz value" "bazVal" "$(k_config_read_string "${config_file2}" baz bazDefault section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz value" "bazVal" "$(k_config_read_string "${config_file2}" section2/baz bazDefault2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" "barFooVal" "$(k_config_read_string "${config_file2}" foo fooDefault section2/bar)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" "barFooVal" "$(k_config_read_string "${config_file2}" bar/foo fooDefault2 section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo value" "barFooVal" "$(k_config_read_string "${config_file2}" section2/bar/foo fooDefault3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File2 section3/nonexistent value" "nonexistentDefault" "$(k_config_read_string "${config_file2}" nonexistent nonexistentDefault section3)"

	k_config_read_string "${config_file1}" key keyDefault > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key return code" $?
	k_config_read_string "${config_file1}" key2 key2Default > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key2 return code" $?
	k_config_read_string "${config_file1}" foo fooDefault section > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo return code" $?
	k_config_read_string "${config_file1}" section/foo fooDefault2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo return code" $?
	k_config_read_string "${config_file1}" baz bazDefault section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz return code" $?
	k_config_read_string "${config_file1}" section2/baz bazDefault2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz return code" $?
	k_config_read_string "${config_file1}" foo barFooDefault section2/bar > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo return code" $?
	k_config_read_string "${config_file1}" bar/foo barFooDefault2 section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo return code" $?
	k_config_read_string "${config_file1}" section2/bar/foo barFooDefault3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo return code" $?
	k_config_read_string "${config_file1}" nonexistent nonexistentDefault section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section3/nonexistent return code" $?

	k_config_read_string "${config_file2}" key keyDefault > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key return code" $?
	k_config_read_string "${config_file2}" key2 key2Default > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key2 return code" $?
	k_config_read_string "${config_file2}" key firstKeyDefault first > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key return code" $?
	k_config_read_string "${config_file2}" key2 firstKeyDefault2 first > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key2 return code" $?
	k_config_read_string "${config_file2}" first/key firstKeyDefault3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key return code" $?
	k_config_read_string "${config_file2}" first/key2 firstKey2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 key2 return code" $?
	k_config_read_string "${config_file2}" foo fooDefault section > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo return code" $?
	k_config_read_string "${config_file2}" section/foo fooDefault2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section/foo return code" $?
	k_config_read_string "${config_file2}" baz bazDefault section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz return code" $?
	k_config_read_string "${config_file2}" section2/baz bazDefault2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/baz return code" $?
	k_config_read_string "${config_file2}" foo fooDefault section2/bar > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo return code" $?
	k_config_read_string "${config_file2}" bar/foo fooDefault2 section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo return code" $?
	k_config_read_string "${config_file2}" section2/bar/foo fooDefault3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section2/bar/foo return code" $?
	k_config_read_string "${config_file2}" nonexistent nonexistentDefault section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 section3/nonexistent return code" $?
}

test_k_config_read_string() {
	unset KOALEPHANT_CONFIG_MODULE
	worker_k_config_read_string
}

test_k_config_read_string_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	worker_k_config_read_string
}

test_k_config_read_string_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	worker_k_config_read_string
}

test_k_config_read_string_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	worker_k_config_read_string
}

test_k_config_read_string_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	worker_k_config_read_string
}

worker_k_config_read_bool() {
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key3 bool value" "true" "$(k_config_read_bool "${config_file1}" key3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key4 bool value" "false" "$(k_config_read_bool "${config_file1}" key4)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 fooTrue bool value" "true" "$(k_config_read_bool "${config_file1}" fooTrue '' section)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 bazOff bool value" "false" "$(k_config_read_bool "${config_file1}" bazOff '' section2)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 sec3Off bool value" "false" "$(k_config_read_bool "${config_file1}" sec3/Off '' Section3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 sec3On bool value" "true" "$(k_config_read_bool "${config_file1}" Sec3/On '' Section3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 sec3Empty bool value" "true" "$(k_config_read_bool "${config_file1}" Sec3/Empty On Section3)"
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 sec3Empty bool value" "false" "$(k_config_read_bool "${config_file1}" Sec3/Empty Off Section3)"

	k_config_read_bool "${config_file1}" key3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key3 bool value" $?
	k_config_read_bool "${config_file1}" key4 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key4 bool value" $?
	k_config_read_bool "${config_file1}" fooTrue '' section > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 fooTrue bool value" $?
	k_config_read_bool "${config_file1}" bazOff '' section2 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 bazOff bool value" $?
	k_config_read_bool "${config_file1}" sec3/Off '' Section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 sec3Off bool value" $?
	k_config_read_bool "${config_file1}" Sec3/On '' Section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 sec3On bool value" $?
	k_config_read_bool "${config_file1}" Sec3/Empty On Section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 sec3Empty bool value" $?
	k_config_read_bool "${config_file1}" Sec3/Empty Off Section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 sec3Empty bool value" $?
}

test_k_config_read_bool() {
	unset KOALEPHANT_CONFIG_MODULE
	worker_k_config_read_bool
}

test_k_config_read_bool_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	worker_k_config_read_bool
}

test_k_config_read_bool_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	worker_k_config_read_bool
}

test_k_config_read_bool_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	worker_k_config_read_bool
}

test_k_config_read_bool_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	worker_k_config_read_bool
}

worker_k_config_test_bool() {
	k_config_test_bool "${config_file1}" key3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key3 bool value" $?
	k_config_test_bool "${config_file1}" key4 > /dev/null
	assertFalse "${KOALEPHANT_CONFIG_MODULE}: File1 key4 bool value" $?
	k_config_test_bool "${config_file1}" fooTrue '' section > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 fooTrue bool value" $?
	k_config_test_bool "${config_file1}" bazOff '' section2 > /dev/null
	assertFalse "${KOALEPHANT_CONFIG_MODULE}: File1 bazOff bool value" $?
	k_config_test_bool "${config_file1}" sec3/Off '' Section3 > /dev/null
	assertFalse "${KOALEPHANT_CONFIG_MODULE}: File1 sec3Off bool value" $?
	k_config_test_bool "${config_file1}" Sec3/On '' Section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 sec3On bool value" $?
	k_config_test_bool "${config_file1}" Sec3/Empty On Section3 > /dev/null
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 sec3Empty bool value" $?
	k_config_test_bool "${config_file1}" Sec3/Empty Off Section3 > /dev/null
	assertFalse "${KOALEPHANT_CONFIG_MODULE}: File1 sec3Empty bool value" $?
}

test_k_config_test_bool() {
	unset KOALEPHANT_CONFIG_MODULE
	worker_k_config_test_bool
}

test_k_config_test_bool_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	worker_k_config_test_bool
}

test_k_config_test_bool_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	worker_k_config_test_bool
}

test_k_config_test_bool_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	worker_k_config_test_bool
}

test_k_config_test_bool_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	worker_k_config_test_bool
}

worker_k_config_test_read_keyword() {
	# shellcheck disable=SC2039
	local default=defaultKeyWord allKeywords="keyVal key2Val True FALSE fooVal On barFooVal bazVal No 0 1 ${default}"

	# shellcheck disable=SC2086
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key value" "keyVal" "$(k_config_read_keyword "${config_file1}" key '' '' ${allKeywords})"
	# shellcheck disable=SC2086
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key2 value" "key2Val" "$(k_config_read_keyword "${config_file1}" key2 '' '' ${allKeywords})"
	# shellcheck disable=SC2086
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key3 value" "defaultKeyWord" "$(k_config_read_keyword "${config_file1}" key3 "${default}" '' ${allKeywords})"
	# shellcheck disable=SC2086
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key4 value" "False" "$(k_config_read_keyword "${config_file1}" key4 'False' '' ${allKeywords})"
}

test_k_config_read_keyword() {
	unset KOALEPHANT_CONFIG_MODULE
	worker_k_config_test_read_keyword
}

test_k_config_test_read_keyword_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	worker_k_config_test_read_keyword
}

test_k_config_test_read_keyword_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	worker_k_config_test_read_keyword
}

test_k_config_test_read_keyword_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	worker_k_config_test_read_keyword
}

test_k_config_test_read_keyword_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	worker_k_config_test_read_keyword
}

test_k_config_command() {
	# shellcheck disable=SC2039
	local output

	[ -z "${KOALEPHANT_CFGET_PATH}" ] && startSkipping

	output="$(k_config_command "" --version 2>&1)"
	assertTrue 'Cfget returns success' $?
	assertEquals "Cfget version info" "$(${KOALEPHANT_CFGET_PATH} --version 2>&1)" "${output}"
}

test_k_config_file_check_readable() {
	# shellcheck disable=SC2039
	local readableFile unreadableFile

	KOALEPHANT_LOG_LEVEL_ACTIVE="${KOALEPHANT_LOG_LEVEL_ERR}"

	readableFile="$(mktemp)"
	unreadableFile="$(sudo mktemp)"

	k_config_file_check_readable "${readableFile}"
	assertTrue 'Readable file returns success' $?

	output="$(k_config_file_check_readable 2>&1 1> /dev/null)"
	assertFalse 'No file returns error' $?
	assertEquals 'No file outputs error message' 'No config file specified for reading' "${output}"

	output="$(k_config_file_check_readable "${unreadableFile}" 2>&1 1> /dev/null)"
	assertFalse 'Unreadable file returns error' $?
	assertEquals 'Unreadable file outputs error message' "$(printf -- 'Cannot open config file "%s" for reading' "${unreadableFile}")" "${output}"

	output="$(k_config_file_check_readable no-file-readable.file.txt 2>&1 1> /dev/null)"
	assertFalse 'Non-existent file returns error' $?
	assertEquals 'Non-existent file outputs error message' 'Cannot open config file "no-file-readable.file.txt" for reading' "${output}"
}

test_k_config_file_check_writable() {
	# shellcheck disable=SC2039
	local writableFile unwritableFile

	KOALEPHANT_LOG_LEVEL_ACTIVE="${KOALEPHANT_LOG_LEVEL_ERR}"

	writableFile="$(mktemp)"
	unwritableFile="$(sudo mktemp)"

	k_config_file_check_writable "${writableFile}"
	assertTrue 'Writable file returns success' $?

	k_config_file_check_writable no-file-writable.file.txt
	assertTrue 'Non-existent relative file returns success' $?

	rm -f no-file-writable.file.txt

	output="$(k_config_file_check_writable 2>&1 1> /dev/null)"
	assertFalse 'No file returns error' $?
	assertEquals 'No file outputs error message' 'No config file specified for writing' "${output}"

	output="$(k_config_file_check_writable "${unwritableFile}" 2>&1 1> /dev/null)"
	assertFalse 'Unwritable file returns error' $?
	assertEquals 'Unwritable file outputs error message' "$(printf -- 'Cannot open config file "%s" for writing' "${unwritableFile}")" "${output}"

	output="$(k_config_file_check_writable "/foo/${unwritableFile}" 2>&1 1> /dev/null)"
	assertFalse 'Unwritable non-existent file returns error' $?
	assertEquals 'Unwritable non-existent file outputs error message' "$(printf -- 'Cannot open config file "/foo/%s" for writing' "${unwritableFile}")" "${output}"
}

test_k_config_op() {
	KOALEPHANT_CONFIG_MODULE=''

	command() {
		case "$2" in
			(php|python|python3)
				return 1
			;;
		esac

		(
			unset -f command
			command "$@"
		)
		return $?
	}

	output="$(k_config_op 'whoami' '' 2>&1 1> /dev/null)"
	assertFalse 'Return is error when no config modules can run' $?
	assertEquals 'Output is error message when no config modules can run' 'No config module available' "${output}"

	unset -f command

	KOALEPHANT_CONFIG_MODULE='php-dba'
	output="$(k_config_op 'whoami' '')"
	assertTrue 'Return is success when php-dba config module can run' $?
	assertEquals 'Output is php-dba Version info' "$(php --version)" "${output}"

	KOALEPHANT_CONFIG_MODULE='php-ini'
	output="$(k_config_op 'whoami' '')"
	assertTrue 'Return is success when php-ini config module can run' $?
	assertEquals 'Output is php-ini Version info' "$(php --version)" "${output}"

	KOALEPHANT_CONFIG_MODULE='python2'
	output="$(k_config_op 'whoami' '')"
	assertTrue 'Return is success when Python2 config module can run' $?
	assertEquals 'Output is Python2 Version info' "$(python --version 2>&1)" "${output}"

	KOALEPHANT_CONFIG_MODULE='python3'
	output="$(k_config_op 'whoami' '')"
	assertTrue 'Return is success when Python3 config module can run' $?
	assertEquals 'Output is Python3 Version info' "$(python3 --version)" "${output}"
}

test_k_config_op_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	command() {
		if [ "$2" = 'php' ]; then
			return 1
		fi
		(
		unset -f command
		command "$@"
		)
		return $?
	}

	output="$(k_config_op_php_dba 'avail' '' 2>&1 1> /dev/null)"
	assertFalse 'Return is error when php-dba config module cannot run' $?
	unset -f command

	output="$(k_config_op_php_dba 'whoami' '')"
	assertTrue 'Return is success when php-dba config module can run' $?
	assertEquals 'Output is php-dba Version info' "$(php --version)" "${output}"
}

test_k_config_op_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	command() {
		if [ "$2" = 'php' ]; then
			return 1
		fi
		(
		unset -f command
		command "$@"
		)
		return $?
	}

	output="$(k_config_op_php_ini 'avail' '')"
	assertFalse 'Return is error when php-ini config module cannot run' $?

	unset -f command

	output="$(k_config_op_php_ini 'whoami' '')"
	assertTrue 'Return is success when php-dba config module can run' $?
	assertEquals 'Output is php-dba Version info' "$(php --version)" "${output}"
}

test_k_config_op_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	command() {
		if [ "$2" = 'python' ]; then
			return 1
		fi
		(
		unset -f command
		command "$@"
		)
		return $?
	}

	output="$(k_config_op_python2 'avail' '' 2>&1 1> /dev/null)"
	assertFalse 'Return is error when Python2 config module cannot run' $?

	unset -f command

	output="$(k_config_op_python2 'whoami' '')"
	assertTrue 'Return is success when Python2 config module can run' $?
	assertEquals 'Output is Python2 Version info' "$(python --version 2>&1)" "${output}"

}

test_k_config_op_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	command() {
		if [ "$2" = 'python3' ]; then
			return 1
		fi
		(
		unset -f command
		command "$@"
		)
		return $?
	}


	output="$(k_config_op_python3 'avail' '' 2>&1 1> /dev/null)"
	assertFalse 'Return is error when Python3 config module cannot run' $?

	unset -f command

	output="$(k_config_op_python3 'whoami' '')"
	assertTrue 'Return is success when Python3 config module can run' $?
	assertEquals 'Output is Python3 Version info' "$(python3 --version)" "${output}"
}

worker_k_config_write_error() {
	# shellcheck disable=SC2039
	local config_file1 config_file2 output=''
	config_file1="$(mktemp)"
	config_file2="$(mktemp)"
	rm -f "${config_file2}"

	k_config_write_error "${config_file1}" key keyVal
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key value" "keyVal" "$(k_config_read_error "${config_file1}" key)"
	k_config_write_error "${config_file1}" key2 key2Val
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 key2 value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 key2 value" "key2Val" "$(k_config_read_error "${config_file1}" key2)"
	k_config_write_error "${config_file1}" foo fooVal section
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo value" "fooVal" "$(k_config_read_error "${config_file1}" foo section)"
	k_config_write_error "${config_file1}" section/foo2 foo2Val
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo2 value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section/foo2 value" "foo2Val" "$(k_config_read_error "${config_file1}" section/foo2)"
	k_config_write_error "${config_file1}" baz bazVal section2
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz value" "bazVal" "$(k_config_read_error "${config_file1}" baz section2)"
	k_config_write_error "${config_file1}" section2/baz2 baz2Val
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz2 value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/baz2 value" "baz2Val" "$(k_config_read_error "${config_file1}" section2/baz2)"
	k_config_write_error "${config_file1}" foo barFooVal section2/bar
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo value" "barFooVal" "$(k_config_read_error "${config_file1}" foo section2/bar)"
	k_config_write_error "${config_file1}" bar/foo2 barFoo2Val section2
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo2 value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo2 value" "barFoo2Val" "$(k_config_read_error "${config_file1}" bar/foo2 section2)"
	k_config_write_error "${config_file1}" section2/bar/foo3 barFoo3Val
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo3 value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: File1 section2/bar/foo3 value" "barFoo3Val" "$(k_config_read_error "${config_file1}" section2/bar/foo3)"

	output="$(k_config_write_error '/foo/bar/baz.file' key keyVal 2>&1 1> /dev/null)"
	assertFalse "${KOALEPHANT_CONFIG_MODULE}: Non-Existent file key value" $?
	assertEquals "${KOALEPHANT_CONFIG_MODULE}: Non-Existent file error output" 'Cannot open config file "/foo/bar/baz.file" for writing' "${output}"

	k_config_write_error "${config_file2}" foo bar section
	assertTrue "${KOALEPHANT_CONFIG_MODULE}: File2 foo bar section" $?
}

test_k_config_write_error() {
	unset KOALEPHANT_CONFIG_MODULE
	worker_k_config_write_error
}

test_k_config_write_error_php_dba() {
	KOALEPHANT_CONFIG_MODULE=php-dba
	worker_k_config_write_error
}

test_k_config_write_error_php_ini() {
	KOALEPHANT_CONFIG_MODULE=php-ini
	#	worker_k_config_write_error
}

test_k_config_write_error_python2() {
	KOALEPHANT_CONFIG_MODULE=python2
	worker_k_config_write_error
}

test_k_config_write_error_python3() {
	KOALEPHANT_CONFIG_MODULE=python3
	worker_k_config_write_error
}

test_k_config_modules (){
	# shellcheck disable=SC2039
	local modules expected

	expected="$(printf '%s\n' php_dba php_ini python2 python3 | sort)"
	modules="$(k_config_modules)"
	assertTrue 'Listing config modules returns success' $?
	assertEquals 'Known config modules are loaded' "${expected}" "${modules}"
}
