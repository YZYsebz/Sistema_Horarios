import {useEffect, useState} from 'react';
import {Link} from 'react-router-dom';
import {CalendarCheck, CheckCircle2} from 'lucide-react';
import {academic} from '../services/academic';
import {mensajeError} from '../api/client';
import {useAcademic} from '../hooks/useAcademic';
import {WeekCalendar} from '../components/WeekCalendar';
import {Loading, ErrorBox, Empty} from '../components/Feedback';
import type {Horario} from '../models/types';

export function MiHorarioPage() {
  const {perfil} = useAcademic();
  const [rows, setRows] = useState<Horario[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [index, setIndex] = useState(0);
  const [saving, setSaving] = useState(false);
  useEffect(() => {
    let live = true;
    academic.horarios().then(r => {
      if (live) { setRows(r); setIndex(Math.max(0, r.findIndex(h => h.seleccionado && h.idPeriodo === perfil?.idPeriodo))); }
    }).catch(e => { if (live) setError(mensajeError(e)); }).finally(() => { if (live) setLoading(false); });
    return () => { live = false; };
  }, [perfil?.idPeriodo]);
  async function seleccionar(id: number) {
    setSaving(true); setError('');
    try { await academic.seleccionar(id); setRows(await academic.horarios()); }
    catch (e) { setError(mensajeError(e)); }
    finally { setSaving(false); }
  }
  if (loading) return <Loading/>;
  const actual = rows[index];
  return <>
    <div className="page-heading"><span className="eyebrow">LISTO PARA TU SEMESTRE</span><h1>Mi horario</h1><p>Tus materias, grupos y aulas en una sola vista.</p></div>
    {error && <ErrorBox message={error}/>}
    {!actual ? <div className="panel"><Empty title="Aún no tienes horarios guardados" detail="Crea una selección de materias para encontrar tu primera opción."/><div className="text-center pb-5"><Link className="btn btn-primary" to="/materias">Explorar materias</Link></div></div> : <>
      <div className="schedule-toolbar"><div><CalendarCheck size={22}/><select aria-label="Elegir horario guardado" className="form-select" value={index} disabled={saving} onChange={e => setIndex(Number(e.target.value))}>{rows.map((h, i) => <option key={h.id} value={i}>{h.nombre.replace('DEMO-v1-', 'Horario de referencia · ')}</option>)}</select></div><div className="schedule-badges"><span>{actual.periodo}</span><span>{actual.creditos} créditos</span><span>{actual.grupos.length} materias</span>{actual.seleccionado && <span className="selected-pill"><CheckCircle2 size={15}/> Seleccionado</span>}</div></div>
      {!actual.seleccionado && actual.idPeriodo === perfil?.idPeriodo && <button className="btn btn-primary mb-3" disabled={saving} onClick={() => seleccionar(actual.id)}><CheckCircle2 size={17}/>{saving ? 'Seleccionando…' : 'Usar este horario'}</button>}
      <section className="panel calendar-panel"><WeekCalendar grupos={actual.grupos}/></section>
      <section className="panel mt-4"><div className="panel-heading"><h2>Detalle de materias</h2></div><div className="table-responsive"><table className="table academic-table"><thead><tr><th>Materia</th><th>Grupo</th><th>Docente</th><th>Sesiones</th></tr></thead><tbody>{actual.grupos.map(g => <tr key={g.id}><td><small className="subject-code">{g.materiaClave}</small><strong className="subject-name">{g.materia}</strong></td><td>{g.clave}</td><td>{g.docente}</td><td>{g.sesiones.map(s => <div className="session-detail" key={s.id}>{s.diaNombre} {s.inicio.slice(0, 5)}–{s.fin.slice(0, 5)} <strong>{s.aula}</strong></div>)}</td></tr>)}</tbody></table></div></section>
    </>}
  </>;
}
