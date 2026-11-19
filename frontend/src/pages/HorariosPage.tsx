import {useEffect, useRef, useState} from 'react';
import {Link} from 'react-router-dom';
import {ArrowRight, CheckCircle2, Save, Sparkles} from 'lucide-react';
import {useAcademic} from '../hooks/useAcademic';
import {academic} from '../services/academic';
import {mensajeError} from '../api/client';
import {Empty, ErrorBox, Loading} from '../components/Feedback';
import {WeekCalendar} from '../components/WeekCalendar';
import type {Generacion} from '../models/types';

export function HorariosPage() {
  const {seleccion, materias, perfil, loading, error} = useAcademic();
  const [resultado, setResultado] = useState<Generacion | null>(null);
  const [indice, setIndice] = useState(0);
  const [generando, setGenerando] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [fallo, setFallo] = useState('');
  const [nombre, setNombre] = useState('Mi horario');
  const [seleccionar, setSeleccionar] = useState(true);
  const [guardado, setGuardado] = useState<number | null>(null);
  const version = useRef(0);
  const claveSeleccion = seleccion.join(',');
  useEffect(() => {
    version.current++;
    setResultado(null); setGuardado(null); setFallo(''); setGenerando(false);
    return () => { version.current++; };
  }, [claveSeleccion]);

  async function generar() {
    const actual = ++version.current;
    setGenerando(true); setFallo(''); setGuardado(null); setResultado(null);
    try {
      const respuesta = await academic.generar(seleccion);
      if (actual === version.current) { setResultado(respuesta); setIndice(0); }
    } catch (e) { if (actual === version.current) setFallo(mensajeError(e)); }
    finally { if (actual === version.current) setGenerando(false); }
  }
  async function guardar(e: React.FormEvent) {
    e.preventDefault();
    const opcion = resultado?.opciones[indice];
    if (!opcion) return;
    setGuardando(true); setFallo('');
    try {
      const respuesta = await academic.guardar(nombre.trim(), opcion.grupos.map(g => g.id), seleccionar);
      setGuardado(respuesta.id);
    } catch (e) { setFallo(mensajeError(e)); }
    finally { setGuardando(false); }
  }
  if (loading) return <Loading/>;
  if (error) return <ErrorBox message={error}/>;
  const elegidas = materias.filter(m => seleccion.includes(m.id));
  const opcion = resultado?.opciones[indice];
  return <>
    <div className="page-heading"><span className="eyebrow">PASO 03 · ENCUENTRA TU SEMANA</span><h1>Opciones de horario</h1><p>Compara combinaciones sin empalmes y guarda la que mejor se adapte a ti.</p></div>
    {!seleccion.length ? <section className="panel"><Empty title="Comienza con tus materias" detail="Agrega las materias que quieres cursar para encontrar combinaciones de grupos."/><div className="text-center pb-5"><Link className="btn btn-primary" to="/materias">Explorar materias <ArrowRight size={18}/></Link></div></section> : <>
      <section className="panel generating-banner"><div><h2>{elegidas.length} materias para tu próximo semestre</h2><p>{elegidas.map(m => m.nombre).join(' · ')}</p><Link className="text-link mt-2" to="/seleccion">Revisar selección</Link></div><button className="btn btn-primary" disabled={generando || guardando} onClick={generar}><Sparkles size={17}/>{generando ? 'Buscando combinaciones…' : 'Generar horarios'}</button></section>
      {fallo && <ErrorBox message={fallo}/>}
      {generando && <Loading/>}
      {resultado && !resultado.opciones.length && <section className="panel"><Empty title="No encontramos una combinación válida" detail="Los grupos disponibles para estas materias no pueden combinarse. Prueba retirando una materia de tu selección."/><div className="text-center pb-5"><Link className="btn btn-outline-secondary" to="/seleccion">Ajustar selección</Link></div></section>}
      {!!resultado?.opciones.length && <>
        <p className="options-note" role="status">{resultado.opciones.length} {resultado.opciones.length === 1 ? 'combinación disponible' : 'combinaciones disponibles'} · Límite de {perfil?.limiteCreditos} créditos.{resultado.limiteAlcanzado && ' Se alcanzó el límite de búsqueda; puede haber más combinaciones.'}</p>
        <div className="option-grid">{resultado.opciones.map((o, i) => <section className={`panel option-card ${i === indice ? 'option-active' : ''}`} key={o.id}><div className="option-title"><h3>Opción {o.id.toString().padStart(2, '0')}</h3>{i === indice && <CheckCircle2 size={19}/>}</div><div className="option-meta"><span>{o.creditos} créditos</span><span>{o.grupos.length} materias</span><span>Sin empalmes</span></div><ul>{o.grupos.map(g => <li key={g.id}><strong>{g.materia}</strong><span>{g.materiaClave} · Grupo {g.clave} · {g.docente}</span></li>)}</ul><button className="btn btn-outline-secondary btn-sm" aria-pressed={i === indice} disabled={guardando} onClick={() => { setIndice(i); setGuardado(null); }}>Ver opción {o.id}</button></section>)}</div>
        {opcion && <>
          <div className="schedule-toolbar mt-4"><h2 className="mb-0">Vista semanal · Opción {opcion.id}</h2><div className="schedule-badges"><span>{opcion.creditos} créditos</span><span>{opcion.grupos.length} materias</span></div></div>
          <section className="panel calendar-panel"><WeekCalendar grupos={opcion.grupos}/></section>
          <section className="panel save-schedule mt-4"><div><span className="eyebrow">TU DECISIÓN, GUARDADA</span><h2>Conserva esta opción</h2><p>Puedes guardar varias opciones y elegir una para el periodo actual.</p></div>{guardado ? <div className="saved-message" role="status"><CheckCircle2 size={22}/><div><strong>Horario guardado correctamente</strong><Link className="text-link" to="/mi-horario">Ver mis horarios <ArrowRight size={16}/></Link></div></div> : <form onSubmit={guardar}><label className="form-label" htmlFor="schedule-name">Nombre del horario</label><input id="schedule-name" className="form-control" value={nombre} onChange={e => setNombre(e.target.value)} required maxLength={100} placeholder="Por ejemplo, Mi horario de otoño"/><label className="save-checkbox"><input type="checkbox" checked={seleccionar} onChange={e => setSeleccionar(e.target.checked)}/> Usar como mi horario seleccionado</label><button className="btn btn-primary" disabled={guardando || !nombre.trim()}><Save size={17}/>{guardando ? 'Guardando…' : 'Guardar horario'}</button></form>}</section>
        </>}
      </>}
    </>}
  </>;
}
