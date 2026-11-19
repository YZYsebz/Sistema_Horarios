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
/* Cada caso comienza transacción y termina en rollback, también cuando el error esperado invalida la transacción. */
CREATE TABLE #Resultados(cPrueba nvarchar(150),nEsperado int,nReal int,nCorrecta bit,cDetalle nvarchar(2048));
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl,cNombre,nAnioIngreso,nGeneracion) VALUES(@nUsuario,@cControl,N'Estudiante Negativo',2024,24);
 ROLLBACK;
 INSERT #Resultados VALUES(N'Número de control duplicado',2627,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Número de control duplicado',2627,@nError,CASE WHEN @nError=2627 AND CHARINDEX(N'UQ_Tbl_Estudiante_cNumeroControl',@cError)>0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl,cNombre,nAnioIngreso,nGeneracion) VALUES(@nUsuario,'2424001',N'Estudiante Negativo',2024,24);
 ROLLBACK;
 INSERT #Resultados VALUES(N'Número de control con siete dígitos',547,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Número de control con siete dígitos',547,@nError,CASE WHEN @nError=547 AND CHARINDEX(N'CK_Tbl_Estudiante_NumeroControl8',@cError)>0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl,cNombre,nAnioIngreso,nGeneracion) VALUES(@nUsuario,'2424ABCD',N'Estudiante Negativo',2024,24);
 ROLLBACK;
 INSERT #Resultados VALUES(N'Número de control con letras',547,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Número de control con letras',547,@nError,CASE WHEN @nError=547 AND CHARINDEX(N'CK_Tbl_Estudiante_NumeroControl8',@cError)>0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl,cNombre,nAnioIngreso,nGeneracion) VALUES(@nUsuario,'242400001',N'Estudiante Negativo',2024,24);
 ROLLBACK;
 INSERT #Resultados VALUES(N'Número de control con nueve dígitos',2628,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Número de control con nueve dígitos',2628,@nError,CASE WHEN @nError=2628 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl,cNombre,nAnioIngreso,nGeneracion) VALUES(@nUsuario,'25251234',N'Estudiante Negativo',2024,24);
 ROLLBACK;
 INSERT #Resultados VALUES(N'Año de ingreso incompatible',547,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Año de ingreso incompatible',547,@nError,CASE WHEN @nError=547 AND CHARINDEX(N'CK_Tbl_Estudiante_IngresoGeneracion',@cError)>0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT App.Cat_Materia(cClave,cNombre) VALUES('ACF-0901',N'Duplicada');
 ROLLBACK;
 INSERT #Resultados VALUES(N'Materia duplicada',2627,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Materia duplicada',2627,@nError,CASE WHEN @nError=2627 AND CHARINDEX(N'UQ_Cat_Materia_cClave',@cError)>0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) SELECT nIdTipoAula,'D6',30 FROM App.Cat_TipoAula WHERE cClave='AULA';
 ROLLBACK;
 INSERT #Resultados VALUES(N'Aula duplicada',2627,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Aula duplicada',2627,@nError,CASE WHEN @nError=2627 AND CHARINDEX(N'UQ_Tbl_Aula_cClave',@cError)>0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) SELECT TOP(1) nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo FROM App.Tbl_Grupo;
 ROLLBACK;
 INSERT #Resultados VALUES(N'Grupo duplicado',2627,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Grupo duplicado',2627,@nError,CASE WHEN @nError=2627 AND CHARINDEX(N'UQ_Tbl_Grupo_nIdPeriodo_nIdMateria_cClaveGrupo',@cError)>0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;


INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('NEG-PRUEBA',N'Prueba revertida','20270101','20270630'); SET @nPruebaPeriodo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente,@nPruebaPeriodo,'NEG1'); SET @nGrupo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente2,@nPruebaPeriodo,'NEG2'); SET @nGrupo2=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo,1,@nAula,'08:00','10:00');
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,2,@nAula2,'10:00','08:00');
 ROLLBACK;
 INSERT #Resultados VALUES(N'Sesión con horas invertidas',547,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Sesión con horas invertidas',547,@nError,CASE WHEN @nError=547 AND CHARINDEX(N'CK_Tbl_SesionGrupo_Horas',@cError)>0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;


INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('NEG-PRUEBA',N'Prueba revertida','20270101','20270630'); SET @nPruebaPeriodo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente,@nPruebaPeriodo,'NEG1'); SET @nGrupo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente2,@nPruebaPeriodo,'NEG2'); SET @nGrupo2=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo,1,@nAula,'08:00','10:00');
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,9,@nAula2,'10:00','11:00');
 ROLLBACK;
 INSERT #Resultados VALUES(N'Día inexistente',547,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Día inexistente',547,@nError,CASE WHEN @nError=547 AND CHARINDEX(N'FK_Tbl_SesionGrupo_Cat_DiaSemana',@cError)>0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;


INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('NEG-PRUEBA',N'Prueba revertida','20270101','20270630'); SET @nPruebaPeriodo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente,@nPruebaPeriodo,'NEG1'); SET @nGrupo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente,@nPruebaPeriodo,'NEG2'); SET @nGrupo2=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo,1,@nAula,'08:00','10:00');
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,1,@nAula2,'09:00','11:00');
 ROLLBACK;
 INSERT #Resultados VALUES(N'Choque de docente',51002,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Choque de docente',51002,@nError,CASE WHEN @nError=51002 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;


INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('NEG-PRUEBA',N'Prueba revertida','20270101','20270630'); SET @nPruebaPeriodo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente,@nPruebaPeriodo,'NEG1'); SET @nGrupo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente2,@nPruebaPeriodo,'NEG2'); SET @nGrupo2=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo,1,@nAula,'08:00','10:00');
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,1,@nAula,'09:00','11:00');
 ROLLBACK;
 INSERT #Resultados VALUES(N'Choque de aula',51003,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Choque de aula',51003,@nError,CASE WHEN @nError=51003 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;


INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin) VALUES('NEG-PRUEBA',N'Prueba revertida','20270101','20270630'); SET @nPruebaPeriodo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente,@nPruebaPeriodo,'NEG1'); SET @nGrupo=SCOPE_IDENTITY();
INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo) VALUES(@nMateria,@nDocente,@nPruebaPeriodo,'NEG2'); SET @nGrupo2=SCOPE_IDENTITY();
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo,1,@nAula,'08:00','10:00');
INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin) VALUES(@nGrupo2,1,@nAula,'10:00','12:00');
 ROLLBACK;
 INSERT #Resultados VALUES(N'Sesiones contiguas válidas',0,0,1,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Sesiones contiguas válidas',0,@nError,CASE WHEN @nError=0 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT @Grupos SELECT G.nIdGrupo FROM App.Tbl_Grupo G JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria WHERE G.nIdPeriodo=@nPeriodo AND M.cClave=N'ACF-0901' AND G.cClaveGrupo=N'1T1';
INSERT @Grupos SELECT G.nIdGrupo FROM App.Tbl_Grupo G JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria WHERE G.nIdPeriodo=@nPeriodo AND M.cClave=N'ACF-0901' AND G.cClaveGrupo=N'1T2';
EXEC App.Sp_GuardarHorarioGenerado @nTrayectoria,@nPeriodo,N'NEGATIVO',@Grupos,@nHorario OUTPUT;
 ROLLBACK;
 INSERT #Resultados VALUES(N'RV001 materia repetida',51102,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'RV001 materia repetida',51102,@nError,CASE WHEN @nError=51102 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT @Grupos SELECT G.nIdGrupo FROM App.Tbl_Grupo G JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria WHERE G.nIdPeriodo=@nPeriodo AND M.cClave=N'ACF-0901' AND G.cClaveGrupo=N'1T1';
INSERT @Grupos SELECT G.nIdGrupo FROM App.Tbl_Grupo G JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria WHERE G.nIdPeriodo=@nPeriodo AND M.cClave=N'ACF-0902' AND G.cClaveGrupo=N'2T1';
EXEC App.Sp_GuardarHorarioGenerado @nTrayectoria,@nPeriodo,N'NEGATIVO',@Grupos,@nHorario OUTPUT;
 ROLLBACK;
 INSERT #Resultados VALUES(N'RV002 empalme del estudiante',51104,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'RV002 empalme del estudiante',51104,@nError,CASE WHEN @nError=51104 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

UPDATE App.Tbl_TrayectoriaEstudiante SET nLimiteCreditos=1 WHERE nIdTrayectoria=@nTrayectoria;INSERT @Grupos SELECT G.nIdGrupo FROM App.Tbl_Grupo G JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria WHERE G.nIdPeriodo=@nPeriodo AND M.cClave=N'ACF-0901' AND G.cClaveGrupo=N'1T1';
EXEC App.Sp_GuardarHorarioGenerado @nTrayectoria,@nPeriodo,N'NEGATIVO',@Grupos,@nHorario OUTPUT;
 ROLLBACK;
 INSERT #Resultados VALUES(N'RV003 créditos excesivos',51105,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'RV003 créditos excesivos',51105,@nError,CASE WHEN @nError=51105 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

INSERT @Grupos SELECT G.nIdGrupo FROM App.Tbl_Grupo G JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria WHERE G.nIdPeriodo=@nPeriodo AND M.cClave=N'AED-1286' AND G.cClaveGrupo=N'2T1';
EXEC App.Sp_GuardarHorarioGenerado @nTrayectoria,@nPeriodo,N'NEGATIVO',@Grupos,@nHorario OUTPUT;
 ROLLBACK;
 INSERT #Resultados VALUES(N'RV004 prerrequisito sin aprobar',51106,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'RV004 prerrequisito sin aprobar',51106,@nError,CASE WHEN @nError=51106 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

DECLARE @nVacio App.Tbl_ListaGrupo; EXEC App.Sp_GuardarHorarioGenerado @nTrayectoria,@nPeriodo,N'Vacío',@nVacio,@nHorario OUTPUT;
 ROLLBACK;
 INSERT #Resultados VALUES(N'Horario vacío',51101,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Horario vacío',51101,@nError,CASE WHEN @nError=51101 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

UPDATE App.Tbl_Grupo SET cClaveGrupo='CAMBIO' WHERE nIdGrupo=(SELECT MIN(nIdGrupo) FROM App.Tbl_Grupo);
 ROLLBACK;
 INSERT #Resultados VALUES(N'Oferta publicada congelada',51300,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Oferta publicada congelada',51300,@nError,CASE WHEN @nError=51300 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
BEGIN TRY
 BEGIN TRANSACTION;

DECLARE @nUsuario int=(SELECT nIdUsuario FROM App.Tbl_Usuario WHERE cNombreUsuario='docente.001');
DECLARE @cControl char(8)=(SELECT TOP(1) cNumeroControl FROM App.Tbl_Estudiante ORDER BY nIdEstudiante);
DECLARE @nMateria int=(SELECT nIdMateria FROM App.Cat_Materia WHERE cClave='ACF-0901');
DECLARE @nDocente int=(SELECT MIN(nIdDocente) FROM App.Tbl_Docente),@nDocente2 int=(SELECT MAX(nIdDocente) FROM App.Tbl_Docente);
DECLARE @nAula int=(SELECT MIN(nIdAula) FROM App.Tbl_Aula),@nAula2 int=(SELECT MAX(nIdAula) FROM App.Tbl_Aula);
DECLARE @nPeriodo int=(SELECT nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1);
DECLARE @nTrayectoria int=(SELECT MIN(nIdTrayectoria) FROM App.Tbl_TrayectoriaEstudiante WHERE nSemestreActual=1);
DECLARE @nGrupo int,@nGrupo2 int,@nPruebaPeriodo int,@nHorario int;
DECLARE @Grupos App.Tbl_ListaGrupo;

BEGIN TRY EXECUTE AS USER='Usr_SistemaHorarios'; EXEC sys.sp_executesql N'SELECT nIdAuditoria FROM Aud.Tbl_Auditoria;'; REVERT; END TRY BEGIN CATCH IF XACT_STATE()=-1 ROLLBACK; REVERT; THROW; END CATCH;
 ROLLBACK;
 INSERT #Resultados VALUES(N'Runtime no puede consultar Aud',229,0,0,N'Operación válida');
END TRY BEGIN CATCH
 DECLARE @nError int=ERROR_NUMBER(),@cError nvarchar(2048)=ERROR_MESSAGE();
 IF XACT_STATE()<>0 ROLLBACK;
 INSERT #Resultados VALUES(N'Runtime no puede consultar Aud',229,@nError,CASE WHEN @nError=229 THEN 1 ELSE 0 END,@cError);
END CATCH;
GO
SELECT cPrueba,nEsperado,nReal,nCorrecta,cDetalle FROM #Resultados ORDER BY nCorrecta,cPrueba;
SELECT COUNT(*) AS nTotal,SUM(CONVERT(int,nCorrecta)) AS nCorrectas FROM #Resultados;
IF EXISTS(SELECT 1 FROM #Resultados WHERE nCorrecta=0) THROW 52010,N'Fallaron pruebas negativas.',1;
DROP TABLE #Resultados;
GO
