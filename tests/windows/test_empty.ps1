function global:empty () {
    $TEST_RES = 0

    . tests/windows/helpers.ps1

    $TEST_RES += assertNotInEnv ENVR_ROOT

    . ./envr.ps1

    $TEST_RES += assertEqual "$(Get-Location)" $env:ENVR_ROOT

    unsource

    $TEST_RES += assertNotInEnv ENVR_ROOT

    return $TEST_RES
}