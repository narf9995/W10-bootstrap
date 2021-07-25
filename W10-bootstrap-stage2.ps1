### Windows 10 Config Bootsrap Script
### By NAAJ - Dev. started 7/22/2021

# Check Powershell Running with Admin Privilleges; Escalate If Not
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# 1 - Finalize WSL Install

# Install WSL2 
cd filesystem::c:\SystemDownload\Temp | Start-Process -FilePath C:\SystemDownload\Temp\wsl_update_x64.msi -wait

# Set WSL 2 as your default version
wsl --set-default-version 2

## 2 - Install Powershell Modules

# Download & Install Custom Powershell Module


# Pscx - PowerShell Community Extensions
Install-Module Pscx -Scope CurrentUser -Force

# DeviceManagement Powershell Module
Install-Module -Name DeviceManagement -Scope CurrentUser -Force

# AnyBox Module
Install-Module -Name 'AnyBox' -Force