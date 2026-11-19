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
/* Relación operativa de versiones curriculares y sus materias. */
CREATE OR ALTER VIEW App.Vi_MateriasReticula AS
SELECT C.nIdCarrera,C.cClave AS cClaveCarrera,C.cNombre AS cCarrera,
 R.nIdReticula,R.cClave AS cClaveReticula,R.cNombre AS cReticula,
 M.nIdMateria,M.cClave AS cClaveMateria,M.cNombre AS cMateria,
 RM.nSemestreRecomendado,RM.nCreditos,RM.nObligatoria
FROM App.Cat_Carrera C JOIN App.Cat_Reticula R ON R.nIdCarrera=C.nIdCarrera
JOIN App.Tbl_ReticulaMateria RM ON RM.nIdReticula=R.nIdReticula
JOIN App.Cat_Materia M ON M.nIdMateria=RM.nIdMateria;
GO
/* Elegibilidad para el periodo activo: no aprobada/cursando y antecedentes aprobados antes del periodo. */
CREATE OR ALTER VIEW App.Vi_MateriasDisponibles AS
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
