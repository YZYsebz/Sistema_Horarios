namespace SistemaHorarios.Domain.Entities;

public sealed class Estudiante
{
    public int IdEstudiante { get; set; }
    public int IdUsuario { get; set; }
    public string NumeroControl { get; set; } = string.Empty;
    public bool Estatus { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public short AnioIngreso { get; set; }
    public byte Generacion { get; set; }
}
