namespace SistemaHorarios.Domain.Entities;

public sealed class MateriaPrerrequisito
{
    public int IdReticula { get; set; }
    public int IdMateria { get; set; }
    public int IdMateriaPrerrequisito { get; set; }
    public bool Obligatorio { get; set; }
}
