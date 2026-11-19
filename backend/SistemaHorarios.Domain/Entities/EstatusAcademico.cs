namespace SistemaHorarios.Domain.Entities;

public sealed class EstatusAcademico
{
    public byte IdEstatusAcademico { get; set; }
    public string Clave { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
}
