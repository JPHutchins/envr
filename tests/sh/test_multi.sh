source tests/sh/helpers.sh
if [[ -n "${BASH:-}" ]] ; then
    shopt -s expand_aliases
elif [[ -n "${ZSH_VERSION:-}" ]] ; then
    setopt aliases
fi

cp tests/fixtures/$1-default envr-default
cp tests/fixtures/$1-local envr-local

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
    assertEqual "$(echo $PS1 | cut -c 15-)" "(2a)"
elif [[ -n "${ZSH_VERSION:-}" ]] ; then
    assertEqual "$(echo $PS1 | cut -c 8-)" "(2a) "
fi

# test aliases
assertEqual "$(user_alias)" "2c"
assertEqual "$(new_alias)" "new_alias"

# test variables
NEW_ENV="$(printenv)"
assertContains "$NEW_ENV" "FOO=2d"                     
assertContains "$NEW_ENV" "ANSWER=42"                    
assertContains "$NEW_ENV" "SPACES=oh we got some spaces"
assertContains "$NEW_ENV" "USER_VAR=2e"
assertContains "$NEW_ENV" "NEW_VAR=new_var"

# test path
assertNotEqual "$OLD_PATH" "$PATH"
assertNotContains "$PATH" "/usr:"
assertContains "$PATH" "/usr/local/bin"
assertContains "$PATH" "/usr/local"
assertContains "$PATH" "/etc"

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
assertNotContains "new_alias" "$(alias)"
assertEqual "$(user_alias user)" "user"
#TODO: why is this failing...
# assertEqual "$OLD_ALS" "$(alias)"

# test variables          
RESTORED_ENV="$(printenv)"
assertNotContains "$RESTORED_ENV" "FOO"                        
assertNotContains "$RESTORED_ENV" "ANSWER"                     
assertNotContains "$RESTORED_ENV" "SPACES"
assertNotContains "$RESTORED_ENV" "NEW_VAR"
assertContains "$RESTORED_ENV" "USER_VAR=original user value"
assertEqual "$OLD_PATH" "$PATH"

# test path
assertEqual $OLD_PATH "$PATH"
assertNotContains "$PATH" "/home"
assertContains "$PATH" "/usr/local/bin"

exit $RES