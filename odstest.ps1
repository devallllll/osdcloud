Start-Transcript -Path "$env:WINDIR\Temp\GitHubPostInstall.log" -Append
Write-Output "Downloading GitHub-hosted postinstall.ps1 script..."

# Use the RAW GitHub URL for the actual script
$rawScriptUri = "https://raw.githubusercontent.com/devallllll/osdcloud/main/postinstall.ps1"
$tempScript = "$env:TEMP\postinstall.ps1"

Invoke-WebRequest -Uri $rawScriptUri -OutFile $tempScript -UseBasicParsing

Write-Output "Running postinstall.ps1..."
powershell.exe -ExecutionPolicy Bypass -File $tempScript

Write-Output "Finished running postinstall.ps1"
Stop-Transcript
