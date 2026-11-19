SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_WARNINGS ON;
SET ANSI_PADDING ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO
USE [Bd_SistemaHorarios];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
/* Cambio acotado exigido por los nuevos requisitos. No reconstruye la base.
Se aborta si hay estudiantes que requieren depuración; nunca se truncan números existentes. */
BEGIN TRY
 BEGIN TRANSACTION;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS(SELECT 1 FROM App.Tbl_Estudiante WHERE LEN(cNumeroControl)<>8 OR cNumeroControl COLLATE Latin1_General_100_BIN2 LIKE '%[^0-9]%')
  THROW 52000,N'Existen números de control incompatibles; depure sin truncar antes de migrar.',1;
 IF COL_LENGTH('App.Tbl_Estudiante','cNombre') IS NULL EXEC(N'ALTER TABLE App.Tbl_Estudiante ADD cNombre nvarchar(150) NULL;');
 IF COL_LENGTH('App.Tbl_Estudiante','nAnioIngreso') IS NULL EXEC(N'ALTER TABLE App.Tbl_Estudiante ADD nAnioIngreso smallint NULL;');
 IF COL_LENGTH('App.Tbl_Estudiante','nGeneracion') IS NULL EXEC(N'ALTER TABLE App.Tbl_Estudiante ADD nGeneracion tinyint NULL;');
 EXEC(N'IF EXISTS(SELECT 1 FROM App.Tbl_Estudiante WHERE cNombre IS NULL OR nAnioIngreso IS NULL OR nGeneracion IS NULL)
 THROW 52001,N''Complete nombre, año y generación de estudiantes existentes antes de migrar.'',1;');
 IF EXISTS(SELECT 1 FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID('App.Tbl_Estudiante') AND name='UQ_Tbl_Estudiante_cNumeroControl')
 ALTER TABLE App.Tbl_Estudiante DROP CONSTRAINT UQ_Tbl_Estudiante_cNumeroControl;
 IF EXISTS(SELECT 1 FROM sys.check_constraints WHERE name='CK_Tbl_Estudiante_cNumeroControl_NoVacio')
 ALTER TABLE App.Tbl_Estudiante DROP CONSTRAINT CK_Tbl_Estudiante_cNumeroControl_NoVacio;
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE name='CK_Tbl_Estudiante_NumeroControl8')
 BEGIN
  ALTER TABLE App.Tbl_Estudiante ALTER COLUMN cNumeroControl char(8) NOT NULL;
  ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT CK_Tbl_Estudiante_NumeroControl8 CHECK(LEN(cNumeroControl)=8 AND cNumeroControl COLLATE Latin1_General_100_BIN2 NOT LIKE '%[^0-9]%');
 END;
 ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT UQ_Tbl_Estudiante_cNumeroControl UNIQUE(cNumeroControl);
 EXEC(N'ALTER TABLE App.Tbl_Estudiante ALTER COLUMN cNombre nvarchar(150) NOT NULL;
 ALTER TABLE App.Tbl_Estudiante ALTER COLUMN nAnioIngreso smallint NOT NULL;
 ALTER TABLE App.Tbl_Estudiante ALTER COLUMN nGeneracion tinyint NOT NULL;');
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE name='CK_Tbl_Estudiante_IngresoGeneracion')
 EXEC(N'ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT CK_Tbl_Estudiante_IngresoGeneracion CHECK
 (nAnioIngreso BETWEEN 1950 AND 2100 AND nGeneracion BETWEEN 0 AND 99 AND LEN(LTRIM(RTRIM(cNombre)))>0
 AND LEFT(cNumeroControl,2)=RIGHT(CONVERT(varchar(4),nAnioIngreso),2)
 AND SUBSTRING(cNumeroControl,3,2)=RIGHT(''00''+CONVERT(varchar(2),nGeneracion),2));');
 COMMIT;
END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
GO
