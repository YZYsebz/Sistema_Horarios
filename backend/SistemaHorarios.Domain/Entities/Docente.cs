namespace SistemaHorarios.Domain.Entities;

public sealed class Docente
{
    public int IdDocente { get; set; }
    public int? IdUsuario { get; set; }
    public string NumeroEmpleado { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public bool Estatus { get; set; }
}
