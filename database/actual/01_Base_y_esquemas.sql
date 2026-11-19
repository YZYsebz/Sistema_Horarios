/* Schema-only export. No table rows, passwords, login hashes or physical server paths. */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO
USE [master];
GO
IF TRY_CONVERT(int,SERVERPROPERTY('ProductMajorVersion')) < 16
BEGIN
 RAISERROR(N'SQL Server 2022 or later is required.',16,1);
 SET NOEXEC ON;
END;
DECLARE @existing bit=0;
IF DB_ID(N'Bd_SistemaHorarios') IS NOT NULL
 EXEC sys.sp_executesql N'USE [Bd_SistemaHorarios]; SELECT @found=CASE WHEN EXISTS(SELECT 1 FROM sys.objects WHERE is_ms_shipped=0 AND schema_id IN(SCHEMA_ID(''App''),SCHEMA_ID(''Rep''),SCHEMA_ID(''Aud''))) THEN 1 ELSE 0 END;',N'@found bit OUTPUT',@found=@existing OUTPUT;
IF @existing=1
BEGIN
 RAISERROR(N'The database already contains application objects. No objects were replaced.',16,1);
 SET NOEXEC ON;
END;
GO
IF DB_ID(N'Bd_SistemaHorarios') IS NULL
 EXEC(N'CREATE DATABASE [Bd_SistemaHorarios] COLLATE Modern_Spanish_CI_AS');
GO
USE [Bd_SistemaHorarios];
GO
IF SCHEMA_ID(N'App') IS NULL EXEC(N'CREATE SCHEMA [App] AUTHORIZATION [dbo];');
GO
IF SCHEMA_ID(N'Aud') IS NULL EXEC(N'CREATE SCHEMA [Aud] AUTHORIZATION [dbo];');
GO
IF SCHEMA_ID(N'Rep') IS NULL EXEC(N'CREATE SCHEMA [Rep] AUTHORIZATION [dbo];');
GO
