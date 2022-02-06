# Koalephant Shell Script Library

This project provides a functions library to simplify building portable command-line tools using shell scripts, and tools (built on top of the library itself) to assist with dependency management, building self-contained scripts, and documentation.

## Tools

- `k-script-build`: Creates a distributable/installable shell script by converting relative source (`.`) statements into absolute references or inlining the referenced script. Additionally, accepts `m4`-style `--define` options to replace strings in the source script.
- `k-shell-doc`: Reads formatted comments and produces Markdown formatted API documentation. See [base.lib.md](docs/base.lib.md) for an example of the output. 
- `k-help2man`: Creates `man` pages from a script's `--help` output. Wraps `help2man` to simplify usage. See [k-script-build.1](man/k-script-build.1) for an example of output.
- `k-tool-install`: Rudimentary dependency resolution and installation for packages installable via the traditional `tar -x ...; configure && make && sudo make install` routine. 
- `k-version-compare`: Helper tool for comparing version number strings.
 
## Modules

- `base.lib.sh`: CLI tool helpers (tool name, options, version), Logging
- `bool.lib.sh`: Boolean value handling
- `config.lib.sh`: Config file handling
- `environment.lib.sh`: Environment variable handling
- `fs.lib.sh`: File/Directory handling
- `hash.lib.sh`: Hash handling
- `gpg.lib.sh`: GPG key/keyring handling
- `string.lib.sh`: String handling 
- `number.lib.sh`: Number handling

## Installing

1. Either download a release tarball or clone the repository.
2. If you're on a Debian derivative, run `./install-deps.sh` with root privileges.
3. Run the typical build steps:

```sh
./configure
make
make test # Optional but recommended
sudo make install
```

### Distribution
If you intend to distribute your scripts as 'static' or 'self-contained' built scripts, they will contain all the library code needed to operate.

If you intend to distribute your scripts using `Koalephant Shell Script Library` as a shared library, you will need to ensure it is installed on target machines for your scripts to run. A simple shell install script is provided (available as`install.sh` in a release archive, or use `make install.sh` to build it) to allow downloading and installing the library.

## Using
As of version `2.7.0` the recommended way to load the library is by sourcing the single `shell-script-library.lib.sh` file, installed in `$PREFIX/share/koalephant/shell-script-library/`.

You may source indidivual files `*.lib.sh` files if you wish, this would mostly benefit static built scripts, however you will need to ensure the internal library dependencies of the functions you use, are sourced properly.

## Compatibilty

This library aims for POSIX compatibility, with the notable exception of the `local` keyword, which is supported in all tested shell implementations.

## Dependencies

- a POSIX compliant shell
- sed
- gpg/gpg2 (for gpg module)
- one of php, python2 or python3 for config file handling
- perl shasum, GNU coreutils *sum, or php for hash handling

## Testing

As this project aims for portability, it's intended to be built on multiple POSIX platforms.
A [Vagrant](https://vagrantup.com) configuration is included to make building/testing in a Debian Linux VM simpler. 

### Predefined Vagrant helpers

Since 2.7.2, the included Vagrantfile has three named provisioners that can be used to run pre-defined steps from a host.
They can be called using the following command format: `vagrant provision --provision-with name,[name2,[...]]` 

The usable names are:

- `build` - completely cleans (via `make distclean`) the working directory and rebuilds the project.
- `test` - runs all tests
- `test-release` - builds a release archive, then extracts it to a temporary directory and tries to build it and run the tests.

### Multi-Shell testing

There is also an included script, `build-test-all.sh` that will iterate through a list of supported shells, testing each one.
The supported list is currently defined as `dash` `bash` and `mksh`.
For each shell the project will be built and tested, in the shell invoked normally (i.e. `dash`) and in the shell invoked via a symlink called `sh`.
This second run causes shells that aren't normally POSIX strict, to be closer to POSIX strict. 
