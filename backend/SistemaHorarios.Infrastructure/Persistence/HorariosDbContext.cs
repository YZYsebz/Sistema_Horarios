using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using SistemaHorarios.Domain.Entities;
using SistemaHorarios.Infrastructure.Identity;
namespace SistemaHorarios.Infrastructure.Persistence;

public sealed class HorariosDbContext(DbContextOptions<HorariosDbContext> options) : IdentityDbContext<Usuario,Rol,int>(options)
{
 public DbSet<Carrera> Carrera => Set<Carrera>();
 public DbSet<Materia> Materia => Set<Materia>();
 public DbSet<TipoAula> TipoAula => Set<TipoAula>();
 public DbSet<Reticula> Reticula => Set<Reticula>();
 public DbSet<DiaSemana> DiaSemana => Set<DiaSemana>();
 public DbSet<EstatusAcademico> EstatusAcademico => Set<EstatusAcademico>();
 public DbSet<Estudiante> Estudiante => Set<Estudiante>();
 public DbSet<TrayectoriaEstudiante> TrayectoriaEstudiante => Set<TrayectoriaEstudiante>();
 public DbSet<Docente> Docente => Set<Docente>();
 public DbSet<Aula> Aula => Set<Aula>();
 public DbSet<ReticulaMateria> ReticulaMateria => Set<ReticulaMateria>();
 public DbSet<MateriaPrerrequisito> MateriaPrerrequisito => Set<MateriaPrerrequisito>();
 public DbSet<PeriodoAcademico> PeriodoAcademico => Set<PeriodoAcademico>();
 public DbSet<Grupo> Grupo => Set<Grupo>();
 public DbSet<SesionGrupo> SesionGrupo => Set<SesionGrupo>();
 public DbSet<HistorialAcademico> HistorialAcademico => Set<HistorialAcademico>();
 public DbSet<HorarioGenerado> HorarioGenerado => Set<HorarioGenerado>();
 public DbSet<HorarioGeneradoDetalle> HorarioGeneradoDetalle => Set<HorarioGeneradoDetalle>();
 protected override void OnModelCreating(ModelBuilder b)
 {
  base.OnModelCreating(b);
  b.HasDefaultSchema("App");
  b.Entity<Usuario>(e=> {
   e.ToTable("Tbl_Usuario","App",t=>t.UseSqlOutputClause(false));
   e.Property(x=>x.Id).HasColumnName("nIdUsuario");
   e.Property(x=>x.UserName).HasColumnName("cNombreUsuario").IsRequired();
   e.Property(x=>x.NormalizedUserName).HasColumnName("cNombreUsuarioNormalizado").IsRequired();
   e.Property(x=>x.Email).HasColumnName("cCorreo");
   e.Property(x=>x.NormalizedEmail).HasColumnName("cCorreoNormalizado");
   e.Property(x=>x.EmailConfirmed).HasColumnName("nCorreoConfirmado");
   e.Property(x=>x.PasswordHash).HasColumnName("cPasswordHash");
   e.Property(x=>x.SecurityStamp).HasColumnName("cSecurityStamp").HasMaxLength(64);
   e.Property(x=>x.ConcurrencyStamp).HasColumnName("cConcurrencyStamp").HasMaxLength(64);
   e.Property(x=>x.PhoneNumber).HasColumnName("cTelefono").HasMaxLength(50);
   e.Property(x=>x.PhoneNumberConfirmed).HasColumnName("nTelefonoConfirmado");
   e.Property(x=>x.TwoFactorEnabled).HasColumnName("nDosFactoresHabilitados");
   e.Property(x=>x.LockoutEnd).HasColumnName("dFinBloqueo").HasColumnType("datetimeoffset(0)");
   e.Property(x=>x.LockoutEnabled).HasColumnName("nBloqueoHabilitado");
   e.Property(x=>x.AccessFailedCount).HasColumnName("nIntentosFallidos");
   e.Property(x=>x.Estatus).HasColumnName("nEstatus");
   e.Property(x=>x.FechaRegistro).HasColumnName("dFechaRegistro").HasColumnType("datetime2(0)");
  });
  b.Entity<Rol>(e=>{
   e.ToTable("Cat_Rol","App",t=>t.UseSqlOutputClause(false));
   e.Property(x=>x.Id).HasColumnName("nIdRol");e.Property(x=>x.Name).HasColumnName("cNombre").IsRequired();
   e.Property(x=>x.NormalizedName).HasColumnName("cNombreNormalizado").IsRequired();
   e.Property(x=>x.ConcurrencyStamp).HasColumnName("cConcurrencyStamp").HasMaxLength(64);
  });
  b.Entity<IdentityUserRole<int>>(e=>{e.ToTable("Tbl_UsuarioRol","App");e.Property(x=>x.UserId).HasColumnName("nIdUsuario");e.Property(x=>x.RoleId).HasColumnName("nIdRol");});
  b.Entity<IdentityUserClaim<int>>(e=>{e.ToTable("Tbl_UsuarioClaim","App");e.Property(x=>x.Id).HasColumnName("nIdUsuarioClaim");e.Property(x=>x.UserId).HasColumnName("nIdUsuario");e.Property(x=>x.ClaimType).HasColumnName("cTipoClaim");e.Property(x=>x.ClaimValue).HasColumnName("cValorClaim");});
  b.Entity<IdentityRoleClaim<int>>(e=>{e.ToTable("Tbl_RolClaim","App");e.Property(x=>x.Id).HasColumnName("nIdRolClaim");e.Property(x=>x.RoleId).HasColumnName("nIdRol");e.Property(x=>x.ClaimType).HasColumnName("cTipoClaim");e.Property(x=>x.ClaimValue).HasColumnName("cValorClaim");});
  b.Entity<IdentityUserLogin<int>>(e=>{e.ToTable("Tbl_UsuarioLogin","App");e.Property(x=>x.UserId).HasColumnName("nIdUsuario");e.Property(x=>x.LoginProvider).HasColumnName("cProveedorLogin").HasMaxLength(128);e.Property(x=>x.ProviderKey).HasColumnName("cClaveProveedor").HasMaxLength(128);e.Property(x=>x.ProviderDisplayName).HasColumnName("cNombreProveedor").HasMaxLength(128);});
  b.Entity<IdentityUserToken<int>>(e=>{e.ToTable("Tbl_UsuarioToken","App");e.Property(x=>x.UserId).HasColumnName("nIdUsuario");e.Property(x=>x.LoginProvider).HasColumnName("cProveedorLogin").HasMaxLength(128);e.Property(x=>x.Name).HasColumnName("cNombre").HasMaxLength(128);e.Property(x=>x.Value).HasColumnName("cValor");});
  b.Entity<Carrera>(e=>{
   e.ToTable("Cat_Carrera","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdCarrera});
   e.Property(x=>x.IdCarrera).HasColumnName("nIdCarrera").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.Clave).HasColumnName("cClave").HasColumnType("varchar(30)");
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(150)");
   e.Property(x=>x.Estatus).HasColumnName("nEstatus").HasColumnType("bit");
  });
  b.Entity<Materia>(e=>{
   e.ToTable("Cat_Materia","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdMateria});
   e.Property(x=>x.IdMateria).HasColumnName("nIdMateria").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.Clave).HasColumnName("cClave").HasColumnType("varchar(30)");
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(150)");
   e.Property(x=>x.Estatus).HasColumnName("nEstatus").HasColumnType("bit");
  });
  b.Entity<TipoAula>(e=>{
   e.ToTable("Cat_TipoAula","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdTipoAula});
   e.Property(x=>x.IdTipoAula).HasColumnName("nIdTipoAula").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.Clave).HasColumnName("cClave").HasColumnType("varchar(30)");
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(150)");
   e.Property(x=>x.Estatus).HasColumnName("nEstatus").HasColumnType("bit");
  });
  b.Entity<Reticula>(e=>{
   e.ToTable("Cat_Reticula","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdReticula});
   e.Property(x=>x.IdReticula).HasColumnName("nIdReticula").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.IdCarrera).HasColumnName("nIdCarrera").HasColumnType("int");
   e.Property(x=>x.Clave).HasColumnName("cClave").HasColumnType("varchar(30)");
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(150)");
   e.Property(x=>x.Estatus).HasColumnName("nEstatus").HasColumnType("bit");
   e.HasOne<Carrera>().WithMany().HasForeignKey(x=>x.IdCarrera).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<DiaSemana>(e=>{
   e.ToTable("Cat_DiaSemana","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdDiaSemana});
   e.Property(x=>x.IdDiaSemana).HasColumnName("nIdDiaSemana").HasColumnType("tinyint").ValueGeneratedNever();
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(15)");
  });
  b.Entity<EstatusAcademico>(e=>{
   e.ToTable("Cat_EstatusAcademico","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdEstatusAcademico});
   e.Property(x=>x.IdEstatusAcademico).HasColumnName("nIdEstatusAcademico").HasColumnType("tinyint").ValueGeneratedNever();
   e.Property(x=>x.Clave).HasColumnName("cClave").HasColumnType("varchar(15)");
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(50)");
  });
  b.Entity<Estudiante>(e=>{
   e.ToTable("Tbl_Estudiante","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdEstudiante});
   e.Property(x=>x.IdEstudiante).HasColumnName("nIdEstudiante").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.IdUsuario).HasColumnName("nIdUsuario").HasColumnType("int");
   e.Property(x=>x.NumeroControl).HasColumnName("cNumeroControl").HasColumnType("char(8)");
   e.Property(x=>x.Estatus).HasColumnName("nEstatus").HasColumnType("bit");
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(150)");
   e.Property(x=>x.AnioIngreso).HasColumnName("nAnioIngreso").HasColumnType("smallint");
   e.Property(x=>x.Generacion).HasColumnName("nGeneracion").HasColumnType("tinyint");
   e.HasOne<Usuario>().WithMany().HasForeignKey(x=>x.IdUsuario).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<TrayectoriaEstudiante>(e=>{
   e.ToTable("Tbl_TrayectoriaEstudiante","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdTrayectoria});
   e.Property(x=>x.IdTrayectoria).HasColumnName("nIdTrayectoria").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.IdEstudiante).HasColumnName("nIdEstudiante").HasColumnType("int");
   e.Property(x=>x.IdReticula).HasColumnName("nIdReticula").HasColumnType("int");
   e.Property(x=>x.SemestreActual).HasColumnName("nSemestreActual").HasColumnType("tinyint");
   e.Property(x=>x.LimiteCreditos).HasColumnName("nLimiteCreditos").HasColumnType("smallint");
   e.Property(x=>x.FechaInicio).HasColumnName("dFechaInicio").HasColumnType("date");
   e.Property(x=>x.FechaFin).HasColumnName("dFechaFin").HasColumnType("date");
   e.HasOne<Estudiante>().WithMany().HasForeignKey(x=>x.IdEstudiante).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<Reticula>().WithMany().HasForeignKey(x=>x.IdReticula).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<Docente>(e=>{
   e.ToTable("Tbl_Docente","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdDocente});
   e.Property(x=>x.IdDocente).HasColumnName("nIdDocente").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.IdUsuario).HasColumnName("nIdUsuario").HasColumnType("int");
   e.Property(x=>x.NumeroEmpleado).HasColumnName("cNumeroEmpleado").HasColumnType("varchar(25)");
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(150)");
   e.Property(x=>x.Estatus).HasColumnName("nEstatus").HasColumnType("bit");
   e.HasOne<Usuario>().WithMany().HasForeignKey(x=>x.IdUsuario).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<Aula>(e=>{
   e.ToTable("Tbl_Aula","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdAula});
   e.Property(x=>x.IdAula).HasColumnName("nIdAula").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.IdTipoAula).HasColumnName("nIdTipoAula").HasColumnType("int");
   e.Property(x=>x.Clave).HasColumnName("cClave").HasColumnType("varchar(30)");
   e.Property(x=>x.Capacidad).HasColumnName("nCapacidad").HasColumnType("smallint");
   e.Property(x=>x.Estatus).HasColumnName("nEstatus").HasColumnType("bit");
   e.HasOne<TipoAula>().WithMany().HasForeignKey(x=>x.IdTipoAula).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<ReticulaMateria>(e=>{
   e.ToTable("Tbl_ReticulaMateria","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdReticula,x.IdMateria});
   e.Property(x=>x.IdReticula).HasColumnName("nIdReticula").HasColumnType("int").ValueGeneratedNever();
   e.Property(x=>x.IdMateria).HasColumnName("nIdMateria").HasColumnType("int").ValueGeneratedNever();
   e.Property(x=>x.SemestreRecomendado).HasColumnName("nSemestreRecomendado").HasColumnType("tinyint");
   e.Property(x=>x.Creditos).HasColumnName("nCreditos").HasColumnType("tinyint");
   e.Property(x=>x.Obligatoria).HasColumnName("nObligatoria").HasColumnType("bit");
   e.HasOne<Reticula>().WithMany().HasForeignKey(x=>x.IdReticula).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<Materia>().WithMany().HasForeignKey(x=>x.IdMateria).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<MateriaPrerrequisito>(e=>{
   e.ToTable("Tbl_MateriaPrerrequisito","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdReticula,x.IdMateria,x.IdMateriaPrerrequisito});
   e.Property(x=>x.IdReticula).HasColumnName("nIdReticula").HasColumnType("int").ValueGeneratedNever();
   e.Property(x=>x.IdMateria).HasColumnName("nIdMateria").HasColumnType("int").ValueGeneratedNever();
   e.Property(x=>x.IdMateriaPrerrequisito).HasColumnName("nIdMateriaPrerrequisito").HasColumnType("int").ValueGeneratedNever();
   e.Property(x=>x.Obligatorio).HasColumnName("nObligatorio").HasColumnType("bit");
   e.HasOne<ReticulaMateria>().WithMany().HasForeignKey(x=>new{x.IdReticula,x.IdMateria}).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<ReticulaMateria>().WithMany().HasForeignKey(x=>new{x.IdReticula,x.IdMateriaPrerrequisito}).HasPrincipalKey(x=>new{x.IdReticula,x.IdMateria}).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<PeriodoAcademico>(e=>{
   e.ToTable("Tbl_PeriodoAcademico","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdPeriodo});
   e.Property(x=>x.IdPeriodo).HasColumnName("nIdPeriodo").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.Clave).HasColumnName("cClave").HasColumnType("varchar(20)");
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(100)");
   e.Property(x=>x.FechaInicio).HasColumnName("dFechaInicio").HasColumnType("date");
   e.Property(x=>x.FechaFin).HasColumnName("dFechaFin").HasColumnType("date");
   e.Property(x=>x.ActivoGeneracion).HasColumnName("nActivoGeneracion").HasColumnType("bit");
   e.Property(x=>x.OfertaPublicada).HasColumnName("nOfertaPublicada").HasColumnType("bit");
  });
  b.Entity<Grupo>(e=>{
   e.ToTable("Tbl_Grupo","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdGrupo});
   e.Property(x=>x.IdGrupo).HasColumnName("nIdGrupo").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.IdMateria).HasColumnName("nIdMateria").HasColumnType("int");
   e.Property(x=>x.IdDocente).HasColumnName("nIdDocente").HasColumnType("int");
   e.Property(x=>x.IdPeriodo).HasColumnName("nIdPeriodo").HasColumnType("int");
   e.Property(x=>x.ClaveGrupo).HasColumnName("cClaveGrupo").HasColumnType("varchar(20)");
   e.Property(x=>x.Estatus).HasColumnName("nEstatus").HasColumnType("bit");
   e.HasOne<Materia>().WithMany().HasForeignKey(x=>x.IdMateria).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<Docente>().WithMany().HasForeignKey(x=>x.IdDocente).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<PeriodoAcademico>().WithMany().HasForeignKey(x=>x.IdPeriodo).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<SesionGrupo>(e=>{
   e.ToTable("Tbl_SesionGrupo","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdSesionGrupo});
   e.Property(x=>x.IdSesionGrupo).HasColumnName("nIdSesionGrupo").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.IdGrupo).HasColumnName("nIdGrupo").HasColumnType("int");
   e.Property(x=>x.IdDiaSemana).HasColumnName("nIdDiaSemana").HasColumnType("tinyint");
   e.Property(x=>x.IdAula).HasColumnName("nIdAula").HasColumnType("int");
   e.Property(x=>x.HoraInicio).HasColumnName("dHoraInicio").HasColumnType("time(0)");
   e.Property(x=>x.HoraFin).HasColumnName("dHoraFin").HasColumnType("time(0)");
   e.HasOne<Grupo>().WithMany(x=>x.Sesiones).HasForeignKey(x=>x.IdGrupo).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<DiaSemana>().WithMany().HasForeignKey(x=>x.IdDiaSemana).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<Aula>().WithMany().HasForeignKey(x=>x.IdAula).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<HistorialAcademico>(e=>{
   e.ToTable("Tbl_HistorialAcademico","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdHistorialAcademico});
   e.Property(x=>x.IdHistorialAcademico).HasColumnName("nIdHistorialAcademico").HasColumnType("bigint").ValueGeneratedOnAdd();
   e.Property(x=>x.IdEstudiante).HasColumnName("nIdEstudiante").HasColumnType("int");
   e.Property(x=>x.IdMateria).HasColumnName("nIdMateria").HasColumnType("int");
   e.Property(x=>x.IdPeriodo).HasColumnName("nIdPeriodo").HasColumnType("int");
   e.Property(x=>x.IdEstatusAcademico).HasColumnName("nIdEstatusAcademico").HasColumnType("tinyint");
   e.Property(x=>x.Calificacion).HasColumnName("nCalificacion").HasColumnType("decimal(5,2)");
   e.Property(x=>x.FechaRegistro).HasColumnName("dFechaRegistro").HasColumnType("datetime2(0)");
   e.HasOne<Estudiante>().WithMany().HasForeignKey(x=>x.IdEstudiante).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<Materia>().WithMany().HasForeignKey(x=>x.IdMateria).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<PeriodoAcademico>().WithMany().HasForeignKey(x=>x.IdPeriodo).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<EstatusAcademico>().WithMany().HasForeignKey(x=>x.IdEstatusAcademico).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<HorarioGenerado>(e=>{
   e.ToTable("Tbl_HorarioGenerado","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdHorarioGenerado});
   e.Property(x=>x.IdHorarioGenerado).HasColumnName("nIdHorarioGenerado").HasColumnType("int").ValueGeneratedOnAdd();
   e.Property(x=>x.IdTrayectoria).HasColumnName("nIdTrayectoria").HasColumnType("int");
   e.Property(x=>x.IdPeriodo).HasColumnName("nIdPeriodo").HasColumnType("int");
   e.Property(x=>x.Nombre).HasColumnName("cNombre").HasColumnType("nvarchar(100)");
   e.Property(x=>x.Confirmado).HasColumnName("nConfirmado").HasColumnType("bit");
   e.Property(x=>x.Seleccionado).HasColumnName("nSeleccionado").HasColumnType("bit");
   e.Property(x=>x.FechaRegistro).HasColumnName("dFechaRegistro").HasColumnType("datetime2(0)");
   e.HasOne<TrayectoriaEstudiante>().WithMany().HasForeignKey(x=>x.IdTrayectoria).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<PeriodoAcademico>().WithMany().HasForeignKey(x=>x.IdPeriodo).OnDelete(DeleteBehavior.Restrict);
  });
  b.Entity<HorarioGeneradoDetalle>(e=>{
   e.ToTable("Tbl_HorarioGeneradoDetalle","App",t=>t.UseSqlOutputClause(false));
   e.HasKey(x=>new{x.IdHorarioGenerado,x.IdGrupo});
   e.Property(x=>x.IdHorarioGenerado).HasColumnName("nIdHorarioGenerado").HasColumnType("int").ValueGeneratedNever();
   e.Property(x=>x.IdGrupo).HasColumnName("nIdGrupo").HasColumnType("int").ValueGeneratedNever();
   e.HasOne<HorarioGenerado>().WithMany().HasForeignKey(x=>x.IdHorarioGenerado).OnDelete(DeleteBehavior.Restrict);
   e.HasOne<Grupo>().WithMany().HasForeignKey(x=>x.IdGrupo).OnDelete(DeleteBehavior.Restrict);
  });
  foreach(var fk in b.Model.GetEntityTypes().SelectMany(e=>e.GetForeignKeys())) fk.DeleteBehavior=DeleteBehavior.Restrict;
 }
}
