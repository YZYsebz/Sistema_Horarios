namespace SistemaHorarios.Domain.Entities;

public sealed class ReticulaMateria
{
    public int IdReticula { get; set; }
    public int IdMateria { get; set; }
    public byte SemestreRecomendado { get; set; }
    public byte Creditos { get; set; }
    public bool Obligatoria { get; set; }
}
