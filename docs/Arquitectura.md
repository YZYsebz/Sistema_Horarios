# Arquitectura y decisiones

La aplicación reutiliza Bd_SistemaHorarios. El navegador consulta la API ASP.NET Core; sus controladores aplican JWT y roles, los servicios resuelven al estudiante desde el identificador del token y EF Core consulta las tablas existentes. El generador es un servicio del backend con reglas puras en Domain.

## Persistencia e integridad

Infrastructure configura explícitamente los nombres físicos y esquemas de las entidades académicas y las siete tablas de Identity. Las lecturas usan AsNoTracking; las tablas con triggers deshabilitan la cláusula SQL OUTPUT de EF. El contexto no contiene entidades de Aud. Los objetos Rep conservan permisos de lectura y todavía no se consultan desde este módulo.

La carrera del estudiante se deriva de su trayectoria y retícula; no se agrega una carrera redundante al estudiante. Los créditos pertenecen a ReticulaMateria. Esto conserva el diseño normalizado y el historial entre trayectorias.

La migración 10 cambia únicamente el contrato de estudiante: cNumeroControl CHAR(8), nombre, año de ingreso y generación, UNIQUE y validaciones de dígitos/YYGG. Comprueba la compatibilidad antes de alterar datos; no trunca identificadores existentes.

Guardar un horario llama App.Sp_GuardarHorarioGenerado con un TVP de grupos. El procedimiento crea cabecera y detalles, valida y confirma dentro de una transacción. La oferta publicada y los horarios confirmados mantienen las protecciones del diseño. Los rechazos no dejan cabeceras parciales.

App.Sp_SeleccionarHorarioGenerado comprueba propiedad, trayectoria vigente y periodo activo publicado. Con el bloqueo transaccional de integridad existente desmarca la selección anterior y marca la nueva de forma atómica. Un índice filtrado impide múltiples seleccionados para la misma trayectoria y periodo. Ambos procedimientos registran auditoría internamente; el runtime no recibe acceso directo a Aud.

## Generador y reglas

La API acepta de 1 a 12 identificadores de materia únicos. Primero valida que sean materias disponibles para la trayectoria, que no estén aprobadas/cursándose según la vista existente y que satisfagan sus antecedentes. Se calcula el crédito desde la retícula en SQL, no desde el cuerpo enviado por React.

El generador ordena las materias por cantidad de grupos candidatos, explora con backtracking y poda al detectar créditos excesivos o empalmes. Excluye grupos inactivos, de otro periodo, sin sesiones o sin pertenencia/antecedentes válidos. Revisa conflictos de docente y aula contra el resto de la oferta activa, incluso en grupos no elegidos.

Un empalme exige mismo día, inicioA < finB e inicioB < finA. Los intervalos contiguos son válidos. El resultado contiene un grupo por materia. Tiene límite de 20 opciones, 50 000 estados y cancelación por solicitud; LimiteAlcanzado comunica si la búsqueda quedó limitada. El estado es local a cada invocación.

| Regla | Validación principal |
|---|---|
| RV-001 | Materias e identificadores únicos; restricciones de persistencia |
| RV-002 | Validador de intervalos y poda; procedimiento SQL |
| RV-003 | Créditos de la retícula y límite de la trayectoria |
| RV-004 | Vista de disponibles y antecedentes aprobados antes del periodo |
| RV-005 | Perfil con periodo activo y oferta publicada |
| RV-006 | Filtro de grupos activos |
| RV-007 | Pertenencia a retícula vigente |
| RV-008 | Conflicto de docente en oferta |
| RV-009 | Conflicto de aula en oferta |

## Autenticación y aislamiento

Identity usa hashes de contraseñas y bloqueo de cinco minutos tras cinco fallos. El login se limita a 12 peticiones por minuto por IP. Los JWT firmados con HMAC SHA-256 incluyen sub, nombre, roles y expiración de 30 minutos; se validan firma, emisor, audiencia y vigencia.

La API obtiene el estudiante del sub verificado y no permite enviar otro estudiante en las solicitudes. ESTUDIANTE consulta y guarda opciones propias; DOCENTE ve sus grupos; COORDINADOR consulta los catálogos. El frontend aplica guardas de rutas y la API verifica permisos independientemente.

Los tokens se mantienen en memoria; un 401 limpia la sesión. Las variables de entorno prevalecen también fuera de Development. No se habilita Swagger fuera de Development. La autenticación Windows se reserva al despliegue DBA y a las verificaciones; el runtime SQL separado no es sysadmin ni db_owner y no tiene SELECT en Aud.

## HTTP implementado

| Ruta | Rol / uso |
|---|---|
| GET /api/health | Público, comprobación del proceso |
| POST /api/auth/login | Público con límite de frecuencia |
| GET /api/estudiantes/me | ESTUDIANTE, perfil propio |
| GET /api/estudiantes/me/materias-disponibles | ESTUDIANTE, oferta elegible |
| POST /api/estudiantes/me/seleccion/creditos | ESTUDIANTE, cálculo servidor |
| POST /api/horarios/generar | ESTUDIANTE, combinaciones válidas |
| GET, POST /api/horarios | ESTUDIANTE, consulta/guardado propio |
| PUT /api/horarios/{id}/seleccion | ESTUDIANTE, opción propia confirmada |
| GET /api/historial | ESTUDIANTE, antecedentes propios |
| GET /api/materias | Autenticado, catálogo |
| GET /api/grupos | Oferta estudiantil, propios del docente o catálogo coordinador |
| GET /api/carreras, reticulas, periodos, docentes, aulas, estudiantes, sesiones | COORDINADOR, consulta |

Los errores de validación tienen 400/422, los conflictos de reglas SQL 409, la ausencia de autenticación 401 y los roles insuficientes 403. Los errores inesperados se registran en el servidor y devuelven un mensaje genérico.

## Límites de esta etapa

Los catálogos administrativos aún no tienen operaciones de escritura. El algoritmo valida factibilidad, sin optimización de preferencias, huecos, cupos o inscripción oficial. Los grupos pertenecen a una oferta de prueba congelada. Las políticas no documentadas en las fuentes requieren confirmación institucional. El calendario adapta su rango horario e incluye fines de semana cuando existen sesiones; en móvil permite desplazamiento horizontal sin ampliar el ancho de la página.
