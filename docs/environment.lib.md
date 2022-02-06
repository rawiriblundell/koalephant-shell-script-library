---
title: environment.lib.sh
version: 2.8.1
copyright: 2014, Koalephant Co., Ltd
author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
description: Environment handling functionality (Koalephant Shell Script Library)
---

### `$KOALEPHANT_ENVIRONMENT_PREFIX`
Prefix to use when setting environment variables

### `k_env_safename`
Make sure a name is safe for use as a variable name

#### Input:
 * `$1` - the name to make safe

#### Output:
The save variable name

### `k_env_set`
Set a local variable
Useful to set a variable using a generated name, i.e. variable variables.

#### Input:
 * `$1` - the name of the variable to set
 * `$2` - the value to set

### `k_env_unset`
Unset one or more environment variables

#### Input:
 * `$1...n variables to unset from the environment` - $1...n variables to unset from the environment

### `k_env_export`
Export one or more environment variables

#### Input:
 * `$1...n variables to export for child processes` - $1...n variables to export for child processes

### `k_env_unexport`
Un-Export one or more environment variables

#### Input:
 * `$1...n` - variables to un-export

### `k_env_import_gecos`
Import environment variables from the GECOS field

#### Input:
 * `$1 the user to import from. Defaults to the current logged in user.` - $1 the user to import from. Defaults to the current logged in user.

### `$userName`
If no argument is provided, use $USER

### `k_env_export_gecos`
Export environment variables previously imported with [`k_env_import_gecos`](#k_env_import_gecos)

### `k_env_unset_gecos`
Unset environment variables previously imported with {k_env_import_gecos}

### `k_env_import_apache`
Import environment variables from an apache config file

#### Input:
 * `$1` - the apache config file to set environment variables from

### `k_env_export_apache`
Export environment variables previously imported with [`k_env_import_apache`](#k_env_import_apache)

### `k_env_unset_apache`
Unset environment variables previously imported with @link k_env_import_apache @/link

### `k_env_unexport_apache`
Un-Export environment variables previously exported with @link k_env_import_apache @/link

### `k_env_import_ldap`
Import environment variables from an LDAP object as environment variables

#### Input:
 * `$1` - filter the mode to operate in, set or unset
 * `$2...n` - the attributes to fetch

### `$if [ -d "${KOALEPHANT_LIB_PATH}/ldap-attr-maps" ]; then`
attribute renaming maps:

### `k_env_export_ldap`
Export environment variables previously imported with @link k_env_import_ldap @/link

### `k_env_unset_ldap`
Unset environment variables previously imported with @link k_env_import_ldap @/link

