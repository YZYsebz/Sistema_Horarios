import {createContext,useContext,useEffect,useState,type ReactNode} from 'react';
import {useAuth} from './useAuth';import {academic} from '../services/academic';import {mensajeError} from '../api/client';import type {Perfil,Materia} from '../models/types';
interface Value{perfil:Perfil|null;materias:Materia[];seleccion:number[];setSeleccion:(ids:number[])=>void;loading:boolean;error:string;recargar:()=>void}
const Context=createContext<Value|null>(null);
export function AcademicProvider({children}:{children:ReactNode}){const{usuario}=useAuth();const[perfil,setPerfil]=useState<Perfil|null>(null);const[materias,setMaterias]=useState<Materia[]>([]);const[seleccion,setSeleccion]=useState<number[]>([]);const[loading,setLoading]=useState(false);const[error,setError]=useState('');const[version,setVersion]=useState(0);
 useEffect(()=>{let vigente=true;setSeleccion([]);setPerfil(null);setMaterias([]);setError('');if(!usuario?.roles.includes('ESTUDIANTE')){setLoading(false);return}setLoading(true);Promise.all([academic.perfil(),academic.materias()]).then(([p,m])=>{if(vigente){setPerfil(p);setMaterias(m)}}).catch(e=>{if(vigente)setError(mensajeError(e))}).finally(()=>{if(vigente)setLoading(false)});return()=>{vigente=false}},[usuario,version]);
 return <Context.Provider value={{perfil,materias,seleccion,setSeleccion,loading,error,recargar:()=>setVersion(x=>x+1)}}>{children}</Context.Provider>
}
export function useAcademic(){const v=useContext(Context);if(!v)throw new Error('Falta AcademicProvider');return v}
