using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using SistemaHorarios.Application.Academic;
namespace SistemaHorarios.Api.Errors;
public sealed class AcademicExceptionHandler(ILogger<AcademicExceptionHandler> logger): IExceptionHandler
{
 public async ValueTask<bool> TryHandleAsync(HttpContext context,Exception error,CancellationToken ct)
 {
  var status=error is AcademicException a?a.Status:error is SqlException sql && sql.Number>=50000?409:500;
  if(status==500)logger.LogError(error,"Error inesperado de la API en {Path}",context.Request.Path);
  var problem=new ProblemDetails{Status=status,Title=status==500?"No fue posible completar la operación.":"Validación académica",Detail=status==500?null:error.Message};
  if(error is AcademicException academic)problem.Extensions["regla"]=academic.Regla;
  if(error is SqlException s && s.Number>=50000)problem.Extensions["codigo"]=s.Number;
  context.Response.StatusCode=status;await context.Response.WriteAsJsonAsync(problem,ct);return true;
 }
}

