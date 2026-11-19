import type {Grupo} from '../models/types';
const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
const minutos = (s: string) => Number(s.slice(0, 2)) * 60 + Number(s.slice(3, 5));
export function WeekCalendar({grupos}: {grupos: Grupo[]}) {
  const sesiones = grupos.flatMap(g => g.sesiones);
  const inicio = Math.floor(Math.min(420, ...sesiones.map(s => minutos(s.inicio))) / 60) * 60;
  const fin = Math.ceil(Math.max(1020, ...sesiones.map(s => minutos(s.fin))) / 60) * 60;
  const horas = Array.from({length: (fin - inicio) / 60}, (_, j) => inicio / 60 + j);
  const diasVisibles = dias.filter((_, i) => i < 5 || sesiones.some(s => s.dia === i + 1));
  return <div className="week-scroll" role="region" aria-label="Horario semanal. Desplaza horizontalmente para consultar todos los días." tabIndex={0}><div className="week" style={{gridTemplateColumns: `57px repeat(${diasVisibles.length}, minmax(128px, 1fr))`, height: fin - inicio + 48}}><div className="time-axis"><div className="day-heading">Hora</div>{horas.map(h => <div key={h} className="hour-label" style={{top: 48 + h * 60 - inicio}}>{String(h).padStart(2, '0')}:00</div>)}</div>{diasVisibles.map(dia => { const numeroDia = dias.indexOf(dia) + 1; return <div className="day-column" key={dia}><div className="day-heading">{dia}<span>{numeroDia}</span></div><div className="day-body" style={{height: fin - inicio}}>{horas.map(h => <div className="hour-line" key={h} style={{top: h * 60 - inicio}}/>)}{grupos.flatMap((g, index) => g.sesiones.filter(s => s.dia === numeroDia).map(s => <div key={`${g.id}-${s.id}`} className={`class-block tone-${index % 6}`} style={{top: minutos(s.inicio) - inicio, height: minutos(s.fin) - minutos(s.inicio)}} title={`${g.materia} · ${g.docente} · ${dia} ${s.inicio.slice(0, 5)}–${s.fin.slice(0, 5)} · ${s.aula}`}><span className="class-time">{s.inicio.slice(0, 5)}–{s.fin.slice(0, 5)}</span><strong>{g.materia}</strong><span>{g.materiaClave} · {g.clave}</span><span className="class-room">{s.aula}</span></div>))}</div></div>; })}</div></div>;
}
