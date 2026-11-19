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
/* Interno. Debe llamarse dentro de transacción. Bloqueo común a SP y guards de DML. */
CREATE   PROCEDURE App.Sp_BloquearIntegridad
AS
BEGIN
 SET NOCOUNT ON;
 IF @@TRANCOUNT=0 THROW 51000,N'La operación de integridad requiere transacción.',1;
 IF (SELECT transaction_isolation_level FROM sys.dm_exec_sessions WHERE session_id=@@SPID)=5
  THROW 51000,N'Use READ COMMITTED para escrituras académicas, no SNAPSHOT.',1;
 DECLARE @nResultado int;
 EXEC @nResultado=sys.sp_getapplock @Resource=N'IntegridadSistemaHorarios',@LockMode='Exclusive',
  @LockOwner='Transaction',@LockTimeout=15000,@DbPrincipal='public';
 IF @nResultado<0 THROW 51000,N'No se obtuvo el bloqueo de integridad; reintente la transacción.',1;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Grupos activos publicados y sus sesiones para la materia y el periodo activo. */
CREATE   PROCEDURE App.Sp_ObtenerGruposMateria @nIdMateria int AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM App.Cat_Materia WHERE nIdMateria=@nIdMateria) THROW 51209,N'Materia inexistente.',1;
 SELECT G.nIdGrupo,G.cClaveGrupo,G.nIdDocente,G.nIdPeriodo,S.nIdSesionGrupo,S.nIdDiaSemana,S.nIdAula,S.dHoraInicio,S.dHoraFin
 FROM App.Tbl_Grupo G JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=G.nIdPeriodo
 JOIN App.Cat_Materia M ON M.nIdMateria=G.nIdMateria
 JOIN App.Tbl_SesionGrupo S ON S.nIdGrupo=G.nIdGrupo
 WHERE G.nIdMateria=@nIdMateria AND G.nEstatus=1 AND M.nEstatus=1 AND P.nActivoGeneracion=1 AND P.nOfertaPublicada=1
 ORDER BY G.cClaveGrupo,S.nIdDiaSemana,S.dHoraInicio;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Elegibilidad parametrizada para una persona; consulta no garantiza una futura escritura. */
CREATE   PROCEDURE App.Sp_ObtenerMateriasDisponibles @nIdEstudiante int AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_Estudiante WHERE nIdEstudiante=@nIdEstudiante) THROW 51208,N'Estudiante inexistente.',1;
 SELECT nIdTrayectoria,nIdEstudiante,nIdReticula,nIdPeriodo,nIdMateria,cClaveMateria,cMateria,nCreditos,nSemestreRecomendado,nObligatoria
 FROM App.Vi_MateriasDisponibles WHERE nIdEstudiante=@nIdEstudiante ORDER BY nSemestreRecomendado,cClaveMateria;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Diagnóstico de conflicto de aula; no sustituye el registro atómico. */
CREATE   PROCEDURE App.Sp_ValidarConflictoAula
 @nIdAula int,@nIdPeriodo int,@nIdDiaSemana tinyint,@dHoraInicio time(0),@dHoraFin time(0),
 @nHayConflicto bit OUTPUT,@nIdSesionExcluir int=NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF @dHoraInicio IS NULL OR @dHoraFin IS NULL OR @dHoraInicio>=@dHoraFin
  THROW 51200,N'Intervalo de horas inválido.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=@nIdDiaSemana)
  THROW 51201,N'Día de semana inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_Aula WHERE nIdAula=@nIdAula)
  THROW 51202,N'Aula inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico WHERE nIdPeriodo=@nIdPeriodo)
  THROW 51203,N'Periodo inexistente.',1;
 SELECT @nHayConflicto=CASE WHEN EXISTS (
 SELECT 1 FROM App.Tbl_SesionGrupo S WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=S.nIdGrupo
 WHERE S.nIdAula=@nIdAula
 AND G.nIdPeriodo=@nIdPeriodo AND G.nEstatus=1 AND S.nIdDiaSemana=@nIdDiaSemana
 AND (@nIdSesionExcluir IS NULL OR S.nIdSesionGrupo<>@nIdSesionExcluir)
 AND S.dHoraInicio<@dHoraFin AND @dHoraInicio<S.dHoraFin) THEN 1 ELSE 0 END;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Diagnóstico de conflicto de docente; no sustituye el registro atómico. */
CREATE   PROCEDURE App.Sp_ValidarConflictoDocente
 @nIdDocente int,@nIdPeriodo int,@nIdDiaSemana tinyint,@dHoraInicio time(0),@dHoraFin time(0),
 @nHayConflicto bit OUTPUT,@nIdSesionExcluir int=NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF @dHoraInicio IS NULL OR @dHoraFin IS NULL OR @dHoraInicio>=@dHoraFin
  THROW 51200,N'Intervalo de horas inválido.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=@nIdDiaSemana)
  THROW 51201,N'Día de semana inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_Docente WHERE nIdDocente=@nIdDocente)
  THROW 51202,N'Docente inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico WHERE nIdPeriodo=@nIdPeriodo)
  THROW 51203,N'Periodo inexistente.',1;
 SELECT @nHayConflicto=CASE WHEN EXISTS (
 SELECT 1 FROM App.Tbl_SesionGrupo S WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=S.nIdGrupo
 WHERE G.nIdDocente=@nIdDocente
 AND G.nIdPeriodo=@nIdPeriodo AND G.nEstatus=1 AND S.nIdDiaSemana=@nIdDiaSemana
 AND (@nIdSesionExcluir IS NULL OR S.nIdSesionGrupo<>@nIdSesionExcluir)
 AND S.dHoraInicio<@dHoraFin AND @dHoraInicio<S.dHoraFin) THEN 1 ELSE 0 END;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Solo administradores autorizados. No registra payload de credenciales. */
CREATE   PROCEDURE Aud.Sp_RegistrarAuditoria
 @cOperacion varchar(30),@cEsquema varchar(3),@cObjeto nvarchar(128),@nIdRegistroAfectado bigint=NULL,
 @nIdUsuario int=NULL,@cDatosAdicionales nvarchar(1000)=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @cOperacion IS NULL OR LEN(LTRIM(RTRIM(@cOperacion)))=0 THROW 51400,N'Operación de auditoría requerida.',1;
 INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado,cDatosAdicionales)
 VALUES(@nIdUsuario,@cOperacion,@cEsquema,@cObjeto,@nIdRegistroAfectado,@cDatosAdicionales);
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Sp_GuardarHorarioGenerado. Parámetros: trayectoria, periodo, nombre, TVP grupos, selección y actor. Valida RV-001..007. Afecta cabecera, detalle y auditoría.
Transacción propia o savepoint; errores personalizados; escritura y auditoría atómicas. */
CREATE   PROCEDURE App.Sp_GuardarHorarioGenerado 
 @nIdTrayectoria int,@nIdPeriodo int,@cNombre nvarchar(100),@Grupos App.Tbl_ListaGrupo READONLY,
 @nIdHorarioGenerado int OUTPUT,@nSeleccionar bit=0,@nIdUsuarioActor int=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 DECLARE @nTransaccionInicial int=@@TRANCOUNT;
 BEGIN TRY
  IF @nTransaccionInicial=0 BEGIN TRANSACTION; ELSE SAVE TRANSACTION SV_GuardarHorarioGenerado;
  EXEC App.Sp_BloquearIntegridad;
  
 IF @cNombre IS NULL OR LEN(LTRIM(RTRIM(@cNombre)))=0 THROW 51206,N'Indique el nombre del horario.',1;
 IF @nSeleccionar IS NULL THROW 51206,N'Indique si se seleccionará la opción.',1;
 IF NOT EXISTS (SELECT 1 FROM @Grupos) THROW 51101,N'El horario debe contener al menos un grupo.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_TrayectoriaEstudiante WITH (UPDLOCK,HOLDLOCK) WHERE nIdTrayectoria=@nIdTrayectoria)
  THROW 51207,N'Trayectoria inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico WITH (UPDLOCK,HOLDLOCK) WHERE nIdPeriodo=@nIdPeriodo AND nActivoGeneracion=1 AND nOfertaPublicada=1)
  THROW 51100,N'Periodo inactivo o sin oferta publicada.',1;
 IF EXISTS (SELECT 1 FROM @Grupos L LEFT JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=L.nIdGrupo WHERE G.nIdGrupo IS NULL)
  THROW 51204,N'Grupo inexistente.',1;
 INSERT App.Tbl_HorarioGenerado(nIdTrayectoria,nIdPeriodo,cNombre) VALUES(@nIdTrayectoria,@nIdPeriodo,@cNombre);
 SET @nIdHorarioGenerado=CONVERT(int,SCOPE_IDENTITY());
 INSERT App.Tbl_HorarioGeneradoDetalle(nIdHorarioGenerado,nIdGrupo) SELECT @nIdHorarioGenerado,nIdGrupo FROM @Grupos;
 IF @nSeleccionar=1 UPDATE App.Tbl_HorarioGenerado SET nSeleccionado=0 WHERE nIdTrayectoria=@nIdTrayectoria AND nIdPeriodo=@nIdPeriodo AND nSeleccionado=1;
 UPDATE App.Tbl_HorarioGenerado SET nConfirmado=1,nSeleccionado=@nSeleccionar WHERE nIdHorarioGenerado=@nIdHorarioGenerado;
 INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado)
 VALUES(@nIdUsuarioActor,'CONFIRMAR','App',N'Tbl_HorarioGenerado',@nIdHorarioGenerado);

  IF @nTransaccionInicial=0 COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF @nTransaccionInicial=0 AND XACT_STATE()<>0 ROLLBACK TRANSACTION;
  ELSE IF @nTransaccionInicial>0 AND XACT_STATE()=1 ROLLBACK TRANSACTION SV_GuardarHorarioGenerado;
  THROW;
 END CATCH;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Sp_PublicarOferta. Parámetros: periodo y actor. Afecta Periodo y auditoría. El guard comprueba RV-012 y empalmes.
Transacción propia o savepoint; errores personalizados; escritura y auditoría atómicas. */
CREATE   PROCEDURE App.Sp_PublicarOferta @nIdPeriodo int,@nIdUsuarioActor int=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 DECLARE @nTransaccionInicial int=@@TRANCOUNT;
 BEGIN TRY
  IF @nTransaccionInicial=0 BEGIN TRANSACTION; ELSE SAVE TRANSACTION SV_PublicarOferta;
  EXEC App.Sp_BloquearIntegridad;
  
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico WITH (UPDLOCK,HOLDLOCK) WHERE nIdPeriodo=@nIdPeriodo)
  THROW 51203,N'Periodo inexistente.',1;
 UPDATE App.Tbl_PeriodoAcademico SET nOfertaPublicada=1 WHERE nIdPeriodo=@nIdPeriodo;
 INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado)
 VALUES(@nIdUsuarioActor,'PUBLICAR','App',N'Tbl_PeriodoAcademico',@nIdPeriodo);

  IF @nTransaccionInicial=0 COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF @nTransaccionInicial=0 AND XACT_STATE()<>0 ROLLBACK TRANSACTION;
  ELSE IF @nTransaccionInicial>0 AND XACT_STATE()=1 ROLLBACK TRANSACTION SV_PublicarOferta;
  THROW;
 END CATCH;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Sp_RegistrarSesionGrupo. Parámetros: grupo, día, aula, intervalo y actor opcional. Afecta SesionGrupo y auditoría. Valida grupo y recursos.
Transacción propia o savepoint; errores personalizados; escritura y auditoría atómicas. */
CREATE   PROCEDURE App.Sp_RegistrarSesionGrupo 
 @nIdGrupo int,@nIdDiaSemana tinyint,@nIdAula int,@dHoraInicio time(0),@dHoraFin time(0),
 @nIdSesionGrupo int OUTPUT,@nIdUsuarioActor int=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 DECLARE @nTransaccionInicial int=@@TRANCOUNT;
 BEGIN TRY
  IF @nTransaccionInicial=0 BEGIN TRANSACTION; ELSE SAVE TRANSACTION SV_RegistrarSesionGrupo;
  EXEC App.Sp_BloquearIntegridad;
  
 IF @dHoraInicio IS NULL OR @dHoraFin IS NULL OR @dHoraInicio>=@dHoraFin THROW 51200,N'Intervalo de horas inválido.',1;
 DECLARE @nIdPeriodo int,@nIdDocente int,@nGrupoActivo bit,@nConflicto bit;
 SELECT @nIdPeriodo=nIdPeriodo,@nIdDocente=nIdDocente,@nGrupoActivo=nEstatus
 FROM App.Tbl_Grupo WITH (UPDLOCK,HOLDLOCK) WHERE nIdGrupo=@nIdGrupo;
 IF @nIdPeriodo IS NULL THROW 51204,N'Grupo inexistente.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_Aula WITH (READCOMMITTEDLOCK) WHERE nIdAula=@nIdAula AND nEstatus=1)
  THROW 51205,N'Aula inexistente o inactiva.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Cat_DiaSemana WHERE nIdDiaSemana=@nIdDiaSemana) THROW 51201,N'Día de semana inexistente.',1;
 IF @nGrupoActivo=1
 BEGIN
  IF @nIdDocente IS NOT NULL
  BEGIN
   EXEC App.Sp_ValidarConflictoDocente @nIdDocente,@nIdPeriodo,@nIdDiaSemana,@dHoraInicio,@dHoraFin,@nConflicto OUTPUT;
   IF @nConflicto=1 THROW 51002,N'Conflicto de docente en el mismo periodo.',1;
  END;
  EXEC App.Sp_ValidarConflictoAula @nIdAula,@nIdPeriodo,@nIdDiaSemana,@dHoraInicio,@dHoraFin,@nConflicto OUTPUT;
  IF @nConflicto=1 THROW 51003,N'Conflicto de aula en el mismo periodo.',1;
 END;
 INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin)
 VALUES(@nIdGrupo,@nIdDiaSemana,@nIdAula,@dHoraInicio,@dHoraFin);
 SET @nIdSesionGrupo=CONVERT(int,SCOPE_IDENTITY());
 INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado)
 VALUES(@nIdUsuarioActor,'INSERT','App',N'Tbl_SesionGrupo',@nIdSesionGrupo);

  IF @nTransaccionInicial=0 COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF @nTransaccionInicial=0 AND XACT_STATE()<>0 ROLLBACK TRANSACTION;
  ELSE IF @nTransaccionInicial>0 AND XACT_STATE()=1 ROLLBACK TRANSACTION SV_RegistrarSesionGrupo;
  THROW;
 END CATCH;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Selecciona una opción propia confirmada del periodo activo, de forma atómica.
La identidad del actor proviene del JWT verificado en la API; no del cuerpo de la petición.
Registra auditoría interna por ownership chaining, sin conceder acceso directo a Aud. */
CREATE   PROCEDURE App.Sp_SeleccionarHorarioGenerado @nIdUsuarioActor int,@nIdHorarioGenerado int
AS
BEGIN
 SET NOCOUNT ON;SET XACT_ABORT ON;
 DECLARE @nInicial int=@@TRANCOUNT,@nTrayectoria int,@nPeriodo int;
 BEGIN TRY
  IF @nInicial=0 BEGIN TRAN;ELSE SAVE TRAN SV_SeleccionarHorario;
  EXEC App.Sp_BloquearIntegridad;
  SELECT @nTrayectoria=H.nIdTrayectoria,@nPeriodo=H.nIdPeriodo FROM App.Tbl_HorarioGenerado H WITH(UPDLOCK,HOLDLOCK)
  JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdTrayectoria=H.nIdTrayectoria
  JOIN App.Tbl_Estudiante E ON E.nIdEstudiante=T.nIdEstudiante
  JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=H.nIdPeriodo
  WHERE H.nIdHorarioGenerado=@nIdHorarioGenerado AND H.nConfirmado=1 AND E.nIdUsuario=@nIdUsuarioActor
   AND E.nEstatus=1 AND T.dFechaFin IS NULL AND P.nActivoGeneracion=1 AND P.nOfertaPublicada=1;
  IF @nTrayectoria IS NULL THROW 52200,N'La opción no existe, no te pertenece o no está disponible en el periodo activo.',1;
  UPDATE App.Tbl_HorarioGenerado SET nSeleccionado=0 WHERE nIdTrayectoria=@nTrayectoria AND nIdPeriodo=@nPeriodo AND nSeleccionado=1;
  UPDATE App.Tbl_HorarioGenerado SET nSeleccionado=1 WHERE nIdHorarioGenerado=@nIdHorarioGenerado;
  INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado)
  VALUES(@nIdUsuarioActor,'SELECCIONAR','App','Tbl_HorarioGenerado',@nIdHorarioGenerado);
  IF @nInicial=0 COMMIT;
 END TRY BEGIN CATCH
  IF @nInicial=0 AND XACT_STATE()<>0 ROLLBACK;
  ELSE IF @nInicial>0 AND XACT_STATE()=1 ROLLBACK TRAN SV_SeleccionarHorario;
  THROW;
 END CATCH;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Interno. Valida una opción entera antes de confirmarla; no modifica datos. */
CREATE   PROCEDURE App.Sp_ValidarHorario @nIdHorarioGenerado int
AS
BEGIN
 SET NOCOUNT ON;
 EXEC App.Sp_BloquearIntegridad;
 DECLARE @nIdTrayectoria int,@nIdReticula int,@nIdEstudiante int,@nLimiteCreditos int,@nIdPeriodo int,@dInicio date;
 SELECT @nIdTrayectoria=H.nIdTrayectoria,@nIdPeriodo=H.nIdPeriodo,@nIdReticula=T.nIdReticula,
 @nIdEstudiante=T.nIdEstudiante,@nLimiteCreditos=T.nLimiteCreditos,@dInicio=P.dFechaInicio
 FROM App.Tbl_HorarioGenerado H WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_TrayectoriaEstudiante T WITH (READCOMMITTEDLOCK) ON T.nIdTrayectoria=H.nIdTrayectoria
 JOIN App.Tbl_Estudiante E WITH (READCOMMITTEDLOCK) ON E.nIdEstudiante=T.nIdEstudiante
 JOIN App.Tbl_Usuario U WITH (READCOMMITTEDLOCK) ON U.nIdUsuario=E.nIdUsuario
 JOIN App.Cat_Reticula R WITH (READCOMMITTEDLOCK) ON R.nIdReticula=T.nIdReticula
 JOIN App.Cat_Carrera C WITH (READCOMMITTEDLOCK) ON C.nIdCarrera=R.nIdCarrera
 JOIN App.Tbl_PeriodoAcademico P WITH (READCOMMITTEDLOCK) ON P.nIdPeriodo=H.nIdPeriodo
 WHERE H.nIdHorarioGenerado=@nIdHorarioGenerado AND T.dFechaFin IS NULL AND T.dFechaInicio<=P.dFechaInicio
 AND E.nEstatus=1 AND U.nEstatus=1 AND R.nEstatus=1 AND C.nEstatus=1 AND P.nActivoGeneracion=1 AND P.nOfertaPublicada=1;
 IF @nIdTrayectoria IS NULL THROW 51100,N'Horario, trayectoria o periodo activo/publicado no válidos.',1;
 IF NOT EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle WITH (READCOMMITTEDLOCK) WHERE nIdHorarioGenerado=@nIdHorarioGenerado)
  THROW 51101,N'El horario debe contener al menos un grupo.',1;
 IF EXISTS (SELECT G.nIdMateria FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado GROUP BY G.nIdMateria HAVING COUNT(*)>1)
  THROW 51102,N'RV-001: dos grupos de la misma materia.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 JOIN App.Cat_Materia M WITH (READCOMMITTEDLOCK) ON M.nIdMateria=G.nIdMateria
 LEFT JOIN App.Tbl_ReticulaMateria RM WITH (READCOMMITTEDLOCK) ON RM.nIdReticula=@nIdReticula AND RM.nIdMateria=G.nIdMateria
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado AND (G.nIdPeriodo<>@nIdPeriodo OR G.nEstatus=0 OR M.nEstatus=0 OR RM.nIdMateria IS NULL))
  THROW 51103,N'RV-005/006/007: grupo inactivo, ajeno al periodo o a la retícula.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_HorarioGeneradoDetalle B WITH (READCOMMITTEDLOCK) ON B.nIdHorarioGenerado=A.nIdHorarioGenerado AND A.nIdGrupo<B.nIdGrupo
 JOIN App.Tbl_SesionGrupo SA WITH (READCOMMITTEDLOCK) ON SA.nIdGrupo=A.nIdGrupo
 JOIN App.Tbl_SesionGrupo SB WITH (READCOMMITTEDLOCK) ON SB.nIdGrupo=B.nIdGrupo
 WHERE A.nIdHorarioGenerado=@nIdHorarioGenerado AND SA.nIdDiaSemana=SB.nIdDiaSemana
 AND SA.dHoraInicio<SB.dHoraFin AND SB.dHoraInicio<SA.dHoraFin)
  THROW 51104,N'RV-002: empalme entre grupos seleccionados.',1;
 IF (SELECT SUM(CONVERT(int,RM.nCreditos)) FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 JOIN App.Tbl_ReticulaMateria RM WITH (READCOMMITTEDLOCK) ON RM.nIdReticula=@nIdReticula AND RM.nIdMateria=G.nIdMateria
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado)>@nLimiteCreditos
  THROW 51105,N'RV-003: el horario supera el límite de créditos.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 JOIN App.Tbl_MateriaPrerrequisito PR WITH (READCOMMITTEDLOCK) ON PR.nIdReticula=@nIdReticula AND PR.nIdMateria=G.nIdMateria AND PR.nObligatorio=1
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado AND NOT EXISTS (
 SELECT 1 FROM App.Tbl_HistorialAcademico HA WITH (READCOMMITTEDLOCK)
 JOIN App.Cat_EstatusAcademico EA WITH (READCOMMITTEDLOCK) ON EA.nIdEstatusAcademico=HA.nIdEstatusAcademico
 JOIN App.Tbl_PeriodoAcademico PA WITH (READCOMMITTEDLOCK) ON PA.nIdPeriodo=HA.nIdPeriodo
 WHERE HA.nIdEstudiante=@nIdEstudiante AND HA.nIdMateria=PR.nIdMateriaPrerrequisito AND EA.cClave='APROBADA' AND PA.dFechaFin<@dInicio))
  THROW 51106,N'RV-004: falta aprobar un prerrequisito obligatorio antes del periodo.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGeneradoDetalle D WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) ON G.nIdGrupo=D.nIdGrupo
 JOIN App.Tbl_HistorialAcademico HA WITH (READCOMMITTEDLOCK) ON HA.nIdMateria=G.nIdMateria AND HA.nIdEstudiante=@nIdEstudiante
 JOIN App.Cat_EstatusAcademico EA WITH (READCOMMITTEDLOCK) ON EA.nIdEstatusAcademico=HA.nIdEstatusAcademico
 WHERE D.nIdHorarioGenerado=@nIdHorarioGenerado AND EA.cClave IN ('APROBADA','CURSANDO'))
  THROW 51107,N'La materia ya está aprobada o cursándose.',1;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
/* Interno. Estado global de oferta y dominios; ejecutado con el bloqueo transaccional adquirido. */
CREATE   PROCEDURE App.Sp_ValidarIntegridadOferta
AS
BEGIN
 SET NOCOUNT ON;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_SesionGrupo B WITH (READCOMMITTEDLOCK) ON A.nIdSesionGrupo<B.nIdSesionGrupo
 AND A.nIdDiaSemana=B.nIdDiaSemana AND A.dHoraInicio<B.dHoraFin AND B.dHoraInicio<A.dHoraFin
 JOIN App.Tbl_Grupo GA WITH (READCOMMITTEDLOCK) ON GA.nIdGrupo=A.nIdGrupo
 JOIN App.Tbl_Grupo GB WITH (READCOMMITTEDLOCK) ON GB.nIdGrupo=B.nIdGrupo
 WHERE GA.nEstatus=1 AND GB.nEstatus=1 AND GA.nIdPeriodo=GB.nIdPeriodo AND GA.nIdGrupo=GB.nIdGrupo)
  THROW 51004,N'El grupo contiene sesiones empalmadas.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_SesionGrupo B WITH (READCOMMITTEDLOCK) ON A.nIdSesionGrupo<B.nIdSesionGrupo
 AND A.nIdDiaSemana=B.nIdDiaSemana AND A.dHoraInicio<B.dHoraFin AND B.dHoraInicio<A.dHoraFin
 JOIN App.Tbl_Grupo GA WITH (READCOMMITTEDLOCK) ON GA.nIdGrupo=A.nIdGrupo
 JOIN App.Tbl_Grupo GB WITH (READCOMMITTEDLOCK) ON GB.nIdGrupo=B.nIdGrupo
 WHERE GA.nEstatus=1 AND GB.nEstatus=1 AND GA.nIdPeriodo=GB.nIdPeriodo AND GA.nIdDocente=GB.nIdDocente)
  THROW 51002,N'Conflicto de docente en el mismo periodo.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_SesionGrupo B WITH (READCOMMITTEDLOCK) ON A.nIdSesionGrupo<B.nIdSesionGrupo
 AND A.nIdDiaSemana=B.nIdDiaSemana AND A.dHoraInicio<B.dHoraFin AND B.dHoraInicio<A.dHoraFin
 JOIN App.Tbl_Grupo GA WITH (READCOMMITTEDLOCK) ON GA.nIdGrupo=A.nIdGrupo
 JOIN App.Tbl_Grupo GB WITH (READCOMMITTEDLOCK) ON GB.nIdGrupo=B.nIdGrupo
 WHERE GA.nEstatus=1 AND GB.nEstatus=1 AND GA.nIdPeriodo=GB.nIdPeriodo AND A.nIdAula=B.nIdAula)
  THROW 51003,N'Conflicto de aula en el mismo periodo.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_PeriodoAcademico P WITH (READCOMMITTEDLOCK)
 WHERE P.nOfertaPublicada=1 AND
 (NOT EXISTS (SELECT 1 FROM App.Tbl_Grupo G WITH (READCOMMITTEDLOCK) WHERE G.nIdPeriodo=P.nIdPeriodo AND G.nEstatus=1)
 OR EXISTS (SELECT 1 FROM App.Tbl_Grupo G WITH (READCOMMITTEDLOCK)
 LEFT JOIN App.Tbl_Docente D WITH (READCOMMITTEDLOCK) ON D.nIdDocente=G.nIdDocente
 JOIN App.Cat_Materia M WITH (READCOMMITTEDLOCK) ON M.nIdMateria=G.nIdMateria
 WHERE G.nIdPeriodo=P.nIdPeriodo AND G.nEstatus=1 AND
 (G.nIdDocente IS NULL OR (P.nActivoGeneracion=1 AND (D.nEstatus=0 OR M.nEstatus=0))
 OR NOT EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo S WITH (READCOMMITTEDLOCK) WHERE S.nIdGrupo=G.nIdGrupo)
 OR EXISTS (SELECT 1 FROM App.Tbl_SesionGrupo S WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_Aula A WITH (READCOMMITTEDLOCK) ON A.nIdAula=S.nIdAula
 JOIN App.Cat_TipoAula TA WITH (READCOMMITTEDLOCK) ON TA.nIdTipoAula=A.nIdTipoAula
 WHERE S.nIdGrupo=G.nIdGrupo AND P.nActivoGeneracion=1 AND (A.nEstatus=0 OR TA.nEstatus=0))))))
  THROW 51012,N'Oferta incompleta: requiere grupos activos, docentes, materias, sesiones y aulas habilitados.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HorarioGenerado H WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_PeriodoAcademico P WITH (READCOMMITTEDLOCK) ON P.nIdPeriodo=H.nIdPeriodo
 WHERE H.nConfirmado=1 AND P.nOfertaPublicada=0)
  THROW 51013,N'No se puede despublicar un periodo con horarios confirmados.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_HistorialAcademico H WITH (READCOMMITTEDLOCK)
 JOIN App.Cat_EstatusAcademico E WITH (READCOMMITTEDLOCK) ON E.nIdEstatusAcademico=H.nIdEstatusAcademico
 WHERE (E.cClave='PENDIENTE' AND (H.nIdPeriodo IS NOT NULL OR H.nCalificacion IS NOT NULL))
 OR (E.cClave<>'PENDIENTE' AND H.nIdPeriodo IS NULL)
 OR (E.cClave IN ('APROBADA','NO_APROBADA') AND H.nCalificacion IS NULL)
 OR (E.cClave='CURSANDO' AND H.nCalificacion IS NOT NULL))
  THROW 51014,N'Historial: periodo o calificación incompatibles con el estado académico.',1;
 IF EXISTS (SELECT 1 FROM App.Tbl_TrayectoriaEstudiante A WITH (READCOMMITTEDLOCK)
 JOIN App.Tbl_TrayectoriaEstudiante B WITH (READCOMMITTEDLOCK) ON A.nIdTrayectoria<B.nIdTrayectoria
 AND A.nIdEstudiante=B.nIdEstudiante AND A.dFechaInicio<=COALESCE(B.dFechaFin,CONVERT(date,'99991231'))
 AND B.dFechaInicio<=COALESCE(A.dFechaFin,CONVERT(date,'99991231')))
  THROW 51015,N'Las trayectorias del estudiante no pueden solaparse.',1;
 DECLARE @nCiclos int;
 ;WITH R AS (
 SELECT nIdReticula,nIdMateria,nIdMateriaPrerrequisito,
 CAST('/'+CONVERT(varchar(11),nIdMateria)+'/'+CONVERT(varchar(11),nIdMateriaPrerrequisito)+'/' AS varchar(max)) AS cRuta,
 CAST(0 AS int) AS nCiclo FROM App.Tbl_MateriaPrerrequisito WITH (READCOMMITTEDLOCK)
 UNION ALL
 SELECT R.nIdReticula,R.nIdMateria,P.nIdMateriaPrerrequisito,
 CAST(R.cRuta+CONVERT(varchar(11),P.nIdMateriaPrerrequisito)+'/' AS varchar(max)),
 CASE WHEN CHARINDEX('/'+CONVERT(varchar(11),P.nIdMateriaPrerrequisito)+'/',R.cRuta)>0 THEN 1 ELSE 0 END
 FROM R JOIN App.Tbl_MateriaPrerrequisito P WITH (READCOMMITTEDLOCK)
 ON P.nIdReticula=R.nIdReticula AND P.nIdMateria=R.nIdMateriaPrerrequisito WHERE R.nCiclo=0)
 SELECT @nCiclos=COUNT(*) FROM R WHERE nCiclo=1 OPTION (MAXRECURSION 32767);
 IF @nCiclos>0 THROW 51016,N'La relación de prerrequisitos contiene un ciclo.',1;
END;
GO
