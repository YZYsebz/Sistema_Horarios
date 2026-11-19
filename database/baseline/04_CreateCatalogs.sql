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
/* Objeto: App.Cat_Rol. Roles de Identity; múltiples roles por usuario. */
IF OBJECT_ID(N'App.Cat_Rol',N'U') IS NULL
BEGIN
CREATE TABLE App.Cat_Rol (
 [nIdRol] int IDENTITY(1,1) NOT NULL,
 [cNombre] nvarchar(256) NOT NULL,
 [cNombreNormalizado] nvarchar(256) NOT NULL,
 [cConcurrencyStamp] nvarchar(64) NULL
);
END;
GO
/* Objeto: App.Cat_Carrera. Maestro de carrera */
IF OBJECT_ID(N'App.Cat_Carrera',N'U') IS NULL
BEGIN
CREATE TABLE App.Cat_Carrera (
 [nIdCarrera] int IDENTITY(1,1) NOT NULL,
 [cClave] varchar(30) NOT NULL,
 [cNombre] nvarchar(150) NOT NULL,
 [nEstatus] bit NOT NULL
);
END;
GO
/* Objeto: App.Cat_Materia. Maestro de materia */
IF OBJECT_ID(N'App.Cat_Materia',N'U') IS NULL
BEGIN
CREATE TABLE App.Cat_Materia (
 [nIdMateria] int IDENTITY(1,1) NOT NULL,
 [cClave] varchar(30) NOT NULL,
 [cNombre] nvarchar(150) NOT NULL,
 [nEstatus] bit NOT NULL
);
END;
GO
/* Objeto: App.Cat_TipoAula. Maestro de tipoaula */
IF OBJECT_ID(N'App.Cat_TipoAula',N'U') IS NULL
BEGIN
CREATE TABLE App.Cat_TipoAula (
 [nIdTipoAula] int IDENTITY(1,1) NOT NULL,
 [cClave] varchar(30) NOT NULL,
 [cNombre] nvarchar(150) NOT NULL,
 [nEstatus] bit NOT NULL
);
END;
GO
/* Objeto: App.Cat_Reticula. Versión de plan de estudios de una carrera. */
IF OBJECT_ID(N'App.Cat_Reticula',N'U') IS NULL
BEGIN
CREATE TABLE App.Cat_Reticula (
 [nIdReticula] int IDENTITY(1,1) NOT NULL,
 [nIdCarrera] int NOT NULL,
 [cClave] varchar(30) NOT NULL,
 [cNombre] nvarchar(150) NOT NULL,
 [nEstatus] bit NOT NULL
);
END;
GO
/* Objeto: App.Cat_DiaSemana. Dominio ISO fijo: lunes 1 a domingo 7. */
IF OBJECT_ID(N'App.Cat_DiaSemana',N'U') IS NULL
BEGIN
CREATE TABLE App.Cat_DiaSemana (
 [nIdDiaSemana] tinyint NOT NULL,
 [cNombre] nvarchar(15) NOT NULL
);
END;
GO
/* Objeto: App.Cat_EstatusAcademico. Estados controlados del intento académico. */
IF OBJECT_ID(N'App.Cat_EstatusAcademico',N'U') IS NULL
BEGIN
CREATE TABLE App.Cat_EstatusAcademico (
 [nIdEstatusAcademico] tinyint NOT NULL,
 [cClave] varchar(15) NOT NULL,
 [cNombre] nvarchar(50) NOT NULL
);
END;
GO
