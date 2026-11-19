using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using SistemaHorarios.Application.Academic;
using SistemaHorarios.Application.Contracts;
using SistemaHorarios.Infrastructure.Persistence;
namespace SistemaHorarios.Infrastructure.Academic;

public sealed class AcademicService(HorariosDbContext db):IAcademicService
{
 public async Task<IReadOnlyList<MateriaDto>> MateriasAsync(CancellationToken ct)=>await db.Materia.AsNoTracking().OrderBy(x=>x.Clave).Select(x=>new MateriaDto(x.IdMateria,x.Clave,x.Nombre,x.Estatus)).ToListAsync(ct);
 public async Task<PerfilDto> PerfilAsync(int usuario,CancellationToken ct)
 {
  var data=await (from e in db.Estudiante.AsNoTracking() join t in db.TrayectoriaEstudiante on e.IdEstudiante equals t.IdEstudiante
   join r in db.Reticula on t.IdReticula equals r.IdReticula join c in db.Carrera on r.IdCarrera equals c.IdCarrera
   from p in db.PeriodoAcademico where e.IdUsuario==usuario && e.Estatus && t.FechaFin==null && p.ActivoGeneracion
   select new {e.IdEstudiante,e.NumeroControl,e.Nombre,t.SemestreActual,t.LimiteCreditos,t.IdReticula,Reticula=r.Clave,Carrera=c.Nombre,p.IdPeriodo,Periodo=p.Clave}).SingleOrDefaultAsync(ct)
   ?? throw new AcademicException("PERFIL","Se requiere un estudiante vigente y un periodo académico activo.",404);
  var aprobadas=await (from h in db.HistorialAcademico.AsNoTracking() join ea in db.EstatusAcademico on h.IdEstatusAcademico equals ea.IdEstatusAcademico
   where h.IdEstudiante==data.IdEstudiante && ea.Clave=="APROBADA" select h.IdMateria).Distinct().ToListAsync(ct);
  var creditos=await db.ReticulaMateria.AsNoTracking().Where(x=>x.IdReticula==data.IdReticula && aprobadas.Contains(x.IdMateria)).SumAsync(x=>(int)x.Creditos,ct);
  return new(data.IdEstudiante,data.NumeroControl,data.Nombre,data.SemestreActual,data.LimiteCreditos,data.IdReticula,data.Reticula,data.Carrera,data.IdPeriodo,data.Periodo,creditos);
 }
 public async Task<IReadOnlyList<MateriaDisponibleDto>> DisponiblesAsync(int usuario,CancellationToken ct)
 {
  var perfil=await PerfilAsync(usuario,ct);
  var rows=await db.Database.SqlQueryRaw<DisponibleRow>("""
   SELECT V.nIdMateria AS Id,V.cClaveMateria AS Clave,V.cMateria AS Nombre,CONVERT(int,V.nCreditos) AS Creditos,
   CONVERT(int,V.nSemestreRecomendado) AS Semestre,V.nObligatoria AS Obligatoria,
   (SELECT COUNT(*) FROM App.Tbl_Grupo G JOIN App.Tbl_PeriodoAcademico P ON P.nIdPeriodo=G.nIdPeriodo
    WHERE G.nIdMateria=V.nIdMateria AND G.nIdPeriodo=V.nIdPeriodo AND G.nEstatus=1 AND P.nOfertaPublicada=1) AS Grupos
   FROM App.Vi_MateriasDisponibles V WHERE V.nIdEstudiante=@estudiante
   """,new SqlParameter("@estudiante",perfil.IdEstudiante)).ToListAsync(ct);
  return rows.Where(x=>x.Grupos>0).OrderBy(x=>x.Semestre).ThenBy(x=>x.Clave).Select(x=>new MateriaDisponibleDto(x.Id,x.Clave,x.Nombre,x.Creditos,x.Semestre,x.Obligatoria,x.Grupos)).ToArray();
 }
 public async Task<CreditosDto> CreditosAsync(int usuario,int[] materias,CancellationToken ct)
 {
  if(materias is null || materias.Length==0 || materias.Length>12)throw new AcademicException("SELECCION","Seleccione entre una y doce materias.",400);
  if(materias.Distinct().Count()!=materias.Length)throw new AcademicException("RV-001","No repita materias.",400);
  var perfil=await PerfilAsync(usuario,ct);var disponibles=await DisponiblesAsync(usuario,ct);
  var elegidas=disponibles.Where(x=>materias.Contains(x.Id)).ToArray();
  if(elegidas.Length!=materias.Length)throw new AcademicException("RV-004/007","La selección incluye materias no disponibles para tu retícula o antecedentes.");
  var total=elegidas.Sum(x=>x.Creditos);return new(total,perfil.LimiteCreditos,total<=perfil.LimiteCreditos,elegidas.Length);
 }
 public async Task<IReadOnlyList<GrupoDto>> GruposAsync(int usuario,bool coordinador,bool docente,CancellationToken ct)
 {
  var query=from g in db.Grupo.AsNoTracking() join m in db.Materia on g.IdMateria equals m.IdMateria
   join p in db.PeriodoAcademico on g.IdPeriodo equals p.IdPeriodo
   join d in db.Docente on g.IdDocente equals (int?)d.IdDocente into docentes from d in docentes.DefaultIfEmpty()
   where coordinador || (g.Estatus && p.ActivoGeneracion && p.OfertaPublicada && (!docente || (d!=null && d.IdUsuario==usuario)))
   orderby m.Clave,g.ClaveGrupo select new {g.IdGrupo,g.IdMateria,MateriaClave=m.Clave,Materia=m.Nombre,g.ClaveGrupo,g.IdDocente,Docente=d==null?"Sin asignar":d.Nombre,g.IdPeriodo,Periodo=p.Clave,g.Estatus};
  var grupos=await query.ToListAsync(ct);var ids=grupos.Select(x=>x.IdGrupo).ToArray();
  var sesiones=await (from s in db.SesionGrupo.AsNoTracking() join a in db.Aula on s.IdAula equals a.IdAula join d in db.DiaSemana on s.IdDiaSemana equals d.IdDiaSemana
   where ids.Contains(s.IdGrupo) orderby s.IdDiaSemana,s.HoraInicio
   select new{s.IdGrupo,Dto=new SesionDto(s.IdSesionGrupo,s.IdDiaSemana,d.Nombre,a.IdAula,a.Clave,s.HoraInicio,s.HoraFin)}).ToListAsync(ct);
  return grupos.Select(x=>new GrupoDto(x.IdGrupo,x.IdMateria,x.MateriaClave,x.Materia,x.ClaveGrupo,x.IdDocente,x.Docente,x.IdPeriodo,x.Periodo,x.Estatus,sesiones.Where(s=>s.IdGrupo==x.IdGrupo).Select(s=>s.Dto).ToArray())).ToArray();
 }
 public async Task<IReadOnlyList<HorarioDto>> HorariosAsync(int usuario,CancellationToken ct)
 {
  var owned=await (from h in db.HorarioGenerado.AsNoTracking() join t in db.TrayectoriaEstudiante on h.IdTrayectoria equals t.IdTrayectoria
   join e in db.Estudiante on t.IdEstudiante equals e.IdEstudiante join p in db.PeriodoAcademico on h.IdPeriodo equals p.IdPeriodo
   where e.IdUsuario==usuario && h.Confirmado orderby h.FechaRegistro descending select new{h.IdHorarioGenerado,h.Nombre,h.IdPeriodo,Periodo=p.Clave,h.Seleccionado,h.FechaRegistro,t.IdReticula}).ToListAsync(ct);
  var ids=owned.Select(x=>x.IdHorarioGenerado).ToArray();
  var detalles=await db.HorarioGeneradoDetalle.AsNoTracking().Where(x=>ids.Contains(x.IdHorarioGenerado)).ToListAsync(ct);
  var grupos=await GruposAsync(usuario,true,false,ct);var result=new List<HorarioDto>();
  foreach(var h in owned){var elegidos=grupos.Where(g=>detalles.Any(d=>d.IdHorarioGenerado==h.IdHorarioGenerado && d.IdGrupo==g.Id)).ToArray();
   var materiaIds=elegidos.Select(g=>g.IdMateria).ToArray();var total=await db.ReticulaMateria.AsNoTracking().Where(x=>x.IdReticula==h.IdReticula && materiaIds.Contains(x.IdMateria)).SumAsync(x=>(int)x.Creditos,ct);
   result.Add(new(h.IdHorarioGenerado,h.Nombre,h.IdPeriodo,h.Periodo,total,h.Seleccionado,h.FechaRegistro,elegidos));}
  return result;
 }
 public async Task<int> GuardarAsync(int usuario,GuardarHorarioRequest request,CancellationToken ct)
 {
  if(string.IsNullOrWhiteSpace(request.Nombre) || request.Nombre.Length>100 || request.GrupoIds is null || request.GrupoIds.Length is <1 or >12)throw new AcademicException("GUARDAR","Indique nombre y entre uno y doce grupos.",400);
  if(request.GrupoIds.Distinct().Count()!=request.GrupoIds.Length)throw new AcademicException("RV-001","No repita grupos.",400);
  var perfil=await PerfilAsync(usuario,ct);var tabla=new DataTable();tabla.Columns.Add("nIdGrupo",typeof(int));foreach(var id in request.GrupoIds)tabla.Rows.Add(id);
  await db.Database.OpenConnectionAsync(ct);
  try{
   await using var command=(SqlCommand)db.Database.GetDbConnection().CreateCommand();command.CommandType=CommandType.StoredProcedure;command.CommandText="App.Sp_GuardarHorarioGenerado";command.CommandTimeout=45;
   command.Parameters.Add(new("@nIdTrayectoria",SqlDbType.Int){Value=await db.TrayectoriaEstudiante.Where(t=>t.IdEstudiante==perfil.IdEstudiante && t.FechaFin==null).Select(t=>t.IdTrayectoria).SingleAsync(ct)});
   command.Parameters.Add(new("@nIdPeriodo",SqlDbType.Int){Value=perfil.IdPeriodo});command.Parameters.Add(new("@cNombre",SqlDbType.NVarChar,100){Value=request.Nombre.Trim()});
   command.Parameters.Add(new("@Grupos",SqlDbType.Structured){TypeName="App.Tbl_ListaGrupo",Value=tabla});var output=new SqlParameter("@nIdHorarioGenerado",SqlDbType.Int){Direction=ParameterDirection.Output};command.Parameters.Add(output);
   command.Parameters.Add(new("@nSeleccionar",SqlDbType.Bit){Value=request.Seleccionar});command.Parameters.Add(new("@nIdUsuarioActor",SqlDbType.Int){Value=usuario});
   await command.ExecuteNonQueryAsync(ct);return (int)output.Value;
  }finally{await db.Database.CloseConnectionAsync();}
 }
 public async Task<object> CatalogoAsync(string catalogo,CancellationToken ct)=>catalogo switch
 {
  "carreras"=>await db.Carrera.AsNoTracking().OrderBy(x=>x.Nombre).Select(x=>new{x.IdCarrera,x.Clave,x.Nombre,x.Estatus}).ToListAsync(ct),
  "reticulas"=>await db.Reticula.AsNoTracking().Select(x=>new{x.IdReticula,x.IdCarrera,x.Clave,x.Nombre,x.Estatus}).ToListAsync(ct),
  "periodos"=>await db.PeriodoAcademico.AsNoTracking().OrderByDescending(x=>x.FechaInicio).ToListAsync(ct),
  "docentes"=>await db.Docente.AsNoTracking().OrderBy(x=>x.Nombre).Select(x=>new{x.IdDocente,x.NumeroEmpleado,x.Nombre,x.Estatus}).ToListAsync(ct),
  "aulas"=>await db.Aula.AsNoTracking().OrderBy(x=>x.Clave).Select(x=>new{x.IdAula,x.Clave,x.Capacidad,x.IdTipoAula,x.Estatus}).ToListAsync(ct),
  "estudiantes"=>await db.Estudiante.AsNoTracking().OrderBy(x=>x.NumeroControl).Select(x=>new{x.IdEstudiante,x.NumeroControl,x.Nombre,x.AnioIngreso,x.Generacion,x.Estatus}).ToListAsync(ct),
  "sesiones"=>await db.SesionGrupo.AsNoTracking().OrderBy(x=>x.IdGrupo).ThenBy(x=>x.IdDiaSemana).ToListAsync(ct),
  _=>throw new AcademicException("CATALOGO","Catálogo no disponible.",404)
 };
 public sealed class DisponibleRow{public int Id{get;set;}public string Clave{get;set;}="";public string Nombre{get;set;}="";public int Creditos{get;set;}public int Semestre{get;set;}public bool Obligatoria{get;set;}public int Grupos{get;set;}}
}
