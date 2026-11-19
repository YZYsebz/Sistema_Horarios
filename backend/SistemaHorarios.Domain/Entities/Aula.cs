namespace SistemaHorarios.Domain.Entities;

public sealed class Aula
{
    public int IdAula { get; set; }
    public int IdTipoAula { get; set; }
    public string Clave { get; set; } = string.Empty;
    public short Capacidad { get; set; }
    public bool Estatus { get; set; }
}
