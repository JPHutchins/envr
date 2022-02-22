. tests/windows/helpers.ps1
. tests/windows/test_empty.ps1
. tests/windows/test_envars.ps1
. tests/windows/test_project_options.ps1
. tests/windows/test_aliases.ps1
. tests/windows/test_path.ps1

Write-Output "Running tests on Windows PowerShell"

runTest empty
runTest envars
runTest project_options
runTest aliases
runTest path_win
