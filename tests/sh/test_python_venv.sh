source tests/sh/helpers.sh

cp tests/fixtures/$1 envr-local

OLD_ENV="$(printenv)"
OLD_PATH="$PATH"
OLD_ALS="$(alias)"
OLD_PS1="${PS1:-}"

. ./envr.ps1

# Python venv stuff is there
assertEqual "$(pwd)/venv/bin:$OLD_PATH" "$PATH"
assertContains "$(printenv)" "VIRTUAL_ENV=$(pwd)/venv"

assertEqual "$OLD_ALS" "$(alias)"

# cut off the leading characters
if [[ -n "${BASH:-}" ]] ; then
    assertEqual "$(echo $PS1 | cut -c 15-)" "(envr)"
elif [[ -n "${ZSH_VERSION:-}" ]] ; then
    assertEqual "$(echo $PS1)" "%F{36}(envr)%F{reset} "
fi

unsource

assertEqual "$OLD_PATH" "$PATH"
assertEqual "$OLD_ALS" "$(alias)"

exit $RES