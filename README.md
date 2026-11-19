# Sistema de Generación y Validación de Horarios Académicos

Aplicación local para Ingeniería en Sistemas Computacionales. Trabaja sobre la base existente **Bd_SistemaHorarios**, conserva sus esquemas App, Rep y Aud, y completa el flujo **login → materias disponibles → selección → créditos → generación → guardado → horario seleccionado**.

Todo el proyecto, incluido el SDK local, dependencias, cachés y secretos de desarrollo, está dentro de esta carpeta. Fecha de comprobación: **17 de noviembre de 2026**.

## Arranque en este equipo

Abra **PowerShell 7** en esta carpeta y ejecute:

```powershell
.\Iniciar.ps1
```

El script compila el backend, inicia ambos servidores en segundo plano y comprueba que responden. Después abra:

- Aplicación: http://127.0.0.1:5173/
- Swagger: http://127.0.0.1:5080/swagger
- Salud: http://127.0.0.1:5080/api/health

Para reiniciar sin recompilar: `.\Iniciar.ps1 -SinCompilar`. Para detener únicamente los procesos del proyecto: `.\Detener.ps1`. Los PID y logs están en `.local/`. Si modifica C#, detenga la API antes de compilar; Windows bloquea sus DLL mientras está ejecutándose.

## Cuentas de prueba

| Usuario | Rol | Uso |
|---|---|---|
| estudiante.24248001 | ESTUDIANTE | Seleccionar materias, generar y guardar horarios propios |
| docente.001 | DOCENTE | Consultar sus grupos |
| coordinador.demo | COORDINADOR | Consultar los catálogos académicos |

Las tres contraseñas son aleatorias y distintas. Consúltelas **localmente** mediante:

```powershell
(Get-Content .\.secrets\development.json -Raw | ConvertFrom-Json).DemoUsers |
    Select-Object UserName, Password
```

El archivo es privado y está excluido de Git. Las contraseñas de los usuarios se guardan **hasheadas por ASP.NET Core Identity en SQL Server**. Los restantes usuarios sintéticos no tienen contraseña habilitada. El archivo privado conserva los accesos iniciales de demostración; no se incorporan al código ni a la documentación pública.

## Demostración del flujo

1. Ingrese como `estudiante.24248001`.
2. Abra **Materias disponibles**, filtre por quinto semestre y agregue las seis materias de referencia.
3. En **Mi selección**, el servidor valida **26 créditos de un máximo de 36**.
4. Pulse **Continuar a horarios → Generar horarios**.
5. Revise la opción y su calendario; escriba un nombre y pulse **Guardar horario**.
6. En **Mi horario** puede consultar todas sus opciones y marcar una como seleccionada. La selección es exclusiva para estudiante y periodo.

Las seis materias de referencia tienen un grupo cada una: generan una sola combinación válida. La oferta sintética también contiene alternativas para otras materias. El generador limita la salida a 20 opciones y explora como máximo 50 000 estados por solicitud.

La sesión JWT y la selección provisional viven en memoria del navegador. Al recargar se inicia sesión otra vez; los horarios guardados permanecen en SQL Server.

## Tecnologías y arquitectura

- Backend: .NET SDK **10.0.404**, ASP.NET Core 10, EF Core/Identity/JWT **10.0.15**, Swagger mediante Swashbuckle **11.0.1**.
- Frontend: React **19.3.1**, TypeScript **7.0.2**, Vite **8.3.8**, Bootstrap **5.3.9**, Axios **1.21.1**.
- Pruebas: xUnit y Vitest; integración HTTP real con PowerShell.
- SQL Server 2022 o posterior; instancia comprobada: **LAPTOPMASEB\DBA_TOPICOS**.

```text
SistemaHorarios.sln
backend/
  SistemaHorarios.Domain/          Entidades y validadores puros
  SistemaHorarios.Application/     Contratos y casos de uso
  SistemaHorarios.Infrastructure/  EF Core, Identity, SQL y servicios
  SistemaHorarios.Api/             HTTP, JWT, roles, Swagger y errores
frontend/src/
  api/ components/ layouts/ models/ pages/
  routes/ services/ hooks/ utils/
database/
  baseline/                       Diseño SQL recibido de la etapa anterior
  10_StudentRequirements.sql       Migración acotada de estudiantes
  11_SeedCatalogs.sql
  12_TestData.sql
  13_NegativeTests.sql
  14_DataValidation.sql
  15_Procedures_Api.sql
tests/
  SistemaHorarios.UnitTests/
  integration/SmokeApi.ps1
docs/
  Arquitectura.md
  Fases_y_validacion.md
  fase1/Datos_fuentes_y_sinteticos.json
  fase1/Resultado_validacion.json
tools/
.tools/ .cache/ .local/ .secrets/   Recursos privados/locales, excluidos de Git
```

## Configuración SQL y primera instalación

**En este equipo la base, los datos y las cuentas ya están preparados. No necesita volver a cargarlos para iniciar la aplicación.**

El despliegue y las comprobaciones DBA utilizan la **autenticación Windows indicada por el usuario**:

```powershell
sqlcmd -S 'lpc:LAPTOPMASEB\DBA_TOPICOS' -E -C -I -b -Q 'SELECT @@SERVERNAME;'
```

El prefijo `lpc:` selecciona memoria compartida local. La aplicación usa el login separado **Usr_SistemaHorarios**, miembro de **Rol_AppSistemaHorarios**, con los permisos runtime definidos en el diseño; no utiliza la identidad DBA Windows. La instancia comprobada admite autenticación mixta.

Para crear la estructura vigente en una instancia nueva, dispone del [script SQL completo y los objetos exportados](database/actual/README.md), con su inventario, verificaciones y guía de instalación. La carpeta [database](database/README.md) reúne también los datos de prueba y las validaciones.

Como alternativa al script completo, puede ejecutar los scripts `database/baseline/01` a `11`, en orden, con una identidad de despliegue autorizada, y aplicar la secuencia siguiente. Los archivos `baseline/12` y `baseline/13` son fixtures antiguos archivados. No ejecute ambas rutas de creación sobre la misma base. En una base con datos propios, revise primero la compatibilidad de la migración; esta aborta ante controles incompatibles.

```powershell
. .\tools\Use-ProjectEnvironment.ps1
foreach ($script in @(
  '10_StudentRequirements.sql', '11_SeedCatalogs.sql', '12_TestData.sql',
  '13_NegativeTests.sql', '14_DataValidation.sql', '15_Procedures_Api.sql'
)) {
  sqlcmd -S 'lpc:LAPTOPMASEB\DBA_TOPICOS' -E -C -I -b -f 65001 -i ".\database\$script"
  if ($LASTEXITCODE -ne 0) { throw "Falló $script" }
}
```

Las consultas deben terminar con **BASE DE DATOS VALIDADA** y **BASE DE DATOS LISTA PARA DESARROLLO**. La semilla es transaccional, determinista y reconoce su marcador: repetirla no duplica ni reemplaza horarios confirmados.

Preparación de secretos y accesos en una instalación nueva:

```powershell
. .\tools\Use-ProjectEnvironment.ps1
.\tools\Initialize-LocalSecrets.ps1
dotnet restore SistemaHorarios.sln
dotnet build SistemaHorarios.sln
dotnet .\backend\SistemaHorarios.Api\bin\Debug\net10.0\SistemaHorarios.Api.dll --seed-demo
Push-Location frontend
npm ci
Pop-Location
```

`Initialize-LocalSecrets.ps1` genera el secreto runtime, la clave JWT y los tres accesos demo. No muestra contraseñas. Si ya existe un login runtime con otra contraseña, falla la comprobación: el parámetro explícito `-SincronizarPasswordRuntime` permite sincronizarlo con el secreto privado cuando se administra esta instalación.

## Requisitos y configuración del backend

Requiere PowerShell 7, Node.js 22.12+ compatible con Vite, npm y sqlcmd. El SDK 10 está instalado en `.tools/dotnet/`; `Use-ProjectEnvironment.ps1` configura PATH, DOTNET_ROOT, NuGet, npm y los temporales dentro del proyecto.

Si faltase ese SDK, después de crear `.cache/tmp` y cargar el entorno:

```powershell
.\tools\dotnet-install.ps1 -Version 10.0.404 -InstallDir "$PWD\.tools\dotnet" -NoPath
```

La configuración se lee en este orden: `appsettings.json`, `appsettings.{Environment}.json`, secretos privados de desarrollo y variables de entorno. Los ejemplos versionables están en `appsettings.Example.json` y `.env.example`; no contienen credenciales reales. El archivo `.env.example` es documental y no se carga automáticamente.

Se usa `.secrets/development.json` dentro del proyecto en lugar del almacén User Secrets del perfil de Windows, para respetar la ruta exclusiva solicitada. En otro despliegue configure `ConnectionStrings__SqlServer`, `Jwt__Key`, emisor y audiencia mediante variables del proceso. No hay `EnsureCreated` ni ejecución automática de migrations al iniciar.

El desarrollo escucha HTTP exclusivamente en loopback. Un despliegue público requiere configurar HTTPS, certificados SQL confiables, hosts y orígenes CORS propios; no está publicado como servicio de producción.

## Pruebas

Con la API encendida:

```powershell
. .\tools\Use-ProjectEnvironment.ps1
dotnet test .\tests\SistemaHorarios.UnitTests\SistemaHorarios.UnitTests.csproj
Push-Location frontend
npm test
npm run build
Pop-Location
.\tests\integration\SmokeApi.ps1
.\tools\Check-Database.ps1
```

Resultados comprobados: **34 pruebas xUnit**, **5 Vitest**, **20 casos SQL**, **18 consultas de inconsistencias en cero** y el flujo HTTP integral. La primera ejecución de integración aprobó 53 comprobaciones; al reutilizar su horario persistente se omite una creación y se aprueban 52. La prueba guarda una opción `PRUEBA-API-INTEGRACION` y restaura la selección previa; no elimina horarios confirmados.

Los resultados están en `docs/Pruebas_integracion_API.json`, `docs/fase1/Resultado_validacion.json`, logs locales y `tests/resultados/unitarias.trx`.

## Estado y alcance

Está implementado y probado el flujo estudiantil completo, consulta del historial, consulta de grupos del docente, catálogos de coordinación y generador backend con guardado transaccional. Los catálogos administrativos son de **consulta** en esta entrega. Las altas, ediciones y bajas administrativas, recuperación de cuentas y despliegue productivo corresponden a la siguiente etapa.

Los antecedentes institucionales se limitan a las flechas de prerrequisito identificadas en la retícula. Los umbrales numéricos sin leyenda, equivalencias, residencias y servicio social requieren políticas institucionales adicionales antes de utilizarlos para inscripciones reales. Consulte `docs/Fases_y_validacion.md`.

El repositorio de GitHub es [YZYsebz/Sistema_Horarios](https://github.com/YZYsebz/Sistema_Horarios), con visibilidad privada y rama principal `main`. Los PDF, secretos, SDK, dependencias, resultados locales de pruebas y cachés están excluidos. Si Git muestra una advertencia de propietario en esta carpeta creada desde Codex, puede comprobar este repositorio de forma acotada con `git -c safe.directory="$PWD" status`, después de verificar la ruta.

Al clonar el repositorio en otro equipo, siga las instrucciones de primera instalación para restaurar dependencias, desplegar SQL y generar nuevos secretos y accesos demo. Las credenciales de esta instalación local no se incluyen en GitHub.
