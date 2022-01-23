source tests/sh/helpers.sh

cp tests/fixtures/$1 envr-local

OLD_ENV="$(printenv)"
OLD_PATH="$PATH"
OLD_ALS="$(alias)"
OLD_PS1="${PS1:-}"

assertContains "$PATH" "/usr/local/bin"

. envr.ps1

assertEqual $OLD_ALS $(alias)

assertNotEqual "$OLD_PATH" "$PATH"
assertContains "$PATH" "/opt"
assertContains "$PATH" "/usr/local/bin"

unsource

assertEqual $OLD_PATH "$PATH"
assertNotContains "$PATH" "/opt"
assertContains "$PATH" "/usr/local/bin"

exit $RES