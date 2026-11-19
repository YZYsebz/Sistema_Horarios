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
/* PK_Cat_Rol */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Rol') AND name=N'PK_Cat_Rol')
 ALTER TABLE App.Cat_Rol ADD CONSTRAINT [PK_Cat_Rol] PRIMARY KEY (nIdRol);
GO
/* PK_Cat_Carrera */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Carrera') AND name=N'PK_Cat_Carrera')
 ALTER TABLE App.Cat_Carrera ADD CONSTRAINT [PK_Cat_Carrera] PRIMARY KEY (nIdCarrera);
GO
/* PK_Cat_Materia */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Materia') AND name=N'PK_Cat_Materia')
 ALTER TABLE App.Cat_Materia ADD CONSTRAINT [PK_Cat_Materia] PRIMARY KEY (nIdMateria);
GO
/* PK_Cat_TipoAula */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_TipoAula') AND name=N'PK_Cat_TipoAula')
 ALTER TABLE App.Cat_TipoAula ADD CONSTRAINT [PK_Cat_TipoAula] PRIMARY KEY (nIdTipoAula);
GO
/* PK_Cat_Reticula */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Reticula') AND name=N'PK_Cat_Reticula')
 ALTER TABLE App.Cat_Reticula ADD CONSTRAINT [PK_Cat_Reticula] PRIMARY KEY (nIdReticula);
GO
/* PK_Cat_DiaSemana */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_DiaSemana') AND name=N'PK_Cat_DiaSemana')
 ALTER TABLE App.Cat_DiaSemana ADD CONSTRAINT [PK_Cat_DiaSemana] PRIMARY KEY (nIdDiaSemana);
GO
/* PK_Cat_EstatusAcademico */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_EstatusAcademico') AND name=N'PK_Cat_EstatusAcademico')
 ALTER TABLE App.Cat_EstatusAcademico ADD CONSTRAINT [PK_Cat_EstatusAcademico] PRIMARY KEY (nIdEstatusAcademico);
GO
/* PK_Tbl_Usuario */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'PK_Tbl_Usuario')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [PK_Tbl_Usuario] PRIMARY KEY (nIdUsuario);
GO
/* PK_Tbl_UsuarioRol */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioRol') AND name=N'PK_Tbl_UsuarioRol')
 ALTER TABLE App.Tbl_UsuarioRol ADD CONSTRAINT [PK_Tbl_UsuarioRol] PRIMARY KEY (nIdUsuario,nIdRol);
GO
/* PK_Tbl_UsuarioClaim */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioClaim') AND name=N'PK_Tbl_UsuarioClaim')
 ALTER TABLE App.Tbl_UsuarioClaim ADD CONSTRAINT [PK_Tbl_UsuarioClaim] PRIMARY KEY (nIdUsuarioClaim);
GO
/* PK_Tbl_RolClaim */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_RolClaim') AND name=N'PK_Tbl_RolClaim')
 ALTER TABLE App.Tbl_RolClaim ADD CONSTRAINT [PK_Tbl_RolClaim] PRIMARY KEY (nIdRolClaim);
GO
/* PK_Tbl_UsuarioLogin */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioLogin') AND name=N'PK_Tbl_UsuarioLogin')
 ALTER TABLE App.Tbl_UsuarioLogin ADD CONSTRAINT [PK_Tbl_UsuarioLogin] PRIMARY KEY (cProveedorLogin,cClaveProveedor);
GO
/* PK_Tbl_UsuarioToken */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioToken') AND name=N'PK_Tbl_UsuarioToken')
 ALTER TABLE App.Tbl_UsuarioToken ADD CONSTRAINT [PK_Tbl_UsuarioToken] PRIMARY KEY (nIdUsuario,cProveedorLogin,cNombre);
GO
/* PK_Tbl_Estudiante */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Estudiante') AND name=N'PK_Tbl_Estudiante')
 ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT [PK_Tbl_Estudiante] PRIMARY KEY (nIdEstudiante);
GO
/* PK_Tbl_TrayectoriaEstudiante */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante') AND name=N'PK_Tbl_TrayectoriaEstudiante')
 ALTER TABLE App.Tbl_TrayectoriaEstudiante ADD CONSTRAINT [PK_Tbl_TrayectoriaEstudiante] PRIMARY KEY (nIdTrayectoria);
GO
/* PK_Tbl_Docente */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Docente') AND name=N'PK_Tbl_Docente')
 ALTER TABLE App.Tbl_Docente ADD CONSTRAINT [PK_Tbl_Docente] PRIMARY KEY (nIdDocente);
GO
/* PK_Tbl_Aula */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Aula') AND name=N'PK_Tbl_Aula')
 ALTER TABLE App.Tbl_Aula ADD CONSTRAINT [PK_Tbl_Aula] PRIMARY KEY (nIdAula);
GO
/* PK_Tbl_ReticulaMateria */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_ReticulaMateria') AND name=N'PK_Tbl_ReticulaMateria')
 ALTER TABLE App.Tbl_ReticulaMateria ADD CONSTRAINT [PK_Tbl_ReticulaMateria] PRIMARY KEY (nIdReticula,nIdMateria);
GO
/* PK_Tbl_MateriaPrerrequisito */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_MateriaPrerrequisito') AND name=N'PK_Tbl_MateriaPrerrequisito')
 ALTER TABLE App.Tbl_MateriaPrerrequisito ADD CONSTRAINT [PK_Tbl_MateriaPrerrequisito] PRIMARY KEY (nIdReticula,nIdMateria,nIdMateriaPrerrequisito);
GO
/* PK_Tbl_PeriodoAcademico */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_PeriodoAcademico') AND name=N'PK_Tbl_PeriodoAcademico')
 ALTER TABLE App.Tbl_PeriodoAcademico ADD CONSTRAINT [PK_Tbl_PeriodoAcademico] PRIMARY KEY (nIdPeriodo);
GO
/* PK_Tbl_Grupo */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Grupo') AND name=N'PK_Tbl_Grupo')
 ALTER TABLE App.Tbl_Grupo ADD CONSTRAINT [PK_Tbl_Grupo] PRIMARY KEY (nIdGrupo);
GO
/* PK_Tbl_SesionGrupo */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_SesionGrupo') AND name=N'PK_Tbl_SesionGrupo')
 ALTER TABLE App.Tbl_SesionGrupo ADD CONSTRAINT [PK_Tbl_SesionGrupo] PRIMARY KEY (nIdSesionGrupo);
GO
/* PK_Tbl_HistorialAcademico */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'PK_Tbl_HistorialAcademico')
 ALTER TABLE App.Tbl_HistorialAcademico ADD CONSTRAINT [PK_Tbl_HistorialAcademico] PRIMARY KEY (nIdHistorialAcademico);
GO
/* PK_Tbl_HorarioGenerado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'PK_Tbl_HorarioGenerado')
 ALTER TABLE App.Tbl_HorarioGenerado ADD CONSTRAINT [PK_Tbl_HorarioGenerado] PRIMARY KEY (nIdHorarioGenerado);
GO
/* PK_Tbl_HorarioGeneradoDetalle */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGeneradoDetalle') AND name=N'PK_Tbl_HorarioGeneradoDetalle')
 ALTER TABLE App.Tbl_HorarioGeneradoDetalle ADD CONSTRAINT [PK_Tbl_HorarioGeneradoDetalle] PRIMARY KEY (nIdHorarioGenerado,nIdGrupo);
GO
/* CK_Cat_Rol_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Rol') AND name=N'CK_Cat_Rol_cNombre_NoVacio')
 ALTER TABLE App.Cat_Rol ADD CONSTRAINT [CK_Cat_Rol_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* DF_Cat_Carrera_nEstatus */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Carrera') AND name=N'DF_Cat_Carrera_nEstatus')
 ALTER TABLE App.Cat_Carrera ADD CONSTRAINT [DF_Cat_Carrera_nEstatus] DEFAULT (1) FOR nEstatus;
GO
/* CK_Cat_Carrera_cClave_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Carrera') AND name=N'CK_Cat_Carrera_cClave_NoVacio')
 ALTER TABLE App.Cat_Carrera ADD CONSTRAINT [CK_Cat_Carrera_cClave_NoVacio] CHECK (LEN(LTRIM(RTRIM(cClave))) > 0);
GO
/* CK_Cat_Carrera_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Carrera') AND name=N'CK_Cat_Carrera_cNombre_NoVacio')
 ALTER TABLE App.Cat_Carrera ADD CONSTRAINT [CK_Cat_Carrera_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* DF_Cat_Materia_nEstatus */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Materia') AND name=N'DF_Cat_Materia_nEstatus')
 ALTER TABLE App.Cat_Materia ADD CONSTRAINT [DF_Cat_Materia_nEstatus] DEFAULT (1) FOR nEstatus;
GO
/* CK_Cat_Materia_cClave_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Materia') AND name=N'CK_Cat_Materia_cClave_NoVacio')
 ALTER TABLE App.Cat_Materia ADD CONSTRAINT [CK_Cat_Materia_cClave_NoVacio] CHECK (LEN(LTRIM(RTRIM(cClave))) > 0);
GO
/* CK_Cat_Materia_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Materia') AND name=N'CK_Cat_Materia_cNombre_NoVacio')
 ALTER TABLE App.Cat_Materia ADD CONSTRAINT [CK_Cat_Materia_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* DF_Cat_TipoAula_nEstatus */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_TipoAula') AND name=N'DF_Cat_TipoAula_nEstatus')
 ALTER TABLE App.Cat_TipoAula ADD CONSTRAINT [DF_Cat_TipoAula_nEstatus] DEFAULT (1) FOR nEstatus;
GO
/* CK_Cat_TipoAula_cClave_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_TipoAula') AND name=N'CK_Cat_TipoAula_cClave_NoVacio')
 ALTER TABLE App.Cat_TipoAula ADD CONSTRAINT [CK_Cat_TipoAula_cClave_NoVacio] CHECK (LEN(LTRIM(RTRIM(cClave))) > 0);
GO
/* CK_Cat_TipoAula_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_TipoAula') AND name=N'CK_Cat_TipoAula_cNombre_NoVacio')
 ALTER TABLE App.Cat_TipoAula ADD CONSTRAINT [CK_Cat_TipoAula_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* DF_Cat_Reticula_nEstatus */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Reticula') AND name=N'DF_Cat_Reticula_nEstatus')
 ALTER TABLE App.Cat_Reticula ADD CONSTRAINT [DF_Cat_Reticula_nEstatus] DEFAULT (1) FOR nEstatus;
GO
/* CK_Cat_Reticula_cClave_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Reticula') AND name=N'CK_Cat_Reticula_cClave_NoVacio')
 ALTER TABLE App.Cat_Reticula ADD CONSTRAINT [CK_Cat_Reticula_cClave_NoVacio] CHECK (LEN(LTRIM(RTRIM(cClave))) > 0);
GO
/* CK_Cat_Reticula_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Reticula') AND name=N'CK_Cat_Reticula_cNombre_NoVacio')
 ALTER TABLE App.Cat_Reticula ADD CONSTRAINT [CK_Cat_Reticula_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* CK_Cat_DiaSemana_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_DiaSemana') AND name=N'CK_Cat_DiaSemana_cNombre_NoVacio')
 ALTER TABLE App.Cat_DiaSemana ADD CONSTRAINT [CK_Cat_DiaSemana_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* CK_Cat_EstatusAcademico_cClave_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_EstatusAcademico') AND name=N'CK_Cat_EstatusAcademico_cClave_NoVacio')
 ALTER TABLE App.Cat_EstatusAcademico ADD CONSTRAINT [CK_Cat_EstatusAcademico_cClave_NoVacio] CHECK (LEN(LTRIM(RTRIM(cClave))) > 0);
GO
/* CK_Cat_EstatusAcademico_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_EstatusAcademico') AND name=N'CK_Cat_EstatusAcademico_cNombre_NoVacio')
 ALTER TABLE App.Cat_EstatusAcademico ADD CONSTRAINT [CK_Cat_EstatusAcademico_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* DF_Tbl_Usuario_nEstatus */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'DF_Tbl_Usuario_nEstatus')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [DF_Tbl_Usuario_nEstatus] DEFAULT (1) FOR nEstatus;
GO
/* DF_Tbl_Usuario_dFechaRegistro */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'DF_Tbl_Usuario_dFechaRegistro')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [DF_Tbl_Usuario_dFechaRegistro] DEFAULT (SYSUTCDATETIME()) FOR dFechaRegistro;
GO
/* CK_Tbl_Usuario_cNombreUsuario_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'CK_Tbl_Usuario_cNombreUsuario_NoVacio')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [CK_Tbl_Usuario_cNombreUsuario_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombreUsuario))) > 0);
GO
/* CK_Tbl_Usuario_cNombreUsuarioNormalizado_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'CK_Tbl_Usuario_cNombreUsuarioNormalizado_NoVacio')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [CK_Tbl_Usuario_cNombreUsuarioNormalizado_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombreUsuarioNormalizado))) > 0);
GO
/* CK_Tbl_UsuarioToken_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioToken') AND name=N'CK_Tbl_UsuarioToken_cNombre_NoVacio')
 ALTER TABLE App.Tbl_UsuarioToken ADD CONSTRAINT [CK_Tbl_UsuarioToken_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* DF_Tbl_Estudiante_nEstatus */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Estudiante') AND name=N'DF_Tbl_Estudiante_nEstatus')
 ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT [DF_Tbl_Estudiante_nEstatus] DEFAULT (1) FOR nEstatus;
GO
/* CK_Tbl_Estudiante_cNumeroControl_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Estudiante') AND name=N'CK_Tbl_Estudiante_cNumeroControl_NoVacio')
 ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT [CK_Tbl_Estudiante_cNumeroControl_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNumeroControl))) > 0);
GO
/* DF_Tbl_Docente_nEstatus */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Docente') AND name=N'DF_Tbl_Docente_nEstatus')
 ALTER TABLE App.Tbl_Docente ADD CONSTRAINT [DF_Tbl_Docente_nEstatus] DEFAULT (1) FOR nEstatus;
GO
/* CK_Tbl_Docente_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Docente') AND name=N'CK_Tbl_Docente_cNombre_NoVacio')
 ALTER TABLE App.Tbl_Docente ADD CONSTRAINT [CK_Tbl_Docente_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* CK_Tbl_Docente_cNumeroEmpleado_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Docente') AND name=N'CK_Tbl_Docente_cNumeroEmpleado_NoVacio')
 ALTER TABLE App.Tbl_Docente ADD CONSTRAINT [CK_Tbl_Docente_cNumeroEmpleado_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNumeroEmpleado))) > 0);
GO
/* DF_Tbl_Aula_nEstatus */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Aula') AND name=N'DF_Tbl_Aula_nEstatus')
 ALTER TABLE App.Tbl_Aula ADD CONSTRAINT [DF_Tbl_Aula_nEstatus] DEFAULT (1) FOR nEstatus;
GO
/* CK_Tbl_Aula_cClave_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Aula') AND name=N'CK_Tbl_Aula_cClave_NoVacio')
 ALTER TABLE App.Tbl_Aula ADD CONSTRAINT [CK_Tbl_Aula_cClave_NoVacio] CHECK (LEN(LTRIM(RTRIM(cClave))) > 0);
GO
/* CK_Tbl_PeriodoAcademico_cClave_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_PeriodoAcademico') AND name=N'CK_Tbl_PeriodoAcademico_cClave_NoVacio')
 ALTER TABLE App.Tbl_PeriodoAcademico ADD CONSTRAINT [CK_Tbl_PeriodoAcademico_cClave_NoVacio] CHECK (LEN(LTRIM(RTRIM(cClave))) > 0);
GO
/* CK_Tbl_PeriodoAcademico_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_PeriodoAcademico') AND name=N'CK_Tbl_PeriodoAcademico_cNombre_NoVacio')
 ALTER TABLE App.Tbl_PeriodoAcademico ADD CONSTRAINT [CK_Tbl_PeriodoAcademico_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* DF_Tbl_Grupo_nEstatus */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Grupo') AND name=N'DF_Tbl_Grupo_nEstatus')
 ALTER TABLE App.Tbl_Grupo ADD CONSTRAINT [DF_Tbl_Grupo_nEstatus] DEFAULT (1) FOR nEstatus;
GO
/* CK_Tbl_Grupo_cClaveGrupo_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Grupo') AND name=N'CK_Tbl_Grupo_cClaveGrupo_NoVacio')
 ALTER TABLE App.Tbl_Grupo ADD CONSTRAINT [CK_Tbl_Grupo_cClaveGrupo_NoVacio] CHECK (LEN(LTRIM(RTRIM(cClaveGrupo))) > 0);
GO
/* DF_Tbl_HistorialAcademico_dFechaRegistro */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'DF_Tbl_HistorialAcademico_dFechaRegistro')
 ALTER TABLE App.Tbl_HistorialAcademico ADD CONSTRAINT [DF_Tbl_HistorialAcademico_dFechaRegistro] DEFAULT (SYSUTCDATETIME()) FOR dFechaRegistro;
GO
/* DF_Tbl_HorarioGenerado_dFechaRegistro */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'DF_Tbl_HorarioGenerado_dFechaRegistro')
 ALTER TABLE App.Tbl_HorarioGenerado ADD CONSTRAINT [DF_Tbl_HorarioGenerado_dFechaRegistro] DEFAULT (SYSUTCDATETIME()) FOR dFechaRegistro;
GO
/* CK_Tbl_HorarioGenerado_cNombre_NoVacio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'CK_Tbl_HorarioGenerado_cNombre_NoVacio')
 ALTER TABLE App.Tbl_HorarioGenerado ADD CONSTRAINT [CK_Tbl_HorarioGenerado_cNombre_NoVacio] CHECK (LEN(LTRIM(RTRIM(cNombre))) > 0);
GO
/* UQ_Cat_Carrera_cClave */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Carrera') AND name=N'UQ_Cat_Carrera_cClave')
 ALTER TABLE App.Cat_Carrera ADD CONSTRAINT [UQ_Cat_Carrera_cClave] UNIQUE (cClave);
GO
/* UQ_Cat_Reticula_cClave */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Reticula') AND name=N'UQ_Cat_Reticula_cClave')
 ALTER TABLE App.Cat_Reticula ADD CONSTRAINT [UQ_Cat_Reticula_cClave] UNIQUE (cClave);
GO
/* UQ_Cat_Materia_cClave */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Materia') AND name=N'UQ_Cat_Materia_cClave')
 ALTER TABLE App.Cat_Materia ADD CONSTRAINT [UQ_Cat_Materia_cClave] UNIQUE (cClave);
GO
/* UQ_Cat_TipoAula_cClave */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_TipoAula') AND name=N'UQ_Cat_TipoAula_cClave')
 ALTER TABLE App.Cat_TipoAula ADD CONSTRAINT [UQ_Cat_TipoAula_cClave] UNIQUE (cClave);
GO
/* UQ_Cat_Rol_cNombreNormalizado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Rol') AND name=N'UQ_Cat_Rol_cNombreNormalizado')
 ALTER TABLE App.Cat_Rol ADD CONSTRAINT [UQ_Cat_Rol_cNombreNormalizado] UNIQUE (cNombreNormalizado);
GO
/* UQ_Cat_DiaSemana_cNombre */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_DiaSemana') AND name=N'UQ_Cat_DiaSemana_cNombre')
 ALTER TABLE App.Cat_DiaSemana ADD CONSTRAINT [UQ_Cat_DiaSemana_cNombre] UNIQUE (cNombre);
GO
/* UQ_Cat_EstatusAcademico_cClave */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_EstatusAcademico') AND name=N'UQ_Cat_EstatusAcademico_cClave')
 ALTER TABLE App.Cat_EstatusAcademico ADD CONSTRAINT [UQ_Cat_EstatusAcademico_cClave] UNIQUE (cClave);
GO
/* CK_Cat_DiaSemana_Dominio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_DiaSemana') AND name=N'CK_Cat_DiaSemana_Dominio')
 ALTER TABLE App.Cat_DiaSemana ADD CONSTRAINT [CK_Cat_DiaSemana_Dominio] CHECK (nIdDiaSemana BETWEEN 1 AND 7);
GO
/* CK_Cat_EstatusAcademico_Dominio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_EstatusAcademico') AND name=N'CK_Cat_EstatusAcademico_Dominio')
 ALTER TABLE App.Cat_EstatusAcademico ADD CONSTRAINT [CK_Cat_EstatusAcademico_Dominio] CHECK (cClave IN ('APROBADA','NO_APROBADA','CURSANDO','PENDIENTE'));
GO
/* FK_Cat_Reticula_Cat_Carrera */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Cat_Reticula') AND name=N'FK_Cat_Reticula_Cat_Carrera')
 ALTER TABLE App.Cat_Reticula ADD CONSTRAINT [FK_Cat_Reticula_Cat_Carrera] FOREIGN KEY (nIdCarrera) REFERENCES App.Cat_Carrera (nIdCarrera);
GO
/* UQ_Tbl_Usuario_cNombreUsuarioNormalizado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'UQ_Tbl_Usuario_cNombreUsuarioNormalizado')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [UQ_Tbl_Usuario_cNombreUsuarioNormalizado] UNIQUE (cNombreUsuarioNormalizado);
GO
/* DF_Tbl_Usuario_nCorreoConfirmado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'DF_Tbl_Usuario_nCorreoConfirmado')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [DF_Tbl_Usuario_nCorreoConfirmado] DEFAULT (0) FOR nCorreoConfirmado;
GO
/* DF_Tbl_Usuario_nTelefonoConfirmado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'DF_Tbl_Usuario_nTelefonoConfirmado')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [DF_Tbl_Usuario_nTelefonoConfirmado] DEFAULT (0) FOR nTelefonoConfirmado;
GO
/* DF_Tbl_Usuario_nDosFactoresHabilitados */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'DF_Tbl_Usuario_nDosFactoresHabilitados')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [DF_Tbl_Usuario_nDosFactoresHabilitados] DEFAULT (0) FOR nDosFactoresHabilitados;
GO
/* DF_Tbl_Usuario_nBloqueoHabilitado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'DF_Tbl_Usuario_nBloqueoHabilitado')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [DF_Tbl_Usuario_nBloqueoHabilitado] DEFAULT (0) FOR nBloqueoHabilitado;
GO
/* DF_Tbl_Usuario_nIntentosFallidos */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'DF_Tbl_Usuario_nIntentosFallidos')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [DF_Tbl_Usuario_nIntentosFallidos] DEFAULT (0) FOR nIntentosFallidos;
GO
/* CK_Tbl_Usuario_Intentos */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'CK_Tbl_Usuario_Intentos')
 ALTER TABLE App.Tbl_Usuario ADD CONSTRAINT [CK_Tbl_Usuario_Intentos] CHECK (nIntentosFallidos >= 0);
GO
/* FK_Tbl_UsuarioRol_Tbl_Usuario */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioRol') AND name=N'FK_Tbl_UsuarioRol_Tbl_Usuario')
 ALTER TABLE App.Tbl_UsuarioRol ADD CONSTRAINT [FK_Tbl_UsuarioRol_Tbl_Usuario] FOREIGN KEY (nIdUsuario) REFERENCES App.Tbl_Usuario (nIdUsuario);
GO
/* FK_Tbl_UsuarioClaim_Tbl_Usuario */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioClaim') AND name=N'FK_Tbl_UsuarioClaim_Tbl_Usuario')
 ALTER TABLE App.Tbl_UsuarioClaim ADD CONSTRAINT [FK_Tbl_UsuarioClaim_Tbl_Usuario] FOREIGN KEY (nIdUsuario) REFERENCES App.Tbl_Usuario (nIdUsuario);
GO
/* FK_Tbl_UsuarioLogin_Tbl_Usuario */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioLogin') AND name=N'FK_Tbl_UsuarioLogin_Tbl_Usuario')
 ALTER TABLE App.Tbl_UsuarioLogin ADD CONSTRAINT [FK_Tbl_UsuarioLogin_Tbl_Usuario] FOREIGN KEY (nIdUsuario) REFERENCES App.Tbl_Usuario (nIdUsuario);
GO
/* FK_Tbl_UsuarioToken_Tbl_Usuario */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioToken') AND name=N'FK_Tbl_UsuarioToken_Tbl_Usuario')
 ALTER TABLE App.Tbl_UsuarioToken ADD CONSTRAINT [FK_Tbl_UsuarioToken_Tbl_Usuario] FOREIGN KEY (nIdUsuario) REFERENCES App.Tbl_Usuario (nIdUsuario);
GO
/* FK_Tbl_Estudiante_Tbl_Usuario */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Estudiante') AND name=N'FK_Tbl_Estudiante_Tbl_Usuario')
 ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT [FK_Tbl_Estudiante_Tbl_Usuario] FOREIGN KEY (nIdUsuario) REFERENCES App.Tbl_Usuario (nIdUsuario);
GO
/* FK_Tbl_Docente_Tbl_Usuario */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Docente') AND name=N'FK_Tbl_Docente_Tbl_Usuario')
 ALTER TABLE App.Tbl_Docente ADD CONSTRAINT [FK_Tbl_Docente_Tbl_Usuario] FOREIGN KEY (nIdUsuario) REFERENCES App.Tbl_Usuario (nIdUsuario);
GO
/* FK_Tbl_UsuarioRol_Cat_Rol */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_UsuarioRol') AND name=N'FK_Tbl_UsuarioRol_Cat_Rol')
 ALTER TABLE App.Tbl_UsuarioRol ADD CONSTRAINT [FK_Tbl_UsuarioRol_Cat_Rol] FOREIGN KEY (nIdRol) REFERENCES App.Cat_Rol (nIdRol);
GO
/* FK_Tbl_RolClaim_Cat_Rol */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_RolClaim') AND name=N'FK_Tbl_RolClaim_Cat_Rol')
 ALTER TABLE App.Tbl_RolClaim ADD CONSTRAINT [FK_Tbl_RolClaim_Cat_Rol] FOREIGN KEY (nIdRol) REFERENCES App.Cat_Rol (nIdRol);
GO
/* UQ_Tbl_Estudiante_nIdUsuario */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Estudiante') AND name=N'UQ_Tbl_Estudiante_nIdUsuario')
 ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT [UQ_Tbl_Estudiante_nIdUsuario] UNIQUE (nIdUsuario);
GO
/* UQ_Tbl_Estudiante_cNumeroControl */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Estudiante') AND name=N'UQ_Tbl_Estudiante_cNumeroControl')
 ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT [UQ_Tbl_Estudiante_cNumeroControl] UNIQUE (cNumeroControl);
GO
/* UQ_Tbl_Docente_cNumeroEmpleado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Docente') AND name=N'UQ_Tbl_Docente_cNumeroEmpleado')
 ALTER TABLE App.Tbl_Docente ADD CONSTRAINT [UQ_Tbl_Docente_cNumeroEmpleado] UNIQUE (cNumeroEmpleado);
GO
/* FK_Tbl_TrayectoriaEstudiante_Tbl_Estudiante */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante') AND name=N'FK_Tbl_TrayectoriaEstudiante_Tbl_Estudiante')
 ALTER TABLE App.Tbl_TrayectoriaEstudiante ADD CONSTRAINT [FK_Tbl_TrayectoriaEstudiante_Tbl_Estudiante] FOREIGN KEY (nIdEstudiante) REFERENCES App.Tbl_Estudiante (nIdEstudiante);
GO
/* FK_Tbl_TrayectoriaEstudiante_Cat_Reticula */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante') AND name=N'FK_Tbl_TrayectoriaEstudiante_Cat_Reticula')
 ALTER TABLE App.Tbl_TrayectoriaEstudiante ADD CONSTRAINT [FK_Tbl_TrayectoriaEstudiante_Cat_Reticula] FOREIGN KEY (nIdReticula) REFERENCES App.Cat_Reticula (nIdReticula);
GO
/* CK_Tbl_TrayectoriaEstudiante_Semestre */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante') AND name=N'CK_Tbl_TrayectoriaEstudiante_Semestre')
 ALTER TABLE App.Tbl_TrayectoriaEstudiante ADD CONSTRAINT [CK_Tbl_TrayectoriaEstudiante_Semestre] CHECK (nSemestreActual BETWEEN 1 AND 30);
GO
/* CK_Tbl_TrayectoriaEstudiante_Creditos */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante') AND name=N'CK_Tbl_TrayectoriaEstudiante_Creditos')
 ALTER TABLE App.Tbl_TrayectoriaEstudiante ADD CONSTRAINT [CK_Tbl_TrayectoriaEstudiante_Creditos] CHECK (nLimiteCreditos > 0);
GO
/* CK_Tbl_TrayectoriaEstudiante_Fechas */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante') AND name=N'CK_Tbl_TrayectoriaEstudiante_Fechas')
 ALTER TABLE App.Tbl_TrayectoriaEstudiante ADD CONSTRAINT [CK_Tbl_TrayectoriaEstudiante_Fechas] CHECK (dFechaFin IS NULL OR dFechaFin >= dFechaInicio);
GO
/* FK_Tbl_Aula_Cat_TipoAula */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Aula') AND name=N'FK_Tbl_Aula_Cat_TipoAula')
 ALTER TABLE App.Tbl_Aula ADD CONSTRAINT [FK_Tbl_Aula_Cat_TipoAula] FOREIGN KEY (nIdTipoAula) REFERENCES App.Cat_TipoAula (nIdTipoAula);
GO
/* UQ_Tbl_Aula_cClave */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Aula') AND name=N'UQ_Tbl_Aula_cClave')
 ALTER TABLE App.Tbl_Aula ADD CONSTRAINT [UQ_Tbl_Aula_cClave] UNIQUE (cClave);
GO
/* CK_Tbl_Aula_Capacidad */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Aula') AND name=N'CK_Tbl_Aula_Capacidad')
 ALTER TABLE App.Tbl_Aula ADD CONSTRAINT [CK_Tbl_Aula_Capacidad] CHECK (nCapacidad > 0);
GO
/* FK_Tbl_ReticulaMateria_Cat_Reticula */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_ReticulaMateria') AND name=N'FK_Tbl_ReticulaMateria_Cat_Reticula')
 ALTER TABLE App.Tbl_ReticulaMateria ADD CONSTRAINT [FK_Tbl_ReticulaMateria_Cat_Reticula] FOREIGN KEY (nIdReticula) REFERENCES App.Cat_Reticula (nIdReticula);
GO
/* FK_Tbl_ReticulaMateria_Cat_Materia */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_ReticulaMateria') AND name=N'FK_Tbl_ReticulaMateria_Cat_Materia')
 ALTER TABLE App.Tbl_ReticulaMateria ADD CONSTRAINT [FK_Tbl_ReticulaMateria_Cat_Materia] FOREIGN KEY (nIdMateria) REFERENCES App.Cat_Materia (nIdMateria);
GO
/* CK_Tbl_ReticulaMateria_Creditos */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_ReticulaMateria') AND name=N'CK_Tbl_ReticulaMateria_Creditos')
 ALTER TABLE App.Tbl_ReticulaMateria ADD CONSTRAINT [CK_Tbl_ReticulaMateria_Creditos] CHECK (nCreditos BETWEEN 1 AND 100);
GO
/* CK_Tbl_ReticulaMateria_Semestre */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_ReticulaMateria') AND name=N'CK_Tbl_ReticulaMateria_Semestre')
 ALTER TABLE App.Tbl_ReticulaMateria ADD CONSTRAINT [CK_Tbl_ReticulaMateria_Semestre] CHECK (nSemestreRecomendado BETWEEN 1 AND 30);
GO
/* DF_Tbl_ReticulaMateria_nObligatoria */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_ReticulaMateria') AND name=N'DF_Tbl_ReticulaMateria_nObligatoria')
 ALTER TABLE App.Tbl_ReticulaMateria ADD CONSTRAINT [DF_Tbl_ReticulaMateria_nObligatoria] DEFAULT (1) FOR nObligatoria;
GO
/* FK_Tbl_MateriaPrerrequisito_Tbl_ReticulaMateria_Objetivo */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_MateriaPrerrequisito') AND name=N'FK_Tbl_MateriaPrerrequisito_Tbl_ReticulaMateria_Objetivo')
 ALTER TABLE App.Tbl_MateriaPrerrequisito ADD CONSTRAINT [FK_Tbl_MateriaPrerrequisito_Tbl_ReticulaMateria_Objetivo] FOREIGN KEY (nIdReticula,nIdMateria) REFERENCES App.Tbl_ReticulaMateria (nIdReticula,nIdMateria);
GO
/* FK_Tbl_MateriaPrerrequisito_Tbl_ReticulaMateria_Antecedente */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_MateriaPrerrequisito') AND name=N'FK_Tbl_MateriaPrerrequisito_Tbl_ReticulaMateria_Antecedente')
 ALTER TABLE App.Tbl_MateriaPrerrequisito ADD CONSTRAINT [FK_Tbl_MateriaPrerrequisito_Tbl_ReticulaMateria_Antecedente] FOREIGN KEY (nIdReticula,nIdMateriaPrerrequisito) REFERENCES App.Tbl_ReticulaMateria (nIdReticula,nIdMateria);
GO
/* CK_Tbl_MateriaPrerrequisito_NoAutorreferencia */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_MateriaPrerrequisito') AND name=N'CK_Tbl_MateriaPrerrequisito_NoAutorreferencia')
 ALTER TABLE App.Tbl_MateriaPrerrequisito ADD CONSTRAINT [CK_Tbl_MateriaPrerrequisito_NoAutorreferencia] CHECK (nIdMateria <> nIdMateriaPrerrequisito);
GO
/* DF_Tbl_MateriaPrerrequisito_nObligatorio */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_MateriaPrerrequisito') AND name=N'DF_Tbl_MateriaPrerrequisito_nObligatorio')
 ALTER TABLE App.Tbl_MateriaPrerrequisito ADD CONSTRAINT [DF_Tbl_MateriaPrerrequisito_nObligatorio] DEFAULT (1) FOR nObligatorio;
GO
/* UQ_Tbl_PeriodoAcademico_cClave */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_PeriodoAcademico') AND name=N'UQ_Tbl_PeriodoAcademico_cClave')
 ALTER TABLE App.Tbl_PeriodoAcademico ADD CONSTRAINT [UQ_Tbl_PeriodoAcademico_cClave] UNIQUE (cClave);
GO
/* CK_Tbl_PeriodoAcademico_Fechas */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_PeriodoAcademico') AND name=N'CK_Tbl_PeriodoAcademico_Fechas')
 ALTER TABLE App.Tbl_PeriodoAcademico ADD CONSTRAINT [CK_Tbl_PeriodoAcademico_Fechas] CHECK (dFechaInicio < dFechaFin);
GO
/* DF_Tbl_PeriodoAcademico_nActivoGeneracion */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_PeriodoAcademico') AND name=N'DF_Tbl_PeriodoAcademico_nActivoGeneracion')
 ALTER TABLE App.Tbl_PeriodoAcademico ADD CONSTRAINT [DF_Tbl_PeriodoAcademico_nActivoGeneracion] DEFAULT (0) FOR nActivoGeneracion;
GO
/* DF_Tbl_PeriodoAcademico_nOfertaPublicada */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_PeriodoAcademico') AND name=N'DF_Tbl_PeriodoAcademico_nOfertaPublicada')
 ALTER TABLE App.Tbl_PeriodoAcademico ADD CONSTRAINT [DF_Tbl_PeriodoAcademico_nOfertaPublicada] DEFAULT (0) FOR nOfertaPublicada;
GO
/* FK_Tbl_Grupo_Cat_Materia */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Grupo') AND name=N'FK_Tbl_Grupo_Cat_Materia')
 ALTER TABLE App.Tbl_Grupo ADD CONSTRAINT [FK_Tbl_Grupo_Cat_Materia] FOREIGN KEY (nIdMateria) REFERENCES App.Cat_Materia (nIdMateria);
GO
/* FK_Tbl_Grupo_Tbl_Docente */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Grupo') AND name=N'FK_Tbl_Grupo_Tbl_Docente')
 ALTER TABLE App.Tbl_Grupo ADD CONSTRAINT [FK_Tbl_Grupo_Tbl_Docente] FOREIGN KEY (nIdDocente) REFERENCES App.Tbl_Docente (nIdDocente);
GO
/* FK_Tbl_Grupo_Tbl_PeriodoAcademico */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Grupo') AND name=N'FK_Tbl_Grupo_Tbl_PeriodoAcademico')
 ALTER TABLE App.Tbl_Grupo ADD CONSTRAINT [FK_Tbl_Grupo_Tbl_PeriodoAcademico] FOREIGN KEY (nIdPeriodo) REFERENCES App.Tbl_PeriodoAcademico (nIdPeriodo);
GO
/* UQ_Tbl_Grupo_nIdPeriodo_nIdMateria_cClaveGrupo */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_Grupo') AND name=N'UQ_Tbl_Grupo_nIdPeriodo_nIdMateria_cClaveGrupo')
 ALTER TABLE App.Tbl_Grupo ADD CONSTRAINT [UQ_Tbl_Grupo_nIdPeriodo_nIdMateria_cClaveGrupo] UNIQUE (nIdPeriodo,nIdMateria,cClaveGrupo);
GO
/* FK_Tbl_SesionGrupo_Tbl_Grupo */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_SesionGrupo') AND name=N'FK_Tbl_SesionGrupo_Tbl_Grupo')
 ALTER TABLE App.Tbl_SesionGrupo ADD CONSTRAINT [FK_Tbl_SesionGrupo_Tbl_Grupo] FOREIGN KEY (nIdGrupo) REFERENCES App.Tbl_Grupo (nIdGrupo);
GO
/* FK_Tbl_SesionGrupo_Cat_DiaSemana */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_SesionGrupo') AND name=N'FK_Tbl_SesionGrupo_Cat_DiaSemana')
 ALTER TABLE App.Tbl_SesionGrupo ADD CONSTRAINT [FK_Tbl_SesionGrupo_Cat_DiaSemana] FOREIGN KEY (nIdDiaSemana) REFERENCES App.Cat_DiaSemana (nIdDiaSemana);
GO
/* FK_Tbl_SesionGrupo_Tbl_Aula */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_SesionGrupo') AND name=N'FK_Tbl_SesionGrupo_Tbl_Aula')
 ALTER TABLE App.Tbl_SesionGrupo ADD CONSTRAINT [FK_Tbl_SesionGrupo_Tbl_Aula] FOREIGN KEY (nIdAula) REFERENCES App.Tbl_Aula (nIdAula);
GO
/* CK_Tbl_SesionGrupo_Horas */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_SesionGrupo') AND name=N'CK_Tbl_SesionGrupo_Horas')
 ALTER TABLE App.Tbl_SesionGrupo ADD CONSTRAINT [CK_Tbl_SesionGrupo_Horas] CHECK (dHoraInicio < dHoraFin);
GO
/* UQ_Tbl_SesionGrupo_nIdGrupo_nIdDiaSemana_dHoraInicio_dHoraFin_nIdAula */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_SesionGrupo') AND name=N'UQ_Tbl_SesionGrupo_nIdGrupo_nIdDiaSemana_dHoraInicio_dHoraFin_nIdAula')
 ALTER TABLE App.Tbl_SesionGrupo ADD CONSTRAINT [UQ_Tbl_SesionGrupo_nIdGrupo_nIdDiaSemana_dHoraInicio_dHoraFin_nIdAula] UNIQUE (nIdGrupo,nIdDiaSemana,dHoraInicio,dHoraFin,nIdAula);
GO
/* FK_Tbl_HistorialAcademico_Tbl_Estudiante */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'FK_Tbl_HistorialAcademico_Tbl_Estudiante')
 ALTER TABLE App.Tbl_HistorialAcademico ADD CONSTRAINT [FK_Tbl_HistorialAcademico_Tbl_Estudiante] FOREIGN KEY (nIdEstudiante) REFERENCES App.Tbl_Estudiante (nIdEstudiante);
GO
/* FK_Tbl_HistorialAcademico_Cat_Materia */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'FK_Tbl_HistorialAcademico_Cat_Materia')
 ALTER TABLE App.Tbl_HistorialAcademico ADD CONSTRAINT [FK_Tbl_HistorialAcademico_Cat_Materia] FOREIGN KEY (nIdMateria) REFERENCES App.Cat_Materia (nIdMateria);
GO
/* FK_Tbl_HistorialAcademico_Tbl_PeriodoAcademico */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'FK_Tbl_HistorialAcademico_Tbl_PeriodoAcademico')
 ALTER TABLE App.Tbl_HistorialAcademico ADD CONSTRAINT [FK_Tbl_HistorialAcademico_Tbl_PeriodoAcademico] FOREIGN KEY (nIdPeriodo) REFERENCES App.Tbl_PeriodoAcademico (nIdPeriodo);
GO
/* FK_Tbl_HistorialAcademico_Cat_EstatusAcademico */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'FK_Tbl_HistorialAcademico_Cat_EstatusAcademico')
 ALTER TABLE App.Tbl_HistorialAcademico ADD CONSTRAINT [FK_Tbl_HistorialAcademico_Cat_EstatusAcademico] FOREIGN KEY (nIdEstatusAcademico) REFERENCES App.Cat_EstatusAcademico (nIdEstatusAcademico);
GO
/* UQ_Tbl_HistorialAcademico_nIdEstudiante_nIdMateria_nIdPeriodo */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'UQ_Tbl_HistorialAcademico_nIdEstudiante_nIdMateria_nIdPeriodo')
 ALTER TABLE App.Tbl_HistorialAcademico ADD CONSTRAINT [UQ_Tbl_HistorialAcademico_nIdEstudiante_nIdMateria_nIdPeriodo] UNIQUE (nIdEstudiante,nIdMateria,nIdPeriodo);
GO
/* CK_Tbl_HistorialAcademico_Calificacion */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'CK_Tbl_HistorialAcademico_Calificacion')
 ALTER TABLE App.Tbl_HistorialAcademico ADD CONSTRAINT [CK_Tbl_HistorialAcademico_Calificacion] CHECK (nCalificacion IS NULL OR nCalificacion BETWEEN 0 AND 100);
GO
/* FK_Tbl_HorarioGenerado_Tbl_TrayectoriaEstudiante */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'FK_Tbl_HorarioGenerado_Tbl_TrayectoriaEstudiante')
 ALTER TABLE App.Tbl_HorarioGenerado ADD CONSTRAINT [FK_Tbl_HorarioGenerado_Tbl_TrayectoriaEstudiante] FOREIGN KEY (nIdTrayectoria) REFERENCES App.Tbl_TrayectoriaEstudiante (nIdTrayectoria);
GO
/* FK_Tbl_HorarioGenerado_Tbl_PeriodoAcademico */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'FK_Tbl_HorarioGenerado_Tbl_PeriodoAcademico')
 ALTER TABLE App.Tbl_HorarioGenerado ADD CONSTRAINT [FK_Tbl_HorarioGenerado_Tbl_PeriodoAcademico] FOREIGN KEY (nIdPeriodo) REFERENCES App.Tbl_PeriodoAcademico (nIdPeriodo);
GO
/* DF_Tbl_HorarioGenerado_nConfirmado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'DF_Tbl_HorarioGenerado_nConfirmado')
 ALTER TABLE App.Tbl_HorarioGenerado ADD CONSTRAINT [DF_Tbl_HorarioGenerado_nConfirmado] DEFAULT (0) FOR nConfirmado;
GO
/* DF_Tbl_HorarioGenerado_nSeleccionado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'DF_Tbl_HorarioGenerado_nSeleccionado')
 ALTER TABLE App.Tbl_HorarioGenerado ADD CONSTRAINT [DF_Tbl_HorarioGenerado_nSeleccionado] DEFAULT (0) FOR nSeleccionado;
GO
/* CK_Tbl_HorarioGenerado_SeleccionConfirmada */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'CK_Tbl_HorarioGenerado_SeleccionConfirmada')
 ALTER TABLE App.Tbl_HorarioGenerado ADD CONSTRAINT [CK_Tbl_HorarioGenerado_SeleccionConfirmada] CHECK (nSeleccionado=0 OR nConfirmado=1);
GO
/* FK_Tbl_HorarioGeneradoDetalle_Tbl_HorarioGenerado */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGeneradoDetalle') AND name=N'FK_Tbl_HorarioGeneradoDetalle_Tbl_HorarioGenerado')
 ALTER TABLE App.Tbl_HorarioGeneradoDetalle ADD CONSTRAINT [FK_Tbl_HorarioGeneradoDetalle_Tbl_HorarioGenerado] FOREIGN KEY (nIdHorarioGenerado) REFERENCES App.Tbl_HorarioGenerado (nIdHorarioGenerado);
GO
/* FK_Tbl_HorarioGeneradoDetalle_Tbl_Grupo */
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE parent_object_id=OBJECT_ID(N'App.Tbl_HorarioGeneradoDetalle') AND name=N'FK_Tbl_HorarioGeneradoDetalle_Tbl_Grupo')
 ALTER TABLE App.Tbl_HorarioGeneradoDetalle ADD CONSTRAINT [FK_Tbl_HorarioGeneradoDetalle_Tbl_Grupo] FOREIGN KEY (nIdGrupo) REFERENCES App.Tbl_Grupo (nIdGrupo);
GO
/* Relación opcional 1:1; UNIQUE normal permitiría solo un NULL. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_Docente') AND name=N'IX_Tbl_Docente_Usuario')
 CREATE UNIQUE INDEX [IX_Tbl_Docente_Usuario] ON App.Tbl_Docente (nIdUsuario) WHERE nIdUsuario IS NOT NULL;
GO
/* Máximo una trayectoria vigente; PK por ID no lo asegura. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante') AND name=N'IX_Tbl_TrayectoriaEstudiante_Vigente')
 CREATE UNIQUE INDEX [IX_Tbl_TrayectoriaEstudiante_Vigente] ON App.Tbl_TrayectoriaEstudiante (nIdEstudiante) WHERE dFechaFin IS NULL;
GO
/* Cero o un periodo activo; UNIQUE normal impediría varios inactivos. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_PeriodoAcademico') AND name=N'IX_Tbl_PeriodoAcademico_UnicoActivo')
 CREATE UNIQUE INDEX [IX_Tbl_PeriodoAcademico_UnicoActivo] ON App.Tbl_PeriodoAcademico (nActivoGeneracion) WHERE nActivoGeneracion=1;
GO
/* Máximo una opción final; PK identifica solo una opción. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'IX_Tbl_HorarioGenerado_SeleccionUnica')
 CREATE UNIQUE INDEX [IX_Tbl_HorarioGenerado_SeleccionUnica] ON App.Tbl_HorarioGenerado (nIdTrayectoria,nIdPeriodo) WHERE nSeleccionado=1;
GO
/* Planes de carrera; PK empieza por retícula. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Cat_Reticula') AND name=N'IX_Cat_Reticula_Carrera')
 CREATE INDEX [IX_Cat_Reticula_Carrera] ON App.Cat_Reticula (nIdCarrera);
GO
/* Consulta Identity por correo; no se impone unicidad no solicitada. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_Usuario') AND name=N'IX_Tbl_Usuario_Correo')
 CREATE INDEX [IX_Tbl_Usuario_Correo] ON App.Tbl_Usuario (cCorreoNormalizado);
GO
/* Usuarios de un rol; PK empieza por usuario. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_UsuarioRol') AND name=N'IX_Tbl_UsuarioRol_Rol')
 CREATE INDEX [IX_Tbl_UsuarioRol_Rol] ON App.Tbl_UsuarioRol (nIdRol,nIdUsuario);
GO
/* Claims de usuario; PK por claim. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_UsuarioClaim') AND name=N'IX_Tbl_UsuarioClaim_Usuario')
 CREATE INDEX [IX_Tbl_UsuarioClaim_Usuario] ON App.Tbl_UsuarioClaim (nIdUsuario);
GO
/* Claims de rol; PK por claim. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_RolClaim') AND name=N'IX_Tbl_RolClaim_Rol')
 CREATE INDEX [IX_Tbl_RolClaim_Rol] ON App.Tbl_RolClaim (nIdRol);
GO
/* Logins de usuario; PK por proveedor. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_UsuarioLogin') AND name=N'IX_Tbl_UsuarioLogin_Usuario')
 CREATE INDEX [IX_Tbl_UsuarioLogin_Usuario] ON App.Tbl_UsuarioLogin (nIdUsuario);
GO
/* Trayectorias históricas; índice filtrado solo cubre vigente. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante') AND name=N'IX_Tbl_TrayectoriaEstudiante_Estudiante')
 CREATE INDEX [IX_Tbl_TrayectoriaEstudiante_Estudiante] ON App.Tbl_TrayectoriaEstudiante (nIdEstudiante,dFechaInicio) INCLUDE (nIdReticula,dFechaFin);
GO
/* Trayectorias de un plan; PK por trayectoria. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_TrayectoriaEstudiante') AND name=N'IX_Tbl_TrayectoriaEstudiante_Reticula')
 CREATE INDEX [IX_Tbl_TrayectoriaEstudiante_Reticula] ON App.Tbl_TrayectoriaEstudiante (nIdReticula) INCLUDE (nIdEstudiante);
GO
/* Relación inversa materia a planes; PK por retícula. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_ReticulaMateria') AND name=N'IX_Tbl_ReticulaMateria_Materia')
 CREATE INDEX [IX_Tbl_ReticulaMateria_Materia] ON App.Tbl_ReticulaMateria (nIdMateria,nIdReticula);
GO
/* Recorrido inverso del grafo; PK por objetivo. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_MateriaPrerrequisito') AND name=N'IX_Tbl_MateriaPrerrequisito_Antecedente')
 CREATE INDEX [IX_Tbl_MateriaPrerrequisito_Antecedente] ON App.Tbl_MateriaPrerrequisito (nIdReticula,nIdMateriaPrerrequisito) INCLUDE (nIdMateria);
GO
/* Conflictos de docente; UNIQUE empieza por periodo y materia. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_Grupo') AND name=N'IX_Tbl_Grupo_DocentePeriodo')
 CREATE INDEX [IX_Tbl_Grupo_DocentePeriodo] ON App.Tbl_Grupo (nIdDocente,nIdPeriodo,nEstatus) INCLUDE (nIdMateria);
GO
/* Grupos ofertados por materia; UNIQUE empieza por periodo. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_Grupo') AND name=N'IX_Tbl_Grupo_MateriaPeriodo')
 CREATE INDEX [IX_Tbl_Grupo_MateriaPeriodo] ON App.Tbl_Grupo (nIdMateria,nIdPeriodo,nEstatus) INCLUDE (nIdDocente,cClaveGrupo);
GO
/* Conflictos de aula; UNIQUE empieza por grupo. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_SesionGrupo') AND name=N'IX_Tbl_SesionGrupo_AulaDiaHora')
 CREATE INDEX [IX_Tbl_SesionGrupo_AulaDiaHora] ON App.Tbl_SesionGrupo (nIdAula,nIdDiaSemana,dHoraInicio) INCLUDE (dHoraFin,nIdGrupo);
GO
/* Relación inversa y FK materia; UNIQUE empieza por estudiante. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'IX_Tbl_HistorialAcademico_MateriaEstudiante')
 CREATE INDEX [IX_Tbl_HistorialAcademico_MateriaEstudiante] ON App.Tbl_HistorialAcademico (nIdMateria,nIdEstudiante) INCLUDE (nIdEstatusAcademico);
GO
/* Intentos de un periodo; UNIQUE por estudiante. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_HistorialAcademico') AND name=N'IX_Tbl_HistorialAcademico_Periodo')
 CREATE INDEX [IX_Tbl_HistorialAcademico_Periodo] ON App.Tbl_HistorialAcademico (nIdPeriodo);
GO
/* Todas las opciones; índice filtrado solo cubre seleccionada. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'IX_Tbl_HorarioGenerado_TrayectoriaPeriodo')
 CREATE INDEX [IX_Tbl_HorarioGenerado_TrayectoriaPeriodo] ON App.Tbl_HorarioGenerado (nIdTrayectoria,nIdPeriodo) INCLUDE (nConfirmado);
GO
/* Publicación y horarios por periodo; PK por horario. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_HorarioGenerado') AND name=N'IX_Tbl_HorarioGenerado_Periodo')
 CREATE INDEX [IX_Tbl_HorarioGenerado_Periodo] ON App.Tbl_HorarioGenerado (nIdPeriodo);
GO
/* Opciones que usan un grupo; PK por horario. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'App.Tbl_HorarioGeneradoDetalle') AND name=N'IX_Tbl_HorarioGeneradoDetalle_Grupo')
 CREATE INDEX [IX_Tbl_HorarioGeneradoDetalle_Grupo] ON App.Tbl_HorarioGeneradoDetalle (nIdGrupo,nIdHorarioGenerado);
GO
