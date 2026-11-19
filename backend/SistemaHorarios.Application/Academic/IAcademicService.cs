using SistemaHorarios.Application.Contracts;
namespace SistemaHorarios.Application.Academic;
public interface IAcademicService
{
 Task<IReadOnlyList<MateriaDto>> MateriasAsync(CancellationToken ct);
 Task<PerfilDto> PerfilAsync(int usuario,CancellationToken ct);
 Task<IReadOnlyList<MateriaDisponibleDto>> DisponiblesAsync(int usuario,CancellationToken ct);
 Task<CreditosDto> CreditosAsync(int usuario,int[] materias,CancellationToken ct);
 Task<IReadOnlyList<GrupoDto>> GruposAsync(int usuario,bool coordinador,bool docente,CancellationToken ct);
 Task<IReadOnlyList<HorarioDto>> HorariosAsync(int usuario,CancellationToken ct);
 Task<int> GuardarAsync(int usuario,GuardarHorarioRequest request,CancellationToken ct);
 Task<object> CatalogoAsync(string catalogo,CancellationToken ct);
}
public sealed class AcademicException(string regla,string mensaje,int status=422):Exception(mensaje)
{public string Regla {get;}=regla;public int Status {get;}=status;}
