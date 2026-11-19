namespace SistemaHorarios.Domain.Rules;
public readonly record struct SesionSemanal(int Dia,TimeOnly Inicio,TimeOnly Fin,int AulaId=0);
public static class EmpalmeValidator
{
 public static bool Existe(SesionSemanal a,SesionSemanal b)=>a.Dia==b.Dia && a.Inicio<b.Fin && b.Inicio<a.Fin;
 public static bool EsValida(SesionSemanal s)=>s.Dia is >=1 and <=7 && s.Inicio<s.Fin;
}
public static class CreditosValidator
{public static bool EsValido(IEnumerable<int> creditos,int limite)=>limite>0 && creditos.All(x=>x>0) && creditos.Sum()<=limite;}
public static class PrerequisitoValidator
{public static bool Cumple(IEnumerable<int> requisitos,IReadOnlySet<int> aprobadas)=>requisitos.All(aprobadas.Contains);}
