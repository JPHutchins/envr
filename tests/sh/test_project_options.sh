source tests/sh/helpers.sh

cp tests/fixtures/$1 envr-local

OLD_ENV="$(printenv)"
OLD_PATH="$PATH"
OLD_ALS="$(alias)"
OLD_PS1="${PS1:-}"

. ./envr.ps1

assertEqual "$OLD_PATH" "$PATH" 
assertEqual "$OLD_ALS" "$(alias)"

# cut off the leading characters
if [[ -n "${BASH:-}" ]] ; then
    assertEqual "$(echo $PS1 | cut -c 15-)" "(my long project name 1337 !_*#? 3)"
elif [[ -n "${ZSH_VERSION:-}" ]] ; then
    assertEqual "$(echo $PS1)" "%F{36}(my long project name 1337 !_*#? 3)%F{reset} "
fi

assertEqual "my long project name 1337 !_*#? 3" "$ENVR_PROJECT_NAME"

unsource

assertEqual "$OLD_PATH" "$PATH"
assertEqual "$OLD_ALS" "$(alias)"

exit $RES