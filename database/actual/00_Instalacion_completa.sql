/* Schema-only export. No table rows, passwords, login hashes or physical server paths. */
/* SOURCE: 01_Base_y_esquemas.sql */
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

/* SOURCE: 02_Tipos_tabla.sql */
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
CREATE TYPE [App].[Tbl_ListaGrupo] AS TABLE (
    [nIdGrupo] [int] NOT NULL,
    PRIMARY KEY CLUSTERED ([nIdGrupo] ASC)
);
GO

/* SOURCE: 03_Tablas_y_restricciones.sql */
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
CREATE TABLE [App].[Cat_Carrera] (
    [nIdCarrera] [int] IDENTITY(1,1) NOT NULL,
    [cClave] [varchar](30) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombre] [nvarchar](150) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nEstatus] [bit] NOT NULL CONSTRAINT [DF_Cat_Carrera_nEstatus] DEFAULT ((1)),
    CONSTRAINT [CK_Cat_Carrera_cClave_NoVacio] CHECK (len(ltrim(rtrim([cClave])))>(0)),
    CONSTRAINT [CK_Cat_Carrera_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [PK_Cat_Carrera] PRIMARY KEY CLUSTERED ([nIdCarrera] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Cat_Carrera_cClave] UNIQUE NONCLUSTERED ([cClave] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Cat_DiaSemana] (
    [nIdDiaSemana] [tinyint] NOT NULL,
    [cNombre] [nvarchar](15) COLLATE Modern_Spanish_CI_AS NOT NULL,
    CONSTRAINT [CK_Cat_DiaSemana_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [CK_Cat_DiaSemana_Dominio] CHECK ([nIdDiaSemana]>=(1) AND [nIdDiaSemana]<=(7)),
    CONSTRAINT [PK_Cat_DiaSemana] PRIMARY KEY CLUSTERED ([nIdDiaSemana] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Cat_DiaSemana_cNombre] UNIQUE NONCLUSTERED ([cNombre] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Cat_EstatusAcademico] (
    [nIdEstatusAcademico] [tinyint] NOT NULL,
    [cClave] [varchar](15) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombre] [nvarchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
    CONSTRAINT [CK_Cat_EstatusAcademico_cClave_NoVacio] CHECK (len(ltrim(rtrim([cClave])))>(0)),
    CONSTRAINT [CK_Cat_EstatusAcademico_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [CK_Cat_EstatusAcademico_Dominio] CHECK ([cClave]='PENDIENTE' OR [cClave]='CURSANDO' OR [cClave]='NO_APROBADA' OR [cClave]='APROBADA'),
    CONSTRAINT [PK_Cat_EstatusAcademico] PRIMARY KEY CLUSTERED ([nIdEstatusAcademico] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Cat_EstatusAcademico_cClave] UNIQUE NONCLUSTERED ([cClave] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Cat_Materia] (
    [nIdMateria] [int] IDENTITY(1,1) NOT NULL,
    [cClave] [varchar](30) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombre] [nvarchar](150) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nEstatus] [bit] NOT NULL CONSTRAINT [DF_Cat_Materia_nEstatus] DEFAULT ((1)),
    CONSTRAINT [CK_Cat_Materia_cClave_NoVacio] CHECK (len(ltrim(rtrim([cClave])))>(0)),
    CONSTRAINT [CK_Cat_Materia_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [PK_Cat_Materia] PRIMARY KEY CLUSTERED ([nIdMateria] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Cat_Materia_cClave] UNIQUE NONCLUSTERED ([cClave] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Cat_Reticula] (
    [nIdReticula] [int] IDENTITY(1,1) NOT NULL,
    [nIdCarrera] [int] NOT NULL,
    [cClave] [varchar](30) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombre] [nvarchar](150) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nEstatus] [bit] NOT NULL CONSTRAINT [DF_Cat_Reticula_nEstatus] DEFAULT ((1)),
    CONSTRAINT [CK_Cat_Reticula_cClave_NoVacio] CHECK (len(ltrim(rtrim([cClave])))>(0)),
    CONSTRAINT [CK_Cat_Reticula_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [PK_Cat_Reticula] PRIMARY KEY CLUSTERED ([nIdReticula] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Cat_Reticula_cClave] UNIQUE NONCLUSTERED ([cClave] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Cat_Rol] (
    [nIdRol] [int] IDENTITY(1,1) NOT NULL,
    [cNombre] [nvarchar](256) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombreNormalizado] [nvarchar](256) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cConcurrencyStamp] [nvarchar](64) COLLATE Modern_Spanish_CI_AS NULL,
    CONSTRAINT [CK_Cat_Rol_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [PK_Cat_Rol] PRIMARY KEY CLUSTERED ([nIdRol] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Cat_Rol_cNombreNormalizado] UNIQUE NONCLUSTERED ([cNombreNormalizado] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Cat_TipoAula] (
    [nIdTipoAula] [int] IDENTITY(1,1) NOT NULL,
    [cClave] [varchar](30) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombre] [nvarchar](150) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nEstatus] [bit] NOT NULL CONSTRAINT [DF_Cat_TipoAula_nEstatus] DEFAULT ((1)),
    CONSTRAINT [CK_Cat_TipoAula_cClave_NoVacio] CHECK (len(ltrim(rtrim([cClave])))>(0)),
    CONSTRAINT [CK_Cat_TipoAula_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [PK_Cat_TipoAula] PRIMARY KEY CLUSTERED ([nIdTipoAula] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Cat_TipoAula_cClave] UNIQUE NONCLUSTERED ([cClave] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_Aula] (
    [nIdAula] [int] IDENTITY(1,1) NOT NULL,
    [nIdTipoAula] [int] NOT NULL,
    [cClave] [varchar](30) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nCapacidad] [smallint] NOT NULL,
    [nEstatus] [bit] NOT NULL CONSTRAINT [DF_Tbl_Aula_nEstatus] DEFAULT ((1)),
    CONSTRAINT [CK_Tbl_Aula_Capacidad] CHECK ([nCapacidad]>(0)),
    CONSTRAINT [CK_Tbl_Aula_cClave_NoVacio] CHECK (len(ltrim(rtrim([cClave])))>(0)),
    CONSTRAINT [PK_Tbl_Aula] PRIMARY KEY CLUSTERED ([nIdAula] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Tbl_Aula_cClave] UNIQUE NONCLUSTERED ([cClave] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_Docente] (
    [nIdDocente] [int] IDENTITY(1,1) NOT NULL,
    [nIdUsuario] [int] NULL,
    [cNumeroEmpleado] [varchar](25) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombre] [nvarchar](150) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nEstatus] [bit] NOT NULL CONSTRAINT [DF_Tbl_Docente_nEstatus] DEFAULT ((1)),
    CONSTRAINT [CK_Tbl_Docente_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [CK_Tbl_Docente_cNumeroEmpleado_NoVacio] CHECK (len(ltrim(rtrim([cNumeroEmpleado])))>(0)),
    CONSTRAINT [PK_Tbl_Docente] PRIMARY KEY CLUSTERED ([nIdDocente] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Tbl_Docente_cNumeroEmpleado] UNIQUE NONCLUSTERED ([cNumeroEmpleado] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_Estudiante] (
    [nIdEstudiante] [int] IDENTITY(1,1) NOT NULL,
    [nIdUsuario] [int] NOT NULL,
    [cNumeroControl] [char](8) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nEstatus] [bit] NOT NULL CONSTRAINT [DF_Tbl_Estudiante_nEstatus] DEFAULT ((1)),
    [cNombre] [nvarchar](150) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nAnioIngreso] [smallint] NOT NULL,
    [nGeneracion] [tinyint] NOT NULL,
    CONSTRAINT [CK_Tbl_Estudiante_IngresoGeneracion] CHECK ([nAnioIngreso]>=(1950) AND [nAnioIngreso]<=(2100) AND ([nGeneracion]>=(0) AND [nGeneracion]<=(99)) AND len(ltrim(rtrim([cNombre])))>(0) AND left([cNumeroControl],(2))=right(CONVERT([varchar](4),[nAnioIngreso]),(2)) AND substring([cNumeroControl],(3),(2))=right('00'+CONVERT([varchar](2),[nGeneracion]),(2))),
    CONSTRAINT [CK_Tbl_Estudiante_NumeroControl8] CHECK (len([cNumeroControl])=(8) AND NOT ([cNumeroControl]) collate Latin1_General_100_BIN2 like '%[^0-9]%'),
    CONSTRAINT [PK_Tbl_Estudiante] PRIMARY KEY CLUSTERED ([nIdEstudiante] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Tbl_Estudiante_nIdUsuario] UNIQUE NONCLUSTERED ([nIdUsuario] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Tbl_Estudiante_cNumeroControl] UNIQUE NONCLUSTERED ([cNumeroControl] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_Grupo] (
    [nIdGrupo] [int] IDENTITY(1,1) NOT NULL,
    [nIdMateria] [int] NOT NULL,
    [nIdDocente] [int] NULL,
    [nIdPeriodo] [int] NOT NULL,
    [cClaveGrupo] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nEstatus] [bit] NOT NULL CONSTRAINT [DF_Tbl_Grupo_nEstatus] DEFAULT ((1)),
    CONSTRAINT [CK_Tbl_Grupo_cClaveGrupo_NoVacio] CHECK (len(ltrim(rtrim([cClaveGrupo])))>(0)),
    CONSTRAINT [PK_Tbl_Grupo] PRIMARY KEY CLUSTERED ([nIdGrupo] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Tbl_Grupo_nIdPeriodo_nIdMateria_cClaveGrupo] UNIQUE NONCLUSTERED ([nIdPeriodo] ASC, [nIdMateria] ASC, [cClaveGrupo] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_HistorialAcademico] (
    [nIdHistorialAcademico] [bigint] IDENTITY(1,1) NOT NULL,
    [nIdEstudiante] [int] NOT NULL,
    [nIdMateria] [int] NOT NULL,
    [nIdPeriodo] [int] NULL,
    [nIdEstatusAcademico] [tinyint] NOT NULL,
    [nCalificacion] [decimal](5,2) NULL,
    [dFechaRegistro] [datetime2](0) NOT NULL CONSTRAINT [DF_Tbl_HistorialAcademico_dFechaRegistro] DEFAULT (sysutcdatetime()),
    CONSTRAINT [CK_Tbl_HistorialAcademico_Calificacion] CHECK ([nCalificacion] IS NULL OR [nCalificacion]>=(0) AND [nCalificacion]<=(100)),
    CONSTRAINT [PK_Tbl_HistorialAcademico] PRIMARY KEY CLUSTERED ([nIdHistorialAcademico] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Tbl_HistorialAcademico_nIdEstudiante_nIdMateria_nIdPeriodo] UNIQUE NONCLUSTERED ([nIdEstudiante] ASC, [nIdMateria] ASC, [nIdPeriodo] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_HorarioGenerado] (
    [nIdHorarioGenerado] [int] IDENTITY(1,1) NOT NULL,
    [nIdTrayectoria] [int] NOT NULL,
    [nIdPeriodo] [int] NOT NULL,
    [cNombre] [nvarchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nConfirmado] [bit] NOT NULL CONSTRAINT [DF_Tbl_HorarioGenerado_nConfirmado] DEFAULT ((0)),
    [nSeleccionado] [bit] NOT NULL CONSTRAINT [DF_Tbl_HorarioGenerado_nSeleccionado] DEFAULT ((0)),
    [dFechaRegistro] [datetime2](0) NOT NULL CONSTRAINT [DF_Tbl_HorarioGenerado_dFechaRegistro] DEFAULT (sysutcdatetime()),
    CONSTRAINT [CK_Tbl_HorarioGenerado_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [CK_Tbl_HorarioGenerado_SeleccionConfirmada] CHECK ([nSeleccionado]=(0) OR [nConfirmado]=(1)),
    CONSTRAINT [PK_Tbl_HorarioGenerado] PRIMARY KEY CLUSTERED ([nIdHorarioGenerado] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_HorarioGeneradoDetalle] (
    [nIdHorarioGenerado] [int] NOT NULL,
    [nIdGrupo] [int] NOT NULL,
    CONSTRAINT [PK_Tbl_HorarioGeneradoDetalle] PRIMARY KEY CLUSTERED ([nIdHorarioGenerado] ASC, [nIdGrupo] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_MateriaPrerrequisito] (
    [nIdReticula] [int] NOT NULL,
    [nIdMateria] [int] NOT NULL,
    [nIdMateriaPrerrequisito] [int] NOT NULL,
    [nObligatorio] [bit] NOT NULL CONSTRAINT [DF_Tbl_MateriaPrerrequisito_nObligatorio] DEFAULT ((1)),
    CONSTRAINT [CK_Tbl_MateriaPrerrequisito_NoAutorreferencia] CHECK ([nIdMateria]<>[nIdMateriaPrerrequisito]),
    CONSTRAINT [PK_Tbl_MateriaPrerrequisito] PRIMARY KEY CLUSTERED ([nIdReticula] ASC, [nIdMateria] ASC, [nIdMateriaPrerrequisito] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_PeriodoAcademico] (
    [nIdPeriodo] [int] IDENTITY(1,1) NOT NULL,
    [cClave] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombre] [nvarchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [dFechaInicio] [date] NOT NULL,
    [dFechaFin] [date] NOT NULL,
    [nActivoGeneracion] [bit] NOT NULL CONSTRAINT [DF_Tbl_PeriodoAcademico_nActivoGeneracion] DEFAULT ((0)),
    [nOfertaPublicada] [bit] NOT NULL CONSTRAINT [DF_Tbl_PeriodoAcademico_nOfertaPublicada] DEFAULT ((0)),
    CONSTRAINT [CK_Tbl_PeriodoAcademico_cClave_NoVacio] CHECK (len(ltrim(rtrim([cClave])))>(0)),
    CONSTRAINT [CK_Tbl_PeriodoAcademico_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [CK_Tbl_PeriodoAcademico_Fechas] CHECK ([dFechaInicio]<[dFechaFin]),
    CONSTRAINT [PK_Tbl_PeriodoAcademico] PRIMARY KEY CLUSTERED ([nIdPeriodo] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Tbl_PeriodoAcademico_cClave] UNIQUE NONCLUSTERED ([cClave] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_ReticulaMateria] (
    [nIdReticula] [int] NOT NULL,
    [nIdMateria] [int] NOT NULL,
    [nSemestreRecomendado] [tinyint] NOT NULL,
    [nCreditos] [tinyint] NOT NULL,
    [nObligatoria] [bit] NOT NULL CONSTRAINT [DF_Tbl_ReticulaMateria_nObligatoria] DEFAULT ((1)),
    CONSTRAINT [CK_Tbl_ReticulaMateria_Creditos] CHECK ([nCreditos]>=(1) AND [nCreditos]<=(100)),
    CONSTRAINT [CK_Tbl_ReticulaMateria_Semestre] CHECK ([nSemestreRecomendado]>=(1) AND [nSemestreRecomendado]<=(30)),
    CONSTRAINT [PK_Tbl_ReticulaMateria] PRIMARY KEY CLUSTERED ([nIdReticula] ASC, [nIdMateria] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_RolClaim] (
    [nIdRolClaim] [int] IDENTITY(1,1) NOT NULL,
    [nIdRol] [int] NOT NULL,
    [cTipoClaim] [nvarchar](max) COLLATE Modern_Spanish_CI_AS NULL,
    [cValorClaim] [nvarchar](max) COLLATE Modern_Spanish_CI_AS NULL,
    CONSTRAINT [PK_Tbl_RolClaim] PRIMARY KEY CLUSTERED ([nIdRolClaim] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_SesionGrupo] (
    [nIdSesionGrupo] [int] IDENTITY(1,1) NOT NULL,
    [nIdGrupo] [int] NOT NULL,
    [nIdDiaSemana] [tinyint] NOT NULL,
    [nIdAula] [int] NOT NULL,
    [dHoraInicio] [time](0) NOT NULL,
    [dHoraFin] [time](0) NOT NULL,
    CONSTRAINT [CK_Tbl_SesionGrupo_Horas] CHECK ([dHoraInicio]<[dHoraFin]),
    CONSTRAINT [PK_Tbl_SesionGrupo] PRIMARY KEY CLUSTERED ([nIdSesionGrupo] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Tbl_SesionGrupo_nIdGrupo_nIdDiaSemana_dHoraInicio_dHoraFin_nIdAula] UNIQUE NONCLUSTERED ([nIdGrupo] ASC, [nIdDiaSemana] ASC, [dHoraInicio] ASC, [dHoraFin] ASC, [nIdAula] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_TrayectoriaEstudiante] (
    [nIdTrayectoria] [int] IDENTITY(1,1) NOT NULL,
    [nIdEstudiante] [int] NOT NULL,
    [nIdReticula] [int] NOT NULL,
    [nSemestreActual] [tinyint] NOT NULL,
    [nLimiteCreditos] [smallint] NOT NULL,
    [dFechaInicio] [date] NOT NULL,
    [dFechaFin] [date] NULL,
    CONSTRAINT [CK_Tbl_TrayectoriaEstudiante_Creditos] CHECK ([nLimiteCreditos]>(0)),
    CONSTRAINT [CK_Tbl_TrayectoriaEstudiante_Fechas] CHECK ([dFechaFin] IS NULL OR [dFechaFin]>=[dFechaInicio]),
    CONSTRAINT [CK_Tbl_TrayectoriaEstudiante_Semestre] CHECK ([nSemestreActual]>=(1) AND [nSemestreActual]<=(30)),
    CONSTRAINT [PK_Tbl_TrayectoriaEstudiante] PRIMARY KEY CLUSTERED ([nIdTrayectoria] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_Usuario] (
    [nIdUsuario] [int] IDENTITY(1,1) NOT NULL,
    [cNombreUsuario] [nvarchar](256) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombreUsuarioNormalizado] [nvarchar](256) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cCorreo] [nvarchar](256) COLLATE Modern_Spanish_CI_AS NULL,
    [cCorreoNormalizado] [nvarchar](256) COLLATE Modern_Spanish_CI_AS NULL,
    [nCorreoConfirmado] [bit] NOT NULL CONSTRAINT [DF_Tbl_Usuario_nCorreoConfirmado] DEFAULT ((0)),
    [cPasswordHash] [nvarchar](max) COLLATE Modern_Spanish_CI_AS NULL,
    [cSecurityStamp] [nvarchar](64) COLLATE Modern_Spanish_CI_AS NULL,
    [cConcurrencyStamp] [nvarchar](64) COLLATE Modern_Spanish_CI_AS NULL,
    [cTelefono] [nvarchar](50) COLLATE Modern_Spanish_CI_AS NULL,
    [nTelefonoConfirmado] [bit] NOT NULL CONSTRAINT [DF_Tbl_Usuario_nTelefonoConfirmado] DEFAULT ((0)),
    [nDosFactoresHabilitados] [bit] NOT NULL CONSTRAINT [DF_Tbl_Usuario_nDosFactoresHabilitados] DEFAULT ((0)),
    [dFinBloqueo] [datetimeoffset](0) NULL,
    [nBloqueoHabilitado] [bit] NOT NULL CONSTRAINT [DF_Tbl_Usuario_nBloqueoHabilitado] DEFAULT ((0)),
    [nIntentosFallidos] [int] NOT NULL CONSTRAINT [DF_Tbl_Usuario_nIntentosFallidos] DEFAULT ((0)),
    [nEstatus] [bit] NOT NULL CONSTRAINT [DF_Tbl_Usuario_nEstatus] DEFAULT ((1)),
    [dFechaRegistro] [datetime2](0) NOT NULL CONSTRAINT [DF_Tbl_Usuario_dFechaRegistro] DEFAULT (sysutcdatetime()),
    CONSTRAINT [CK_Tbl_Usuario_cNombreUsuario_NoVacio] CHECK (len(ltrim(rtrim([cNombreUsuario])))>(0)),
    CONSTRAINT [CK_Tbl_Usuario_cNombreUsuarioNormalizado_NoVacio] CHECK (len(ltrim(rtrim([cNombreUsuarioNormalizado])))>(0)),
    CONSTRAINT [CK_Tbl_Usuario_Intentos] CHECK ([nIntentosFallidos]>=(0)),
    CONSTRAINT [PK_Tbl_Usuario] PRIMARY KEY CLUSTERED ([nIdUsuario] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    CONSTRAINT [UQ_Tbl_Usuario_cNombreUsuarioNormalizado] UNIQUE NONCLUSTERED ([cNombreUsuarioNormalizado] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_UsuarioClaim] (
    [nIdUsuarioClaim] [int] IDENTITY(1,1) NOT NULL,
    [nIdUsuario] [int] NOT NULL,
    [cTipoClaim] [nvarchar](max) COLLATE Modern_Spanish_CI_AS NULL,
    [cValorClaim] [nvarchar](max) COLLATE Modern_Spanish_CI_AS NULL,
    CONSTRAINT [PK_Tbl_UsuarioClaim] PRIMARY KEY CLUSTERED ([nIdUsuarioClaim] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_UsuarioLogin] (
    [cProveedorLogin] [nvarchar](128) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cClaveProveedor] [nvarchar](128) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombreProveedor] [nvarchar](128) COLLATE Modern_Spanish_CI_AS NULL,
    [nIdUsuario] [int] NOT NULL,
    CONSTRAINT [PK_Tbl_UsuarioLogin] PRIMARY KEY CLUSTERED ([cProveedorLogin] ASC, [cClaveProveedor] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_UsuarioRol] (
    [nIdUsuario] [int] NOT NULL,
    [nIdRol] [int] NOT NULL,
    CONSTRAINT [PK_Tbl_UsuarioRol] PRIMARY KEY CLUSTERED ([nIdUsuario] ASC, [nIdRol] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [App].[Tbl_UsuarioToken] (
    [nIdUsuario] [int] NOT NULL,
    [cProveedorLogin] [nvarchar](128) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cNombre] [nvarchar](128) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cValor] [nvarchar](max) COLLATE Modern_Spanish_CI_AS NULL,
    CONSTRAINT [CK_Tbl_UsuarioToken_cNombre_NoVacio] CHECK (len(ltrim(rtrim([cNombre])))>(0)),
    CONSTRAINT [PK_Tbl_UsuarioToken] PRIMARY KEY CLUSTERED ([nIdUsuario] ASC, [cProveedorLogin] ASC, [cNombre] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO
CREATE TABLE [Aud].[Tbl_Auditoria] (
    [nIdAuditoria] [bigint] IDENTITY(1,1) NOT NULL,
    [nIdUsuario] [int] NULL,
    [cLoginOriginal] [nvarchar](128) COLLATE Modern_Spanish_CI_AS NOT NULL CONSTRAINT [DF_Tbl_Auditoria_cLoginOriginal] DEFAULT (original_login()),
    [cOperacion] [varchar](30) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cEsquema] [varchar](3) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [cObjeto] [nvarchar](128) COLLATE Modern_Spanish_CI_AS NOT NULL,
    [nIdRegistroAfectado] [bigint] NULL,
    [dFechaRegistro] [datetime2](0) NOT NULL CONSTRAINT [DF_Tbl_Auditoria_dFechaRegistro] DEFAULT (sysutcdatetime()),
    [cDatosAdicionales] [nvarchar](1000) COLLATE Modern_Spanish_CI_AS NULL,
    CONSTRAINT [CK_Tbl_Auditoria_Esquema] CHECK ([cEsquema]='Aud' OR [cEsquema]='Rep' OR [cEsquema]='App'),
    CONSTRAINT [PK_Tbl_Auditoria] PRIMARY KEY CLUSTERED ([nIdAuditoria] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
);
GO

/* SOURCE: 04_Indices.sql */
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
CREATE NONCLUSTERED INDEX [IX_Cat_Reticula_Carrera] ON [App].[Cat_Reticula] ([nIdCarrera] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_Usuario_Correo] ON [App].[Tbl_Usuario] ([cCorreoNormalizado] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_UsuarioRol_Rol] ON [App].[Tbl_UsuarioRol] ([nIdRol] ASC, [nIdUsuario] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_UsuarioClaim_Usuario] ON [App].[Tbl_UsuarioClaim] ([nIdUsuario] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_RolClaim_Rol] ON [App].[Tbl_RolClaim] ([nIdRol] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_UsuarioLogin_Usuario] ON [App].[Tbl_UsuarioLogin] ([nIdUsuario] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Tbl_TrayectoriaEstudiante_Vigente] ON [App].[Tbl_TrayectoriaEstudiante] ([nIdEstudiante] ASC) WHERE ([dFechaFin] IS NULL) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_TrayectoriaEstudiante_Estudiante] ON [App].[Tbl_TrayectoriaEstudiante] ([nIdEstudiante] ASC, [dFechaInicio] ASC) INCLUDE ([nIdReticula], [dFechaFin]) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_TrayectoriaEstudiante_Reticula] ON [App].[Tbl_TrayectoriaEstudiante] ([nIdReticula] ASC) INCLUDE ([nIdEstudiante]) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Tbl_Docente_Usuario] ON [App].[Tbl_Docente] ([nIdUsuario] ASC) WHERE ([nIdUsuario] IS NOT NULL) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_ReticulaMateria_Materia] ON [App].[Tbl_ReticulaMateria] ([nIdMateria] ASC, [nIdReticula] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_MateriaPrerrequisito_Antecedente] ON [App].[Tbl_MateriaPrerrequisito] ([nIdReticula] ASC, [nIdMateriaPrerrequisito] ASC) INCLUDE ([nIdMateria]) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Tbl_PeriodoAcademico_UnicoActivo] ON [App].[Tbl_PeriodoAcademico] ([nActivoGeneracion] ASC) WHERE ([nActivoGeneracion]=(1)) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_Grupo_DocentePeriodo] ON [App].[Tbl_Grupo] ([nIdDocente] ASC, [nIdPeriodo] ASC, [nEstatus] ASC) INCLUDE ([nIdMateria]) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_Grupo_MateriaPeriodo] ON [App].[Tbl_Grupo] ([nIdMateria] ASC, [nIdPeriodo] ASC, [nEstatus] ASC) INCLUDE ([nIdDocente], [cClaveGrupo]) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_SesionGrupo_AulaDiaHora] ON [App].[Tbl_SesionGrupo] ([nIdAula] ASC, [nIdDiaSemana] ASC, [dHoraInicio] ASC) INCLUDE ([dHoraFin], [nIdGrupo]) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_HistorialAcademico_MateriaEstudiante] ON [App].[Tbl_HistorialAcademico] ([nIdMateria] ASC, [nIdEstudiante] ASC) INCLUDE ([nIdEstatusAcademico]) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_HistorialAcademico_Periodo] ON [App].[Tbl_HistorialAcademico] ([nIdPeriodo] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Tbl_HorarioGenerado_SeleccionUnica] ON [App].[Tbl_HorarioGenerado] ([nIdTrayectoria] ASC, [nIdPeriodo] ASC) WHERE ([nSeleccionado]=(1)) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_HorarioGenerado_TrayectoriaPeriodo] ON [App].[Tbl_HorarioGenerado] ([nIdTrayectoria] ASC, [nIdPeriodo] ASC) INCLUDE ([nConfirmado]) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_HorarioGenerado_Periodo] ON [App].[Tbl_HorarioGenerado] ([nIdPeriodo] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_HorarioGeneradoDetalle_Grupo] ON [App].[Tbl_HorarioGeneradoDetalle] ([nIdGrupo] ASC, [nIdHorarioGenerado] ASC) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO
CREATE NONCLUSTERED INDEX [IX_Tbl_Auditoria_Fecha] ON [Aud].[Tbl_Auditoria] ([dFechaRegistro] ASC) INCLUDE ([cOperacion], [cObjeto]) WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO

/* SOURCE: 05_Claves_foraneas.sql */
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
ALTER TABLE [App].[Cat_Reticula] WITH CHECK ADD CONSTRAINT [FK_Cat_Reticula_Cat_Carrera] FOREIGN KEY ([nIdCarrera]) REFERENCES [App].[Cat_Carrera] ([nIdCarrera]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [Aud].[Tbl_Auditoria] WITH CHECK ADD CONSTRAINT [FK_Tbl_Auditoria_Tbl_Usuario] FOREIGN KEY ([nIdUsuario]) REFERENCES [App].[Tbl_Usuario] ([nIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_Aula] WITH CHECK ADD CONSTRAINT [FK_Tbl_Aula_Cat_TipoAula] FOREIGN KEY ([nIdTipoAula]) REFERENCES [App].[Cat_TipoAula] ([nIdTipoAula]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_Docente] WITH CHECK ADD CONSTRAINT [FK_Tbl_Docente_Tbl_Usuario] FOREIGN KEY ([nIdUsuario]) REFERENCES [App].[Tbl_Usuario] ([nIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_Estudiante] WITH CHECK ADD CONSTRAINT [FK_Tbl_Estudiante_Tbl_Usuario] FOREIGN KEY ([nIdUsuario]) REFERENCES [App].[Tbl_Usuario] ([nIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_Grupo] WITH CHECK ADD CONSTRAINT [FK_Tbl_Grupo_Cat_Materia] FOREIGN KEY ([nIdMateria]) REFERENCES [App].[Cat_Materia] ([nIdMateria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_Grupo] WITH CHECK ADD CONSTRAINT [FK_Tbl_Grupo_Tbl_Docente] FOREIGN KEY ([nIdDocente]) REFERENCES [App].[Tbl_Docente] ([nIdDocente]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_Grupo] WITH CHECK ADD CONSTRAINT [FK_Tbl_Grupo_Tbl_PeriodoAcademico] FOREIGN KEY ([nIdPeriodo]) REFERENCES [App].[Tbl_PeriodoAcademico] ([nIdPeriodo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_HistorialAcademico] WITH CHECK ADD CONSTRAINT [FK_Tbl_HistorialAcademico_Cat_EstatusAcademico] FOREIGN KEY ([nIdEstatusAcademico]) REFERENCES [App].[Cat_EstatusAcademico] ([nIdEstatusAcademico]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_HistorialAcademico] WITH CHECK ADD CONSTRAINT [FK_Tbl_HistorialAcademico_Cat_Materia] FOREIGN KEY ([nIdMateria]) REFERENCES [App].[Cat_Materia] ([nIdMateria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_HistorialAcademico] WITH CHECK ADD CONSTRAINT [FK_Tbl_HistorialAcademico_Tbl_Estudiante] FOREIGN KEY ([nIdEstudiante]) REFERENCES [App].[Tbl_Estudiante] ([nIdEstudiante]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_HistorialAcademico] WITH CHECK ADD CONSTRAINT [FK_Tbl_HistorialAcademico_Tbl_PeriodoAcademico] FOREIGN KEY ([nIdPeriodo]) REFERENCES [App].[Tbl_PeriodoAcademico] ([nIdPeriodo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_HorarioGenerado] WITH CHECK ADD CONSTRAINT [FK_Tbl_HorarioGenerado_Tbl_PeriodoAcademico] FOREIGN KEY ([nIdPeriodo]) REFERENCES [App].[Tbl_PeriodoAcademico] ([nIdPeriodo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_HorarioGenerado] WITH CHECK ADD CONSTRAINT [FK_Tbl_HorarioGenerado_Tbl_TrayectoriaEstudiante] FOREIGN KEY ([nIdTrayectoria]) REFERENCES [App].[Tbl_TrayectoriaEstudiante] ([nIdTrayectoria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_HorarioGeneradoDetalle] WITH CHECK ADD CONSTRAINT [FK_Tbl_HorarioGeneradoDetalle_Tbl_Grupo] FOREIGN KEY ([nIdGrupo]) REFERENCES [App].[Tbl_Grupo] ([nIdGrupo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_HorarioGeneradoDetalle] WITH CHECK ADD CONSTRAINT [FK_Tbl_HorarioGeneradoDetalle_Tbl_HorarioGenerado] FOREIGN KEY ([nIdHorarioGenerado]) REFERENCES [App].[Tbl_HorarioGenerado] ([nIdHorarioGenerado]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_MateriaPrerrequisito] WITH CHECK ADD CONSTRAINT [FK_Tbl_MateriaPrerrequisito_Tbl_ReticulaMateria_Antecedente] FOREIGN KEY ([nIdReticula], [nIdMateriaPrerrequisito]) REFERENCES [App].[Tbl_ReticulaMateria] ([nIdReticula], [nIdMateria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_MateriaPrerrequisito] WITH CHECK ADD CONSTRAINT [FK_Tbl_MateriaPrerrequisito_Tbl_ReticulaMateria_Objetivo] FOREIGN KEY ([nIdReticula], [nIdMateria]) REFERENCES [App].[Tbl_ReticulaMateria] ([nIdReticula], [nIdMateria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_ReticulaMateria] WITH CHECK ADD CONSTRAINT [FK_Tbl_ReticulaMateria_Cat_Materia] FOREIGN KEY ([nIdMateria]) REFERENCES [App].[Cat_Materia] ([nIdMateria]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_ReticulaMateria] WITH CHECK ADD CONSTRAINT [FK_Tbl_ReticulaMateria_Cat_Reticula] FOREIGN KEY ([nIdReticula]) REFERENCES [App].[Cat_Reticula] ([nIdReticula]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_RolClaim] WITH CHECK ADD CONSTRAINT [FK_Tbl_RolClaim_Cat_Rol] FOREIGN KEY ([nIdRol]) REFERENCES [App].[Cat_Rol] ([nIdRol]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_SesionGrupo] WITH CHECK ADD CONSTRAINT [FK_Tbl_SesionGrupo_Cat_DiaSemana] FOREIGN KEY ([nIdDiaSemana]) REFERENCES [App].[Cat_DiaSemana] ([nIdDiaSemana]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_SesionGrupo] WITH CHECK ADD CONSTRAINT [FK_Tbl_SesionGrupo_Tbl_Aula] FOREIGN KEY ([nIdAula]) REFERENCES [App].[Tbl_Aula] ([nIdAula]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_SesionGrupo] WITH CHECK ADD CONSTRAINT [FK_Tbl_SesionGrupo_Tbl_Grupo] FOREIGN KEY ([nIdGrupo]) REFERENCES [App].[Tbl_Grupo] ([nIdGrupo]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_TrayectoriaEstudiante] WITH CHECK ADD CONSTRAINT [FK_Tbl_TrayectoriaEstudiante_Cat_Reticula] FOREIGN KEY ([nIdReticula]) REFERENCES [App].[Cat_Reticula] ([nIdReticula]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_TrayectoriaEstudiante] WITH CHECK ADD CONSTRAINT [FK_Tbl_TrayectoriaEstudiante_Tbl_Estudiante] FOREIGN KEY ([nIdEstudiante]) REFERENCES [App].[Tbl_Estudiante] ([nIdEstudiante]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_UsuarioClaim] WITH CHECK ADD CONSTRAINT [FK_Tbl_UsuarioClaim_Tbl_Usuario] FOREIGN KEY ([nIdUsuario]) REFERENCES [App].[Tbl_Usuario] ([nIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_UsuarioLogin] WITH CHECK ADD CONSTRAINT [FK_Tbl_UsuarioLogin_Tbl_Usuario] FOREIGN KEY ([nIdUsuario]) REFERENCES [App].[Tbl_Usuario] ([nIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_UsuarioRol] WITH CHECK ADD CONSTRAINT [FK_Tbl_UsuarioRol_Cat_Rol] FOREIGN KEY ([nIdRol]) REFERENCES [App].[Cat_Rol] ([nIdRol]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_UsuarioRol] WITH CHECK ADD CONSTRAINT [FK_Tbl_UsuarioRol_Tbl_Usuario] FOREIGN KEY ([nIdUsuario]) REFERENCES [App].[Tbl_Usuario] ([nIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO
ALTER TABLE [App].[Tbl_UsuarioToken] WITH CHECK ADD CONSTRAINT [FK_Tbl_UsuarioToken_Tbl_Usuario] FOREIGN KEY ([nIdUsuario]) REFERENCES [App].[Tbl_Usuario] ([nIdUsuario]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO

/* SOURCE: 06_Vistas_y_funciones.sql */
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
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Elegibilidad para el periodo activo: no aprobada/cursando y antecedentes aprobados antes del periodo. */
CREATE   VIEW App.Vi_MateriasDisponibles AS
SELECT T.nIdTrayectoria,T.nIdEstudiante,T.nIdReticula,P.nIdPeriodo,M.nIdMateria,M.cClave AS cClaveMateria,
 M.cNombre AS cMateria,RM.nCreditos,RM.nSemestreRecomendado,RM.nObligatoria
FROM App.Tbl_TrayectoriaEstudiante T
JOIN App.Tbl_Estudiante E ON E.nIdEstudiante=T.nIdEstudiante
JOIN App.Cat_Reticula R ON R.nIdReticula=T.nIdReticula
JOIN App.Cat_Carrera C ON C.nIdCarrera=R.nIdCarrera
JOIN App.Tbl_ReticulaMateria RM ON RM.nIdReticula=T.nIdReticula
JOIN App.Cat_Materia M ON M.nIdMateria=RM.nIdMateria
CROSS JOIN App.Tbl_PeriodoAcademico P
WHERE P.nActivoGeneracion=1 AND T.dFechaFin IS NULL AND T.dFechaInicio<=P.dFechaInicio
 AND E.nEstatus=1 AND R.nEstatus=1 AND C.nEstatus=1 AND M.nEstatus=1
 AND NOT EXISTS (SELECT 1 FROM App.Tbl_HistorialAcademico H
 JOIN App.Cat_EstatusAcademico EA ON EA.nIdEstatusAcademico=H.nIdEstatusAcademico
 WHERE H.nIdEstudiante=T.nIdEstudiante AND H.nIdMateria=M.nIdMateria AND EA.cClave IN ('APROBADA','CURSANDO'))
 AND NOT EXISTS (SELECT 1 FROM App.Tbl_MateriaPrerrequisito PR
 WHERE PR.nIdReticula=T.nIdReticula AND PR.nIdMateria=M.nIdMateria AND PR.nObligatorio=1
 AND NOT EXISTS (SELECT 1 FROM App.Tbl_HistorialAcademico H
 JOIN App.Cat_EstatusAcademico EA ON EA.nIdEstatusAcademico=H.nIdEstatusAcademico
 JOIN App.Tbl_PeriodoAcademico PA ON PA.nIdPeriodo=H.nIdPeriodo
 WHERE H.nIdEstudiante=T.nIdEstudiante AND H.nIdMateria=PR.nIdMateriaPrerrequisito
 AND EA.cClave='APROBADA' AND PA.dFechaFin<P.dFechaInicio));
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Relación operativa de versiones curriculares y sus materias. */
CREATE   VIEW App.Vi_MateriasReticula AS
SELECT C.nIdCarrera,C.cClave AS cClaveCarrera,C.cNombre AS cCarrera,
 R.nIdReticula,R.cClave AS cClaveReticula,R.cNombre AS cReticula,
 M.nIdMateria,M.cClave AS cClaveMateria,M.cNombre AS cMateria,
 RM.nSemestreRecomendado,RM.nCreditos,RM.nObligatoria
FROM App.Cat_Carrera C JOIN App.Cat_Reticula R ON R.nIdCarrera=C.nIdCarrera
JOIN App.Tbl_ReticulaMateria RM ON RM.nIdReticula=R.nIdReticula
JOIN App.Cat_Materia M ON M.nIdMateria=RM.nIdMateria;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Supervisión DBA de eventos; runtime no tiene SELECT. */
CREATE   VIEW Aud.Vi_ActividadBD AS
SELECT nIdAuditoria,nIdUsuario,cLoginOriginal,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado,dFechaRegistro,cDatosAdicionales
FROM Aud.Tbl_Auditoria;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Intentos por estudiante y periodo, sin credenciales. */
CREATE   VIEW Rep.Vi_HistorialEstudiante AS
SELECT E.nIdEstudiante,E.cNumeroControl,H.nIdHistorialAcademico,M.nIdMateria,M.cClave AS cClaveMateria,
 M.cNombre AS cMateria,P.nIdPeriodo,P.cClave AS cPeriodo,EA.cClave AS cEstatusAcademico,H.nCalificacion,H.dFechaRegistro
FROM App.Tbl_HistorialAcademico H JOIN App.Tbl_Estudiante E ON E.nIdEstudiante=H.nIdEstudiante
JOIN App.Cat_Materia M ON M.nIdMateria=H.nIdMateria
JOIN App.Cat_EstatusAcademico EA ON EA.nIdEstatusAcademico=H.nIdEstatusAcademico
LEFT JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=H.nIdPeriodo;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Detalle de opciones confirmadas, una fila por grupo. */
CREATE   VIEW Rep.Vi_HorariosGenerados AS
SELECT H.nIdHorarioGenerado,T.nIdEstudiante,T.nIdReticula,H.nIdPeriodo,P.cClave AS cPeriodo,
 H.cNombre,H.nConfirmado,H.nSeleccionado,H.dFechaRegistro,G.nIdGrupo,G.cClaveGrupo,M.nIdMateria,
 M.cClave AS cClaveMateria,M.cNombre AS cMateria,RM.nCreditos
FROM App.Tbl_HorarioGenerado H JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria
JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=H.nIdPeriodo
JOIN App.Tbl_HorarioGeneradoDetalle D ON D.nIdHorarioGenerado=H.nIdHorarioGenerado
JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo
JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria
LEFT JOIN App.Tbl_ReticulaMateria RM ON RM.nIdReticula=T.nIdReticula AND RM.nIdMateria=G.nIdMateria
WHERE H.nConfirmado=1;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Una fila por sesión; LEFT JOIN permite observar faltantes en preparación. */
CREATE   VIEW Rep.Vi_OfertaAcademica AS
SELECT P.nIdPeriodo,P.cClave AS cPeriodo,P.nActivoGeneracion,P.nOfertaPublicada,
 M.nIdMateria,M.cClave AS cClaveMateria,M.cNombre AS cMateria,G.nIdGrupo,G.cClaveGrupo,G.nEstatus AS nGrupoActivo,
 D.nIdDocente,D.cNombre AS cDocente,S.nIdSesionGrupo,DS.nIdDiaSemana,DS.cNombre AS cDia,
 S.dHoraInicio,S.dHoraFin,A.nIdAula,A.cClave AS cAula,A.nCapacidad
FROM App.Tbl_Grupo G JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=G.nIdPeriodo
JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria
LEFT JOIN App.Tbl_Docente D ON D.nIdDocente=G.nIdDocente
LEFT JOIN App.Tbl_SesionGrupo S ON S.nIdGrupo=G.nIdGrupo
LEFT JOIN App.Cat_DiaSemana DS ON DS.nIdDiaSemana=S.nIdDiaSemana
LEFT JOIN App.Tbl_Aula A ON A.nIdAula=S.nIdAula;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Periodos disponibles para consulta y reportes cronológicos. */
CREATE   VIEW Rep.Vi_PeriodosAcademicos AS
SELECT nIdPeriodo,cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion,nOfertaPublicada
FROM App.Tbl_PeriodoAcademico;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Totales calculados por grupo, nunca multiplicados por las sesiones. */
CREATE   VIEW Rep.Vi_ResumenHorarios AS
SELECT H.nIdHorarioGenerado,T.nIdEstudiante,H.nIdTrayectoria,H.nIdPeriodo,H.cNombre,
 H.nConfirmado,H.nSeleccionado,H.dFechaRegistro,
 COALESCE(SUM(CONVERT(int,RM.nCreditos)),0) AS nTotalCreditos,COUNT(D.nIdGrupo) AS nTotalGrupos
FROM App.Tbl_HorarioGenerado H JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria
LEFT JOIN App.Tbl_HorarioGeneradoDetalle D ON D.nIdHorarioGenerado=H.nIdHorarioGenerado
LEFT JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo
LEFT JOIN App.Tbl_ReticulaMateria RM ON RM.nIdReticula=T.nIdReticula AND RM.nIdMateria=G.nIdMateria
GROUP BY H.nIdHorarioGenerado,T.nIdEstudiante,H.nIdTrayectoria,H.nIdPeriodo,H.cNombre,
 H.nConfirmado,H.nSeleccionado,H.dFechaRegistro;
GO

/* SOURCE: 07_Procedimientos.sql */
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
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Interno. Debe llamarse dentro de transacción. Bloqueo común a SP y guards de DML. */
CREATE   PROCEDURE App.Sp_BloquearIntegridad
AS
BEGIN
 SET NOCOUNT ON;
 IF @@TRANCOUNT=0 THROW 51000,N'La operación de integridad requiere transacción.',1;
 IF (SELECT transaction_isolation_level FROM sys.dm_exec_sessions WHERE session_id=@@SPID)=5
  THROW 51000,N'Use READ COMMITTED para escrituras académicas, no SNAPSHOT.',1;
 DECLARE @nResultado int;
 EXEC @nResultado=sys.sp_getapplock @Resource=N'IntegridadSistemaHorarios',@LockMode='Exclusive',
  @LockOwner='Transaction',@LockTimeout=15000,@DbPrincipal='public';
 IF @nResultado<0 THROW 51000,N'No se obtuvo el bloqueo de integridad; reintente la transacción.',1;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Grupos activos publicados y sus sesiones para la materia y el periodo activo. */
CREATE   PROCEDURE App.Sp_ObtenerGruposMateria @nIdMateria int AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM App.Cat_Materia WHERE nIdMateria=@nIdMateria) THROW 51209,N'Materia inexistente.',1;
 SELECT G.nIdGrupo,G.cClaveGrupo,G.nIdDocente,G.nIdPeriodo,S.nIdSesionGrupo,S.nIdDiaSemana,S.nIdAula,S.dHoraInicio,S.dHoraFin
 FROM App.Tbl_Grupo G JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=G.nIdPeriodo
 JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria
 JOIN App.Tbl_SesionGrupo S ON S.nIdGrupo=G.nIdGrupo
 WHERE G.nIdMateria=@nIdMateria AND G.nEstatus=1 AND M.nEstatus=1 AND P.nActivoGeneracion=1 AND P.nOfertaPublicada=1
 ORDER BY G.cClaveGrupo,S.nIdDiaSemana,S.dHoraInicio;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Elegibilidad parametrizada para una persona; consulta no garantiza una futura escritura. */
CREATE   PROCEDURE App.Sp_ObtenerMateriasDisponibles @nIdEstudiante int AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_Estudiante WHERE nIdEstudiante=@nIdEstudiante) THROW 51208,N'Estudiante inexistente.',1;
 SELECT nIdTrayectoria,nIdEstudiante,nIdReticula,nIdPeriodo,nIdMateria,cClaveMateria,cMateria,nCreditos,nSemestreRecomendado,nObligatoria
 FROM App.Vi_MateriasDisponibles WHERE nIdEstudiante=@nIdEstudiante ORDER BY nSemestreRecomendado,cClaveMateria;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Diagnóstico de conflicto de aula; no sustituye el registro atómico. */
CREATE   PROCEDURE App.Sp_ValidarConflictoAula
 @nIdAula int,@nIdPeriodo int,@nIdDiaSemana tinyint,@dHoraInicio time(0),@dHoraFin time(0),
 @nHayConflicto bit OUTPUT,@nIdSesionExcluir int=NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF @dHoraInicio IS NULL OR @dHoraFin IS NULL OR @dHoraInicio>=@dHoraFin
  THROW 51200,N'Intervalo de horas inválido.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=@nIdDiaSemana)
  THROW 51201,N'Día de semana inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_Aula WHERE nIdAula=@nIdAula)
  THROW 51202,N'Aula inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico WHERE nIdPeriodo=@nIdPeriodo)
  THROW 51203,N'Periodo inexistente.',1;
 SELECT @nHayConflicto=CASE WHEN EXISTS (
 SELECT 1 FROM App.Tbl_SesionGrupo S WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=S.nIdGrupo
 WHERE S.nIdAula=@nIdAula
 AND G.nIdPeriodo=@nIdPeriodo AND G.nEstatus=1 AND S.nIdDiaSemana=@nIdDiaSemana
 AND (@nIdSesionExcluir IS NULL OR S.nIdSesionGrupo<>@nIdSesionExcluir)
 AND S.dHoraInicio<@dHoraFin AND @dHoraInicio<S.dHoraFin) THEN 1 ELSE 0 END;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Diagnóstico de conflicto de docente; no sustituye el registro atómico. */
CREATE   PROCEDURE App.Sp_ValidarConflictoDocente
 @nIdDocente int,@nIdPeriodo int,@nIdDiaSemana tinyint,@dHoraInicio time(0),@dHoraFin time(0),
 @nHayConflicto bit OUTPUT,@nIdSesionExcluir int=NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF @dHoraInicio IS NULL OR @dHoraFin IS NULL OR @dHoraInicio>=@dHoraFin
  THROW 51200,N'Intervalo de horas inválido.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=@nIdDiaSemana)
  THROW 51201,N'Día de semana inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_Docente WHERE nIdDocente=@nIdDocente)
  THROW 51202,N'Docente inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico WHERE nIdPeriodo=@nIdPeriodo)
  THROW 51203,N'Periodo inexistente.',1;
 SELECT @nHayConflicto=CASE WHEN EXISTS (
 SELECT 1 FROM App.Tbl_SesionGrupo S WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=S.nIdGrupo
 WHERE G.nIdDocente=@nIdDocente
 AND G.nIdPeriodo=@nIdPeriodo AND G.nEstatus=1 AND S.nIdDiaSemana=@nIdDiaSemana
 AND (@nIdSesionExcluir IS NULL OR S.nIdSesionGrupo<>@nIdSesionExcluir)
 AND S.dHoraInicio<@dHoraFin AND @dHoraInicio<S.dHoraFin) THEN 1 ELSE 0 END;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Solo administradores autorizados. No registra payload de credenciales. */
CREATE   PROCEDURE Aud.Sp_RegistrarAuditoria
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
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Sp_GuardarHorarioGenerado. Parámetros: trayectoria, periodo, nombre, TVP grupos, selección y actor. Valida RV-001..007. Afecta cabecera, detalle y auditoría.
Transacción propia o savepoint; errores personalizados; escritura y auditoría atómicas. */
CREATE   PROCEDURE App.Sp_GuardarHorarioGenerado 
 @nIdTrayectoria int,@nIdPeriodo int,@cNombre nvarchar(100),@Grupos App.Tbl_ListaGrupo READONLY,
 @nIdHorarioGenerado int OUTPUT,@nSeleccionar bit=0,@nIdUsuarioActor int=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 DECLARE @nTransaccionInicial int=@@TRANCOUNT;
 BEGIN TRY
  IF @nTransaccionInicial=0 BEGIN TRANSACTION; ELSE SAVE TRANSACTION SV_GuardarHorarioGenerado;
  EXEC App.Sp_BloquearIntegridad;
  
 IF @cNombre IS NULL OR LEN(LTRIM(RTRIM(@cNombre)))=0 THROW 51206,N'Indique el nombre del horario.',1;
 IF @nSeleccionar IS NULL THROW 51206,N'Indique si se seleccionará la opción.',1;
 IF NOT EXISTS (SELECT 1 FROM @Grupos) THROW 51101,N'El horario debe contener al menos un grupo.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_TrayectoriaEstudiante WITH (UPDLOCK,HOLDLOCK) WHERE nIdTrayectoria=@nIdTrayectoria)
  THROW 51207,N'Trayectoria inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico WITH (UPDLOCK,HOLDLOCK) WHERE nIdPeriodo=@nIdPeriodo AND nActivoGeneracion=1 AND nOfertaPublicada=1)
  THROW 51100,N'Periodo inactivo o sin oferta publicada.',1;
 IF EXISTS (SELECT 1 FROM @Grupos L LEFT JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=L.nIdGrupo WHERE G.nIdGrupo IS NULL)
  THROW 51204,N'Grupo inexistente.',1;
 INSERT App.Tbl_HorarioGenerado(nIdTrayectoria,nIdPeriodo,cNombre) VALUES(@nIdTrayectoria,@nIdPeriodo,@cNombre);
 SET @nIdHorarioGenerado=CONVERT(int,SCOPE_IDENTITY());
 INSERT App.Tbl_HorarioGeneradoDetalle(nIdHorarioGenerado,nIdGrupo) SELECT @nIdHorarioGenerado,nIdGrupo FROM @Grupos;
 IF @nSeleccionar=1 UPDATE App.Tbl_HorarioGenerado SET nSeleccionado=0 WHERE nIdTrayectoria=@nIdTrayectoria AND nIdPeriodo=@nIdPeriodo AND nSeleccionado=1;
 UPDATE App.Tbl_HorarioGenerado SET nConfirmado=1,nSeleccionado=@nSeleccionar WHERE nIdHorarioGenerado=@nIdHorarioGenerado;
 INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado)
 VALUES(@nIdUsuarioActor,'CONFIRMAR','App',N'Tbl_HorarioGenerado',@nIdHorarioGenerado);

  IF @nTransaccionInicial=0 COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF @nTransaccionInicial=0 AND XACT_STATE()<>0 ROLLBACK TRANSACTION;
  ELSE IF @nTransaccionInicial>0 AND XACT_STATE()=1 ROLLBACK TRANSACTION SV_GuardarHorarioGenerado;
  THROW;
 END CATCH;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Sp_PublicarOferta. Parámetros: periodo y actor. Afecta Periodo y auditoría. El guard comprueba RV-012 y empalmes.
Transacción propia o savepoint; errores personalizados; escritura y auditoría atómicas. */
CREATE   PROCEDURE App.Sp_PublicarOferta @nIdPeriodo int,@nIdUsuarioActor int=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 DECLARE @nTransaccionInicial int=@@TRANCOUNT;
 BEGIN TRY
  IF @nTransaccionInicial=0 BEGIN TRANSACTION; ELSE SAVE TRANSACTION SV_PublicarOferta;
  EXEC App.Sp_BloquearIntegridad;
  
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico WITH (UPDLOCK,HOLDLOCK) WHERE nIdPeriodo=@nIdPeriodo)
  THROW 51203,N'Periodo inexistente.',1;
 UPDATE App.Tbl_PeriodoAcademico SET nOfertaPublicada=1 WHERE nIdPeriodo=@nIdPeriodo;
 INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado)
 VALUES(@nIdUsuarioActor,'PUBLICAR','App',N'Tbl_PeriodoAcademico',@nIdPeriodo);

  IF @nTransaccionInicial=0 COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF @nTransaccionInicial=0 AND XACT_STATE()<>0 ROLLBACK TRANSACTION;
  ELSE IF @nTransaccionInicial>0 AND XACT_STATE()=1 ROLLBACK TRANSACTION SV_PublicarOferta;
  THROW;
 END CATCH;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Sp_RegistrarSesionGrupo. Parámetros: grupo, día, aula, intervalo y actor opcional. Afecta SesionGrupo y auditoría. Valida grupo y recursos.
Transacción propia o savepoint; errores personalizados; escritura y auditoría atómicas. */
CREATE   PROCEDURE App.Sp_RegistrarSesionGrupo 
 @nIdGrupo int,@nIdDiaSemana tinyint,@nIdAula int,@dHoraInicio time(0),@dHoraFin time(0),
 @nIdSesionGrupo int OUTPUT,@nIdUsuarioActor int=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 DECLARE @nTransaccionInicial int=@@TRANCOUNT;
 BEGIN TRY
  IF @nTransaccionInicial=0 BEGIN TRANSACTION; ELSE SAVE TRANSACTION SV_RegistrarSesionGrupo;
  EXEC App.Sp_BloquearIntegridad;
  
 IF @dHoraInicio IS NULL OR @dHoraFin IS NULL OR @dHoraInicio>=@dHoraFin THROW 51200,N'Intervalo de horas inválido.',1;
 DECLARE @nIdPeriodo int,@nIdDocente int,@nGrupoActivo bit,@nConflicto bit;
 SELECT @nIdPeriodo=nIdPeriodo,@nIdDocente=nIdDocente,@nGrupoActivo=nEstatus
 FROM App.Tbl_Grupo WITH (UPDLOCK,HOLDLOCK) WHERE nIdGrupo=@nIdGrupo;
 IF @nIdPeriodo IS NULL THROW 51204,N'Grupo inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_Aula WITH (READCOMMITTEDLOCK) WHERE nIdAula=@nIdAula AND nEstatus=1)
  THROW 51205,N'Aula inexistente o inactiva.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=@nIdDiaSemana) THROW 51201,N'Día de semana inexistente.',1;
 IF @nGrupoActivo=1
 BEGIN
  IF @nIdDocente IS NOT NULL
  BEGIN
   EXEC App.Sp_ValidarConflictoDocente @nIdDocente,@nIdPeriodo,@nIdDiaSemana,@dHoraInicio,@dHoraFin,@nConflicto OUTPUT;
   IF @nConflicto=1 THROW 51002,N'Conflicto de docente en el mismo periodo.',1;
  END;
  EXEC App.Sp_ValidarConflictoAula @nIdAula,@nIdPeriodo,@nIdDiaSemana,@dHoraInicio,@dHoraFin,@nConflicto OUTPUT;
  IF @nConflicto=1 THROW 51003,N'Conflicto de aula en el mismo periodo.',1;
 END;
 INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin)
 VALUES(@nIdGrupo,@nIdDiaSemana,@nIdAula,@dHoraInicio,@dHoraFin);
 SET @nIdSesionGrupo=CONVERT(int,SCOPE_IDENTITY());
 INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado)
 VALUES(@nIdUsuarioActor,'INSERT','App',N'Tbl_SesionGrupo',@nIdSesionGrupo);

  IF @nTransaccionInicial=0 COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF @nTransaccionInicial=0 AND XACT_STATE()<>0 ROLLBACK TRANSACTION;
  ELSE IF @nTransaccionInicial>0 AND XACT_STATE()=1 ROLLBACK TRANSACTION SV_RegistrarSesionGrupo;
  THROW;
 END CATCH;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Selecciona una opción propia confirmada del periodo activo, de forma atómica.
La identidad del actor proviene del JWT verificado en la API; no del cuerpo de la petición.
Registra auditoría interna por ownership chaining, sin conceder acceso directo a Aud. */
CREATE   PROCEDURE App.Sp_SeleccionarHorarioGenerado @nIdUsuarioActor int,@nIdHorarioGenerado int
AS
BEGIN
 SET NOCOUNT ON;SET XACT_ABORT ON;
 DECLARE @nInicial int=@@TRANCOUNT,@nTrayectoria int,@nPeriodo int;
 BEGIN TRY
  IF @nInicial=0 BEGIN TRAN;ELSE SAVE TRAN SV_SeleccionarHorario;
  EXEC App.Sp_BloquearIntegridad;
  SELECT @nTrayectoria=H.nIdTrayectoria,@nPeriodo=H.nIdPeriodo FROM App.Tbl_HorarioGenerado H WITH(UPDLOCK,HOLDLOCK)
  JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria
  JOIN App.Tbl_Estudiante E ON E.nIdEstudiante=T.nIdEstudiante
  JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=H.nIdPeriodo
  WHERE H.nIdHorarioGenerado=@nIdHorarioGenerado AND H.nConfirmado=1 AND E.nIdUsuario=@nIdUsuarioActor
   AND E.nEstatus=1 AND T.dFechaFin IS NULL AND P.nActivoGeneracion=1 AND P.nOfertaPublicada=1;
  IF @nTrayectoria IS NULL THROW 52200,N'La opción no existe, no te pertenece o no está disponible en el periodo activo.',1;
  UPDATE App.Tbl_HorarioGenerado SET nSeleccionado=0 WHERE nIdTrayectoria=@nTrayectoria AND nIdPeriodo=@nPeriodo AND nSeleccionado=1;
  UPDATE App.Tbl_HorarioGenerado SET nSeleccionado=1 WHERE nIdHorarioGenerado=@nIdHorarioGenerado;
  INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado)
  VALUES(@nIdUsuarioActor,'SELECCIONAR','App','Tbl_HorarioGenerado',@nIdHorarioGenerado);
  IF @nInicial=0 COMMIT;
 END TRY BEGIN CATCH
  IF @nInicial=0 AND XACT_STATE()<>0 ROLLBACK;
  ELSE IF @nInicial>0 AND XACT_STATE()=1 ROLLBACK TRAN SV_SeleccionarHorario;
  THROW;
 END CATCH;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Interno. Valida una opción entera antes de confirmarla; no modifica datos. */
CREATE   PROCEDURE App.Sp_ValidarHorario @nIdHorarioGenerado int
AS
BEGIN
 SET NOCOUNT ON;
 EXEC App.Sp_BloquearIntegridad;
 DECLARE @nIdTrayectoria int,@nIdReticula int,@nIdEstudiante int,@nLimiteCreditos int,@nIdPeriodo int,@dInicio date;
 SELECT @nIdTrayectoria=H.nIdTrayectoria,@nIdPeriodo=H.nIdPeriodo,@nIdReticula=T.nIdReticula,
 @nIdEstudiante=T.nIdEstudiante,@nLimiteCreditos=T.nLimiteCreditos,@dInicio=P.dFechaInicio
 FROM App.Tbl_HorarioGenerado H WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_TrayectoriaEstudiante T WITH (READCOMMITTEDLOCK) ON T.nIdTrayectoria=H.nIdTrayectoria
 JOIN App.Tbl_Estudiante E WITH (READCOMMITTEDLOCK) ON E.nIdEstudiante=T.nIdEstudiante
 JOIN App.Tbl_Usuario U WITH (READCOMMITTEDLOCK) ON U.nIdUsuario=E.nIdUsuario
 JOIN App.Cat_Reticula R WITH (READCOMMITTEDLOCK) ON R.nIdReticula=T.nIdReticula
 JOIN App.Cat_Carrera C WITH (READCOMMITTEDLOCK) ON C.nIdCarrera=R.nIdCarrera
 JOIN App.Tbl_PeriodoAcademico P WITH (READCOMMITTEDLOCK) ON P.nIdPeriodo=H.nIdPeriodo
 WHERE H.nIdHorarioGenerado=@nIdHorarioGenerado AND T.dFechaFin IS NULL AND T.dFechaInicio<=P.dFechaInicio
 AND E.nEstatus=1 AND U.nEstatus=1 AND R.nEstatus=1 AND C.nEstatus=1 AND P.nActivoGeneracion=1 AND P.nOfertaPublicada=1;
 IF @nIdTrayectoria IS NULL THROW 51100,N'Horario, trayectoria o periodo activo/publicado no válidos.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle WITH (READCOMMITTEDLOCK) WHERE nIdHorarioGenerado=@nIdHorarioGenerado)
  THROW 51101,N'El horario debe contener al menos un grupo.',1;
 IF EXISTS (SELECT G.nIdMateria FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado GROUP BY G.nIdMateria HAVING COUNT(*)>1)
  THROW 51102,N'RV-001: dos grupos de la misma materia.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 JOIN App.Cat_Materia M WITH (READCOMMITTEDLOCK) ON M.nIdMateria=G.nIdMateria
 LEFT JOIN App.Tbl_ReticulaMateria RM WITH (READCOMMITTEDLOCK) ON RM.nIdReticula=@nIdReticula AND RM.nIdMateria=G.nIdMateria
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado AND (G.nIdPeriodo<>@nIdPeriodo OR G.nEstatus=0 OR M.nEstatus=0 OR RM.nIdMateria IS NULL))
  THROW 51103,N'RV-005/006/007: grupo inactivo, ajeno al periodo o a la retícula.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_HorarioGeneradoDetalle B WITH (READCOMMITTEDLOCK) ON B.nIdHorarioGenerado=A.nIdHorarioGenerado AND A.nIdGrupo<B.nIdGrupo
 JOIN App.Tbl_SesionGrupo SA WITH (READCOMMITTEDLOCK) ON SA.nIdGrupo=A.nIdGrupo
 JOIN App.Tbl_SesionGrupo SB WITH (READCOMMITTEDLOCK) ON SB.nIdGrupo=B.nIdGrupo
 WHERE A.nIdHorarioGenerado=@nIdHorarioGenerado AND SA.nIdDiaSemana=SB.nIdDiaSemana
 AND SA.dHoraInicio<SB.dHoraFin AND SB.dHoraInicio<SA.dHoraFin)
  THROW 51104,N'RV-002: empalme entre grupos seleccionados.',1;
 IF (SELECT SUM(CONVERT(int,RM.nCreditos)) FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 JOIN App.Tbl_ReticulaMateria RM WITH (READCOMMITTEDLOCK) ON RM.nIdReticula=@nIdReticula AND RM.nIdMateria=G.nIdMateria
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado)>@nLimiteCreditos
  THROW 51105,N'RV-003: el horario supera el límite de créditos.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 JOIN App.Tbl_MateriaPrerrequisito PR WITH (READCOMMITTEDLOCK) ON PR.nIdReticula=@nIdReticula AND PR.nIdMateria=G.nIdMateria AND PR.nObligatorio=1
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado AND NOT EXISTS (
 SELECT 1 FROM App.Tbl_HistorialAcademico HA WITH (READCOMMITTEDLOCK)
 JOIN App.Cat_EstatusAcademico EA WITH (READCOMMITTEDLOCK) ON EA.nIdEstatusAcademico=HA.nIdEstatusAcademico
 JOIN App.Tbl_PeriodoAcademico PA WITH (READCOMMITTEDLOCK) ON PA.nIdPeriodo=HA.nIdPeriodo
 WHERE HA.nIdEstudiante=@nIdEstudiante AND HA.nIdMateria=PR.nIdMateriaPrerrequisito AND EA.cClave='APROBADA' AND PA.dFechaFin<@dInicio))
  THROW 51106,N'RV-004: falta aprobar un prerrequisito obligatorio antes del periodo.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 JOIN App.Tbl_HistorialAcademico HA WITH (READCOMMITTEDLOCK) ON HA.nIdMateria=G.nIdMateria AND HA.nIdEstudiante=@nIdEstudiante
 JOIN App.Cat_EstatusAcademico EA WITH (READCOMMITTEDLOCK) ON EA.nIdEstatusAcademico=HA.nIdEstatusAcademico
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado AND EA.cClave IN ('APROBADA','CURSANDO'))
  THROW 51107,N'La materia ya está aprobada o cursándose.',1;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Interno. Estado global de oferta y dominios; ejecutado con el bloqueo transaccional adquirido. */
CREATE   PROCEDURE App.Sp_ValidarIntegridadOferta
AS
BEGIN
 SET NOCOUNT ON;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_SesionGrupo B WITH (READCOMMITTEDLOCK) ON A.nIdSesionGrupo<B.nIdSesionGrupo
 AND A.nIdDiaSemana=B.nIdDiaSemana AND A.dHoraInicio<B.dHoraFin AND B.dHoraInicio<A.dHoraFin
 JOIN App.Tbl_Grupo GA WITH (READCOMMITTEDLOCK) ON GA.nIdGrupo=A.nIdGrupo
 JOIN App.Tbl_Grupo GB WITH (READCOMMITTEDLOCK) ON GB.nIdGrupo=B.nIdGrupo
 WHERE GA.nEstatus=1 AND GB.nEstatus=1 AND GA.nIdPeriodo=GB.nIdPeriodo AND GA.nIdGrupo=GB.nIdGrupo)
  THROW 51004,N'El grupo contiene sesiones empalmadas.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_SesionGrupo B WITH (READCOMMITTEDLOCK) ON A.nIdSesionGrupo<B.nIdSesionGrupo
 AND A.nIdDiaSemana=B.nIdDiaSemana AND A.dHoraInicio<B.dHoraFin AND B.dHoraInicio<A.dHoraFin
 JOIN App.Tbl_Grupo GA WITH (READCOMMITTEDLOCK) ON GA.nIdGrupo=A.nIdGrupo
 JOIN App.Tbl_Grupo GB WITH (READCOMMITTEDLOCK) ON GB.nIdGrupo=B.nIdGrupo
 WHERE GA.nEstatus=1 AND GB.nEstatus=1 AND GA.nIdPeriodo=GB.nIdPeriodo AND GA.nIdDocente=GB.nIdDocente)
  THROW 51002,N'Conflicto de docente en el mismo periodo.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_SesionGrupo B WITH (READCOMMITTEDLOCK) ON A.nIdSesionGrupo<B.nIdSesionGrupo
 AND A.nIdDiaSemana=B.nIdDiaSemana AND A.dHoraInicio<B.dHoraFin AND B.dHoraInicio<A.dHoraFin
 JOIN App.Tbl_Grupo GA WITH (READCOMMITTEDLOCK) ON GA.nIdGrupo=A.nIdGrupo
 JOIN App.Tbl_Grupo GB WITH (READCOMMITTEDLOCK) ON GB.nIdGrupo=B.nIdGrupo
 WHERE GA.nEstatus=1 AND GB.nEstatus=1 AND GA.nIdPeriodo=GB.nIdPeriodo AND A.nIdAula=B.nIdAula)
  THROW 51003,N'Conflicto de aula en el mismo periodo.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico P WITH (READCOMMITTEDLOCK)
 WHERE P.nOfertaPublicada=1 AND
 (NOT EXISTS (SELECT 1 FROM App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) WHERE G.nIdPeriodo=P.nIdPeriodo AND G.nEstatus=1)
 OR EXISTS (SELECT 1 FROM App.Tbl_Grupo G WITH (READCOMMITTEDLOCK)
 LEFT JOIN App.Tbl_Docente D WITH (READCOMMITTEDLOCK) ON D.nIdDocente=G.nIdDocente
 JOIN App.Cat_Materia M WITH (READCOMMITTEDLOCK) ON M.nIdMateria=G.nIdMateria
 WHERE G.nIdPeriodo=P.nIdPeriodo AND G.nEstatus=1 AND
 (G.nIdDocente IS NULL OR (P.nActivoGeneracion=1 AND (D.nEstatus=0 OR M.nEstatus=0))
 OR NOT EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo S WITH (READCOMMITTEDLOCK) WHERE S.nIdGrupo=G.nIdGrupo)
 OR EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo S WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Aula A WITH (READCOMMITTEDLOCK) ON A.nIdAula=S.nIdAula
 JOIN App.Cat_TipoAula TA WITH (READCOMMITTEDLOCK) ON TA.nIdTipoAula=A.nIdTipoAula
 WHERE S.nIdGrupo=G.nIdGrupo AND P.nActivoGeneracion=1 AND (A.nEstatus=0 OR TA.nEstatus=0))))))
  THROW 51012,N'Oferta incompleta: requiere grupos activos, docentes, materias, sesiones y aulas habilitados.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGenerado H WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_PeriodoAcademico P WITH (READCOMMITTEDLOCK) ON P.nIdPeriodo=H.nIdPeriodo
 WHERE H.nConfirmado=1 AND P.nOfertaPublicada=0)
  THROW 51013,N'No se puede despublicar un periodo con horarios confirmados.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HistorialAcademico H WITH (READCOMMITTEDLOCK)
 JOIN App.Cat_EstatusAcademico E WITH (READCOMMITTEDLOCK) ON E.nIdEstatusAcademico=H.nIdEstatusAcademico
 WHERE (E.cClave='PENDIENTE' AND (H.nIdPeriodo IS NOT NULL OR H.nCalificacion IS NOT NULL))
 OR (E.cClave<>'PENDIENTE' AND H.nIdPeriodo IS NULL)
 OR (E.cClave IN ('APROBADA','NO_APROBADA') AND H.nCalificacion IS NULL)
 OR (E.cClave='CURSANDO' AND H.nCalificacion IS NOT NULL))
  THROW 51014,N'Historial: periodo o calificación incompatibles con el estado académico.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_TrayectoriaEstudiante A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_TrayectoriaEstudiante B WITH (READCOMMITTEDLOCK) ON A.nIdTrayectoria<B.nIdTrayectoria
 AND A.nIdEstudiante=B.nIdEstudiante AND A.dFechaInicio<=COALESCE(B.dFechaFin,CONVERT(date,'99991231'))
 AND B.dFechaInicio<=COALESCE(A.dFechaFin,CONVERT(date,'99991231')))
  THROW 51015,N'Las trayectorias del estudiante no pueden solaparse.',1;
 DECLARE @nCiclos int;
 ;WITH R AS (
 SELECT nIdReticula,nIdMateria,nIdMateriaPrerrequisito,
 CAST('/'+CONVERT(varchar(11),nIdMateria)+'/'+CONVERT(varchar(11),nIdMateriaPrerrequisito)+'/' AS varchar(max)) AS cRuta,
 CAST(0 AS int) AS nCiclo FROM App.Tbl_MateriaPrerrequisito WITH (READCOMMITTEDLOCK)
 UNION ALL
 SELECT R.nIdReticula,R.nIdMateria,P.nIdMateriaPrerrequisito,
 CAST(R.cRuta+CONVERT(varchar(11),P.nIdMateriaPrerrequisito)+'/' AS varchar(max)),
 CASE WHEN CHARINDEX('/'+CONVERT(varchar(11),P.nIdMateriaPrerrequisito)+'/',R.cRuta)>0 THEN 1 ELSE 0 END
 FROM R JOIN App.Tbl_MateriaPrerrequisito P WITH (READCOMMITTEDLOCK)
 ON P.nIdReticula=R.nIdReticula AND P.nIdMateria=R.nIdMateriaPrerrequisito WHERE R.nCiclo=0)
 SELECT @nCiclos=COUNT(*) FROM R WHERE nCiclo=1 OPTION (MAXRECURSION 32767);
 IF @nCiclos>0 THROW 51016,N'La relación de prerrequisitos contiene un ciclo.',1;
END;
GO

/* SOURCE: 08_Triggers.sql */
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
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Cat_Carrera; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Cat_Carrera_Integridad ON App.Cat_Carrera AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Cat_DiaSemana; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Cat_DiaSemana_Integridad ON App.Cat_DiaSemana AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM deleted) THROW 51305,N'Los dominios iniciales de días y estados son inmutables; use despliegue controlado.',1;
EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Cat_EstatusAcademico; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Cat_EstatusAcademico_Integridad ON App.Cat_EstatusAcademico AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM deleted) THROW 51305,N'Los dominios iniciales de días y estados son inmutables; use despliegue controlado.',1;
EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Cat_Materia; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Cat_Materia_Integridad ON App.Cat_Materia AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Cat_Reticula; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Cat_Reticula_Integridad ON App.Cat_Reticula AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM inserted I JOIN deleted D ON D.nIdReticula=I.nIdReticula
 JOIN App.Tbl_TrayectoriaEstudiante T WITH (READCOMMITTEDLOCK) ON T.nIdReticula=I.nIdReticula WHERE I.nIdCarrera<>D.nIdCarrera)
 THROW 51304,N'No se puede cambiar la carrera de una retícula utilizada.',1;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Cat_TipoAula; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Cat_TipoAula_Integridad ON App.Cat_TipoAula AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_Aula; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_Aula_Integridad ON App.Tbl_Aula AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_Docente; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_Docente_Integridad ON App.Tbl_Docente AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_Estudiante; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_Estudiante_Integridad ON App.Tbl_Estudiante AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_Grupo; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_Grupo_Integridad ON App.Tbl_Grupo AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM (SELECT nIdPeriodo FROM inserted UNION SELECT nIdPeriodo FROM deleted) X
 JOIN App.Tbl_PeriodoAcademico P WITH (READCOMMITTEDLOCK) ON P.nIdPeriodo=X.nIdPeriodo WHERE P.nOfertaPublicada=1)
 THROW 51300,N'La oferta publicada no admite cambios en grupos.',1;
EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_HistorialAcademico; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_HistorialAcademico_Integridad ON App.Tbl_HistorialAcademico AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_HorarioGeneradoDetalle; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_HorarioGeneradoDetalle_Integridad ON App.Tbl_HorarioGeneradoDetalle AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM (SELECT nIdHorarioGenerado FROM inserted UNION SELECT nIdHorarioGenerado FROM deleted) X
 JOIN App.Tbl_HorarioGenerado H WITH (READCOMMITTEDLOCK) ON H.nIdHorarioGenerado=X.nIdHorarioGenerado WHERE H.nConfirmado=1)
 THROW 51306,N'El detalle de un horario confirmado es inmutable.',1;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_HorarioGenerado; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_HorarioGenerado_Integridad ON App.Tbl_HorarioGenerado AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM deleted D LEFT JOIN inserted I ON I.nIdHorarioGenerado=D.nIdHorarioGenerado
 WHERE D.nConfirmado=1 AND (I.nIdHorarioGenerado IS NULL OR I.nConfirmado=0 OR I.nIdTrayectoria<>D.nIdTrayectoria
 OR I.nIdPeriodo<>D.nIdPeriodo OR I.dFechaRegistro<>D.dFechaRegistro))
 THROW 51307,N'Un horario confirmado conserva su identidad académica y no se elimina.',1;
 IF EXISTS (SELECT 1 FROM inserted I LEFT JOIN deleted D ON D.nIdHorarioGenerado=I.nIdHorarioGenerado
 JOIN App.Tbl_PeriodoAcademico P WITH (READCOMMITTEDLOCK) ON P.nIdPeriodo=I.nIdPeriodo
 JOIN App.Tbl_TrayectoriaEstudiante T WITH (READCOMMITTEDLOCK) ON T.nIdTrayectoria=I.nIdTrayectoria
 WHERE I.nSeleccionado=1 AND COALESCE(D.nSeleccionado,0)=0 AND (P.nActivoGeneracion=0 OR P.nOfertaPublicada=0 OR T.dFechaFin IS NOT NULL))
 THROW 51100,N'Solo se seleccionan opciones del periodo activo y trayectoria vigente.',1;
 DECLARE @nId int;
 DECLARE C CURSOR LOCAL FAST_FORWARD FOR SELECT I.nIdHorarioGenerado FROM inserted I
 LEFT JOIN deleted D ON D.nIdHorarioGenerado=I.nIdHorarioGenerado WHERE I.nConfirmado=1 AND COALESCE(D.nConfirmado,0)=0;
 OPEN C; FETCH NEXT FROM C INTO @nId;
 WHILE @@FETCH_STATUS=0 BEGIN EXEC App.Sp_ValidarHorario @nId; FETCH NEXT FROM C INTO @nId; END;
 CLOSE C; DEALLOCATE C;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_MateriaPrerrequisito; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_MateriaPrerrequisito_Integridad ON App.Tbl_MateriaPrerrequisito AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM (SELECT nIdReticula FROM inserted UNION SELECT nIdReticula FROM deleted) X
 JOIN App.Tbl_TrayectoriaEstudiante T WITH (READCOMMITTEDLOCK) ON T.nIdReticula=X.nIdReticula
 JOIN App.Tbl_HorarioGenerado H WITH (READCOMMITTEDLOCK) ON H.nIdTrayectoria=T.nIdTrayectoria WHERE H.nConfirmado=1)
 THROW 51301,N'El plan tiene horarios confirmados; cree una nueva versión curricular.',1;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_PeriodoAcademico; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_PeriodoAcademico_Integridad ON App.Tbl_PeriodoAcademico AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM inserted I JOIN deleted D ON D.nIdPeriodo=I.nIdPeriodo
 WHERE D.nOfertaPublicada=1 AND (I.dFechaInicio<>D.dFechaInicio OR I.dFechaFin<>D.dFechaFin))
 THROW 51302,N'No cambie fechas de un periodo publicado.',1;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_ReticulaMateria; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_ReticulaMateria_Integridad ON App.Tbl_ReticulaMateria AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM (SELECT nIdReticula FROM inserted UNION SELECT nIdReticula FROM deleted) X
 JOIN App.Tbl_TrayectoriaEstudiante T WITH (READCOMMITTEDLOCK) ON T.nIdReticula=X.nIdReticula
 JOIN App.Tbl_HorarioGenerado H WITH (READCOMMITTEDLOCK) ON H.nIdTrayectoria=T.nIdTrayectoria WHERE H.nConfirmado=1)
 THROW 51301,N'El plan tiene horarios confirmados; cree una nueva versión curricular.',1;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_SesionGrupo; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_SesionGrupo_Integridad ON App.Tbl_SesionGrupo AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM (SELECT nIdGrupo FROM inserted UNION SELECT nIdGrupo FROM deleted) X
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=X.nIdGrupo
 JOIN App.Tbl_PeriodoAcademico P WITH (READCOMMITTEDLOCK) ON P.nIdPeriodo=G.nIdPeriodo WHERE P.nOfertaPublicada=1)
 THROW 51300,N'La oferta publicada no admite cambios en sesiones.',1;
EXEC App.Sp_ValidarIntegridadOferta;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Guard de App.Tbl_TrayectoriaEstudiante; cubre DML de una o múltiples filas. */
CREATE   TRIGGER App.Tr_Tbl_TrayectoriaEstudiante_Integridad ON App.Tbl_TrayectoriaEstudiante AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM inserted I JOIN deleted D ON D.nIdTrayectoria=I.nIdTrayectoria
 JOIN App.Tbl_HorarioGenerado H WITH (READCOMMITTEDLOCK) ON H.nIdTrayectoria=I.nIdTrayectoria
 WHERE H.nConfirmado=1 AND (I.nIdReticula<>D.nIdReticula OR I.nIdEstudiante<>D.nIdEstudiante))
 THROW 51303,N'La trayectoria usada por horarios confirmados conserva estudiante y retícula.',1;
 EXEC App.Sp_ValidarIntegridadOferta;
END;
GO

/* SOURCE: 09_Seguridad_sin_credenciales.sql */
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
