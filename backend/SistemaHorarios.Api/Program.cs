using System.Text;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using SistemaHorarios.Infrastructure.Persistence;
using SistemaHorarios.Infrastructure.Identity;
using SistemaHorarios.Infrastructure.Academic;
using SistemaHorarios.Application.Academic;
using SistemaHorarios.Api.Development;
using SistemaHorarios.Api.Errors;

var seed=args.Contains("--seed-demo");
var builder=WebApplication.CreateBuilder(args.Where(x=>x!="--seed-demo").ToArray());
var root=Environment.GetEnvironmentVariable("SISTEMA_HORARIOS_ROOT")??FindRoot(builder.Environment.ContentRootPath);
var taskSettings=Path.Combine(root,"backend","SistemaHorarios.Api","appsettings.json"); if(File.Exists(taskSettings))builder.Configuration.AddJsonFile(taskSettings,false,false).AddJsonFile(Path.Combine(root,"backend","SistemaHorarios.Api","appsettings."+builder.Environment.EnvironmentName+".json"),true,false);
if(builder.Environment.IsDevelopment())builder.Configuration.AddJsonFile(Path.Combine(root,".secrets","development.json"),true,false);
builder.Configuration.AddEnvironmentVariables();
var connection=builder.Configuration.GetConnectionString("SqlServer")??throw new InvalidOperationException("Configure ConnectionStrings__SqlServer.");
var jwtKey=builder.Configuration["Jwt:Key"]??throw new InvalidOperationException("Configure Jwt__Key mediante secretos locales o variables de entorno.");
if(Encoding.UTF8.GetByteCount(jwtKey)<32)throw new InvalidOperationException("Jwt__Key debe tener al menos 32 bytes.");
var protection=builder.Services.AddDataProtection().SetApplicationName("SistemaHorarios")
 .PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(root,".secrets","dataprotection")));
if(OperatingSystem.IsWindows())protection.ProtectKeysWithDpapi();
builder.Services.AddDbContext<HorariosDbContext>(o=>o.UseSqlServer(connection));
builder.Services.AddScoped<IAcademicService,AcademicService>();
builder.Services.AddSingleton<SistemaHorarios.Domain.Rules.HorarioGenerator>();
builder.Services.AddScoped<IGeneratorService,GeneratorService>();
builder.Services.AddIdentityCore<Usuario>(o=>{o.Password.RequiredLength=12;o.User.RequireUniqueEmail=false;o.Lockout.MaxFailedAccessAttempts=5;o.Lockout.DefaultLockoutTimeSpan=TimeSpan.FromMinutes(5);})
 .AddRoles<Rol>().AddEntityFrameworkStores<HorariosDbContext>().AddSignInManager();
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(o=>{
 o.MapInboundClaims=false;o.TokenValidationParameters=new(){ValidateIssuer=true,ValidateAudience=true,ValidateLifetime=true,ValidateIssuerSigningKey=true,
 ValidIssuer=builder.Configuration["Jwt:Issuer"],ValidAudience=builder.Configuration["Jwt:Audience"],IssuerSigningKey=new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),ClockSkew=TimeSpan.FromSeconds(30),NameClaimType="name",RoleClaimType="role"};
});
builder.Services.AddAuthorization(o=>o.FallbackPolicy=new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build());
builder.Services.AddCors(o=>o.AddDefaultPolicy(p=>p.WithOrigins("http://localhost:5173","http://127.0.0.1:5173").AllowAnyHeader().AllowAnyMethod()));
builder.Services.AddRateLimiter(o=>{o.RejectionStatusCode=429;o.AddPolicy("login",context=>RateLimitPartition.GetFixedWindowLimiter(context.Connection.RemoteIpAddress?.ToString()??"local",_=>new(){PermitLimit=12,Window=TimeSpan.FromMinutes(1),QueueLimit=0}));});
builder.Services.AddControllers();builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(o=>{
 o.AddSecurityDefinition("Bearer",new OpenApiSecurityScheme{Type=SecuritySchemeType.Http,Scheme="bearer",BearerFormat="JWT",Description="Token devuelto por /api/auth/login"});
 o.AddSecurityRequirement(doc=>new OpenApiSecurityRequirement{[new OpenApiSecuritySchemeReference("Bearer",doc)]=[]});
});
builder.Services.AddExceptionHandler<AcademicExceptionHandler>();builder.Services.AddProblemDetails();
var app=builder.Build();
if(seed){if(!app.Environment.IsDevelopment())throw new InvalidOperationException("La semilla de acceso solo se ejecuta en Development.");await DemoSeeder.RunAsync(app.Services,app.Configuration);return;}
app.UseExceptionHandler();
if(app.Environment.IsDevelopment()){app.UseSwagger();app.UseSwaggerUI();}else{app.UseHsts();app.UseHttpsRedirection();}
app.UseCors();app.UseRateLimiter();app.UseAuthentication();app.UseAuthorization();app.MapControllers();app.Run();
static string FindRoot(string path){var dir=new DirectoryInfo(path);while(dir!=null){if(File.Exists(Path.Combine(dir.FullName,"global.json")))return dir.FullName;dir=dir.Parent;}return path;}
public partial class Program { }


