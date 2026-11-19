# Fases y evidencia de validación

Comprobación local realizada el 17 de noviembre de 2026 sobre LAPTOPMASEB\\DBA_TOPICOS, Bd_SistemaHorarios.

## Fases 1 y 2: referencias, semilla e integridad

Se leyeron y contrastaron visualmente la carga académica y la retícula local entregadas. Las fuentes definitivas se conservan en docs/fuentes, junto con extracciones privadas en docs/fase1/extraccion:

- Reticula-ISIE-COE-2024-02-ISC.pdf: plan ISIC-2010-224, especialidad Cómputo Empresarial ISIE-COE-2024-02, revisión 14/12/2023.
- CargaAcademica_24240198 (8).pdf: seis grupos, cinco docentes y catorce sesiones reales de referencia.
- La retícula genérica de 2016 se inspeccionó como contraste; para semestres y especialidad prevalece la retícula local suministrada.

**Referencia documental:** 55 componentes curriculares, total 260 créditos (235 de materias y especialidad más actividades complementarias 5, servicio social 10 y residencia 10). Se conservaron nombres, claves, créditos y distribución local; Inteligencia Artificial y Redes figuran en quinto en esta retícula.

**Sintético:** 50 identidades estudiantiles, controles, usuarios, números de empleado, docentes adicionales, oferta adicional, periodos, trayectorias, calificaciones, historial, opciones y eventos simulados de auditoría. No se usó el nombre ni el número de control del estudiante del PDF como alumno de prueba. Los cinco docentes del archivo se distinguen con identificadores REF-DOC; sus números reales de empleado son desconocidos y no se inventaron como si fueran reales.

El manifiesto Datos_fuentes_y_sinteticos.json registra la separación de fuentes. La semilla usa una generación determinista y comprueba controles únicos; el primer estudiante de demostración es 24248001. La generación 24 concentra el conjunto. Los años previos permiten antecedentes terminados antes del periodo activo de prueba TEST-2026-2.

Se transcribieron 18 relaciones de prerrequisito legibles. Los números destacados sin leyenda no se interpretaron como requisitos institucionales. Las calificaciones son de prueba. El historial completo llega a 1 457 registros, por encima de la preferencia de 500–1 000, para preservar antecedentes coherentes en los nueve semestres.

| Objeto | Semilla | Después del flujo API y navegador |
|---|---:|---:|
| Usuarios | 101 | 101 |
| Estudiantes | 50 | 50 |
| Docentes | 50 | 50 |
| Grupos | 64 | 64 |
| Sesiones | 161 | 161 |
| Historial | 1 457 | 1 457 |
| Horarios | 50 | 52 |
| Detalles | 200 | 210 |

Los horarios adicionales corresponden a una opción de integración de cuatro materias y una opción visual de seis materias. No se agregaron registros ficticios a catálogos de tamaño natural: roles 3, días 7, estatus 4 y tipos de aula 4.

La reejecución de 12_TestData.sql reconoció su marcador y conservó los datos sin duplicarlos. Las 20 pruebas de 13_NegativeTests.sql se ejecutaron con rollback. Los 18 controles de inconsistencias en 14_DataValidation.sql devolvieron cero, incluyendo coincidencia de las catorce sesiones documentales, prerrequisitos, retícula, créditos, empalmes y restricciones confiables. Se ejecutó además el validador global de integridad SQL.

**BASE DE DATOS VALIDADA**  
**BASE DE DATOS LISTA PARA DESARROLLO**

Evidencia: fase1/Resultado_validacion.json, fase1/Validacion_datos.log, fase1/Pruebas_negativas.log y fase1/Reejecucion_idempotente.log. Los conteos de auditoría aumentan con cada selección posterior; son eventos válidos del uso de prueba.

## Fases 3 a 6: arquitectura, backend, EF y primeros endpoints

Se creó la solución de cuatro proyectos .NET 10 y el mapeo explícito de las tablas existentes. Se verificó primero GET /api/health y después GET /api/materias mediante SQL Server → EF Core → API → Swagger. Evidencia: Prueba_backend_inicial.json. El endpoint de materias pasó posteriormente a requerir autenticación.

El runtime se comprobó con sysadmin=0, db_owner=0 y permiso SELECT sobre Aud=0. El despliegue Windows no se reutiliza como identidad runtime. No se reconstruyó la base.

## Fases 7 y 8: frontend y autenticación

Se implementaron React/TypeScript/Vite/Bootstrap/Axios, las seis pantallas solicitadas, guardas por rol y estados de carga, vacío y error. Las credenciales se generan localmente y se habilitan mediante Identity.

El primer flujo quedó validado antes de comenzar el algoritmo complejo: estudiante de quinto, 19 materias elegibles, selección de cuatro materias, 16 créditos de 36. Evidencia: Prueba_primer_flujo_API.json. Después se amplió la revisión visual a las seis materias del PDF y 26 créditos.

## Fase 9: generador y persistencia

Se implementó backtracking con poda en Domain y un servicio independiente en Infrastructure. Se aplican RV-001 a RV-009 con comprobación definitiva en SQL al guardar. La selección de opciones se incorporó con el script 15_Procedures_Api.sql sin rediseñar las tablas.

La API generó una opción de cuatro grupos y 16 créditos. El navegador generó y guardó una opción de seis grupos y 26 créditos, mostró las catorce sesiones de referencia y permitió cambiar de horario seleccionado. Se comprobó el menú móvil y ausencia de desbordamiento horizontal global a 390 px; el calendario tiene desplazamiento propio.

## Fase 10: pruebas finales

| Comprobación | Resultado |
|---|---|
| Compilación .NET de la solución | 0 errores, 0 advertencias |
| xUnit: intervalos, créditos, antecedentes y generador | 34 aprobadas |
| Vitest: selección y créditos | 5 aprobadas |
| TypeScript y compilación Vite | Aprobados |
| Casos SQL de datos inválidos y continuidad válida | 20 aprobados |
| Consultas de inconsistencias | 18 en cero |
| Integración HTTP inicial | 53 comprobaciones aprobadas |
| Reejecución HTTP sin duplicar su horario | 52 comprobaciones aprobadas |
| Navegador: seis materias → generación → guardado → selección | Verificado |
| Responsive: escritorio 1280 y móvil 390 | Verificado |

La integración comprueba 401 anónimo, credenciales inválidas, 403 por rol, entradas inválidas, créditos excesivos, rechazo de grupo inexistente sin cabecera parcial, propiedad del horario, selección exclusiva, consulta de catálogos y OpenAPI. Restaura la selección anterior al finalizar.

El proyecto está listo para continuar con mantenimiento administrativo y políticas institucionales adicionales. No está presentado como un sistema de inscripción oficial ni como un despliegue productivo.
