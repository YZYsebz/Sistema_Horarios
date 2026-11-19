using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaHorarios.Application.Academic;
using SistemaHorarios.Application.Contracts;
using SistemaHorarios.Infrastructure.Persistence;
namespace SistemaHorarios.Api.Controllers;
[ApiController][Route("api/estudiantes")][Authorize(Roles="ESTUDIANTE")]
public sealed class EstudiantesController(IAcademicService service):ControllerBase
{
 private int Usuario=>int.Parse(User.FindFirstValue("sub")!);
 [HttpGet("me")] public async Task<IActionResult> Perfil(CancellationToken ct)=>Ok(await service.PerfilAsync(Usuario,ct));
 [HttpGet("me/materias-disponibles")]public async Task<IActionResult> Disponibles(CancellationToken ct)=>Ok(await service.DisponiblesAsync(Usuario,ct));
 [HttpPost("me/seleccion/creditos")]public async Task<IActionResult> Creditos(SeleccionRequest request,CancellationToken ct)=>Ok(await service.CreditosAsync(Usuario,request.MateriaIds,ct));
}
[ApiController][Route("api/grupos")][Authorize]
public sealed class GruposController(IAcademicService service):ControllerBase
{[HttpGet]public async Task<IActionResult> Get(CancellationToken ct)=>Ok(await service.GruposAsync(int.Parse(User.FindFirstValue("sub")!),User.IsInRole("COORDINADOR"),User.IsInRole("DOCENTE"),ct));}
[ApiController][Route("api/horarios")][Authorize(Roles="ESTUDIANTE")]
public sealed class HorariosController(IAcademicService service):ControllerBase
{
 private int Usuario=>int.Parse(User.FindFirstValue("sub")!);
 [HttpGet]public async Task<IActionResult> Get(CancellationToken ct)=>Ok(await service.HorariosAsync(Usuario,ct));
 [HttpPost]public async Task<IActionResult> Guardar(GuardarHorarioRequest request,CancellationToken ct){var id=await service.GuardarAsync(Usuario,request,ct);return Created($"/api/horarios/{id}",new{id});}
}
[ApiController][Route("api")][Authorize(Roles="COORDINADOR")]
public sealed class CatalogosController(IAcademicService service):ControllerBase
{
 [HttpGet("carreras")][HttpGet("reticulas")][HttpGet("periodos")][HttpGet("docentes")][HttpGet("aulas")][HttpGet("estudiantes")][HttpGet("sesiones")]
 public async Task<IActionResult> Get(CancellationToken ct)=>Ok(await service.CatalogoAsync(Request.Path.Value!.Split('/').Last(),ct));
}
[ApiController][Route("api/historial")][Authorize(Roles="ESTUDIANTE")]
public sealed class HistorialController(HorariosDbContext db):ControllerBase
{
 [HttpGet] public async Task<IActionResult> Get(CancellationToken ct){var u=int.Parse(User.FindFirstValue("sub")!);
 return Ok(await (from h in db.HistorialAcademico.AsNoTracking() join e in db.Estudiante on h.IdEstudiante equals e.IdEstudiante
 join m in db.Materia on h.IdMateria equals m.IdMateria join s in db.EstatusAcademico on h.IdEstatusAcademico equals s.IdEstatusAcademico
 where e.IdUsuario==u orderby m.Clave select new{h.IdHistorialAcademico,m.Clave,m.Nombre,Estatus=s.Clave,h.Calificacion,h.IdPeriodo}).ToListAsync(ct));}
}
