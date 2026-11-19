$ErrorActionPreference='Stop'
& (Join-Path $PSScriptRoot 'tools/Stop-ProjectServer.ps1') -Name frontend
& (Join-Path $PSScriptRoot 'tools/Stop-ProjectServer.ps1') -Name backend
