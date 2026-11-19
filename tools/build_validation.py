from build_test_data import *

context='''
DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;
'''
student_insert="INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl,cNombre,nAnioIngreso,nGeneracion) VALUES(@nUsuario,{control},N'Estudiante Negativo',2024,24);"
temp_groups='''
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('NEG-PRUEBA',N'Prueba revertida','20270101','20270630'); SET @nPruebaPeriodo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente,@nPruebaPeriodo,'NEG1'); SET @nGrupo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,{docente2},@nPruebaPeriodo,'NEG2'); SET @nGrupo2=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo,1,@nAula,'08:00','10:00');
'''
tests=[]
def case(n,s,e,marker=''):tests.append((n,s,e,marker))
case('Número de control duplicado',student_insert.format(control='@cControl'),2627,'UQ_Tbl_Estudiante_cNumeroControl')
case('Número de control con siete dígitos',student_insert.format(control="'2424001'"),547,'CK_Tbl_Estudiante_NumeroControl8')
case('Número de control con letras',student_insert.format(control="'2424ABCD'"),547,'CK_Tbl_Estudiante_NumeroControl8')
case('Número de control con nueve dígitos',student_insert.format(control="'242400001'"),2628)
case('Año de ingreso incompatible',student_insert.format(control="'25251234'"),547,'CK_Tbl_Estudiante_IngresoGeneracion')
case('Materia duplicada',"INSERT App.Cat_Materia(cClave,cNombre) VALUES('ACF-0901',N'Duplicada');",2627,'UQ_Cat_Materia_cClave')
case('Aula duplicada',"INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) SELECT nIdTipoAula,'D6',30 FROM App.Cat_TipoAula WHERE cClave='AULA';",2627,'UQ_Tbl_Aula_cClave')
case('Grupo duplicado',"INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) SELECT TOP(1) nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo FROM App.Tbl_Grupo;",2627,'UQ_Tbl_Grupo_nIdPeriodo_nIdMateria_cClaveGrupo')
case('Sesión con horas invertidas',temp_groups.format(docente2='@nDocente2')+"INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,2,@nAula2,'10:00','08:00');",547,'CK_Tbl_SesionGrupo_Horas')
case('Día inexistente',temp_groups.format(docente2='@nDocente2')+"INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,9,@nAula2,'10:00','11:00');",547,'FK_Tbl_SesionGrupo_Cat_DiaSemana')
case('Choque de docente',temp_groups.format(docente2='@nDocente')+"INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,1,@nAula2,'09:00','11:00');",51002)
case('Choque de aula',temp_groups.format(docente2='@nDocente2')+"INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,1,@nAula,'09:00','11:00');",51003)
case('Sesiones contiguas válidas',temp_groups.format(docente2='@nDocente')+"INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,1,@nAula,'10:00','12:00');",0)
select_group="SELECT G.nIdGrupo FROM App.Tbl_Grupo G JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria WHERE G.nIdPeriodo=@nPeriodo AND M.cClave={materia} AND G.cClaveGrupo={grupo}"
def add_group(m,g):return 'INSERT @Grupos '+select_group.format(materia=q(m),grupo=q(g))+';\n'
save="EXEC App.Sp_GuardarHorarioGenerado @nTrayectoria,@nPeriodo,N'NEGATIVO',@Grupos,@nHorario OUTPUT;"
case('RV001 materia repetida',add_group('ACF-0901','1T1')+add_group('ACF-0901','1T2')+save,51102)
case('RV002 empalme del estudiante',add_group('ACF-0901','1T1')+add_group('ACF-0902','2T1')+save,51104)
case('RV003 créditos excesivos',"UPDATE App.Tbl_TrayectoriaEstudiante SET nLimiteCreditos=1 WHERE nIdTrayectoria=@nTrayectoria;"+add_group('ACF-0901','1T1')+save,51105)
case('RV004 prerrequisito sin aprobar',add_group('AED-1286','2T1')+save,51106)
case('Horario vacío',"DECLARE @nVacio App.Tbl_ListaGrupo; EXEC App.Sp_GuardarHorarioGenerado @nTrayectoria,@nPeriodo,N'Vacío',@nVacio,@nHorario OUTPUT;",51101)
case('Oferta publicada congelada',"UPDATE App.Tbl_Grupo SET cClaveGrupo='CAMBIO' WHERE nIdGrupo=(SELECT MIN(nIdGrupo) FROM App.Tbl_Grupo);",51300)
case('Runtime no puede consultar Aud',"BEGIN TRY EXECUTE AS USER='Usr_SistemaHorarios'; EXEC sys.sp_executesql N'SELECT nIdAuditoria FROM Aud.Tbl_Auditoria;'; REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK; REVERT; THROW; END CATCH;",229)
negative='''/* Cada caso comienza transacción y termina en rollback, también cuando el error esperado invalida la transacción. */
CREATE TABLE #Resultados(cPrueba nvarchar(150),nEsperado int,nReal int,nCorrecta bit,cDetalle nvarchar(2048));
GO
'''
for n,s,e,marker in tests:
    negative+=f"BEGIN TRY\n BEGIN TRANSACTION;\n{context}\n{s}\n ROLLBACK;\n INSERT #Resultados VALUES({q(n)},{e},0,{1 if e==0 else 0},N'Operación válida');\nEND TRY BEGIN CATCH\n DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();\n IF XACT_STATE()<>0 ROLLBACK;\n INSERT #Resultados VALUES({q(n)},{e},@nError,CASE WHEN @nError={e}"+(f" AND CHARINDEX({q(marker)},@cError)>0" if marker else '')+" THEN 1 ELSE 0 END,@cError);\nEND CATCH;\nGO\n"
negative+='''SELECT cPrueba,nEsperado,nReal,nCorrecta,cDetalle FROM #Resultados ORDER BY nCorrecta,cPrueba;
SELECT COUNT(*) AS nTotal,SUM(CONVERT(int,nCorrecta)) AS nCorrectas FROM #Resultados;
IF EXISTS(SELECT 1 FROM #Resultados WHERE nCorrecta=0) THROW 52010,N'Fallaron pruebas negativas.',1;
DROP TABLE #Resultados;
GO'''
emit('13_NegativeTests.sql',negative)

checks=[]
def check(n,query):checks.append((n,query))
check('Números de control inválidos',"SELECT COUNT(*) FROM App.Tbl_Estudiante WHERE LEN(cNumeroControl)<>8 OR cNumeroControl COLLATE Latin1_General_100_BIN2 LIKE '%[^0-9]%'")
check('Números de control duplicados',"SELECT COUNT(*) FROM (SELECT cNumeroControl FROM App.Tbl_Estudiante GROUP BY cNumeroControl HAVING COUNT(*)>1) D")
check('Materias duplicadas',"SELECT COUNT(*) FROM (SELECT cClave FROM App.Cat_Materia GROUP BY cClave HAVING COUNT(*)>1) D")
check('Grupos duplicados',"SELECT COUNT(*) FROM (SELECT nIdPeriodo,nIdMateria,cClaveGrupo FROM App.Tbl_Grupo GROUP BY nIdPeriodo,nIdMateria,cClaveGrupo HAVING COUNT(*)>1) D")
check('Sesiones inválidas',"SELECT COUNT(*) FROM App.Tbl_SesionGrupo WHERE dHoraInicio>=dHoraFin OR nIdDiaSemana NOT BETWEEN 1 AND 7")
session_pairs='''FROM App.Tbl_SesionGrupo A JOIN App.Tbl_SesionGrupo B ON A.nIdSesionGrupo<B.nIdSesionGrupo
 AND A.nIdDiaSemana=B.nIdDiaSemana AND A.dHoraInicio<B.dHoraFin AND B.dHoraInicio<A.dHoraFin
 JOIN App.Tbl_Grupo GA ON GA.nIdGrupo=A.nIdGrupo JOIN App.Tbl_Grupo GB ON GB.nIdGrupo=B.nIdGrupo
 WHERE GA.nEstatus=1 AND GB.nEstatus=1 AND GA.nIdPeriodo=GB.nIdPeriodo AND '''
check('Docentes con empalmes','SELECT COUNT(*) '+session_pairs+' GA.nIdDocente=GB.nIdDocente')
check('Aulas con empalmes','SELECT COUNT(*) '+session_pairs+' A.nIdAula=B.nIdAula')
check('Horarios con materias duplicadas',"SELECT COUNT(*) FROM (SELECT D.nIdHorarioGenerado,G.nIdMateria FROM App.Tbl_HorarioGeneradoDetalle D JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo GROUP BY D.nIdHorarioGenerado,G.nIdMateria HAVING COUNT(*)>1) X")
check('Horarios con empalmes','''SELECT COUNT(*) FROM App.Tbl_HorarioGeneradoDetalle A
 JOIN App.Tbl_HorarioGeneradoDetalle B ON A.nIdHorarioGenerado=B.nIdHorarioGenerado AND A.nIdGrupo<B.nIdGrupo
 JOIN App.Tbl_SesionGrupo SA ON SA.nIdGrupo=A.nIdGrupo JOIN App.Tbl_SesionGrupo SB ON SB.nIdGrupo=B.nIdGrupo
 WHERE SA.nIdDiaSemana=SB.nIdDiaSemana AND SA.dHoraInicio<SB.dHoraFin AND SB.dHoraInicio<SA.dHoraFin''')
check('Materias fuera de retícula','''SELECT COUNT(*) FROM App.Tbl_HorarioGenerado H JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria
 JOIN App.Tbl_HorarioGeneradoDetalle D ON D.nIdHorarioGenerado=H.nIdHorarioGenerado JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo
 LEFT JOIN App.Tbl_ReticulaMateria RM ON RM.nIdReticula=T.nIdReticula AND RM.nIdMateria=G.nIdMateria WHERE RM.nIdMateria IS NULL''')
check('Trayectorias o carreras inválidas','''SELECT COUNT(*) FROM App.Tbl_TrayectoriaEstudiante T LEFT JOIN App.Cat_Reticula R ON R.nIdReticula=T.nIdReticula
 LEFT JOIN App.Cat_Carrera C ON C.nIdCarrera=R.nIdCarrera WHERE R.nIdReticula IS NULL OR C.nIdCarrera IS NULL''')
check('Horarios con créditos excesivos',"SELECT COUNT(*) FROM Rep.Vi_ResumenHorarios H JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria WHERE H.nTotalCreditos>T.nLimiteCreditos")
check('Horarios con periodo o grupo inválido','''SELECT COUNT(*) FROM App.Tbl_HorarioGenerado H JOIN App.Tbl_HorarioGeneradoDetalle D ON D.nIdHorarioGenerado=H.nIdHorarioGenerado
 JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo WHERE G.nIdPeriodo<>H.nIdPeriodo OR G.nEstatus=0 OR H.nConfirmado<>1''')
check('Prerrequisitos incumplidos en horarios','''SELECT COUNT(*) FROM App.Tbl_HorarioGenerado H JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria
 JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=H.nIdPeriodo JOIN App.Tbl_HorarioGeneradoDetalle D ON D.nIdHorarioGenerado=H.nIdHorarioGenerado
 JOIN App.Tbl_Grupo G ON G.nIdGrupo=D.nIdGrupo JOIN App.Tbl_MateriaPrerrequisito PR ON PR.nIdReticula=T.nIdReticula AND PR.nIdMateria=G.nIdMateria AND PR.nObligatorio=1
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_HistorialAcademico HA JOIN App.Cat_EstatusAcademico EA ON EA.nIdEstatusAcademico=HA.nIdEstatusAcademico
 JOIN App.Tbl_PeriodoAcademico PA ON PA.nIdPeriodo=HA.nIdPeriodo WHERE HA.nIdEstudiante=T.nIdEstudiante AND HA.nIdMateria=PR.nIdMateriaPrerrequisito AND EA.cClave='APROBADA' AND PA.dFechaFin<P.dFechaInicio)''')
check('Nombres reales usados como estudiantes',"SELECT COUNT(*) FROM App.Tbl_Estudiante WHERE cNombre NOT LIKE N'Estudiante Sintético %'")
check('Claves foráneas no confiables',"SELECT COUNT(*) FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1")
check('CHECK no confiables',"SELECT COUNT(*) FROM sys.check_constraints WHERE is_disabled=1 OR is_not_trusted=1")
validation='''/* Validación real previa al desarrollo. Falla ante cantidades insuficientes o cualquier inconsistencia. */
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
'''
for n,s in checks:validation+=f'INSERT #Inconsistencias VALUES({q(n)},({s}));\n'
validation+='CREATE TABLE #Referencia(cMateria varchar(30),cGrupo varchar(20),cDocente nvarchar(150),nDia tinyint,cAula varchar(30),dInicio time(0),dFin time(0));\nINSERT #Referencia VALUES\n'+values([(k,g,real_teachers[t],day,room,a,b) for k,(g,t,room,ses) in refs.items() for day,a,b in ses])+''';
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
GO'''
emit('14_DataValidation.sql',validation)
print(f'Generadas {len(tests)} pruebas negativas/limítrofes y {len(checks)+1} consultas de inconsistencias.')
