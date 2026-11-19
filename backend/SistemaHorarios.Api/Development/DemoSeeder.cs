using Microsoft.AspNetCore.Identity;
using SistemaHorarios.Infrastructure.Identity;
namespace SistemaHorarios.Api.Development;
public static class DemoSeeder
{
 public static async Task RunAsync(IServiceProvider provider,IConfiguration configuration)
 {
  using var scope=provider.CreateScope();var manager=scope.ServiceProvider.GetRequiredService<UserManager<Usuario>>();
  foreach(var entry in configuration.GetSection("DemoUsers").GetChildren())
  {
   var user=await manager.FindByNameAsync(entry["UserName"]!)??throw new InvalidOperationException("Usuario sintético no encontrado.");
   var password=entry["Password"]??throw new InvalidOperationException("Falta el secreto local de demostración.");
   if(password.Length<24)throw new InvalidOperationException("El secreto de desarrollo debe tener al menos 24 caracteres.");
   user.PasswordHash=manager.PasswordHasher.HashPassword(user,password);user.SecurityStamp=Guid.NewGuid().ToString();user.LockoutEnabled=true;user.AccessFailedCount=0;user.LockoutEnd=null;
   var result=await manager.UpdateAsync(user);if(!result.Succeeded)throw new InvalidOperationException(string.Join("; ",result.Errors.Select(e=>e.Description)));
   Console.WriteLine("Acceso de prueba habilitado: "+user.UserName);
  }
 }
}
