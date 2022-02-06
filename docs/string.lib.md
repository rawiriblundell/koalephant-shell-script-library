---
title: string.lib.sh
version: 2.8.1
copyright: 2014-2017, Koalephant Co., Ltd
author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
description: String functionality (Koalephant Shell Script Library)
---

### `k_string_get_line`
Get a line from a multiline variable

#### Input:
 * `$1` - the line number to fetch, starting from 1
 * `$2...n` - all remaining arguments are treated as the text to search. If `$2` is `-` or arg count is < 2, reads from STDIN.

#### Output:
The text on the specified line

### `k_string_get_lines`
Get multiple lines from a multiline variable

#### Input:
 * `$1` - the first line number to fetch, starting from 1
 * `$2` - the number of lines to fetch
 * `$3...n` - all remaining arguments are treated as the text to search. If `$3` is `-` or arg count is < 3, reads from STDIN.

#### Output:
The text on the specified lines

### `k_string_pad_right`
Right Pad a string to the given length

#### Input:
 * `$1` - the length to pad to
 * `$2...n` - all remaining arguments are treated as the text to pad. If `$2` is `-` or arg count is < 2, reads from STDIN.

#### Output:
The string, with padding applied

### `k_string_pad_left`
Left Pad a string to the given length

#### Input:
 * `$1` - the length to pad to
 * `$2...n` - all remaining arguments are treated as the text to pad. If `$2` is `-` or arg count is < 2, reads from STDIN.

#### Output:
The string, with padding applied

### `k_string_lower`
Convert a string to lower case

#### Input:
 * `$1...n` - all arguments are treated as the text to convert. If `$1` is `-` or arg count is < 1, reads from STDIN.

#### Output:
The string, converted to lower case

### `k_string_upper`
Convert a string to upper case

#### Input:
 * `$1...n` - all arguments are treated as the text to convert. If `$1` is `-` or arg count is < 1, reads from STDIN.

#### Output:
The string, converted to upper case

### `k_string_contains`
Test if a string contains the given substring

#### Input:
 * `$1` - the substring to check for
 * `$2...n` - all arguments are treated as the string to check in. If `$2` is `-` or arg count is < 2, reads from STDIN.

#### Return:
0 if substring is found, 1 if not

### `k_string_starts_with`
Test if a string starts with the given substring

#### Input:
 * `$1` - the substring to check for
 * `$2...n` - all arguments are treated as the string to check in. If `$2` is `-` or arg count is < 2, reads from STDIN.

#### Return:
0 if the string starts with substring, 1 if not

### `k_string_ends_with`
Test if a string ends with the given substring

#### Input:
 * `$1` - the substring to check for
 * `$2...n` - all arguments are treated as the string to check in. If `$2` is `-` or arg count is < 2, reads from STDIN.

#### Return:
0 if the string ends with substring, 1 if not

### `k_string_remove_start`
Remove a substring from the start of a string

#### Input:
 * `$1` - the substring to remove
 * `$2...n` - all arguments are treated as the string to operate on. If `$2` is `-` or arg count is < 2, reads from STDIN.
 * `$REMOVE_GREEDY flag to enable greedy removal if the substring contains the '*' character` - $REMOVE_GREEDY flag to enable greedy removal if the substring contains the '*' character

#### Output:
The string with substring removed from the start

### `k_string_remove_end`
Remove a substring from the end of a string

#### Input:
 * `$1` - the substring to remove
 * `$2...n` - all arguments are treated as the string to operate on. If `$2` is `-` or arg count is < 2, reads from STDIN.
 * `$REMOVE_GREEDY flag to enable greedy removal if the substring contains the '*' character` - $REMOVE_GREEDY flag to enable greedy removal if the substring contains the '*' character

#### Output:
The string with substring removed from the end

### `k_string_join`
Join strings with an optional separator

#### Input:
 * `$1` - the separator string
 * `$2...n` - the strings to join

#### Output:
the strings joined by the separator

#### Example:
~~~sh
k_string_join "-" this is a nice day # "this-is-a-nice-day"
~~~

### `k_string_trim`
Remove leading and trailing whitespace from strings

#### Input:
 * `$1...n` - the strings to trim. If `$1` is `-` or arg count is < 1, reads from STDIN.

#### Output:
the strings with leading/trailing whitespace removed

### `k_string_keyword_error`
Check if the given keyword is in the list of valid keywords, or error

#### Input:
 * `$1` - the input to check
 * `$2...n` - the list of valid keywords

#### Output:
the keyword if valid

#### Return:
0 if keyword is valid, 1 if not

### `k_string_keyword`
Get the selected keyword from a list, or default

#### Input:
 * `$1` - the input to check
 * `$2...n` - the list of valid keywords. The last value is used as the default if none match

#### Output:
the valid keyword or default

### `k_string_prefix`
Prefix lines of text with a given string

#### Input:
 * `$1` - the string to prefix each string with.
 * `$2...n` - The strings to indent. Args are joined by newline character. If `$2` is `-` or arg count is < 2, reads from STDIN.

### `k_string_indent`
Indent lines of text by given number of spaces

#### Input:
 * `$1` - the indent level to apply.
 * `$2...n` - The strings to indent. Args are joined by newline character. If `$2` is `-` or arg count is < 2, reads from STDIN.

#### Output:
the indented lines of text

#### Return:
1 if indent level cannot be parsed as an integer, 0 otherwise.

### `k_string_wrap`
Wrap lines of text to a given length, splitting by words when possible

#### Input:
 * `$1` - the maximum line length to allow. If < 1, disables wrapping.
 * `$2...n` - the strings to wrap. Args are joined by newline character. If `$2` is `-` or arg count is < 2, reads from STDIN.

