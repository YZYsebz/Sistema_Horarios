import {createContext,useContext,useEffect,useState,type ReactNode} from 'react';
import {http,setAccessToken} from '../api/client';
import type {Usuario,SesionLogin} from '../models/types';
interface AuthValue{usuario:Usuario|null;login:(usuario:string,password:string)=>Promise<void>;logout:()=>void}
const Context=createContext<AuthValue|null>(null);
export function AuthProvider({children}:{children:ReactNode}){const [usuario,setUsuario]=useState<Usuario|null>(null);
 const logout=()=>{setAccessToken(null);setUsuario(null)};
 useEffect(()=>{window.addEventListener('sesion-expirada',logout);return()=>window.removeEventListener('sesion-expirada',logout)},[]);
 const login=async(usuario:string,password:string)=>{const {data}=await http.post<SesionLogin>('/auth/login',{usuario,password});setAccessToken(data.accessToken);setUsuario(data.usuario)};
 return <Context.Provider value={{usuario,login,logout}}>{children}</Context.Provider>
}
export function useAuth(){const value=useContext(Context);if(!value)throw new Error('Falta AuthProvider');return value}
