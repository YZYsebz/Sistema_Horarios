namespace SistemaHorarios.Domain.Entities;

public sealed class Carrera
{
    public int IdCarrera { get; set; }
    public string Clave { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public bool Estatus { get; set; }
}
