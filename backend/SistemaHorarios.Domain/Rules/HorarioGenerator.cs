namespace SistemaHorarios.Domain.Rules;

public sealed record GrupoCandidato(int Id,int MateriaId,int Creditos,int DocenteId,int PeriodoId,bool Activo,bool PerteneceReticula,bool CumplePrerequisitos,IReadOnlyList<SesionSemanal> Sesiones);
public sealed record ResultadoGenerador(IReadOnlyList<IReadOnlyList<GrupoCandidato>> Opciones,int EstadosExplorados,bool LimiteAlcanzado);

/// <summary>Backtracking determinista con poda de créditos, recursos y empalmes. Estado local por invocación.</summary>
public sealed class HorarioGenerator
{
 public ResultadoGenerador Generar(IReadOnlyList<int> materias,IReadOnlyList<GrupoCandidato> grupos,int limiteCreditos,int periodoActivo,int maxOpciones=20,int maxEstados=50000,CancellationToken ct=default)
 {
  if(materias.Count is <1 or >12 || materias.Any(x=>x<=0))throw new ArgumentException("Seleccione entre una y doce materias válidas.");
  if(materias.Distinct().Count()!=materias.Count)throw new ArgumentException("RV-001: no repita materias.");
  if(limiteCreditos<=0 || periodoActivo<=0 || maxOpciones<=0 || maxEstados<=0)throw new ArgumentOutOfRangeException(nameof(limiteCreditos));
  if(grupos.GroupBy(g=>g.Id).Any(g=>g.Count()>1))throw new ArgumentException("Hay identificadores de grupo duplicados.");
  var opciones=new List<IReadOnlyList<GrupoCandidato>>();var elegidos=new List<GrupoCandidato>();var estados=0;var limitado=false;
  bool Valido(GrupoCandidato g)=>g.Activo && g.PeriodoId==periodoActivo && g.DocenteId>0 && g.Creditos>0 && g.PerteneceReticula && g.CumplePrerequisitos
   && g.Sesiones.Count>0 && g.Sesiones.All(EmpalmeValidator.EsValida)
   && !g.Sesiones.SelectMany((a,i)=>g.Sesiones.Skip(i+1).Select(b=>(a,b))).Any(p=>EmpalmeValidator.Existe(p.a,p.b))
   && !grupos.Any(o=>o.Id!=g.Id && o.Activo && o.PeriodoId==g.PeriodoId && g.Sesiones.Any(a=>o.Sesiones.Any(b=>(o.DocenteId==g.DocenteId || a.AulaId==b.AulaId) && EmpalmeValidator.Existe(a,b))));
  var candidatos=materias.Select(id=>grupos.Where(g=>g.MateriaId==id && Valido(g)).OrderBy(g=>g.Id).ToArray()).OrderBy(g=>g.Length).ThenBy(g=>g.FirstOrDefault()?.MateriaId??0).ToArray();
  if(candidatos.Any(c=>c.Length==0))return new([],0,false);
  void Buscar(int depth,int creditos)
  {
   ct.ThrowIfCancellationRequested();
   if(opciones.Count>=maxOpciones || estados>=maxEstados){limitado=true;return;}
   estados++;
   if(depth==candidatos.Length){opciones.Add(elegidos.ToArray());return;}
   foreach(var grupo in candidatos[depth])
   {
    if(opciones.Count>=maxOpciones || estados>=maxEstados){limitado=true;break;}
    if(creditos+grupo.Creditos>limiteCreditos)continue;
    if(elegidos.Any(g=>g.Sesiones.Any(a=>grupo.Sesiones.Any(b=>EmpalmeValidator.Existe(a,b)))))continue;
    elegidos.Add(grupo);Buscar(depth+1,creditos+grupo.Creditos);elegidos.RemoveAt(elegidos.Count-1);
   }
  }
  Buscar(0,0);return new(opciones,estados,limitado);
 }
}
