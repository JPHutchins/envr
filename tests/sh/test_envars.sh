source tests/sh/helpers.sh

cp tests/fixtures/$1 envr-local

export USER_VAR="original user value"

OLD_ENV="$(printenv)"
OLD_PATH="$PATH"
OLD_ALS="$(alias)"
OLD_PS1="${PS1:-}"

assertContains "$OLD_ENV" "USER_VAR=original user value"

. envr.ps1

assertEqual "$OLD_PATH" "$PATH"                
assertEqual "$OLD_ALS" "$(alias)"              

NEW_ENV="$(printenv)"
assertContains "$NEW_ENV" "FOO=bar"                     
assertContains "$NEW_ENV" "ANSWER=42"                    
assertContains "$NEW_ENV" "SPACES=oh we got some spaces"
assertContains "$NEW_ENV" "USER_VAR=user value overwritten"

unsource

assertEqual $OLD_PATH "$PATH"               
assertEqual $OLD_ALS "$(alias)"               

RESTORED_ENV="$(printenv)"
assertNotContains "$RESTORED_ENV" "FOO"                        
assertNotContains "$RESTORED_ENV" "ANSWER"                     
assertNotContains "$RESTORED_ENV" "SPACES"
assertContains "$RESTORED_ENV" "USER_VAR=original user value"

exit $RES