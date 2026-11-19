from pathlib import Path
import pdfplumber
import pypdfium2 as pdfium
root=Path(r'C:\Users\mause\OneDrive\Escritorio\5TO SEMESTRE\Ingenieria de software\Sistema_Horarios')
for path in (root/'docs'/'fuentes').glob('*.pdf'):
    render=pdfium.PdfDocument(path)
    stem=('reticula_especialidad' if path.name.startswith('Reticula-ISIE') else 'reticula_base') if path.name.startswith('Reticula') else 'carga'
    with pdfplumber.open(path) as doc:
        for i,page in enumerate(doc.pages):
            text=page.extract_text(layout=True) or ''
            (root/'docs'/'fase1'/'extraccion'/f'{stem}_{i+1}.txt').write_text(text,encoding='utf-8')
            render[i].render(scale=1.5).to_pil().save(root/'docs'/'fase1'/'extraccion'/f'{stem}_{i+1}.png')
            print(f'=== {stem} pagina {i+1} ===\n{text}')

