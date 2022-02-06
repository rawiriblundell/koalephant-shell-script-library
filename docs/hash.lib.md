---
title: hash.lib.sh
version: 2.8.1
copyright: 2019, Koalephant Co., Ltd
author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
description: Hashing functionality (Koalephant Shell Script Library)
---

### `$KOALEPHANT_HASH_MODULES_LOADED`
List of loaded Hash modules

### `k_hash_op`
Perform a hash operation

#### Input:
 * `$1` - the operation to perform, one of 'verify', 'generate', 'avail' and 'whoami' or 'load'
 * `$2...n` - extra arguments for the operation
 * `$KOALEPHANT_HASH_MODULE an override to use a specific hash module` - $KOALEPHANT_HASH_MODULE an override to use a specific hash module

#### Output:
The result from the hash module

#### Return:
0 unless error, then 1, or no hash module is usable, then 2.

### `k_hash_modules`
Print a list of loaded hash modules

#### Output:
The module names

### `k_hash_algos`
Print a list of hash algorithms supported by the loaded modules

#### Output:
The algorithm names

### `k_hash_verify`
Verify a file against a hash/checksum

#### Input:
 * `$1` - the hash/checksum algorithm. Use `k_hash_alogs()` to get a list of supported algorithms
 * `$2` - the file to verify the hash against, or `-` to use stdin
 * `$3` - the known hash/checksum

#### Return:
0 if the hash is verified, 1 if not

### `k_hash_generate`
Verify a file against a hash/checksum

#### Input:
 * `$1` - the hash/checksum algorithm. Use `k_hash_alogs()` to get a list of supported algorithms
 * `$2` - the file to generate the hash for, or `-` to use stdin

#### Return:
0 if the hash is verified, 1 if not

