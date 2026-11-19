SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_WARNINGS ON;
SET ANSI_PADDING ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO
USE [Bd_SistemaHorarios];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
/* Validación real previa al desarrollo. Falla ante cantidades insuficientes o cualquier inconsistencia. */
CREATE TABLE #Conteos(cObjeto nvarchar(80),nRegistros int,nMinimo int);
INSERT #Conteos VALUES
('Usuarios',(SELECT COUNT(*) FROM App.Tbl_Usuario),100),
('Estudiantes',(SELECT COUNT(*) FROM App.Tbl_Estudiante),50),
('Docentes',(SELECT COUNT(*) FROM App.Tbl_Docente),50),
('Grupos',(SELECT COUNT(*) FROM App.Tbl_Grupo),50),
('Sesiones',(SELECT COUNT(*) FROM App.Tbl_SesionGrupo),100),
('Historial',(SELECT COUNT(*) FROM App.Tbl_HistorialAcademico),300),
('Horarios',(SELECT COUNT(*) FROM App.Tbl_HorarioGenerado WHERE nConfirmado=1),50),
('Detalle',(SELECT COUNT(*) FROM App.Tbl_HorarioGeneradoDetalle),200),
('Auditoría',(SELECT COUNT(*) FROM Aud.Tbl_Auditoria),50);
CREATE TABLE #Inconsistencias(cRegla nvarchar(120),nCantidad int);
INSERT #Inconsistencias VALUES(N'Números de control inválidos',(SELECT COUNT(*) FROM App.Tbl_Estudiante WHERE LEN(cNumeroControl)<>8 OR cNumeroControl COLLATE Latin1_General_100_BIN2 LIKE '%[^0-9]%'));
INSERT #Inconsistencias VALUES(N'Números de control duplicados',(SELECT COUNT(*) FROM (SELECT cNumeroControl FROM App.Tbl_Estudiante GROUP BY cNumeroControl HAVING COUNT(*)>1) D));
INSERT #Inconsistencias VALUES(N'Materias duplicadas',(SELECT COUNT(*) FROM (SELECT cClave FROM App.Cat_Materia GROUP BY cClave HAVING COUNT(*)>1) D));
INSERT #Inconsistencias VALUES(N'Grupos duplicados',(SELECT COUNT(*) FROM (SELECT nIdPeriodo,nIdMateria,cClaveGrupo FROM App.Tbl_Grupo GROUP BY nIdPeriodo,nIdMateria,cClaveGrupo HAVING COUNT(*)>1) D));
INSERT #Inconsistencias VALUES(N'Sesiones inválidas',(SELECT COUNT(*) FROM App.Tbl_SesionGrupo WHERE dHoraInicio>=dHoraFin OR nIdDiaSemana NOT BETWEEN 1 AND 7));
INSERT #Inconsistencias VALUES(N'Docentes con empalmes',(SELECT COUNT(*) FROM App.Tbl_SesionGrupo A JOIN App.Tbl_SesionGrupo B ON A.nIdSesionGrupo<B.nIdSesionGrupo
 AND A.nIdDiaSemana=B.nIdDiaSemana AND A.dHoraInicio<B.dHoraFin AND B.dHoraInicio<A.dHoraFin
 JOIN App.Tbl_Grupo GA ON GA.nIdGrupo=A.nIdGrupo JOIN App.Tbl_Grupo GB ON GB.nIdGrupo=B.nIdGrupo
 WHERE GA.nEstatus=1 AND GB.nEstatus=1 AND GA.nIdPeriodo=GB.nIdPeriodo AND  GA.nIdDocente=GB.nIdDocente));
INSERT #Inconsistencias VALUES(N'Aulas con empalmes',(SELECT COUNT(*) FROM App.Tbl_SesionGrupo A JOIN App.Tbl_SesionGrupo B ON A.nIdSesionGrupo<B.nIdSesionGrupo
 AND A.nIdDiaSemana=B.nIdDiaSemana AND A.dHoraInicio<B.dHoraFin AND B.dHoraInicio<A.dHoraFin
 JOIN App.Tbl_Grupo GA ON GA.nIdGrupo=A.nIdGrupo JOIN App.Tbl_Grupo GB ON GB.nIdGrupo=B.nIdGrupo
 WHERE GA.nEstatus=1 AND GB.nEstatus=1 AND GA.nIdPeriodo=GB.nIdPeriodo AND  A.nIdAula=B.nIdAula));
INSERT #Inconsistencias VALUES(N'Horarios con materias duplicadas',(SELECT COUNT(*) FROM (SELECT D.nIdHorarioGenerado,G.nIdMateria FROM App.Tbl_HorarioGeneradoDetalle D JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo GROUP BY D.nIdHorarioGenerado,G.nIdMateria HAVING COUNT(*)>1) X));
INSERT #Inconsistencias VALUES(N'Horarios con empalmes',(SELECT COUNT(*) FROM App.Tbl_HorarioGeneradoDetalle A
 JOIN App.Tbl_HorarioGeneradoDetalle B ON A.nIdHorarioGenerado=B.nIdHorarioGenerado AND A.nIdGrupo<B.nIdGrupo
 JOIN App.Tbl_SesionGrupo SA ON SA.nIdGrupo=A.nIdGrupo JOIN App.Tbl_SesionGrupo SB ON SB.nIdGrupo=B.nIdGrupo
 WHERE SA.nIdDiaSemana=SB.nIdDiaSemana AND SA.dHoraInicio<SB.dHoraFin AND SB.dHoraInicio<SA.dHoraFin));
INSERT #Inconsistencias VALUES(N'Materias fuera de retícula',(SELECT COUNT(*) FROM App.Tbl_HorarioGenerado H JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria
 JOIN App.Tbl_HorarioGeneradoDetalle D ON D.nIdHorarioGenerado=H.nIdHorarioGenerado JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo
 LEFT JOIN App.Tbl_ReticulaMateria RM ON RM.nIdReticula=T.nIdReticula AND RM.nIdMateria=G.nIdMateria WHERE RM.nIdMateria IS NULL));
INSERT #Inconsistencias VALUES(N'Trayectorias o carreras inválidas',(SELECT COUNT(*) FROM App.Tbl_TrayectoriaEstudiante T LEFT JOIN App.Cat_Reticula R ON R.nIdReticula=T.nIdReticula
 LEFT JOIN App.Cat_Carrera C ON C.nIdCarrera=R.nIdCarrera WHERE R.nIdReticula IS NULL OR C.nIdCarrera IS NULL));
INSERT #Inconsistencias VALUES(N'Horarios con créditos excesivos',(SELECT COUNT(*) FROM Rep.Vi_ResumenHorarios H JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria WHERE H.nTotalCreditos>T.nLimiteCreditos));
INSERT #Inconsistencias VALUES(N'Horarios con periodo o grupo inválido',(SELECT COUNT(*) FROM App.Tbl_HorarioGenerado H JOIN App.Tbl_HorarioGeneradoDetalle D ON D.nIdHorarioGenerado=H.nIdHorarioGenerado
 JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo WHERE G.nIdPeriodo<>H.nIdPeriodo OR G.nEstatus=0 OR H.nConfirmado<>1));
INSERT #Inconsistencias VALUES(N'Prerrequisitos incumplidos en horarios',(SELECT COUNT(*) FROM App.Tbl_HorarioGenerado H JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria
 JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=H.nIdPeriodo JOIN App.Tbl_HorarioGeneradoDetalle D ON D.nIdHorarioGenerado=H.nIdHorarioGenerado
 JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo JOIN App.Tbl_MateriaPrerrequisito PR ON PR.nIdReticula=T.nIdReticula AND PR.nIdMateria=G.nIdMateria AND PR.nObligatorio=1
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_HistorialAcademico HA JOIN App.Cat_EstatusAcademico EA ON EA.nIdEstatusAcademico=HA.nIdEstatusAcademico
 JOIN App.Tbl_PeriodoAcademico PA ON PA.nIdPeriodo=HA.nIdPeriodo WHERE HA.nIdEstudiante=T.nIdEstudiante AND HA.nIdMateria=PR.nIdMateriaPrerrequisito AND EA.cClave='APROBADA' AND PA.dFechaFin<P.dFechaInicio)));
INSERT #Inconsistencias VALUES(N'Nombres reales usados como estudiantes',(SELECT COUNT(*) FROM App.Tbl_Estudiante WHERE cNombre NOT LIKE N'Estudiante Sintético %'));
INSERT #Inconsistencias VALUES(N'Claves foráneas no confiables',(SELECT COUNT(*) FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1));
INSERT #Inconsistencias VALUES(N'CHECK no confiables',(SELECT COUNT(*) FROM sys.check_constraints WHERE is_disabled=1 OR is_not_trusted=1));
CREATE TABLE #Referencia(cMateria varchar(30),cGrupo varchar(20),cDocente nvarchar(150),nDia tinyint,cAula varchar(30),dInicio time(0),dFin time(0));
INSERT #Referencia VALUES
(N'SCA-1025',N'5B',N'RUIZ GAYTAN LUZ DEL CARMEN',1,N'D11',N'10:30',N'12:10'),
(N'SCA-1025',N'5B',N'RUIZ GAYTAN LUZ DEL CARMEN',3,N'D11',N'10:30',N'12:10'),
(N'SCC-1012',N'5C',N'BALTAZAR FLORES MARIA DEL ROSARIO',1,N'D6',N'07:00',N'08:40'),
(N'SCC-1012',N'5C',N'BALTAZAR FLORES MARIA DEL ROSARIO',3,N'D6',N'07:00',N'08:40'),
(N'SCD-1003',N'5A',N'VALDIVIA MURILLO MARIA MAGDALENA',1,N'D9',N'08:45',N'10:25'),
(N'SCD-1003',N'5A',N'VALDIVIA MURILLO MARIA MAGDALENA',3,N'D9',N'08:45',N'10:25'),
(N'SCD-1003',N'5A',N'VALDIVIA MURILLO MARIA MAGDALENA',5,N'D9',N'08:45',N'09:35'),
(N'SCD-1021',N'5B',N'RAMIREZ MENDEZ JESUS ENRIQUE',2,N'LR2',N'10:30',N'12:10'),
(N'SCD-1021',N'5B',N'RAMIREZ MENDEZ JESUS ENRIQUE',4,N'LR2',N'10:30',N'12:10'),
(N'SCD-1021',N'5B',N'RAMIREZ MENDEZ JESUS ENRIQUE',5,N'LR2',N'11:20',N'12:10'),
(N'SCC-1007',N'5B',N'TRUJILLO CASTELLANOS CARLOS ALBERTO',2,N'D7',N'07:00',N'08:40'),
(N'SCC-1007',N'5B',N'TRUJILLO CASTELLANOS CARLOS ALBERTO',4,N'D7',N'07:00',N'08:40'),
(N'AEC-1061',N'5B',N'TRUJILLO CASTELLANOS CARLOS ALBERTO',2,N'LC2',N'08:45',N'10:25'),
(N'AEC-1061',N'5B',N'TRUJILLO CASTELLANOS CARLOS ALBERTO',4,N'LC2',N'08:45',N'10:25');
INSERT #Inconsistencias SELECT N'Sesiones de referencia faltantes',COUNT(*) FROM #Referencia R
WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_Grupo G JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria
 JOIN App.Tbl_Docente D ON D.nIdDocente=G.nIdDocente JOIN App.Tbl_SesionGrupo S ON S.nIdGrupo=G.nIdGrupo
 JOIN App.Tbl_Aula A ON A.nIdAula=S.nIdAula JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=G.nIdPeriodo
 WHERE P.cClave='TEST-2026-2' AND M.cClave=R.cMateria AND G.cClaveGrupo=R.cGrupo AND D.cNombre=R.cDocente
 AND A.cClave=R.cAula AND S.nIdDiaSemana=R.nDia AND S.dHoraInicio=R.dInicio AND S.dHoraFin=R.dFin);
IF EXISTS(SELECT 1 FROM #Conteos WHERE nRegistros<nMinimo) THROW 52011,N'Cantidades insuficientes; no comenzar desarrollo web.',1;
IF EXISTS(SELECT 1 FROM #Inconsistencias WHERE nCantidad<>0) BEGIN SELECT cRegla,nCantidad FROM #Inconsistencias; THROW 52012,N'Hay inconsistencias; no comenzar desarrollo web.',1; END;
IF (SELECT COUNT(*) FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1 AND nOfertaPublicada=1)<>1 THROW 52013,N'Se requiere exactamente un periodo activo publicado.',1;
IF (SELECT COUNT(*) FROM App.Cat_Rol)<>3 OR (SELECT COUNT(*) FROM App.Cat_DiaSemana)<>7 OR (SELECT COUNT(*) FROM App.Cat_EstatusAcademico)<>4 OR (SELECT COUNT(*) FROM App.Cat_TipoAula)<>4 THROW 52014,N'Catálogos base incorrectos.',1;
IF (SELECT SUM(CONVERT(int,RM.nCreditos)) FROM App.Tbl_ReticulaMateria RM JOIN App.Cat_Reticula R ON R.nIdReticula=RM.nIdReticula WHERE R.cClave='ISIC-2010-224')<>260 THROW 52015,N'Créditos de la retícula no coinciden con 260.',1;
BEGIN TRAN; EXEC App.Sp_ValidarIntegridadOferta; ROLLBACK;
-- Consultas solicitadas explícitamente: ambas devuelven cero filas.
SELECT cNumeroControl FROM App.Tbl_Estudiante WHERE LEN(cNumeroControl)<>8 OR cNumeroControl LIKE '%[^0-9]%';
SELECT cNumeroControl,COUNT(*) AS nCantidad FROM App.Tbl_Estudiante GROUP BY cNumeroControl HAVING COUNT(*)>1;
SELECT N'BASE DE DATOS VALIDADA' AS cEstado,
 JSON_QUERY((SELECT cObjeto,nRegistros,nMinimo FROM #Conteos FOR JSON PATH)) AS Conteos,
 JSON_QUERY((SELECT cRegla,nCantidad FROM #Inconsistencias FOR JSON PATH)) AS Comprobaciones
 FOR JSON PATH,WITHOUT_ARRAY_WRAPPER;
PRINT N'BASE DE DATOS LISTA PARA DESARROLLO';
DROP TABLE #Referencia;
DROP TABLE #Conteos;
DROP TABLE #Inconsistencias;
GO
