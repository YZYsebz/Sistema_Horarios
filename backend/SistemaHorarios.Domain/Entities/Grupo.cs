namespace SistemaHorarios.Domain.Entities;

public sealed class Grupo
{
    public int IdGrupo { get; set; }
    public int IdMateria { get; set; }
    public int? IdDocente { get; set; }
    public int IdPeriodo { get; set; }
    public string ClaveGrupo { get; set; } = string.Empty;
    public bool Estatus { get; set; }
    public List<SesionGrupo> Sesiones { get; set; } = [];
}
