#!/bin/sh

. ../base.lib.sh
. ../string.lib.sh
. ../bool.lib.sh
. ../number.lib.sh
. ../fs.lib.sh

debugMode() {
	k_bool_test "${DEBUG_TESTS:-}"
}

oneTimeSetUp() {
	if debugMode; then
		k_log_level "${KOALEPHANT_LOG_LEVEL_DEBUG}" >/dev/null
	fi

	mkdir -p ./tmp/
}

tearDown() {
	if debugMode; then
		rm -rfv ./tmp/*
	else
		rm -rf ./tmp/*
	fi
}

test_k_string_contains() {
	k_string_contains 1 241345
	assertTrue "241345 contains 1" $?

	k_string_contains a d3dabcd
	assertTrue "d3dabcd contains a" $?

	k_string_contains - --
	assertTrue "-- contains -" $?

	k_string_contains b acd
	assertFalse "acd does not contain b" $?
}
test_k_string_get_line() {
	# shellcheck disable=SC2039
	local str expected

	str="$(printf -- '%s\n' 'Hello world!' 'This is some text' 'And this is more' 'It gets even longer here.' 'And this one is a biggun too' | tee ./tmp/k_string_get_line.txt)"

	expected='Hello world!'
	assertEquals 'Getting line 1 from string' "$expected" "$(k_string_get_line 1 "${str}")"
	assertEquals 'Getting line 1 from stdin' "$expected" "$(k_string_get_line 1 < ./tmp/k_string_get_line.txt)"
	assertEquals 'Getting line 1 from explicit stdin' "$expected" "$(k_string_get_line 1 - < ./tmp/k_string_get_line.txt)"

	expected='This is some text'
	assertEquals 'Getting line 2 from string' "$expected" "$(k_string_get_line 2 "${str}")"
	assertEquals 'Getting line 2 from file' "$expected" "$(k_string_get_line 2 < ./tmp/k_string_get_line.txt)"
	assertEquals 'Getting line 2 from explicit stdin' "$expected" "$(k_string_get_line 2 - < ./tmp/k_string_get_line.txt)"

	expected='It gets even longer here.'
	assertEquals 'Getting line 4 from string' "$expected" "$(k_string_get_line 4 "${str}")"
	assertEquals 'Getting line 4 from stdin' "$expected" "$(k_string_get_line 4 < ./tmp/k_string_get_line.txt)"
	assertEquals 'Getting line 4 from explicit stdin' "$expected" "$(k_string_get_line 4 - < ./tmp/k_string_get_line.txt)"

	k_string_get_line 2>/dev/null
	assertFalse 'No arguments results in error' $?

	k_string_get_line a "${str}" 2>/dev/null
	assertFalse 'Get a non-numeric line results in error' $?
}

test_k_string_get_lines() {
	# shellcheck disable=SC2039
	local str expected

	str="$(printf -- '%s\n' 'Hello world!' 'This is some text' 'And this is more' 'It gets even longer here.' 'And this one is a biggun too' | tee ./tmp/test_k_string_get_lines.txt)"

	expected='Hello world!'
	assertEquals 'Getting line 1+1 from string' "$expected" "$(k_string_get_lines 1 1 "${str}")"
	assertEquals 'Getting line 1+1 from stdin' "$expected" "$(k_string_get_lines 1 1 < ./tmp/test_k_string_get_lines.txt)"
	assertEquals 'Getting line 1+1 from explicit stdin' "$expected" "$(k_string_get_lines 1 1 - <./tmp/test_k_string_get_lines.txt)"

	expected="$(printf -- '%s\n' 'Hello world!' 'This is some text')"
	assertEquals 'Getting line 1+2 from string' "$expected" "$(k_string_get_lines 1 2 "${str}")"
	assertEquals 'Getting line 1+2 from stdin' "$expected" "$(k_string_get_lines 1 2 < ./tmp/test_k_string_get_lines.txt)"
	assertEquals 'Getting line 1+2 from explicit stdin' "$expected" "$(k_string_get_lines 1 2 - < ./tmp/test_k_string_get_lines.txt)"

	expected="$(printf -- '%s\n' 'This is some text' 'And this is more' 'It gets even longer here.' 'And this one is a biggun too')"
	assertEquals 'Getting line 2+4 from string' "$expected" "$(k_string_get_lines 2 4 "${str}")"
	assertEquals 'Getting line 2+4 from stdin' "$expected" "$(k_string_get_lines 2 4 < ./tmp/test_k_string_get_lines.txt)"
	assertEquals 'Getting line 2+4 from explicit stdin' "$expected" "$(k_string_get_lines 2 4 - < ./tmp/test_k_string_get_lines.txt)"

	k_string_get_lines 2>/dev/null
	assertFalse 'No arguments results in error' $?

	k_string_get_lines 1 2>/dev/null
	assertFalse 'Less than 2 arguments results in error' $?

	k_string_get_lines a 1 "${str}" 2>/dev/null
	assertFalse 'Get a non-numeric start line results in error' $?

	k_string_get_lines 1 a "${str}" 2>/dev/null
	assertFalse 'Get a non-numeric line count results in error' $?
}


test_k_string_ends_with() {

	k_string_ends_with 5 12345
	assertTrue "12345 ends with 5" $?

	k_string_ends_with 6 12345
	assertFalse "12345 does not end with 6" $?

	k_string_ends_with d abcd
	assertTrue "abcd ends with d" $?


	k_string_ends_with - --
	assertTrue "-- ends with -" $?

	k_string_ends_with -- -
	assertFalse "- does not end with --" $?

	k_string_ends_with b abcd
	assertFalse "abcd does not end with b" $?
}
test_k_string_starts_with() {
	k_string_starts_with 1 12345
	assertTrue "12345 starts with 1" $?

	k_string_starts_with a abcd
	assertTrue "abcd starts with a" $?

	k_string_starts_with - --
	assertTrue "-- starts with -" $?

	k_string_starts_with -- -
	assertFalse "- does not start with --" $?

	k_string_starts_with b abcd
	assertFalse "abcd does not start with b" $?
}
test_k_string_lower() {
	assertEquals "ABC to lower" abc "$(k_string_lower ABC)"
	assertEquals "Abc to lower" abc "$(k_string_lower Abc)"
	assertEquals "123 to lower" 123 "$(k_string_lower 123)"
	assertEquals "D-e+F to lower" d-e+f "$(k_string_lower D-e+F)"
}

test_k_string_upper() {
	assertEquals "abc to upper" ABC "$(k_string_upper abc)"
	assertEquals "Abc to upper" ABC "$(k_string_upper Abc)"
	assertEquals "123 to upper" 123 "$(k_string_upper 123)"
	assertEquals "D-e+F to upper" D-E+F "$(k_string_upper D-e+F)"
}

test_k_string_pad_right() {
	assertEquals "Pad to 8 spaces" "foo     " "$(k_string_pad_right 8 foo)"
}

test_k_string_pad_left() {
	assertEquals "Pad to 8 spaces" "     foo" "$(k_string_pad_left 8 foo)"
}

test_k_string_remove_start() {
	assertEquals "abc remove a from start" bc "$(k_string_remove_start a abc)"
	assertEquals "aabc remove a from start" abc "$(k_string_remove_start a aabc)"
	assertEquals "abc remove b from start" abc "$(k_string_remove_start b abc)"
	assertEquals "abc remove c from start" abc "$(k_string_remove_start c abc)"
	assertEquals "abc remove d from start" abc "$(k_string_remove_start d abc)"
}

test_k_string_remove_end() {
	assertEquals "abc remove a from end" abc "$(k_string_remove_end a abc)"
	assertEquals "abc remove b from end" abc "$(k_string_remove_end b abc)"
	assertEquals "abc remove c from end" ab "$(k_string_remove_end c abc)"
	assertEquals "abc remove d from end" abc "$(k_string_remove_end d abc)"
}

test_k_string_join() {
	assertEquals "nothing joined by hyphen" "" "$(k_string_join "-")"
	assertEquals "a joined by hyphen" "a" "$(k_string_join "-" a)"
	assertEquals "a, b joined by hyphen" "a-b" "$(k_string_join "-" a b)"
	assertEquals "a, b, c joined by hyphen" "a-b-c" "$(k_string_join "-" a b c)"
	assertEquals "a, b, c joined by nothing" "abc" "$(k_string_join "" a b c)"
	assertEquals "a, b, c joined by a" "aabac" "$(k_string_join "a" a b c)"
}

test_k_string_trim() {
	assertEquals "'   a' trimmed" "a" "$(k_string_trim "   a")"
	assertEquals "'a	' trimmed" "a" "$(k_string_trim "a	")"
	assertEquals "'   a   ' trimmed" "a" "$(k_string_trim "   a   ")"
	assertEquals "'   a b c	' trimmed" "a b c" "$(k_string_trim "   a b c	")"
}

test_k_string_keyword (){
	assertEquals "'key3' returns 'key3'" key3 "$(k_string_keyword key3 key1 key2 key3 key4 key5)"
	assertEquals "'key7' returns 'key5'" key5 "$(k_string_keyword key7 key1 key2 key3 key4 key5)"
}

test_k_string_keyword_error (){
	k_string_keyword_error key3 key1 key2 key3 key4 key5 >/dev/null
	assertTrue "'key3' is found in key1 key2 key3 key4 key5" $?

	k_string_keyword_error key7 key1 key2 key3 key4 key5 >/dev/null
	assertFalse "'key7' is not found in key1 key2 key3 key4 key5" $?
}

test_k_string_indent() {
	# shellcheck disable=SC2039
	local expected str

	str="$(printf -- 'Line %s\n' one two three | tee ./tmp/k_string_indent.txt)"

	expected="$(sed -e "s/^/                    /" < ./tmp/k_string_indent.txt)"

	assertEquals 'Multi line string var is indented 20 chars' "$expected" "$(k_string_indent 20 "$str")"
	assertEquals 'Multi line stdin is indented 20 chars' "$expected" "$(k_string_indent 20 < ./tmp/k_string_indent.txt)"
	assertEquals 'Multi line explicit stdin is indented 20 chars' "$expected" "$(k_string_indent 20 - < ./tmp/k_string_indent.txt)"
	assertEquals 'Multi var input is indented 20 chars' "$expected" "$(k_string_indent 20 'Line one' 'Line two' 'Line three')"
}


test_k_string_prefix (){
	# shellcheck disable=SC2039
	local expected str

	str="$(printf -- '%s\n' cat dog pig | tee ./tmp/k_string_prefix.txt)"

	expected="$(sed -e "s/^/This is a: /" < ./tmp/k_string_prefix.txt)"
	assertEquals 'Multi line string var is prefixed' "$expected" "$(k_string_prefix 'This is a: ' "$str")"
	assertEquals 'Multi line stdin is prefixed' "$expected" "$(k_string_prefix 'This is a: ' < ./tmp/k_string_prefix.txt)"
	assertEquals 'Multi line explicit stdin is prefixed' "$expected" "$(k_string_prefix 'This is a: ' - < ./tmp/k_string_prefix.txt)"
	assertEquals 'Multi var input is prefixed' "$expected" "$(k_string_prefix 'This is a: ' 'cat' 'dog' 'pig')"
}



test_k_string_wrap (){
	# shellcheck disable=SC2039
	local expected str

	str="$(printf -- 'Line %s\n' one two three | tee ./tmp/k_string_wrap.txt)"

	expected="$(printf -- 'Line \n%s\n' one two three)"

	assertEquals 'Multi line string var is wrapped' "$expected" "$(k_string_wrap 5 "$str")"
	assertEquals 'Multi line stdin is wrapped' "$expected" "$(k_string_wrap 5 < ./tmp/k_string_wrap.txt)"
	assertEquals 'Multi line explicit stdin is wrapped' "$expected" "$(k_string_wrap 5 - < ./tmp/k_string_wrap.txt)"
	assertEquals 'Multi var input is wrapped' "$expected" "$(k_string_wrap 5 'Line one' 'Line two' 'Line three')"

	expected="$(printf -- 'Line %s\n' one two three)"

	assertEquals 'Multi line string var is not wrapped when width is < 1' "$expected" "$(k_string_wrap 0 "$str")"
	assertEquals 'Multi line stdin is not wrapped when width is < 1' "$expected" "$(k_string_wrap 0 < ./tmp/k_string_wrap.txt)"
	assertEquals 'Multi line explicit stdin is not wrapped when width is < 1' "$expected" "$(k_string_wrap 0 - < ./tmp/k_string_wrap.txt)"
	assertEquals 'Multi var input is not wrapped when width is < 1' "$expected" "$(k_string_wrap 0 'Line one' 'Line two' 'Line three')"
}

