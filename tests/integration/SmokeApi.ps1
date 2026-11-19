param([string]$BaseUrl='http://127.0.0.1:5080')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot '../../tools/Use-ProjectEnvironment.ps1')
$taskConfig=Get-Content -LiteralPath (Join-Path $taskRoot '.secrets/development.json') -Raw | ConvertFrom-Json
$taskResults=[Collections.Generic.List[object]]::new()
function Assert-Task([string]$Name,[bool]$Condition) {
 $taskResults.Add([pscustomobject]@{prueba=$Name;correcta=$Condition})
 if(-not $Condition){throw "Falló: $Name"}
}
function Invoke-TaskApi([string]$Method,[string]$Path,$Body=$null,$Headers=@{},[int]$Expected=200) {
 $taskArgs=@{Uri=$BaseUrl+$Path;Method=$Method;Headers=$Headers;SkipHttpErrorCheck=$true}
 if($null -ne $Body){$taskArgs.ContentType='application/json';$taskArgs.Body=$Body|ConvertTo-Json -Depth 10 -Compress}
 $taskResponse=Invoke-WebRequest @taskArgs
 Assert-Task "$Method $Path -> $Expected" ([int]$taskResponse.StatusCode -eq $Expected)
 if($taskResponse.Content){return $taskResponse.Content|ConvertFrom-Json}
}
function Get-TaskToken([int]$Index) {
 $taskCredentials=$taskConfig.DemoUsers[$Index]
 $taskLogin=Invoke-TaskApi POST '/api/auth/login' @{usuario=$taskCredentials.UserName;password=$taskCredentials.Password}
 return @{Authorization="Bearer $($taskLogin.accessToken)"}
}
$taskOriginal=$null
$taskStudent=$null
try {
 $taskHealth=Invoke-TaskApi GET '/api/health'; Assert-Task 'Health real' ($taskHealth.status -eq 'ok')
 $null=Invoke-TaskApi GET '/api/materias' -Expected 401
 $null=Invoke-TaskApi POST '/api/auth/login' @{usuario='no.existe.demo';password='ContraseñaIncorrecta!'} -Expected 401
 $taskStudent=Get-TaskToken 0
 $taskProfile=Invoke-TaskApi GET '/api/estudiantes/me' -Headers $taskStudent
 Assert-Task 'Control numérico de ocho dígitos' ($taskProfile.numeroControl -match '^\d{8}$')
 $taskAvailable=@(Invoke-TaskApi GET '/api/estudiantes/me/materias-disponibles' -Headers $taskStudent)
 $taskIds=@($taskAvailable|Where-Object semestre -eq 5|Select-Object -First 4|ForEach-Object id)
 Assert-Task 'Cuatro materias de referencia disponibles' ($taskIds.Count -eq 4)
 $taskCredits=Invoke-TaskApi POST '/api/estudiantes/me/seleccion/creditos' @{materiaIds=$taskIds} $taskStudent
 Assert-Task 'Créditos validados por servidor' ($taskCredits.total -eq 16 -and $taskCredits.dentroDelLimite)
 $null=Invoke-TaskApi POST '/api/estudiantes/me/seleccion/creditos' @{materiaIds=@($taskIds[0],$taskIds[0])} $taskStudent 400
 $null=Invoke-TaskApi POST '/api/horarios/generar' @{materiaIds=@()} $taskStudent 400
 $null=Invoke-TaskApi POST '/api/horarios/generar' @{materiaIds=@(2147483647)} $taskStudent 422
 $taskOver=@($taskAvailable|Select-Object -First 12|ForEach-Object id)
 $null=Invoke-TaskApi POST '/api/horarios/generar' @{materiaIds=$taskOver} $taskStudent 422
 $taskGenerated=Invoke-TaskApi POST '/api/horarios/generar' @{materiaIds=$taskIds} $taskStudent
 Assert-Task 'Generador devuelve combinación completa' ($taskGenerated.opciones.Count -ge 1 -and $taskGenerated.opciones[0].grupos.Count -eq 4 -and $taskGenerated.opciones[0].creditos -eq 16)
 $taskBefore=@(Invoke-TaskApi GET '/api/horarios' -Headers $taskStudent)
 $taskOriginal=$taskBefore|Where-Object {$_.seleccionado -and $_.idPeriodo -eq $taskProfile.idPeriodo}|Select-Object -First 1
 $null=Invoke-TaskApi POST '/api/horarios' @{nombre='Inválido, no debe persistir';grupoIds=@(2147483647);seleccionar=$false} $taskStudent 409
 $taskAfterInvalid=@(Invoke-TaskApi GET '/api/horarios' -Headers $taskStudent)
 Assert-Task 'Guardado inválido no deja cabecera parcial' ($taskAfterInvalid.Count -eq $taskBefore.Count)
 $taskExisting=$taskBefore|Where-Object {$_.nombre -eq 'PRUEBA-API-INTEGRACION'}|Select-Object -First 1
 if($taskExisting){$taskSavedId=$taskExisting.id}
 else {
  $taskSaved=Invoke-TaskApi POST '/api/horarios' @{nombre='PRUEBA-API-INTEGRACION';grupoIds=@($taskGenerated.opciones[0].grupos|ForEach-Object id);seleccionar=$false} $taskStudent 201
  $taskSavedId=$taskSaved.id
 }
 $null=Invoke-TaskApi PUT "/api/horarios/$taskSavedId/seleccion" -Headers $taskStudent -Expected 204
 $taskSavedRows=@(Invoke-TaskApi GET '/api/horarios' -Headers $taskStudent)
 Assert-Task 'Persistencia y selección exclusivas' (@($taskSavedRows|Where-Object {$_.seleccionado -and $_.idPeriodo -eq $taskProfile.idPeriodo}).Count -eq 1 -and @($taskSavedRows|Where-Object {$_.id -eq $taskSavedId -and $_.seleccionado}).Count -eq 1)
 # ID ajeno obtenido con la identidad DBA Windows solo para esta prueba de aislamiento.
 $taskForeign=& sqlcmd -S 'lpc:LAPTOPMASEB\DBA_TOPICOS' -E -C -I -b -d Bd_SistemaHorarios -h -1 -W -Q "SET NOCOUNT ON; SELECT TOP(1) H.nIdHorarioGenerado FROM App.Tbl_HorarioGenerado H JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria WHERE T.nIdEstudiante<>$([int]$taskProfile.idEstudiante) ORDER BY H.nIdHorarioGenerado;"
 if($LASTEXITCODE -ne 0){throw 'No se pudo preparar la prueba de aislamiento.'}
 $taskForeignId=[int]($taskForeign|Where-Object {$_ -match '^\d+$'}|Select-Object -First 1)
 $null=Invoke-TaskApi PUT "/api/horarios/$taskForeignId/seleccion" -Headers $taskStudent -Expected 409
 $null=Invoke-TaskApi GET '/api/carreras' -Headers $taskStudent -Expected 403
 $taskTeacher=Get-TaskToken 1
 $null=Invoke-TaskApi GET '/api/estudiantes/me' -Headers $taskTeacher -Expected 403
 $taskTeacherGroups=@(Invoke-TaskApi GET '/api/grupos' -Headers $taskTeacher)
 Assert-Task 'Docente consulta únicamente sus grupos' (@($taskTeacherGroups|Select-Object -ExpandProperty idDocente -Unique).Count -le 1)
 $taskCoordinator=Get-TaskToken 2
 foreach($taskCatalog in @('carreras','reticulas','materias','periodos','docentes','aulas','grupos','estudiantes','sesiones')){
  $taskRows=@(Invoke-TaskApi GET "/api/$taskCatalog" -Headers $taskCoordinator)
  Assert-Task "Catálogo $taskCatalog con datos reales de SQL" ($taskRows.Count -gt 0)
 }
 $taskSwagger=Invoke-TaskApi GET '/swagger/v1/swagger.json'
 Assert-Task 'OpenAPI incluye generación y guardado' ($null -ne $taskSwagger.paths.'/api/horarios/generar' -and $null -ne $taskSwagger.paths.'/api/horarios')
} finally {
 if($taskOriginal -and $taskStudent){$null=Invoke-TaskApi PUT "/api/horarios/$($taskOriginal.id)/seleccion" -Headers $taskStudent -Expected 204}
 $taskResults|ConvertTo-Json -Depth 5|Set-Content -LiteralPath (Join-Path $taskRoot 'docs/Pruebas_integracion_API.json') -Encoding UTF8
}
$taskResults|Format-Table -AutoSize
Write-Host "$($taskResults.Count) comprobaciones de integración aprobadas. No se imprimieron credenciales."
