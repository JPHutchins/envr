. tests/windows/helpers.ps1
. tests/windows/test_empty.ps1
. tests/windows/test_envars.ps1
. tests/windows/test_expansion.ps1
. tests/windows/test_project_options.ps1
. tests/windows/test_aliases.ps1
. tests/windows/test_path.ps1
. tests/windows/test_full.ps1

$_PS_VERSION = $PSVersionTable.PSVersion

Write-Host "Running tests on Windows PowerShell $_PS_VERSION"

$TEST_RES = 0

$TEST_RES += runTest empty
$TEST_RES += runTest envars
$TEST_RES += runTest project_options
$TEST_RES += runTest aliases
$TEST_RES += runTest path_win
$TEST_RES += runTest full_win
$TEST_RES += runTest expansion

if ($TEST_RES -eq 0) {
    Write-Host "Windows PowerShell $_PS_VERSION passed! 🎉"  -ForegroundColor Green
}    
else {
    Write-Host "Windows PowerShell $_PS_VERSION failed! 🤬" -ForegroundColor Red
}

exit $TEST_RES