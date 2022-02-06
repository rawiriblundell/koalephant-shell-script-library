---
title: fs.lib.sh
version: 2.8.1
copyright: 2017, Koalephant Co., Ltd
author: Stephen Reay <stephen@koalephant.com>, Koalephant Packaging Team <packages@koalephant.com>
description: Filesystem functionality (Koalephant Shell Script Library)
---

### `k_fs_resolve`
Resolve a given filesystem path to an absolute path

#### Input:
 * `$1` - the path to resolve

#### Output:
the resolved path

### `$dir`
Prefix relative paths with current path

### `k_fs_basename`
Get the base name of a filesystem path, optionally with an extension removed

#### Input:
 * `$1` - the path to get the basename of
 * `$2` - the extension to remove if found

#### Output:
the base name of the given path

### `k_fs_extension`
Get the extension of a filesystem path

#### Input:
 * `$1` - the path to get the extension of
 * `$2` - flag to get all extension parts, rather than just the last part. Defaults to false.

#### Output:
the extension of the given path, if it has one

#### Example:
~~~sh
k_fs_extension foo.bar.baz [false] // baz
k_fs_extension foo.bar.baz true // bar.baz
~~~

### `k_fs_dirname`
Get the parent directory path of a filesystem path

#### Input:
 * `$1` - the path to get the parent directory path of

#### Output:
the parent directory name of the given path

### `k_fs_temp_get_raw`
Low level function to create a temporary file or directory, or lookup the system temp dir.
Note, this does *not* register the created files/directories for cleanup.
Generally you should not use this, it's used by [`k_fs_temp_dir`](#k_fs_temp_dir) and [`k_fs_temp_file`](#k_fs_temp_file)

#### Input:
 * `$0` - the type to create: either 'file', 'dir' or 'parent'
 * `$KOALEPHANT_TMP_USE_MEM` - flag to try to use a memory-based filesystem if possible
 * `$KOALEPHANT_TMP_REQ_MEM` - flag to require a memory-based filesystem, and error if not possible

#### Output:
the generated file or directory name.

#### Return:
0 if the temp file/dir was created, 2 if neither `mktemp` nor `/dev/urandom` is available

### `k_fs_temp_dir`
Get a temp directory

#### Input:
 * `$KOALEPHANT_TMP_USE_MEM` - flag to try to use a memory-based filesystem if possible
 * `$KOALEPHANT_TMP_REQ_MEM` - flag to require a memory-based filesystem, and error if not possible

#### Output:
the temp directory path

### `k_fs_temp_file`
Get a temp file

#### Input:
 * `$KOALEPHANT_TMP_USE_MEM` - flag to try to use a memory-based filesystem if possible
 * `$KOALEPHANT_TMP_REQ_MEM` - flag to require a memory-based filesystem, and error if not possible

#### Output:
the temp file path

### `k_fs_register_temp_file`
Register a file as temporary, for automatic cleanup

#### Input:
 * `$1...n the filename(s) to register as temporary files` - $1...n the filename(s) to register as temporary files

### `k_fs_predictable_dir`
Get a 'predictable' temporary directory
The directory path is generated using constants for this process, so they can be retrieved within a trap callback

#### Input:
 * `$1` - the basename for the directory. If not specified, the output of [`k_tool_name`](#k_tool_name) is used
 * `$2` - the optional suffix for the directory
 * `$KOALEPHANT_TMP_USE_MEM` - flag to try to use a memory-based filesystem if possible
 * `$KOALEPHANT_TMP_REQ_MEM` - flag to require a memory-based filesystem, and error if not possible

#### Output:
the temporary directory name

#### Return:
0 if the directory is usable, 1 if it cannot be used due to a file existing with the same name.

### `k_fs_predictable_file`
Get a 'predictable' temporary file
The file path is generated using constants for this process, so they can be retrieved within a trap callback

#### Input:
 * `$1` - the basename for the file. If not specified, the output of [`k_tool_name`](#k_tool_name) is used
 * `$2` - the optional suffix for the filename
 * `$KOALEPHANT_TMP_USE_MEM` - flag to try to use a memory-based filesystem if possible
 * `$KOALEPHANT_TMP_REQ_MEM` - flag to require a memory-based filesystem, and error if not possible

#### Output:
the temporary file name

#### Return:
0 if the file is usable, 1 if it cannot be used due to a directory existing with the same name.

### `k_fs_temp_cleanup`
Cleanup temp files and directories

### `k_fs_perms_useronly`
Make a file/directory accessible only by the named or current user
Changes user/group ownership and sets read/write (+executable if a directory or already executable) permission to user only

#### Input:
 * `$1` - the path to set ownership/permissions on
 * `$2` - the username to set ownership to. If omitted, uses the current user
 * `$3` - the group to set ownership to. If omitted, uses the current user's primary group

### `k_fs_temp_exit`
Run [`k_fs_temp_cleanup`](#k_fs_temp_cleanup) when the program exits.
This uses trap to listen for the signals INT TERM QUIT EXIT HUP
This should handle most causes of exit:
Regular program close, Ctrl-C, SIGHUP, etc.
Note: This does NOT cleanup temp files if the program receives the ABRT signal.
Use [`k_fs_temp_abort`](#k_fs_temp_abort) to cleanup on ABRT.

### `k_fs_temp_abort`
Run [`k_fs_temp_cleanup`](#k_fs_temp_cleanup) when the program is killed.
This uses trap to listen for the signal ABRT
Note: This will ONLY cleanup temp files if the program receives the ABRT signal.
Use [`k_fs_temp_exit`](#k_fs_temp_exit) to cleanup on INT TERM QUIT EXIT HUP.

### `k_fs_dir_empty`
Checks if a path is an empty directory

#### Input:
 * `$1` - the path to check

#### Return:
0 if the path is an empty directory, 1 if not empty, 2 if not a directory

