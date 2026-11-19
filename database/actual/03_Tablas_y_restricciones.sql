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
