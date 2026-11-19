using Xunit;
using SistemaHorarios.Domain.Rules;
namespace SistemaHorarios.UnitTests;
public sealed class EmpalmeValidatorTests
{
 [Theory][InlineData(8,10,9,11,true)][InlineData(8,10,10,12,false)][InlineData(8,10,7,8,false)][InlineData(8,12,9,10,true)][InlineData(8,10,8,10,true)]
 public void IntervalosSemiabiertos(int ai,int af,int bi,int bf,bool expected)=>Assert.Equal(expected,EmpalmeValidator.Existe(new(1,new(ai,0),new(af,0)),new(1,new(bi,0),new(bf,0))));
 [Fact]public void DiasDistintosNoSeEmpalman()=>Assert.False(EmpalmeValidator.Existe(new(1,new(8,0),new(10,0)),new(2,new(8,0),new(10,0))));
 [Theory][InlineData(0,8,10)][InlineData(8,8,10)][InlineData(1,10,8)][InlineData(1,10,10)]
 public void IntervaloInvalido(int dia,int inicio,int fin)=>Assert.False(EmpalmeValidator.EsValida(new(dia,new(inicio,0),new(fin,0))));
}
