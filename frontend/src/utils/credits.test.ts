import{describe,it,expect}from'vitest';import{totalCreditos,toggleMateria}from'./credits';
describe('selección académica',()=>{
 const materias=[{id:1,creditos:5},{id:2,creditos:4},{id:3,creditos:6}];
 it('suma únicamente las materias elegidas',()=>expect(totalCreditos(materias,[1,3])).toBe(11));
 it('evita contar dos veces una selección repetida',()=>expect(totalCreditos(materias,[1,1])).toBe(5));
 it('da cero con selección vacía',()=>expect(totalCreditos(materias,[])).toBe(0));
 it('agrega una materia sin modificar la selección original',()=>{const original=[1];expect(toggleMateria(original,2)).toEqual([1,2]);expect(original).toEqual([1])});
 it('quita la materia seleccionada',()=>expect(toggleMateria([1,2],1)).toEqual([2]));
});
