function global:path_win () {
    . tests/windows/helpers.ps1

    Copy-Item -Path Env:PATH -Destination Env:OLD_PATH

    assertContains $env:OLD_PATH "C:\Windows$([System.IO.Path]::PathSeparator)"
    assertNotContains $env:OLD_PATH "C:\Users$([System.IO.Path]::PathSeparator)"

    . ./envr.ps1

    assertContains $env:path "C:\Users$([System.IO.Path]::PathSeparator)"

    unsource

    assertNotContains $env:OLD_PATH "C:\Users$([System.IO.Path]::PathSeparator)"
    assertEqual $env:OLD_PATH $env:path

    return $RES
}