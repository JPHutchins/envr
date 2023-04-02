function global:path_win () {
    $TEST_RES = 0

    . tests/windows/helpers.ps1

    Copy-Item -Path Env:PATH -Destination Env:OLD_PATH

    $TEST_RES += assertContains $env:OLD_PATH "C:\Windows$([System.IO.Path]::PathSeparator)"
    $TEST_RES += assertNotContains $env:OLD_PATH "C:\Users$([System.IO.Path]::PathSeparator)"

    . ./envr.ps1

    $TEST_RES += assertContains $env:path "C:\Users$([System.IO.Path]::PathSeparator)"

    unsource

    $TEST_RES += assertNotContains $env:OLD_PATH "C:\Users$([System.IO.Path]::PathSeparator)"
    $TEST_RES += assertEqual $env:OLD_PATH $env:path

    return $TEST_RES
}