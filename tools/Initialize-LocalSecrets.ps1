param([string]$Servidor='lpc:LAPTOPMASEB\DBA_TOPICOS',[switch]$SincronizarPasswordRuntime)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Use-ProjectEnvironment.ps1')
$taskSecretPath=Join-Path $taskRoot '.secrets/development.json'
New-Item -ItemType Directory -Path (Join-Path $taskRoot '.secrets') -Force | Out-Null
function New-TaskSecret([int]$Length=32){$taskBytes=New-Object byte[] $Length;[Security.Cryptography.RandomNumberGenerator]::Fill($taskBytes);[Convert]::ToBase64String($taskBytes)+'aA1!'}
if(Test-Path -LiteralPath $taskSecretPath){
 $taskSecrets=Get-Content -LiteralPath $taskSecretPath -Raw -Encoding UTF8 | ConvertFrom-Json
}else{
 $taskStudent=& sqlcmd -S $Servidor -E -C -I -b -h -1 -W -d Bd_SistemaHorarios -Q "SET NOCOUNT ON; SELECT TOP(1) U.cNombreUsuario FROM App.Tbl_Estudiante E JOIN App.Tbl_Usuario U ON U.nIdUsuario=E.nIdUsuario JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdEstudiante=E.nIdEstudiante WHERE T.nSemestreActual=5 AND T.dFechaFin IS NULL ORDER BY E.nIdEstudiante;"
 if($LASTEXITCODE -ne 0){throw 'No fue posible consultar el usuario sintético de prueba.'}
 $taskPassword=New-TaskSecret
 $taskConnection=[System.Data.Common.DbConnectionStringBuilder]::new()
 $taskConnection['Server']=$Servidor;$taskConnection['Database']='Bd_SistemaHorarios';$taskConnection['User ID']='Usr_SistemaHorarios';$taskConnection['Password']=$taskPassword
 $taskConnection['Encrypt']='True';$taskConnection['TrustServerCertificate']='True';$taskConnection['Persist Security Info']='False';$taskConnection['Application Name']='SistemaHorarios.Runtime'
 $taskSecrets=[ordered]@{
  ConnectionStrings=@{SqlServer=$taskConnection.get_ConnectionString()}
  Jwt=@{Key=(New-TaskSecret 64)}
  DemoUsers=@(
   @{UserName=($taskStudent | Where-Object {$_ -match '^estudiante\.'} | Select-Object -First 1).Trim();Password=(New-TaskSecret)}
   @{UserName='docente.001';Password=(New-TaskSecret)}
   @{UserName='coordinador.demo';Password=(New-TaskSecret)}
  )
 }
 $taskSecrets | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $taskSecretPath -Encoding UTF8
}
$taskConnection=[System.Data.Common.DbConnectionStringBuilder]::new();$taskConnection.set_ConnectionString([string]$taskSecrets.ConnectionStrings.SqlServer)
$taskSqlPassword=[string]$taskConnection.get_Item('Password')
if($taskSqlPassword.Length -lt 24){throw 'El secreto runtime debe tener al menos 24 caracteres.'}
$taskSyncSql=if($SincronizarPasswordRuntime){"ALTER LOGIN [Usr_SistemaHorarios] WITH PASSWORD=N'"+$taskSqlPassword.Replace("'","''")+"';"}else{''}
# Los secretos van por stdin; nunca por argumentos SQLCMD ni por archivos versionados.
$taskSql=@"
SET NOCOUNT ON; SET XACT_ABORT ON;
USE [master];
IF CONVERT(int,SERVERPROPERTY('IsIntegratedSecurityOnly'))=1 THROW 52100,N'La instancia no permite login SQL. Configure una identidad runtime Windows aparte.',1;
IF SUSER_ID(N'Usr_SistemaHorarios') IS NULL
CREATE LOGIN [Usr_SistemaHorarios] WITH PASSWORD=N'$($taskSqlPassword.Replace("'","''"))',CHECK_POLICY=ON,CHECK_EXPIRATION=OFF,DEFAULT_DATABASE=[Bd_SistemaHorarios];
$taskSyncSql
IF IS_SRVROLEMEMBER('sysadmin','Usr_SistemaHorarios')<>0 THROW 52101,N'Runtime no puede ser sysadmin.',1;
USE [Bd_SistemaHorarios];
BEGIN TRANSACTION;
IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name='Usr_SistemaHorarios' AND authentication_type=0)
BEGIN
 IF EXISTS(SELECT 1 FROM sys.schemas WHERE principal_id=USER_ID('Usr_SistemaHorarios'))
 OR EXISTS(SELECT 1 FROM sys.objects WHERE principal_id=USER_ID('Usr_SistemaHorarios'))
 OR EXISTS(SELECT 1 FROM sys.database_principals WHERE owning_principal_id=USER_ID('Usr_SistemaHorarios'))
 OR EXISTS(SELECT 1 FROM sys.database_permissions WHERE grantee_principal_id=USER_ID('Usr_SistemaHorarios') AND NOT(class=0 AND permission_name='CONNECT' AND state='G'))
 OR EXISTS(SELECT 1 FROM sys.sql_modules WHERE execute_as_principal_id=USER_ID('Usr_SistemaHorarios'))
 THROW 52102,N'El usuario sin login posee objetos, permisos o dependencias; se requiere revisión explícita.',1;
 DROP USER [Usr_SistemaHorarios];
END;
IF USER_ID('Usr_SistemaHorarios') IS NULL CREATE USER [Usr_SistemaHorarios] FOR LOGIN [Usr_SistemaHorarios] WITH DEFAULT_SCHEMA=[App];
ELSE ALTER USER [Usr_SistemaHorarios] WITH LOGIN=[Usr_SistemaHorarios],DEFAULT_SCHEMA=[App];
IF IS_ROLEMEMBER('Rol_AppSistemaHorarios','Usr_SistemaHorarios')<>1 ALTER ROLE [Rol_AppSistemaHorarios] ADD MEMBER [Usr_SistemaHorarios];
COMMIT;
GO
"@
$taskSql | & sqlcmd -S $Servidor -E -C -I -b -d master -o (Join-Path $taskRoot '.secrets/provision.log')
if($LASTEXITCODE -ne 0){throw 'No se pudo provisionar el login runtime. Revise el log privado sin copiar secretos.'}
$env:SQLCMDPASSWORD=$taskSqlPassword
try{
 & sqlcmd -S $Servidor -U Usr_SistemaHorarios -C -I -b -W -d Bd_SistemaHorarios -Q "SET NOCOUNT ON; SELECT USER_NAME() AS cUsuario,IS_SRVROLEMEMBER('sysadmin') AS nSysadmin,IS_ROLEMEMBER('db_owner') AS nDbOwner,HAS_PERMS_BY_NAME('Aud','SCHEMA','SELECT') AS nAccesoAud;"
 if($LASTEXITCODE -ne 0){throw 'El login runtime no se pudo autenticar.'}
}finally{Remove-Item Env:SQLCMDPASSWORD -ErrorAction SilentlyContinue}
Write-Host 'Secretos locales preparados. Las contraseñas no se muestran ni se incluyen en Git.'
