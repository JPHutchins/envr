# envr

![](https://byob.yarr.is/JPHutchins/envr/ubuntu_bash)
![](https://byob.yarr.is/JPHutchins/envr/ubuntu_zsh)
![](https://byob.yarr.is/JPHutchins/envr/windows_ps_core)
![](https://byob.yarr.is/JPHutchins/envr/windows_ps)
![](https://byob.yarr.is/JPHutchins/envr/mac_zsh)
![](https://byob.yarr.is/JPHutchins/envr/mac_bash)

## Simple Development Environment Manager

envr is a *self-contained cross-platform script* (envr.ps1) that allows developers to specify environment variables, aliases, and additions to the system path.

## Compatibility

envr can be used with bash, zsh, and PowerShell in Linux, Windows, and MacOS.  See the [github workflows](.github/workflows) for more information on the shells that are tested.

# Usage

Activate the environment: `. ./envr.ps1`

Deactivate the environment: `unsource`

## Adding envr to Your Repository

* Download and commit `envr.ps1` to the root of your repository
  * Linux/Mac/Windows (`wget`): `wget https://github.com/JPHutchins/envr/releases/latest/download/envr.ps1`
  * Windows (no `wget`): `Invoke-WebRequest -OutFile envr.ps1 -Uri https://github.com/JPHutchins/envr/releases/latest/download/envr.ps1`
* Create, define and commit `envr-default` to the root of your repository.
* Modify your `.gitignore` to ignore `envr-local`.

## Define Your Environment in envr-default

`envr-default` (and `envr-local`) is a INI/TOML-ish text file of the following shape.  Currently four categories are supported, marked by `[ ]`.  Definitions are in the format `KEY=VALUE`.

Note: inline comments are not supported

```ini
[PROJECT_OPTIONS]
# This sets the environment variable ENVR_PROJECT_NAME for use by the environment
PROJECT_NAME=coolrepo
# If you have a python venv, envr can activate it along with the envr environment
PYTHON_VENV=venv

[VARIABLES]
FOO=bar
ANSWER=42
PLUGINS=~/chuck/ext/plugins
# Environment variables can use other environment variables
PATH_SNOOPY_TOOL=$PLUGINS/x86/v436.874/snoopy-ext/bin

[ADD_TO_PATH]
# Here, the key "TOOLCHAIN_PATH" is not exported to PATH but rather
# it is used internally to keep track of modifications to PATH
TOOLCHAIN_PATH=/opt/supercollider/system/arm32/bin
# ENVR_ROOT is an environment variable set by envr
# It is the full path to envr.ps1 (the root of your repo)
BINARIES=$ENVR_ROOT/build/bin

[ALIASES]
build=cmake -GNinja -Bbuild -DBOARD=hrv43 -DCMAKE_BUILD_TYPE=Debug -DLOG_LEVEL=INFO && cmake --build build
flash=cmake -GNinja -Bbuild -DBOARD=hrv43 -DCMAKE_BUILD_TYPE=Debug -DLOG_LEVEL=INFO && cmake --build build --target flash
```

## Use the Environment Definition

* `. ./envr.ps1` from the root of your repository.
* envr always reads `envr-default` first, followed by `envr-local` if it exists.  
  
  `envr-local` is used to provide the necessary local modifications to environment variables, paths, and aliases.  `envr-default` keys that are not overwritten by `envr-local` will be available as they were defined in `envr-default`.  Users can add keys to their `envr-local`, though it would often be preferred to update `envr-default` as well so that everyone can be benefit from the definitions.

## Restore Previous Shell Environment (deactivate)

* `unsource`

### Why .ps1?

#$&*%^

Because PowerShell scripts don't run with any other extension.

# Motivation

The goal of envr is to unify the development environment setup of any repository by providing a consistent interface for Windows, MacOS, and GNU/Linux shells.

# envr testing and development

```
git clone git@github.com:JPHutchins/envr.git
cd envr
git checkout develop
git checkout -b feature/my-feature-branch-name
```

## Unit Tests

* Tests are run from this repository root.
  * Windows PS: `.\tests\windows\ps.ps1`
  * Windows WSL bash: `bash tests/sh/bash.sh`
  * Windows WSL bash with zsh installed: `bash tests/sh/zsh.sh`
  * Linux/macOS bash: `tests/sh/bash.sh`
  * Linux/macOS zsh: `tests/sh/zsh.sh`
  * Linux/macOS all shells: `tests/sh/all.sh` *recommended to verify `bash` `zsh` compatibility.*
* Add tests for any new shell, feature, or compatibility update.
