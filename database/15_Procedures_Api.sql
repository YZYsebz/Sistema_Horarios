SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO
USE [Bd_SistemaHorarios];
GO
/* Selecciona una opción propia confirmada del periodo activo, de forma atómica.
La identidad del actor proviene del JWT verificado en la API; no del cuerpo de la petición.
Registra auditoría interna por ownership chaining, sin conceder acceso directo a Aud. */
CREATE OR ALTER PROCEDURE App.Sp_SeleccionarHorarioGenerado @nIdUsuarioActor int,@nIdHorarioGenerado int
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
