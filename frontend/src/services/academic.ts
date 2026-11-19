import {http} from '../api/client';
import type {Perfil,Materia,Grupo,Horario,Creditos,Generacion} from '../models/types';
export const academic={
 perfil:async()=> (await http.get<Perfil>('/estudiantes/me')).data,
 materias:async()=> (await http.get<Materia[]>('/estudiantes/me/materias-disponibles')).data,
 grupos:async()=> (await http.get<Grupo[]>('/grupos')).data,
 horarios:async()=> (await http.get<Horario[]>('/horarios')).data,
 creditos:async(materiaIds:number[])=> (await http.post<Creditos>('/estudiantes/me/seleccion/creditos',{materiaIds})).data,
 generar:async(materiaIds:number[])=> (await http.post<Generacion>('/horarios/generar',{materiaIds})).data,
 guardar:async(nombre:string,grupoIds:number[],seleccionar:boolean)=> (await http.post<{id:number}>('/horarios',{nombre,grupoIds,seleccionar})).data,
 seleccionar:async(id:number)=>http.put(`/horarios/${id}/seleccion`),
 catalogo:async(endpoint:string)=> (await http.get<Record<string,unknown>[]>(`/${endpoint}`)).data
};
