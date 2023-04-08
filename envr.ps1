# envr v0.3.1
# https://www.github.com/JPHutchins/envr
# https://www.crumpledpaper.tech

# MIT License
# Copyright (c) 2022 J.P. Hutchins
# License text at the bottom of this source file

# Use with "source" from *bash* or *Windows PowerShell*
# Usage:
#   bash $> . envr.ps1
#   zsh $> . ./envr.ps1
#   WinPS $> . ./envr.ps1
# You cannot use it directly; it will not set your environment variables.

# Installation (optional)
# - Windows PowerShell
#   - Add the installation location to your system PATH
#   - Usage:
#     WinPS $> . envr
# - BASH
#   - Alias or link envr.ps1 as envr
#   - Add it to your system PATH (or add a link to a folder that is in PATH)
#   - Usage:
#     bash $> . envr

# The following line is for PowerShell/bash cross compatability.
# - The bash section shall begin with the delimiter "<#'"
# - The bash section shall end with the delimiter "#>"
echo --% > /dev/null ; : ' | out-null
<#'

# Check for bash or zsh then verify script is sourced
if [[ -n "${BASH:-}" ]] ; then
    if [[ "${BASH_SOURCE[0]}" = "${0}" ]] ; then
        ARG1=$1
        if [[ -z "$ARG1" || $ARG1 = "-h" || $ARG1 = "--help" ]] ; then
            echo -e "Usage: bash $> . envr.ps1"
            exit 1
        else
            echo "Unknown argument: $ARG1"
            exit 1
        fi
    fi
elif [[ -n "${ZSH_VERSION:-}" ]] ; then
    if [[ $ZSH_EVAL_CONTEXT = :file$ ]] ; then
        ARG1=$1
        if [[ -z "$ARG1" || $ARG1 = "-h" || $ARG1 = "--help" ]] ; then
            echo -e "Usage: zsh $> . envr.ps1"
            exit 1
        else
            echo "Unknown argument: $ARG1"
            exit 1
        fi
    fi
else 
    echo -e "\033[0;31mERROR - Script was not sourced from zsh or bash.\033[0m"
    echo -e "Usage: prompt $> . envr.ps1"
    return 1         
fi

KEY_NOT_FOUND_ERROR=255

zsh_emulate_ksh () {
    if [[ -n "$ZSH_VERSION" ]] ; then
        emulate -L ksh
    fi
}

_envr_check_for_config () {
    _ENVR_HAS_DEFAULT_CONFIG=0
    if [[ -f "envr-default" ]] ; then
        _ENVR_HAS_DEFAULT_CONFIG=1
    else 
        echo -e "\033[0;31mERROR: an envr-default configuration file must exist.\033[0m"
        unset _ENVR_HAS_DEFAULT_CONFIG
        return 1
    fi

    _ENVR_HAS_LOCAL_CONFIG=0
    if [[ -f "envr-local" ]] ; then
        _ENVR_HAS_LOCAL_CONFIG=1
    fi
}

unsource () {
    zsh_emulate_ksh

    # deactivate the python venv:
    if [[ -n "${BASH:-}" ]] ; then
        if [[ $(type -t deactivate) == function ]] ; then
            deactivate
        fi
    elif [[ -n "${ZSH_VERSION:-}" ]] ; then
        if [[ $(type deactivate) == function ]] ; then
            deactivate
        fi
    fi

    # reset to the old PATH:
    if [[ -n "${_ENVR_OLD_PATH:-}" ]] ; then
        PATH="${_ENVR_OLD_PATH:-}"
        export PATH
        unset _ENVR_OLD_PATH
    fi

    # reset to the old prompt:
    if [[ -n "${_ENVR_OLD_ENVIRONMENT_PS1:-}" ]] ; then
        PS1="${_ENVR_OLD_ENVIRONMENT_PS1:-}"
        export PS1
        unset _ENVR_OLD_ENVIRONMENT_PS1
    fi

    # Remove project options:
    for (( i = 0; i <= ${#_ENVR_PROJECT_OPTIONS[@]}; i++ )) ; do
        local KEY=$(echo ${_ENVR_PROJECT_OPTIONS[i]/%=*/})
        if [[ -n "${KEY:-}" ]] ; then
            unset $KEY
        fi
    done
    
    # Remove added environment variables:
    for (( i = 0; i <= ${#_ENVR_NEW_ENVIRONMENT_VARS[@]}; i++ )) ; do
        local KEY=$(echo ${_ENVR_NEW_ENVIRONMENT_VARS[i]/%=*/})
        if [[ -n "${KEY:-}" ]] ; then
            unset $KEY
        fi
    done
    # And restore any environment variables that were overwritten:
    for (( i = 0; i <= ${#_ENVR_OVERWRITTEN_ENVIRONMENT_VARS[@]}; i++ )) ; do
        local ENVAR=${_ENVR_OVERWRITTEN_ENVIRONMENT_VARS[i]}
        if [[ -n "${ENVAR:-}" ]] ; then
            export "$ENVAR"
        fi
    done

    # Remove added aliases:
    for env_var in "${_ENVR_NEW_ALIASES[@]}"; do
        KEY=$(echo ${env_var/%=*/})
        unalias "$KEY" 2>/dev/null  # entry may appear twice, silence error
    done
    # And restore any aliases that were overwritten:
    for alias_entry in "${_ENVR_OVERWRITTEN_ALIASES[@]}"; do
        alias "$alias_entry"
    done

    # This should detect bash and zsh, which have a hash command that must
    # be called to get it to forget past commands.  Without forgetting
    # past commands the $PATH changes we made may not be respected
    if [ -n "${BASH:-}" -o -n "${ZSH_VERSION:-}" ] ; then
        hash -r
    fi

    if [[ ! "${1:-}" = "nondestructive" ]] ; then
    # Self destruct!
        unset _ENVR_HAS_DEFAULT_CONFIG
        unset _ENVR_HAS_LOCAL_CONFIG
    fi

    unset _ENVR_PROJECT_OPTIONS
    unset _ENVR_NEW_ENVIRONMENT_VARS
    unset _ENVR_OVERWRITTEN_ENVIRONMENT_VARS
    unset _ENVR_NEW_ALIASES
    unset _ENVR_OVERWRITTEN_ALIASES
    unset _ENVR_NEW_PATH
    unset _ENVR_PATH_ADDITIONS
    unset VIRTUAL_ENV_DISABLE_PROMPT
    unset ENVR_ROOT
    unset ENVR_PROJECT_NAME
}

_envr_init_private_variables () {
    _ENVR_PROJECT_OPTIONS=()
    _ENVR_NEW_ENVIRONMENT_VARS=()
    _ENVR_OVERWRITTEN_ENVIRONMENT_VARS=()
    _ENVR_NEW_ALIASES=()
    _ENVR_OVERWRITTEN_ALIASES=()
    _ENVR_PATH_ADDITIONS=()
    _ENVR_NEW_PATH="$PATH"
}

_envr_get_index () {
    local key=$1
    shift
    local list=("$@")

    local list_length="${#list[@]}"
    if [[ $list_length -gt 255 ]] ; then
        exit 2  # can only return 0 - 255; not supporing more than 256 entries
    fi

    local index=$KEY_NOT_FOUND_ERROR
    for (( i = 0; i <= $list_length; i++ )) ; do
        local KEY=$(echo ${list[i]/%=*/})
        if [[ "$key" = "$KEY" ]] ; then
            index=$i
            break
        fi
    done
    echo $index
}

_envr_parse_config () {
    ENVR_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    export ENVR_ROOT="$ENVR_ROOT"

    local config_file=$1
    local envr_config_category="INITIAL"
    local config_file_line_number=0

    while IFS= read -r line <&3 || [[ -n "$line" ]] ; do
        config_file_line_number=$((config_file_line_number + 1))

        # trim whitespace and continue if line is blank
        local line="$(echo $line | xargs)"
        if [[ "$line" = "" ]] ; then
            continue
        fi

        # ignore comments
        if [[ "#" = $(echo ${line:0:1}) ]] ; then
            continue
        fi

        # get key value of entry, if any, e.g. KEY=VALUE
        local KEY=$(echo ${line/%=*/})
        local VALUE=$(echo ${line#${KEY}=})

        # check for update to envr_config_category, choosing what is set
        if [[ "[" = $(echo ${line:0:1}) ]] ; then
            envr_config_category="$line"

        # update the list of project options
        elif [[ "$envr_config_category" = "[PROJECT_OPTIONS]" ]] ; then
            local index=$(_envr_get_index "$KEY" "${_ENVR_PROJECT_OPTIONS[@]}")
            if [[ $index == $KEY_NOT_FOUND_ERROR ]] ; then
                _ENVR_PROJECT_OPTIONS+=( "$KEY=$VALUE" )
            else
                _ENVR_PROJECT_OPTIONS[$index]="$KEY=$VALUE"
            fi

        # update the list of new environment variables
        elif [[ "$envr_config_category" = "[VARIABLES]" ]] ; then
            local index=$(_envr_get_index "$KEY" "${_ENVR_NEW_ENVIRONMENT_VARS[@]}")
            if [[ $index == $KEY_NOT_FOUND_ERROR ]] ; then
                _ENVR_NEW_ENVIRONMENT_VARS+=( "$KEY=$VALUE" )
            else
                _ENVR_NEW_ENVIRONMENT_VARS[$index]="$KEY=$VALUE"
            fi
        
        # update the list of new aliases
        elif [[ "$envr_config_category" = "[ALIASES]" ]] ; then
            local index=$(_envr_get_index "$KEY" "${_ENVR_NEW_ALIASES[@]}")
            if [[ $index == $KEY_NOT_FOUND_ERROR ]] ; then
                _ENVR_NEW_ALIASES+=( "$KEY=$VALUE" )
            else
                _ENVR_NEW_ALIASES[$index]="$KEY=$VALUE"
            fi 

        # update the list of additions to system PATH
        elif [[ "$envr_config_category" = "[ADD_TO_PATH]" ]] ; then
            local index=$(_envr_get_index "$KEY" "${_ENVR_PATH_ADDITIONS[@]}")
            if [[ $index == $KEY_NOT_FOUND_ERROR ]] ; then
                _ENVR_PATH_ADDITIONS+=( "$KEY=$VALUE" )
            else
                _ENVR_PATH_ADDITIONS[$index]="$KEY=$VALUE"
            fi 

        # parsing error
        else
            echo -e "\033[0;31mERROR\033[0m - line $config_file_line_number of ${config_file}: $line under section $envr_config_category unknown."
            return 1
        fi
    done 3< "$1"
}

_envr_set_prompt_prefix () {
    if [[ -z "${ENVIRONMENT_DISABLE_PROMPT:-}" ]] ; then
        _ENVR_OLD_ENVIRONMENT_PS1="${PS1:-}"
        if [[ -n "${_ENVR_PROJECT_NAME:-}" ]] ; then
            _PROMPT="$_ENVR_PROJECT_NAME"
        else
            _PROMPT="envr"
        fi
        PS1="\033[0;36m(${_PROMPT}) ${PS1:-}"
        export PS1
    fi
}

_envr_forget_hash () {
    # This should detect bash and zsh, which have a hash command that must
    # be called to get it to forget past commands.  Without forgetting
    # past commands the $PATH changes we made may not be respected
    if [ -n "${BASH:-}" -o -n "${ZSH_VERSION:-}" ] ; then
        hash -r
    fi
}

_envr_activate_python_venv () {
    # Activate the python venv if specified
    if [[ -n "${_ENVR_PYTHON_VENV:-}" ]] ; then
        if [[ -z "${ENVIRONMENT_DISABLE_PROMPT:-}" ]] ; then
            # We're using the envr prompt; disable the python (venv) prompt
            VIRTUAL_ENV_DISABLE_PROMPT="true"
        fi
        source "${_ENVR_PYTHON_VENV}/bin/activate"
    fi
}

_envr_main () {
    _envr_check_for_config &&
    unsource nondestructive &&
    _envr_init_private_variables &&

    # Always parse the default config first
    _envr_parse_config "envr-default"

    if [[ $? == 1 ]] ; then
        unsource
        return 1
    fi
    
    # Parse the local config
    if [[ $_ENVR_HAS_LOCAL_CONFIG = 1 ]] ; then
        _envr_parse_config "envr-local" 
    fi

    if [[ $? == 1 ]] ; then
        unsource
        return 1
    fi

    # Apply the project options
    for option in "${_ENVR_PROJECT_OPTIONS[@]}"; do
        local key=$(echo ${option/%=*/})
        local value=$(echo ${option#${key}=})

        case "$key" in
            "PROJECT_NAME")
                _ENVR_PROJECT_NAME="$value"
                export ENVR_PROJECT_NAME=$_ENVR_PROJECT_NAME;;
            "PYTHON_VENV")
                _ENVR_PYTHON_VENV="$value";;
            *)
                echo -e "\033[0;31mERROR - line $config_file_line_number of ${config_file}: $line under section $envr_config_category unknown.\033[0m"
                unsource
                return 1;;
        esac
    done

    # Apply the environment changes
    for env_var in "${_ENVR_NEW_ENVIRONMENT_VARS[@]}"; do
        local key=$(echo ${env_var/%=*/})

        # check if we are overwriting an existing environment variable
        if [[ -n "${BASH:-}" ]] ; then
            local old_value=$(printf '%s\n' "${!key}")
        elif [[ -n "${ZSH_VERSION:-}" ]] ; then
            local old_value=$(printf '%s\n' "${(P)key}")
        fi
        if [[ -n "$old_value" ]] ; then
            _ENVR_OVERWRITTEN_ENVIRONMENT_VARS+=( "${key}=${old_value}" )
        fi

        # expand the variables
        if [[ -n "${BASH:-}" ]] ; then
            if [[ $(printf %.1s $BASH_VERSION) -ge 5 ]] ; then
                env_var="${env_var@P}"
            else  # bash < 4.4 doesn't have @P
                env_var="$(eval echo "$env_var")"
            fi
        elif [[ -n "${ZSH_VERSION:-}" ]] ; then
            env_var="${(e)env_var}"
        fi
        
        export "$env_var"
    done

    # Apply the the new aliases and save overwrites
    for alias in "${_ENVR_NEW_ALIASES[@]}"; do
        local key=$(echo ${alias/%=*/})
        local value=$(echo ${alias#${key}=})

        # check if we are overwriting an alias
        if [[ -n "${BASH:-}" ]] ; then
            if [[ "$(type -t ${key})" = "alias" ]] ; then
                local alias_output=$(alias ${key})
                local old_value=$(echo ${alias_output#alias })
                _ENVR_OVERWRITTEN_ALIASES+=("$old_value")
            fi 
        elif [[ -n "${ZSH_VERSION:-}" ]] ; then 
            if [[ ${+aliases[${key}]} ]] ; then
                local old_value=$(alias ${key})
                _ENVR_OVERWRITTEN_ALIASES+=("$old_value")
            fi 
        fi
        alias "$key=$value"
    done

    # Apply additions to the system PATH
    for path_dir in "${_ENVR_PATH_ADDITIONS[@]}"; do
        local key=$(echo ${path_dir/%=*/})
        local value=$(echo ${path_dir#${key}=})

        # make sure that the directory exists
        if [[ ! -d "$value" ]] ; then
            echo -e "\033[0;31mERROR\033[0m - ${KEY}, line $config_file_line_number of ${config_file}: $value is not a directory."
            unsource
            return 1
        fi
        # don't add duplicate directories to PATH
        if [[ ":${_ENVR_NEW_PATH}:" == *":${value}:"* ]]; then
            continue
        fi
        _ENVR_NEW_PATH="${value}:${_ENVR_NEW_PATH}"
    
    done

    # Save the unmodified PATH and export the new one
    _ENVR_OLD_PATH="$PATH"
    PATH="$_ENVR_NEW_PATH"
    export PATH

    _envr_set_prompt_prefix &&
    _envr_forget_hash &&
    _envr_activate_python_venv
    return 0
}

# run main
_envr_main

true << 'POWERSHELL_SECTION'
#>

function global:unsource ([switch]$NonDestructive) {
    # Revert to original values

    # Deactivate the python venv:
    if (Test-Path -Path Function:deactivate) {
        deactivate
    }

    # Reset to the old PATH:
    if (Test-Path -Path Env:_OLD_PATH) {
        Copy-Item -Path Env:_OLD_PATH -Destination Env:PATH
        Remove-Item -Path Env:_OLD_PATH
    }

    # The prior prompt:
    if (Test-Path -Path Function:_OLD_VIRTUAL_PROMPT) {
        Copy-Item -Path Function:_OLD_VIRTUAL_PROMPT -Destination Function:prompt
        Remove-Item -Path Function:_OLD_VIRTUAL_PROMPT
    }

    # Just remove the _ENVAR_PROMPT_PREFIX altogether:
    if (Get-Variable -Name "_ENVAR_PROMPT_PREFIX" -ErrorAction SilentlyContinue) {
        Remove-Variable -Name _ENVAR_PROMPT_PREFIX -Scope Global -Force
    }

    # Remove added environment variables:
    foreach ($env_var in $_NEW_ENVIRONMENT_VARS) {
        $_TEMP_ARRAY = $env_var.split("=")
        $KEY = $_TEMP_ARRAY[0]

        if (Test-Path -Path env:$KEY) {
            Remove-Item -Path env:$KEY
        }
    }
    # And restore any environment variables that were overwritten:
    foreach ($env_var in $_OVERWRITTEN_ENVIRONMENT_VARS) {
        $_TEMP_ARRAY = $env_var.split("=")
        $KEY = $_TEMP_ARRAY[0]
        $VALUE = $_TEMP_ARRAY[1]

        if (Test-Path -Path env:$KEY) {
            Write-Host "ERROR: $KEY should have been removed already!"
            return 1
        }
        Set-Item -Path env:$KEY -Value $VALUE
    }

    # Remove added aliases:
    foreach ($alias in $_NEW_ALIASES) {
        $KEY = $alias.split("=")[0]

        if (Test-Path -Path alias:$KEY) {
            Remove-Item alias:$KEY
        }
        else {
            Write-Host "WARNING: alias $KEY was removed already!"
        }
    }
    # And restore any aliases that were overwritten:
    foreach ($alias in $_OVERWRITTEN_ALIASES) {
        $_TEMP_ARRAY = $alias.split("=")
        $KEY = $_TEMP_ARRAY[0]
        $VALUE = $_TEMP_ARRAY[1]

        Set-Alias $KEY $VALUE -Scope Global -Option AllScope -Force
    }

    # Leave unsource function in the global namespace if requested:
    if (-not $NonDestructive) {
        Remove-Item -Path function:unsource
    }

    if (Get-Variable -Name "ENVR_ROOT" -ErrorAction SilentlyContinue) {
        Remove-Variable -Name ENVR_ROOT -Scope Global -Force
    } 

    # Remove variables leftover from script run
    # $_VAR_REMOVE_LIST = 
    #     "_PROJECT_NAME",
    #     "_PYTHON_VENV_SCRIPT",
    #     "_NEW_ENVIRONMENT_VARS",
    #     "_OVERWRITTEN_ENVIRONMENT_VARS",
    #     "_NEW_ALIASES",
    #     "_CATEGORY",
    #     "_PYTHON_VENV",
    #     "_TEMP_ARRAY"
    # foreach ($var in $_VAR_REMOVE_LIST) {
    #     $p = Get-Variable -Name $var -ErrorAction SilentlyContinue
    #     echo $p
    #     if (Get-Variable -Name $var -ErrorAction SilentlyContinue) {
    #         Remove-Variable -Name $var -Scope Global -Force
    #     }
    # }

    if (Test-Path -Path env:VIRTUAL_ENV_DISABLE_PROMPT) {
        Remove-Item -Path env:VIRTUAL_ENV_DISABLE_PROMPT
    }
}

# Check for config
if (Test-Path -Path envr-local) {
    $_ENVR_CONFIG = "envr-local"
} elseif (Test-Path -Path envr-default) {
    $_ENVR_CONFIG = "envr-default"
} else {
    Write-Host "ERROR: an envr-local or envr-default configuration file must exist." -ForegroundColor Red
    unsource
    return
}

# Deactivate any currently active virtual environment, but leave the
# deactivate function in place.
unsource -nondestructive

# Save the old path
Copy-Item -Path Env:PATH -Destination Env:_OLD_PATH

# parse the environment file and setup
$_CATEGORY = "INITIAL"
$_NEW_ENVIRONMENT_VARS = @()
$_OVERWRITTEN_ENVIRONMENT_VARS = @()
$_NEW_ALIASES = @()
$_OVERWRITTEN_ALIASES = @()
$_ALIAS_FN_INDEX = 0
$_ALIAS_COMMAND_ARR = @()
$_ALIAS_ARGS_ARR = @()

New-Variable -Name ENVR_ROOT -Description "envr parent folder path" -Scope Global -Option ReadOnly -Visibility Public -Value "$PSScriptRoot"
Set-Item -Path env:ENVR_ROOT -Value $ENVR_ROOT
$_NEW_ENVIRONMENT_VARS += "ENVR_ROOT=$ENVR_ROOT"

foreach ($line in Get-Content $_ENVR_CONFIG) {
    # trim whitespace and continue if line is blank 
    $line = $line.Trim()
    if ($line -eq "") {
        continue
    }

    # ignore comments
    if ($line.SubString(0,1) -eq "#") {
        continue
    }

    # get key value of entry, if any, e.g. KEY=VALUE
    $_TEMP_ARRAY = $line.split("=")
    $KEY = $_TEMP_ARRAY[0]
    $VALUE = $_TEMP_ARRAY[1]
    if ($null -ne $VALUE) {
        $VALUE = $ExecutionContext.InvokeCommand.ExpandString($VALUE.Replace('$', '$env:'))
    }

    # check for update to _CATEGORY, choosing what is set
    if ($line.SubString(0,1) -eq "[") {
        $_CATEGORY = $line
    }

    # set environment variables
    elseif ($_CATEGORY -eq "[VARIABLES]") {
        # check if we are overwriting an environment variable
        if (Test-Path -Path env:$KEY) {
            $OLD_VALUE = [System.Environment]::GetEnvironmentVariable($KEY)
            $_OVERWRITTEN_ENVIRONMENT_VARS += "$KEY=$OLD_VALUE"
        }
        Set-Item -Path env:$KEY -Value $VALUE
        $_NEW_ENVIRONMENT_VARS += "$KEY=$VALUE"
    }

    # set project options
    elseif ($_CATEGORY -eq "[PROJECT_OPTIONS]") {
        switch ($KEY)
        {
            "PROJECT_NAME" { 
                $_PROJECT_NAME = $VALUE
                Set-Item -Path env:ENVR_PROJECT_NAME -Value $VALUE
                $_NEW_ENVIRONMENT_VARS += "ENVR_PROJECT_NAME=$VALUE"
            }
            "PYTHON_VENV" { $_PYTHON_VENV = $VALUE }
        }
    }

    # set aliases
    elseif ($_CATEGORY -eq "[ALIASES]") {
        # check if we are overwriting an alias
        if (Test-Path -Path alias:$KEY) {
            $_OLD_ALIAS = $((Get-Alias $KEY).Definition)
            $_OVERWRITTEN_ALIASES += "$KEY=$_OLD_ALIAS"
            Remove-Item -Path Alias:$KEY
        }
        if ($_ALIAS_FN_INDEX -eq 10) {
            Write-Host "ERROR: only $_ALIAS_FN_INDEX aliases allowed!"
            return 1
        }
        $_TEMP_ARRAY = $VALUE.split(" ")
        $_ALIAS_COMMAND_ARR += ,$_TEMP_ARRAY[0]
        if ($_TEMP_ARRAY.Length -ge 2) {
            $_args = @()
            for (($i = 1); $i -lt $_TEMP_ARRAY.Length; $i++) {
                # Expand the args to use any environment variables 
                $_args += ,$ExecutionContext.InvokeCommand.ExpandString($_TEMP_ARRAY[$i])
            }
            $_ALIAS_ARGS_ARR += ,$_args
        }
        else {
            $_ALIAS_ARGS_ARR += ,""
        }

        # Hack to support aliases with parameters
        function _ENVR_ALIAS_FN_0 { . $_ALIAS_COMMAND_ARR[0] $_ALIAS_ARGS_ARR[0] }
        function _ENVR_ALIAS_FN_1 { . $_ALIAS_COMMAND_ARR[1] $_ALIAS_ARGS_ARR[1] }
        function _ENVR_ALIAS_FN_2 { . $_ALIAS_COMMAND_ARR[2] $_ALIAS_ARGS_ARR[2] }
        function _ENVR_ALIAS_FN_3 { . $_ALIAS_COMMAND_ARR[3] $_ALIAS_ARGS_ARR[3] }
        function _ENVR_ALIAS_FN_4 { . $_ALIAS_COMMAND_ARR[4] $_ALIAS_ARGS_ARR[4] }
        function _ENVR_ALIAS_FN_5 { . $_ALIAS_COMMAND_ARR[5] $_ALIAS_ARGS_ARR[5] }
        function _ENVR_ALIAS_FN_6 { . $_ALIAS_COMMAND_ARR[6] $_ALIAS_ARGS_ARR[6] }
        function _ENVR_ALIAS_FN_7 { . $_ALIAS_COMMAND_ARR[7] $_ALIAS_ARGS_ARR[7] }
        function _ENVR_ALIAS_FN_8 { . $_ALIAS_COMMAND_ARR[8] $_ALIAS_ARGS_ARR[8] }
        function _ENVR_ALIAS_FN_9 { . $_ALIAS_COMMAND_ARR[9] $_ALIAS_ARGS_ARR[9] }
        Set-Alias -Name $KEY -Value "_ENVR_ALIAS_FN_$_ALIAS_FN_INDEX"
        $_NEW_ALIASES += $line
        $_ALIAS_FN_INDEX += 1
    }

    # add to PATH
    elseif ($_CATEGORY -eq "[ADD_TO_PATH]") {
        if (Test-Path -Path $VALUE) {
        } else {
            Write-Host "$VALUE is not a directory." -ForegroundColor Red
            unsource
            return
        }
        foreach ($folder in $(Get-Item env:path).value.split($([System.IO.Path]::PathSeparator))) {
            if ($folder -eq $VALUE) {
                $duplicate = 1
            }
        }
        if ($duplicate -eq 1) {
            continue
        }

        $Env:PATH = "$VALUE$([System.IO.Path]::PathSeparator)$Env:PATH"
    }
}

# Activate the python venv if specified
if (-not $_PYTHON_VENV -eq "") {
    if (-not $Env:ENVIRONMENT_DISABLE_PROMPT) {
        # We're going to set envr prompt; disable the python (venv) prompt
        Set-Item -Path env:VIRTUAL_ENV_DISABLE_PROMPT -Value "true"
    }
    . "$_PYTHON_VENV/Scripts/Activate.ps1"
}

# Set the prompt prefix
if (-not $Env:ENVIRONMENT_DISABLE_PROMPT) {

    # Set the prompt to include the env name
    # Make sure _OLD_VIRTUAL_PROMPT is global
    function global:_OLD_VIRTUAL_PROMPT { "" }
    Copy-Item -Path function:prompt -Destination function:_OLD_VIRTUAL_PROMPT

    $prompt = "(envr) "
    if (-not $_PROJECT_NAME -eq "") {
        $prompt = "($_PROJECT_NAME) " 
    }
    New-Variable -Name _ENVAR_PROMPT_PREFIX -Description "Python virtual environment prompt prefix" -Scope Global -Option ReadOnly -Visibility Public -Value $prompt

    function global:prompt {
        Write-Host -NoNewline -ForegroundColor Cyan "$_ENVAR_PROMPT_PREFIX"
        _OLD_VIRTUAL_PROMPT
    }
}

# These lines deal with either script ending
echo --% > /dev/null ; : ' | out-null
<#'
POWERSHELL_SECTION
#>

# License text continued

# MIT License
# Copyright (c) 2022 J.P. Hutchins

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
