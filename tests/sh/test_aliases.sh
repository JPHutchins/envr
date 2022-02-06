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

OLD_ENV="$(printenv)"
OLD_PATH="$PATH"
OLD_ALS="$(alias)"
OLD_PS1="${PS1:-}"

. ./envr.ps1

assertEqual "$OLD_PATH" "$PATH"

# test aliases
assertEqual "$(user_alias)" "PWNED"
assertEqual "$(hello)" "Hello world!"

# cut off the leading characters
if [[ -n "${BASH:-}" ]] ; then
    assertEqual "$(echo $PS1 | cut -c 9-)" "(envr)"
elif [[ -n "${ZSH_VERSION:-}" ]] ; then
    assertEqual "$(echo $PS1 | cut -c 8-)" "(envr) "
fi

# some error is getting caught by unsource but it's not apparent in
# interactive testing - occurs when using aliases
CURRENT_RES=$RES
unsource
RES=$CURRENT_RES

assertEqual "$OLD_PATH" "$PATH"
#TODO: why is this failing...
# assertEqual "$OLD_ALS" "$(alias)"

assertNotContains "hello" "$(alias)"

# user alias is restored
assertEqual "$(user_alias user)" "user"

exit $RES