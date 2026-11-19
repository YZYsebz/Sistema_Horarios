using Xunit;
using SistemaHorarios.Domain.Rules;
namespace SistemaHorarios.UnitTests;
public sealed class HorarioGeneratorTests
{
 private static GrupoCandidato G(int id,int materia,int inicio,int fin,int dia=1,int creditos=4,int periodo=1,bool activo=true,int? docente=null,int? aula=null,bool reticula=true,bool requisitos=true)
 =>new(id,materia,creditos,docente??id,periodo,activo,reticula,requisitos,[new(dia,new(inicio,0),new(fin,0),aula??id)]);
 private readonly HorarioGenerator engine=new();
 [Fact]public void GeneraUnaCombinacionContigua(){var r=engine.Generar([1,2],[G(1,1,8,10),G(2,2,10,12)],8,1);Assert.Single(r.Opciones);Assert.Equal(2,r.Opciones[0].Count);}
 [Fact]public void RechazaEmpalmeObligatorio()=>Assert.Empty(engine.Generar([1,2],[G(1,1,8,10),G(2,2,9,11)],20,1).Opciones);
 [Fact]public void ExploraAlternativasYHacePoda(){var r=engine.Generar([1,2],[G(1,1,8,10),G(2,1,10,12),G(3,2,9,11),G(4,2,12,14)],20,1);Assert.Equal(2,r.Opciones.Count);Assert.All(r.Opciones,o=>Assert.Equal(2,o.Select(g=>g.MateriaId).Distinct().Count()));}
 [Fact]public void NoExcedeCreditos()=>Assert.Empty(engine.Generar([1,2],[G(1,1,8,10),G(2,2,10,12)],7,1).Opciones);
 [Fact]public void NoRepiteMateriaSolicitada()=>Assert.Throws<ArgumentException>(()=>engine.Generar([1,1],[G(1,1,8,10)],10,1));
 [Theory][InlineData(false,1,true,true)][InlineData(true,2,true,true)][InlineData(true,1,false,true)][InlineData(true,1,true,false)]
 public void FiltraGrupoInvalido(bool activo,int periodo,bool reticula,bool requisitos)=>Assert.Empty(engine.Generar([1],[G(1,1,8,10,periodo:periodo,activo:activo,reticula:reticula,requisitos:requisitos)],10,1).Opciones);
 [Fact]public void NoAceptaGrupoSinSesiones(){var g=G(1,1,8,10) with{Sesiones=[]};Assert.Empty(engine.Generar([1],[g],10,1).Opciones);}
 [Fact]public void DetectaConflictoDocenteConOtroGrupoOfertado()=>Assert.Empty(engine.Generar([1],[G(1,1,8,10,docente:7),G(2,2,9,11,docente:7)],10,1).Opciones);
 [Fact]public void DetectaConflictoAulaConOtroGrupoOfertado()=>Assert.Empty(engine.Generar([1],[G(1,1,8,10,aula:7),G(2,2,9,11,aula:7)],10,1).Opciones);
 [Fact]public void IgnoraRecursoDeGrupoInactivo()=>Assert.Single(engine.Generar([1],[G(1,1,8,10,aula:7),G(2,2,9,11,aula:7,activo:false)],10,1).Opciones);
 [Fact]public void LimitaOpciones(){var grupos=new[]{G(1,1,8,9),G(2,1,9,10),G(3,2,10,11),G(4,2,11,12)};var r=engine.Generar([1,2],grupos,20,1,maxOpciones:2);Assert.Equal(2,r.Opciones.Count);Assert.True(r.LimiteAlcanzado);}
 [Fact]public void LimitaEstados(){var r=engine.Generar([1,2],[G(1,1,8,10),G(2,2,10,12)],20,1,maxEstados:1);Assert.Empty(r.Opciones);Assert.True(r.LimiteAlcanzado);Assert.Equal(1,r.EstadosExplorados);}
 [Fact]public void AtiendeCancelacion(){using var c=new CancellationTokenSource();c.Cancel();Assert.Throws<OperationCanceledException>(()=>engine.Generar([1],[G(1,1,8,10)],10,1,ct:c.Token));}
 [Fact]public void NoMutaResultadosEntreInvocaciones(){var a=engine.Generar([1],[G(1,1,8,10)],10,1);engine.Generar([2],[G(2,2,10,12)],10,1);Assert.Equal(1,a.Opciones[0][0].Id);}
}
