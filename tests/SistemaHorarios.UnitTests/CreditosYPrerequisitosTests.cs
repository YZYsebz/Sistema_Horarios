using Xunit;
using SistemaHorarios.Domain.Rules;
namespace SistemaHorarios.UnitTests;
public sealed class CreditosYPrerequisitosTests
{
 [Fact]public void AceptaElLimiteExacto()=>Assert.True(CreditosValidator.EsValido([5,5,4],14));
 [Fact]public void RechazaExceso()=>Assert.False(CreditosValidator.EsValido([5,5,4],13));
 [Theory][InlineData(0)][InlineData(-4)]public void RechazaCreditosNoPositivos(int value)=>Assert.False(CreditosValidator.EsValido([value],20));
 [Fact]public void SinPrerequisitosEsElegible()=>Assert.True(PrerequisitoValidator.Cumple([],new HashSet<int>()));
 [Fact]public void RequiereTodosLosAntecedentes()=>Assert.False(PrerequisitoValidator.Cumple([1,2],new HashSet<int>{1}));
 [Fact]public void CumpleMultiplesAntecedentes()=>Assert.True(PrerequisitoValidator.Cumple([1,2],new HashSet<int>{1,2,3}));
}
