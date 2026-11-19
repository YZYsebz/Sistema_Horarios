param([ValidateSet('backend','frontend')][string]$Name='backend')
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$taskPidPath=Join-Path $taskRoot ('.local/'+$Name+'.pid')
if(Test-Path -LiteralPath $taskPidPath){
 $taskPid=[int](Get-Content -LiteralPath $taskPidPath -Raw)
 $taskProcess=Get-CimInstance Win32_Process -Filter ('ProcessId='+$taskPid) -ErrorAction SilentlyContinue
 if($taskProcess -and $taskProcess.CommandLine -and $taskProcess.CommandLine.Contains($taskRoot)){
  Stop-Process -Id $taskPid -Force
  Write-Host ('Proceso '+$Name+' detenido: '+$taskPid)
 }elseif($taskProcess){throw 'El PID guardado pertenece a otro proceso. No se detiene.'}
 Remove-Item -LiteralPath $taskPidPath
}
