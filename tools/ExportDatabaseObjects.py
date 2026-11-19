"""Export application schemas with Windows authentication, schema only, no login secrets."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'database' / 'actual'
ARRAYS = ('schemas','tables','table_types','columns','indexes','index_columns','defaults','checks','foreign_keys','foreign_key_columns','modules','dependencies','extended_properties','objects')
QUERY = r"""
SET NOCOUNT ON;
DECLARE @ids TABLE(id int PRIMARY KEY);
INSERT @ids SELECT object_id FROM sys.tables WHERE SCHEMA_NAME(schema_id) IN ('App','Rep','Aud') AND is_ms_shipped=0
UNION SELECT type_table_object_id FROM sys.table_types WHERE SCHEMA_NAME(schema_id) IN ('App','Rep','Aud');
SELECT DB_NAME() AS database_name,CONVERT(nvarchar(128),DATABASEPROPERTYEX(DB_NAME(),'Collation')) AS collation_name,
JSON_QUERY((SELECT name,USER_NAME(principal_id) AS owner_name FROM sys.schemas WHERE name IN ('App','Rep','Aud') ORDER BY name FOR JSON PATH)) AS schemas,
JSON_QUERY((SELECT object_id AS id,SCHEMA_NAME(schema_id) AS schema_name,name,is_memory_optimized,temporal_type,is_filetable,is_external,is_node,is_edge FROM sys.tables WHERE object_id IN(SELECT id FROM @ids) ORDER BY schema_name,name FOR JSON PATH)) AS tables,
JSON_QUERY((SELECT type_table_object_id AS id,SCHEMA_NAME(schema_id) AS schema_name,name FROM sys.table_types WHERE SCHEMA_NAME(schema_id) IN ('App','Rep','Aud') ORDER BY schema_name,name FOR JSON PATH)) AS table_types,
JSON_QUERY((SELECT c.object_id,c.column_id,c.name,T.name AS type_name,T.is_user_defined,c.max_length,c.precision,c.scale,c.is_nullable,c.is_identity,
CONVERT(varchar(50),I.seed_value) AS identity_seed,CONVERT(varchar(50),I.increment_value) AS identity_increment,I.is_not_for_replication AS identity_not_for_replication,
c.collation_name,c.is_computed,CC.definition AS computed_definition,CC.is_persisted,c.is_rowguidcol,c.is_sparse,c.is_filestream,c.generated_always_type,c.encryption_type,c.xml_collection_id
FROM sys.columns c JOIN @ids x ON x.id=c.object_id JOIN sys.types T ON T.user_type_id=c.user_type_id
LEFT JOIN sys.identity_columns I ON I.object_id=c.object_id AND I.column_id=c.column_id
LEFT JOIN sys.computed_columns CC ON CC.object_id=c.object_id AND CC.column_id=c.column_id ORDER BY c.object_id,c.column_id FOR JSON PATH)) AS columns,
JSON_QUERY((SELECT i.object_id,i.index_id,i.name,i.type,i.is_unique,i.is_primary_key,i.is_unique_constraint,i.fill_factor,i.is_padded,i.ignore_dup_key,i.allow_row_locks,i.allow_page_locks,i.is_disabled,i.has_filter,i.filter_definition
FROM sys.indexes i JOIN @ids x ON x.id=i.object_id WHERE i.index_id>0 AND i.is_hypothetical=0 ORDER BY i.object_id,i.index_id FOR JSON PATH)) AS indexes,
JSON_QUERY((SELECT i.object_id,i.index_id,i.column_id,i.key_ordinal,i.is_descending_key,i.is_included_column FROM sys.index_columns i JOIN @ids x ON x.id=i.object_id ORDER BY i.object_id,i.index_id,i.index_column_id FOR JSON PATH)) AS index_columns,
JSON_QUERY((SELECT d.parent_object_id AS object_id,d.parent_column_id AS column_id,d.name,d.definition FROM sys.default_constraints d JOIN @ids x ON x.id=d.parent_object_id ORDER BY d.name FOR JSON PATH)) AS defaults,
JSON_QUERY((SELECT c.parent_object_id AS object_id,c.name,c.definition,c.is_disabled,c.is_not_trusted,c.is_not_for_replication FROM sys.check_constraints c JOIN @ids x ON x.id=c.parent_object_id ORDER BY c.name FOR JSON PATH)) AS checks,
JSON_QUERY((SELECT f.object_id AS id,f.parent_object_id,f.referenced_object_id,f.name,f.delete_referential_action_desc,f.update_referential_action_desc,f.is_not_for_replication,f.is_disabled,f.is_not_trusted FROM sys.foreign_keys f JOIN @ids x ON x.id=f.parent_object_id ORDER BY f.name FOR JSON PATH)) AS foreign_keys,
JSON_QUERY((SELECT f.constraint_object_id,f.parent_column_id,f.referenced_column_id FROM sys.foreign_key_columns f JOIN @ids x ON x.id=f.parent_object_id ORDER BY f.constraint_object_id,f.constraint_column_id FOR JSON PATH)) AS foreign_key_columns,
JSON_QUERY((SELECT o.object_id AS id,SCHEMA_NAME(o.schema_id) AS schema_name,o.name,o.type,m.definition,m.uses_ansi_nulls,m.uses_quoted_identifier,
o.parent_object_id,TR.is_disabled FROM sys.objects o JOIN sys.sql_modules m ON m.object_id=o.object_id LEFT JOIN sys.triggers TR ON TR.object_id=o.object_id
WHERE SCHEMA_NAME(o.schema_id) IN ('App','Rep','Aud') AND o.is_ms_shipped=0 ORDER BY o.type,schema_name,o.name FOR JSON PATH)) AS modules,
JSON_QUERY((SELECT DISTINCT d.referencing_id,d.referenced_id FROM sys.sql_expression_dependencies d JOIN sys.objects o ON o.object_id=d.referencing_id WHERE SCHEMA_NAME(o.schema_id) IN ('App','Rep','Aud') AND d.referenced_id IS NOT NULL FOR JSON PATH)) AS dependencies,
JSON_QUERY((SELECT p.class,p.major_id,p.minor_id,p.name,CONVERT(nvarchar(max),p.value) AS value FROM sys.extended_properties p WHERE
(p.class IN (1,7) AND p.major_id IN(SELECT object_id FROM sys.objects WHERE SCHEMA_NAME(schema_id) IN ('App','Rep','Aud')))
OR(p.class=3 AND p.major_id IN(SELECT schema_id FROM sys.schemas WHERE name IN('App','Rep','Aud')))
OR(p.class=6 AND p.major_id IN(SELECT user_type_id FROM sys.types WHERE SCHEMA_NAME(schema_id) IN('App','Rep','Aud'))) FOR JSON PATH)) AS extended_properties,
JSON_QUERY((SELECT SCHEMA_NAME(o.schema_id) AS schema_name,o.name,o.type_desc FROM sys.objects o WHERE SCHEMA_NAME(o.schema_id) IN ('App','Rep','Aud') AND o.is_ms_shipped=0 ORDER BY schema_name,o.type_desc,o.name FOR JSON PATH)) AS objects
FOR JSON PATH,WITHOUT_ARRAY_WRAPPER;
"""

def collect(server: str):
    result = subprocess.run(['sqlcmd', '-S', server, '-E', '-C', '-I', '-b', '-f', '65001', '-y', '0', '-w', '65535', '-d', 'Bd_SistemaHorarios', '-Q', QUERY], capture_output=True, encoding='utf-8-sig')
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    data = json.loads(''.join(result.stdout.splitlines()).strip())
    for name in ARRAYS:
        data.setdefault(name, [])
    DEST.mkdir(parents=True, exist_ok=True)
    (DEST / 'Inventario_objetos.json').write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    return data

def ident(name):
    return '[' + name.replace(']', ']]') + ']'

def literal(value):
    return "N'" + value.replace("'", "''") + "'"

def full(obj):
    return ident(obj['schema_name']) + '.' + ident(obj['name'])

SETTINGS = '''SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO
'''

def build(data):
    for name in ARRAYS:
        data.setdefault(name, [])
    if data['database_name'] != 'Bd_SistemaHorarios':
        raise ValueError('Unexpected database name.')
    if data['extended_properties']:
        raise ValueError('Extended properties require an explicit supported export; none will be silently omitted.')
    tables = {t['id']: t for t in data['tables']}
    objects = {t['id']: t for t in data['tables'] + data['table_types']}
    cols = {(c['object_id'], c['column_id']): c for c in data['columns']}
    defaults = {(d['object_id'], d['column_id']): d for d in data['defaults']}
    for t in tables.values():
        if any(t.get(flag) for flag in ('is_memory_optimized','temporal_type','is_filetable','is_external','is_node','is_edge')):
            raise ValueError('Unsupported specialized table: ' + full(t))

    def column(c):
        result = ident(c['name'])
        if c.get('is_computed'):
            return result + ' AS ' + c['computed_definition'] + (' PERSISTED' if c.get('is_persisted') else '')
        if any(c.get(flag) for flag in ('is_user_defined','is_sparse','is_filestream','generated_always_type','encryption_type','xml_collection_id')):
            raise ValueError('Unsupported specialized column: ' + c['name'])
        kind = c['type_name']
        sqltype = ident(kind)
        if kind in ('varchar','char','nvarchar','nchar','varbinary','binary'):
            size = c['max_length']
            size = 'max' if size == -1 else str(size // 2 if kind.startswith('n') else size)
            sqltype += '(' + size + ')'
        elif kind in ('decimal','numeric'):
            sqltype += f"({c['precision']},{c['scale']})"
        elif kind in ('datetime2','datetimeoffset','time'):
            sqltype += f"({c['scale']})"
        elif kind == 'float':
            sqltype += f"({c['precision']})"
        result += ' ' + sqltype
        if c.get('collation_name'):
            if not re.fullmatch(r'[A-Za-z0-9_]+', c['collation_name']):
                raise ValueError('Unexpected collation.')
            result += ' COLLATE ' + c['collation_name']
        if c.get('is_identity'):
            result += f" IDENTITY({c['identity_seed']},{c['identity_increment']})"
            if c.get('identity_not_for_replication'):
                result += ' NOT FOR REPLICATION'
        if c.get('is_rowguidcol'):
            result += ' ROWGUIDCOL'
        result += ' NULL' if c['is_nullable'] else ' NOT NULL'
        default = defaults.get((c['object_id'], c['column_id']))
        if default:
            result += ' CONSTRAINT ' + ident(default['name']) + ' DEFAULT ' + default['definition']
        return result

    def index_keys(index):
        items = [c for c in data['index_columns'] if c['object_id'] == index['object_id'] and c['index_id'] == index['index_id'] and c['key_ordinal'] > 0]
        items.sort(key=lambda c: c['key_ordinal'])
        return ', '.join(ident(cols[(c['object_id'], c['column_id'])]['name']) + (' DESC' if c['is_descending_key'] else ' ASC') for c in items)

    def index_options(index):
        flags = {'PAD_INDEX':'is_padded','IGNORE_DUP_KEY':'ignore_dup_key','ALLOW_ROW_LOCKS':'allow_row_locks','ALLOW_PAGE_LOCKS':'allow_page_locks'}
        opts = [name + ' = ' + ('ON' if index[key] else 'OFF') for name,key in flags.items()]
        if index['fill_factor']:
            opts.append('FILLFACTOR = ' + str(index['fill_factor']))
        return ' WITH (' + ', '.join(opts) + ')'

    def table_sql(table, is_type=False):
        table_cols = sorted((c for c in data['columns'] if c['object_id'] == table['id']), key=lambda c: c['column_id'])
        parts = [column(c) for c in table_cols]
        for check in (c for c in data['checks'] if c['object_id'] == table['id']):
            if check['is_disabled'] or check['is_not_trusted']:
                raise ValueError('Untrusted/disabled constraint: ' + check['name'])
            parts.append('CONSTRAINT ' + ident(check['name']) + ' CHECK ' + ('NOT FOR REPLICATION ' if check['is_not_for_replication'] else '') + check['definition'])
        for index in (i for i in data['indexes'] if i['object_id'] == table['id'] and (i['is_primary_key'] or i['is_unique_constraint'])):
            if index['type'] not in (1,2) or index['is_disabled']:
                raise ValueError('Unsupported constraint index: ' + index['name'])
            clause = ('PRIMARY KEY' if index['is_primary_key'] else 'UNIQUE') + (' CLUSTERED' if index['type'] == 1 else ' NONCLUSTERED')
            clause += ' (' + index_keys(index) + ')'
            if not is_type:
                clause = 'CONSTRAINT ' + ident(index['name']) + ' ' + clause + index_options(index)
            parts.append(clause)
        return ('CREATE TYPE ' if is_type else 'CREATE TABLE ') + full(table) + (' AS TABLE' if is_type else '') + ' (\n    ' + ',\n    '.join(parts) + '\n);\nGO\n'

    collation = data['collation_name']
    if not re.fullmatch(r'[A-Za-z0-9_]+', collation):
        raise ValueError('Unexpected database collation.')
    create = '''USE [master];
GO
IF TRY_CONVERT(int,SERVERPROPERTY('ProductMajorVersion')) < 16
BEGIN
 RAISERROR(N'SQL Server 2022 or later is required.',16,1);
 SET NOEXEC ON;
END;
DECLARE @existing bit=0;
IF DB_ID(N'Bd_SistemaHorarios') IS NOT NULL
 EXEC sys.sp_executesql N'USE [Bd_SistemaHorarios]; SELECT @found=CASE WHEN EXISTS(SELECT 1 FROM sys.objects WHERE is_ms_shipped=0 AND schema_id IN(SCHEMA_ID(''App''),SCHEMA_ID(''Rep''),SCHEMA_ID(''Aud''))) THEN 1 ELSE 0 END;',N'@found bit OUTPUT',@found=@existing OUTPUT;
IF @existing=1
BEGIN
 RAISERROR(N'The database already contains application objects. No objects were replaced.',16,1);
 SET NOEXEC ON;
END;
GO
IF DB_ID(N'Bd_SistemaHorarios') IS NULL
 EXEC(N'CREATE DATABASE [Bd_SistemaHorarios] COLLATE ''' + collation + "');\nGO\nUSE [Bd_SistemaHorarios];\nGO\n"
    for schema in data['schemas']:
        create += 'IF SCHEMA_ID(' + literal(schema['name']) + ') IS NULL EXEC(' + literal('CREATE SCHEMA ' + ident(schema['name']) + ' AUTHORIZATION [dbo];') + ');\nGO\n'
    chunks = {'01_Base_y_esquemas.sql': SETTINGS + create}
    prefix = SETTINGS + 'USE [Bd_SistemaHorarios];\nGO\n'
    chunks['02_Tipos_tabla.sql'] = prefix + ''.join(table_sql(t, True) for t in data['table_types'])
    chunks['03_Tablas_y_restricciones.sql'] = prefix + ''.join(table_sql(t) for t in data['tables'])
    indexes = ''
    for index in data['indexes']:
        if index['object_id'] not in tables or index['is_primary_key'] or index['is_unique_constraint']:
            continue
        if index['type'] not in (1,2):
            raise ValueError('Unsupported index: ' + index['name'])
        indexes += 'CREATE ' + ('UNIQUE ' if index['is_unique'] else '') + ('CLUSTERED ' if index['type'] == 1 else 'NONCLUSTERED ') + 'INDEX ' + ident(index['name'])
        indexes += ' ON ' + full(tables[index['object_id']]) + ' (' + index_keys(index) + ')'
        included = [ident(cols[(c['object_id'], c['column_id'])]['name']) for c in data['index_columns'] if c['object_id'] == index['object_id'] and c['index_id'] == index['index_id'] and c['is_included_column']]
        if included:
            indexes += ' INCLUDE (' + ', '.join(included) + ')'
        if index.get('filter_definition'):
            indexes += ' WHERE ' + index['filter_definition']
        indexes += index_options(index) + ';\nGO\n'
        if index['is_disabled']:
            indexes += 'ALTER INDEX ' + ident(index['name']) + ' ON ' + full(tables[index['object_id']]) + ' DISABLE;\nGO\n'
    chunks['04_Indices.sql'] = prefix + indexes
    foreign_keys = ''
    for fk in data['foreign_keys']:
        if fk['is_disabled'] or fk['is_not_trusted']:
            raise ValueError('Untrusted/disabled FK: ' + fk['name'])
        pairs = [c for c in data['foreign_key_columns'] if c['constraint_object_id'] == fk['id']]
        parent_cols = ', '.join(ident(cols[(fk['parent_object_id'], c['parent_column_id'])]['name']) for c in pairs)
        ref_cols = ', '.join(ident(cols[(fk['referenced_object_id'], c['referenced_column_id'])]['name']) for c in pairs)
        foreign_keys += 'ALTER TABLE ' + full(tables[fk['parent_object_id']]) + ' WITH CHECK ADD CONSTRAINT ' + ident(fk['name'])
        foreign_keys += ' FOREIGN KEY (' + parent_cols + ') REFERENCES ' + full(tables[fk['referenced_object_id']]) + ' (' + ref_cols + ')'
        foreign_keys += ' ON DELETE ' + fk['delete_referential_action_desc'].replace('_',' ') + ' ON UPDATE ' + fk['update_referential_action_desc'].replace('_',' ')
        foreign_keys += (' NOT FOR REPLICATION' if fk['is_not_for_replication'] else '') + ';\nGO\n'
    chunks['05_Claves_foraneas.sql'] = prefix + foreign_keys

    def ordered_modules(types):
        pending = {m['id']: m for m in data['modules'] if m['type'].strip() in types}
        while pending:
            ready = [m for mid,m in pending.items() if not any(d['referencing_id'] == mid and d['referenced_id'] in pending and d['referenced_id'] != mid for d in data['dependencies'])]
            if not ready:
                raise ValueError('Cyclic module dependency requires explicit review.')
            for module in sorted(ready, key=lambda m: (m['schema_name'],m['name'])):
                yield module
                del pending[module['id']]

    for filename, types in (('06_Vistas_y_funciones.sql', {'V','FN','IF','TF'}), ('07_Procedimientos.sql', {'P'}), ('08_Triggers.sql', {'TR'})):
        sql = prefix
        for module in ordered_modules(types):
            if not module.get('definition'):
                raise ValueError('Unavailable/encrypted module: ' + full(module))
            sql += 'SET ANSI_NULLS ' + ('ON' if module['uses_ansi_nulls'] else 'OFF') + ';\nSET QUOTED_IDENTIFIER ' + ('ON' if module['uses_quoted_identifier'] else 'OFF') + ';\nGO\n'
            sql += module['definition'].replace('\r\n','\n').strip() + '\nGO\n'
            if module.get('is_disabled'):
                sql += 'DISABLE TRIGGER ' + full(module) + ' ON ' + full(tables[module['parent_object_id']]) + ';\nGO\n'
        chunks[filename] = sql
    security = (ROOT / 'database' / 'baseline' / '03_CreateSecurity.sql').read_text(encoding='utf-8-sig')
    security += '\nGRANT REFERENCES ON TYPE::[App].[Tbl_ListaGrupo] TO [Rol_AppSistemaHorarios];\nGO\nSET NOEXEC OFF;\nGO\n'
    chunks['09_Seguridad_sin_credenciales.sql'] = security
    note = '/* Schema-only export. No table rows, passwords, login hashes or physical server paths. */\n'
    for name, content in chunks.items():
        (DEST / name).write_text(note + content, encoding='utf-8-sig')
    combined = note + '\n'.join('/* SOURCE: ' + name + ' */\n' + text for name,text in chunks.items())
    (DEST / '00_Instalacion_completa.sql').write_text(combined, encoding='utf-8-sig')
    counts = {
        'tablas': len(data['tables']), 'tipos_tabla': len(data['table_types']),
        'vistas': sum(m['type'].strip() == 'V' for m in data['modules']),
        'procedimientos': sum(m['type'].strip() == 'P' for m in data['modules']),
        'triggers': sum(m['type'].strip() == 'TR' for m in data['modules']),
        'claves_foraneas': len(data['foreign_keys']), 'checks': len(data['checks']),
        'defaults': len(data['defaults']), 'indices_incluye_pk_unique': len(data['indexes'])
    }
    manifest = {'base': data['database_name'], 'esquemas': [s['name'] for s in data['schemas']], 'solo_estructura': True, 'autenticacion_extraccion': 'Windows', 'objetos': counts,
        'archivos': [{'archivo': p.name, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(DEST.glob('*.sql'))]}
    (DEST / 'Manifiesto_exportacion.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    return manifest

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--server', default=r'lpc:LAPTOPMASEB\DBA_TOPICOS')
    parser.add_argument('--inventory-only', action='store_true')
    parser.add_argument('--from-inventory', action='store_true')
    args = parser.parse_args()
    data = json.loads((DEST / 'Inventario_objetos.json').read_text(encoding='utf-8-sig')) if args.from_inventory else collect(args.server)
    if args.inventory_only:
        print(json.dumps({k: len(data.get(k, [])) for k in ('tables','table_types','columns','indexes','checks','foreign_keys','modules','extended_properties')}, ensure_ascii=False))
    else:
        print(json.dumps(build(data)['objetos'], ensure_ascii=False))
