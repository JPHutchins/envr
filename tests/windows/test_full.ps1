function global:full_win () {
    . tests/windows/helpers.ps1

    Copy-Item -Path Env:PATH -Destination Env:OLD_PATH

    # Path
    assertContains $env:OLD_PATH "C:\Windows$([System.IO.Path]::PathSeparator)"
    assertNotContains $env:OLD_PATH "C:\Users$([System.IO.Path]::PathSeparator)"

    # Alias
    $contains_user_alias = Test-Path -Path alias:user_alias
    assertEqual False $contains_user_alias

    $contains_hello = Test-Path -Path alias:hello
    assertEqual False $contains_hello

    function _user_alias_fn () {return "original user alias"}
    Set-Alias -Name user_alias -Value _user_alias_fn -Option AllScope
    assertEqual "original user alias" $(user_alias)

    $contains_user_alias = Test-Path -Path alias:user_alias
    assertEqual True $contains_user_alias

    # Variables
    assertNotInEnv FOO
    assertNotInEnv ANSWER
    assertNotInEnv SPACES
    assertNotInEnv USER_VAR

    Set-Item -Path env:USER_VAR -Value "very important user envar"

    assertInEnv USER_VAR
    assertEqual $env:USER_VAR "very important user envar"

    # Project Options
    $OLD_PS1_OUT = prompt 6>&1

    . ./envr.ps1

    # Path
    assertContains $env:path "C:\Users$([System.IO.Path]::PathSeparator)"

    # Alias
    $contains_hello = Test-Path -Path alias:hello
    assertEqual True $contains_hello

    assertEqual "Hello world!" $(hello)

    assertEqual "PWNED" $(user_alias)

    # Variables
    assertInEnv FOO
    assertInEnv ANSWER
    assertInEnv SPACES
    assertInEnv USER_VAR

    assertEqual $env:FOO bar
    assertEqual $env:ANSWER 42
    assertEqual $env:SPACES "oh we got some spaces"
    assertEqual $env:USER_VAR "user value overwritten"

    # Project Options
    $PS1_OUT = prompt 6>&1
    assertEqual "(poopsmith)  $OLD_PS1_OUT" $PS1_OUT

    unsource

    # Path
    assertNotContains $env:OLD_PATH "C:\Users$([System.IO.Path]::PathSeparator)"
    assertEqual $env:OLD_PATH $env:path

    # Alias
    $contains_hello = Test-Path -Path alias:hello
    assertEqual False $contains_hello

    $contains_user_alias = Test-Path -Path alias:user_alias
    assertEqual True $contains_user_alias
    
    assertEqual "original user alias" $(user_alias)

    Remove-Item -Path alias:user_alias -Force

    # Variables
    assertNotInEnv FOO
    assertNotInEnv ANSWER
    assertNotInEnv SPACES
    assertInEnv USER_VAR
    assertEqual $env:USER_VAR "very important user envar"

    Remove-Item -Path env:USER_VAR

    assertNotInEnv USER_VAR

    # Project Options
    $PS1_OUT = prompt 6>&1
    assertEqual $OLD_PS1_OUT $PS1_OUT

    return $RES
}