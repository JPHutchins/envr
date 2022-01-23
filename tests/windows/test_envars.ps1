function global:envars () {
    . tests/windows/helpers.ps1

    assertNotInEnv FOO
    assertNotInEnv ANSWER
    assertNotInEnv SPACES
    assertNotInEnv USER_VAR

    Set-Item -Path env:USER_VAR -Value "very important user envar"

    assertInEnv USER_VAR
    assertEqual $env:USER_VAR "very important user envar"

    . ./envr.ps1

    assertInEnv FOO
    assertInEnv ANSWER
    assertInEnv SPACES
    assertInEnv USER_VAR

    assertEqual $env:FOO bar
    assertEqual $env:ANSWER 42
    assertEqual $env:SPACES "oh we got some spaces"
    assertEqual $env:USER_VAR "user value overwritten"

    unsource

    assertNotInEnv FOO
    assertNotInEnv ANSWER
    assertNotInEnv SPACES
    assertInEnv USER_VAR
    assertEqual $env:USER_VAR "very important user envar"

    Remove-Item -Path env:USER_VAR

    assertNotInEnv USER_VAR

    return $RES
}