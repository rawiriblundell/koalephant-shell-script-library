---
title: number.lib.sh
version: 2.8.1
copyright: 2014-2019, Koalephant Co., Ltd
author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
description: String functionality (Koalephant Shell Script Library)
---

### `k_int_parse`
Parse a string into an integer
Accepts decimal or hex values, any precision (right of the decimal point) is lost

#### Input:
 * `$1` - the string to parse
 * `$2` - the default value to return if the string is not an integer

#### Output:
an integer or the default value if specified

#### Return:
0 if either the first or second argument can be parsed to int, 1 if not

### `k_int_parse_error`
Parse a string into an integer or error
Accepts decimal or hex values, any precision (right of the decimal point) is lost

#### Input:
 * `$1` - the string to parse

#### Output:
an integer

#### Return:
0 if the string can be parsed to an integer 1 if not

### `k_int_min`
Get the lowest of a series of integers

#### Input:
 * `$1...n` - the integers to get the lowest of

#### Output:
the lowest value
Return
1 if any of the numbers cannot be parsed to an integer

### `k_int_max`
Get the highest of a series of integers

#### Input:
 * `$1...n` - the integers to get the highest of

#### Output:
the highest value
Return
1 if any of the numbers cannot be parsed to an integer

### `k_int_sum`
Get the sum of a series of integers

#### Input:
 * `$1...n` - the integers to get sum average of

#### Output:
the sum of the values
Return
1 if any of the numbers cannot be parsed to an integer

### `k_int_avg`
Get the average of a series of integers

#### Input:
 * `$1...n` - the integers to get the average of

#### Output:
the average value
Return
1 if any of the numbers cannot be parsed to an integer

