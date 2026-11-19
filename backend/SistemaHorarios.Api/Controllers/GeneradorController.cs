using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SistemaHorarios.Infrastructure.Persistence;
using SistemaHorarios.Application.Academic;
using SistemaHorarios.Application.Contracts;
namespace SistemaHorarios.Api.Controllers;
[ApiController][Route("api/horarios")][Authorize(Roles="ESTUDIANTE")]
public sealed class GeneradorController(IGeneratorService generator,HorariosDbContext db):ControllerBase
{
 [HttpPost("generar")]
 public async Task<IActionResult> Generar(SeleccionRequest request,CancellationToken ct)=>Ok(await generator.GenerarAsync(int.Parse(User.FindFirstValue("sub")!),request.MateriaIds,ct));
 [HttpPut("{id:int}/seleccion")]
 public async Task<IActionResult> Seleccionar(int id,CancellationToken ct)
 {var actor=int.Parse(User.FindFirstValue("sub")!);await db.Database.ExecuteSqlInterpolatedAsync($"EXEC App.Sp_SeleccionarHorarioGenerado @nIdUsuarioActor={actor},@nIdHorarioGenerado={id}",ct);return NoContent();}
}
