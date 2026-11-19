using System.ComponentModel.DataAnnotations;
namespace SistemaHorarios.Application.Contracts;
public sealed record PerfilDto(int IdEstudiante,string NumeroControl,string Nombre,byte SemestreActual,short LimiteCreditos,int IdReticula,string Reticula,string Carrera,int IdPeriodo,string Periodo,int CreditosAprobados);
public sealed record MateriaDisponibleDto(int Id,string Clave,string Nombre,int Creditos,int Semestre,bool Obligatoria,int Grupos);
public sealed record SesionDto(int Id,int Dia,string DiaNombre,int IdAula,string Aula,TimeOnly Inicio,TimeOnly Fin);
public sealed record GrupoDto(int Id,int IdMateria,string MateriaClave,string Materia,string Clave,int? IdDocente,string Docente,int IdPeriodo,string Periodo,bool Activo,IReadOnlyList<SesionDto> Sesiones);
public sealed record SeleccionRequest([Required,MinLength(1),MaxLength(12)] int[] MateriaIds);
public sealed record CreditosDto(int Total,int Limite,bool DentroDelLimite,int Materias);
public sealed record HorarioDto(int Id,string Nombre,int IdPeriodo,string Periodo,int Creditos,bool Seleccionado,DateTime Fecha,IReadOnlyList<GrupoDto> Grupos);
public sealed record GuardarHorarioRequest([Required,StringLength(100,MinimumLength=1)] string Nombre,[Required,MinLength(1),MaxLength(12)] int[] GrupoIds,bool Seleccionar);

