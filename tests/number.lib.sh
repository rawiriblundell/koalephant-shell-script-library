#!/bin/sh -eu

. ../base.lib.sh
. ../string.lib.sh
. ../bool.lib.sh
. ../number.lib.sh

test_k_int_parse () {
	assertEquals "'10' is 10" 10 "$(k_int_parse "10")"
	assertEquals "'8' is 8" 8 "$(k_int_parse "8")"
	assertEquals "8 is 8" 8 "$(k_int_parse 8)"
	assertEquals "'10.0' is 10" 10 "$(k_int_parse "10.0")"
	assertEquals "'999999' is 999999" 999999 "$(k_int_parse "999999")"
	assertEquals "'0xFF' is 255" 255 "$(k_int_parse "0xFF")"
	assertEquals "'abc', '10' is 10" 10 "$(k_int_parse "abc" "10")"
	assertEquals "'def', '0xFF' is 255" 255 "$(k_int_parse "def" "0xFF")"
	assertEquals "'12.3', '11' is 12" 12 "$(k_int_parse "12.3" "11")"
	assertEquals "'12.abc', '11' is 11" 11 "$(k_int_parse "12.abc" "11")"
}

test_k_int_parse_error (){
	# shellcheck disable=SC2039
	local output=''


	output="$(k_int_parse_error "10" 2>&1)"
	assertTrue "10 can be parsed as int" $?
	assertEquals '10 is 10' '10' "${output}"

	output="$(k_int_parse_error "8" 2>&1)"
	assertTrue "8 can be parsed as int" $?
	assertEquals '8 is 8' '8' "${output}"

	output="$(k_int_parse_error 8 2>&1)"
	assertTrue "8 can be parsed as int" $?
	assertEquals '8 is 8' 8 "${output}"

	output="$(k_int_parse_error "abc" 2>&1)"
	assertFalse "abc cannot be parsed as int" $?
	assertEquals 'abc is not int' 'Cannot parse "abc" as integer' "${output}"

	output="$(k_int_parse_error "10.0" 2>&1)"
	assertTrue "10.0 can be parsed as int" $?
	assertEquals '10.0 is 10' '10' "${output}"

	output="$(k_int_parse_error "10.5" 2>&1)"
	assertTrue "10.5 can be parsed as int" $?
	assertEquals '10.5 is 10' '10' "${output}"

	output="$(k_int_parse_error "10.abc" 2>&1)"
	assertFalse "10.abc cannot be parsed as int" $?
	assertEquals '10.abc is not int' 'Cannot parse "10.abc" as integer' "${output}"

	output="$(k_int_parse_error "999999" 2>&1)"
	assertTrue "999999 can be parsed as int" $?
	assertEquals '999999 is 999999' '999999' "${output}"

	output="$(k_int_parse_error "0xFF" 2>&1)"
	assertTrue "0xFF can be parsed as int" $?
	assertEquals '0xFF is 255' '255' "${output}"
}



test_k_int_avg (){
	check_avg() {
		# shellcheck disable=SC2039
		local actualAvg="$1"
		shift

		assertEquals "$(printf -- 'Avg number of "%s" is "%d"' "$*" "$actualAvg")" "${actualAvg}" "$(k_int_avg "$@")"
	}

	check_avg 53 33 48 50 83
	check_avg -74 -94 -19 -95 -94 -72
	check_avg -27 -95 -71 83 56 -68 -68
	check_avg -55 -87 -54 -42 -31 -87 -55 -29
	check_avg 54 74 38 19 62 28 39 94 81
	check_avg 2 -91 88 2 96 33 -39 -11 -30 -24
	check_avg 58 51 82 30 71 83 20 46 58 76 67
	check_avg -56 -29 -28 -86 -67 -89 -56 -55 -89 -25 -69 -30
	check_avg 0 3 69 -68 85 -34 26 -5 -60 -85 -40 83 19
	check_avg -59 -46 -11 -74 -95 -97 -71 -44 -47 -48 -97 -2 -98 -46
	check_avg 42 45 59 32 77 21 25 73 17 54 6 78 49 50 15
	check_avg 15 -60 -91 86 78 -30 1 66 -24 85 -22 55 51 -72 66 50
	check_avg 41 52 71 11 84 22 7 54 22 39 90 83 68 13 1 21 19
	check_avg -47 -58 -22 -29 -43 -74 -19 -65 -76 -65 -34 -51 -96 -91 -19 -64 -9 0
	check_avg -8 -98 16 -71 -8 -36 26 54 79 33 -55 -83 -51 80 60 -94 15 -52 41
	check_avg -51 -72 -51 -6 -25 -56 -68 -48 -78 -59 -43 -73 -15 -5 -93 -42 -61 -87 -100 0
}



test_k_int_max (){
	check_max() {
		# shellcheck disable=SC2039
		local actualMax="$1"
		shift

		assertEquals "$(printf -- 'Max number of "%s" is "%d"' "$*" "$actualMax")" "${actualMax}" "$(k_int_max "$@")"
	}

	check_max 91 91 14 24 41
	check_max -18 -18 -22 -18 -32 -98
	check_max 83 -82 83 -82 73 65 -72
	check_max -7 -99 -95 -17 -7 -10 -49 -11
	check_max 70 18 21 65 65 70 23 30 60
	check_max 83 83 61 80 -14 -70 -37 -79 -60 73
	check_max 97 35 61 22 38 14 97 69 12 24 7
	check_max -8 -14 -57 -31 -42 -21 -8 -67 -78 -76 -62 -49
	check_max 70 -98 -8 37 35 -54 70 33 -63 -63 -65 67 20
	check_max -15 -58 -33 -66 -59 -74 -87 -28 -92 -15 -65 -41 -88 -40
	check_max 95 14 6 95 48 44 29 40 0 74 23 67 45 8 40
	check_max 95 53 -1 -59 15 95 69 16 -89 -22 58 -86 -17 -68 -47 -66
	check_max 100 52 25 75 21 35 100 18 48 64 73 49 44 99 58 1 52
	check_max -3 -93 -22 -66 -56 -27 -59 -67 -3 -72 -3 -32 -18 -71 -4 -9 -54 -67
	check_max 96 3 -34 -5 10 -19 -52 -30 91 -93 -23 17 87 82 -20 -12 96 -70 62
	check_max -11 -62 -62 -33 -87 -96 -57 -32 -72 -20 -44 -71 -67 -90 -72 -39 -80 -90 -55 -11
}



test_k_int_min (){
	check_min() {
		# shellcheck disable=SC2039
		local actualMin="$1"
		shift

		assertEquals "$(printf -- 'Min number of "%s" is "%d"' "$*" "$actualMin")" "${actualMin}" "$(k_int_min "$@")"
	}

	check_min 1 26 90 1 29
	check_min -66 -8 -66 -45 -64 -10
	check_min -15 47 -11 57 -15 -12 92
	check_min -83 -50 -80 -55 -75 -83 -79 -14
	check_min 9 83 100 61 42 11 9 44 35
	check_min -100 55 63 -100 82 77 5 77 -95 -58
	check_min 9 93 36 78 61 71 71 9 88 73 95
	check_min -90 -5 -35 -7 -8 -83 -90 -45 -56 -49 -3 -5
	check_min -81 -61 19 79 -30 55 65 -58 -72 -32 61 -81 -76
	check_min -93 -65 -60 -91 -67 -7 -93 -12 -5 -60 -46 -15 -75 -63
	check_min 0 65 76 82 57 54 40 66 38 62 0 84 69 100 47
	check_min -89 100 30 -13 60 14 53 61 -35 89 -77 -48 -35 -21 6 -89
	check_min 0 26 42 56 98 28 87 57 76 6 44 60 20 33 0 18 99
	check_min -99 -62 -2 -28 -18 -95 -27 -35 -2 -77 -66 -89 -18 -82 -83 -49 -11 -99
	check_min -83 -50 -43 72 30 -43 -55 -82 -55 -17 -14 -2 -66 70 -21 -22 -50 -17 -83
	check_min -99 -16 -56 -99 -50 -81 -47 -31 -27 -32 -90 -11 -27 -27 -1 -79 -56 -12 -75 -9

}



test_k_int_sum (){
	check_sum() {
		# shellcheck disable=SC2039
		local actualSum="$1"
		shift

		assertEquals "$(printf -- 'Sum number of "%s" is "%d"' "$*" "$actualSum")" "${actualSum}" "$(k_int_sum "$@")"
	}

	check_sum 233 88 55 85 5
	check_sum -302 -33 -73 -22 -100 -74
	check_sum 66 44 92 93 -40 -40 -83
	check_sum -318 -32 -8 -16 -83 -83 -78 -18
	check_sum 453 100 43 20 23 76 72 67 52
	check_sum -143 47 47 34 -50 -65 -82 -26 37 -85
	check_sum 455 76 75 63 44 78 46 7 4 10 52
	check_sum -632 -71 -3 -97 -69 -15 -63 -50 -86 -31 -60 -87
	check_sum 58 19 -82 -33 -70 98 25 51 22 5 13 71 -61
	check_sum -592 -71 -73 -71 -43 -10 -70 -37 -16 -42 -66 -13 -20 -60
	check_sum 747 12 41 94 77 37 63 76 86 77 83 22 9 64 6
	check_sum 252 -22 -38 -3 4 14 32 55 18 95 94 96 -75 24 -86 44
	check_sum 922 17 12 31 57 64 78 62 80 86 77 13 97 18 72 88 70
	check_sum -845 -90 -28 -73 -82 -69 -86 -41 -59 -7 -57 -20 -62 -6 -83 -41 -25 -16
	check_sum 52 31 -17 -24 -48 -76 -29 69 80 56 -86 9 78 -99 -7 -15 47 39 44
	check_sum -833 -50 -73 -88 -10 -76 -76 -38 -64 -37 -53 -80 -10 -47 -22 -14 -46 -2 -10 -37
}

