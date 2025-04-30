Start-Transcript -Path "C:\Windows\Temp\PostInstall-Full.log" -Append
Write-Output "Starting post-install tasks..."

# Ensure TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Install Chocolatey (if missing)
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Output "Chocolatey already installed."
}

# Install Winget (if missing) - needs App Installer package
$winget = "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*"
if (-not (Test-Path $winget)) {
    Write-Output "Installing Winget via Microsoft Store..."
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$env:TEMP\Winget.msixbundle"
    Add-AppxPackage -Path "$env:TEMP\Winget.msixbundle"
} else {
    Write-Output "Winget already present."
}

# Refresh environment to use choco immediately
$env:Path += ";$env:ProgramData\chocolatey\bin"

# Useful Apps (via Chocolatey or Winget)
Write-Output "Installing apps..."

# Chocolatey installs
choco install googlechrome -y
choco install 7zip -y
choco install vlc -y


# Winget installs (fallbacks or extras)
# You can uncomment these as needed
winget install -e --id Microsoft.Office

# RMM agent installer
# Write-Output "Installing RMM agent..."
# Invoke-WebRequest -Uri "https://setup.euplatform.connectwise.com/windows/BareboneAgent/32/TechResults-Techresults_-_manual_Windows_OS_ITSPlatform_TKN35a6029f-a4f5-4b27-9fc4-5eb07f4ead12/MSI/setup" -OutFile "$env:TEMP\rmm.exe"
# Start-Process "$env:TEMP\rmm.exe" -ArgumentList "/quiet" -Wait

# Set power plan to high performance
powercfg -setactive SCHEME_MIN

# Disable Sleep for plugged-in state
powercfg -change -standby-timeout-ac 0

# Enable Windows Update immediately
Write-Output "Triggering Windows Update..."
Start-Process -FilePath "powershell.exe" -ArgumentList "-Command", "Install-WindowsUpdate -AcceptAll -AutoReboot" -Wait

Write-Output "Post-install tasks complete."
Stop-Transcript
