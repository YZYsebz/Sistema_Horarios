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
