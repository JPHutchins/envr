function global:assertEqual ($a, $b) {
    if ($a -eq $b) {
        Write-Host ". " -ForegroundColor Green -NoNewline
        return 0
    }
    else {
        Write-Host ". $a != $b" -ForegroundColor Red -NoNewline
        return 1
    }
}

function global:assertNotEqual ($a, $b) {
    if ($a -eq $b) {
        Write-Host ". $a == $b" -ForegroundColor Red -NoNewline
        return 1
    }
    else {
        Write-Host ". " -ForegroundColor Green -NoNewline
        return 0
    }
}

function global:assertContains ($container, $item) {
    if ($container -clike "*$item*") {
        Write-Host ". " -ForegroundColor Green -NoNewline
        return 0
    }
    else {
        Write-Host "$container does not contain $item" -ForegroundColor Red -NoNewline
        return 1
    }
}

function global:assertNotContains ($container, $item) {
    if ($container -clike "*$item*") {
        Write-Host "$container contains $item" -ForegroundColor Red -NoNewline
        return 1
    }
    else {
        Write-Host ". " -ForegroundColor Green -NoNewline
        return 0
    }
}

function global:assertInEnv ($a) {
    if (Test-Path -Path env:$a) {
        Write-Host ". " -ForegroundColor Green -NoNewline
        return 0
    }
    else {
        Write-Host "$a not in env" -ForegroundColor Red -NoNewline
        return 1
    }
}

function global:assertNotInEnv ($a) {
    if (Test-Path -Path env:$a) {
        Write-Host "$a in env:" -ForegroundColor Red -NoNewline
        return 1
    }
    else {
        Write-Host ". " -ForegroundColor Green -NoNewline
        return 0
    }
}

$EMOJI_WHITE_HEAVY_CHECK_MARK = [char]::ConvertFromUtf32(0x2705)
$EMOJI_FACE_WITH_PARTY_HORN = [char]::ConvertFromUtf32(0x1f973)
$EMOJI_CROSS_MARK = [char]::ConvertFromUtf32(0x274C)
$EMOJI_POOP = [char]::ConvertFromUtf32(0x1F4A9)

function global:runTest ($name) {
    Write-Host "`tTesting $name " -NoNewline
    if ($name -eq "multi") {
        Copy-Item tests/fixtures/multi-default-win envr-default
        Copy-Item tests/fixtures/multi-local-win envr-local
    }
    else {
        Copy-Item tests/fixtures/empty envr-default
        Copy-Item tests/fixtures/$name envr-local
    }
    $TEST_RES = & $name
    if ($TEST_RES -eq 0) {
        Write-Host "`r$EMOJI_WHITE_HEAVY_CHECK_MARK`n`t`t$name passed! $EMOJI_FACE_WITH_PARTY_HORN" -ForegroundColor Green
    }
    else {
        Write-Host "`r$EMOJI_CROSS_MARK`n`t`t$name failed! $EMOJI_POOP" -ForegroundColor Red
    }
    Remove-Item .\envr-default
    Remove-Item .\envr-local

    return $TEST_RES
}