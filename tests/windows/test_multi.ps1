function global:multi () {
    $TEST_RES = 0

    . tests/windows/helpers.ps1

    Copy-Item -Path Env:PATH -Destination Env:OLD_PATH

    # Path
    $TEST_RES += assertNotContains $env:OLD_PATH "C:\Windows\Help$([System.IO.Path]::PathSeparator)"
    $TEST_RES += assertNotContains $env:OLD_PATH "C:\Windows\Logs$([System.IO.Path]::PathSeparator)"

    # Alias
    $contains_user_alias = Test-Path -Path alias:user_alias
    $TEST_RES += assertEqual False $contains_user_alias

    $contains_hello = Test-Path -Path alias:hello
    $TEST_RES += assertEqual False $contains_hello

    $contains_new_alias = Test-Path -Path alias:new_alias
    $TEST_RES += assertEqual False $contains_new_alias

    function _user_alias_fn () {return "original user alias"}
    Set-Alias -Name user_alias -Value _user_alias_fn -Option AllScope
    $TEST_RES += assertEqual "original user alias" $(user_alias)

    $contains_user_alias = Test-Path -Path alias:user_alias
    $TEST_RES += assertEqual True $contains_user_alias

    # Variables
    $TEST_RES += assertNotInEnv FOO
    $TEST_RES += assertNotInEnv ANSWER
    $TEST_RES += assertNotInEnv SPACES
    $TEST_RES += assertNotInEnv USER_VAR

    Set-Item -Path env:USER_VAR -Value "original user value"

    $TEST_RES += assertInEnv USER_VAR
    $TEST_RES += assertEqual $env:USER_VAR "original user value"

    # Project Options
    $OLD_PS1_OUT = prompt 6>&1

    . ./envr.ps1

    # Path
    $TEST_RES += assertContains $env:path "C:\Windows\Logs$([System.IO.Path]::PathSeparator)"
    $TEST_RES += assertContains $env:path "C:\Windows\Help$([System.IO.Path]::PathSeparator)"
    $TEST_RES += assertContains $env:path "C:\Program Files (x86)$([System.IO.Path]::PathSeparator)"

    # Alias
    $contains_hello = Test-Path -Path alias:hello
    $TEST_RES += assertEqual True $contains_hello

    $TEST_RES += assertEqual "Hello world!" $(hello)

    $TEST_RES += assertEqual "2c" $(user_alias)

    # Variables
    $TEST_RES += assertEqual $env:FOO "2d"
    $TEST_RES += assertEqual $env:ANSWER 42
    $TEST_RES += assertEqual $env:SPACES "oh we got some spaces"
    $TEST_RES += assertEqual $env:USER_VAR "2e"
    $TEST_RES += assertEqual $env:NEW_VAR "new_var"

    # Project Options
    $PS1_OUT = prompt 6>&1
    $TEST_RES += assertEqual "(2a)  $OLD_PS1_OUT" $PS1_OUT

    unsource

    # Path
    $TEST_RES += assertNotContains $env:OLD_PATH "C:\Users$([System.IO.Path]::PathSeparator)"
    $TEST_RES += assertEqual $env:OLD_PATH $env:path

    # Alias
    $contains_hello = Test-Path -Path alias:hello
    $TEST_RES += assertEqual False $contains_hello

    $contains_user_alias = Test-Path -Path alias:user_alias
    $TEST_RES += assertEqual True $contains_user_alias
    
    $TEST_RES += assertEqual "original user alias" $(user_alias)

    Remove-Item -Path alias:user_alias -Force

    # Variables
    $TEST_RES += assertNotInEnv FOO
    $TEST_RES += assertNotInEnv ANSWER
    $TEST_RES += assertNotInEnv SPACES
    $TEST_RES += assertInEnv USER_VAR
    $TEST_RES += assertEqual $env:USER_VAR "original user value"

    Remove-Item -Path env:USER_VAR

    $TEST_RES += assertNotInEnv USER_VAR

    # Project Options
    $PS1_OUT = prompt 6>&1
    $TEST_RES += assertEqual $OLD_PS1_OUT $PS1_OUT

    return $TEST_RES
}
