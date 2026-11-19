using SistemaHorarios.Application.Contracts;
namespace SistemaHorarios.Application.Academic;
public sealed record OpcionHorarioDto(int Id,int Creditos,IReadOnlyList<GrupoDto> Grupos);
public sealed record GeneracionDto(IReadOnlyList<OpcionHorarioDto> Opciones,bool LimiteAlcanzado,int EstadosExplorados);
public interface IGeneratorService {Task<GeneracionDto> GenerarAsync(int usuario,int[] materias,CancellationToken ct);}
