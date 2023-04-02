function global:envars () {
    $TEST_RES = 0

    . tests/windows/helpers.ps1

    $TEST_RES += assertNotInEnv FOO
    $TEST_RES += assertNotInEnv ANSWER
    $TEST_RES += assertNotInEnv SPACES
    $TEST_RES += assertNotInEnv USER_VAR

    Set-Item -Path env:USER_VAR -Value "very important user envar"

    $TEST_RES += assertInEnv USER_VAR
    $TEST_RES += assertEqual $env:USER_VAR "very important user envar"

    . ./envr.ps1

    $TEST_RES += assertInEnv FOO
    $TEST_RES += assertInEnv ANSWER
    $TEST_RES += assertInEnv SPACES
    $TEST_RES += assertInEnv USER_VAR

    $TEST_RES += assertEqual $env:FOO bar
    $TEST_RES += assertEqual $env:ANSWER 42
    $TEST_RES += assertEqual $env:SPACES "oh we got some spaces"
    $TEST_RES += assertEqual $env:USER_VAR "user value overwritten"

    unsource

    $TEST_RES += assertNotInEnv FOO
    $TEST_RES += assertNotInEnv ANSWER
    $TEST_RES += assertNotInEnv SPACES
    $TEST_RES += assertInEnv USER_VAR
    $TEST_RES += assertEqual $env:USER_VAR "very important user envar"

    Remove-Item -Path env:USER_VAR

    $TEST_RES += assertNotInEnv USER_VAR

    return $TEST_RES
}