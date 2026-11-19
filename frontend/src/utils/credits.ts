import type {Materia} from '../models/types';
export function totalCreditos(materias:Pick<Materia,'id'|'creditos'>[],ids:number[]):number{const unique=new Set(ids);return materias.filter(m=>unique.has(m.id)).reduce((a,m)=>a+m.creditos,0)}
export function toggleMateria(ids:number[],id:number):number[]{return ids.includes(id)?ids.filter(x=>x!==id):[...ids,id]}
