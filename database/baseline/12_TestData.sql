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
/* Ficticios exclusivamente de desarrollo. Por defecto todo se revierte, incluidos eventos de auditoría.
Para conservarlos en una base de desarrollo aislada, revisar el fixture y sustituir ROLLBACK por COMMIT. */
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
 INSERT @L(nIdGrupo) VALUES(@ga),(@gb);
 EXEC App.Sp_GuardarHorarioGenerado @t,@p,N'Opción de demostración',@L,@h OUTPUT,1;
 SELECT nIdHorarioGenerado,nTotalCreditos,nTotalGrupos,nSeleccionado FROM Rep.Vi_ResumenHorarios WHERE nIdHorarioGenerado=@h;
 ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
GO
