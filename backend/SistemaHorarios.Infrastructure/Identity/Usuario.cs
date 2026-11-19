using Microsoft.AspNetCore.Identity;
namespace SistemaHorarios.Infrastructure.Identity;
public sealed class Usuario : IdentityUser<int>
{
 public bool Estatus {get;set;}=true;
 public DateTime FechaRegistro {get;set;}=DateTime.UtcNow;
}
public sealed class Rol : IdentityRole<int> { }
