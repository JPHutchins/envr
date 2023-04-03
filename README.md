# envr

## Simple Development Environment Manager

envr is a self-contained *cross-platform script* (envr.ps1) that allows developers to specify environment variables, aliases, and additions to the system path.

The goal of envr is to unify the development environment setup of any repository by providing a consistent interface for Windows, MacOS, or GNU/Linux.

![](https://byob.yarr.is/JPHutchins/envr/ubuntu_bash)

# Usage

## Setup

* Copy and commit `envr.ps1` to the root of your repository.
* Create, define and commit `envr-default` to the root of your repository.
* Modify your `.gitignore` to ignore `envr-local` and commit.
* Add documentation instructing users to `cp envr-default envr-local` in order to resolve local differences

## Define Your Environment in envr-default

`envr-default` (and `envr-local`) is just a text file of the following shape.  Currently four categories are supported, marked by `[ ]`.  Environment definitions are in the format `KEY=VALUE`.

```
# An example using all current categories

[PROJECT_OPTIONS]
    PROJECT_NAME=coolrepo
    PYTHON_VENV=venv
[ALIASES]
    build=make -j 14 -DDEFAULTS=1
    release=make -j 14 -DOPTION=2 -DSWITCH=5
    clean=make clean
[VARIABLES]
    FOO=bar
    ANSWER=42
    STACK_SIZE=2048
    CONFIG_DEBUG=1
    PATH_SNOOPY_TOOL=~/chuck/ext/plugins/x86/v436.874/snoopy-ext/bin
[ADD_TO_PATH]
    # Here, the key "GROOBER_PATH" is not exported to PATH but rather
    # it is used internally to keep track of modifications to PATH
    GROOBER_PATH=~/opt/supercollider/system/x86/bin
```

## Use the Environment Definition

* `. ./envr.ps1` from the root of your repository.
  * `envr-local` takes precedence over `envr-default`; the script requires at least one to exist at repository root.
* Some users may not have to create a local copy of `envr-default` - the defaults might work.  Anything that *could* be unique to user's environment should be specified in `envr-default`.
* The gitignored local copy of `envr-default`, named `envr-local`, provides each user an interface to the environment requirements.

## Restore Previous Shell Environment (deactivate)

* `unsource`

### Why .ps1

#$&*%^

Because PowerShell scripts don't run with any other extension.  If you don't want to support Windows development then alias or rename `envr.ps1` to `envr`.

# Support Status

| Feature                                     | Windows PowerShell   | GNU bash 5.0.17(1)-release | zsh 5.8 (x86_64-ubuntu-linux-gnu) | GNU bash 3.2.57(1)-release | zsh 5.3 (x86_64-apple-darwin18.0) |
| ------------------------------------------- | -------------------- | -------------------------- | --------------------------------- | -------------------------- | --------------------------------- |
| set/overwrite/restore environment variables | ✅                    | ✅                          | ✅                                 | ✅                          | ✅                                 |
| prompt shows active project name            | ✅                    | ✅                          | ✅                                 | ✅                          | ✅                                 |
| activate/deactivate python venv             | ✅  (needs unit test) | ✅                          | ✅                                 | ✅                          | ✅                                 |
| set aliases                                 | ✅                    | ✅                          | ✅                                 | ✅                          | ✅                                 |
| overwrite/restore aliases                   | ✅                    | ✅                          | ✅                                 | ✅                          | ✅                                 |
| add-to/restore PATH                         | ✅                    | ✅                          | ✅                                 | ✅                          | ✅                                 |


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