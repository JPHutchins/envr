function global:expansion () {
    $TEST_RES = 0

    . tests/windows/helpers.ps1

    $TEST_RES += assertNotInEnv ENVR_ROOT
    $TEST_RES += assertNotInEnv ABS_PATH_EXAMPLE
    $TEST_RES += assertNotInEnv COMBINED
    $TEST_RES += assertNotInEnv COMBINED_PATH

    . ./envr.ps1

    $TEST_RES += assertEqual "$(Get-Location)" $env:ENVR_ROOT
    $TEST_RES += assertEqual "$(Get-Location)/path/to/resource" $env:ABS_PATH_EXAMPLE
    $TEST_RES += assertEqual bar42 $env:COMBINED
    $TEST_RES += assertEqual "$(Get-Location)/path/to/resource/bar42" $env:COMBINED_PATH

    $TEST_RES += assertContains $env:path "$(Get-Location)/tests/fixtures$([System.IO.Path]::PathSeparator)"
    $TEST_RES += assertContains $env:path "$(Get-Location)/path/to/resource/bar42$([System.IO.Path]::PathSeparator)"

    unsource

    $TEST_RES += assertNotInEnv ENVR_ROOT
    $TEST_RES += assertNotInEnv ABS_PATH_EXAMPLE
    $TEST_RES += assertNotInEnv COMBINED
    $TEST_RES += assertNotInEnv COMBINED_PATH

    return $TEST_RES
}