$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Use-ProjectEnvironment.ps1')
New-Item -ItemType Directory -Path (Join-Path $taskRoot '.local') -Force | Out-Null
$taskNode=(Get-Command node.exe).Source
$taskVite=Join-Path $taskRoot 'frontend\node_modules\vite\bin\vite.js'
$taskProcess=Start-Process -FilePath $taskNode -ArgumentList @('"'+$taskVite+'"','--host','127.0.0.1','--port','5173') -WorkingDirectory (Join-Path $taskRoot 'frontend') -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $taskRoot '.local\frontend.log') -RedirectStandardError (Join-Path $taskRoot '.local\frontend.err.log')
$taskProcess.Id | Set-Content -LiteralPath (Join-Path $taskRoot '.local\frontend.pid')
Write-Host ('Frontend iniciado, PID '+$taskProcess.Id+' en http://127.0.0.1:5173')
