namespace SistemaHorarios.Domain.Entities;

public sealed class HorarioGenerado
{
    public int IdHorarioGenerado { get; set; }
    public int IdTrayectoria { get; set; }
    public int IdPeriodo { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public bool Confirmado { get; set; }
    public bool Seleccionado { get; set; }
    public DateTime FechaRegistro { get; set; }
}
