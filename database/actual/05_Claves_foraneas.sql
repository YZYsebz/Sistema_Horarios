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
