# Plantillas para documentar

Scripts reutilizables para tareas repetitivas de documentación.

## `agregar-diagrama-mermaid-en-documento.sh`

Inserta un bloque Mermaid bien formado en un `.md`, **reemplazando una
etiqueta de marcador** o **insertando en una línea específica**.

### Ubicación

```
docs/plantillasParaDocumentar/agregar-diagrama-mermaid-en-documento.sh
```

### Modelo de uso (obligatorio seguir este orden)

1. **Agregar la etiqueta** en el documento destino, en la línea donde
   debe ir el diagrama. Ejemplo:
   ```
   {pon aqui tu diagrama secuencia tokens}
   ```
2. **Copiar la plantilla** a `/tmp/<nombre>.sh`.
3. **Rellenar la configuración** del shell temporal:
   - `ARCHIVO` (ruta del `.md`)
   - `ETIQUETA` (o `LINEA` como override)
   - `TIPO` (`sequence` | `flowchart`)
   - `CONTENIDO` (ruta del `.md` con el bloque Mermaid)
4. **Ejecutar el shell temporal**.
5. **Verificar el resultado** (`sed -n`, `diff`, `cat`).
6. **Borrar el shell temporal** antes del commit.

### Comportamiento

- **Busca la etiqueta** en el archivo:
  - 0 ocurrencias → error: "etiqueta no encontrada en el archivo"
  - 1 ocurrencia → reemplaza esa línea por el bloque ` ```mermaid `
  - 2+ ocurrencias → error: "etiqueta ambigua (N ocurrencias en líneas X, Y, Z). Usá --linea N"
- **Fix estático en flowchart**: envuelve en comillas los labels con `{}`,
  `*`, `/` o espacios (Mermaid rompe con esos caracteres si no están entre
  comillas).
- **Valida** que no queden `{}` sin comillas en flowchart.
- **Idempotente**: si la línea ya tiene un bloque ` ```mermaid `, no inserta.
- **Backup temporal** del archivo, se borra al terminar.

### Uso directo (CLI)

```bash
./agregar-diagrama-mermaid-en-documento.sh \
  --archivo docs/tecnica/04-.../00_alcance.md \
  --etiqueta "{pon aqui tu diagrama secuencia tokens}" \
  --tipo sequence \
  --contenido /tmp/bloque-sequence.md
```

### Uso con shell temporal (recomendado)

```bash
# 1. Copiar
cp docs/plantillasParaDocumentar/agregar-diagrama-mermaid-en-documento.sh /tmp/insert-mi-diagrama.sh

# 2. Rellenar configuración (editar /tmp/insert-mi-diagrama.sh):
ARCHIVO="docs/tecnica/04-.../00_alcance.md"
ETIQUETA="{pon aqui tu diagrama secuencia tokens}"
LINEA=""
TIPO="sequence"
CONTENIDO="/tmp/bloque-sequence.md"

# 3. Ejecutar
bash /tmp/insert-mi-diagrama.sh

# 4. Verificar
sed -n '35,60p' docs/tecnica/04-.../00_alcance.md

# 5. Borrar temporal
rm /tmp/insert-mi-diagrama.sh
```

### Reglas

- **No** se ejecuta la plantilla directamente. Siempre se copia a `/tmp/`
  y se rellena.
- **No** se commitea el shell temporal.
- **Sí** se commitea el resultado (el `.md` modificado).
- La etiqueta **desaparece** al insertar el bloque.
- Si la etiqueta aparece 2+ veces, **abortar** y usar `--linea N` como
  override.

### Ver también

- Regla R15 en `docs/prompts/prompt_inicial.md`.
- Sección "Diagramas Mermaid" en `README.md`.
