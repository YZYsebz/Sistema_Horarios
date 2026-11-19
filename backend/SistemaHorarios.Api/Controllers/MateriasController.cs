using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaHorarios.Application.Academic;
namespace SistemaHorarios.Api.Controllers;
[ApiController][Route("api/materias")][Authorize]
public sealed class MateriasController(IAcademicService service):ControllerBase
{[HttpGet]public async Task<IActionResult> Get(CancellationToken ct)=>Ok(await service.MateriasAsync(ct));}
