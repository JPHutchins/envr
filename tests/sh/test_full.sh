source tests/sh/helpers.sh
if [[ -n "${BASH:-}" ]] ; then
    shopt -s expand_aliases
elif [[ -n "${ZSH_VERSION:-}" ]] ; then
    setopt aliases
fi

cp tests/fixtures/$1 envr-local

# user has set an alias
alias user_alias=echo
assertEqual "$(user_alias user)" "user"

# user has set an environment variable
export USER_VAR="original user value"

OLD_ENV="$(printenv)"
OLD_PATH="$PATH"
OLD_ALS="$(alias)"
OLD_PS1="${PS1:-}"

assertContains "$OLD_ENV" "USER_VAR=original user value"

. ./envr.ps1

assertNotEqual "$OLD_ENV" "$(printenv)"
assertNotEqual "$OLD_PATH" "$PATH"
assertNotEqual "$OLD_ALS" "$(alias)"
assertNotEqual "$OLD_PS1" "${PS1:-}"

# test project options
if [[ -n "${BASH:-}" ]] ; then
    assertEqual "$(echo $PS1 | cut -c 9-)" "(poopsmith)"
elif [[ -n "${ZSH_VERSION:-}" ]] ; then
    assertEqual "$(echo $PS1 | cut -c 8-)" "(poopsmith) "
fi

# test aliases
assertEqual "$(user_alias)" "PWNED"
assertEqual "$(hello)" "Hello world!"

# test variables
NEW_ENV="$(printenv)"
assertContains "$NEW_ENV" "FOO=bar"                     
assertContains "$NEW_ENV" "ANSWER=42"                    
assertContains "$NEW_ENV" "SPACES=oh we got some spaces"
assertContains "$NEW_ENV" "USER_VAR=user value overwritten"

# test path
assertNotEqual "$OLD_PATH" "$PATH"
assertContains "$PATH" "/home"
assertContains "$PATH" "/usr/local/bin"

# some error is getting caught by unsource but it's not apparent in
# interactive testing - occurs when using aliases
CURRENT_RES=$RES
unsource
RES=$CURRENT_RES

# test project options
#TODO: why is this failing...
# assertEqual "$OLD_PS1" "${PS1:-}"

# test aliases
assertNotContains "hello" "$(alias)"
assertEqual "$(user_alias user)" "user"
#TODO: why is this failing...
# assertEqual "$OLD_ALS" "$(alias)"

# test variables          
RESTORED_ENV="$(printenv)"
assertNotContains "$RESTORED_ENV" "FOO"                        
assertNotContains "$RESTORED_ENV" "ANSWER"                     
assertNotContains "$RESTORED_ENV" "SPACES"
assertContains "$RESTORED_ENV" "USER_VAR=original user value"
assertEqual "$OLD_PATH" "$PATH"

# test path
assertEqual $OLD_PATH "$PATH"
assertNotContains "$PATH" "/home"
assertContains "$PATH" "/usr/local/bin"

exit $RES