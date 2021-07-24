### Windows 10 Config Bootsrap Script
### By NAAJ - Dev. started 7/22/2021

# Check Powershell Running with Admin Privilleges; Escalate If Not
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Check if SystemDownload Exists; Create if Absent
$path = "C:\SystemDownload"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

# Download latest PowerShell-7 release from github
# Forked from Splaxi/download-latest-release.ps1 (https://gist.github.com/Splaxi/fe168eaa91eb8fb8d62eba21736dc88a)
$repo = "PowerShell/PowerShell"
$filenamePattern = "*win-x64.msi"
$pathExtract = "C:\SystemDownload\Temp"
$innerDirectory = $false
$preRelease = $false

if ($preRelease) {
    $releasesUri = "https://api.github.com/repos/$repo/releases"
    $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri)[0].assets | Where-Object name -like $filenamePattern ).browser_download_url
}
else {
    $releasesUri = "https://api.github.com/repos/$repo/releases/latest"
    $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -like $filenamePattern ).browser_download_url
}

$pathZip = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $(Split-Path -Path $downloadUri -Leaf)

Invoke-WebRequest -Uri $downloadUri -Out $pathZip

Remove-Item -Path $pathExtract -Recurse -Force -ErrorAction SilentlyContinue

if ($innerDirectory) {
    $tempExtract = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $((New-Guid).Guid)
    Expand-Archive -Path $pathZip -DestinationPath $tempExtract -Force
    Move-Item -Path "$tempExtract\*" -Destination $pathExtract -Force
    #Move-Item -Path "$tempExtract\*\*" -Destination $location -Force
    Remove-Item -Path $tempExtract -Force -Recurse -ErrorAction SilentlyContinue
}
else {
    Expand-Archive -Path $pathZip -DestinationPath $pathExtract -Force
}

Remove-Item $pathZip -Force

# Find & Install Powershell 7
$powershell = Get-ChildItem -Path C:\SystemDownload\Temp -Include *win-x64.msi -File -Recurse -ErrorAction SilentlyContinue
cd filesystem::c:\SystemDownload\Temp | Invoke-Expression; ./$powershell

# Download & Install Custom Powershell Module

# Enable Virtual Machine Platform Feature
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Download WSL2 Update
cd $env:temp | Invoke-Expression; Invoke-RestMethod -Method Get -URI https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi | Invoke-Expression; ./wsl_update_x64.msi

# Restart Computer to Finalize WSL Install
Restart-Computer