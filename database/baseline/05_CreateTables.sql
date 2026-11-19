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
/* Objeto: App.Tbl_Usuario. Usuario compatible con Identity de clave int. */
IF OBJECT_ID(N'App.Tbl_Usuario',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_Usuario (
 [nIdUsuario] int IDENTITY(1,1) NOT NULL,
 [cNombreUsuario] nvarchar(256) NOT NULL,
 [cNombreUsuarioNormalizado] nvarchar(256) NOT NULL,
 [cCorreo] nvarchar(256) NULL,
 [cCorreoNormalizado] nvarchar(256) NULL,
 [nCorreoConfirmado] bit NOT NULL,
 [cPasswordHash] nvarchar(max) NULL,
 [cSecurityStamp] nvarchar(64) NULL,
 [cConcurrencyStamp] nvarchar(64) NULL,
 [cTelefono] nvarchar(50) NULL,
 [nTelefonoConfirmado] bit NOT NULL,
 [nDosFactoresHabilitados] bit NOT NULL,
 [dFinBloqueo] datetimeoffset(0) NULL,
 [nBloqueoHabilitado] bit NOT NULL,
 [nIntentosFallidos] int NOT NULL,
 [nEstatus] bit NOT NULL,
 [dFechaRegistro] datetime2(0) NOT NULL
);
END;
GO
/* Objeto: App.Tbl_UsuarioRol. Relación N:M de usuarios y roles. */
IF OBJECT_ID(N'App.Tbl_UsuarioRol',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_UsuarioRol (
 [nIdUsuario] int NOT NULL,
 [nIdRol] int NOT NULL
);
END;
GO
/* Objeto: App.Tbl_UsuarioClaim. Claims de Usuario */
IF OBJECT_ID(N'App.Tbl_UsuarioClaim',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_UsuarioClaim (
 [nIdUsuarioClaim] int IDENTITY(1,1) NOT NULL,
 [nIdUsuario] int NOT NULL,
 [cTipoClaim] nvarchar(max) NULL,
 [cValorClaim] nvarchar(max) NULL
);
END;
GO
/* Objeto: App.Tbl_RolClaim. Claims de Rol */
IF OBJECT_ID(N'App.Tbl_RolClaim',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_RolClaim (
 [nIdRolClaim] int IDENTITY(1,1) NOT NULL,
 [nIdRol] int NOT NULL,
 [cTipoClaim] nvarchar(max) NULL,
 [cValorClaim] nvarchar(max) NULL
);
END;
GO
/* Objeto: App.Tbl_UsuarioLogin. Inicio de sesión externo de Identity. */
IF OBJECT_ID(N'App.Tbl_UsuarioLogin',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_UsuarioLogin (
 [cProveedorLogin] nvarchar(128) NOT NULL,
 [cClaveProveedor] nvarchar(128) NOT NULL,
 [cNombreProveedor] nvarchar(128) NULL,
 [nIdUsuario] int NOT NULL
);
END;
GO
/* Objeto: App.Tbl_UsuarioToken. Tokens de Identity; evitar exposición y proteger en el backend. */
IF OBJECT_ID(N'App.Tbl_UsuarioToken',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_UsuarioToken (
 [nIdUsuario] int NOT NULL,
 [cProveedorLogin] nvarchar(128) NOT NULL,
 [cNombre] nvarchar(128) NOT NULL,
 [cValor] nvarchar(max) NULL
);
END;
GO
/* Objeto: App.Tbl_Estudiante. Identidad académica independiente del plan. */
IF OBJECT_ID(N'App.Tbl_Estudiante',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_Estudiante (
 [nIdEstudiante] int IDENTITY(1,1) NOT NULL,
 [nIdUsuario] int NOT NULL,
 [cNumeroControl] varchar(25) NOT NULL,
 [nEstatus] bit NOT NULL
);
END;
GO
/* Objeto: App.Tbl_TrayectoriaEstudiante. Asignación temporal de retícula que conserva cambios de carrera. */
IF OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_TrayectoriaEstudiante (
 [nIdTrayectoria] int IDENTITY(1,1) NOT NULL,
 [nIdEstudiante] int NOT NULL,
 [nIdReticula] int NOT NULL,
 [nSemestreActual] tinyint NOT NULL,
 [nLimiteCreditos] smallint NOT NULL,
 [dFechaInicio] date NOT NULL,
 [dFechaFin] date NULL
);
END;
GO
/* Objeto: App.Tbl_Docente. Perfil laboral; usuario opcional sin duplicar credenciales. */
IF OBJECT_ID(N'App.Tbl_Docente',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_Docente (
 [nIdDocente] int IDENTITY(1,1) NOT NULL,
 [nIdUsuario] int NULL,
 [cNumeroEmpleado] varchar(25) NOT NULL,
 [cNombre] nvarchar(150) NOT NULL,
 [nEstatus] bit NOT NULL
);
END;
GO
/* Objeto: App.Tbl_Aula. Recurso físico de enseñanza. */
IF OBJECT_ID(N'App.Tbl_Aula',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_Aula (
 [nIdAula] int IDENTITY(1,1) NOT NULL,
 [nIdTipoAula] int NOT NULL,
 [cClave] varchar(30) NOT NULL,
 [nCapacidad] smallint NOT NULL,
 [nEstatus] bit NOT NULL
);
END;
GO
/* Objeto: App.Tbl_ReticulaMateria. Atributos dependientes del par retícula-materia. */
IF OBJECT_ID(N'App.Tbl_ReticulaMateria',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_ReticulaMateria (
 [nIdReticula] int NOT NULL,
 [nIdMateria] int NOT NULL,
 [nSemestreRecomendado] tinyint NOT NULL,
 [nCreditos] tinyint NOT NULL,
 [nObligatoria] bit NOT NULL
);
END;
GO
/* Objeto: App.Tbl_MateriaPrerrequisito. Arista del grafo de materias de una retícula. */
IF OBJECT_ID(N'App.Tbl_MateriaPrerrequisito',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_MateriaPrerrequisito (
 [nIdReticula] int NOT NULL,
 [nIdMateria] int NOT NULL,
 [nIdMateriaPrerrequisito] int NOT NULL,
 [nObligatorio] bit NOT NULL
);
END;
GO
/* Objeto: App.Tbl_PeriodoAcademico. Ciclo y publicación de oferta. */
IF OBJECT_ID(N'App.Tbl_PeriodoAcademico',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_PeriodoAcademico (
 [nIdPeriodo] int IDENTITY(1,1) NOT NULL,
 [cClave] varchar(20) NOT NULL,
 [cNombre] nvarchar(100) NOT NULL,
 [dFechaInicio] date NOT NULL,
 [dFechaFin] date NOT NULL,
 [nActivoGeneracion] bit NOT NULL,
 [nOfertaPublicada] bit NOT NULL
);
END;
GO
/* Objeto: App.Tbl_Grupo. Oferta de una materia por periodo. */
IF OBJECT_ID(N'App.Tbl_Grupo',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_Grupo (
 [nIdGrupo] int IDENTITY(1,1) NOT NULL,
 [nIdMateria] int NOT NULL,
 [nIdDocente] int NULL,
 [nIdPeriodo] int NOT NULL,
 [cClaveGrupo] varchar(20) NOT NULL,
 [nEstatus] bit NOT NULL
);
END;
GO
/* Objeto: App.Tbl_SesionGrupo. Una reunión semanal, intervalo [inicio, fin). */
IF OBJECT_ID(N'App.Tbl_SesionGrupo',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_SesionGrupo (
 [nIdSesionGrupo] int IDENTITY(1,1) NOT NULL,
 [nIdGrupo] int NOT NULL,
 [nIdDiaSemana] tinyint NOT NULL,
 [nIdAula] int NOT NULL,
 [dHoraInicio] time(0) NOT NULL,
 [dHoraFin] time(0) NOT NULL
);
END;
GO
/* Objeto: App.Tbl_HistorialAcademico. Un intento por estudiante/materia/periodo; admite recursamientos. */
IF OBJECT_ID(N'App.Tbl_HistorialAcademico',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_HistorialAcademico (
 [nIdHistorialAcademico] bigint IDENTITY(1,1) NOT NULL,
 [nIdEstudiante] int NOT NULL,
 [nIdMateria] int NOT NULL,
 [nIdPeriodo] int NULL,
 [nIdEstatusAcademico] tinyint NOT NULL,
 [nCalificacion] decimal(5,2) NULL,
 [dFechaRegistro] datetime2(0) NOT NULL
);
END;
GO
/* Objeto: App.Tbl_HorarioGenerado. Opción en borrador o confirmada para una trayectoria. */
IF OBJECT_ID(N'App.Tbl_HorarioGenerado',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_HorarioGenerado (
 [nIdHorarioGenerado] int IDENTITY(1,1) NOT NULL,
 [nIdTrayectoria] int NOT NULL,
 [nIdPeriodo] int NOT NULL,
 [cNombre] nvarchar(100) NOT NULL,
 [nConfirmado] bit NOT NULL,
 [nSeleccionado] bit NOT NULL,
 [dFechaRegistro] datetime2(0) NOT NULL
);
END;
GO
/* Objeto: App.Tbl_HorarioGeneradoDetalle. Un grupo por fila; sin atributos derivados. */
IF OBJECT_ID(N'App.Tbl_HorarioGeneradoDetalle',N'U') IS NULL
BEGIN
CREATE TABLE App.Tbl_HorarioGeneradoDetalle (
 [nIdHorarioGenerado] int NOT NULL,
 [nIdGrupo] int NOT NULL
);
END;
GO
