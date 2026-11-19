# Estructura vigente de Bd_SistemaHorarios

Exportación de metadatos de los esquemas App, Rep y Aud. Las definiciones de procedimientos, vistas y triggers se obtienen directamente de `sys.sql_modules`; las tablas, tipos, índices y restricciones se reconstruyen desde los catálogos del servidor. El inventario no consulta filas de las tablas de la aplicación.

| Objeto | Cantidad |
|---|---:|
| Esquemas | 3 |
| Tablas | 26 |
| Tipo tabla para TVP | 1 |
| Vistas | 8 |
| Procedimientos almacenados | 12 |
| Triggers | 18 |
| Claves foráneas | 31 |
| CHECK | 39 |
| DEFAULT | 25 |
| Índices, incluidos PK/UNIQUE y el PK del TVP | 66 |

## Archivos

`00_Instalacion_completa.sql` reúne los siguientes archivos, en orden:

1. `01_Base_y_esquemas.sql`: creación de base y esquemas, con collation Modern_Spanish_CI_AS.
2. `02_Tipos_tabla.sql`: App.Tbl_ListaGrupo.
3. `03_Tablas_y_restricciones.sql`: columnas actuales, IDENTITY, nulabilidad, PK, UNIQUE, CHECK y DEFAULT. Incluye el control CHAR(8), nombre, año y generación del estudiante.
4. `04_Indices.sql`: índices adicionales, claves incluidas y filtros.
5. `05_Claves_foraneas.sql`: relaciones, acciones referenciales y restricciones confiables.
6. `06_Vistas_y_funciones.sql`: las ocho vistas actuales; actualmente no existen funciones propias.
7. `07_Procedimientos.sql`: los doce procedimientos, incluido el guardado y la selección de horarios.
8. `08_Triggers.sql`: los dieciocho triggers de integridad.
9. `09_Seguridad_sin_credenciales.sql`: rol runtime, usuario sin login, permisos App, lectura de Rep, denegación de Aud y REFERENCES sobre el TVP.

`Inventario_objetos.json` contiene los metadatos de origen. `Manifiesto_exportacion.json` identifica los archivos SQL mediante SHA-256. Los SQL se guardan como UTF-8 con BOM y saltos LF; `.gitattributes` conserva ese formato al clonarlos en cualquier plataforma para que los hashes sean reproducibles. `Validacion_sintaxis.json` registra el análisis de los diez archivos mediante el parser oficial ScriptDom de Microsoft.

## Instalación en una base nueva

Requiere SQL Server 2022 o posterior y una identidad de despliegue con permisos para crear la base y sus objetos. Ejecute con autenticación Windows desde la raíz del proyecto, cambiando el servidor por el de la instalación nueva:

```powershell
sqlcmd -S '[SERVIDOR_DESTINO]' -E -C -I -b -f 65001 -i '.\database\actual\00_Instalacion_completa.sql'
```

Si utiliza SSMS, puede abrir el script completo. El primer archivo comprueba si ya existen objetos de la aplicación: en ese caso informa el error y activa NOEXEC para evitar reemplazarlos; el final restablece NOEXEC OFF. Con sqlcmd, `-b` finaliza al detectar el error.

Para cargar los datos sintéticos de la demostración en esa base nueva, ejecute después `../11_SeedCatalogs.sql`, `../12_TestData.sql` y `../14_DataValidation.sql`, con `-E -C -I -b -f 65001`. Puede ejecutar `../13_NegativeTests.sql` para comprobar los rechazos con rollback. No necesita aplicar la migración 10 ni el script 15: sus cambios ya están incluidos en esta estructura.

El login del servidor, la contraseña runtime, la clave JWT y los accesos demo se configuran por separado con `tools/Initialize-LocalSecrets.ps1` y el seeder Identity descrito en el README principal. El usuario SQL del archivo 09 se crea WITHOUT LOGIN para mantener portable el esquema y permitir ese aprovisionamiento posterior.

## Alcance y comprobaciones

La exportación incluye los objetos funcionales App/Rep/Aud. Los objetos técnicos de diagramas de SSMS en dbo, archivos MDF/LDF, configuración física de la instancia, hashes de usuarios y filas de auditoría no forman parte de esta entrega. Los datos sintéticos se conservan en el script de semilla separado.

Se comparan los conteos con el inventario y se analiza la sintaxis SQL. La protección de instalación se comprueba contra la base existente, verificando que rechaza la ejecución antes de crear o alterar objetos. No se presenta este análisis como una restauración ejecutada en una instancia nueva.

Para regenerar la exportación, con Python 3.10+ y sqlcmd disponibles, desde la raíz:

```powershell
python .\tools\ExportDatabaseObjects.py --server 'lpc:LAPTOPMASEB\DBA_TOPICOS'
```

El generador rechaza objetos especializados que no sabe reproducir para evitar omitirlos silenciosamente. La seguridad portable toma como base el contrato de permisos versionado en `database/baseline/03_CreateSecurity.sql`; no exporta inicios de sesión ni secretos del servidor.
