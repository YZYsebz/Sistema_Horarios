using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SistemaHorarios.Infrastructure.Identity;
using SistemaHorarios.Infrastructure.Persistence;
namespace SistemaHorarios.Api.Controllers;
[ApiController][Route("api/auth")]
public sealed class AuthController(UserManager<Usuario> users,SignInManager<Usuario> signIn,IConfiguration configuration,HorariosDbContext db):ControllerBase
{
 [AllowAnonymous][HttpPost("login")][EnableRateLimiting("login")]
 public async Task<IActionResult> Login(LoginRequest request,CancellationToken ct)
 {
  var user=await users.FindByNameAsync(request.Usuario.Trim());
  if(user is null || !user.Estatus)return Unauthorized(new ProblemDetails{Status=401,Title="Usuario o contraseña incorrectos."});
  var check=await signIn.CheckPasswordSignInAsync(user,request.Password,lockoutOnFailure:true);
  if(!check.Succeeded)return Unauthorized(new ProblemDetails{Status=401,Title="Usuario o contraseña incorrectos, o acceso temporalmente bloqueado."});
  var roles=await users.GetRolesAsync(user);var expires=DateTime.UtcNow.AddMinutes(configuration.GetValue<int>("Jwt:Minutes",30));
  var claims=new List<Claim>{new("sub",user.Id.ToString()),new("name",user.UserName!),new("jti",Guid.NewGuid().ToString())};claims.AddRange(roles.Select(r=>new Claim("role",r)));
  var token=new JwtSecurityToken(configuration["Jwt:Issuer"],configuration["Jwt:Audience"],claims,DateTime.UtcNow,expires,new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]!)),SecurityAlgorithms.HmacSha256));
  var nombre=await db.Estudiante.AsNoTracking().Where(e=>e.IdUsuario==user.Id).Select(e=>e.Nombre).SingleOrDefaultAsync(ct)
    ??await db.Docente.AsNoTracking().Where(d=>d.IdUsuario==user.Id).Select(d=>d.Nombre).SingleOrDefaultAsync(ct)??user.UserName!;
  return Ok(new{accessToken=new JwtSecurityTokenHandler().WriteToken(token),expiresAt=expires,usuario=new{id=user.Id,nombreUsuario=user.UserName,nombre,roles}});
 }
 public sealed record LoginRequest([Required,StringLength(256)] string Usuario,[Required,StringLength(256)] string Password);
}

