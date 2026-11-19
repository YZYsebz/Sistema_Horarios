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
/* Objeto: Aud.Tbl_Auditoria. Bitácora administrativa; sin payload sensible. */
IF OBJECT_ID(N'Aud.Tbl_Auditoria',N'U') IS NULL
BEGIN
CREATE TABLE Aud.Tbl_Auditoria (
 [nIdAuditoria] bigint IDENTITY(1,1) NOT NULL,
 [nIdUsuario] int NULL,
 [cLoginOriginal] nvarchar(128) NOT NULL,
 [cOperacion] varchar(30) NOT NULL,
 [cEsquema] varchar(3) NOT NULL,
 [cObjeto] nvarchar(128) NOT NULL,
 [nIdRegistroAfectado] bigint NULL,
 [dFechaRegistro] datetime2(0) NOT NULL,
 [cDatosAdicionales] nvarchar(1000) NULL
);
END;
GO
/* PK_Tbl_Auditoria */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'Aud.Tbl_Auditoria') AND name=N'PK_Tbl_Auditoria')
 ALTER TABLE Aud.Tbl_Auditoria ADD CONSTRAINT [PK_Tbl_Auditoria] PRIMARY KEY (nIdAuditoria);
GO
/* DF_Tbl_Auditoria_dFechaRegistro */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'Aud.Tbl_Auditoria') AND name=N'DF_Tbl_Auditoria_dFechaRegistro')
 ALTER TABLE Aud.Tbl_Auditoria ADD CONSTRAINT [DF_Tbl_Auditoria_dFechaRegistro] DEFAULT (SYSUTCDATETIME()) FOR dFechaRegistro;
GO
/* FK_Tbl_Auditoria_Tbl_Usuario */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'Aud.Tbl_Auditoria') AND name=N'FK_Tbl_Auditoria_Tbl_Usuario')
 ALTER TABLE Aud.Tbl_Auditoria ADD CONSTRAINT [FK_Tbl_Auditoria_Tbl_Usuario] FOREIGN KEY (nIdUsuario) REFERENCES App.Tbl_Usuario (nIdUsuario);
GO
/* DF_Tbl_Auditoria_cLoginOriginal */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'Aud.Tbl_Auditoria') AND name=N'DF_Tbl_Auditoria_cLoginOriginal')
 ALTER TABLE Aud.Tbl_Auditoria ADD CONSTRAINT [DF_Tbl_Auditoria_cLoginOriginal] DEFAULT (ORIGINAL_LOGIN()) FOR cLoginOriginal;
GO
/* CK_Tbl_Auditoria_Esquema */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'Aud.Tbl_Auditoria') AND name=N'CK_Tbl_Auditoria_Esquema')
 ALTER TABLE Aud.Tbl_Auditoria ADD CONSTRAINT [CK_Tbl_Auditoria_Esquema] CHECK (cEsquema IN ('App','Rep','Aud'));
GO
/* Bitácora por intervalo UTC; PK por evento. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'Aud.Tbl_Auditoria') AND name=N'IX_Tbl_Auditoria_Fecha')
 CREATE INDEX [IX_Tbl_Auditoria_Fecha] ON Aud.Tbl_Auditoria (dFechaRegistro) INCLUDE (cOperacion,cObjeto);
GO

/* Supervisión DBA de eventos; runtime no tiene SELECT. */
CREATE OR ALTER VIEW Aud.Vi_ActividadBD AS
SELECT nIdAuditoria,nIdUsuario,cLoginOriginal,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado,dFechaRegistro,cDatosAdicionales
FROM Aud.Tbl_Auditoria;
GO
/* Solo administradores autorizados. No registra payload de credenciales. */
CREATE OR ALTER PROCEDURE Aud.Sp_RegistrarAuditoria
 @cOperacion varchar(30),@cEsquema varchar(3),@cObjeto nvarchar(128),@nIdRegistroAfectado bigint=NULL,
 @nIdUsuario int=NULL,@cDatosAdicionales nvarchar(1000)=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @cOperacion IS NULL OR LEN(LTRIM(RTRIM(@cOperacion)))=0 THROW 51400,N'Operación de auditoría requerida.',1;
 INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado,cDatosAdicionales)
 VALUES(@nIdUsuario,@cOperacion,@cEsquema,@cObjeto,@nIdRegistroAfectado,@cDatosAdicionales);
END;
GO
