source tests/sh/helpers.sh

echo -e "Running tests on GNU bash ${BASH_VERSION}"

rm envr-local 2> /dev/null

RES=0  # reset helpers.sh::trap

runtest bash empty
runtest bash envars
runtest bash project_options
runtest bash aliases
runtest bash path

# create a python venv
python3 -m venv venv
runtest bash python_venv
rm -Rf venv

runtest bash full

rm envr-local

if [[ $RES = 0 ]] ; then
    echo -e "${GRN}GNU bash ${BASH_VERSION} passed!${RST} 🎉"    
else 
    echo -e "${RED}GNU bash ${BASH_VERSION} failed!${RST} 🤬"
fi

exit $RES