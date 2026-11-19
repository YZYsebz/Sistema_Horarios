# Base de datos y objetos SQL

La carpeta `actual/` contiene una exportación de estructura de `Bd_SistemaHorarios`, obtenida del catálogo de SQL Server mediante autenticación Windows. Incluye los objetos funcionales de los esquemas **App, Rep y Aud**.

- [Instalación completa en un solo script](actual/00_Instalacion_completa.sql).
- [Instrucciones e inventario de la exportación](actual/README.md).
- [Datos de prueba reproducibles](12_TestData.sql).
- [Pruebas negativas](13_NegativeTests.sql) y [validaciones](14_DataValidation.sql).

`baseline/` conserva el diseño de la etapa inicial; los scripts 10 a 15 de esta carpeta documentan sus cambios y datos de prueba. Para crear una base nueva puede usar **la instalación completa de `actual/`**, sin ejecutar además la estructura de `baseline/` ni la migración 10.

Los scripts se conservan como código fuente SQL; no se incluye un respaldo binario de la instancia ni credenciales del servidor.
