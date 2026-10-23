---
name: registrar-sesion
description: Cierra una sesión de trabajo del Taller 2 — escribe la bitácora en 06_Bitacoras/ con el formato exigido por CLAUDE.md, actualiza HANDOFF.md (estado actual, dos a tres siguientes objetivos y registro de sesiones), hace commit y push de los cambios a la rama del integrante (nunca a main) y copia el registro crudo (.jsonl) de la conversación actual a 09_Conversaciones/ (carpeta ignorada por git). Usar cuando el usuario pida "cerrar sesión", "registrar la sesión", "escribir la bitácora", "actualizar el handoff" o "guardar la conversación".
---

# Registrar sesión de trabajo

Al terminar una sesión de trabajo en este taller, hace cuatro cosas en este
orden:

1. Escribir la bitácora de la sesión en `06_Bitacoras/`.
2. Actualizar `HANDOFF.md` (raíz del repo) a partir de esa bitácora.
3. Hacer commit y push de la sesión a la rama del integrante (nunca a `main`).
4. Copiar el registro crudo (`.jsonl`) de la conversación a `09_Conversaciones/`.

Básate solo en lo que ocurrió en la conversación. Confirma los archivos
afectados con `git status` / `git diff --stat` (y `git log` si hubo commits).
Si algo no es inferible con certeza (un supuesto, un resultado ambiguo, quién
del equipo trabajó en la sesión, cuáles deben ser los siguientes objetivos),
pregunta al usuario en vez de adivinar. Si el
usuario pide solo una de las partes, haz solo esa.

## Paso 1: bitácora

Antes de escribir, lee `HANDOFF.md` y las bitácoras previas en `06_Bitacoras/`
(si existen) para entender qué se hizo, qué quedó pendiente y mantener el
formato.

Nombre del archivo: `YYYY-MM-DD_slug-descriptivo.md` (minúsculas, guiones), con
la fecha real de la sesión. Si ya hay una bitácora del mismo día, agrega un
sufijo numérico (`_2`) o pregunta.

Estructura (la que exige `CLAUDE.md`):

```markdown
# Bitácora — YYYY-MM-DD: <descripción corta>

## Resumen
Objetivo de la sesión y desarrollo, en pocos párrafos. Indica cuáles de los
"Siguientes objetivos" que traía HANDOFF.md se cumplieron, cuáles avanzaron y
cuáles no se trabajaron.

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
sección alimenta los "Siguientes objetivos" de HANDOFF.md.
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
  descartó algo); el estado de avance se actualiza en `HANDOFF.md` (Paso 2).
- Sin código en la bitácora salvo que aporte a entender una decisión.

## Paso 2: actualizar `HANDOFF.md`

Sigue la sección "`HANDOFF.md`" de `CLAUDE.md`. Actualiza las tres secciones:

- **Siguientes objetivos:** reescríbela con **dos a tres** tareas concretas,
  en orden de prioridad. Cada una lleva el archivo que debe producirse, un
  criterio de terminado verificable y, si aplica, el integrante a cargo.
  - **Si existe el plan de implementación** (su ruta está en la sección
    "`HANDOFF.md`" de `CLAUDE.md`): toma los próximos pasos no terminados del
    plan, en su orden, y cita el número de paso en cada objetivo. Si la sesión
    cerró pasos del plan, márcalos como terminados en el plan también.
  - **Si no existe:** derívalos de "Pendientes" de la bitácora. Si hay
    varias opciones razonables, pregunta al usuario cuáles siguen.
  - Un objetivo que no se terminó se mantiene.
  - Actualiza la lista de bloqueos y preguntas abiertas debajo de los
    objetivos: quita los resueltos y agrega los nuevos.
- **Estado actual:** reescríbelo para reflejar qué existe y funciona hoy
  (datos, scripts, resultados). No es un historial.
- **Registro de sesiones:** agrega una entrada arriba (la más reciente
  primero), con este formato:

  ```markdown
  ### YYYY-MM-DD: <descripción corta>

  - <Integrante> (`<rama>`). Qué se hizo, en tres a cinco líneas; si hay plan,
    qué pasos avanzó o cerró. Si un objetivo no se terminó, qué avanzó y qué
    lo impidió.
  - Bitácora: [<archivo>.md](06_Bitacoras/<archivo>.md)
  - **Siguientes objetivos:** (1) ...; (2) ...; (3) ... (los mismos dos a tres
    de la sección de arriba, en una línea cada uno).
  ```

  No edites las entradas anteriores.

## Paso 3: commit y push a la rama del integrante

Sigue la sección "Flujo de versiones" de `CLAUDE.md`, donde está la tabla
integrante → rama. Cada integrante tiene su rama (p. ej. `SantiagoMunozM`), y
los cambios de la sesión se suben **solo** a esa rama. Nunca a `main`.

1. **Identificar la rama del integrante.** Compara `git branch --show-current`
   y `git config user.name` con la tabla de `CLAUDE.md`.
   - Si la rama actual es la del integrante, continúa.
   - Si la rama actual es `main`, **no hagas commit**. Si los cambios están sin
     commitear, cambia a la rama del integrante con `git switch <rama>` (los
     cambios sin commitear se trasladan) y continúa ahí. Si ya hay commits
     locales en `main` que no están en `origin/main`, detente y pregunta al
     usuario cómo moverlos.
   - Si la rama actual es la de otro integrante, o no es inferible quién
     trabajó, pregunta antes de seguir.
2. **Revisar qué entra al commit.** Muestra `git status --short` y
   `git diff --stat`. Agrega los archivos de la sesión por nombre (no
   `git add -A` a ciegas):
   - Sí se versionan: la bitácora, `HANDOFF.md`, los scripts, `CLAUDE.md`, el README, los
     recursos de `07_Recursos/` y los datos y resultados que generan los
     scripts (p. ej. los `.Rds` de `01_Datos/02_Procesados/` y `03_Listos/`, y
     las tablas y figuras de `03_Resultados/`). Revisa en `git status` que no
     haya archivos de datos o resultados sin seguimiento.
   - No se versionan: nada de `09_Conversaciones/` (está en `.gitignore`; no
     uses `git add -f`), ni archivos temporales o de sesión de RStudio. Los
     datos crudos de `01_Datos/01_Crudos/` nunca se modifican.
   - Si aparecen archivos modificados que no son de esta sesión, o archivos
     pesados o sensibles, pregunta antes de incluirlos.
3. **Commit.** Mensaje en español, en imperativo, que resuma la sesión (p. ej.
   "Crear 00_main.R con pacman y verificación de carpetas"), con el cuerpo
   apuntando a la bitácora (`Bitácora: 06_Bitacoras/<archivo>.md`).
4. **Push a la rama del integrante:** `git push origin <rama>`; usa
   `git push -u origin <rama>` si la rama local no sigue todavía a la remota.
   - Si el push es rechazado porque la rama remota avanzó, haz
     `git pull --no-rebase origin <rama>`, resuelve con el usuario cualquier
     conflicto y vuelve a intentar. Nunca uses `--force`.
   - **Nunca** `git push origin main`, ni push de la rama del integrante hacia
     `main` (`<rama>:main`), ni merge a `main`. Llevar los cambios a `main` es
     decisión del integrante y se hace aparte, solo si lo pide.
5. Si el usuario pidió explícitamente no versionar, omite este paso y dilo en
   el cierre.

## Paso 4: copiar el `.jsonl` de la conversación

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
el hash y mensaje del commit, la rama a la que se hizo push (o por qué no se
hizo) y los dos a tres siguientes objetivos que quedaron en `HANDOFF.md`. Si el integrante quiere llevar los cambios a
`main`, recuérdale que se hace aparte, con un pull request desde su rama.
