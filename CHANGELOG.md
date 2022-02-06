# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [2.8.1] - 2020-05-02
### Fixed
- Help output alignment in `k-tool-install`

## [2.8.0] - 2020-04-10
### Added
- `k_tool_description_add`, `k_tool_description_code_add` for adding formatted blocks of text/code to 'help' output.
- `k_tool_usage_text`, `k_tool_usage_code` for formatting blocks of test/code to use in 'help' output.
- `k_tool_environment_add` for adding a defined environment variable to 'help' output
- `k_tool_environment_alias` for adding a defined environment variable alias to 'help' output
- `k_tool_environment_print` for printing defined environment 'help' output 
- `k_function_exists` for checking if a named function is defined

### Fixed
- Allow `k_fs_resolve` to resolve paths to non-existent files/directories 

### Deprecated
- `k_tool_options_text` use `k_tool_description_add` or `k_tool_usage_text` instead
- `k_tool_options_code` use `k_tool_description_code_add` or `k_tool_usage_code` instead

## [2.7.3] - 2020-03-13
### Fixed
- Fix a bug causing `k_fs_resolve` to return some paths ending with `/`
- Fix a hang when running GPG tests with low entropy 

## [2.7.2] - 2019-11-21
### Added
- Helper named 'provision' scripts in the Vagrantfile for `build`, `test` and `test-release`

### Fixed
- Handle lack of TTY device gracefully
- Fix a bug causing `k-script-build` to hang waiting for input when there is no TTY present.
- Resolved a circular dependency issue and an overridden recipe issue in the Makefile when building temporary `k-script-build-static` asset.
- Resolved sed-related issue preventing some string-handling functions working properly on BSD/macOS systems
- Improve fallback temp file handling
- Improved memory-backed tmp file testing on systems without tmpfs filesystems
- Fix GPG tests on macOS

## [2.7.1] - 2019-11-16
### Fixed
- Let `k-tool-install` pass value of `--version-opt` to detected binaries unquoted. 

## [2.7.0] - 2019-11-15
### Added
- `k_int_{min,max,sum,avg}()` functions, to get minimum, maximum, sum and average value from a series, respectively.
- `k_string_indent()` function to indent lines of text.
- `k_string_wrap()` function to word-wrap lines of text.
- `k_string_prefix()` function to apply a prefix to lines of text.
- `k_string_get_lines()` function to retrieve multiple lines from a string
- `k_tool_options_add()` function to add an entry for formatted options help text.
- `k_tool_options_alias()` function to add an alias entry for formatted options help text.
- `k_tool_options_print()` function to print all formatted options help text.
- `k_tool_options_text()` function to print descriptive help text.
- `k_tool_options_code()` function to print example code-like text.
- `k_tool_has_options()` function to determine whether a tool accepts options.
- `k_tty_width()` function to retrieve the column width of the TTY.
 
### Changed
- `k_string_{get_line,pad_right,pad_left,lower,upper,contains,starts_with,ends_with,remove_start,remove_end,trim}()` functions can read from STDIN.
- `k_options_{split,arg_required,arg_optional}()` functions can handle option values that start with a dash by setting `$KOALEPHANT_OPTIONS_ALLOW_DASH`.
- `k_options_arg_required()` function can accept empty-string option values by setting `$KOALEPHANT_OPTIONS_ALLOW_EMPTY`.
- `k_fs_temp_{get_raw,dir,file,predictable_dir,predictable_file}()` functions accept `$KOALEPHANT_TMP_USE_MEM` and `$KOALEPHANT_TMP_REQ_MEM` to try, and require using an in-memory filesystem, respectively.

### Fixed
- Prevent building release file with `unreleased` entry in CHANGELOG.
- Fix docs issue with `k_version_helper` specifying `$0` is input.
- Spelling mistakes in various shelldoc comments.
- A heap of unlikely-but-possible shell quoting issues.
- Ensure quotes and backticks in values are escaped in `k_env_set()`

## [2.6.2] - 2019-07-27
### Fixed
- Ensure dynamically loaded elements of library still work dynamically in a static script
- issue where `k-script-build` would error when processing a script provided via STDIN

## [2.6.1] - 2019-07-26
### Fixed
- missing date for 2.6.0 release
- missing version in generated `install.sh`

## [2.6.0] - 2019-07-26
### Added
- missing Unit tests for `k_gpg_*` and `k_fs_*` functions
- `k_fs_dir_empty()` function to check if a directory is empty
- `k_fs_temp_get_raw()` function to generate temporary names and get the system temp dir using either `mktemp` or `/dev/urandom`
- a generated 'install' script for use in other projects
- `k_hash_*` functions to support hash generation and verification using modules
- `php`, `shasum` and `algosum` modules for `k_hash_*` functions
- `k_config_modules()` function to list loaded config modules
- `k-tool-install` now supports hash verification on source archives
- `k-tool-install` now supports downloading via either `curl` or `wget`, depending on which is available

### Changed
- renamed `php` and `php_ro` config modules to `php-dba` and `php-ini` respectively
- moved config module functions into separate module files
- `k_options_split()`, `k_options_arg_required()` and `k_options_arg_optional()` now use a variable `$OPTION_VALUE_SET` to set/check if an option has been provided a value
- `k_options_arg_required()` now accepts a second boolean parameter, to accept an empty string value. Defaults to false 

### Fixed
- a bug in `k_fs_resolve()` with certain symlink paths
- `k_fs_temp_*()` and `k_fs_predictable_*()` functions now use `k_fs_temp_get_raw()` rather than `mktemp` directly
- a race condition bug in `k_fs_predictable_file()` when generating the predictable file for the first time
- a situation where `k_fs_predictable_file()` returned filenames without creating them
- k-tool-install erroneously always using `--dev` option with `install-deps.sh` scripts
- Ensure `shell-script-library.lib.sh` loader includes all components
- an issue where `k_log_*()` could error when writing to `stderr` in a subshell with different permissions (i.e. via `sudo` or `su` to a non-superuser account)
- small improvements to php and python scripts used by config modules
- `k-tool-install` options `--{local,url}-{path,suffix}` now accept an empty string value

## [2.5.4] - 2019-07-19
### Fixed
- failure to resolve symbolic links to absolute paths in some situations 

## [2.5.3] - 2019-07-19
### Fixed
- several sed compatibility issues on BSD-like systems
- ensure use of `command -v` over `which`
- ensure tools explicitly set `-e` and `-u`, regardless of how the shell is invoked
- handle python3 deprecation of `RawConfigParser.readfp`
- default to using `python` binary for `python2`
- ensure python2 config module is using python2
- fix `k_fs_perms_useronly()` function on BSD-like systems
- ensure `k_fs_temp_exit()` and `k_fs_temp_abort()` functions don't suppress original exit code
- fix `k_gpg_create()` function on BSD-like systems
- optimisation in `k_gpg_keyid_valid()` function to avoid a subshell
- accurately detect 'invalid' files (i.e. no trailing newline) and abort in `k-script-build` tool
- fixes for various tests that have false-positive failures or other issues on BSD-like systems
- documentation on `k_options_split()`

## [2.5.2] - 2019-05-26

### Fixed
- release/dist archive is not compressed via gzip

## [2.5.1] - 2019-05-23

### Added
- working tests for `k_gpg_*()` functions
- working tests for `k_fs_*()` functions

### Changed
- generate documentation from 'built' library files so that placeholder values (such as version) are correct

### Fixed
- calls to `tr` might fail due to locale settings
- ensure `$CDPATH` doesn't cause issues
- a bug in `k_fs_resolve()` with certain symlink paths
- missing Unit tests for `k_gpg_*` and `k_fs_*` functions
- a race condition bug in `k_fs_predictable_file()` when generating the predictable file for the first time
- a situation where `k_fs_predictable_file()` returned filenames without creating them
- documentation of return code for `k_fs_predictable_dir()` and `k_fs_predictable_file()` functions
- linked references in documentation for between `k_fs_temp_*()` functions
- incorrect function name used when triggering a required-arguments error in `k_log_level_parse()` function
- extraneous GPG output included in output from some `k_gpg_*()` functions
- number and string library files had a hard-coded version number

## [2.5.0] - 2019-05-14

### Added
- `k-version-compare` tool to wrap `k_version_compare` function for use in other scripts.
- `k-tool-install` tool to simplify installing a tool with a standard `install-deps, configure, make, make install` setup. 
- `$KOALEPHANT_LIB_NAME`, `$KOALEPHANT_LIB_OWNER` and `$KOALEPHANT_LIB_YEAR` constants.
- `k_tool_environment()` function to show environment variables read by a tool.
- `k_library_version()` function to show library info.
- `k_version_helper()` function to handle showing version information.
- `k_options_split()`, `k_options_arg_required()`, and `k_options_arg_optional()` functions to improve handling of option arguments.
- Support for handling deprecation info in shell docs to `k-shell-doc` tool
- `k_log_deprecated()` function to handle logging a deprecation message
- `k_config_op()` and `k_config_op*` functions to handle config file operations in a modular fashion
- `k_config_op_{php,php_ro,python2,python3}` modules for php (with dba extension), php (without dba extension, read only), python2 and python3 
- `k_config_write()` function allows writing to config (ini-formatted) files
- `--with-cfget` flag for `configure` to enable building with CFGET bin path set (also activated when using option `--cfget`)
- Tests now run in up to four shells, if installed: `dash`, `bash`, `posh` and `mksh`.
- Full unit test coverage
- `k_log_level_parse()` function to parse and output a log level, or report an error if invalid


### Changed
- `k_usage()` function includes information from `k_tool_environment()`
- `k_version_compare()` function accepts =, !=, >, <, >= and <= comparison operators as aliases of the existing letter-based operators.
- `k_log_*()` functions optionally accept a printf format string as the first argument.
- `k_config_*` functions are refactored to remove the reliance on `cfget` tool, instead using either a PHP, Python2 or Python3 script depending on availability
- Defaults to building without cfget (see `--with-cfget`)
- `k_fs_extension()` function now accepts a flag as it's second argument to return full extension (e.g. tar.gz from foo.tar.gz)
- Improve the way `k_log_message()` function uses `logger` utility
 
### Fixed 

- Incorrect result from `k_version_compare()` for `lt`/`gt` operator when the version stings are equal strings.
- Incorrect docs for `k_string_trim()`.
- Ensure `k-help2man`, `k-script-build`, `k-shell-doc`, `k-tool-install` tools clean up their temporary files.
- Fixed `make help` output
- Ensure `k_log_level()` function outputs active log level even when passed an invalid level to set
- Incorrect handling of falsey value in first argument to `k_bool_test()` function
- Refactored operations causing failures in mksh/posh.


### Deprecated

- `k_option_requires_arg()`, use `k_options_split()` and `k_options_arg_required()` instead 
- `k_option_optional_arg()`, use `k_options_split()` and `k_options_arg_optional()` instead
- `k_config_command()`, use `k_config_op()` instead

## [2.4.0] - 2019-04-18

### Added
- Added `k_fs_temp_exit` and `k_fs_temp_abort` helper to ensure `k_fs_temp_cleanup` runs when the script closes.

## [2.3.3] - 2018-09-19

### Fixed
- Handle Ubuntu in `install-deps.sh` script

## [2.3.2] - 2018-04-26

### Fixed
- Fixed missing trailing newline in `k_requires_args`
- Fixed typo in `k-script-build --help` output
- Fix current directory issue in `k-script-build` when source is passed by stdin 

## [2.3.1] - 2018-04-05

### Fixed
- Include Vagrantfile, install-deps and full tool sources in Release archive

## [2.3.0] - 2018-04-03

### Added
- Initial test for `gpg.lib.sh` module

### Changed
- Added a third parameter, `group` to `k_fs_perms_useronly`

### Fixed
- Use a default fallback value of 'false' in `k_bool_test`
- Improved return code handling in `k_bool_valid` and `k_gpg_create`
- Fix a bug when no user/group is specified for `k_fs_perms_useronly`
- Fix a bug where k_log_* messages could result in a loop.
- Fixed a build system issue where GPG path wasn't being set properly
- Fixed shellcheck reported issues in `gpg.lib.sh`

## [2.2.0] - 2018-04-02

### Added
- `k_fs_extension` function to get the extension part of a filesystem path
- `k-script-build` now accepts an `-M/--make-deps` flag to output a Make compatible rule defining a scripts direct dependencies
- `k-script-build` now accepts an `-R/--report-replaced` flag to output sourced files similar to `-r/--report` but with prefix replacements applied. 
- `Makefile` target 'shellcheck' to run source scripts through `shellcheck`
- `k-help2man` now exports `K_HELP2MAN_BUILD` with a value of 1, so tools can alter help output for use by man pages
- `k-shell-doc` now correctly parses local and readonly variables, and tags readonly variables as such

### Changed
- `install-deps.sh` now accepts `--dev` to install build dependencies
- `k-script-build` no longer requires or is affected by the `-c/-cd` flag. Different relative paths are now handled automatically
- `k-script-build` `-h/--help` output and man page include a detailed description of the three modes of operation.
- `k-shell-doc` `-h/--help` output and man page include a detailed description of the expected format for shelldoc comments.
- `k-shell-doc` can now disable Markdown Extra 'heading ID' syntax using `--md-extra-ids off`.
- `k_bool_keyword` & `k_bool_status` gained extra debug logging

### Fixed
- Make `gpg` and `cfget` detection work better with `$PATH`
- Clean up `configure` script code style
- Include vendor name in release archive filename
- Updated `k-shell-doc` to properly handle blank links in function descriptions
- Updated `k_bool_parse` to use 'false'`as default 
- Updated `k_bool_keyword` to parse 'false' properly
- Updated `k_fs_perms_useronly` to resolve shellcheck issues

## [2.1.0] - 2018-03-21

### Added
- Make `SYS_CONF_DIR` available in `Makefile`
- Make `PACKAGE_NAME` and `PACKAGE_VERSION` available in source script 
- `k_fs_register_temp_file` to register a file for cleanup by `k_fs_temp_cleanup`
- `k_fs_perms_useronly` to set ownership & permissions of a file/directory
- `install-deps.sh` script

### Changed
- Accept a second parameter in `k_fs_predictable_file` and `k_fs_predictable_dir`, to set a suffix

## [2.0.0] - 2018-03-19

### Added
- This changelog
- The [README](README.md)

### Changed
- Fixes to pass (or override where appropriate) [shellcheck](https://www.shellcheck.net) tests
