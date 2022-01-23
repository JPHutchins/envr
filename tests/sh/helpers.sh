# Helper constants and functions for bash tests

readonly GRN="\e[0;32m"
readonly RED="\e[0;31m"
readonly RST="\e[0m"

assertEqual () {
    if [[ $1 != $2 ]] ; then
        echo -e -n "$RED.$RST $1 != $2"
        return 1
    else
        echo -e -n "$GRN. $RST"
    fi
}

assertNotEqual () {
    if [[ $1 = $2 ]] ; then
        echo -e -n "$RED.$RST $1 != $2"
        return 1
    else
        echo -e -n "$GRN. $RST"
    fi
}

assertContains () {
    case "$1" in 
        *"$2"*) echo -e -n "$GRN. $RST" ;;
        *) echo -e -n "$RED.$RST $2 not found " ; return 1 ;;
    esac
}

assertNotContains () {
    case "$1" in 
        *"$2"*) echo -e -n "$RED.$RST $2 found | " ; return 1 ;;
        *) echo -e -n "$GRN. $RST" ;;
    esac
}

pass () {
    echo -e -n "\r✅\n"
    echo -e -n "\t\t$GRN$1$RST\n"
}

fail () {
    echo -e -n "\r❌\n"
    echo -e -n "\t\t$RED$1$RST\n"
}

zsh_emulate_sh () {
    if [[ -n "$ZSH_VERSION" ]] ; then
        emulate -L sh
    fi
}

runtest () {
    echo -n -e "\tTesting $2 "
    env -i $1 tests/sh/test_$2.sh $2
    if [[ $? != 0 ]] ; then
        fail "$2 failed! 💩"
        return 1
    else
        pass "$2 passed! 🥳"
        return 0
    fi
}

trap '(( RES |= $? ))' ERR