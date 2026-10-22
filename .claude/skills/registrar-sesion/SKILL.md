---
name: registrar-sesion
description: Cierra una sesión de trabajo del Taller 2 — escribe la bitácora en 06_Bitacoras/ con el formato exigido por CLAUDE.md y copia el registro crudo (.jsonl) de la conversación actual a 09_Conversaciones/ (carpeta ignorada por git). Usar cuando el usuario pida "cerrar sesión", "registrar la sesión", "escribir la bitácora" o "guardar la conversación".
---

# Registrar sesión de trabajo

Al terminar una sesión de trabajo en este taller, hace dos cosas en este
orden:

1. Escribir la bitácora de la sesión en `06_Bitacoras/`.
2. Copiar el registro crudo (`.jsonl`) de la conversación a `09_Conversaciones/`.

Básate solo en lo que ocurrió en la conversación. Confirma los archivos
afectados con `git status` / `git diff --stat` (y `git log` si hubo commits).
Si algo no es inferible con certeza (un supuesto, un resultado ambiguo, quién
del equipo trabajó en la sesión), pregunta al usuario en vez de adivinar. Si el
usuario pide solo una de las dos partes, haz solo esa.

## Paso 1: bitácora

Antes de escribir, lee las bitácoras previas en `06_Bitacoras/` (si existen)
para entender qué se hizo y qué quedó pendiente, y para mantener el formato.

Nombre del archivo: `YYYY-MM-DD_slug-descriptivo.md` (minúsculas, guiones), con
la fecha real de la sesión. Si ya hay una bitácora del mismo día, agrega un
sufijo numérico (`_2`) o pregunta.

Estructura (la que exige `CLAUDE.md`):

```markdown
# Bitácora — YYYY-MM-DD: <descripción corta>

## Resumen
Objetivo de la sesión y desarrollo, en pocos párrafos.

## Archivos
- Creados: ...
- Modificados: ...
- Eliminados: ...

## Detalle por archivo
### `ruta/relativa/archivo`
Qué cambió, decisiones de implementación, supuestos usados y la intuición
en lenguaje natural de cada decisión.

## Resultados nuevos (tablas, figuras, gráficos)
Por cada uno: qué busca comunicar, cómo se generan los datos que lo alimentan
y qué rol cumple dentro del taller. Omitir la sección si no hubo.

## Pendientes
Lo que quedó sin hacer, supuestos sin confirmar y el siguiente paso. Esta
sección es el insumo de la próxima sesión.
```

Reglas de contenido (de `CLAUDE.md`):

- Reporta cuántas observaciones se pierden en cualquier limpieza o filtro
  mencionado.
- No juicios de "bueno" o "malo" sobre resultados, ni entusiasmo por
  coeficientes, métricas o significancia.
- Distingue siempre estimando, estimador y estimación; y en qué escala está
  cada número (`ln(Revenue)` o `Revenue`).
- Si se mencionan subgrupos o CATE, indica que son descriptivos/estimados y
  dependen de la partición muestral; una covariable que divide un árbol no es
  la causa de que el efecto difiera.
- Para las variables que construyen un estimador, explica cada una por aparte:
  fuente (página o sección del recurso, p. ej. en `07_Recursos/`), cómo se
  calcula y qué rol cumple en la fórmula.
- Si se tomó una decisión metodológica relevante, regístrala también en la
  tabla "Decisiones tomadas" de `CLAUDE.md` (o en "Análisis descartados" si se
  descartó algo), y actualiza "Estado actual".
- Sin código en la bitácora salvo que aporte a entender una decisión.

Versionado: haz commit de la bitácora y de los cambios de la sesión, y súbelos
al repositorio de GitHub asociado, salvo que el usuario indique lo contrario.
Los archivos de datos generados por los scripts (p. ej. los `.rds` nuevos o
regenerados en `01_Datos/`) se versionan: revisa `git status` por archivos de
datos sin seguimiento. Los datos crudos de `01_Datos/01_Crudos/` nunca se
modifican. Nunca push a `main` sin que el usuario lo pida.

## Paso 2: copiar el `.jsonl` de la conversación

Claude Code guarda cada sesión como un `.jsonl` en
`~/.claude/projects/<slug>/`, donde `<slug>` es la ruta del directorio de
trabajo con todo carácter no alfanumérico reemplazado por `-`. Si la sesión
corrió desde un worktree, el directorio de trabajo es el del worktree, así que
basta con usar la raíz del directorio actual (`git rev-parse --show-toplevel`).

Esta skill se invoca **sin argumentos**: Claude Code sustituye los marcadores
`$1`, `$2`... del texto de la skill por los argumentos, y por eso el bloque no
los usa.

```bash
# Raíz del directorio de trabajo actual (repo principal o worktree)
TOPLEVEL=$(git rev-parse --show-toplevel)

# Carpeta de proyecto de Claude: la ruta con lo no alfanumérico cambiado por "-"
CARPETA="$HOME/.claude/projects/$(printf '%s' "$TOPLEVEL" | sed -E 's/[^A-Za-z0-9]/-/g')"

# Sesión actual = .jsonl modificado más recientemente en esa carpeta
SESSION_FILE=$(ls -t "$CARPETA"/*.jsonl 2>/dev/null | head -1)

if [ -z "$SESSION_FILE" ]; then
  echo "No se encontró ningún .jsonl en: $CARPETA"; exit 1
fi

# Destino dentro del repo (relativo a la raíz donde se ejecuta la sesión)
mkdir -p "$TOPLEVEL/09_Conversaciones"
DEST="$TOPLEVEL/09_Conversaciones/$(date +%Y-%m-%d)_$(basename "$SESSION_FILE")"
cp "$SESSION_FILE" "$DEST"
echo "Copiado: $SESSION_FILE -> $DEST"
```

Reglas:

- Es una copia: el original en `~/.claude/projects/...` no se toca.
- Antes de copiar, muestra al usuario qué archivo se eligió (nombre y fecha de
  modificación). Si hay varios `.jsonl` con fechas cercanas y hay duda de cuál
  es la sesión actual, pregunta.
- `09_Conversaciones/` está en `.gitignore`: el `.jsonl` copiado **no se
  versiona** ni se sube a GitHub. No lo agregues con `git add -f`.
- Copia el `.jsonl` al final de la sesión, para que incluya lo más reciente de
  la conversación.
- Si no existe la carpeta de proyecto o no hay `.jsonl`, informa al usuario en
  vez de improvisar otra ruta.

## Cierre

Termina con un reporte corto: ruta de la bitácora, ruta del `.jsonl` copiado,
si hubo commit/push y qué quedó pendiente.
