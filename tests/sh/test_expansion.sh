source tests/sh/helpers.sh

cp tests/fixtures/$1 envr-local

export USER_VAR="original user value"

OLD_ENV="$(printenv)"
OLD_PATH="$PATH"
OLD_ALS="$(alias)"
OLD_PS1="${PS1:-}"

assertContains "$OLD_ENV" "USER_VAR=original user value"

. ./envr.ps1

assertEqual "$OLD_ALS" "$(alias)"              

assertEqual "$(pwd)" "$ENVR_ROOT"
assertEqual "$(pwd)/path/to/resource" $ABS_PATH_EXAMPLE
assertEqual bar42 $COMBINED
assertEqual "$(pwd)/path/to/resource/bar42" $COMBINED_PATH

assertContains "$PATH" "$(pwd)/tests/fixtures"
assertContains "$PATH" "$(pwd)/path/to/resource/bar42"

unsource

assertEqual $OLD_PATH "$PATH"               
assertEqual $OLD_ALS "$(alias)"               

RESTORED_ENV="$(printenv)"
assertNotContains "$RESTORED_ENV" "ENVR_ROOT"                        

exit $RES