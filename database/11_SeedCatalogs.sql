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
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF NOT EXISTS (SELECT 1 FROM App.Cat_Rol WHERE cNombreNormalizado=N'COORDINADOR') INSERT App.Cat_Rol(cNombre,cNombreNormalizado,cConcurrencyStamp) VALUES(N'COORDINADOR',N'COORDINADOR',CONVERT(nvarchar(36),NEWID()));
IF NOT EXISTS (SELECT 1 FROM App.Cat_Rol WHERE cNombreNormalizado=N'ESTUDIANTE') INSERT App.Cat_Rol(cNombre,cNombreNormalizado,cConcurrencyStamp) VALUES(N'ESTUDIANTE',N'ESTUDIANTE',CONVERT(nvarchar(36),NEWID()));
IF NOT EXISTS (SELECT 1 FROM App.Cat_Rol WHERE cNombreNormalizado=N'DOCENTE') INSERT App.Cat_Rol(cNombre,cNombreNormalizado,cConcurrencyStamp) VALUES(N'DOCENTE',N'DOCENTE',CONVERT(nvarchar(36),NEWID()));
IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=1) INSERT App.Cat_DiaSemana(nIdDiaSemana,cNombre) VALUES(1,N'Lunes');
IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=2) INSERT App.Cat_DiaSemana(nIdDiaSemana,cNombre) VALUES(2,N'Martes');
IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=3) INSERT App.Cat_DiaSemana(nIdDiaSemana,cNombre) VALUES(3,N'Miércoles');
IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=4) INSERT App.Cat_DiaSemana(nIdDiaSemana,cNombre) VALUES(4,N'Jueves');
IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=5) INSERT App.Cat_DiaSemana(nIdDiaSemana,cNombre) VALUES(5,N'Viernes');
IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=6) INSERT App.Cat_DiaSemana(nIdDiaSemana,cNombre) VALUES(6,N'Sábado');
IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=7) INSERT App.Cat_DiaSemana(nIdDiaSemana,cNombre) VALUES(7,N'Domingo');
IF NOT EXISTS (SELECT 1 FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA') INSERT App.Cat_EstatusAcademico(nIdEstatusAcademico,cClave,cNombre) VALUES(1,'APROBADA',N'Aprobada');
IF NOT EXISTS (SELECT 1 FROM App.Cat_EstatusAcademico WHERE cClave='NO_APROBADA') INSERT App.Cat_EstatusAcademico(nIdEstatusAcademico,cClave,cNombre) VALUES(2,'NO_APROBADA',N'No aprobada');
IF NOT EXISTS (SELECT 1 FROM App.Cat_EstatusAcademico WHERE cClave='CURSANDO') INSERT App.Cat_EstatusAcademico(nIdEstatusAcademico,cClave,cNombre) VALUES(3,'CURSANDO',N'Cursando');
IF NOT EXISTS (SELECT 1 FROM App.Cat_EstatusAcademico WHERE cClave='PENDIENTE') INSERT App.Cat_EstatusAcademico(nIdEstatusAcademico,cClave,cNombre) VALUES(4,'PENDIENTE',N'Pendiente');
IF NOT EXISTS (SELECT 1 FROM App.Cat_TipoAula WHERE cClave='AULA') INSERT App.Cat_TipoAula(cClave,cNombre) VALUES('AULA',N'Aula normal');
IF NOT EXISTS (SELECT 1 FROM App.Cat_TipoAula WHERE cClave='LABORATORIO') INSERT App.Cat_TipoAula(cClave,cNombre) VALUES('LABORATORIO',N'Laboratorio');
IF NOT EXISTS (SELECT 1 FROM App.Cat_TipoAula WHERE cClave='COMPUTO') INSERT App.Cat_TipoAula(cClave,cNombre) VALUES('COMPUTO',N'Laboratorio de cómputo');
IF NOT EXISTS (SELECT 1 FROM App.Cat_TipoAula WHERE cClave='OTRO') INSERT App.Cat_TipoAula(cClave,cNombre) VALUES('OTRO',N'Otro');
COMMIT TRANSACTION;
GO
