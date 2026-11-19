namespace SistemaHorarios.Domain.Entities;

public sealed class TrayectoriaEstudiante
{
    public int IdTrayectoria { get; set; }
    public int IdEstudiante { get; set; }
    public int IdReticula { get; set; }
    public byte SemestreActual { get; set; }
    public short LimiteCreditos { get; set; }
    public DateOnly FechaInicio { get; set; }
    public DateOnly? FechaFin { get; set; }
}
