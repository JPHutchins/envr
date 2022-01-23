
$global:RES = 0
function global:assertEqual ($a, $b) {
    if ($a -eq $b) {
        Write-Host ". " -ForegroundColor Green -NoNewline
    }
    else {
        Write-Host ". $a != $b" -ForegroundColor Red -NoNewline
        $global:RES = 1
    }
}

function global:assertNotEqual ($a, $b) {
    if ($a -eq $b) {
        Write-Host ". $a == $b" -ForegroundColor Red -NoNewline
        $global:RES = 1
    }
    else {
        Write-Host ". " -ForegroundColor Green -NoNewline
    }
}

function global:assertContains ($container, $item) {
    if ($container -clike "*$item*") {
        Write-Host ". " -ForegroundColor Green -NoNewline
    }
    else {
        Write-Host "$container contains $item" -ForegroundColor Red -NoNewline
        $global:RES = 1
    }
}

function global:assertNotContains ($container, $item) {
    if ($container -clike "*$item*") {
        Write-Host "$container contains $item" -ForegroundColor Red -NoNewline
        $global:RES = 1
    }
    else {
        Write-Host ". " -ForegroundColor Green -NoNewline
    }
}

function global:assertInEnv ($a) {
    if (Test-Path -Path env:$a) {
        Write-Host ". " -ForegroundColor Green -NoNewline
    }
    else {
        Write-Host "$a not in env" -ForegroundColor Red -NoNewline
        $global:RES = 1
    }
}

function global:assertNotInEnv ($a) {
    if (Test-Path -Path env:$a) {
        Write-Host "$a in env:" -ForegroundColor Red -NoNewline
        $global:RES = 1
    }
    else {
        Write-Host ". " -ForegroundColor Green -NoNewline
    }
}

$EMOJI_WHITE_HEAVY_CHECK_MARK = [char]::ConvertFromUtf32(0x2705)
$EMOJI_FACE_WITH_PARTY_HORN = [char]::ConvertFromUtf32(0x1f973)
$EMOJI_CROSS_MARK = [char]::ConvertFromUtf32(0x274C)
$EMOJI_POOP = [char]::ConvertFromUtf32(0x1F4A9)

function global:runTest ($name) {
    Write-Host "`tTesting $name " -NoNewline
    Copy-Item tests/fixtures/$name envr-local
    $global:RES = & $name
    if ($RES -eq 0) {
        Write-Host "`r$EMOJI_WHITE_HEAVY_CHECK_MARK`n`t`t$name passed! $EMOJI_FACE_WITH_PARTY_HORN" -ForegroundColor Green
    }
    else {
        Write-Host "`r$EMOJI_CROSS_MARK`n`t`t$name failed! $EMOJI_POOP" -ForegroundColor Red
    }
    Remove-Item .\envr-local
}