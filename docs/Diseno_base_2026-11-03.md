# Sistema de Generación y Validación de Horarios Académicos

## PARTE 1 — Análisis del dominio

Solo persistencia SQL Server 2022+. El segundo documento exige App, Rep y Aud, con propietario dbo.
TrayectoriaEstudiante conserva los cambios de retícula y carrera. Carrera se obtiene de la retícula:
duplicarla en Estudiante introduciría dependencia transitiva y riesgo de inconsistencias.
Las dos FKs compuestas de prerrequisitos exigen materias del mismo plan. Cada intento académico conserva
su periodo, permitiendo recursamientos. PENDIENTE es el único estado sin periodo; también se pueden derivar
materias pendientes no registradas. La escala es 0 a 100; no se inventa una nota aprobatoria institucional.
La autenticación Windows solicitada corresponde al despliegue; la cuenta runtime se provisiona por separado.

## PARTE 2 — Clasificación de objetos

Cat_: maestros Carrera, Reticula, Materia, Rol, TipoAula, DiaSemana y EstatusAcademico.
Tbl_: perfiles, recursos, relaciones, intentos, periodos y horarios. Periodo tiene ciclo de publicación y
activación; Aula y Docente son entidades operativas. Vi_: consultas operativas en App y reportes en Rep.
Sp_: operaciones transaccionales y consultas que requieren parámetros. Tr_: guards de integridad sobre
tablas críticas, necesarios por la concesión explícita de CRUD directo a runtime. No son auditoría masiva.
Identity incluye sus siete entidades estándar con clave int y múltiples roles, sin contraseñas en texto plano.
Las tablas y todas las columnas se mapearán con EF Core; no se genera todavía código C#.

## PARTE 3 — ANÁLISIS DE NORMALIZACIÓN

**1FN:** campos atómicos, PK en cada tabla, una fila por sesión, arista, rol o grupo de horario; no hay listas.
**2FN:** créditos, semestre y obligatoriedad dependen del par Retícula+Materia completo; obligatoriedad de
prerrequisito depende de la arista completa. Las uniones no contienen atributos de una parte de la clave.
**3FN:** no se repiten carrera, datos del grupo en sesiones, ni materia/periodo del grupo en detalle.
Estados y tipos se referencian por FK. Los créditos totales se calculan. Trayectoria es una asignación
histórica, no un total derivado. Publicada y Confirmado son estados de flujo. Los nombres normalizados y
stamps de Identity son metadatos de su protocolo y deberán mantenerse con el normalizador oficial.
La separación de esquemas es una política de seguridad, independiente de la normalización.

## PARTE 4 — Modelo relacional

Las relaciones ordinarias son padre 1 → hijo N. Usuario→Estudiante y Usuario→Docente son 1→0..1
mediante UNIQUE (filtrado para docente opcional). Trayectoria admite N históricas y como máximo una vigente
por estudiante. Retícula N:M Materia, Usuario N:M Rol y Horario N:M Grupo usan tablas intermedias.

- `App.Cat_Carrera (nIdCarrera)` 1 → N `App.Cat_Reticula (nIdCarrera)`.
- `App.Tbl_Usuario (nIdUsuario)` 1 → N `App.Tbl_UsuarioRol (nIdUsuario)`.
- `App.Tbl_Usuario (nIdUsuario)` 1 → N `App.Tbl_UsuarioClaim (nIdUsuario)`.
- `App.Tbl_Usuario (nIdUsuario)` 1 → N `App.Tbl_UsuarioLogin (nIdUsuario)`.
- `App.Tbl_Usuario (nIdUsuario)` 1 → N `App.Tbl_UsuarioToken (nIdUsuario)`.
- `App.Tbl_Usuario (nIdUsuario)` 1 → N `App.Tbl_Estudiante (nIdUsuario)`.
- `App.Tbl_Usuario (nIdUsuario)` 1 → N `App.Tbl_Docente (nIdUsuario)`.
- `App.Cat_Rol (nIdRol)` 1 → N `App.Tbl_UsuarioRol (nIdRol)`.
- `App.Cat_Rol (nIdRol)` 1 → N `App.Tbl_RolClaim (nIdRol)`.
- `App.Tbl_Estudiante (nIdEstudiante)` 1 → N `App.Tbl_TrayectoriaEstudiante (nIdEstudiante)`.
- `App.Cat_Reticula (nIdReticula)` 1 → N `App.Tbl_TrayectoriaEstudiante (nIdReticula)`.
- `App.Cat_TipoAula (nIdTipoAula)` 1 → N `App.Tbl_Aula (nIdTipoAula)`.
- `App.Cat_Reticula (nIdReticula)` 1 → N `App.Tbl_ReticulaMateria (nIdReticula)`.
- `App.Cat_Materia (nIdMateria)` 1 → N `App.Tbl_ReticulaMateria (nIdMateria)`.
- `App.Tbl_ReticulaMateria (nIdReticula,nIdMateria)` 1 → N `App.Tbl_MateriaPrerrequisito (nIdReticula,nIdMateria)`.
- `App.Tbl_ReticulaMateria (nIdReticula,nIdMateria)` 1 → N `App.Tbl_MateriaPrerrequisito (nIdReticula,nIdMateriaPrerrequisito)`.
- `App.Cat_Materia (nIdMateria)` 1 → N `App.Tbl_Grupo (nIdMateria)`.
- `App.Tbl_Docente (nIdDocente)` 1 → N `App.Tbl_Grupo (nIdDocente)`.
- `App.Tbl_PeriodoAcademico (nIdPeriodo)` 1 → N `App.Tbl_Grupo (nIdPeriodo)`.
- `App.Tbl_Grupo (nIdGrupo)` 1 → N `App.Tbl_SesionGrupo (nIdGrupo)`.
- `App.Cat_DiaSemana (nIdDiaSemana)` 1 → N `App.Tbl_SesionGrupo (nIdDiaSemana)`.
- `App.Tbl_Aula (nIdAula)` 1 → N `App.Tbl_SesionGrupo (nIdAula)`.
- `App.Tbl_Estudiante (nIdEstudiante)` 1 → N `App.Tbl_HistorialAcademico (nIdEstudiante)`.
- `App.Cat_Materia (nIdMateria)` 1 → N `App.Tbl_HistorialAcademico (nIdMateria)`.
- `App.Tbl_PeriodoAcademico (nIdPeriodo)` 1 → N `App.Tbl_HistorialAcademico (nIdPeriodo)`.
- `App.Cat_EstatusAcademico (nIdEstatusAcademico)` 1 → N `App.Tbl_HistorialAcademico (nIdEstatusAcademico)`.
- `App.Tbl_TrayectoriaEstudiante (nIdTrayectoria)` 1 → N `App.Tbl_HorarioGenerado (nIdTrayectoria)`.
- `App.Tbl_PeriodoAcademico (nIdPeriodo)` 1 → N `App.Tbl_HorarioGenerado (nIdPeriodo)`.
- `App.Tbl_HorarioGenerado (nIdHorarioGenerado)` 1 → N `App.Tbl_HorarioGeneradoDetalle (nIdHorarioGenerado)`.
- `App.Tbl_Grupo (nIdGrupo)` 1 → N `App.Tbl_HorarioGeneradoDetalle (nIdGrupo)`.
- `App.Tbl_Usuario (nIdUsuario)` 1 → N `Aud.Tbl_Auditoria (nIdUsuario)`.

## PARTE 5 — Diccionario de datos

Prefijos: c texto, n números/bit, d fechas/horas; datetimeoffset conserva el tipo esperado por Identity.

### App.Cat_Rol

Roles de Identity; múltiples roles por usuario.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Cat_Rol | nIdRol | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Cat_Rol | cNombre | nvarchar(256) | No |  |  | Nombre de rol |
| App.Cat_Rol | cNombreNormalizado | nvarchar(256) | No |  |  | NormalizedName de Identity |
| App.Cat_Rol | cConcurrencyStamp | nvarchar(64) | Sí |  |  | Token de concurrencia |

### App.Cat_Carrera

Maestro de carrera

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Cat_Carrera | nIdCarrera | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Cat_Carrera | cClave | varchar(30) | No |  |  | Clave única |
| App.Cat_Carrera | cNombre | nvarchar(150) | No |  |  | Nombre |
| App.Cat_Carrera | nEstatus | bit | No |  |  | Habilitado |

### App.Cat_Materia

Maestro de materia

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Cat_Materia | nIdMateria | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Cat_Materia | cClave | varchar(30) | No |  |  | Clave única |
| App.Cat_Materia | cNombre | nvarchar(150) | No |  |  | Nombre |
| App.Cat_Materia | nEstatus | bit | No |  |  | Habilitado |

### App.Cat_TipoAula

Maestro de tipoaula

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Cat_TipoAula | nIdTipoAula | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Cat_TipoAula | cClave | varchar(30) | No |  |  | Clave única |
| App.Cat_TipoAula | cNombre | nvarchar(150) | No |  |  | Nombre |
| App.Cat_TipoAula | nEstatus | bit | No |  |  | Habilitado |

### App.Cat_Reticula

Versión de plan de estudios de una carrera.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Cat_Reticula | nIdReticula | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Cat_Reticula | nIdCarrera | int | No |  | App.Cat_Carrera.nIdCarrera | Carrera propietaria del plan |
| App.Cat_Reticula | cClave | varchar(30) | No |  |  | Clave única |
| App.Cat_Reticula | cNombre | nvarchar(150) | No |  |  | Nombre del plan |
| App.Cat_Reticula | nEstatus | bit | No |  |  | Habilitado |

### App.Cat_DiaSemana

Dominio ISO fijo: lunes 1 a domingo 7.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Cat_DiaSemana | nIdDiaSemana | tinyint | No | Sí |  | Número ISO |
| App.Cat_DiaSemana | cNombre | nvarchar(15) | No |  |  | Nombre del día |

### App.Cat_EstatusAcademico

Estados controlados del intento académico.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Cat_EstatusAcademico | nIdEstatusAcademico | tinyint | No | Sí |  | Identificador |
| App.Cat_EstatusAcademico | cClave | varchar(15) | No |  |  | APROBADA, NO_APROBADA, CURSANDO o PENDIENTE |
| App.Cat_EstatusAcademico | cNombre | nvarchar(50) | No |  |  | Etiqueta |

### App.Tbl_Usuario

Usuario compatible con Identity de clave int.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_Usuario | nIdUsuario | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_Usuario | cNombreUsuario | nvarchar(256) | No |  |  | UserName |
| App.Tbl_Usuario | cNombreUsuarioNormalizado | nvarchar(256) | No |  |  | NormalizedUserName |
| App.Tbl_Usuario | cCorreo | nvarchar(256) | Sí |  |  | Email |
| App.Tbl_Usuario | cCorreoNormalizado | nvarchar(256) | Sí |  |  | NormalizedEmail |
| App.Tbl_Usuario | nCorreoConfirmado | bit | No |  |  | EmailConfirmed |
| App.Tbl_Usuario | cPasswordHash | nvarchar(max) | Sí |  |  | Hash de PasswordHasher; NULL para acceso externo |
| App.Tbl_Usuario | cSecurityStamp | nvarchar(64) | Sí |  |  | SecurityStamp |
| App.Tbl_Usuario | cConcurrencyStamp | nvarchar(64) | Sí |  |  | ConcurrencyStamp |
| App.Tbl_Usuario | cTelefono | nvarchar(50) | Sí |  |  | PhoneNumber |
| App.Tbl_Usuario | nTelefonoConfirmado | bit | No |  |  | PhoneNumberConfirmed |
| App.Tbl_Usuario | nDosFactoresHabilitados | bit | No |  |  | TwoFactorEnabled |
| App.Tbl_Usuario | dFinBloqueo | datetimeoffset(0) | Sí |  |  | LockoutEnd |
| App.Tbl_Usuario | nBloqueoHabilitado | bit | No |  |  | LockoutEnabled |
| App.Tbl_Usuario | nIntentosFallidos | int | No |  |  | AccessFailedCount |
| App.Tbl_Usuario | nEstatus | bit | No |  |  | Habilitado |
| App.Tbl_Usuario | dFechaRegistro | datetime2(0) | No |  |  | Alta UTC |

### App.Tbl_UsuarioRol

Relación N:M de usuarios y roles.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_UsuarioRol | nIdUsuario | int | No | Sí | App.Tbl_Usuario.nIdUsuario | Usuario |
| App.Tbl_UsuarioRol | nIdRol | int | No | Sí | App.Cat_Rol.nIdRol | Rol |

### App.Tbl_UsuarioClaim

Claims de Usuario

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_UsuarioClaim | nIdUsuarioClaim | int IDENTITY(1,1) | No | Sí |  | Identificador del claim |
| App.Tbl_UsuarioClaim | nIdUsuario | int | No |  | App.Tbl_Usuario.nIdUsuario | Titular |
| App.Tbl_UsuarioClaim | cTipoClaim | nvarchar(max) | Sí |  |  | ClaimType |
| App.Tbl_UsuarioClaim | cValorClaim | nvarchar(max) | Sí |  |  | ClaimValue |

### App.Tbl_RolClaim

Claims de Rol

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_RolClaim | nIdRolClaim | int IDENTITY(1,1) | No | Sí |  | Identificador del claim |
| App.Tbl_RolClaim | nIdRol | int | No |  | App.Cat_Rol.nIdRol | Titular |
| App.Tbl_RolClaim | cTipoClaim | nvarchar(max) | Sí |  |  | ClaimType |
| App.Tbl_RolClaim | cValorClaim | nvarchar(max) | Sí |  |  | ClaimValue |

### App.Tbl_UsuarioLogin

Inicio de sesión externo de Identity.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_UsuarioLogin | cProveedorLogin | nvarchar(128) | No | Sí |  | LoginProvider |
| App.Tbl_UsuarioLogin | cClaveProveedor | nvarchar(128) | No | Sí |  | ProviderKey |
| App.Tbl_UsuarioLogin | cNombreProveedor | nvarchar(128) | Sí |  |  | ProviderDisplayName |
| App.Tbl_UsuarioLogin | nIdUsuario | int | No |  | App.Tbl_Usuario.nIdUsuario | Usuario |

### App.Tbl_UsuarioToken

Tokens de Identity; evitar exposición y proteger en el backend.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_UsuarioToken | nIdUsuario | int | No | Sí | App.Tbl_Usuario.nIdUsuario | Usuario |
| App.Tbl_UsuarioToken | cProveedorLogin | nvarchar(128) | No | Sí |  | LoginProvider |
| App.Tbl_UsuarioToken | cNombre | nvarchar(128) | No | Sí |  | Nombre del token |
| App.Tbl_UsuarioToken | cValor | nvarchar(max) | Sí |  |  | Valor |

### App.Tbl_Estudiante

Identidad académica independiente del plan.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_Estudiante | nIdEstudiante | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_Estudiante | nIdUsuario | int | No |  | App.Tbl_Usuario.nIdUsuario | Usuario único |
| App.Tbl_Estudiante | cNumeroControl | varchar(25) | No |  |  | Número de control único |
| App.Tbl_Estudiante | nEstatus | bit | No |  |  | Habilitado |

### App.Tbl_TrayectoriaEstudiante

Asignación temporal de retícula que conserva cambios de carrera.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_TrayectoriaEstudiante | nIdTrayectoria | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_TrayectoriaEstudiante | nIdEstudiante | int | No |  | App.Tbl_Estudiante.nIdEstudiante | Estudiante |
| App.Tbl_TrayectoriaEstudiante | nIdReticula | int | No |  | App.Cat_Reticula.nIdReticula | Plan; la carrera se obtiene de él |
| App.Tbl_TrayectoriaEstudiante | nSemestreActual | tinyint | No |  |  | Semestre actual en el plan |
| App.Tbl_TrayectoriaEstudiante | nLimiteCreditos | smallint | No |  |  | Máximo autorizado |
| App.Tbl_TrayectoriaEstudiante | dFechaInicio | date | No |  |  | Inicio |
| App.Tbl_TrayectoriaEstudiante | dFechaFin | date | Sí |  |  | Cierre; NULL indica vigente |

### App.Tbl_Docente

Perfil laboral; usuario opcional sin duplicar credenciales.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_Docente | nIdDocente | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_Docente | nIdUsuario | int | Sí |  | App.Tbl_Usuario.nIdUsuario | Usuario opcional único |
| App.Tbl_Docente | cNumeroEmpleado | varchar(25) | No |  |  | Número de empleado único |
| App.Tbl_Docente | cNombre | nvarchar(150) | No |  |  | Nombre del perfil laboral |
| App.Tbl_Docente | nEstatus | bit | No |  |  | Habilitado |

### App.Tbl_Aula

Recurso físico de enseñanza.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_Aula | nIdAula | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_Aula | nIdTipoAula | int | No |  | App.Cat_TipoAula.nIdTipoAula | Tipo |
| App.Tbl_Aula | cClave | varchar(30) | No |  |  | Clave única |
| App.Tbl_Aula | nCapacidad | smallint | No |  |  | Capacidad positiva |
| App.Tbl_Aula | nEstatus | bit | No |  |  | Habilitado |

### App.Tbl_ReticulaMateria

Atributos dependientes del par retícula-materia.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_ReticulaMateria | nIdReticula | int | No | Sí | App.Cat_Reticula.nIdReticula | Plan |
| App.Tbl_ReticulaMateria | nIdMateria | int | No | Sí | App.Cat_Materia.nIdMateria | Materia |
| App.Tbl_ReticulaMateria | nSemestreRecomendado | tinyint | No |  |  | Semestre recomendado |
| App.Tbl_ReticulaMateria | nCreditos | tinyint | No |  |  | Créditos dentro del plan |
| App.Tbl_ReticulaMateria | nObligatoria | bit | No |  |  | Obligatoria |

### App.Tbl_MateriaPrerrequisito

Arista del grafo de materias de una retícula.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_MateriaPrerrequisito | nIdReticula | int | No | Sí | App.Tbl_ReticulaMateria.nIdReticula, App.Tbl_ReticulaMateria.nIdReticula | Ámbito curricular |
| App.Tbl_MateriaPrerrequisito | nIdMateria | int | No | Sí | App.Tbl_ReticulaMateria.nIdMateria | Materia objetivo |
| App.Tbl_MateriaPrerrequisito | nIdMateriaPrerrequisito | int | No | Sí | App.Tbl_ReticulaMateria.nIdMateria | Materia antecedente; rol de FK a nIdMateria |
| App.Tbl_MateriaPrerrequisito | nObligatorio | bit | No |  |  | Obligatorio o recomendación |

### App.Tbl_PeriodoAcademico

Ciclo y publicación de oferta.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_PeriodoAcademico | nIdPeriodo | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_PeriodoAcademico | cClave | varchar(20) | No |  |  | Clave única |
| App.Tbl_PeriodoAcademico | cNombre | nvarchar(100) | No |  |  | Nombre |
| App.Tbl_PeriodoAcademico | dFechaInicio | date | No |  |  | Inicio |
| App.Tbl_PeriodoAcademico | dFechaFin | date | No |  |  | Fin |
| App.Tbl_PeriodoAcademico | nActivoGeneracion | bit | No |  |  | Único periodo para generación |
| App.Tbl_PeriodoAcademico | nOfertaPublicada | bit | No |  |  | Oferta validada y congelada |

### App.Tbl_Grupo

Oferta de una materia por periodo.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_Grupo | nIdGrupo | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_Grupo | nIdMateria | int | No |  | App.Cat_Materia.nIdMateria | Materia |
| App.Tbl_Grupo | nIdDocente | int | Sí |  | App.Tbl_Docente.nIdDocente | Docente; opcional en borrador |
| App.Tbl_Grupo | nIdPeriodo | int | No |  | App.Tbl_PeriodoAcademico.nIdPeriodo | Periodo |
| App.Tbl_Grupo | cClaveGrupo | varchar(20) | No |  |  | Clave de grupo |
| App.Tbl_Grupo | nEstatus | bit | No |  |  | Grupo activo |

### App.Tbl_SesionGrupo

Una reunión semanal, intervalo [inicio, fin).

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_SesionGrupo | nIdSesionGrupo | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_SesionGrupo | nIdGrupo | int | No |  | App.Tbl_Grupo.nIdGrupo | Grupo |
| App.Tbl_SesionGrupo | nIdDiaSemana | tinyint | No |  | App.Cat_DiaSemana.nIdDiaSemana | Día ISO |
| App.Tbl_SesionGrupo | nIdAula | int | No |  | App.Tbl_Aula.nIdAula | Aula |
| App.Tbl_SesionGrupo | dHoraInicio | time(0) | No |  |  | Inicio |
| App.Tbl_SesionGrupo | dHoraFin | time(0) | No |  |  | Fin |

### App.Tbl_HistorialAcademico

Un intento por estudiante/materia/periodo; admite recursamientos.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_HistorialAcademico | nIdHistorialAcademico | bigint IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_HistorialAcademico | nIdEstudiante | int | No |  | App.Tbl_Estudiante.nIdEstudiante | Estudiante |
| App.Tbl_HistorialAcademico | nIdMateria | int | No |  | App.Cat_Materia.nIdMateria | Materia |
| App.Tbl_HistorialAcademico | nIdPeriodo | int | Sí |  | App.Tbl_PeriodoAcademico.nIdPeriodo | Periodo; NULL solo para PENDIENTE |
| App.Tbl_HistorialAcademico | nIdEstatusAcademico | tinyint | No |  | App.Cat_EstatusAcademico.nIdEstatusAcademico | Estado |
| App.Tbl_HistorialAcademico | nCalificacion | decimal(5,2) | Sí |  |  | 0 a 100; requerida en resultados finales |
| App.Tbl_HistorialAcademico | dFechaRegistro | datetime2(0) | No |  |  | Registro UTC |

### App.Tbl_HorarioGenerado

Opción en borrador o confirmada para una trayectoria.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_HorarioGenerado | nIdHorarioGenerado | int IDENTITY(1,1) | No | Sí |  | Identificador |
| App.Tbl_HorarioGenerado | nIdTrayectoria | int | No |  | App.Tbl_TrayectoriaEstudiante.nIdTrayectoria | Asignación curricular histórica |
| App.Tbl_HorarioGenerado | nIdPeriodo | int | No |  | App.Tbl_PeriodoAcademico.nIdPeriodo | Periodo |
| App.Tbl_HorarioGenerado | cNombre | nvarchar(100) | No |  |  | Nombre de opción |
| App.Tbl_HorarioGenerado | nConfirmado | bit | No |  |  | Estado de flujo: borrador o confirmado inmutable |
| App.Tbl_HorarioGenerado | nSeleccionado | bit | No |  |  | Opción final; máximo una por trayectoria/periodo |
| App.Tbl_HorarioGenerado | dFechaRegistro | datetime2(0) | No |  |  | Registro UTC |

### App.Tbl_HorarioGeneradoDetalle

Un grupo por fila; sin atributos derivados.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| App.Tbl_HorarioGeneradoDetalle | nIdHorarioGenerado | int | No | Sí | App.Tbl_HorarioGenerado.nIdHorarioGenerado | Cabecera |
| App.Tbl_HorarioGeneradoDetalle | nIdGrupo | int | No | Sí | App.Tbl_Grupo.nIdGrupo | Grupo |

### Aud.Tbl_Auditoria

Bitácora administrativa; sin payload sensible.

| Tabla | Columna | Tipo | NULL | PK | FK | Descripción |
|---|---|---|---|---|---|---|
| Aud.Tbl_Auditoria | nIdAuditoria | bigint IDENTITY(1,1) | No | Sí |  | Identificador |
| Aud.Tbl_Auditoria | nIdUsuario | int | Sí |  | App.Tbl_Usuario.nIdUsuario | Actor funcional cuando se conoce |
| Aud.Tbl_Auditoria | cLoginOriginal | nvarchar(128) | No |  |  | ORIGINAL_LOGIN de SQL Server |
| Aud.Tbl_Auditoria | cOperacion | varchar(30) | No |  |  | Operación |
| Aud.Tbl_Auditoria | cEsquema | varchar(3) | No |  |  | Esquema afectado |
| Aud.Tbl_Auditoria | cObjeto | nvarchar(128) | No |  |  | Objeto afectado |
| Aud.Tbl_Auditoria | nIdRegistroAfectado | bigint | Sí |  |  | Clave simple si existe |
| Aud.Tbl_Auditoria | dFechaRegistro | datetime2(0) | No |  |  | Instante UTC |
| Aud.Tbl_Auditoria | cDatosAdicionales | nvarchar(1000) | Sí |  |  | Contexto mínimo sin secretos |

## PARTE 6 — Revisión del diseño

- El índice UNIQUE filtrado permite cero o un periodo activo; generar exige un periodo activo y publicado.
- Publicar exige al menos un grupo activo y docente, materia, aulas y tipos activos y sesiones completas.
  Grupos y sesiones publicados se congelan. Despublicar se permite solo sin horarios confirmados.
  Las relaciones curriculares usadas por horarios confirmados se congelan: modificar el plan exige otra versión.
  La trayectoria usada no cambia de estudiante ni retícula; puede cerrarse y abrir otra sin perder historia.
- Un horario tiene borrador editable y confirmación inmutable. Solo un confirmado puede seleccionarse.
  La confirmación valida el conjunto entero. No se muestran borradores como opciones guardadas válidas.
  Los totales se calculan una vez por grupo, nunca por sesión. Los resultados históricos no se revalidan
  retroactivamente cuando cambia una nota; sí se valida cada nueva confirmación.
- Escrituras académicas críticas comparten un bloqueo transaccional exclusivo sp_getapplock. Los SP toman
  el bloqueo antes de modificar. Triggers AFTER lo toman para cubrir CRUD directo. Este último puede provocar
  deadlocks: SQL Server revierte una operación y el backend reintenta 1205/51000 con límite. Se prioriza
  corrección del MVP sobre paralelismo de escritura. No se usa NOLOCK ni una validación SELECT/INSERT separada.
  Lecturas de validación fuerzan READCOMMITTEDLOCK. Usar READ COMMITTED, no transacciones SNAPSHOT para escribir.
  Los SP usan XACT_ABORT, TRY/CATCH y savepoints si reciben una transacción externa; si esta queda no
  confirmable, el llamador debe revertirla. Los bloqueos transaccionales se liberan al finalizar la transacción.
- Solo grupos activos ocupan recursos. Empalme: mismo día, inicioA<finB e inicioB<finA; contigüidad permitida.
  También se impide que un grupo se empalme consigo mismo. Los SP de consulta son solo diagnósticos.
- Aud registra eventos mínimos dentro de las operaciones transaccionales mediante referencias estáticas
  y ownership chaining con dbo. Runtime no puede consultar ni ejecutar Aud directamente. ORIGINAL_LOGIN
  identifica la sesión; nIdUsuario funcional es opcional y su autenticidad dependerá del backend autenticado.
- Runtime: App CRUD/EXECUTE, Rep SELECT y DENY explícito de Aud como defensa frente a otros roles.
  DENY no limita a sysadmin. No se otorgan roles administrativos ni DDL. Usr_SistemaHorarios se prepara
  WITHOUT LOGIN para impersonación; un script separado lo vincula a una cuenta Windows de servicio existente.
  No se usa la cuenta DBA como runtime ni se inventan credenciales. Rep no expone hash ni tokens.
  Los permisos SQL no sustituyen la autorización por estudiante/rol del backend; no se implementa RLS.
- Capacidad positiva se protege físicamente; cupos de inscripción quedan fuera del modelo solicitado.
  La política institucional de aprobación y equivalencias entre claves de materias requiere definición futura.

### Índices adicionales

Las PK y UNIQUE cubren claves y prefijos izquierdos. El UNIQUE de sesión cubre grupo/día/inicio;
no se duplica. Fin del intervalo se verifica como predicado residual. No se indexa indiscriminadamente cada FK.

| Índice | Claves | INCLUDE / filtro | Justificación y diferencia respecto a PK/UNIQUE |
|---|---|---|---|
| IX_Tbl_Docente_Usuario | nIdUsuario | ; nIdUsuario IS NOT NULL | Relación opcional 1:1; UNIQUE normal permitiría solo un NULL. |
| IX_Tbl_TrayectoriaEstudiante_Vigente | nIdEstudiante | ; dFechaFin IS NULL | Máximo una trayectoria vigente; PK por ID no lo asegura. |
| IX_Tbl_PeriodoAcademico_UnicoActivo | nActivoGeneracion | ; nActivoGeneracion=1 | Cero o un periodo activo; UNIQUE normal impediría varios inactivos. |
| IX_Tbl_HorarioGenerado_SeleccionUnica | nIdTrayectoria,nIdPeriodo | ; nSeleccionado=1 | Máximo una opción final; PK identifica solo una opción. |
| IX_Cat_Reticula_Carrera | nIdCarrera | ;  | Planes de carrera; PK empieza por retícula. |
| IX_Tbl_Usuario_Correo | cCorreoNormalizado | ;  | Consulta Identity por correo; no se impone unicidad no solicitada. |
| IX_Tbl_UsuarioRol_Rol | nIdRol,nIdUsuario | ;  | Usuarios de un rol; PK empieza por usuario. |
| IX_Tbl_UsuarioClaim_Usuario | nIdUsuario | ;  | Claims de usuario; PK por claim. |
| IX_Tbl_RolClaim_Rol | nIdRol | ;  | Claims de rol; PK por claim. |
| IX_Tbl_UsuarioLogin_Usuario | nIdUsuario | ;  | Logins de usuario; PK por proveedor. |
| IX_Tbl_TrayectoriaEstudiante_Estudiante | nIdEstudiante,dFechaInicio | nIdReticula,dFechaFin;  | Trayectorias históricas; índice filtrado solo cubre vigente. |
| IX_Tbl_TrayectoriaEstudiante_Reticula | nIdReticula | nIdEstudiante;  | Trayectorias de un plan; PK por trayectoria. |
| IX_Tbl_ReticulaMateria_Materia | nIdMateria,nIdReticula | ;  | Relación inversa materia a planes; PK por retícula. |
| IX_Tbl_MateriaPrerrequisito_Antecedente | nIdReticula,nIdMateriaPrerrequisito | nIdMateria;  | Recorrido inverso del grafo; PK por objetivo. |
| IX_Tbl_Grupo_DocentePeriodo | nIdDocente,nIdPeriodo,nEstatus | nIdMateria;  | Conflictos de docente; UNIQUE empieza por periodo y materia. |
| IX_Tbl_Grupo_MateriaPeriodo | nIdMateria,nIdPeriodo,nEstatus | nIdDocente,cClaveGrupo;  | Grupos ofertados por materia; UNIQUE empieza por periodo. |
| IX_Tbl_SesionGrupo_AulaDiaHora | nIdAula,nIdDiaSemana,dHoraInicio | dHoraFin,nIdGrupo;  | Conflictos de aula; UNIQUE empieza por grupo. |
| IX_Tbl_HistorialAcademico_MateriaEstudiante | nIdMateria,nIdEstudiante | nIdEstatusAcademico;  | Relación inversa y FK materia; UNIQUE empieza por estudiante. |
| IX_Tbl_HistorialAcademico_Periodo | nIdPeriodo | ;  | Intentos de un periodo; UNIQUE por estudiante. |
| IX_Tbl_HorarioGenerado_TrayectoriaPeriodo | nIdTrayectoria,nIdPeriodo | nConfirmado;  | Todas las opciones; índice filtrado solo cubre seleccionada. |
| IX_Tbl_HorarioGenerado_Periodo | nIdPeriodo | ;  | Publicación y horarios por periodo; PK por horario. |
| IX_Tbl_HorarioGeneradoDetalle_Grupo | nIdGrupo,nIdHorarioGenerado | ;  | Opciones que usan un grupo; PK por horario. |
| IX_Tbl_Auditoria_Fecha | dFechaRegistro | cOperacion,cObjeto;  | Bitácora por intervalo UTC; PK por evento. |

### Preparación para EF Core e Identity

Configurar explícitamente tablas, esquemas, columnas, claves compuestas, precisión decimal y las relaciones
de borrado restrictivo. No hay borrado en cascada implícito ni rutas de cascada múltiples. Las vistas de reportes
son lecturas sin clave de entidad cuando no hay clave única de fila. El resumen sí tiene una fila por horario.
El modelo Identity usa usuario/rol de clave int y todos los tipos relacionados con el mismo tipo de clave.
Mapeo lógico: User→App.Tbl_Usuario, Role→App.Cat_Rol, UserRole→App.Tbl_UsuarioRol,
UserClaim→App.Tbl_UsuarioClaim, RoleClaim→App.Tbl_RolClaim, UserLogin→App.Tbl_UsuarioLogin y
UserToken→App.Tbl_UsuarioToken. Mapear cada propiedad estándar al campo del diccionario: no basta renombrar tablas.
LockoutEnd se conserva como datetimeoffset; los stamps se configuran como tokens de concurrencia de Identity.
Se usa el almacenamiento estándar de tokens/logins de claves de 128 caracteres; configurar las mismas longitudes.
Generar PasswordHash, normalizaciones y stamps desde servicios Identity, nunca con hashes SQL improvisados.
Estos cambios de nombres y tipos se basan en la [personalización oficial de Identity](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/customize-identity-model?view=aspnetcore-10.0).

Las 18 tablas con triggers se deben marcar en el modelo y se debe desactivar para ellas la cláusula OUTPUT
directa mediante la opción UseSqlOutputClause(false) de versiones actuales de EF Core. Es un requisito del
[proveedor SQL Server al usar triggers](https://learn.microsoft.com/en-us/ef/core/providers/sql-server/misc).
No se ha compilado ni probado un DbContext todavía porque esta etapa excluye el backend.
Guardar horarios y registrar sesiones mediante los SP públicos; el TVP evita listas de IDs.
La confirmación de un horario necesita cabecera, detalles y transición final dentro de la misma transacción.
EF debe reintentar la unidad transaccional completa ante deadlock, no una parte de la operación.
No llamar EnsureCreated sobre esta base ni permitir migrations desde runtime; establecer una línea base
de migrations revisada con la cuenta de deployment cuando se apruebe el esquema.
