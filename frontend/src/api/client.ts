import axios from 'axios';
export const http=axios.create({baseURL:import.meta.env.VITE_API_BASE_URL||'/api',timeout:45000});
let token:string|null=null;
export function setAccessToken(value:string|null){token=value}
http.interceptors.request.use(config=>{if(token)config.headers.Authorization=`Bearer ${token}`;return config});
http.interceptors.response.use(r=>r,error=>{if(error.response?.status===401 && token){token=null;window.dispatchEvent(new Event('sesion-expirada'))}return Promise.reject(error)});
export function mensajeError(error:unknown):string{if(axios.isAxiosError(error)){const d=error.response?.data;return d?.detail||d?.title||(error.response?.status===429?'Demasiados intentos. Espera un minuto para volver a intentar.':!error.response?'No se pudo conectar con el servidor. Comprueba que la API esté iniciada.':'No fue posible completar la operación.')}return 'No fue posible completar la operación.'}
