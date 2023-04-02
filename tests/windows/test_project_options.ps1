function global:project_options () {
    $TEST_RES = 0

    . tests/windows/helpers.ps1

    $OLD_PS1_OUT = prompt 6>&1

    . ./envr.ps1

    $PS1_OUT = prompt 6>&1
    $TEST_RES += assertEqual "(my long project name 1337 !_$#? 3)  $OLD_PS1_OUT" $PS1_OUT

    unsource

    $PS1_OUT = prompt 6>&1
    $TEST_RES += assertEqual $OLD_PS1_OUT $PS1_OUT

    return $TEST_RES
}