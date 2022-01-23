#!/usr/bin/zsh

source tests/sh/helpers.sh

echo -e "Running tests on zsh"

rm envr-local 2> /dev/null

RES=0  # reset helpers.sh::trap

runtest zsh empty
runtest zsh envars
runtest zsh project_options
runtest zsh aliases
runtest zsh path

create a python venv
python3 -m venv venv
runtest zsh python_venv
rm -Rf venv

runtest zsh full

rm envr-local

if [[ $RES = 0 ]] ; then
    echo -e "${GRN}GNU bash ${BASH_VERSION} passed!${RST} 🎉"    
else 
    echo -e "${RED}GNU bash ${BASH_VERSION} failed!${RST} 🤬"
fi

exit $RES