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
CREATE TYPE [App].[Tbl_ListaGrupo] AS TABLE (
    [nIdGrupo] [int] NOT NULL,
    PRIMARY KEY CLUSTERED ([nIdGrupo] ASC)
);
GO
