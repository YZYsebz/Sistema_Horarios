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
