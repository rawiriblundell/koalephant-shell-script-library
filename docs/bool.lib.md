---
title: bool.lib.sh
version: 2.8.1
copyright: 2014, Koalephant Co., Ltd
author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
description: Boolean functionality (Koalephant Shell Script Library)
---

### `k_bool_parse`
Parse a string into 'true' or 'false'
'true' values are 'on', 'true', 'yes', 'y' and '1', regardless of case
'false' values are 'off', 'false' 'no', 'n' and '0', regardless of case

#### Input:
 * `$1` - the string to parse
 * `$2` - the default value to return if neither true or false is matched

#### Output:
either 'true' or 'false' or the default value if specified

### `k_bool_keyword`
Parse a string into 'true' or 'false' or error
'true' values are 'on', 'true', 'yes', 'y' and '1', regardless of case
'false' values are 'off', 'false' 'no', 'n' and '0', regardless of case

#### Input:
 * `$1` - the string to parse

#### Output:
either 'true' or 'false'

#### Return:
0 if a valid bool value is given, 1 if not

### `k_bool_status`
Parse a string into a return code representing true, false or error
'true' values are 'on', 'true', 'yes', 'y' and '1', regardless of case
'false' values are 'off', 'false' 'no', 'n' and '0', regardless of case

#### Input:
 * `$1` - the string to parse

#### Return:
0 if the string parsed as true, 1 if parsed as false, 2 otherwise

### `k_bool_test`
Test a variable for truthiness.
Uses [`k_bool_parse`](#k_bool_parse) to parse input

#### Input:
 * `$1` - the variable to test
 * `$2` - the default value to test if neither true or false is matched

#### Return:
0 if true, 1 if not

#### Example:
~~~sh
if k_string_test_bool "${optionValue}"; then
	do_something
fi
~~~

### `k_bool_valid`
Test a variable for booelan-ness
Uses [`k_bool_parse`](#k_bool_parse) to parse input

#### Input:
 * `$1` - the variable to test

#### Return:
0 if a valid boolean value, 1 if not

