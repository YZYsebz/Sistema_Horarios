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
/* Periodos disponibles para consulta y reportes cronológicos. */
CREATE OR ALTER VIEW Rep.Vi_PeriodosAcademicos AS
SELECT nIdPeriodo,cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion,nOfertaPublicada
FROM App.Tbl_PeriodoAcademico;
GO
/* Una fila por sesión; LEFT JOIN permite observar faltantes en preparación. */
CREATE OR ALTER VIEW Rep.Vi_OfertaAcademica AS
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
/* Intentos por estudiante y periodo, sin credenciales. */
CREATE OR ALTER VIEW Rep.Vi_HistorialEstudiante AS
SELECT E.nIdEstudiante,E.cNumeroControl,H.nIdHistorialAcademico,M.nIdMateria,M.cClave AS cClaveMateria,
 M.cNombre AS cMateria,P.nIdPeriodo,P.cClave AS cPeriodo,EA.cClave AS cEstatusAcademico,H.nCalificacion,H.dFechaRegistro
FROM App.Tbl_HistorialAcademico H JOIN App.Tbl_Estudiante E ON E.nIdEstudiante=H.nIdEstudiante
JOIN App.Cat_Materia M ON M.nIdMateria=H.nIdMateria
JOIN App.Cat_EstatusAcademico EA ON EA.nIdEstatusAcademico=H.nIdEstatusAcademico
LEFT JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=H.nIdPeriodo;
GO
/* Totales calculados por grupo, nunca multiplicados por las sesiones. */
CREATE OR ALTER VIEW Rep.Vi_ResumenHorarios AS
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
/* Detalle de opciones confirmadas, una fila por grupo. */
CREATE OR ALTER VIEW Rep.Vi_HorariosGenerados AS
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
