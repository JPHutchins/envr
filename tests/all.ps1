# Tests powershell 5, powershell 7, bash, and zsh
# Requires a Windows host with all that installed!
# Don't use for github workflows!

& pwsh ./tests/windows/ps.ps1
& powershell ./tests/windows/ps.ps1
& bash ./tests/sh/bash.sh
& bash ./tests/sh/zsh.sh
