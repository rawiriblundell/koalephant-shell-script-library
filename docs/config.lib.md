---
title: config.lib.sh
version: 2.8.1
copyright: 2017, Koalephant Co., Ltd
author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
description: Config file functionality (Koalephant Shell Script Library)
---

### `$KOALEPHANT_CFGET_PATH`
`readonly` Path to cfget binary

### `$KOALEPHANT_CONFIG_MODULES_LOADED`
List of loaded Config modules

### `k_config_command`
Run a cfget command

#### Input:
 * `$1` - the config file
 * `$2...n` - extra arguments for cfget

#### Output:
The result from cfget

#### Return:
The cfget return code
Deprecated
As of v2.5.0, use [`k_config_op`](#k_config_op) instead

### `k_config_op`
Perform a config file operation

#### Input:
 * `$1` - the operation to perform, one of 'sections', 'keys', 'read', 'write', 'avail', 'whoami' or 'load'
 * `$2` - the config file
 * `$3...n` - extra arguments for the operation
 * `$KOALEPHANT_CONFIG_MODULE an override to use a specific config moduleName` - $KOALEPHANT_CONFIG_MODULE an override to use a specific config moduleName

#### Output:
The result from the config moduleName

#### Return:
0 unless attempting to read a non-existent key, then 1, or no config moduleName is usable, then 2.

### `k_config_modules`
Print a list of loaded config modules

#### Output:
The moduleName names

### `k_config_sections`
Get config sections

#### Input:
 * `$1` - the config file
 * `$2` - the config root to work from, defaults to empty

#### Output:
the section names, one per line

### `k_config_keys`
Get config keys

#### Input:
 * `$1` - the config file
 * `$2` - the config root to work from

#### Output:
the key names, one per line

### `k_config_read`
Read a Config Value
Unlike [`k_config_read_error`](#k_config_read_error), this function will not error if the config key is not found

#### Input:
 * `$1` - the config file
 * `$2` - the key to read
 * `$3` - the config root to work from

#### Output:
the value of the key, if it exists

### `k_config_read_error`
Read a Config Value, or error

#### Input:
 * `$1` - the config file
 * `$2` - the key to read
 * `$3` - the config root to work from

#### Output:
the value of the key, if it exists

#### Return:
0 on success, 1 on error

### `k_config_read_string`
Get a Config value or a default value

#### Input:
 * `$1` - the config file
 * `$2` - the key to read
 * `$3` - the default value (defaults to empty string)
 * `$4` - the config root to work from

#### Output:
the value of the key, or the default value

### `k_config_read_bool`
Get a 'Boolean' Config value or a default value

#### Input:
 * `$1` - the config file
 * `$2` - the key to read
 * `$3` - the default value (defaults to empty string)
 * `$4` - the config root to work from

#### Output:
`true`, `false` or the default value given if the config value cannot be parsed using [`k_bool_parse`](bool.lib#k_bool_parse)

### `k_config_test_bool`
Test a 'Boolean' Config value or a default value

#### Input:
 * `$1` - the config file
 * `$2` - the key to read
 * `$3` - the default value (defaults to empty string)
 * `$4` - the config root to work from

#### Return:
0 if either the config value or the default value is true, 1 otherwise

### `k_config_read_keyword`
Get a 'keyword' Config value or a default value

#### Input:
 * `$1` - the config file
 * `$2` - the key to read
 * `$3` - the default value
 * `$4` - the config root to work from
 * `$5...n` - the list of valid keyword values

#### Output:
the valid keyword or default value

### `k_config_write_error`
Write a Config Value, or error

#### Input:
 * `$1` - the config file
 * `$2` - the key to write to
 * `$3` - the value to write
 * `$4` - the config root to work from

#### Return:
0 on success, 1 on error

### `k_config_file_check_readable`
Check that a readable file has been provided

#### Input:
 * `$1` - the file pathname to try to read

#### Return:
0 if the file pathname is readable, 1 if not

### `k_config_file_check_writable`
Check that a writable file has been provided

#### Input:
 * `$1` - the file pathname to try to read

#### Output:
the file pathname, if readable.

#### Return:
0 if the file pathname is readable, 1 if not

