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
/* Pruebas aisladas: cada fixture y toda auditoría se revierten. Requiere cuenta de despliegue con IMPERSONATE.
Los errores esperados se capturan; cualquier diferencia hace fallar sqlcmd -b al terminar. */
SET NOCOUNT ON;
CREATE TABLE #Resultados(cPrueba nvarchar(150),nEsperado int,nReal int,nPaso bit,cDetalle nvarchar(2048));
GO
/* Guardar horario válido y total calculado */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga),(@gb);
EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
IF NOT EXISTS(SELECT 1 FROM Rep.Vi_ResumenHorarios WHERE nIdHorarioGenerado=@h AND nTotalCreditos=11 AND nTotalGrupos=2 AND nSeleccionado=1) THROW 51901,N'Total incorrecto.',1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Guardar horario válido y total calculado',0,0,1,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Guardar horario válido y total calculado',0,@nError,CASE WHEN @nError=0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Horas contiguas permitidas */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_RegistrarSesionGrupo @ga,2,@a1,'08:00','10:00',@s OUTPUT; EXEC App.Sp_RegistrarSesionGrupo @gb,2,@a1,'10:00','12:00',@s OUTPUT;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Horas contiguas permitidas',0,0,1,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Horas contiguas permitidas',0,@nError,CASE WHEN @nError=0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Docentes sin usuario múltiples NULL */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

IF (SELECT COUNT(*) FROM App.Tbl_Docente WHERE nIdDocente IN(@d1,@d2,@d3) AND nIdUsuario IS NULL)<>3 THROW 51901,N'NULL únicos inválidos.',1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Docentes sin usuario múltiples NULL',0,0,1,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Docentes sin usuario múltiples NULL',0,@nError,CASE WHEN @nError=0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Retícula sin carrera inexistente */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(-1,'__QA_BAD',N'Inválida');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Retícula sin carrera inexistente',547,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Retícula sin carrera inexistente',547,@nError,CASE WHEN @nError=547 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Clave de materia duplicada */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Duplicada');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Clave de materia duplicada',2627,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Clave de materia duplicada',2627,@nError,CASE WHEN @nError=2627 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Grupo duplicado en periodo materia */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Grupo duplicado en periodo materia',2627,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Grupo duplicado en periodo materia',2627,@nError,CASE WHEN @nError=2627 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Aula capacidad cero */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_CERO',0);
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Aula capacidad cero',547,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Aula capacidad cero',547,@nError,CASE WHEN @nError=547 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Horas invertidas CHECK */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@ga,2,@a1,'10:00','08:00');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Horas invertidas CHECK',547,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Horas invertidas CHECK',547,@nError,CASE WHEN @nError=547 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Horas iguales SP */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_RegistrarSesionGrupo @ga,2,@a1,'10:00','10:00',@s OUTPUT;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Horas iguales SP',51200,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Horas iguales SP',51200,@nError,CASE WHEN @nError=51200 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Día inexistente FK */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@ga,9,@a1,'16:00','17:00');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Día inexistente FK',547,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Día inexistente FK',547,@nError,CASE WHEN @nError=547 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Grupo inexistente SP */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_RegistrarSesionGrupo -1,2,@a1,'16:00','17:00',@s OUTPUT;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Grupo inexistente SP',51204,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Grupo inexistente SP',51204,@nError,CASE WHEN @nError=51204 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Un solo periodo activo */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_DOS',N'Otro','20310101','20310630',1);
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Un solo periodo activo',2601,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Un solo periodo activo',2601,@nError,CASE WHEN @nError=2601 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Fechas de periodo invertidas */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_BADP',N'Otro','20310630','20310101');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Fechas de periodo invertidas',547,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Fechas de periodo invertidas',547,@nError,CASE WHEN @nError=547 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Prerrequisito de sí misma */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@ma,@ma);
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Prerrequisito de sí misma',547,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Prerrequisito de sí misma',547,@nError,CASE WHEN @nError=547 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Prerrequisito fuera de retícula */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mc,@md);
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Prerrequisito fuera de retícula',547,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Prerrequisito fuera de retícula',547,@nError,CASE WHEN @nError=547 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Ciclo transitivo de prerrequisitos */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@ma,@mb);
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Ciclo transitivo de prerrequisitos',51016,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Ciclo transitivo de prerrequisitos',51016,@nError,CASE WHEN @nError=51016 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Duplicado de prerrequisito */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Duplicado de prerrequisito',2627,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Duplicado de prerrequisito',2627,@nError,CASE WHEN @nError=2627 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Conflicto docente mediante SP */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_RegistrarSesionGrupo @go,1,@a2,'10:30','11:30',@s OUTPUT;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Conflicto docente mediante SP',51002,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Conflicto docente mediante SP',51002,@nError,CASE WHEN @nError=51002 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Conflicto aula mediante SP */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_RegistrarSesionGrupo @gc,1,@a1,'12:30','13:30',@s OUTPUT;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Conflicto aula mediante SP',51003,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Conflicto aula mediante SP',51003,@nError,CASE WHEN @nError=51003 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Conflicto docente DML directo */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@go,1,@a2,'10:30','11:30');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Conflicto docente DML directo',51002,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Conflicto docente DML directo',51002,@nError,CASE WHEN @nError=51002 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Conflicto aula DML directo */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@gc,1,@a1,'12:30','13:30');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Conflicto aula DML directo',51003,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Conflicto aula DML directo',51003,@nError,CASE WHEN @nError=51003 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Empalme dentro del propio grupo */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@ga,1,@a2,'09:00','09:30');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Empalme dentro del propio grupo',51004,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Empalme dentro del propio grupo',51004,@nError,CASE WHEN @nError=51004 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Cambio de docente detecta empalme */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

UPDATE App.Tbl_Grupo SET nIdDocente=@d1 WHERE nIdGrupo=@gc;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Cambio de docente detecta empalme',51002,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Cambio de docente detecta empalme',51002,@nError,CASE WHEN @nError=51002 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Cambio de aula detecta empalme */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

UPDATE App.Tbl_SesionGrupo SET nIdAula=@a1 WHERE nIdGrupo=@gc;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Cambio de aula detecta empalme',51003,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Cambio de aula detecta empalme',51003,@nError,CASE WHEN @nError=51003 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Inserción multirregistro detecta empalme */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@ga,3,@a1,'08:00','10:00'),(@gb,3,@a1,'09:00','11:00');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Inserción multirregistro detecta empalme',51003,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Inserción multirregistro detecta empalme',51003,@nError,CASE WHEN @nError=51003 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Publicación impide docente faltante */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

UPDATE App.Tbl_Grupo SET nEstatus=1 WHERE nIdGrupo=@gm;EXEC App.Sp_PublicarOferta @p;

 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Publicación impide docente faltante',51012,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Publicación impide docente faltante',51012,@nError,CASE WHEN @nError=51012 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Publicación impide sesiones faltantes */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

UPDATE App.Tbl_Grupo SET nEstatus=1,nIdDocente=@d3 WHERE nIdGrupo=@gm;EXEC App.Sp_PublicarOferta @p;

 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Publicación impide sesiones faltantes',51012,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Publicación impide sesiones faltantes',51012,@nError,CASE WHEN @nError=51012 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Publicación congela grupos */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
UPDATE App.Tbl_Grupo SET cClaveGrupo='OTRO' WHERE nIdGrupo=@ga;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Publicación congela grupos',51300,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Publicación congela grupos',51300,@nError,CASE WHEN @nError=51300 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Publicación congela sesiones */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
UPDATE App.Tbl_SesionGrupo SET dHoraFin='09:30' WHERE nIdGrupo=@ga;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Publicación congela sesiones',51300,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Publicación congela sesiones',51300,@nError,CASE WHEN @nError=51300 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* RV001 materia repetida */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga),(@gx);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV001 materia repetida',51102,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV001 materia repetida',51102,@nError,CASE WHEN @nError=51102 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* RV002 empalme de estudiante */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga),(@gc);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV002 empalme de estudiante',51104,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV002 empalme de estudiante',51104,@nError,CASE WHEN @nError=51104 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* RV003 límite de créditos */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

UPDATE App.Tbl_TrayectoriaEstudiante SET nLimiteCreditos=6 WHERE nIdTrayectoria=@t;EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga),(@gb);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV003 límite de créditos',51105,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV003 límite de créditos',51105,@nError,CASE WHEN @nError=51105 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* RV004 prerrequisito pendiente */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

DELETE App.Tbl_HistorialAcademico WHERE nIdEstudiante=@e;EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV004 prerrequisito pendiente',51106,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV004 prerrequisito pendiente',51106,@nError,CASE WHEN @nError=51106 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* RV004 aprobación de periodo futuro no cuenta */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

UPDATE App.Tbl_HistorialAcademico SET nIdPeriodo=@p WHERE nIdEstudiante=@e;EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV004 aprobación de periodo futuro no cuenta',51106,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV004 aprobación de periodo futuro no cuenta',51106,@nError,CASE WHEN @nError=51106 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* RV005 periodo inactivo */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nIdPeriodo=@p; INSERT @L VALUES(@ga);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV005 periodo inactivo',51100,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV005 periodo inactivo',51100,@nError,CASE WHEN @nError=51100 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* RV005 grupo de otro periodo */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

UPDATE App.Tbl_Grupo SET nIdPeriodo=@pa WHERE nIdGrupo=@ga;EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV005 grupo de otro periodo',51103,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV005 grupo de otro periodo',51103,@nError,CASE WHEN @nError=51103 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* RV006 grupo inactivo */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@gi);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV006 grupo inactivo',51103,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV006 grupo inactivo',51103,@nError,CASE WHEN @nError=51103 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* RV007 materia ajena a retícula */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@go);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV007 materia ajena a retícula',51103,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'RV007 materia ajena a retícula',51103,@nError,CASE WHEN @nError=51103 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Horario vacío */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Horario vacío',51101,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Horario vacío',51101,@nError,CASE WHEN @nError=51101 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Confirmación directa vacía rechazada */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT App.Tbl_HorarioGenerado(nIdTrayectoria,nIdPeriodo,cNombre,nConfirmado) VALUES(@t,@p,N'Vacío',1);
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Confirmación directa vacía rechazada',51101,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Confirmación directa vacía rechazada',51101,@nError,CASE WHEN @nError=51101 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Confirmación directa valida duplicados */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT App.Tbl_HorarioGenerado(nIdTrayectoria,nIdPeriodo,cNombre) VALUES(@t,@p,N'Directo'); SET @h=SCOPE_IDENTITY(); INSERT App.Tbl_HorarioGeneradoDetalle VALUES(@h,@ga),(@h,@gx); UPDATE App.Tbl_HorarioGenerado SET nConfirmado=1 WHERE nIdHorarioGenerado=@h;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Confirmación directa valida duplicados',51102,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Confirmación directa valida duplicados',51102,@nError,CASE WHEN @nError=51102 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Plan de horario confirmado congelado */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;UPDATE App.Tbl_ReticulaMateria SET nCreditos=9 WHERE nIdReticula=@ret AND nIdMateria=@mb;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Plan de horario confirmado congelado',51301,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Plan de horario confirmado congelado',51301,@nError,CASE WHEN @nError=51301 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Detalle confirmado congelado */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;INSERT App.Tbl_HorarioGeneradoDetalle VALUES(@h,@gb);
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Detalle confirmado congelado',51306,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Detalle confirmado congelado',51306,@nError,CASE WHEN @nError=51306 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* No despublicar horario confirmado */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;UPDATE App.Tbl_PeriodoAcademico SET nOfertaPublicada=0 WHERE nIdPeriodo=@p;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'No despublicar horario confirmado',51013,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'No despublicar horario confirmado',51013,@nError,CASE WHEN @nError=51013 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Segunda opción sustituye selección */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

EXEC App.Sp_PublicarOferta @p;
INSERT @L VALUES(@ga);EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Prueba',@L,@h OUTPUT,1;EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Segunda',@L,@h OUTPUT,1; IF (SELECT COUNT(*) FROM App.Tbl_HorarioGenerado WHERE nIdTrayectoria=@t AND nSeleccionado=1)<>1 THROW 51901,N'Selección inconsistente.',1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Segunda opción sustituye selección',0,0,1,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Segunda opción sustituye selección',0,@nError,CASE WHEN @nError=0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Intento aprobado exige nota */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico) VALUES(@e,@mc,@pa,@apr);
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Intento aprobado exige nota',51014,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Intento aprobado exige nota',51014,@nError,CASE WHEN @nError=51014 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Pendiente no admite periodo */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico) SELECT @e,@mc,@pa,nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='PENDIENTE';
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Pendiente no admite periodo',51014,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Pendiente no admite periodo',51014,@nError,CASE WHEN @nError=51014 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Recursamientos conservan periodos */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion) VALUES(@e,@ma,@p,@apr,90); IF (SELECT COUNT(*) FROM App.Tbl_HistorialAcademico WHERE nIdEstudiante=@e AND nIdMateria=@ma)<>2 THROW 51901,N'Historial incompleto.',1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Recursamientos conservan periodos',0,0,1,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Recursamientos conservan periodos',0,@nError,CASE WHEN @nError=0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Trayectoria vigente única */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio) VALUES(@e,@ret,1,20,'20300101');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Trayectoria vigente única',2601,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Trayectoria vigente única',2601,@nError,CASE WHEN @nError=2601 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Trayectoria histórica no se solapa */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio,dFechaFin) VALUES(@e,@ret,1,20,'20210101','20220101');
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Trayectoria histórica no se solapa',51015,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Trayectoria histórica no se solapa',51015,@nError,CASE WHEN @nError=51015 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Runtime CRUD App, EXECUTE App y SELECT Rep reales */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';

SELECT TOP(0) nIdMateria FROM App.Cat_Materia;
SELECT TOP(0) nIdGrupo FROM Rep.Vi_OfertaAcademica;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CRUD',N'CRUD');
UPDATE App.Cat_Carrera SET cNombre=N'Editado' WHERE cClave='__QA_CRUD';
DELETE App.Cat_Carrera WHERE cClave='__QA_CRUD';
EXEC App.Sp_RegistrarSesionGrupo @ga,7,@a1,'08:00','09:00',@s OUTPUT;

REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;IF NOT EXISTS(SELECT 1 FROM Aud.Tbl_Auditoria WHERE cObjeto='Tbl_SesionGrupo' AND nIdRegistroAfectado=@s) THROW 51901,N'Ownership chain de auditoría no funcionó.',1;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime CRUD App, EXECUTE App y SELECT Rep reales',0,0,1,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime CRUD App, EXECUTE App y SELECT Rep reales',0,@nError,CASE WHEN @nError=0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Matriz de permisos y ausencia de DDL */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';

IF HAS_PERMS_BY_NAME('App','SCHEMA','SELECT')<>1 OR HAS_PERMS_BY_NAME('App','SCHEMA','INSERT')<>1
 OR HAS_PERMS_BY_NAME('App','SCHEMA','UPDATE')<>1 OR HAS_PERMS_BY_NAME('App','SCHEMA','DELETE')<>1
 OR HAS_PERMS_BY_NAME('App','SCHEMA','EXECUTE')<>1 OR HAS_PERMS_BY_NAME('Rep','SCHEMA','SELECT')<>1
 OR HAS_PERMS_BY_NAME('Rep','SCHEMA','INSERT')<>0 OR HAS_PERMS_BY_NAME('Rep','SCHEMA','UPDATE')<>0
 OR HAS_PERMS_BY_NAME('Rep','SCHEMA','DELETE')<>0 OR HAS_PERMS_BY_NAME('Rep','SCHEMA','EXECUTE')<>0
 OR HAS_PERMS_BY_NAME('Aud','SCHEMA','SELECT')<>0 OR HAS_PERMS_BY_NAME('Aud','SCHEMA','INSERT')<>0
 OR HAS_PERMS_BY_NAME('Aud','SCHEMA','UPDATE')<>0 OR HAS_PERMS_BY_NAME('Aud','SCHEMA','DELETE')<>0
 OR HAS_PERMS_BY_NAME('Aud','SCHEMA','EXECUTE')<>0 OR HAS_PERMS_BY_NAME('Aud','SCHEMA','VIEW DEFINITION')<>0
 OR HAS_PERMS_BY_NAME('App','SCHEMA','ALTER')<>0 OR HAS_PERMS_BY_NAME(DB_NAME(),'DATABASE','CREATE TABLE')<>0
 OR IS_ROLEMEMBER('db_owner')<>0 OR IS_ROLEMEMBER('db_ddladmin')<>0 OR IS_ROLEMEMBER('db_securityadmin')<>0
 THROW 51901,N'Matriz de permisos incorrecta.',1;

REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Matriz de permisos y ausencia de DDL',0,0,1,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Matriz de permisos y ausencia de DDL',0,@nError,CASE WHEN @nError=0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Runtime denegado SELECT Aud */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';
EXEC sys.sp_executesql N'SELECT nIdAuditoria FROM Aud.Tbl_Auditoria;';
REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado SELECT Aud',229,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado SELECT Aud',229,@nError,CASE WHEN @nError=229 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Runtime denegado INSERT Aud */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';
EXEC sys.sp_executesql N'INSERT Aud.Tbl_Auditoria(cOperacion,cEsquema,cObjeto) VALUES(''QA'',''App'',''QA'');';
REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado INSERT Aud',229,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado INSERT Aud',229,@nError,CASE WHEN @nError=229 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Runtime denegado UPDATE Aud */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';
EXEC sys.sp_executesql N'UPDATE Aud.Tbl_Auditoria SET cOperacion=''QA'';';
REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado UPDATE Aud',229,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado UPDATE Aud',229,@nError,CASE WHEN @nError=229 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Runtime denegado DELETE Aud */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';
EXEC sys.sp_executesql N'DELETE Aud.Tbl_Auditoria;';
REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado DELETE Aud',229,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado DELETE Aud',229,@nError,CASE WHEN @nError=229 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Runtime denegado EXECUTE Aud */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';
EXEC sys.sp_executesql N'EXEC Aud.Sp_RegistrarAuditoria ''QA'',''App'',''QA'';';
REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado EXECUTE Aud',229,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado EXECUTE Aud',229,@nError,CASE WHEN @nError=229 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Runtime denegado INSERT Rep */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';
EXEC sys.sp_executesql N'INSERT Rep.Vi_PeriodosAcademicos(cClave,cNombre,dFechaInicio,dFechaFin) VALUES(''__QA_REP'',N''Inválido'',''20400101'',''20400630'');';
REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado INSERT Rep',229,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado INSERT Rep',229,@nError,CASE WHEN @nError=229 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Runtime denegado UPDATE Rep */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';
EXEC sys.sp_executesql N'UPDATE Rep.Vi_PeriodosAcademicos SET cNombre=N''Inválido'';';
REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado UPDATE Rep',229,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado UPDATE Rep',229,@nError,CASE WHEN @nError=229 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
/* Runtime denegado DELETE Rep */
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;

SET NOCOUNT ON;
IF EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='__QA_CAR') THROW 51980,N'Ya existen claves QA; no se alteran.',1;
UPDATE App.Tbl_PeriodoAcademico SET nActivoGeneracion=0 WHERE nActivoGeneracion=1;
DECLARE @car int,@ret int,@ma int,@mb int,@mc int,@md int,@u int,@e int,@t int,@p int,@pa int,
 @d1 int,@d2 int,@d3 int,@a1 int,@a2 int,@ga int,@gb int,@gc int,@gx int,@go int,@gi int,@gm int,@h int,@s int,@apr tinyint;
DECLARE @L App.Tbl_ListaGrupo;
INSERT App.Cat_Carrera(cClave,cNombre) VALUES('__QA_CAR',N'Carrera de prueba'); SET @car=SCOPE_IDENTITY();
INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) VALUES(@car,'__QA_RET',N'Plan de prueba'); SET @ret=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_A',N'Antecedente'); SET @ma=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_B',N'Objetivo'); SET @mb=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_C',N'Libre'); SET @mc=SCOPE_IDENTITY();
INSERT App.Cat_Materia(cClave,cNombre) VALUES('__QA_D',N'Ajena al plan'); SET @md=SCOPE_IDENTITY();
INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 VALUES(@ret,@ma,1,4,1),(@ret,@mb,2,5,1),(@ret,@mc,1,6,1);
INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito) VALUES(@ret,@mb,@ma);
INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado) VALUES(N'__qa_usuario',N'__QA_USUARIO'); SET @u=SCOPE_IDENTITY();
INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl) VALUES(@u,'__QA_001'); SET @e=SCOPE_IDENTITY();
INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 VALUES(@e,@ret,2,15,'20200101'); SET @t=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D1',N'Docente uno'); SET @d1=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D2',N'Docente dos'); SET @d2=SCOPE_IDENTITY();
INSERT App.Tbl_Docente(cNumeroEmpleado,cNombre) VALUES('__QA_D3',N'Docente tres'); SET @d3=SCOPE_IDENTITY();
DECLARE @tipo int=(SELECT nIdTipoAula FROM App.Cat_TipoAula WHERE cClave='AULA');
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A1',30); SET @a1=SCOPE_IDENTITY();
INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) VALUES(@tipo,'__QA_A2',30); SET @a2=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('__QA_ANT',N'Anterior','20290101','20290630'); SET @pa=SCOPE_IDENTITY();
INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion) VALUES('__QA_ACT',N'Actual','20300101','20300630',1); SET @p=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B1'); SET @ga=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d2,@p,'C1'); SET @gb=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mc,@d3,@p,'C2'); SET @gc=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@mb,@d1,@p,'B2'); SET @gx=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@md,@d2,@p,'D1'); SET @go=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mc,@d2,@p,'INACTIVO',0); SET @gi=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdPeriodo,cClaveGrupo,nEstatus) VALUES(@mb,@p,'INCOMPLETO',0); SET @gm=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES
 (@ga,1,@a1,'08:00','10:00'),(@gb,1,@a1,'10:00','12:00'),(@gc,1,@a2,'09:00','11:00'),
 (@gx,1,@a1,'12:00','14:00'),(@go,1,@a1,'14:00','15:00'),(@gi,1,@a1,'15:00','16:00');
SELECT @apr=nIdEstatusAcademico FROM App.Cat_EstatusAcademico WHERE cClave='APROBADA';
INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 VALUES(@e,@ma,@pa,@apr,85);

BEGIN TRY EXECUTE AS USER=N'Usr_SistemaHorarios';
EXEC sys.sp_executesql N'DELETE Rep.Vi_PeriodosAcademicos;';
REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK TRANSACTION; REVERT; THROW; END CATCH;
 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado DELETE Rep',229,0,0,N'Operación completada');
END TRY
BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 INSERT #Resultados VALUES(N'Runtime denegado DELETE Rep',229,@nError,CASE WHEN @nError=229 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
SELECT cPrueba,nEsperado,nReal,nPaso,cDetalle FROM #Resultados ORDER BY nPaso,cPrueba;
SELECT COUNT(*) AS nTotal,SUM(CONVERT(int,nPaso)) AS nCorrectas FROM #Resultados;
/* Metadatos: restricciones activas/confiables y ausencia de columnas sin prefijo.
Se conserva sysdiagrams: objeto técnico de SSMS ajeno a los scripts de la aplicación. */
IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1)
 THROW 51990,N'Hay claves foráneas deshabilitadas o no confiables.',1;
IF EXISTS(SELECT 1 FROM sys.check_constraints WHERE is_disabled=1 OR is_not_trusted=1)
 THROW 51990,N'Hay CHECK deshabilitados o no confiables.',1;
IF EXISTS(SELECT 1 FROM sys.tables T WHERE is_ms_shipped=0 AND SCHEMA_NAME(T.schema_id)='dbo' AND T.name<>'sysdiagrams')
 THROW 51990,N'Hay tablas funcionales en dbo.',1;
IF EXISTS(SELECT 1 FROM sys.columns C JOIN sys.tables T ON T.object_id=C.object_id
 JOIN sys.types Y ON Y.user_type_id=C.user_type_id
 WHERE SCHEMA_NAME(T.schema_id) IN('App','Aud') AND ((Y.name IN('int','bigint','smallint','tinyint','bit','decimal','numeric') AND LEFT(C.name,1)<>'n')
 OR (Y.name IN('nvarchar','varchar','char','nchar') AND LEFT(C.name,1)<>'c')
 OR (Y.name IN('date','datetime','datetime2','datetimeoffset','time') AND LEFT(C.name,1)<>'d')))
 THROW 51990,N'Hay columnas fuera de nomenclatura.',1;
DBCC CHECKCONSTRAINTS WITH ALL_CONSTRAINTS,NO_INFOMSGS;
IF EXISTS(SELECT 1 FROM #Resultados WHERE nPaso=0) THROW 51999,N'Fallaron pruebas; revisar resultados.',1;
DROP TABLE #Resultados;
GO
