#!/bin/zsh

source tests/sh/helpers.sh

_ZSH_VERSION=$(zsh --version)

echo -e "Running tests on ${_ZSH_VERSION}"

rm envr-local 2> /dev/null

RES=0  # reset helpers.sh::trap

runtest zsh empty
runtest zsh envars
runtest zsh project_options
runtest zsh aliases
runtest zsh path
runtest zsh expansion

# create a python venv
python3 -m venv venv
runtest zsh python_venv
rm -Rf venv

runtest zsh full

rm envr-local 2> /dev/null

if [[ $RES = 0 ]] ; then
    echo -e "${GRN}${_ZSH_VERSION} passed!${RST} 🎉"    
else 
    echo -e "${RED}${_ZSH_VERSION} failed!${RST} 🤬"
fi

exit $RES