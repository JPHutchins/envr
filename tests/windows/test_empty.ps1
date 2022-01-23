function global:empty () {
    . tests/windows/helpers.ps1

    . ./envr.ps1

    unsource

    return $RES
}