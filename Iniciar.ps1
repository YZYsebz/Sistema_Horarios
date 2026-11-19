param([switch]$SinCompilar)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'tools/Use-ProjectEnvironment.ps1')
Push-Location -LiteralPath $taskRoot
try {
 if(-not(Test-Path -LiteralPath '.secrets/development.json')){throw 'Falta la configuración local. Consulte README.md, sección Primera instalación.'}
 if(-not(Test-Path -LiteralPath 'frontend/node_modules/vite/bin/vite.js')){
  Push-Location -LiteralPath 'frontend'
  try{npm ci; if($LASTEXITCODE -ne 0){throw 'Falló npm ci.'}}finally{Pop-Location}
 }
 & ./tools/Stop-ProjectServer.ps1 -Name backend
 & ./tools/Stop-ProjectServer.ps1 -Name frontend
 if(-not $SinCompilar){
  dotnet build SistemaHorarios.sln -v minimal
  if($LASTEXITCODE -ne 0){throw 'Falló la compilación del backend.'}
 }
 & ./tools/Start-Backend.ps1
 & ./tools/Start-Frontend.ps1
 $taskReady=$false
 for($taskAttempt=0;$taskAttempt -lt 15;$taskAttempt++){
  try{
   $taskHealth=Invoke-RestMethod 'http://127.0.0.1:5080/api/health' -TimeoutSec 2
   $taskWeb=Invoke-WebRequest 'http://127.0.0.1:5173/' -TimeoutSec 2
   if($taskHealth.status -eq 'ok' -and $taskWeb.StatusCode -eq 200){$taskReady=$true;break}
  }catch{Start-Sleep -Milliseconds 500}
 }
 if(-not $taskReady){throw 'Los servidores no respondieron. Consulte los logs dentro de .local.'}
 Write-Host 'Aplicación: http://127.0.0.1:5173/'
 Write-Host 'Swagger:    http://127.0.0.1:5080/swagger'
 Write-Host 'Detener:    .\Detener.ps1'
}finally{Pop-Location}
