from pathlib import Path
import json,random,hashlib

ROOT=Path(__file__).resolve().parents[1]
SQL=ROOT/'database'
SETTINGS='''SET ANSI_NULLS ON;
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
'''
def emit(name,text): (SQL/name).write_text(SETTINGS+text.strip()+'\n',encoding='utf-8-sig')
def q(s):return "N'"+str(s).replace("'","''")+"'"
def values(rows):return ',\n'.join('('+','.join('NULL' if v is None else str(v) if isinstance(v,(int,float)) else q(v) for v in row)+')' for row in rows)

# Transcripción visual de la retícula local proporcionada por el usuario. No se crean claves ficticias.
raw='''1|ACF-0901|Cálculo Diferencial|5
1|AEF-1041|Matemáticas Discretas|5
1|AED-1285|Fundamentos de Programación|5
1|SCH-1024|Taller de Administración|4
1|ACC-0906|Fundamentos de Investigación|4
1|ACA-0907|Taller de Ética|4
2|ACF-0902|Cálculo Integral|5
2|ACF-0903|Álgebra Lineal|5
2|AED-1286|Programación Orientada a Objetos|5
2|AEC-1008|Contabilidad Financiera|4
2|AEC-1058|Química|4
2|AEF-1052|Probabilidad y Estadística|5
3|ACF-0904|Cálculo Vectorial|5
3|SCC-1013|Investigación de Operaciones|4
3|AED-1026|Estructura de Datos|5
3|SCC-1005|Cultura Empresarial|4
3|ACD-0908|Desarrollo Sustentable|5
3|SCF-1006|Física General|5
4|ACF-0905|Ecuaciones Diferenciales|5
4|AEF-1031|Fundamentos de Bases de Datos|5
4|SCD-1027|Tópicos Avanzados de Programación|5
4|SCC-1017|Métodos Numéricos|4
4|AEC-1034|Fundamentos de Telecomunicaciones|4
4|SCD-1018|Principios Eléctricos y Aplicaciones Digitales|5
5|SCC-1007|Fundamentos de Ingeniería de Software|4
5|SCA-1025|Taller de Base de Datos|4
5|SCC-1012|Inteligencia Artificial|4
5|AEC-1061|Sistemas Operativos|4
5|SCD-1021|Redes de Computadoras|5
5|SCD-1003|Arquitectura de Computadoras|5
6|SCD-1011|Ingeniería de Software|5
6|SCB-1001|Administración de Bases de Datos|5
6|SCD-1015|Lenguajes y Autómatas I|5
6|SCA-1026|Taller de Sistemas Operativos|4
6|SCD-1004|Conmutación y Enrutamiento en Redes de Datos|5
6|SCC-1014|Lenguajes de Interfaz|4
7|SCG-1009|Gestión de Proyectos de Software|6
7|COH-2401|Tópicos para el Despliegue de Aplicaciones|4
7|SCD-1016|Lenguajes y Autómatas II|5
7|AEB-1055|Programación Web|5
7|SCC-1010|Graficación|4
7|SCC-1023|Sistemas Programables|4
8|COC-2402|Inteligencia de Negocios I|4
8|COC-2403|Servicios en la Nube|4
8|COH-2405|Desarrollo de Aplicaciones Móviles|4
8|ACA-0909|Taller de Investigación I|4
8|SCC-1019|Programación Lógica y Funcional|4
8|SCA-1002|Administración de Redes|4
9|COC-2404|Inteligencia de Negocios II|4
9|COB-2406|Proyecto Integrador para Aplicaciones Empresariales|5
9|ACA-0910|Taller de Investigación II|4
9|SCD-1022|Simulación|5'''
courses=[dict(semestre=int(s),clave=k,nombre=n,creditos=int(c),origen='PDF_RETICULA') for s,k,n,c in (r.split('|') for r in raw.splitlines())]
bycode={c['clave']:c for c in courses}
assert len(courses)==52 and sum(c['creditos'] for c in courses)==235
# Los componentes tienen códigos reales en el PDF, pero no generan reuniones semanales.
components=[dict(semestre=s,clave=k,nombre=n,creditos=c,origen='PDF_RETICULA',componente=True) for s,k,n,c in [(5,'AC','Actividades Complementarias',5),(7,'S1','Servicio Social',10),(9,'R1','Residencia Profesional',10)]]
prereqs=[('ACF-0902','ACF-0901'),('ACF-0904','ACF-0902'),('ACF-0905','ACF-0904'),
 ('AED-1286','AED-1285'),('AED-1026','AED-1286'),('SCD-1027','AED-1026'),
 ('SCA-1025','AEF-1031'),('SCB-1001','SCA-1025'),('SCD-1021','AEC-1034'),
 ('SCD-1004','SCD-1021'),('SCA-1026','AEC-1061'),('SCD-1003','SCD-1018'),
 ('SCC-1014','SCD-1003'),('SCC-1023','SCC-1014'),('SCD-1016','SCD-1015'),
 ('SCD-1011','SCC-1007'),('SCG-1009','SCD-1011'),('ACA-0910','ACA-0909')]
real_teachers=['RUIZ GAYTAN LUZ DEL CARMEN','BALTAZAR FLORES MARIA DEL ROSARIO',
 'VALDIVIA MURILLO MARIA MAGDALENA','RAMIREZ MENDEZ JESUS ENRIQUE','TRUJILLO CASTELLANOS CARLOS ALBERTO']
refs={
 'SCA-1025':('5B',0,'D11',[(1,'10:30','12:10'),(3,'10:30','12:10')]),
 'SCC-1012':('5C',1,'D6',[(1,'07:00','08:40'),(3,'07:00','08:40')]),
 'SCD-1003':('5A',2,'D9',[(1,'08:45','10:25'),(3,'08:45','10:25'),(5,'08:45','09:35')]),
 'SCD-1021':('5B',3,'LR2',[(2,'10:30','12:10'),(4,'10:30','12:10'),(5,'11:20','12:10')]),
 'SCC-1007':('5B',4,'D7',[(2,'07:00','08:40'),(4,'07:00','08:40')]),
 'AEC-1061':('5B',4,'LC2',[(2,'08:45','10:25'),(4,'08:45','10:25')])}
teachers=[dict(clave=f'REF-DOC-{i+1:03}',nombre=n,origen_nombre='PDF_CARGA',origen_clave='SINTETICO') for i,n in enumerate(real_teachers)]
teachers += [dict(clave=f'SYN-DOC-{i+1:03}',nombre=f'Docente Sintético {i+1:03}',origen_nombre='SINTETICO',origen_clave='SINTETICO') for i in range(45)]
def overlap(a,b):return a[0]==b[0] and a[1]<b[2] and b[1]<a[2]
groups=[]; teacher_sessions={t['clave']:[] for t in teachers}
morning=[('07:00','08:40'),('08:45','10:25'),('10:30','12:10')]
friday=[('07:00','07:50'),('07:50','08:40'),('08:45','09:35'),('09:35','10:25'),('10:30','11:20'),('11:20','12:10')]
for c in courses:
    if c['clave'] in refs:
        group,tid,room,sessions=refs[c['clave']];teacher=teachers[tid]['clave'];origin='PDF_CARGA'
    else:
        peers=[x for x in courses if x['semestre']==c['semestre']]
        i=peers.index(c);a,b=morning[i%3];days=(1,3) if i<3 else (2,4)
        sessions=[(d,a,b) for d in days]
        if c['creditos']==5:sessions.append((5,*friday[i]))
        if c['creditos']==6:sessions.append((5,a,b))
        available=[t for t in teachers[5:] if not any(overlap(a,b) for a in sessions for b in teacher_sessions[t['clave']])]
        teacher=min(available,key=lambda t:len(teacher_sessions[t['clave']]))['clave']
        room='D'+str(20+c['semestre']);group=f"{c['semestre']}T1";origin='SINTETICO'
    groups.append(dict(materia=c['clave'],grupo=group,docente=teacher,aula=room,sesiones=sessions,origen=origin))
    teacher_sessions[teacher]+=sessions
for i,c in enumerate(courses[:12]):
    a,b=('13:00','14:40') if i%2==0 else ('14:45','16:25')
    days=(1,3) if i%4<2 else (2,4)
    sessions=[(d,a,b) for d in days]
    if c['creditos']==5:sessions.append((5,a,'13:50' if a=='13:00' else '15:35'))
    teacher=min([t for t in teachers[5:] if not any(overlap(a,b) for a in sessions for b in teacher_sessions[t['clave']])],key=lambda t:len(teacher_sessions[t['clave']]))['clave']
    groups.append(dict(materia=c['clave'],grupo=f"{c['semestre']}T2",docente=teacher,aula=f'D{40+i}',sesiones=sessions,origen='SINTETICO'))
    teacher_sessions[teacher]+=sessions
for i,a in enumerate(groups):
    for b in groups[i+1:]:
        assert not ((a['docente']==b['docente'] or a['aula']==b['aula']) and any(overlap(x,y) for x in a['sesiones'] for y in b['sesiones']))
semesters=[5]*22+[4]*8+[3]*6+[6]*4+[7]*4+[2]*2+[1]*2+[8,9]
rng=random.Random(24242026); seen={'24240198'};students=[];history=[]
for i,sem in enumerate(semesters,1):
    year=2024 if sem in (3,4,5,6) else 2023 if sem in (7,8) else 2022 if sem==9 else 2026
    while True:
        control=f'{year%100:02}{year%100:02}{rng.randrange(10000):04}'
        if control not in seen:seen.add(control);break
    student=dict(indice=i,control=control,nombre=f'Estudiante Sintético {i:03}',semestre=sem,anio=year,generacion=year%100)
    approved=set()
    for c in courses:
        if c['semestre']<sem:
            status='NO_APROBADA' if i%7==0 and c['semestre']==sem-1 and c==next(x for x in courses if x['semestre']==sem-1) else 'APROBADA'
            # Periodos sintéticos anteriores al activo, sin afirmar fechas que no contiene la carga.
            offset=c['semestre']-1
            yr=year+offset//2
            half=2 if offset%2==0 else 1
            if half==1:yr+=1
            if (yr,half)>=(2026,2):yr,half=2026,1
            history.append((control,c['clave'],f'TEST-{yr}-{half}',status,82+(i%16) if status=='APROBADA' else 55))
            if status=='APROBADA':approved.add(c['clave'])
    eligible=[c for c in courses if c['semestre']==sem and all(pr in approved for k,pr in prereqs if k==c['clave'])]
    assert len(eligible)>=4,(i,sem,eligible)
    selected=eligible[:4]
    student['materias_horario']=[c['clave'] for c in selected]
    for c in [x for x in courses if x['semestre']==sem]:
        status='CURSANDO' if c not in selected and c==eligible[-1] and len(eligible)>4 and i%3==0 else 'PENDIENTE'
        history.append((control,c['clave'],'TEST-2026-2' if status=='CURSANDO' else None,status,None))
    future=next((c for c in courses if c['semestre']>sem),None)
    if future:history.append((control,future['clave'],None,'PENDIENTE',None))
    students.append(student)
assert len(students)==50 and len({s['control'] for s in students})==50
manifest=dict(reticula='ISIC-2010-224',especialidad='ISIE-COE-2024-02',materias=courses+components,
             prerrequisitos=[dict(materia=k,prerrequisito=p,origen='ARCO_VISIBLE_PDF_RETICULA') for k,p in prereqs],
             docentes=teachers,grupos=groups,estudiantes=students,
             conteos=dict(usuarios=101,estudiantes=50,docentes=50,grupos=len(groups),sesiones=sum(len(g['sesiones']) for g in groups),historial=len(history),horarios=50,detalles=200))
(ROOT/'docs'/'fase1'/'Datos_fuentes_y_sinteticos.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')

migration='''/* Cambio acotado exigido por los nuevos requisitos. No reconstruye la base.
Se aborta si hay estudiantes que requieren depuración; nunca se truncan números existentes. */
BEGIN TRY
 BEGIN TRANSACTION;
 EXEC App.Sp_BloquearIntegridad;
 IF EXISTS(SELECT 1 FROM App.Tbl_Estudiante WHERE LEN(cNumeroControl)<>8 OR cNumeroControl COLLATE Latin1_General_100_BIN2 LIKE '%[^0-9]%')
  THROW 52000,N'Existen números de control incompatibles; depure sin truncar antes de migrar.',1;
 IF COL_LENGTH('App.Tbl_Estudiante','cNombre') IS NULL EXEC(N'ALTER TABLE App.Tbl_Estudiante ADD cNombre nvarchar(150) NULL;');
 IF COL_LENGTH('App.Tbl_Estudiante','nAnioIngreso') IS NULL EXEC(N'ALTER TABLE App.Tbl_Estudiante ADD nAnioIngreso smallint NULL;');
 IF COL_LENGTH('App.Tbl_Estudiante','nGeneracion') IS NULL EXEC(N'ALTER TABLE App.Tbl_Estudiante ADD nGeneracion tinyint NULL;');
 EXEC(N'IF EXISTS(SELECT 1 FROM App.Tbl_Estudiante WHERE cNombre IS NULL OR nAnioIngreso IS NULL OR nGeneracion IS NULL)
 THROW 52001,N''Complete nombre, año y generación de estudiantes existentes antes de migrar.'',1;');
 IF EXISTS(SELECT 1 FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID('App.Tbl_Estudiante') AND name='UQ_Tbl_Estudiante_cNumeroControl')
 ALTER TABLE App.Tbl_Estudiante DROP CONSTRAINT UQ_Tbl_Estudiante_cNumeroControl;
 IF EXISTS(SELECT 1 FROM sys.check_constraints WHERE name='CK_Tbl_Estudiante_cNumeroControl_NoVacio')
 ALTER TABLE App.Tbl_Estudiante DROP CONSTRAINT CK_Tbl_Estudiante_cNumeroControl_NoVacio;
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE name='CK_Tbl_Estudiante_NumeroControl8')
 BEGIN
  ALTER TABLE App.Tbl_Estudiante ALTER COLUMN cNumeroControl char(8) NOT NULL;
  ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT CK_Tbl_Estudiante_NumeroControl8 CHECK(LEN(cNumeroControl)=8 AND cNumeroControl COLLATE Latin1_General_100_BIN2 NOT LIKE '%[^0-9]%');
 END;
 ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT UQ_Tbl_Estudiante_cNumeroControl UNIQUE(cNumeroControl);
 EXEC(N'ALTER TABLE App.Tbl_Estudiante ALTER COLUMN cNombre nvarchar(150) NOT NULL;
 ALTER TABLE App.Tbl_Estudiante ALTER COLUMN nAnioIngreso smallint NOT NULL;
 ALTER TABLE App.Tbl_Estudiante ALTER COLUMN nGeneracion tinyint NOT NULL;');
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE name='CK_Tbl_Estudiante_IngresoGeneracion')
 EXEC(N'ALTER TABLE App.Tbl_Estudiante ADD CONSTRAINT CK_Tbl_Estudiante_IngresoGeneracion CHECK
 (nAnioIngreso BETWEEN 1950 AND 2100 AND nGeneracion BETWEEN 0 AND 99 AND LEN(LTRIM(RTRIM(cNombre)))>0
 AND LEFT(cNumeroControl,2)=RIGHT(CONVERT(varchar(4),nAnioIngreso),2)
 AND SUBSTRING(cNumeroControl,3,2)=RIGHT(''00''+CONVERT(varchar(2),nGeneracion),2));');
 COMMIT;
END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
GO'''
emit('10_StudentRequirements.sql',migration)
catalog=(SQL/'baseline'/'11_SeedCatalogs.sql').read_text(encoding='utf-8-sig')
(SQL/'11_SeedCatalogs.sql').write_text(catalog,encoding='utf-8-sig')

seed='''/* SOLO DESARROLLO. Semilla estable SH-DEV-2026-01.
Maestros académicos y seis grupos provienen de los dos PDF documentados.
Usuarios, control, nombres de estudiantes, períodos, capacidades, IDs de empleado y grupos adicionales son sintéticos.
La autenticación se habilita después mediante PasswordHasher de Identity; no hay contraseñas en este archivo. */
BEGIN TRY
 BEGIN TRANSACTION;
 EXEC App.Sp_BloquearIntegridad;
 DECLARE @nIdReticula int,@nIdPeriodo int;
 IF EXISTS(SELECT 1 FROM App.Tbl_HorarioGenerado WHERE cNombre LIKE N'DEMO-v1-%')
 BEGIN
  IF (SELECT COUNT(*) FROM App.Tbl_HorarioGenerado WHERE cNombre LIKE N'DEMO-v1-%')<>50 THROW 52002,N'Semilla parcial: revise el estado; no se sobreescriben horarios confirmados.',1;
  PRINT N'Semilla SH-DEV-2026-01 ya existente. No se duplican registros.';
  COMMIT; RETURN;
 END;
 IF EXISTS(SELECT 1 FROM App.Tbl_PeriodoAcademico WHERE nActivoGeneracion=1)
 THROW 52003,N'Ya hay un periodo activo ajeno a esta semilla. No se desactiva automáticamente.',1;
 IF NOT EXISTS(SELECT 1 FROM App.Cat_Carrera WHERE cClave='ISC') INSERT App.Cat_Carrera(cClave,cNombre) VALUES('ISC',N'Ingeniería en Sistemas Computacionales');
 IF NOT EXISTS(SELECT 1 FROM App.Cat_Reticula WHERE cClave='ISIC-2010-224')
 INSERT App.Cat_Reticula(nIdCarrera,cClave,cNombre) SELECT nIdCarrera,'ISIC-2010-224',N'ISIC-2010-224 · Cómputo Empresarial ISIE-COE-2024-02' FROM App.Cat_Carrera WHERE cClave='ISC';
 SELECT @nIdReticula=nIdReticula FROM App.Cat_Reticula WHERE cClave='ISIC-2010-224';
 CREATE TABLE #Materias(cClave varchar(30),cNombre nvarchar(150),nSemestre tinyint,nCreditos tinyint);
 INSERT #Materias VALUES
'''+values([(c['clave'],c['nombre'],c['semestre'],c['creditos']) for c in courses+components])+''';
 INSERT App.Cat_Materia(cClave,cNombre) SELECT S.cClave,S.cNombre FROM #Materias S WHERE NOT EXISTS(SELECT 1 FROM App.Cat_Materia M WHERE M.cClave=S.cClave);
 INSERT App.Tbl_ReticulaMateria(nIdReticula,nIdMateria,nSemestreRecomendado,nCreditos,nObligatoria)
 SELECT @nIdReticula,M.nIdMateria,S.nSemestre,S.nCreditos,1 FROM #Materias S JOIN App.Cat_Materia M ON M.cClave=S.cClave
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_ReticulaMateria RM WHERE RM.nIdReticula=@nIdReticula AND RM.nIdMateria=M.nIdMateria);
 CREATE TABLE #Prerequisitos(cMateria varchar(30),cPrevia varchar(30));
 INSERT #Prerequisitos VALUES
'''+values(prereqs)+''';
 INSERT App.Tbl_MateriaPrerrequisito(nIdReticula,nIdMateria,nIdMateriaPrerrequisito)
 SELECT @nIdReticula,M.nIdMateria,P.nIdMateria FROM #Prerequisitos S JOIN App.Cat_Materia M ON M.cClave=S.cMateria JOIN App.Cat_Materia P ON P.cClave=S.cPrevia
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_MateriaPrerrequisito R WHERE R.nIdReticula=@nIdReticula AND R.nIdMateria=M.nIdMateria AND R.nIdMateriaPrerrequisito=P.nIdMateria);
 CREATE TABLE #Estudiantes(nIndice int,cNumeroControl char(8),cNombre nvarchar(150),nSemestre tinyint,nAnio smallint,nGeneracion tinyint);
 INSERT #Estudiantes VALUES
'''+values([(s['indice'],s['control'],s['nombre'],s['semestre'],s['anio'],s['generacion']) for s in students])+''';
 IF EXISTS(SELECT cNumeroControl FROM #Estudiantes GROUP BY cNumeroControl HAVING COUNT(*)>1) THROW 52004,N'Números sintéticos repetidos.',1;
 CREATE TABLE #Docentes(nIndice int,cClave varchar(25),cNombre nvarchar(150));
 INSERT #Docentes VALUES
'''+values([(i+1,t['clave'],t['nombre']) for i,t in enumerate(teachers)])+''';
 INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado,cCorreo,cCorreoNormalizado,cSecurityStamp,cConcurrencyStamp)
 SELECT 'estudiante.'+cNumeroControl,UPPER('estudiante.'+cNumeroControl),'estudiante.'+cNumeroControl+'@example.test',UPPER('estudiante.'+cNumeroControl+'@example.test'),CONVERT(nvarchar(36),NEWID()),CONVERT(nvarchar(36),NEWID())
 FROM #Estudiantes S WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_Usuario U WHERE U.cNombreUsuario='estudiante.'+S.cNumeroControl);
 INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado,cCorreo,cCorreoNormalizado,cSecurityStamp,cConcurrencyStamp)
 SELECT 'docente.'+RIGHT('000'+CONVERT(varchar(3),nIndice),3),UPPER('docente.'+RIGHT('000'+CONVERT(varchar(3),nIndice),3)),
 'docente.'+RIGHT('000'+CONVERT(varchar(3),nIndice),3)+'@example.test',UPPER('docente.'+RIGHT('000'+CONVERT(varchar(3),nIndice),3)+'@example.test'),CONVERT(nvarchar(36),NEWID()),CONVERT(nvarchar(36),NEWID())
 FROM #Docentes S WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_Usuario U WHERE U.cNombreUsuario='docente.'+RIGHT('000'+CONVERT(varchar(3),S.nIndice),3));
 IF NOT EXISTS(SELECT 1 FROM App.Tbl_Usuario WHERE cNombreUsuario='coordinador.demo')
 INSERT App.Tbl_Usuario(cNombreUsuario,cNombreUsuarioNormalizado,cSecurityStamp,cConcurrencyStamp) VALUES('coordinador.demo','COORDINADOR.DEMO',CONVERT(nvarchar(36),NEWID()),CONVERT(nvarchar(36),NEWID()));
 INSERT App.Tbl_Estudiante(nIdUsuario,cNumeroControl,cNombre,nAnioIngreso,nGeneracion)
 SELECT U.nIdUsuario,S.cNumeroControl,S.cNombre,S.nAnio,S.nGeneracion FROM #Estudiantes S JOIN App.Tbl_Usuario U ON U.cNombreUsuario='estudiante.'+S.cNumeroControl
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_Estudiante E WHERE E.cNumeroControl=S.cNumeroControl);
 INSERT App.Tbl_TrayectoriaEstudiante(nIdEstudiante,nIdReticula,nSemestreActual,nLimiteCreditos,dFechaInicio)
 SELECT E.nIdEstudiante,@nIdReticula,S.nSemestre,36,DATEFROMPARTS(S.nAnio,8,1) FROM #Estudiantes S JOIN App.Tbl_Estudiante E ON E.cNumeroControl=S.cNumeroControl
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_TrayectoriaEstudiante T WHERE T.nIdEstudiante=E.nIdEstudiante AND T.dFechaFin IS NULL);
 INSERT App.Tbl_Docente(nIdUsuario,cNumeroEmpleado,cNombre)
 SELECT U.nIdUsuario,S.cClave,S.cNombre FROM #Docentes S JOIN App.Tbl_Usuario U ON U.cNombreUsuario='docente.'+RIGHT('000'+CONVERT(varchar(3),S.nIndice),3)
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_Docente D WHERE D.cNumeroEmpleado=S.cClave);
 INSERT App.Tbl_UsuarioRol(nIdUsuario,nIdRol)
 SELECT U.nIdUsuario,R.nIdRol FROM App.Tbl_Usuario U JOIN App.Cat_Rol R ON R.cNombreNormalizado=
 CASE WHEN U.cNombreUsuario LIKE 'estudiante.%' THEN 'ESTUDIANTE' WHEN U.cNombreUsuario LIKE 'docente.%' THEN 'DOCENTE' ELSE 'COORDINADOR' END
 WHERE (U.cNombreUsuario LIKE 'estudiante.%' OR U.cNombreUsuario LIKE 'docente.%' OR U.cNombreUsuario='coordinador.demo')
 AND NOT EXISTS(SELECT 1 FROM App.Tbl_UsuarioRol UR WHERE UR.nIdUsuario=U.nIdUsuario AND UR.nIdRol=R.nIdRol);
 CREATE TABLE #Periodos(cClave varchar(20),dInicio date,dFin date);
 INSERT #Periodos VALUES
'''+values([(f'TEST-{yr}-{half}',f'{yr}-01-15' if half==1 else f'{yr}-08-17',f'{yr}-06-30' if half==1 else f'{yr}-12-18') for yr in range(2022,2027) for half in (1,2)])+''';
 INSERT App.Tbl_PeriodoAcademico(cClave,cNombre,dFechaInicio,dFechaFin,nActivoGeneracion)
 SELECT cClave,N'Periodo sintético '+cClave,dInicio,dFin,CASE WHEN cClave='TEST-2026-2' THEN 1 ELSE 0 END FROM #Periodos S
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_PeriodoAcademico P WHERE P.cClave=S.cClave);
 SELECT @nIdPeriodo=nIdPeriodo FROM App.Tbl_PeriodoAcademico WHERE cClave='TEST-2026-2';
 CREATE TABLE #Aulas(cClave varchar(30),cTipo varchar(30));
 INSERT #Aulas VALUES
'''+values([(room,'COMPUTO' if room.startswith('LC') else 'LABORATORIO' if room.startswith('LR') else 'AULA') for room in sorted({g['aula'] for g in groups})])+''';
 INSERT App.Tbl_Aula(nIdTipoAula,cClave,nCapacidad) SELECT T.nIdTipoAula,S.cClave,35 FROM #Aulas S JOIN App.Cat_TipoAula T ON T.cClave=S.cTipo
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_Aula A WHERE A.cClave=S.cClave);
 CREATE TABLE #Grupos(cMateria varchar(30),cGrupo varchar(20),cDocente varchar(25));
 INSERT #Grupos VALUES
'''+values([(g['materia'],g['grupo'],g['docente']) for g in groups])+''';
 INSERT App.Tbl_Grupo(nIdMateria,nIdDocente,nIdPeriodo,cClaveGrupo)
 SELECT M.nIdMateria,D.nIdDocente,@nIdPeriodo,S.cGrupo FROM #Grupos S JOIN App.Cat_Materia M ON M.cClave=S.cMateria JOIN App.Tbl_Docente D ON D.cNumeroEmpleado=S.cDocente
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_Grupo G WHERE G.nIdPeriodo=@nIdPeriodo AND G.nIdMateria=M.nIdMateria AND G.cClaveGrupo=S.cGrupo);
 CREATE TABLE #Sesiones(cMateria varchar(30),cGrupo varchar(20),nDia tinyint,cAula varchar(30),dInicio time(0),dFin time(0));
 INSERT #Sesiones VALUES
'''+values([(g['materia'],g['grupo'],d,g['aula'],a,b) for g in groups for d,a,b in g['sesiones']])+''';
 INSERT App.Tbl_SesionGrupo(nIdGrupo,nIdDiaSemana,nIdAula,dHoraInicio,dHoraFin)
 SELECT G.nIdGrupo,S.nDia,A.nIdAula,S.dInicio,S.dFin FROM #Sesiones S JOIN App.Cat_Materia M ON M.cClave=S.cMateria
 JOIN App.Tbl_Grupo G ON G.nIdPeriodo=@nIdPeriodo AND G.nIdMateria=M.nIdMateria AND G.cClaveGrupo=S.cGrupo JOIN App.Tbl_Aula A ON A.cClave=S.cAula
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_SesionGrupo X WHERE X.nIdGrupo=G.nIdGrupo AND X.nIdDiaSemana=S.nDia AND X.nIdAula=A.nIdAula AND X.dHoraInicio=S.dInicio AND X.dHoraFin=S.dFin);
 CREATE TABLE #Historial(cControl char(8),cMateria varchar(30),cPeriodo varchar(20) NULL,cEstatus varchar(15),nNota decimal(5,2) NULL);
'''
# SQL Server limita INSERT VALUES a 1000 filas.
for i in range(0,len(history),500): seed+='INSERT #Historial VALUES\n'+values(history[i:i+500])+';\n'
seed+='''INSERT App.Tbl_HistorialAcademico(nIdEstudiante,nIdMateria,nIdPeriodo,nIdEstatusAcademico,nCalificacion)
 SELECT E.nIdEstudiante,M.nIdMateria,P.nIdPeriodo,EA.nIdEstatusAcademico,S.nNota FROM #Historial S
 JOIN App.Tbl_Estudiante E ON E.cNumeroControl=S.cControl JOIN App.Cat_Materia M ON M.cClave=S.cMateria
 LEFT JOIN App.Tbl_PeriodoAcademico P ON P.cClave=S.cPeriodo JOIN App.Cat_EstatusAcademico EA ON EA.cClave=S.cEstatus
 WHERE NOT EXISTS(SELECT 1 FROM App.Tbl_HistorialAcademico H WHERE H.nIdEstudiante=E.nIdEstudiante AND H.nIdMateria=M.nIdMateria
 AND (H.nIdPeriodo=P.nIdPeriodo OR (H.nIdPeriodo IS NULL AND P.nIdPeriodo IS NULL)));
 EXEC App.Sp_PublicarOferta @nIdPeriodo;
 CREATE TABLE #Seleccion(cControl char(8),cMateria varchar(30),cGrupo varchar(20));
 INSERT #Seleccion VALUES
'''+values([(s['control'],k,next(g['grupo'] for g in groups if g['materia']==k)) for s in students for k in s['materias_horario']])+''';
 DECLARE @nTrayectoria int,@cControl char(8),@nHorario int,@cNombre nvarchar(100);
 DECLARE @Grupos App.Tbl_ListaGrupo;
 DECLARE C CURSOR LOCAL FAST_FORWARD FOR SELECT T.nIdTrayectoria,E.cNumeroControl FROM #Estudiantes S
 JOIN App.Tbl_Estudiante E ON E.cNumeroControl=S.cNumeroControl JOIN App.Tbl_TrayectoriaEstudiante T ON T.nIdEstudiante=E.nIdEstudiante AND T.dFechaFin IS NULL ORDER BY S.nIndice;
 OPEN C; FETCH NEXT FROM C INTO @nTrayectoria,@cControl;
 WHILE @@FETCH_STATUS=0
 BEGIN
  DELETE @Grupos;
  INSERT @Grupos SELECT G.nIdGrupo FROM #Seleccion S JOIN App.Cat_Materia M ON M.cClave=S.cMateria
  JOIN App.Tbl_Grupo G ON G.nIdMateria=M.nIdMateria AND G.nIdPeriodo=@nIdPeriodo AND G.cClaveGrupo=S.cGrupo WHERE S.cControl=@cControl;
  SET @cNombre=N'DEMO-v1-'+@cControl;
  EXEC App.Sp_GuardarHorarioGenerado @nTrayectoria,@nIdPeriodo,@cNombre,@Grupos,@nHorario OUTPUT,1;
  FETCH NEXT FROM C INTO @nTrayectoria,@cControl;
 END;
 CLOSE C; DEALLOCATE C;
 INSERT Aud.Tbl_Auditoria(nIdUsuario,cOperacion,cEsquema,cObjeto,nIdRegistroAfectado,cDatosAdicionales)
 SELECT E.nIdUsuario,'INSERT_ESTUDIANTE','App','Tbl_Estudiante',E.nIdEstudiante,N'SIMULACIÓN SH-DEV-2026-01; no constituye un evento de una operación real.'
 FROM #Estudiantes S JOIN App.Tbl_Estudiante E ON E.cNumeroControl=S.cNumeroControl;
 EXEC App.Sp_ValidarIntegridadOferta;
 COMMIT;
 PRINT N'Semilla SH-DEV-2026-01 completada.';
END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
GO'''
emit('12_TestData.sql',seed)
print(json.dumps(manifest['conteos'],ensure_ascii=False))
