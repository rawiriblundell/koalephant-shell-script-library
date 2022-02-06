#!/bin/sh -eu

. ../base.lib.sh
. ../string.lib.sh
. ../bool.lib.sh
. ../number.lib.sh


test_k_bool_parse() {

	assertEquals "true is true" true "$(k_bool_parse true)"
	assertEquals "True is true" true "$(k_bool_parse True)"
	assertEquals "TRUE is true" true "$(k_bool_parse TRUE)"
	assertEquals "yes is true" true "$(k_bool_parse yes)"
	assertEquals "Yes is true" true "$(k_bool_parse Yes)"
	assertEquals "YES is true" true "$(k_bool_parse YES)"
	assertEquals "y is true" true "$(k_bool_parse y)"
	assertEquals "Y is true" true "$(k_bool_parse Y)"
	assertEquals "1 is true" true "$(k_bool_parse 1)"
	assertEquals "on is true" true "$(k_bool_parse on)"
	assertEquals "On is true" true "$(k_bool_parse On)"
	assertEquals "ON is true" true "$(k_bool_parse ON)"

	assertEquals "false is false" false "$(k_bool_parse false)"
	assertEquals "False is false" false "$(k_bool_parse False)"
	assertEquals "FALSE is false" false "$(k_bool_parse FALSE)"
	assertEquals "no is false" false "$(k_bool_parse no)"
	assertEquals "No is false" false "$(k_bool_parse No)"
	assertEquals "NO is false" false "$(k_bool_parse NO)"
	assertEquals "n is false" false "$(k_bool_parse n)"
	assertEquals "N is false" false "$(k_bool_parse N)"
	assertEquals "0 is false" false "$(k_bool_parse 0)"
	assertEquals "off is false" false "$(k_bool_parse off)"
	assertEquals "Off is false" false "$(k_bool_parse Off)"
	assertEquals "OFF is false" false "$(k_bool_parse OFF)"

	assertEquals "foo, true is true" true "$(k_bool_parse foo true)"
	assertEquals "foo, True is true" true "$(k_bool_parse foo True)"
	assertEquals "foo, TRUE is true" true "$(k_bool_parse foo TRUE)"
	assertEquals "foo, yes is true" true "$(k_bool_parse foo yes)"
	assertEquals "foo, Yes is true" true "$(k_bool_parse foo Yes)"
	assertEquals "foo, YES is true" true "$(k_bool_parse foo YES)"
	assertEquals "foo, y is true" true "$(k_bool_parse foo y)"
	assertEquals "foo, Y is true" true "$(k_bool_parse foo Y)"
	assertEquals "foo, 1 is true" true "$(k_bool_parse foo 1)"
	assertEquals "foo, on is true" true "$(k_bool_parse foo on)"
	assertEquals "foo, On is true" true "$(k_bool_parse foo On)"
	assertEquals "foo, ON is true" true "$(k_bool_parse foo ON)"

	assertEquals "foo, false is false" false "$(k_bool_parse foo false)"
	assertEquals "foo, False is false" false "$(k_bool_parse foo False)"
	assertEquals "foo, FALSE is false" false "$(k_bool_parse foo FALSE)"
	assertEquals "foo, no is false" false "$(k_bool_parse foo no)"
	assertEquals "foo, No is false" false "$(k_bool_parse foo No)"
	assertEquals "foo, NO is false" false "$(k_bool_parse foo NO)"
	assertEquals "foo, n is false" false "$(k_bool_parse foo n)"
	assertEquals "foo, N is false" false "$(k_bool_parse foo N)"
	assertEquals "foo, 0 is false" false "$(k_bool_parse foo 0)"
	assertEquals "foo, off is false" false "$(k_bool_parse foo off)"
	assertEquals "foo, Off is false" false "$(k_bool_parse foo Off)"
	assertEquals "foo, OFF is false" false "$(k_bool_parse foo OFF)"


	assertEquals "false, true is false" false "$(k_bool_parse false true)"
	assertEquals "False, true is false" false "$(k_bool_parse False true)"
	assertEquals "FALSE, true is false" false "$(k_bool_parse FALSE true)"
	assertEquals "no, true is false" false "$(k_bool_parse no true)"
	assertEquals "No, true is false" false "$(k_bool_parse No true)"
	assertEquals "NO, true is false" false "$(k_bool_parse NO true)"
	assertEquals "n, true is false" false "$(k_bool_parse n true)"
	assertEquals "N, true is false" false "$(k_bool_parse N true)"
	assertEquals "0, true is false" false "$(k_bool_parse 0 true)"
	assertEquals "off, true is false" false "$(k_bool_parse off true)"
	assertEquals "Off, true is false" false "$(k_bool_parse Off true)"
	assertEquals "OFF, true is false" false "$(k_bool_parse OFF true)"
}

test_k_bool_keyword (){

	assertEquals "true is true" true "$(k_bool_keyword true)"
	assertEquals "True is true" true "$(k_bool_keyword True)"
	assertEquals "TRUE is true" true "$(k_bool_keyword TRUE)"
	assertEquals "yes is true" true "$(k_bool_keyword yes)"
	assertEquals "Yes is true" true "$(k_bool_keyword Yes)"
	assertEquals "YES is true" true "$(k_bool_keyword YES)"
	assertEquals "y is true" true "$(k_bool_keyword y)"
	assertEquals "Y is true" true "$(k_bool_keyword Y)"
	assertEquals "1 is true" true "$(k_bool_keyword 1)"
	assertEquals "on is true" true "$(k_bool_keyword on)"
	assertEquals "On is true" true "$(k_bool_keyword On)"
	assertEquals "ON is true" true "$(k_bool_keyword ON)"


	assertEquals "false is false" false "$(k_bool_keyword false)"
	assertEquals "False is false" false "$(k_bool_keyword False)"
	assertEquals "FALSE is false" false "$(k_bool_keyword FALSE)"
	assertEquals "no is false" false "$(k_bool_keyword no)"
	assertEquals "No is false" false "$(k_bool_keyword No)"
	assertEquals "NO is false" false "$(k_bool_keyword NO)"
	assertEquals "n is false" false "$(k_bool_keyword n)"
	assertEquals "N is false" false "$(k_bool_keyword N)"
	assertEquals "0 is false" false "$(k_bool_keyword 0)"
	assertEquals "off is false" false "$(k_bool_keyword off)"
	assertEquals "Off is false" false "$(k_bool_keyword Off)"
	assertEquals "OFF is false" false "$(k_bool_keyword OFF)"

	k_bool_keyword foo > /dev/null
	assertEquals "foo throws error" 2 $?

}



test_k_bool_status (){

	k_bool_status true
	assertTrue "true is true" $?

	k_bool_status True
	assertTrue "True is true" $?

	k_bool_status TRUE
	assertTrue "TRUE is true" $?

	k_bool_status yes
	assertTrue "yes is true" $?

	k_bool_status Yes
	assertTrue "Yes is true" $?

	k_bool_status YES
	assertTrue "YES is true" $?

	k_bool_status y
	assertTrue "y is true" $?

	k_bool_status Y
	assertTrue "Y is true" $?

	k_bool_status 1
	assertTrue "1 is true" $?

	k_bool_status on
	assertTrue "on is true" $?

	k_bool_status On
	assertTrue "On is true" $?

	k_bool_status ON
	assertTrue "ON is true" $?


	k_bool_status false
	assertFalse "false is false" $?

	k_bool_status False
	assertFalse "False is false" $?

	k_bool_status FALSE
	assertFalse "FALSE is false" $?

	k_bool_status no
	assertFalse "no is false" $?

	k_bool_status No
	assertFalse "No is false" $?

	k_bool_status NO
	assertFalse "NO is false" $?

	k_bool_status n
	assertFalse "n is false" $?

	k_bool_status N
	assertFalse "N is false" $?

	k_bool_status 0
	assertFalse "0 is false" $?

	k_bool_status off
	assertFalse "off is false" $?

	k_bool_status Off
	assertFalse "Off is false" $?

	k_bool_status OFF
	assertFalse "OFF is false" $?


	k_bool_status foo > /dev/null
	assertEquals "foo throws error" 2 $?

}



test_k_bool_test (){
	k_bool_test ''
	assertFalse "'' is false" $?

	k_bool_test '' ''
	assertFalse "'', '' is false" $?

	k_bool_test '' foo
	assertFalse "'', foo is false" $?

	k_bool_test '' One
	assertFalse "'', One is false" $?

	k_bool_test '' true
	assertTrue "'', true is true" $?

	k_bool_test '' True
	assertTrue "'', True is true" $?

	k_bool_test '' TRUE
	assertTrue "'', TRUE is true" $?

	k_bool_test '' yes
	assertTrue "'', yes is true" $?

	k_bool_test '' Yes
	assertTrue "'', Yes is true" $?

	k_bool_test '' YES
	assertTrue "'', YES is true" $?

	k_bool_test '' y
	assertTrue "'', y is true" $?

	k_bool_test '' Y
	assertTrue "'', Y is true" $?

	k_bool_test '' 1
	assertTrue "'', 1 is true" $?

	k_bool_test '' on
	assertTrue "'', on is true" $?

	k_bool_test '' On
	assertTrue "'', On is true" $?

	k_bool_test '' ON
	assertTrue "'', ON is true" $?

	k_bool_test '' false
	assertFalse "'', false is false" $?

	k_bool_test '' False
	assertFalse "'', False is false" $?

	k_bool_test '' FALSE
	assertFalse "'', FALSE is false" $?

	k_bool_test '' no
	assertFalse "'', no is false" $?

	k_bool_test '' No
	assertFalse "'', No is false" $?

	k_bool_test '' NO
	assertFalse "'', NO is false" $?

	k_bool_test '' n
	assertFalse "'', n is false" $?

	k_bool_test '' N
	assertFalse "'', N is false" $?

	k_bool_test '' 0
	assertFalse "'', 0 is false" $?

	k_bool_test '' off
	assertFalse "'', off is false" $?

	k_bool_test '' Off
	assertFalse "'', Off is false" $?

	k_bool_test '' OFF
	assertFalse "'', OFF is false" $?

	k_bool_test foo
	assertFalse "foo is false" $?

	k_bool_test foo ''
	assertFalse "foo, '' is false" $?

	k_bool_test foo foo
	assertFalse "foo, foo is false" $?

	k_bool_test foo One
	assertFalse "foo, One is false" $?

	k_bool_test foo true
	assertTrue "foo, true is true" $?

	k_bool_test foo True
	assertTrue "foo, True is true" $?

	k_bool_test foo TRUE
	assertTrue "foo, TRUE is true" $?

	k_bool_test foo yes
	assertTrue "foo, yes is true" $?

	k_bool_test foo Yes
	assertTrue "foo, Yes is true" $?

	k_bool_test foo YES
	assertTrue "foo, YES is true" $?

	k_bool_test foo y
	assertTrue "foo, y is true" $?

	k_bool_test foo Y
	assertTrue "foo, Y is true" $?

	k_bool_test foo 1
	assertTrue "foo, 1 is true" $?

	k_bool_test foo on
	assertTrue "foo, on is true" $?

	k_bool_test foo On
	assertTrue "foo, On is true" $?

	k_bool_test foo ON
	assertTrue "foo, ON is true" $?

	k_bool_test foo false
	assertFalse "foo, false is false" $?

	k_bool_test foo False
	assertFalse "foo, False is false" $?

	k_bool_test foo FALSE
	assertFalse "foo, FALSE is false" $?

	k_bool_test foo no
	assertFalse "foo, no is false" $?

	k_bool_test foo No
	assertFalse "foo, No is false" $?

	k_bool_test foo NO
	assertFalse "foo, NO is false" $?

	k_bool_test foo n
	assertFalse "foo, n is false" $?

	k_bool_test foo N
	assertFalse "foo, N is false" $?

	k_bool_test foo 0
	assertFalse "foo, 0 is false" $?

	k_bool_test foo off
	assertFalse "foo, off is false" $?

	k_bool_test foo Off
	assertFalse "foo, Off is false" $?

	k_bool_test foo OFF
	assertFalse "foo, OFF is false" $?

	k_bool_test One
	assertFalse "One is false" $?

	k_bool_test One ''
	assertFalse "One, '' is false" $?

	k_bool_test One foo
	assertFalse "One, foo is false" $?

	k_bool_test One One
	assertFalse "One, One is false" $?

	k_bool_test One true
	assertTrue "One, true is true" $?

	k_bool_test One True
	assertTrue "One, True is true" $?

	k_bool_test One TRUE
	assertTrue "One, TRUE is true" $?

	k_bool_test One yes
	assertTrue "One, yes is true" $?

	k_bool_test One Yes
	assertTrue "One, Yes is true" $?

	k_bool_test One YES
	assertTrue "One, YES is true" $?

	k_bool_test One y
	assertTrue "One, y is true" $?

	k_bool_test One Y
	assertTrue "One, Y is true" $?

	k_bool_test One 1
	assertTrue "One, 1 is true" $?

	k_bool_test One on
	assertTrue "One, on is true" $?

	k_bool_test One On
	assertTrue "One, On is true" $?

	k_bool_test One ON
	assertTrue "One, ON is true" $?

	k_bool_test One false
	assertFalse "One, false is false" $?

	k_bool_test One False
	assertFalse "One, False is false" $?

	k_bool_test One FALSE
	assertFalse "One, FALSE is false" $?

	k_bool_test One no
	assertFalse "One, no is false" $?

	k_bool_test One No
	assertFalse "One, No is false" $?

	k_bool_test One NO
	assertFalse "One, NO is false" $?

	k_bool_test One n
	assertFalse "One, n is false" $?

	k_bool_test One N
	assertFalse "One, N is false" $?

	k_bool_test One 0
	assertFalse "One, 0 is false" $?

	k_bool_test One off
	assertFalse "One, off is false" $?

	k_bool_test One Off
	assertFalse "One, Off is false" $?

	k_bool_test One OFF
	assertFalse "One, OFF is false" $?

	k_bool_test true
	assertTrue "true is true" $?

	k_bool_test true ''
	assertTrue "true, '' is true" $?

	k_bool_test true foo
	assertTrue "true, foo is true" $?

	k_bool_test true One
	assertTrue "true, One is true" $?

	k_bool_test true true
	assertTrue "true, true is true" $?

	k_bool_test true True
	assertTrue "true, True is true" $?

	k_bool_test true TRUE
	assertTrue "true, TRUE is true" $?

	k_bool_test true yes
	assertTrue "true, yes is true" $?

	k_bool_test true Yes
	assertTrue "true, Yes is true" $?

	k_bool_test true YES
	assertTrue "true, YES is true" $?

	k_bool_test true y
	assertTrue "true, y is true" $?

	k_bool_test true Y
	assertTrue "true, Y is true" $?

	k_bool_test true 1
	assertTrue "true, 1 is true" $?

	k_bool_test true on
	assertTrue "true, on is true" $?

	k_bool_test true On
	assertTrue "true, On is true" $?

	k_bool_test true ON
	assertTrue "true, ON is true" $?

	k_bool_test true false
	assertTrue "true, false is true" $?

	k_bool_test true False
	assertTrue "true, False is true" $?

	k_bool_test true FALSE
	assertTrue "true, FALSE is true" $?

	k_bool_test true no
	assertTrue "true, no is true" $?

	k_bool_test true No
	assertTrue "true, No is true" $?

	k_bool_test true NO
	assertTrue "true, NO is true" $?

	k_bool_test true n
	assertTrue "true, n is true" $?

	k_bool_test true N
	assertTrue "true, N is true" $?

	k_bool_test true 0
	assertTrue "true, 0 is true" $?

	k_bool_test true off
	assertTrue "true, off is true" $?

	k_bool_test true Off
	assertTrue "true, Off is true" $?

	k_bool_test true OFF
	assertTrue "true, OFF is true" $?

	k_bool_test True
	assertTrue "True is true" $?

	k_bool_test True ''
	assertTrue "True, '' is true" $?

	k_bool_test True foo
	assertTrue "True, foo is true" $?

	k_bool_test True One
	assertTrue "True, One is true" $?

	k_bool_test True true
	assertTrue "True, true is true" $?

	k_bool_test True True
	assertTrue "True, True is true" $?

	k_bool_test True TRUE
	assertTrue "True, TRUE is true" $?

	k_bool_test True yes
	assertTrue "True, yes is true" $?

	k_bool_test True Yes
	assertTrue "True, Yes is true" $?

	k_bool_test True YES
	assertTrue "True, YES is true" $?

	k_bool_test True y
	assertTrue "True, y is true" $?

	k_bool_test True Y
	assertTrue "True, Y is true" $?

	k_bool_test True 1
	assertTrue "True, 1 is true" $?

	k_bool_test True on
	assertTrue "True, on is true" $?

	k_bool_test True On
	assertTrue "True, On is true" $?

	k_bool_test True ON
	assertTrue "True, ON is true" $?

	k_bool_test True false
	assertTrue "True, false is true" $?

	k_bool_test True False
	assertTrue "True, False is true" $?

	k_bool_test True FALSE
	assertTrue "True, FALSE is true" $?

	k_bool_test True no
	assertTrue "True, no is true" $?

	k_bool_test True No
	assertTrue "True, No is true" $?

	k_bool_test True NO
	assertTrue "True, NO is true" $?

	k_bool_test True n
	assertTrue "True, n is true" $?

	k_bool_test True N
	assertTrue "True, N is true" $?

	k_bool_test True 0
	assertTrue "True, 0 is true" $?

	k_bool_test True off
	assertTrue "True, off is true" $?

	k_bool_test True Off
	assertTrue "True, Off is true" $?

	k_bool_test True OFF
	assertTrue "True, OFF is true" $?

	k_bool_test TRUE
	assertTrue "TRUE is true" $?

	k_bool_test TRUE ''
	assertTrue "TRUE, '' is true" $?

	k_bool_test TRUE foo
	assertTrue "TRUE, foo is true" $?

	k_bool_test TRUE One
	assertTrue "TRUE, One is true" $?

	k_bool_test TRUE true
	assertTrue "TRUE, true is true" $?

	k_bool_test TRUE True
	assertTrue "TRUE, True is true" $?

	k_bool_test TRUE TRUE
	assertTrue "TRUE, TRUE is true" $?

	k_bool_test TRUE yes
	assertTrue "TRUE, yes is true" $?

	k_bool_test TRUE Yes
	assertTrue "TRUE, Yes is true" $?

	k_bool_test TRUE YES
	assertTrue "TRUE, YES is true" $?

	k_bool_test TRUE y
	assertTrue "TRUE, y is true" $?

	k_bool_test TRUE Y
	assertTrue "TRUE, Y is true" $?

	k_bool_test TRUE 1
	assertTrue "TRUE, 1 is true" $?

	k_bool_test TRUE on
	assertTrue "TRUE, on is true" $?

	k_bool_test TRUE On
	assertTrue "TRUE, On is true" $?

	k_bool_test TRUE ON
	assertTrue "TRUE, ON is true" $?

	k_bool_test TRUE false
	assertTrue "TRUE, false is true" $?

	k_bool_test TRUE False
	assertTrue "TRUE, False is true" $?

	k_bool_test TRUE FALSE
	assertTrue "TRUE, FALSE is true" $?

	k_bool_test TRUE no
	assertTrue "TRUE, no is true" $?

	k_bool_test TRUE No
	assertTrue "TRUE, No is true" $?

	k_bool_test TRUE NO
	assertTrue "TRUE, NO is true" $?

	k_bool_test TRUE n
	assertTrue "TRUE, n is true" $?

	k_bool_test TRUE N
	assertTrue "TRUE, N is true" $?

	k_bool_test TRUE 0
	assertTrue "TRUE, 0 is true" $?

	k_bool_test TRUE off
	assertTrue "TRUE, off is true" $?

	k_bool_test TRUE Off
	assertTrue "TRUE, Off is true" $?

	k_bool_test TRUE OFF
	assertTrue "TRUE, OFF is true" $?

	k_bool_test yes
	assertTrue "yes is true" $?

	k_bool_test yes ''
	assertTrue "yes, '' is true" $?

	k_bool_test yes foo
	assertTrue "yes, foo is true" $?

	k_bool_test yes One
	assertTrue "yes, One is true" $?

	k_bool_test yes true
	assertTrue "yes, true is true" $?

	k_bool_test yes True
	assertTrue "yes, True is true" $?

	k_bool_test yes TRUE
	assertTrue "yes, TRUE is true" $?

	k_bool_test yes yes
	assertTrue "yes, yes is true" $?

	k_bool_test yes Yes
	assertTrue "yes, Yes is true" $?

	k_bool_test yes YES
	assertTrue "yes, YES is true" $?

	k_bool_test yes y
	assertTrue "yes, y is true" $?

	k_bool_test yes Y
	assertTrue "yes, Y is true" $?

	k_bool_test yes 1
	assertTrue "yes, 1 is true" $?

	k_bool_test yes on
	assertTrue "yes, on is true" $?

	k_bool_test yes On
	assertTrue "yes, On is true" $?

	k_bool_test yes ON
	assertTrue "yes, ON is true" $?

	k_bool_test yes false
	assertTrue "yes, false is true" $?

	k_bool_test yes False
	assertTrue "yes, False is true" $?

	k_bool_test yes FALSE
	assertTrue "yes, FALSE is true" $?

	k_bool_test yes no
	assertTrue "yes, no is true" $?

	k_bool_test yes No
	assertTrue "yes, No is true" $?

	k_bool_test yes NO
	assertTrue "yes, NO is true" $?

	k_bool_test yes n
	assertTrue "yes, n is true" $?

	k_bool_test yes N
	assertTrue "yes, N is true" $?

	k_bool_test yes 0
	assertTrue "yes, 0 is true" $?

	k_bool_test yes off
	assertTrue "yes, off is true" $?

	k_bool_test yes Off
	assertTrue "yes, Off is true" $?

	k_bool_test yes OFF
	assertTrue "yes, OFF is true" $?

	k_bool_test Yes
	assertTrue "Yes is true" $?

	k_bool_test Yes ''
	assertTrue "Yes, '' is true" $?

	k_bool_test Yes foo
	assertTrue "Yes, foo is true" $?

	k_bool_test Yes One
	assertTrue "Yes, One is true" $?

	k_bool_test Yes true
	assertTrue "Yes, true is true" $?

	k_bool_test Yes True
	assertTrue "Yes, True is true" $?

	k_bool_test Yes TRUE
	assertTrue "Yes, TRUE is true" $?

	k_bool_test Yes yes
	assertTrue "Yes, yes is true" $?

	k_bool_test Yes Yes
	assertTrue "Yes, Yes is true" $?

	k_bool_test Yes YES
	assertTrue "Yes, YES is true" $?

	k_bool_test Yes y
	assertTrue "Yes, y is true" $?

	k_bool_test Yes Y
	assertTrue "Yes, Y is true" $?

	k_bool_test Yes 1
	assertTrue "Yes, 1 is true" $?

	k_bool_test Yes on
	assertTrue "Yes, on is true" $?

	k_bool_test Yes On
	assertTrue "Yes, On is true" $?

	k_bool_test Yes ON
	assertTrue "Yes, ON is true" $?

	k_bool_test Yes false
	assertTrue "Yes, false is true" $?

	k_bool_test Yes False
	assertTrue "Yes, False is true" $?

	k_bool_test Yes FALSE
	assertTrue "Yes, FALSE is true" $?

	k_bool_test Yes no
	assertTrue "Yes, no is true" $?

	k_bool_test Yes No
	assertTrue "Yes, No is true" $?

	k_bool_test Yes NO
	assertTrue "Yes, NO is true" $?

	k_bool_test Yes n
	assertTrue "Yes, n is true" $?

	k_bool_test Yes N
	assertTrue "Yes, N is true" $?

	k_bool_test Yes 0
	assertTrue "Yes, 0 is true" $?

	k_bool_test Yes off
	assertTrue "Yes, off is true" $?

	k_bool_test Yes Off
	assertTrue "Yes, Off is true" $?

	k_bool_test Yes OFF
	assertTrue "Yes, OFF is true" $?

	k_bool_test YES
	assertTrue "YES is true" $?

	k_bool_test YES ''
	assertTrue "YES, '' is true" $?

	k_bool_test YES foo
	assertTrue "YES, foo is true" $?

	k_bool_test YES One
	assertTrue "YES, One is true" $?

	k_bool_test YES true
	assertTrue "YES, true is true" $?

	k_bool_test YES True
	assertTrue "YES, True is true" $?

	k_bool_test YES TRUE
	assertTrue "YES, TRUE is true" $?

	k_bool_test YES yes
	assertTrue "YES, yes is true" $?

	k_bool_test YES Yes
	assertTrue "YES, Yes is true" $?

	k_bool_test YES YES
	assertTrue "YES, YES is true" $?

	k_bool_test YES y
	assertTrue "YES, y is true" $?

	k_bool_test YES Y
	assertTrue "YES, Y is true" $?

	k_bool_test YES 1
	assertTrue "YES, 1 is true" $?

	k_bool_test YES on
	assertTrue "YES, on is true" $?

	k_bool_test YES On
	assertTrue "YES, On is true" $?

	k_bool_test YES ON
	assertTrue "YES, ON is true" $?

	k_bool_test YES false
	assertTrue "YES, false is true" $?

	k_bool_test YES False
	assertTrue "YES, False is true" $?

	k_bool_test YES FALSE
	assertTrue "YES, FALSE is true" $?

	k_bool_test YES no
	assertTrue "YES, no is true" $?

	k_bool_test YES No
	assertTrue "YES, No is true" $?

	k_bool_test YES NO
	assertTrue "YES, NO is true" $?

	k_bool_test YES n
	assertTrue "YES, n is true" $?

	k_bool_test YES N
	assertTrue "YES, N is true" $?

	k_bool_test YES 0
	assertTrue "YES, 0 is true" $?

	k_bool_test YES off
	assertTrue "YES, off is true" $?

	k_bool_test YES Off
	assertTrue "YES, Off is true" $?

	k_bool_test YES OFF
	assertTrue "YES, OFF is true" $?

	k_bool_test y
	assertTrue "y is true" $?

	k_bool_test y ''
	assertTrue "y, '' is true" $?

	k_bool_test y foo
	assertTrue "y, foo is true" $?

	k_bool_test y One
	assertTrue "y, One is true" $?

	k_bool_test y true
	assertTrue "y, true is true" $?

	k_bool_test y True
	assertTrue "y, True is true" $?

	k_bool_test y TRUE
	assertTrue "y, TRUE is true" $?

	k_bool_test y yes
	assertTrue "y, yes is true" $?

	k_bool_test y Yes
	assertTrue "y, Yes is true" $?

	k_bool_test y YES
	assertTrue "y, YES is true" $?

	k_bool_test y y
	assertTrue "y, y is true" $?

	k_bool_test y Y
	assertTrue "y, Y is true" $?

	k_bool_test y 1
	assertTrue "y, 1 is true" $?

	k_bool_test y on
	assertTrue "y, on is true" $?

	k_bool_test y On
	assertTrue "y, On is true" $?

	k_bool_test y ON
	assertTrue "y, ON is true" $?

	k_bool_test y false
	assertTrue "y, false is true" $?

	k_bool_test y False
	assertTrue "y, False is true" $?

	k_bool_test y FALSE
	assertTrue "y, FALSE is true" $?

	k_bool_test y no
	assertTrue "y, no is true" $?

	k_bool_test y No
	assertTrue "y, No is true" $?

	k_bool_test y NO
	assertTrue "y, NO is true" $?

	k_bool_test y n
	assertTrue "y, n is true" $?

	k_bool_test y N
	assertTrue "y, N is true" $?

	k_bool_test y 0
	assertTrue "y, 0 is true" $?

	k_bool_test y off
	assertTrue "y, off is true" $?

	k_bool_test y Off
	assertTrue "y, Off is true" $?

	k_bool_test y OFF
	assertTrue "y, OFF is true" $?

	k_bool_test Y
	assertTrue "Y is true" $?

	k_bool_test Y ''
	assertTrue "Y, '' is true" $?

	k_bool_test Y foo
	assertTrue "Y, foo is true" $?

	k_bool_test Y One
	assertTrue "Y, One is true" $?

	k_bool_test Y true
	assertTrue "Y, true is true" $?

	k_bool_test Y True
	assertTrue "Y, True is true" $?

	k_bool_test Y TRUE
	assertTrue "Y, TRUE is true" $?

	k_bool_test Y yes
	assertTrue "Y, yes is true" $?

	k_bool_test Y Yes
	assertTrue "Y, Yes is true" $?

	k_bool_test Y YES
	assertTrue "Y, YES is true" $?

	k_bool_test Y y
	assertTrue "Y, y is true" $?

	k_bool_test Y Y
	assertTrue "Y, Y is true" $?

	k_bool_test Y 1
	assertTrue "Y, 1 is true" $?

	k_bool_test Y on
	assertTrue "Y, on is true" $?

	k_bool_test Y On
	assertTrue "Y, On is true" $?

	k_bool_test Y ON
	assertTrue "Y, ON is true" $?

	k_bool_test Y false
	assertTrue "Y, false is true" $?

	k_bool_test Y False
	assertTrue "Y, False is true" $?

	k_bool_test Y FALSE
	assertTrue "Y, FALSE is true" $?

	k_bool_test Y no
	assertTrue "Y, no is true" $?

	k_bool_test Y No
	assertTrue "Y, No is true" $?

	k_bool_test Y NO
	assertTrue "Y, NO is true" $?

	k_bool_test Y n
	assertTrue "Y, n is true" $?

	k_bool_test Y N
	assertTrue "Y, N is true" $?

	k_bool_test Y 0
	assertTrue "Y, 0 is true" $?

	k_bool_test Y off
	assertTrue "Y, off is true" $?

	k_bool_test Y Off
	assertTrue "Y, Off is true" $?

	k_bool_test Y OFF
	assertTrue "Y, OFF is true" $?

	k_bool_test 1
	assertTrue "1 is true" $?

	k_bool_test 1 ''
	assertTrue "1, '' is true" $?

	k_bool_test 1 foo
	assertTrue "1, foo is true" $?

	k_bool_test 1 One
	assertTrue "1, One is true" $?

	k_bool_test 1 true
	assertTrue "1, true is true" $?

	k_bool_test 1 True
	assertTrue "1, True is true" $?

	k_bool_test 1 TRUE
	assertTrue "1, TRUE is true" $?

	k_bool_test 1 yes
	assertTrue "1, yes is true" $?

	k_bool_test 1 Yes
	assertTrue "1, Yes is true" $?

	k_bool_test 1 YES
	assertTrue "1, YES is true" $?

	k_bool_test 1 y
	assertTrue "1, y is true" $?

	k_bool_test 1 Y
	assertTrue "1, Y is true" $?

	k_bool_test 1 1
	assertTrue "1, 1 is true" $?

	k_bool_test 1 on
	assertTrue "1, on is true" $?

	k_bool_test 1 On
	assertTrue "1, On is true" $?

	k_bool_test 1 ON
	assertTrue "1, ON is true" $?

	k_bool_test 1 false
	assertTrue "1, false is true" $?

	k_bool_test 1 False
	assertTrue "1, False is true" $?

	k_bool_test 1 FALSE
	assertTrue "1, FALSE is true" $?

	k_bool_test 1 no
	assertTrue "1, no is true" $?

	k_bool_test 1 No
	assertTrue "1, No is true" $?

	k_bool_test 1 NO
	assertTrue "1, NO is true" $?

	k_bool_test 1 n
	assertTrue "1, n is true" $?

	k_bool_test 1 N
	assertTrue "1, N is true" $?

	k_bool_test 1 0
	assertTrue "1, 0 is true" $?

	k_bool_test 1 off
	assertTrue "1, off is true" $?

	k_bool_test 1 Off
	assertTrue "1, Off is true" $?

	k_bool_test 1 OFF
	assertTrue "1, OFF is true" $?

	k_bool_test on
	assertTrue "on is true" $?

	k_bool_test on ''
	assertTrue "on, '' is true" $?

	k_bool_test on foo
	assertTrue "on, foo is true" $?

	k_bool_test on One
	assertTrue "on, One is true" $?

	k_bool_test on true
	assertTrue "on, true is true" $?

	k_bool_test on True
	assertTrue "on, True is true" $?

	k_bool_test on TRUE
	assertTrue "on, TRUE is true" $?

	k_bool_test on yes
	assertTrue "on, yes is true" $?

	k_bool_test on Yes
	assertTrue "on, Yes is true" $?

	k_bool_test on YES
	assertTrue "on, YES is true" $?

	k_bool_test on y
	assertTrue "on, y is true" $?

	k_bool_test on Y
	assertTrue "on, Y is true" $?

	k_bool_test on 1
	assertTrue "on, 1 is true" $?

	k_bool_test on on
	assertTrue "on, on is true" $?

	k_bool_test on On
	assertTrue "on, On is true" $?

	k_bool_test on ON
	assertTrue "on, ON is true" $?

	k_bool_test on false
	assertTrue "on, false is true" $?

	k_bool_test on False
	assertTrue "on, False is true" $?

	k_bool_test on FALSE
	assertTrue "on, FALSE is true" $?

	k_bool_test on no
	assertTrue "on, no is true" $?

	k_bool_test on No
	assertTrue "on, No is true" $?

	k_bool_test on NO
	assertTrue "on, NO is true" $?

	k_bool_test on n
	assertTrue "on, n is true" $?

	k_bool_test on N
	assertTrue "on, N is true" $?

	k_bool_test on 0
	assertTrue "on, 0 is true" $?

	k_bool_test on off
	assertTrue "on, off is true" $?

	k_bool_test on Off
	assertTrue "on, Off is true" $?

	k_bool_test on OFF
	assertTrue "on, OFF is true" $?

	k_bool_test On
	assertTrue "On is true" $?

	k_bool_test On ''
	assertTrue "On, '' is true" $?

	k_bool_test On foo
	assertTrue "On, foo is true" $?

	k_bool_test On One
	assertTrue "On, One is true" $?

	k_bool_test On true
	assertTrue "On, true is true" $?

	k_bool_test On True
	assertTrue "On, True is true" $?

	k_bool_test On TRUE
	assertTrue "On, TRUE is true" $?

	k_bool_test On yes
	assertTrue "On, yes is true" $?

	k_bool_test On Yes
	assertTrue "On, Yes is true" $?

	k_bool_test On YES
	assertTrue "On, YES is true" $?

	k_bool_test On y
	assertTrue "On, y is true" $?

	k_bool_test On Y
	assertTrue "On, Y is true" $?

	k_bool_test On 1
	assertTrue "On, 1 is true" $?

	k_bool_test On on
	assertTrue "On, on is true" $?

	k_bool_test On On
	assertTrue "On, On is true" $?

	k_bool_test On ON
	assertTrue "On, ON is true" $?

	k_bool_test On false
	assertTrue "On, false is true" $?

	k_bool_test On False
	assertTrue "On, False is true" $?

	k_bool_test On FALSE
	assertTrue "On, FALSE is true" $?

	k_bool_test On no
	assertTrue "On, no is true" $?

	k_bool_test On No
	assertTrue "On, No is true" $?

	k_bool_test On NO
	assertTrue "On, NO is true" $?

	k_bool_test On n
	assertTrue "On, n is true" $?

	k_bool_test On N
	assertTrue "On, N is true" $?

	k_bool_test On 0
	assertTrue "On, 0 is true" $?

	k_bool_test On off
	assertTrue "On, off is true" $?

	k_bool_test On Off
	assertTrue "On, Off is true" $?

	k_bool_test On OFF
	assertTrue "On, OFF is true" $?

	k_bool_test ON
	assertTrue "ON is true" $?

	k_bool_test ON ''
	assertTrue "ON, '' is true" $?

	k_bool_test ON foo
	assertTrue "ON, foo is true" $?

	k_bool_test ON One
	assertTrue "ON, One is true" $?

	k_bool_test ON true
	assertTrue "ON, true is true" $?

	k_bool_test ON True
	assertTrue "ON, True is true" $?

	k_bool_test ON TRUE
	assertTrue "ON, TRUE is true" $?

	k_bool_test ON yes
	assertTrue "ON, yes is true" $?

	k_bool_test ON Yes
	assertTrue "ON, Yes is true" $?

	k_bool_test ON YES
	assertTrue "ON, YES is true" $?

	k_bool_test ON y
	assertTrue "ON, y is true" $?

	k_bool_test ON Y
	assertTrue "ON, Y is true" $?

	k_bool_test ON 1
	assertTrue "ON, 1 is true" $?

	k_bool_test ON on
	assertTrue "ON, on is true" $?

	k_bool_test ON On
	assertTrue "ON, On is true" $?

	k_bool_test ON ON
	assertTrue "ON, ON is true" $?

	k_bool_test ON false
	assertTrue "ON, false is true" $?

	k_bool_test ON False
	assertTrue "ON, False is true" $?

	k_bool_test ON FALSE
	assertTrue "ON, FALSE is true" $?

	k_bool_test ON no
	assertTrue "ON, no is true" $?

	k_bool_test ON No
	assertTrue "ON, No is true" $?

	k_bool_test ON NO
	assertTrue "ON, NO is true" $?

	k_bool_test ON n
	assertTrue "ON, n is true" $?

	k_bool_test ON N
	assertTrue "ON, N is true" $?

	k_bool_test ON 0
	assertTrue "ON, 0 is true" $?

	k_bool_test ON off
	assertTrue "ON, off is true" $?

	k_bool_test ON Off
	assertTrue "ON, Off is true" $?

	k_bool_test ON OFF
	assertTrue "ON, OFF is true" $?

	k_bool_test false
	assertFalse "false is false" $?

	k_bool_test false ''
	assertFalse "false, '' is false" $?

	k_bool_test false foo
	assertFalse "false, foo is false" $?

	k_bool_test false One
	assertFalse "false, One is false" $?

	k_bool_test false true
	assertFalse "false, true is false" $?

	k_bool_test false True
	assertFalse "false, True is false" $?

	k_bool_test false TRUE
	assertFalse "false, TRUE is false" $?

	k_bool_test false yes
	assertFalse "false, yes is false" $?

	k_bool_test false Yes
	assertFalse "false, Yes is false" $?

	k_bool_test false YES
	assertFalse "false, YES is false" $?

	k_bool_test false y
	assertFalse "false, y is false" $?

	k_bool_test false Y
	assertFalse "false, Y is false" $?

	k_bool_test false 1
	assertFalse "false, 1 is false" $?

	k_bool_test false on
	assertFalse "false, on is false" $?

	k_bool_test false On
	assertFalse "false, On is false" $?

	k_bool_test false ON
	assertFalse "false, ON is false" $?

	k_bool_test false false
	assertFalse "false, false is false" $?

	k_bool_test false False
	assertFalse "false, False is false" $?

	k_bool_test false FALSE
	assertFalse "false, FALSE is false" $?

	k_bool_test false no
	assertFalse "false, no is false" $?

	k_bool_test false No
	assertFalse "false, No is false" $?

	k_bool_test false NO
	assertFalse "false, NO is false" $?

	k_bool_test false n
	assertFalse "false, n is false" $?

	k_bool_test false N
	assertFalse "false, N is false" $?

	k_bool_test false 0
	assertFalse "false, 0 is false" $?

	k_bool_test false off
	assertFalse "false, off is false" $?

	k_bool_test false Off
	assertFalse "false, Off is false" $?

	k_bool_test false OFF
	assertFalse "false, OFF is false" $?

	k_bool_test False
	assertFalse "False is false" $?

	k_bool_test False ''
	assertFalse "False, '' is false" $?

	k_bool_test False foo
	assertFalse "False, foo is false" $?

	k_bool_test False One
	assertFalse "False, One is false" $?

	k_bool_test False true
	assertFalse "False, true is false" $?

	k_bool_test False True
	assertFalse "False, True is false" $?

	k_bool_test False TRUE
	assertFalse "False, TRUE is false" $?

	k_bool_test False yes
	assertFalse "False, yes is false" $?

	k_bool_test False Yes
	assertFalse "False, Yes is false" $?

	k_bool_test False YES
	assertFalse "False, YES is false" $?

	k_bool_test False y
	assertFalse "False, y is false" $?

	k_bool_test False Y
	assertFalse "False, Y is false" $?

	k_bool_test False 1
	assertFalse "False, 1 is false" $?

	k_bool_test False on
	assertFalse "False, on is false" $?

	k_bool_test False On
	assertFalse "False, On is false" $?

	k_bool_test False ON
	assertFalse "False, ON is false" $?

	k_bool_test False false
	assertFalse "False, false is false" $?

	k_bool_test False False
	assertFalse "False, False is false" $?

	k_bool_test False FALSE
	assertFalse "False, FALSE is false" $?

	k_bool_test False no
	assertFalse "False, no is false" $?

	k_bool_test False No
	assertFalse "False, No is false" $?

	k_bool_test False NO
	assertFalse "False, NO is false" $?

	k_bool_test False n
	assertFalse "False, n is false" $?

	k_bool_test False N
	assertFalse "False, N is false" $?

	k_bool_test False 0
	assertFalse "False, 0 is false" $?

	k_bool_test False off
	assertFalse "False, off is false" $?

	k_bool_test False Off
	assertFalse "False, Off is false" $?

	k_bool_test False OFF
	assertFalse "False, OFF is false" $?

	k_bool_test FALSE
	assertFalse "FALSE is false" $?

	k_bool_test FALSE ''
	assertFalse "FALSE, '' is false" $?

	k_bool_test FALSE foo
	assertFalse "FALSE, foo is false" $?

	k_bool_test FALSE One
	assertFalse "FALSE, One is false" $?

	k_bool_test FALSE true
	assertFalse "FALSE, true is false" $?

	k_bool_test FALSE True
	assertFalse "FALSE, True is false" $?

	k_bool_test FALSE TRUE
	assertFalse "FALSE, TRUE is false" $?

	k_bool_test FALSE yes
	assertFalse "FALSE, yes is false" $?

	k_bool_test FALSE Yes
	assertFalse "FALSE, Yes is false" $?

	k_bool_test FALSE YES
	assertFalse "FALSE, YES is false" $?

	k_bool_test FALSE y
	assertFalse "FALSE, y is false" $?

	k_bool_test FALSE Y
	assertFalse "FALSE, Y is false" $?

	k_bool_test FALSE 1
	assertFalse "FALSE, 1 is false" $?

	k_bool_test FALSE on
	assertFalse "FALSE, on is false" $?

	k_bool_test FALSE On
	assertFalse "FALSE, On is false" $?

	k_bool_test FALSE ON
	assertFalse "FALSE, ON is false" $?

	k_bool_test FALSE false
	assertFalse "FALSE, false is false" $?

	k_bool_test FALSE False
	assertFalse "FALSE, False is false" $?

	k_bool_test FALSE FALSE
	assertFalse "FALSE, FALSE is false" $?

	k_bool_test FALSE no
	assertFalse "FALSE, no is false" $?

	k_bool_test FALSE No
	assertFalse "FALSE, No is false" $?

	k_bool_test FALSE NO
	assertFalse "FALSE, NO is false" $?

	k_bool_test FALSE n
	assertFalse "FALSE, n is false" $?

	k_bool_test FALSE N
	assertFalse "FALSE, N is false" $?

	k_bool_test FALSE 0
	assertFalse "FALSE, 0 is false" $?

	k_bool_test FALSE off
	assertFalse "FALSE, off is false" $?

	k_bool_test FALSE Off
	assertFalse "FALSE, Off is false" $?

	k_bool_test FALSE OFF
	assertFalse "FALSE, OFF is false" $?

	k_bool_test no
	assertFalse "no is false" $?

	k_bool_test no ''
	assertFalse "no, '' is false" $?

	k_bool_test no foo
	assertFalse "no, foo is false" $?

	k_bool_test no One
	assertFalse "no, One is false" $?

	k_bool_test no true
	assertFalse "no, true is false" $?

	k_bool_test no True
	assertFalse "no, True is false" $?

	k_bool_test no TRUE
	assertFalse "no, TRUE is false" $?

	k_bool_test no yes
	assertFalse "no, yes is false" $?

	k_bool_test no Yes
	assertFalse "no, Yes is false" $?

	k_bool_test no YES
	assertFalse "no, YES is false" $?

	k_bool_test no y
	assertFalse "no, y is false" $?

	k_bool_test no Y
	assertFalse "no, Y is false" $?

	k_bool_test no 1
	assertFalse "no, 1 is false" $?

	k_bool_test no on
	assertFalse "no, on is false" $?

	k_bool_test no On
	assertFalse "no, On is false" $?

	k_bool_test no ON
	assertFalse "no, ON is false" $?

	k_bool_test no false
	assertFalse "no, false is false" $?

	k_bool_test no False
	assertFalse "no, False is false" $?

	k_bool_test no FALSE
	assertFalse "no, FALSE is false" $?

	k_bool_test no no
	assertFalse "no, no is false" $?

	k_bool_test no No
	assertFalse "no, No is false" $?

	k_bool_test no NO
	assertFalse "no, NO is false" $?

	k_bool_test no n
	assertFalse "no, n is false" $?

	k_bool_test no N
	assertFalse "no, N is false" $?

	k_bool_test no 0
	assertFalse "no, 0 is false" $?

	k_bool_test no off
	assertFalse "no, off is false" $?

	k_bool_test no Off
	assertFalse "no, Off is false" $?

	k_bool_test no OFF
	assertFalse "no, OFF is false" $?

	k_bool_test No
	assertFalse "No is false" $?

	k_bool_test No ''
	assertFalse "No, '' is false" $?

	k_bool_test No foo
	assertFalse "No, foo is false" $?

	k_bool_test No One
	assertFalse "No, One is false" $?

	k_bool_test No true
	assertFalse "No, true is false" $?

	k_bool_test No True
	assertFalse "No, True is false" $?

	k_bool_test No TRUE
	assertFalse "No, TRUE is false" $?

	k_bool_test No yes
	assertFalse "No, yes is false" $?

	k_bool_test No Yes
	assertFalse "No, Yes is false" $?

	k_bool_test No YES
	assertFalse "No, YES is false" $?

	k_bool_test No y
	assertFalse "No, y is false" $?

	k_bool_test No Y
	assertFalse "No, Y is false" $?

	k_bool_test No 1
	assertFalse "No, 1 is false" $?

	k_bool_test No on
	assertFalse "No, on is false" $?

	k_bool_test No On
	assertFalse "No, On is false" $?

	k_bool_test No ON
	assertFalse "No, ON is false" $?

	k_bool_test No false
	assertFalse "No, false is false" $?

	k_bool_test No False
	assertFalse "No, False is false" $?

	k_bool_test No FALSE
	assertFalse "No, FALSE is false" $?

	k_bool_test No no
	assertFalse "No, no is false" $?

	k_bool_test No No
	assertFalse "No, No is false" $?

	k_bool_test No NO
	assertFalse "No, NO is false" $?

	k_bool_test No n
	assertFalse "No, n is false" $?

	k_bool_test No N
	assertFalse "No, N is false" $?

	k_bool_test No 0
	assertFalse "No, 0 is false" $?

	k_bool_test No off
	assertFalse "No, off is false" $?

	k_bool_test No Off
	assertFalse "No, Off is false" $?

	k_bool_test No OFF
	assertFalse "No, OFF is false" $?

	k_bool_test NO
	assertFalse "NO is false" $?

	k_bool_test NO ''
	assertFalse "NO, '' is false" $?

	k_bool_test NO foo
	assertFalse "NO, foo is false" $?

	k_bool_test NO One
	assertFalse "NO, One is false" $?

	k_bool_test NO true
	assertFalse "NO, true is false" $?

	k_bool_test NO True
	assertFalse "NO, True is false" $?

	k_bool_test NO TRUE
	assertFalse "NO, TRUE is false" $?

	k_bool_test NO yes
	assertFalse "NO, yes is false" $?

	k_bool_test NO Yes
	assertFalse "NO, Yes is false" $?

	k_bool_test NO YES
	assertFalse "NO, YES is false" $?

	k_bool_test NO y
	assertFalse "NO, y is false" $?

	k_bool_test NO Y
	assertFalse "NO, Y is false" $?

	k_bool_test NO 1
	assertFalse "NO, 1 is false" $?

	k_bool_test NO on
	assertFalse "NO, on is false" $?

	k_bool_test NO On
	assertFalse "NO, On is false" $?

	k_bool_test NO ON
	assertFalse "NO, ON is false" $?

	k_bool_test NO false
	assertFalse "NO, false is false" $?

	k_bool_test NO False
	assertFalse "NO, False is false" $?

	k_bool_test NO FALSE
	assertFalse "NO, FALSE is false" $?

	k_bool_test NO no
	assertFalse "NO, no is false" $?

	k_bool_test NO No
	assertFalse "NO, No is false" $?

	k_bool_test NO NO
	assertFalse "NO, NO is false" $?

	k_bool_test NO n
	assertFalse "NO, n is false" $?

	k_bool_test NO N
	assertFalse "NO, N is false" $?

	k_bool_test NO 0
	assertFalse "NO, 0 is false" $?

	k_bool_test NO off
	assertFalse "NO, off is false" $?

	k_bool_test NO Off
	assertFalse "NO, Off is false" $?

	k_bool_test NO OFF
	assertFalse "NO, OFF is false" $?

	k_bool_test n
	assertFalse "n is false" $?

	k_bool_test n ''
	assertFalse "n, '' is false" $?

	k_bool_test n foo
	assertFalse "n, foo is false" $?

	k_bool_test n One
	assertFalse "n, One is false" $?

	k_bool_test n true
	assertFalse "n, true is false" $?

	k_bool_test n True
	assertFalse "n, True is false" $?

	k_bool_test n TRUE
	assertFalse "n, TRUE is false" $?

	k_bool_test n yes
	assertFalse "n, yes is false" $?

	k_bool_test n Yes
	assertFalse "n, Yes is false" $?

	k_bool_test n YES
	assertFalse "n, YES is false" $?

	k_bool_test n y
	assertFalse "n, y is false" $?

	k_bool_test n Y
	assertFalse "n, Y is false" $?

	k_bool_test n 1
	assertFalse "n, 1 is false" $?

	k_bool_test n on
	assertFalse "n, on is false" $?

	k_bool_test n On
	assertFalse "n, On is false" $?

	k_bool_test n ON
	assertFalse "n, ON is false" $?

	k_bool_test n false
	assertFalse "n, false is false" $?

	k_bool_test n False
	assertFalse "n, False is false" $?

	k_bool_test n FALSE
	assertFalse "n, FALSE is false" $?

	k_bool_test n no
	assertFalse "n, no is false" $?

	k_bool_test n No
	assertFalse "n, No is false" $?

	k_bool_test n NO
	assertFalse "n, NO is false" $?

	k_bool_test n n
	assertFalse "n, n is false" $?

	k_bool_test n N
	assertFalse "n, N is false" $?

	k_bool_test n 0
	assertFalse "n, 0 is false" $?

	k_bool_test n off
	assertFalse "n, off is false" $?

	k_bool_test n Off
	assertFalse "n, Off is false" $?

	k_bool_test n OFF
	assertFalse "n, OFF is false" $?

	k_bool_test N
	assertFalse "N is false" $?

	k_bool_test N ''
	assertFalse "N, '' is false" $?

	k_bool_test N foo
	assertFalse "N, foo is false" $?

	k_bool_test N One
	assertFalse "N, One is false" $?

	k_bool_test N true
	assertFalse "N, true is false" $?

	k_bool_test N True
	assertFalse "N, True is false" $?

	k_bool_test N TRUE
	assertFalse "N, TRUE is false" $?

	k_bool_test N yes
	assertFalse "N, yes is false" $?

	k_bool_test N Yes
	assertFalse "N, Yes is false" $?

	k_bool_test N YES
	assertFalse "N, YES is false" $?

	k_bool_test N y
	assertFalse "N, y is false" $?

	k_bool_test N Y
	assertFalse "N, Y is false" $?

	k_bool_test N 1
	assertFalse "N, 1 is false" $?

	k_bool_test N on
	assertFalse "N, on is false" $?

	k_bool_test N On
	assertFalse "N, On is false" $?

	k_bool_test N ON
	assertFalse "N, ON is false" $?

	k_bool_test N false
	assertFalse "N, false is false" $?

	k_bool_test N False
	assertFalse "N, False is false" $?

	k_bool_test N FALSE
	assertFalse "N, FALSE is false" $?

	k_bool_test N no
	assertFalse "N, no is false" $?

	k_bool_test N No
	assertFalse "N, No is false" $?

	k_bool_test N NO
	assertFalse "N, NO is false" $?

	k_bool_test N n
	assertFalse "N, n is false" $?

	k_bool_test N N
	assertFalse "N, N is false" $?

	k_bool_test N 0
	assertFalse "N, 0 is false" $?

	k_bool_test N off
	assertFalse "N, off is false" $?

	k_bool_test N Off
	assertFalse "N, Off is false" $?

	k_bool_test N OFF
	assertFalse "N, OFF is false" $?

	k_bool_test 0
	assertFalse "0 is false" $?

	k_bool_test 0 ''
	assertFalse "0, '' is false" $?

	k_bool_test 0 foo
	assertFalse "0, foo is false" $?

	k_bool_test 0 One
	assertFalse "0, One is false" $?

	k_bool_test 0 true
	assertFalse "0, true is false" $?

	k_bool_test 0 True
	assertFalse "0, True is false" $?

	k_bool_test 0 TRUE
	assertFalse "0, TRUE is false" $?

	k_bool_test 0 yes
	assertFalse "0, yes is false" $?

	k_bool_test 0 Yes
	assertFalse "0, Yes is false" $?

	k_bool_test 0 YES
	assertFalse "0, YES is false" $?

	k_bool_test 0 y
	assertFalse "0, y is false" $?

	k_bool_test 0 Y
	assertFalse "0, Y is false" $?

	k_bool_test 0 1
	assertFalse "0, 1 is false" $?

	k_bool_test 0 on
	assertFalse "0, on is false" $?

	k_bool_test 0 On
	assertFalse "0, On is false" $?

	k_bool_test 0 ON
	assertFalse "0, ON is false" $?

	k_bool_test 0 false
	assertFalse "0, false is false" $?

	k_bool_test 0 False
	assertFalse "0, False is false" $?

	k_bool_test 0 FALSE
	assertFalse "0, FALSE is false" $?

	k_bool_test 0 no
	assertFalse "0, no is false" $?

	k_bool_test 0 No
	assertFalse "0, No is false" $?

	k_bool_test 0 NO
	assertFalse "0, NO is false" $?

	k_bool_test 0 n
	assertFalse "0, n is false" $?

	k_bool_test 0 N
	assertFalse "0, N is false" $?

	k_bool_test 0 0
	assertFalse "0, 0 is false" $?

	k_bool_test 0 off
	assertFalse "0, off is false" $?

	k_bool_test 0 Off
	assertFalse "0, Off is false" $?

	k_bool_test 0 OFF
	assertFalse "0, OFF is false" $?

	k_bool_test off
	assertFalse "off is false" $?

	k_bool_test off ''
	assertFalse "off, '' is false" $?

	k_bool_test off foo
	assertFalse "off, foo is false" $?

	k_bool_test off One
	assertFalse "off, One is false" $?

	k_bool_test off true
	assertFalse "off, true is false" $?

	k_bool_test off True
	assertFalse "off, True is false" $?

	k_bool_test off TRUE
	assertFalse "off, TRUE is false" $?

	k_bool_test off yes
	assertFalse "off, yes is false" $?

	k_bool_test off Yes
	assertFalse "off, Yes is false" $?

	k_bool_test off YES
	assertFalse "off, YES is false" $?

	k_bool_test off y
	assertFalse "off, y is false" $?

	k_bool_test off Y
	assertFalse "off, Y is false" $?

	k_bool_test off 1
	assertFalse "off, 1 is false" $?

	k_bool_test off on
	assertFalse "off, on is false" $?

	k_bool_test off On
	assertFalse "off, On is false" $?

	k_bool_test off ON
	assertFalse "off, ON is false" $?

	k_bool_test off false
	assertFalse "off, false is false" $?

	k_bool_test off False
	assertFalse "off, False is false" $?

	k_bool_test off FALSE
	assertFalse "off, FALSE is false" $?

	k_bool_test off no
	assertFalse "off, no is false" $?

	k_bool_test off No
	assertFalse "off, No is false" $?

	k_bool_test off NO
	assertFalse "off, NO is false" $?

	k_bool_test off n
	assertFalse "off, n is false" $?

	k_bool_test off N
	assertFalse "off, N is false" $?

	k_bool_test off 0
	assertFalse "off, 0 is false" $?

	k_bool_test off off
	assertFalse "off, off is false" $?

	k_bool_test off Off
	assertFalse "off, Off is false" $?

	k_bool_test off OFF
	assertFalse "off, OFF is false" $?

	k_bool_test Off
	assertFalse "Off is false" $?

	k_bool_test Off ''
	assertFalse "Off, '' is false" $?

	k_bool_test Off foo
	assertFalse "Off, foo is false" $?

	k_bool_test Off One
	assertFalse "Off, One is false" $?

	k_bool_test Off true
	assertFalse "Off, true is false" $?

	k_bool_test Off True
	assertFalse "Off, True is false" $?

	k_bool_test Off TRUE
	assertFalse "Off, TRUE is false" $?

	k_bool_test Off yes
	assertFalse "Off, yes is false" $?

	k_bool_test Off Yes
	assertFalse "Off, Yes is false" $?

	k_bool_test Off YES
	assertFalse "Off, YES is false" $?

	k_bool_test Off y
	assertFalse "Off, y is false" $?

	k_bool_test Off Y
	assertFalse "Off, Y is false" $?

	k_bool_test Off 1
	assertFalse "Off, 1 is false" $?

	k_bool_test Off on
	assertFalse "Off, on is false" $?

	k_bool_test Off On
	assertFalse "Off, On is false" $?

	k_bool_test Off ON
	assertFalse "Off, ON is false" $?

	k_bool_test Off false
	assertFalse "Off, false is false" $?

	k_bool_test Off False
	assertFalse "Off, False is false" $?

	k_bool_test Off FALSE
	assertFalse "Off, FALSE is false" $?

	k_bool_test Off no
	assertFalse "Off, no is false" $?

	k_bool_test Off No
	assertFalse "Off, No is false" $?

	k_bool_test Off NO
	assertFalse "Off, NO is false" $?

	k_bool_test Off n
	assertFalse "Off, n is false" $?

	k_bool_test Off N
	assertFalse "Off, N is false" $?

	k_bool_test Off 0
	assertFalse "Off, 0 is false" $?

	k_bool_test Off off
	assertFalse "Off, off is false" $?

	k_bool_test Off Off
	assertFalse "Off, Off is false" $?

	k_bool_test Off OFF
	assertFalse "Off, OFF is false" $?

	k_bool_test OFF
	assertFalse "OFF is false" $?

	k_bool_test OFF ''
	assertFalse "OFF, '' is false" $?

	k_bool_test OFF foo
	assertFalse "OFF, foo is false" $?

	k_bool_test OFF One
	assertFalse "OFF, One is false" $?

	k_bool_test OFF true
	assertFalse "OFF, true is false" $?

	k_bool_test OFF True
	assertFalse "OFF, True is false" $?

	k_bool_test OFF TRUE
	assertFalse "OFF, TRUE is false" $?

	k_bool_test OFF yes
	assertFalse "OFF, yes is false" $?

	k_bool_test OFF Yes
	assertFalse "OFF, Yes is false" $?

	k_bool_test OFF YES
	assertFalse "OFF, YES is false" $?

	k_bool_test OFF y
	assertFalse "OFF, y is false" $?

	k_bool_test OFF Y
	assertFalse "OFF, Y is false" $?

	k_bool_test OFF 1
	assertFalse "OFF, 1 is false" $?

	k_bool_test OFF on
	assertFalse "OFF, on is false" $?

	k_bool_test OFF On
	assertFalse "OFF, On is false" $?

	k_bool_test OFF ON
	assertFalse "OFF, ON is false" $?

	k_bool_test OFF false
	assertFalse "OFF, false is false" $?

	k_bool_test OFF False
	assertFalse "OFF, False is false" $?

	k_bool_test OFF FALSE
	assertFalse "OFF, FALSE is false" $?

	k_bool_test OFF no
	assertFalse "OFF, no is false" $?

	k_bool_test OFF No
	assertFalse "OFF, No is false" $?

	k_bool_test OFF NO
	assertFalse "OFF, NO is false" $?

	k_bool_test OFF n
	assertFalse "OFF, n is false" $?

	k_bool_test OFF N
	assertFalse "OFF, N is false" $?

	k_bool_test OFF 0
	assertFalse "OFF, 0 is false" $?

	k_bool_test OFF off
	assertFalse "OFF, off is false" $?

	k_bool_test OFF Off
	assertFalse "OFF, Off is false" $?

	k_bool_test OFF OFF
	assertFalse "OFF, OFF is false" $?
}



test_k_bool_valid (){
	k_bool_valid ''
	assertFalse "'' is invalid" $?

	k_bool_valid foo
	assertFalse "foo is invalid" $?

	k_bool_valid One
	assertFalse "One is invalid" $?

	k_bool_valid true
	assertTrue "true is valid" $?

	k_bool_valid True
	assertTrue "True is valid" $?

	k_bool_valid TRUE
	assertTrue "TRUE is valid" $?

	k_bool_valid yes
	assertTrue "yes is valid" $?

	k_bool_valid Yes
	assertTrue "Yes is valid" $?

	k_bool_valid YES
	assertTrue "YES is valid" $?

	k_bool_valid y
	assertTrue "y is valid" $?

	k_bool_valid Y
	assertTrue "Y is valid" $?

	k_bool_valid 1
	assertTrue "1 is valid" $?

	k_bool_valid on
	assertTrue "on is valid" $?

	k_bool_valid On
	assertTrue "On is valid" $?

	k_bool_valid ON
	assertTrue "ON is valid" $?

	k_bool_valid false
	assertTrue "false is valid" $?

	k_bool_valid False
	assertTrue "False is valid" $?

	k_bool_valid FALSE
	assertTrue "FALSE is valid" $?

	k_bool_valid no
	assertTrue "no is valid" $?

	k_bool_valid No
	assertTrue "No is valid" $?

	k_bool_valid NO
	assertTrue "NO is valid" $?

	k_bool_valid n
	assertTrue "n is valid" $?

	k_bool_valid N
	assertTrue "N is valid" $?

	k_bool_valid 0
	assertTrue "0 is valid" $?

	k_bool_valid off
	assertTrue "off is valid" $?

	k_bool_valid Off
	assertTrue "Off is valid" $?

	k_bool_valid OFF
	assertTrue "OFF is valid" $?

}

