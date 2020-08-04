# Packaging Scripts for macOS
Utilities to build and test packages from a Duke JAMF packaging workflow definition

![Tests](https://github.com/duke-jamf/scripts/workflows/Tests/badge.svg)

## Quick Start

1. Install [Homebrew](https://brew.sh)
2. Download, clone, or create [package definitions](https://github.com/duke-jamf/definitions)
3. Build the package: `src/build path/to/definition`

## Description

**Scripts** is a set of utilities to automate package creation for macOS. This project's intent
is to provide a complete automated workflow for maintaining packages in [Duke University](https://www.duke.edu)'s
instance of [JAMF](https://www.jamf.com), an enterprise endpoint management suite. However many
of these utilities may be useful outside of that context.

All scripts work on a package definition; see [Definitions](https://github.com/duke-jamf/definitions)
for more information on definition formats and examples. You may use the `source` scripts
to generate definitions on-the-fly.

## Installation

This project assumes you have [Homebrew](https://brew.sh) installed and configured. Download
or clone [Scripts](https://github.com/duke-jamf/scripts) and procure your desired definitions.

A number of configurations may be made using environment variables. Before running the scripts
set and export each variable, e.g.:

	$ PKGPREFIX=org.company
	$ export PKGPREFIX

The following environment variables are available:

* `PKGPREFIX`: Used to set the bundle identifier on the generated packages. Example: `edu.duke`

> It is highly recommend you set a package identifier prefix otherwise your resulting packages will be be prefixed "com.example"

## Usage

The typical workflow follows these steps:

1. Sourcing
2. Building
3. Verifying
4. Checking

### Sourcing

**Scripts** work on package definitions. You can download existing examples from the
[Definitions](https://github.com/duke-jamf/definitions) repo or generate your own using the
provided scripts.

#### Casks

If your desired application has an equivalent [Homebrew Cask](https://github.com/Homebrew/homebrew-cask)
(i.e. a pre-built binary) then you can generate a definition by supplying the Cask token:

	src/source-cask {cask_token} [target_directory]

This will create a simple definition directory with the required **variables** file. You may
add and edit anything else you need (see [Definitions](https://github.com/duke-jamf/definitions)
for details). You may browse available Casks here: https://formulae.brew.sh/cask/

### Building

> *Note: source files are installed during build* 

Once you have a definition simply provide the path to the `build` script to generate the new
package and its corresponding manifest:

	src/build {path/to/definition}

The new files will be added to the definition path.

### Verifying

> *Note: packages are installed during verify*

You can verify that a package was built successfully using the `verify` command (must be
run as `root` to install the package):

	sudo src/verify {path/to/definition} [target_volume]

First the package will be checked for integrity and then installed. By default `verify`
will then attempt to launch any **.app** files included in the package, but definitions
may supply an overriding verification script with alternate/additional steps.

### Checking

Once a package has been built it will leave behind a **.manifest** file in the definition
root which includes the timestamp, name, slug, and version of the build. You may use
the `check` script to compare a manifest file with the latest version available from
the definition source:

	src/check-cask {path/to/definition}

This will display one of three results: "missing", "outdated", or "current". This is handy
for determining when it is time to build and deploy an updated package.

## Examples

See the [Automate repo](https://github.com/duke-jamf/automate) for an example of using these
scripts together with the definitions.

## Troubleshooting

> /bin/sh: bad interpreter: Operation not permitted

Sometimes macOS will quarantine executable scripts downloaded from the internet. If you
receive this message then most likely one of your scripts has been quarantined. Check the
extended attributes on the script for `com.apple.quarantine`:

	xattr -l path/to/script

The easiest way to restore execution is to clear all the extended attributes:

	xattr -c src/*

## Testing

> *Note: packages and source files are installed during testing*

**Scripts** comes with its own set of tests to make sure each script functions as expected.
You may run through the test suite to verify your configuration is ready to use:

	tests/run

If you plan on contributing to this project then please run the tests locally before submitting
a Pull Request. Additionally there is a [GitHub Action workflow](.github/workflows/test.yml)
to test PRs on macOS latest.

## Development

Support for more package definition types will be added in upcoming releases. Please submit
all package-specific requests and issues to the [Definitions](https://github.com/duke-jamf/definitions)
repo or they will be closed.
