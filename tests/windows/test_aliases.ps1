function global:aliases () {
    $TEST_RES = 0

    . tests/windows/helpers.ps1

    $contains_user_alias = Test-Path -Path alias:user_alias
    $TEST_RES += assertEqual False $contains_user_alias

    $contains_hello = Test-Path -Path alias:hello
    $TEST_RES += assertEqual False $contains_hello

    function _user_alias_fn () {return "original user alias"}
    Set-Alias -Name user_alias -Value _user_alias_fn -Option AllScope
    $TEST_RES += assertEqual "original user alias" $(user_alias)

    $contains_user_alias = Test-Path -Path alias:user_alias
    $TEST_RES += assertEqual True $contains_user_alias

    . ./envr.ps1

    $contains_hello = Test-Path -Path alias:hello
    $TEST_RES += assertEqual True $contains_hello

    $TEST_RES += assertEqual "Hello world!" $(hello)

    $TEST_RES += assertEqual "PWNED" $(user_alias)

    unsource

    $contains_hello = Test-Path -Path alias:hello
    $TEST_RES += assertEqual False $contains_hello

    $contains_user_alias = Test-Path -Path alias:user_alias
    $TEST_RES += assertEqual True $contains_user_alias
    
    $TEST_RES += assertEqual "original user alias" $(user_alias)

    Remove-Item -Path alias:user_alias -Force

    return $TEST_RES
}