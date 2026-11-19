using SistemaHorarios.Application.Academic;
using SistemaHorarios.Domain.Rules;
namespace SistemaHorarios.Infrastructure.Academic;
public sealed class GeneratorService(IAcademicService academic,HorarioGenerator generator):IGeneratorService
{
 public async Task<GeneracionDto> GenerarAsync(int usuario,int[] materias,CancellationToken ct)
 {
  var creditos=await academic.CreditosAsync(usuario,materias,ct);
  if(!creditos.DentroDelLimite)throw new AcademicException("RV-003","La selección excede el límite de créditos.");
  var perfil=await academic.PerfilAsync(usuario,ct);var disponibles=(await academic.DisponiblesAsync(usuario,ct)).ToDictionary(x=>x.Id);
  var grupos=await academic.GruposAsync(usuario,false,false,ct);
  var candidatos=grupos.Select(g=>new GrupoCandidato(g.Id,g.IdMateria,disponibles.TryGetValue(g.IdMateria,out var m)?m.Creditos:0,g.IdDocente??0,g.IdPeriodo,g.Activo,disponibles.ContainsKey(g.IdMateria),disponibles.ContainsKey(g.IdMateria),g.Sesiones.Select(s=>new SesionSemanal(s.Dia,s.Inicio,s.Fin,s.IdAula)).ToArray())).ToArray();
  var resultado=generator.Generar(materias,candidatos,perfil.LimiteCreditos,perfil.IdPeriodo,ct:ct);
  var map=grupos.ToDictionary(g=>g.Id);
  return new(resultado.Opciones.Select((o,i)=>new OpcionHorarioDto(i+1,o.Sum(g=>g.Creditos),o.Select(g=>map[g.Id]).ToArray())).ToArray(),resultado.LimiteAlcanzado,resultado.EstadosExplorados);
 }
}
