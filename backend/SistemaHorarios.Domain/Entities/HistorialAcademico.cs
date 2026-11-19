namespace SistemaHorarios.Domain.Entities;

public sealed class HistorialAcademico
{
    public long IdHistorialAcademico { get; set; }
    public int IdEstudiante { get; set; }
    public int IdMateria { get; set; }
    public int? IdPeriodo { get; set; }
    public byte IdEstatusAcademico { get; set; }
    public decimal? Calificacion { get; set; }
    public DateTime FechaRegistro { get; set; }
}
