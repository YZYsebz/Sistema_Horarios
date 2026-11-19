param([string]$Servidor='lpc:LAPTOPMASEB\DBA_TOPICOS')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Use-ProjectEnvironment.ps1')
foreach($taskScript in @('13_NegativeTests.sql','14_DataValidation.sql')){
 $taskLog=Join-Path $taskRoot ('docs/fase1/'+$taskScript.Replace('.sql','.log'))
 & sqlcmd -S $Servidor -E -C -I -b -f 65001 -y 0 -w 65535 -i (Join-Path $taskRoot ('database/'+$taskScript)) -o $taskLog
 if($LASTEXITCODE -ne 0){throw "Falló $taskScript. Consulte $taskLog"}
}
$taskJson=Get-Content -LiteralPath (Join-Path $taskRoot 'docs/fase1/14_DataValidation.log') | Where-Object {$_.Trim().StartsWith('{')} | Select-Object -Last 1
if(-not $taskJson){throw 'No se encontró el resultado de validación.'}
$taskResult=$taskJson|ConvertFrom-Json
$taskResult|ConvertTo-Json -Depth 8|Set-Content -LiteralPath (Join-Path $taskRoot 'docs/fase1/Resultado_validacion.json') -Encoding UTF8
$taskResult.Conteos|Format-Table -AutoSize
Write-Host $taskResult.cEstado
Write-Host 'BASE DE DATOS LISTA PARA DESARROLLO'
