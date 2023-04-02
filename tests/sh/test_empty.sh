source tests/sh/helpers.sh

cp tests/fixtures/$1 envr-local

OLD_ENV="$(printenv)"
OLD_PATH="$PATH"
OLD_ALS="$(alias)"
OLD_PS1="${PS1:-}"

. $(pwd)/envr.ps1

assertEqual "$OLD_PATH" "$PATH"
assertEqual "$OLD_ALS" "$(alias)"

assertEqual $(pwd) $(echo $ENVR_ROOT)

# cut off the leading characters
if [[ -n "${BASH:-}" ]] ; then
    assertEqual "$(echo $PS1 | cut -c 11-)" "(envr)"
elif [[ -n "${ZSH_VERSION:-}" ]] ; then
    assertEqual "$(echo $PS1 | cut -c 8-)" "(envr) "
fi

unsource

assertEqual "$OLD_PATH" "$PATH"
assertEqual "$OLD_ALS" "$(alias)"
assertNotContains "$(printenv)" "ENVR_ROOT"

exit $RES