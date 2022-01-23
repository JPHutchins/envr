source tests/sh/helpers.sh

cp tests/fixtures/$1 envr-local

OLD_ENV="$(printenv)"
OLD_PATH="$PATH"
OLD_ALS="$(alias)"
OLD_PS1="${PS1:-}"

. $(pwd)/envr.ps1

assertEqual "$OLD_PATH" "$PATH"
assertEqual "$OLD_ALS" "$(alias)"

# cut off the leading characters
assertEqual "$(echo $PS1 | cut -c 9-)" "(envr)"

unsource

assertEqual "$OLD_PATH" "$PATH"
assertEqual "$OLD_ALS" "$(alias)"

exit $RES