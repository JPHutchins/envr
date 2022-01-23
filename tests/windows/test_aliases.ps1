function global:aliases () {
    . tests/windows/helpers.ps1

    $contains_user_alias = Test-Path -Path alias:user_alias
    assertEqual False $contains_user_alias

    $contains_hello = Test-Path -Path alias:hello
    assertEqual False $contains_hello

    Set-Alias -Name user_alias -Value pwd

    $contains_user_alias = Test-Path -Path alias:user_alias
    assertEqual True $contains_user_alias

    . ./envr.ps1

    $contains_hello = Test-Path -Path alias:hello
    assertEqual True $contains_hello

    $out = hello
    assertEqual "$out" "Hello world!"

    unsource

    $contains_hello = Test-Path -Path alias:hello
    assertEqual False $contains_hello

    $contains_user_alias = Test-Path -Path alias:user_alias
    assertEqual True $contains_user_alias

    return $RES
}