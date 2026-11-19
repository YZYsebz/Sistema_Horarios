param([string]$Url='http://127.0.0.1:5080')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Use-ProjectEnvironment.ps1')
New-Item -ItemType Directory -Path (Join-Path $taskRoot '.local') -Force | Out-Null
$taskExe=Join-Path $taskRoot '.tools\dotnet\dotnet.exe'
$taskDll=Join-Path $taskRoot 'backend\SistemaHorarios.Api\bin\Debug\net10.0\SistemaHorarios.Api.dll'
if(-not(Test-Path -LiteralPath $taskDll)){throw 'Compile la solución antes de iniciar la API.'}
$taskProcess=Start-Process -FilePath $taskExe -ArgumentList @('"'+$taskDll+'"','--urls',$Url) -WorkingDirectory $taskRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $taskRoot '.local\backend.log') -RedirectStandardError (Join-Path $taskRoot '.local\backend.err.log')
$taskProcess.Id | Set-Content -LiteralPath (Join-Path $taskRoot '.local\backend.pid')
Write-Host ('API iniciada, PID '+$taskProcess.Id+' en '+$Url)
