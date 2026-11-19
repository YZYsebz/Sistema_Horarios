/* Schema-only export. No table rows, passwords, login hashes or physical server paths. */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO
USE [Bd_SistemaHorarios];
GO
/* Principal preparado sin credenciales; vincular cuenta Windows con el script separado. */
IF DATABASE_PRINCIPAL_ID(N'Rol_AppSistemaHorarios') IS NULL CREATE ROLE [Rol_AppSistemaHorarios] AUTHORIZATION [dbo];
IF DATABASE_PRINCIPAL_ID(N'Usr_SistemaHorarios') IS NULL CREATE USER [Usr_SistemaHorarios] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[App];
IF IS_ROLEMEMBER(N'Rol_AppSistemaHorarios',N'Usr_SistemaHorarios')<>1 ALTER ROLE [Rol_AppSistemaHorarios] ADD MEMBER [Usr_SistemaHorarios];
GRANT SELECT,INSERT,UPDATE,DELETE,EXECUTE ON SCHEMA::[App] TO [Rol_AppSistemaHorarios];
GRANT SELECT ON SCHEMA::[Rep] TO [Rol_AppSistemaHorarios];
REVOKE CONTROL ON SCHEMA::[Rep] FROM [Rol_AppSistemaHorarios];
DENY INSERT,UPDATE,DELETE,ALTER ON SCHEMA::[Rep] TO [Rol_AppSistemaHorarios];
DENY SELECT,INSERT,UPDATE,DELETE,EXECUTE,ALTER,CONTROL,VIEW DEFINITION ON SCHEMA::[Aud] TO [Rol_AppSistemaHorarios];
GO

GRANT REFERENCES ON TYPE::[App].[Tbl_ListaGrupo] TO [Rol_AppSistemaHorarios];
GO
SET NOEXEC OFF;
GO
