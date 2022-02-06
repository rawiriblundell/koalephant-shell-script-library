---
title: gpg.lib.sh
version: 2.8.1
copyright: 2014, Koalephant Co., Ltd
author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
description: GPG functionality (Koalephant Shell Script Library)
---

### `$KOALEPHANT_GPG_PATH`
`readonly` Path to gpg binary

### `k_gpg_list_keys_public`
List GPG Public Key ID's

#### Input:
 * `$1...n` - query key id/name/email to query for, if set

#### Output:
the public key ID, if one or more keys are found

### `k_gpg_list_keys_secret`
List GPG Secret Key ID's

#### Input:
 * `$1...n` - query key id/name/email to query for, if set

#### Output:
the secret key ID, if one or more keys are found

### `k_gpg_create`
Generate a new GPG Key

#### Input:
 * `$1` - the name for the key
 * `$2` - the email for the key
 * `$3` - optional comment for the key
 * `$4` - optional passphrase for the key. If not supplied, the key will not be protected with a passphrase!

#### Output:
the new Key ID

#### Return:
the exit code from gpg, usually 0 for success and 1 for error

### `k_gpg_password_prompt`
Prompt for a new GPG Key Passphrase

#### Input:
 * `$1` - the ID of the Key to set a passphrase for

#### Return:
the exit code from gpg, usually 0 for success and 1 for error

### `k_gpg_export_armored`
Export an ascii-armored GPG Key
Input
$1 - the ID of the Key to export
$2 - the destination to export the key to. If a directory is given, a file named with the Key ID and a ".asc" extension will be created in the directory

#### Return:
the exit code from gpg, usually 0 for success and 1 for error

### `k_gpg_export`
Export a binary GPG key
Input
$1 - the ID of the Key to export
$2 - the destination to export the key to. If a directory is given, a file named with the Key ID and a ".gpg" extension will be created in the directory

#### Return:
the exit code from gpg, usually 0 for success and 1 for error

### `k_gpg_search_keys`
Search for public keys on the configured keyserver(s)

#### Input:
 * `$1 - the query term` - usually a key ID, email or name.

#### Output:
The

### `k_gpg_receive_keys`
Add a public key from the configured keyserver(s)

#### Input:
 * `$1...n` - the key IDs to add

#### Output:
The GPG message

### `k_gpg_keyid_valid`
Check if a variable is in a valid key-id format

#### Input:
 * `$1` - the variable to check

#### Return:
0 if valid, 1 if not

