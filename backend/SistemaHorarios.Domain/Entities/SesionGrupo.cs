namespace SistemaHorarios.Domain.Entities;

public sealed class SesionGrupo
{
    public int IdSesionGrupo { get; set; }
    public int IdGrupo { get; set; }
    public byte IdDiaSemana { get; set; }
    public int IdAula { get; set; }
    public TimeOnly HoraInicio { get; set; }
    public TimeOnly HoraFin { get; set; }
}
