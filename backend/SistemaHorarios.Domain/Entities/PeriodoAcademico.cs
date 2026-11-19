namespace SistemaHorarios.Domain.Entities;

public sealed class PeriodoAcademico
{
    public int IdPeriodo { get; set; }
    public string Clave { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public DateOnly FechaInicio { get; set; }
    public DateOnly FechaFin { get; set; }
    public bool ActivoGeneracion { get; set; }
    public bool OfertaPublicada { get; set; }
}
