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
