# CLAUDE.md: reglas del proyecto

## Contexto del proyecto

Taller 2 de Ciencia de Datos y Econometría Aplicada (ECON-3785, 2026-2, Universidad
de los Andes). Cliente ficticio: CheMarket Inc., empresa de comercio electrónico.
Es la continuación del Taller 1 (repositorio `taller1/`, carpeta hermana de este
proyecto).

- **Objetivo del curso para este taller:** es la continuación de un informe de
  consultoría y aplica los conceptos de las semanas 5 a 8. En particular, la
  exploración de relaciones no lineales y la estimación de efectos
  heterogéneos mediante árboles de regresión.
- **Pregunta del taller:** ¿cambian las conclusiones del Taller 1 cuando se usan
  métodos más flexibles (basados en árboles), capaces de representar relaciones
  no lineales, interacciones y diferencias entre grupos de usuarios? La mesa
  directiva quiere saber qué cambia, qué se mantiene y qué nuevas implicaciones
  surgen para CheMarket.
- **Pregunta de negocio de fondo (heredada):** ¿debería CheMarket invertir en
  impulsar el registro (`sign_up`) de sus usuarios para aumentar sus ingresos
  (`Revenue`)?
- **Dos fuentes de datos**, las mismas del Taller 1, con roles distintos y no
  intercambiables:
  - `observacional.Rds`: datos históricos del comportamiento de los usuarios. Permite
    describir/predecir, pero no identifica el efecto causal de aumentar el registro.
  - `experimento.Rds`: prueba A/B con asignación aleatoria a `easier_signup`
    (registro facilitado). Permite estimar el efecto causal de esa intervención.
- Hay que ser explícitos, como en el Taller 1, sobre qué conclusiones se pueden
  extraer de cada base y cuáles no.
- **El Taller 2 no es una colección de modelos nuevos.** Su objetivo es evaluar
  qué cambia en las conclusiones del Taller 1 al modificar **dos cosas a la vez**:
  la forma funcional de la variable dependiente (`ln(Revenue)` en lugar de
  `Revenue`) y el método (árboles en lugar de regresión lineal). Siempre hay que
  distinguir si una diferencia viene de la transformación, del método, o de ambos.
- **Entregables finales** (ver "Entregas y fechas"): (1) el video de la
  presentación al cliente más los slides usados, en `08_Entregables/`, sin
  código y estilo *answer-first* (ver "Entregable: presentación al cliente");
  (2) el material de soporte, es decir, este repositorio reproducible.

### Entregas y fechas (instrucciones generales del curso)

Los enlaces de entrega están en Bloque Neón; el enunciado está en
`07_Recursos/Problem_Set_2.pdf`.

| Entrega                                         | Qué se sube                                                                         | Fecha límite              |
| ----------------------------------------------- | ----------------------------------------------------------------------------------- | ------------------------- |
| Cambios en la conformación del grupo            | Aviso al equipo docente (solo si hubo cambios)                                      | Viernes 16 de octubre (vencida) |
| Vídeo                                           | Los slides usados y un enlace al video (OneDrive, YouTube, Dropbox, etc.)           | Domingo 25 de octubre     |
| Material de soporte                             | El repositorio reproducible (README, scripts, resultados, registro de conversaciones) | Domingo 25 de octubre     |
| Vídeo para retroalimentación de pares           | El mismo video, en el enlace de pares                                               | Domingo 25 de octubre     |
| Retroalimentación a compañeros                  | Comentarios a los videos asignados (7 días hábiles)                                 | Martes 3 de noviembre     |
| Lectura de los comentarios recibidos            | —                                                                                   | Miércoles 4 de noviembre  |

- Las tres entregas del equipo vencen el **mismo día (domingo 25 de
  octubre)**. Planear el trabajo hacia atrás desde esa fecha: el video debe
  grabarse con las figuras y tablas ya finales y regeneradas por `00_main.R`.
- La retroalimentación de pares y la lectura de comentarios son posteriores a
  la entrega y no afectan el repositorio.

### Parte A: predicción (base observacional)

Variable dependiente: `ln(Revenue)`. Preguntas que la presentación debe poder responder:

- ¿Qué variables resultan más útiles para predecir `ln(Revenue)`?
- ¿Qué relaciones o patrones aparecen con los métodos basados en árboles?
- ¿Cómo se compara su desempeño predictivo con el de los modelos lineales?
- ¿Qué cambia en el análisis al usar `ln(Revenue)` en lugar de `Revenue`?
- ¿Qué conclusiones del Taller 1 se mantienen y cuáles cambian?

### Parte B: heterogeneidad del efecto (experimento)

Variable dependiente: `ln(Revenue)`; tratamiento: `easier_signup`. Métodos causales
basados en árboles. Además del ATE, se analizan los CATE y la evidencia de HTE.
Preguntas:

- ¿Cambia el ATE y su interpretación si se usa `ln(Revenue)` en lugar de `Revenue`?
- ¿Existe evidencia de heterogeneidad en los efectos del tratamiento (HTE)?
- ¿Cómo varían los CATE entre usuarios con distintas características?
- ¿Qué características permiten identificar grupos con efectos diferentes?
- ¿Hay grupos con efecto sustancialmente mayor, menor o cercano a cero?
- ¿Cómo se relaciona la heterogeneidad con el efecto promedio del Taller 1?
- ¿Qué implicaciones tiene esto para la decisión de CheMarket?

### Estructura sugerida del análisis (del enunciado)

1. Recordar el punto de partida (qué se aprendió en el Taller 1).
2. Evaluar qué cambia con la forma funcional (`ln(Revenue)` vs. `Revenue`).
3. Evaluar qué agregan los métodos basados en árboles (no linealidades,
   interacciones, heterogeneidad).
4. Contrastar la evidencia: qué se mantiene, qué se matiza y qué cambia, y si la
   diferencia se asocia a la transformación, al método o a ambos.
5. Integrar los hallazgos: implicaciones para CheMarket, separando conclusiones
   bien respaldadas de resultados que aún requieren evidencia.

## Estructura del proyecto

- `01_Datos/01_Crudos/`      datos originales. NUNCA se modifican
- `01_Datos/02_Procesados/`  datos limpios o transformados
- `01_Datos/03_Listos/`      bases finales que ingresan al análisis
- `02_Scripts/`              scripts de R
- `03_Resultados/`           Tablas/ y Figuras/ generadas, cada una con una subcarpeta por script (ver "Una carpeta de resultados por script")
- `04_Presentaciones/`       borradores de la presentación
- `05_Notas/`                notas de hallazgos: un `.md` por hallazgo principal, con
  referencia a sus tablas/figuras (ver "Notas de hallazgos")
- `06_Bitacoras/`            documentación de cada sesión de trabajo
- `07_Recursos/`             referencias externas y documentación (aquí está el
  enunciado, `Problem_Set_2.pdf`; la retroalimentación del Taller 1, en los PDF
  `Comentarios para ...`; las heurísticas derivadas de ella,
  `heuristicas_retroalimentacion_taller1.md`; y el catálogo de métodos,
  librerías y funciones permitidos, `catalogo_metodos.md`)
- `08_Entregables/`          presentación final y video
- `09_Conversaciones/`       registro crudo (`.jsonl`) de las conversaciones con los agentes; en `.gitignore`, no se versiona (cada integrante guarda las suyas localmente; al final se unen por aparte)
- `.claude/skills/`          skills del proyecto (`bitacora-sesion`, `cerrar-sesion`, `registrar-hallazgo`)
- `00_main.R`                (raíz) script maestro: corre todo el pipeline
- `HANDOFF.md`               (raíz) estado actual, siguientes objetivos y registro de sesiones
- `taller_02.Rproj`          proyecto de RStudio (raíz del proyecto)

## Reglas de trabajo

- Lenguaje principal: R. Utilice `tidyverse` cuando resulte apropiado.
- Explique lo que va a hacer ANTES de editar o crear archivos.
- Utilice rutas relativas ancladas a la carpeta del proyecto.
- Redacte los comentarios del código en español.
- **Semilla:** `set.seed(2026)` en cualquier análisis con componente aleatorio
  (partición muestral, validación cruzada, bosques aleatorios, bosques causales,
  submuestreo, etc.). Es requisito explícito del enunciado.
- **Evaluación fuera de muestra:** el desempeño predictivo se evalúa siempre
  fuera de muestra (train/test o validación cruzada), nunca dentro de muestra.
  La selección de hiperparámetros (profundidad, poda, número de árboles, etc.)
  se hace solo con datos de entrenamiento; el conjunto de prueba se toca una
  vez, al final.
- **Comparabilidad con el Taller 1:** para que la comparación sea limpia, la
  partición train/test, la métrica y la referencia ingenua deben ser definidas
  de forma explícita y, cuando se compare con el Taller 1, equivalentes a las de
  allá (80/20, semilla 2026, RMSE). Si algo se cambia, se registra en
  "Decisiones tomadas".
- Al cerrar una sesión, registre la sesión con la skill `bitacora-sesion` y
  después ciérrela con `cerrar-sesion` (commit, push y conversación; ver
  "Registro de sesión de trabajo").
- **Heurísticas de la retroalimentación del Taller 1:** antes de (i) definir un
  estimando o una especificación, (ii) diseñar la estadística descriptiva,
  (iii) evaluar o interpretar un modelo predictivo o causal, (iv) validar el
  experimento, o (v) redactar conclusiones, recomendaciones o diapositivas, lea
  `07_Recursos/heuristicas_retroalimentacion_taller1.md` y aplique las
  heurísticas pertinentes (H1–H11). Use su lista de chequeo antes de dar por
  cerrado un análisis o una diapositiva. Si una decisión se aparta de una
  heurística, regístrelo en "Decisiones tomadas" con la razón.

### Reproducibilidad y salidas (retroalimentación del Taller 1)

El repositorio del Taller 1 obtuvo 100/100, pero el profesor pidió tres mejoras
explícitas para este taller. Son obligatorias:

- **`00_main.R` instala y carga todos los paquetes con `pacman`, una sola
  vez.** No se pide al usuario instalar librerías a mano. La lista única de
  paquetes del proyecto vive en el `pacman::p_load()` de `00_main.R`:

  ```r
  if (!require("pacman")) install.packages("pacman")
  pacman::p_load(tidyverse, ...)
  ```

  Los scripts de `02_Scripts/` **no** cargan paquetes (ni `library()` ni
  `p_load()`); en su lugar llevan el comentario
  `# los paquetes los carga 00_main.R con pacman`. Si un script nuevo
  necesita otro paquete, se agrega a ese `p_load()` con un comentario de para
  qué se usa. Para correr un script suelto (p. ej. al depurar), primero se
  ejecutan las secciones 1 a 3 de `00_main.R`. El README debe decir que basta
  con correr `00_main.R`.
- **`00_main.R` verifica las carpetas de salida una sola vez, al comienzo.**
  Borrar `03_Resultados/` (o cualquiera de sus subcarpetas) y correr
  `00_main.R` debe regenerar todo sin errores. Para eso, antes de ejecutar
  cualquier script, `00_main.R` recorre una lista única de carpetas de salida
  y crea las que falten:

  ```r
  carpetas_salida <- c(
    "01_Datos/02_Procesados", "01_Datos/03_Listos",
    "03_Resultados/Tablas", "03_Resultados/Figuras"
  )
  for (carpeta in carpetas_salida) {
    if (!dir.exists(carpeta)) dir.create(carpeta, recursive = TRUE)
  }
  ```

  La verificación vive **solo** en `00_main.R`: las funciones auxiliares
  (`guardar_figura()`, `guardar_tabla()`) y los scripts de análisis **no**
  llaman a `dir.create()`. Si un script nuevo escribe en una carpeta que no
  está en la lista, se agrega la carpeta a `carpetas_salida` en `00_main.R`.
  `01_Datos/01_Crudos/` no va en la lista: no es una salida y nunca se escribe
  en ella.
- **Una carpeta de resultados por script.** Todo script que genere al menos
  una figura o tabla guarda sus salidas en su propia subcarpeta, con el nombre
  del script sin `.R`: `03_Resultados/Figuras/<script>/` y
  `03_Resultados/Tablas/<script>/` (p. ej.
  `03_Resultados/Figuras/03_punto_partida/observacional_revenue_tiempo_sesion.png`).
  Así cada archivo se rastrea a su script por la ruta. Reglas:
  - El script define `carpeta_salida <- "<nombre_del_script>"` al comienzo y
    la pasa a `guardar_figura(nombre, grafica, carpeta)` y
    `guardar_tabla(nombre, tabla, datos, carpeta)`; no escribe en la raíz de
    `Figuras/` ni de `Tablas/`. Lo mismo vale para los `.csv` que se escriben
    con `write_csv()` (p. ej. los reportes de calidad de `01_`).
  - Cada subcarpeta se agrega a `carpetas_salida` en `00_main.R` en la misma
    sesión en que se crea el script (las funciones y los scripts no llaman a
    `dir.create()`).
  - Si se renombra un script, se renombra su subcarpeta (con `git mv`) y se
    actualizan `00_main.R`, el README y las notas de `05_Notas/` que citen sus
    rutas. Los scripts de formato (`00_formato_*.R`) no tienen subcarpeta: no
    generan resultados.
  - Si dos scripts producen una misma figura o tabla, solo uno la genera; el
    otro la lee.
- **Las tablas se exportan en el formato final de la diapositiva.** En el
  Taller 1 las tablas de las diapositivas no eran las exportadas (se cambiaron a
  mano colores de encabezado, decimales, etc.). Ahora la tabla que entra a la
  presentación sale tal cual del código: encabezados, decimales, etiquetas en
  español, notas al pie y colores incluidos. No se reformatean tablas fuera de
  R ni se pegan pantallazos de la consola.
- **`00_main.R` es el único punto de entrada.** Vive en la raíz del proyecto
  y sigue la estructura del Taller 1: (1) verifica que el directorio de trabajo
  es la raíz (`taller_02.Rproj`); (2) carga los paquetes con `pacman`;
  (3) verifica las carpetas de salida; (4) lista los scripts en el orden de su
  numeración; (5) ejecuta cada uno con `source(script, local = new.env(),
  encoding = "UTF-8")`. Regenera todos los datos procesados, tablas y figuras
  que usa la presentación. Cada script nuevo se agrega a la lista `scripts`
  en la misma sesión en que se crea. Los scripts de formato
  (`00_formato_*.R`) no van en la lista: los cargan con `source()` los scripts
  que los usan.

#### Formato de las tablas

Igual que con las figuras, el formato de las tablas vive en un único lugar:
`02_Scripts/00_formato_tablas.R` (**pendiente: crearlo**; elegir el paquete,
p. ej. `gt`, y registrarlo en "Decisiones tomadas"). Ese script no genera
tablas, solo define el estilo y la función de exportación (p. ej.
`guardar_tabla()`).

- Todo script que produzca tablas para la presentación empieza con
  `source("02_Scripts/00_formato_tablas.R")` y exporta con `guardar_tabla()`.
  No se redefine el estilo dentro de un script de análisis.
- Estilo coherente con las figuras: encabezados con la paleta del proyecto
  (`00_formato_graficas.R`), texto en español y sin nombres de variables del
  código, número de decimales fijo por tipo de cifra, unidades explícitas
  (dólares, log, %) y una nota que declare la base (experimento u
  observacional), el `n` y si las cifras son de entrenamiento o de prueba. En
  las tablas de regresión que ya muestran las observaciones por columna, la
  nota no repite el `n` (`nota_tabla(base, NULL, ...)`).
- Se exporta en un formato que se inserta directamente en las diapositivas
  (p. ej. `.png` de alta resolución o `.html`), y además en `.csv` con las
  cifras sin formato, para trazabilidad.
- **Nombres de archivo:** `03_Resultados/Tablas/<script>/<base>_<contenido>.<ext>`
  (la subcarpeta `<script>` es la de "Una carpeta de resultados por script"), con
  la misma convención que las figuras (p. ej.
  `observacional_rmse_escalonado.png`, `experimento_balance.png`).

#### README

Se mantiene lo que obtuvo el puntaje completo en el Taller 1: objetivo del
proyecto, estructura de carpetas, instrucciones de ejecución (solo
`00_main.R`, con `pacman` instalando lo necesario) y un **mapa completo
script → tablas/figuras**, de forma que cada elemento de las diapositivas se
pueda rastrear al script que lo genera. El README se actualiza en la misma
sesión en que se agrega o renombra un script o un resultado.

### Flujo de versiones: una rama por integrante (obligatorio para los agentes)

Repositorio: `https://github.com/talleres-ECON3785/taller_02`. Cada integrante
tiene su propia rama, creada desde `main`, con la convención nombre + primer
apellido + inicial del segundo (la misma de los correos de Uniandes):

| Integrante                | Rama                |
| ------------------------- | ------------------- |
| Samuel Escandón           | `SamuelEscandonC`   |
| Douglas Plazas Guzmán     | `DouglasPlazasG`    |
| Mateo Olmos Becerra       | `MateoOlmosB`       |
| Santiago Muñoz Martínez   | `SantiagoMunozM`    |

Reglas que los agentes siguen **siempre**, sin excepción:

1. **Al empezar la sesión, identificar la rama del integrante.** Revisar
   `git branch --show-current` y `git config user.name`. Si el agente está en
   `main` o en la rama de otro integrante, cambia a la rama de quien trabaja
   (`git switch <rama>`) antes de editar cualquier archivo. Si no es inferible
   con certeza quién trabaja, pregunta; no adivina.
2. **Sincronizar con `main` al empezar:** `git fetch origin` y, si `main`
   avanzó, traer sus cambios a la rama del integrante (`git merge origin/main`)
   antes de trabajar, para reducir conflictos. Si hay conflictos, se muestran al
   usuario y se resuelven con él.
3. **Todo el trabajo se hace, se commitea y se empuja en la rama del
   integrante** (`git push origin <rama>`). La skill `cerrar-sesion` hace
   este commit y push al cerrar cada sesión.
4. **Nunca commitear ni hacer push directamente a `main`.** Llevar los cambios
   a `main` es una decisión del integrante, no del agente: se hace solo cuando el
   usuario lo pide explícitamente, preferiblemente con un pull request desde su
   rama (`gh pr create --base main --head <rama>`), después de sincronizar la
   rama con `main` y de comprobar que `00_main.R` corre sin errores.
5. No crear ramas adicionales por tarea ni trabajar en la rama de otro
   integrante sin que el usuario lo pida.

### Registro de sesión de trabajo

- Cada sesión de trabajo debe quedar documentada en un archivo `.md` en
  `06_Bitacoras/` y sus cambios versionarse en la rama del integrante (ver
  "Flujo de versiones").
  Nombre: `YYYY-MM-DD_slug-descriptivo.md`.
- Estructura de cada bitácora:
  - **Resumen:** objetivo y desarrollo de la sesión, al inicio.
  - **Archivos:** lista de archivos creados, modificados y eliminados.
  - **Detalle por archivo:** explicación de los cambios en cada archivo
    involucrado, con las decisiones de implementación, los supuestos usados y la
    intuición en lenguaje natural de cada decisión.
  - Para las variables que construyen los estimadores (p. ej. el criterio de
    partición, los pesos o la estimación del efecto en una hoja), explicar cada
    una por aparte y a detalle: citar la página o sección del recurso de donde
    se obtiene (`07_Recursos/`), cómo se calcula y qué rol cumple dentro de la
    fórmula que compone.
  - **Resultados nuevos (tablas, figuras, gráficos):** para cada uno, qué busca
    comunicar, cómo se generan los datos que lo alimentan y qué rol cumple
    dentro del taller. Se omite si la sesión no generó resultados.
  - **Pendientes:** lo que quedó sin hacer, los supuestos sin confirmar y el
    siguiente paso.
- Las bitácoras son el insumo de las sesiones posteriores: deben permitir
  entender qué ya se hizo y qué quedó pendiente, para mantener un desarrollo
  coherente del taller. Consúltelas cuando necesite el detalle de una sesión
  (el punto de entrada es `HANDOFF.md`).
- Las decisiones metodológicas relevantes también se registran en las tablas
  "Decisiones tomadas" / "Análisis descartados" de este archivo, y se actualiza
  `HANDOFF.md`.

### `HANDOFF.md`: resumen orientado a lo que sigue

`HANDOFF.md` (raíz) resume las bitácoras para retomar el trabajo sin leerlas
todas. Las bitácoras explican el porqué; el handoff dice dónde estamos y qué
sigue.

- **Al iniciar una sesión:** después de ubicarse en la rama del integrante (ver
  "Flujo de versiones"), lea `HANDOFF.md` antes que cualquier otro archivo y
  proponga trabajar en el primero de sus "Siguientes objetivos" que no esté
  asignado a otro integrante, salvo que el usuario indique otra cosa.
- **Al cerrar una sesión** (lo hace la skill `bitacora-sesion`), después de
  escribir la bitácora, actualice las tres secciones:
  - **Siguientes objetivos:** se reescribe con **dos a tres** tareas concretas,
    en orden de prioridad. Cada una lleva el archivo que debe producirse, un
    criterio de terminado verificable y, si aplica, el integrante a cargo.
    Debajo van los bloqueos o preguntas abiertas para el equipo. Si un objetivo
    no se terminó, se mantiene y se anota en el registro qué avanzó y qué lo
    impidió.
  - **Estado actual:** se reescribe para reflejar qué existe y funciona hoy
    (datos, scripts, resultados). No es un historial.
  - **Registro de sesiones:** se agrega una entrada arriba (la más reciente
    primero), de tres a cinco líneas: quién trabajó y en qué rama, qué se hizo,
    el enlace a la bitácora y, al final, los **dos a tres siguientes
    objetivos** que quedaron al cerrar. Las entradas anteriores no se editan.
- **Plan de implementación:** el plan del proyecto completo está en
  `PLAN.md` (raíz), organizado en hitos H0–H7 con tareas numeradas (`Pk.n`) y
  casillas de verificación. Los "Siguientes objetivos" se derivan
  automáticamente de los próximos pasos sin marcar del plan, citando el número
  de paso, y el registro de cada sesión indica qué pasos del plan avanzó o
  cerró. Las casillas se marcan `[x]` en la misma sesión en que se termina la
  tarea.
- **Conflictos entre ramas:** como cada integrante actualiza `HANDOFF.md` en su
  rama, al traer `main` pueden chocar las entradas del registro. Se resuelven
  conservando todas las entradas, ordenadas por fecha, y reescribiendo
  "Siguientes objetivos" y "Estado actual" para que reflejen el trabajo
  combinado.

### Notas de hallazgos (`05_Notas/`)

`05_Notas/` es la memoria analítica del taller: recopila **qué se encontró y por
qué importa**, mientras que las bitácoras (`06_Bitacoras/`) registran **qué se
hizo en cada sesión**. Quien arme la presentación debe poder leer solo las notas
y reconstruir los mensajes principales.

- **Una nota por hallazgo principal**, no por sesión. Un hallazgo es un
  resultado que sostiene (o matiza, o contradice) una conclusión del taller.
  Nombre: `<parte>_<slug>.md` (p. ej. `A_quiebre_time_spent.md`,
  `B_evidencia_hte.md`), con `<parte>` = `A`, `B` o `X` (transversal, p. ej.
  qué cambia por la transformación vs. por el método).
- **Las notas se agrupan por el script del que se derivan:**
  `05_Notas/<script>/<parte>_<slug>.md` (p. ej.
  `05_Notas/03_punto_partida/A_quiebre_time_spent.md`). Una nota solo habla de lo
  que se sabe con los resultados de su script; si otro script matiza o cambia el
  hallazgo (p. ej. el análisis en `ln(Revenue)`), se registra en la subcarpeta de
  ese script y se enlaza. Cada nota declara su "Script de origen".
- **Una nota se crea o actualiza en la misma sesión en que el resultado que la
  sostiene se genera o cambia.** No se espera al cierre ni a la presentación.
- **Estructura de cada nota:**

  ```markdown
  # <Hallazgo, enunciado como conclusión>

  - **Estado:** vigente | matizado | reemplazado (con enlace a la nota que lo reemplaza)
  - **Parte / base:** A o B; observacional o experimento; descriptivo, predictivo o causal
  - **Script de origen:** `02_Scripts/<script>.R`
  - **Última verificación:** YYYY-MM-DD, con el script que lo genera

  ## Evidencia
  Referencias a una o más tablas/figuras en `03_Resultados/` (ruta exacta,
  p. ej. `03_Resultados/Figuras/observacional_importancia_variables.png`) y el
  script de `02_Scripts/` que las produce. Las cifras clave se citan con su
  escala (`ln(Revenue)` o `Revenue`), `n` y si son de entrenamiento o prueba.

  ## Qué dice, en lenguaje intuitivo
  Explicación para alguien sin formación técnica: qué muestra la figura o la
  tabla, cómo leerla y qué significa en el negocio. Distinguir estimando,
  estimador y estimación; separar lo predictivo/descriptivo de lo causal.

  ## Por qué importa en el estudio
  Qué pregunta del taller responde (Parte A o B), con qué conclusión del Taller 1
  se conecta (se mantiene, se matiza o cambia) y si la diferencia se asocia a la
  transformación, al método o a ambos. Qué implica para la decisión de CheMarket.

  ## Límites e incertidumbre
  Qué no permite afirmar (p. ej. predicción no es causalidad), intervalos o
  variabilidad, y qué evidencia adicional haría falta.

  ## Historial
  Una línea por cambio de estado o de cifras: fecha, qué cambió y por qué.
  ```

- Las notas siguen las reglas de redacción del proyecto: sin juicios de "bueno"
  o "malo", sin entusiasmo por métricas ni significancia, sin código, y con las
  heurísticas H1–H11 aplicadas. Solo se cita lo que está en `03_Resultados/`:
  una cifra sin archivo de respaldo no entra a una nota.
- `05_Notas/README.md` es el índice: una línea por nota con su estado y la
  pregunta del taller que responde. Se actualiza cada vez que se crea o cambia el
  estado de una nota.

#### Contrastar la evidencia nueva con lo ya registrado

Cada vez que un resultado nuevo se genera o se modifica (un script nuevo, un
cambio de especificación, una corrida distinta de `00_main.R`), el agente, antes
de darlo por cerrado:

1. **Lee `05_Notas/README.md` y las notas relacionadas**, y los puntos de partida
   de "Punto de partida: resultados del Taller 1".
2. **Contrasta** el resultado nuevo con lo que ya dicen las notas y con el Taller 1:
   misma dirección y orden de magnitud, misma escala, mismas conclusiones.
3. **Si todo es consistente**, actualiza "Última verificación" de la nota y lo
   deja en el historial.
4. **Si algo es contradictorio, alerta al usuario de inmediato**, sin esperar al
   cierre de sesión y sin resolverlo en silencio. La alerta indica: (i) qué nota
   o resultado previo se contradice (con la ruta), (ii) las cifras de ambos lados
   con su escala y base, (iii) hipótesis de la causa, distinguiendo si viene de
   la transformación, del método, de la partición/semilla, de un error de
   código o de datos distintos, y (iv) qué verificar para resolverlo.
5. **Mientras el usuario no decida**, no se sobrescribe la nota anterior: se marca
   su estado como `matizado` o `reemplazado` solo con su confirmación, se deja la
   evidencia nueva en una nota propia o en el historial, y se registra la
   decisión en "Decisiones tomadas" si cambia una conclusión.
6. **Una diferencia con el Taller 1 no es una contradicción**: es lo que el taller
   quiere medir. Se reporta como "cambia" en la nota, atribuida a la
   transformación, al método o a ambos. La alerta es para inconsistencias dentro
   del Taller 2 o diferencias con el Taller 1 que no tienen una explicación
   atribuible.

La skill `registrar-hallazgo` (`.claude/skills/registrar-hallazgo/SKILL.md`)
implementa este procedimiento: se invoca al generar o cambiar un resultado, y
`bitacora-sesion` verifica al registrar la sesión que cada resultado nuevo tenga su nota.

### Skills de cierre de sesión: `bitacora-sesion` y `cerrar-sesion`

El cierre se divide en dos skills, que se corren en este orden. Las dos
preguntan al usuario cuando algo no es inferible con certeza (p. ej. quién del
equipo trabajó en la sesión) en vez de adivinar.

1. **`bitacora-sesion`** (`.claude/skills/bitacora-sesion/SKILL.md`). Se invoca
   al terminar una sesión (pidiendo "registrar la sesión", "escribir la
   bitácora" o "actualizar el handoff"). Usa el modelo de la sesión, porque
   requiere juicio y el historial de la conversación. Hace tres cosas:
   - Escribe la bitácora de la sesión en `06_Bitacoras/` con la estructura de
     arriba. Para ubicarse lee `HANDOFF.md` y solo la última bitácora; abre
     otras únicamente si necesita más contexto.
   - Verifica que cada resultado nuevo tenga su nota en `05_Notas/` (invoca
     `registrar-hallazgo` si falta).
   - Actualiza `HANDOFF.md`: siguientes objetivos (dos a tres, del plan de
     implementación cuando exista), estado actual y una entrada nueva en el
     registro de sesiones (ver "`HANDOFF.md`").

   Al terminar, indica que el siguiente paso es `cerrar-sesion`; no hace commit.
2. **`cerrar-sesion`** (`.claude/skills/cerrar-sesion/SKILL.md`). Se invoca
   después de la anterior (pidiendo "cerrar sesión", "hacer el commit", "subir
   los cambios" o "guardar la conversación"). Es mecánica y corre con
   `model: haiku` en su frontmatter. Hace dos cosas:
   - Hace commit de la bitácora y de los cambios de la sesión, y push **a la
     rama del integrante**, nunca a `main` (ver "Flujo de versiones").
   - Copia el registro crudo (`.jsonl`) de la conversación a
     `09_Conversaciones/`. Esa carpeta está en `.gitignore`: las conversaciones
     se guardan localmente y **no se suben a GitHub**.

**Cómo se entregan las conversaciones:** cada integrante acumula sus `.jsonl` en
su copia local de `09_Conversaciones/`. Al final del taller, el equipo las une
por aparte, fuera del flujo de git, para entregarlas con el material de
soporte (la rúbrica del Taller 1 asigna puntos por incluir el registro de la
conversación en `.json`). Los agentes no deben versionar esa carpeta, quitarla
del `.gitignore` ni intentar unir las conversaciones de otros integrantes.

## Regla metodológica: regresión lineal como referencia, árboles como extensión

- A diferencia del Taller 1, **este taller sí exige métodos basados en árboles**:
  árboles de regresión y/o ensambles (bagging, bosques aleatorios) para la
  Parte A, y métodos causales basados en árboles (bosques causales) para la
  Parte B.
- **Catálogo cerrado de métodos:** el trabajo se limita a los métodos,
  librerías y funciones de `07_Recursos/catalogo_metodos.md`, recopilados de
  los laboratorios del curso: regresión lineal (`lm`, `sandwich`, `fixest`,
  validación cruzada con `caret`), LASSO (`glmnet`), árboles de regresión
  (`rpart`, `rpart.plot`), bagging y bosques aleatorios (`ranger`) y bosques
  causales (`grf`). El árbol causal individual no se usa (ver "Análisis
  descartados"). Lea ese documento antes de escribir un script de
  estimación y use las funciones y convenciones que ahí se fijan.
- **Ampliar el catálogo:** si en algún punto se decide agregar otro método,
  paquete o función (incluidas las "herramientas previstas" que el catálogo
  marca como no cubiertas en los laboratorios), se documenta **antes de
  usarlo** en la sección "Registro de ampliaciones" de
  `07_Recursos/catalogo_metodos.md` y se registra en "Decisiones tomadas".
  Sin ese registro, no se usa.
- La regresión lineal del Taller 1 se mantiene como **modelo de referencia**
  (benchmark) en ambas partes: toda mejora predictiva o hallazgo de
  heterogeneidad se reporta contra ella.
- No proponga ni ajuste familias de modelos ajenas al enfoque del enunciado
  (redes neuronales, SVM, matching, boosting, etc.) sin autorización del
  equipo. Dentro del catálogo, la elección concreta de qué métodos entran a
  cada parte se registra en "Decisiones tomadas" con su justificación.
- Distinga siempre tres cosas al reportar un resultado: el **estimando** (lo que
  se quiere conocer: p. ej. el ATE o el CATE(x) sobre `ln(Revenue)`), el
  **estimador** (la regresión lineal, el árbol, el bosque causal) y la
  **estimación** (el número obtenido).
- **Predicción no es causalidad.** En la base observacional los árboles solo
  predicen y describen patrones; la importancia de variables y las particiones
  no son efectos causales. Solo el experimento sostiene afirmaciones causales, y
  los CATE son estimaciones de efectos causales condicionales, no descripciones.
- **Importancia de variables:** no es un efecto ni una medida de relevancia
  causal; solo indica cuánto usa el modelo cada variable para predecir.
- **Heterogeneidad (Parte B):** que un método encuentre grupos no prueba que
  haya HTE. Antes de afirmar heterogeneidad hay que evaluarla con evidencia
  formal (p. ej. muestras separadas para construir y para estimar los efectos,
  o pruebas de calibración), y declarar la incertidumbre de cada CATE
  (intervalos). Cuidado con el sobreajuste y con la multiplicidad de
  comparaciones entre subgrupos.
- **`ln(Revenue)` vs. `Revenue`:** los coeficientes y efectos en logaritmo se
  leen como cambios porcentuales aproximados, no en dólares. Al comparar con el
  Taller 1, aclare siempre en qué escala está cada número, y no compare RMSE de
  modelos con distinta variable dependiente como si fueran comparables
  directamente (el RMSE en `ln(Revenue)` y en `Revenue` tienen unidades
  distintas).

## Datos

- El flujo es Crudos, Procesados, Listos. Nunca en sentido inverso.
- Reporte siempre cuántas observaciones se pierden al limpiar o filtrar.
- Son las mismas bases del Taller 1. Ahí los archivos crudos se llaman
  `datos_historicos.Rds` (100,000 obs.) y `datos_experimento.Rds` (10,000 obs.),
  no `observacional.Rds`/`experimento.Rds` como dice el enunciado.
  **Pendiente:** copiarlos a `01_Datos/01_Crudos/` y confirmar los nombres.
- `ln(Revenue)` requiere `Revenue > 0`; verificar y documentar qué pasa con
  valores cero o negativos (el Taller 1 construyó `log_revenue`; revisar allí la
  convención usada y mantenerla).

## Formato de las gráficas

Se mantiene el formato del Taller 1 para que las figuras de ambos talleres se
vean como una sola familia. El formato debe vivir en un único lugar,
`02_Scripts/00_formato_graficas.R` (**pendiente: copiarlo desde el Taller 1**);
ese script no genera figuras, solo define paleta, tema y exportación.

- **Regla:** cualquier script que produzca figuras debe empezar con
  `source("02_Scripts/00_formato_graficas.R")` y usar lo que ahí se define.
  No redefina colores, temas ni tamaños dentro de un script de análisis: si
  algo del formato debe cambiar, cámbielo en `00_formato_graficas.R` para que
  el cambio aplique a todas las figuras a la vez.
- **Paleta:** `paleta_categorica`, terna sobria de azul (`#2B5FA3`), ocre
  (`#B8863B`) y verde-azulado (`#0E8A6C`), distinguibles entre sí incluso con
  daltonismo. Los grises (`gris_texto`, `gris_secundario`, `gris_nota`,
  `gris_grilla`) son estructura, no categorías. Una misma categoría conserva su
  color entre bases y entre talleres (p. ej. "No registrado" azul y "Registrado"
  ocre).
- **Tema:** `tema_presentacion` (más `tema_paneles` si la gráfica usa facetas).
- **Título:** describe qué muestra la figura, en español y sin tecnicismos del
  código (no se nombran variables como `Revenue` o `sign_up`). La regla de
  "el título comunica la conclusión" aplica a los títulos de las diapositivas,
  no a los de las figuras.
- **Subtítulo:** declara siempre de qué base viene la figura, usando
  `subtitulo_experimento` o `subtitulo_observacional`. Las dos bases no permiten
  afirmar lo mismo, y quien vea la figura suelta debe poder saber si está
  viendo un efecto causal o una asociación/predicción descriptiva.
- **Nota al pie (`caption`):** reporta el `n` de cada grupo y, cuando hay una
  línea de referencia punteada, qué marca. En figuras de CATE o de predicción,
  indique también si los resultados son de entrenamiento o de prueba.
- **Convenciones:** ejes en español y con unidades explícitas. Se prefieren
  paneles (`facet_wrap`) sobre leyendas. Distribuciones como densidad continua
  (`geom_density`, `alpha = 0.55`, `linewidth = 0.8`), nunca histograma, con la
  mediana de cada grupo en línea punteada gris; `Revenue` y `time_spent` van en
  escala logarítmica en el eje x.
- **Nombres de archivo:** `03_Resultados/Figuras/<script>/<base>_<contenido>.png`
  (la subcarpeta `<script>` es la de "Una carpeta de resultados por script"), donde
  `<base>` es `experimento` u `observacional`. Para distinguir partes del
  taller puede agregarse el contenido (p. ej. `observacional_importancia_variables.png`,
  `experimento_cate_por_grupo.png`).
- **Exportación:** siempre con `guardar_figura()` (9×6 pulgadas, 300 dpi, fondo
  blanco explícito). `guardar_figura()` no crea carpetas: asume que
  `00_main.R` ya verificó `03_Resultados/Figuras/` (ver "Reproducibilidad y
  salidas"). Las figuras de gráficos base de R que `ggsave()` no guarda (p. ej.
  el árbol de `rpart.plot`) usan `guardar_figura_base(nombre, dibujar, carpeta)`,
  definida en el mismo `00_formato_graficas.R` con el mismo tamaño, resolución y
  fondo.
- La figura que entra a la diapositiva es la exportada, sin retoques manuales:
  si algo debe verse distinto en la presentación, se cambia en el código.
- Las figuras de árboles (diagramas de particiones) y de importancia de
  variables siguen las mismas reglas de paleta, tema y exportación.

## Primero el diseño, después los resultados

- No emita juicios sobre si un resultado es "bueno" o "malo".
- No exprese entusiasmo por una métrica, un coeficiente ni por su significancia.
- Mientras el diseño no esté resuelto, lo único relevante es si la especificación es correcta.
- Un mejor desempeño predictivo fuera de muestra no implica que el modelo sea
  "mejor" para la decisión de negocio; reporte la magnitud y la incertidumbre.

## Integrantes

| Nombre                    | Rol / responsabilidad                    | Contacto                                                         |
| ------------------------- | ---------------------------------------- | ---------------------------------------------------------------- |
| Samuel Escandón          | Por definir                              | [s.escandoc@uniandes.edu.co](mailto:s.escandoc@uniandes.edu.co)   |
| Douglas Plazas Guzmán    | analisis historico                              | [d.plazasg@uniandes.edu.co](mailto:d.plazasg@uniandes.edu.co)     |
| Mateo Olmos Becerra       | Por definir                              | [m.olmosb@uniandes.edu.co](mailto:m.olmosb@uniandes.edu.co)       |
| Santiago Muñoz Martínez | Por definir                              | [s.munozm234@uniandes.edu.co](mailto:s.munozm234@uniandes.edu.co) |

<!-- Roles del Taller 2 sin asignar todavía; en el Taller 1 estaban divididos
     entre datos históricos y experimento A/B. -->

## Decisiones tomadas

<!-- Registro acumulado de decisiones metodológicas y su justificación, para no
     perder de vista por qué se hizo algo varias semanas después. -->

| Fecha      | Decisión                                                                                                                                      | Justificación                                                                                                                                                                  |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| (heredada) | `time_spent` está en minutos, en las dos bases.                                                                                                | Confirmado en el Taller 1.                                                                                                                                                     |
| (heredada) | El estimando central del experimento es el efecto de `easier_signup` sobre el ingreso (ITT); `sign_up` es un mecanismo, no la palanca.         | `easier_signup` es lo que CheMarket puede manipular. En el Taller 1, `sign_up` y `easier_signup` coinciden perfectamente en el experimento (primer estadio = 1, LATE = ITT).      |
| 2026-10-21 | Variable dependiente de las Partes A y B: `ln(Revenue)`; `Revenue` en nivel se conserva solo para la comparación con el Taller 1.              | Lo exige el enunciado; permite separar el efecto de la transformación del efecto del método.                                                                                  |
| 2026-10-23 | Las conversaciones con los agentes (`.jsonl`) se guardan localmente en `09_Conversaciones/` (ignorada por git) y al final se unen por aparte.  | Cada integrante trabaja en su máquina; unirlas fuera de git evita conflictos y subir registros crudos al repositorio, y aun así cumple con el registro que pide la rúbrica.      |
| 2026-10-23 | Los métodos, paquetes y funciones se limitan al catálogo `07_Recursos/catalogo_metodos.md` (lineal, LASSO, CART con `rpart`, bagging/bosque con `ranger`, bosque causal con `grf`). Boosting y el árbol causal individual quedan fuera. Toda ampliación se documenta primero en el "Registro de ampliaciones" del catálogo. | Son los métodos vistos en los laboratorios 04 a 10; usar las mismas funciones que el curso facilita la verificación del código y evita introducir métodos que no se vieron en clase. |
| 2026-10-23 | Plan de implementación en `PLAN.md` (raíz), con hitos H0–H7 y casillas de verificación; `HANDOFF.md` deriva de él sus siguientes objetivos.                       | Con la entrega el 25 de octubre, una sola lista priorizada permite repartir el trabajo y verificar qué falta.                                                                    |
| 2026-10-23 | Diseño 2×2 en las dos partes: forma funcional (`Revenue` / `ln(Revenue)`) × método (lineal / árboles).                                                              | Es la forma de atribuir cada diferencia con el Taller 1 a la transformación, al método o a ambos, como pide el enunciado.                                                         |
| 2026-10-23 | Se registran tres ampliaciones del catálogo: importancia de variables en `ranger`/`rpart`, varianza de los CATE (`estimate.variance = TRUE`) y ATE por subgrupo (`average_treatment_effect(..., subset = )`). | Sin ellas quedan sin herramienta la pregunta "¿qué variables predicen mejor?" (A) y los intervalos de los CATE y de los grupos (B), que exige `CLAUDE.md`. Ver "Registro de ampliaciones" del catálogo. |
| 2026-10-23 | LASSO (`cv.glmnet`) entra en la Parte A como benchmark lineal flexible, junto con la regresión lineal del Taller 1.                                                   | Un benchmark solo lineal inflaría la ventaja aparente de los árboles (H4); LASSO con un diccionario de no linealidades e interacciones es la referencia lineal más exigente del catálogo. |
| 2026-10-23 | `05_Notas/` pasa a ser un conjunto de `.md` de hallazgos (uno por hallazgo principal, con referencia a tablas/figuras, explicación intuitiva e importancia), y los agentes contrastan la evidencia nueva con esas notas y alertan ante contradicciones. | Mantener una memoria analítica separada de las bitácoras (que son cronológicas) facilita armar la presentación *answer-first* y detectar inconsistencias entre corridas, partes y talleres antes de grabar el video. |
| 2026-10-23 | El cierre de sesión se divide en `bitacora-sesion` (bitácora, notas y handoff; modelo de la sesión) y `cerrar-sesion` (commit, push y copia del `.jsonl`; `model: haiku`). Se descarta `context: fork` para la bitácora. | Reduce el uso de tokens delegando a un modelo más barato solo la parte mecánica; la bitácora requiere juicio y el historial de la conversación, que un subagente no ve. |
| 2026-10-23 | `time_spent` se trata como covariable pre-tratamiento (moderador) en el bosque causal, con una prueba de robustez sin ella.                                          | En el Taller 1, `easier_signup` no afectó significativamente a `time_spent`; la robustez cubre la posibilidad de que se mida en la misma sesión que el gasto.                         |
| 2026-10-23 | Las tablas se formatean con `gt`, con `modelsummary(..., output = "gt")` para las tablas de regresión; el `.png` se genera con Chrome/Chromium en modo headless (sin `webshot2`, cuya dependencia `websocket` no compila en todas las máquinas); el estilo y `guardar_tabla()` viven en `02_Scripts/00_formato_tablas.R`. Se descartan `flextable`, `kableExtra` y el dibujo de tablas con `ggplot2`. | `gt` da control total de encabezados, decimales, etiquetas y notas al pie desde el código, y `modelsummary` evita rehacer a mano las tablas con errores robustos. El equipo ya tiene Chrome/Chromium; `guardar_tabla()` lo localiza o usa `CHROME_PATH`. Registrado en el "Registro de ampliaciones" del catálogo. |
| 2026-10-23 | `ln(Revenue)` = `log(Revenue)` (logaritmo natural, sin constante), construido como `log_revenue` en los scripts `01_` y `02_`, que se detienen si algún `Revenue <= 0`. | `Revenue > 0` en las dos bases (0 observaciones perdidas), así que no hace falta sumar una constante. Confirmado el 2026-10-24: el Taller 1 también usa `log(Revenue)` sin constante. |
| 2026-10-24 | Cada script que genera figuras o tablas guarda sus salidas en una subcarpeta propia, con su nombre: `03_Resultados/{Figuras,Tablas}/<script>/`. `guardar_figura()` y `guardar_tabla()` reciben `carpeta`; `00_main.R` crea las subcarpetas en `carpetas_salida`. | La ruta de cada archivo indica qué script lo genera; con decenas de figuras en una sola carpeta, rastrear y regenerar cada resultado se vuelve lento. Se conservan `Figuras/` y `Tablas/` como carpetas de primer nivel para no romper las rutas ya citadas. |
| 2026-10-24 | La figura de interacción tiempo × sesiones pasadas es un solo panel con una curva loess por tramo de sesiones, ajustada por separado a cada lado de los 5 minutos y con el eje x recortado a 0.1–25 minutos. Se descartan la versión de tres paneles con 20 grupos por tramo y el promedio móvil. `loess` solo se usa como suavizado descriptivo de figuras (ampliación registrada en el catálogo). | La curva continua muestra la interacción sin elegir cuantiles; el promedio móvil se probó y el usuario prefirió el loess. No es un estimador ni un benchmark. |
| 2026-10-24 | Las figuras se construyen dentro del script que las genera; `02_Scripts/00_formato_*.R` solo define formato (paleta, tema, tablas, guardado). Se elimina `00_formato_descriptivas.R`. El ingreso frente al tiempo en el sitio también usa curva loess por lado de los 5 minutos, sin banda de confianza (límite de memoria). Las densidades por categoría muestran media (línea continua) y mediana (punteada) con sus cifras junto a cada línea y el n en el título del panel. | Quien lee un script debe ver cómo se construye cada figura, sin saltar a un auxiliar; las cifras dentro de la figura evitan consultarlas en la nota al pie. Con ~85,000 observaciones a un lado, loess con errores estándar necesita más de 4 mil millones de celdas. |
| 2026-10-24 | Las notas de `05_Notas/` se agrupan en una subcarpeta por script de origen (`05_Notas/<script>/`) y solo hablan de lo que se sabe con los resultados de ese script. | Permite atribuir cada hallazgo a su script y registrar por separado qué cambia al pasar a `ln(Revenue)` (script 04). |
| 2026-10-24 | En el lineal flexible de la Parte A el tiempo entra solo como indicador de más de 5 minutos; `time_spent` continuo queda únicamente en el lineal del Taller 1 (referencia). La escalera pone el cruce (más de 5 minutos × sesiones) después de sesiones anteriores y `sign_up` al final. | Con el indicador incluido, el RMSE de validación cruzada es igual con o sin el tiempo continuo (1.869 frente a 1.869; 1.873 con solo el tiempo); si el tiempo entra primero, infla su importancia al aproximar el salto. Ver `05_Notas/04_prediccion_lineal_observacional/`. Solo probado en dólares; falta `ln(Revenue)`. |
| 2026-10-24 | Los scripts 04 y 05 intercambian número: `04_prediccion_lineal_observacional.R` y `05_forma_funcional_observacional.R` (con sus subcarpetas de resultados y de notas). | Mantener el orden de la numeración: la predicción lineal precede a los demás scripts de la Parte A; los números 05 en adelante del plan (árboles, comparación, Parte B) deben renumerarse al crearse. |
| 2026-10-24 | Las notas al pie de las tablas van en párrafos cortos (`nota_tabla()` devuelve un vector y `estilo_tabla()` agrega un `tab_source_note` por elemento); la primera línea combina base, muestra y n ("Datos históricos, muestra de entrenamiento (n = 80,000). Análisis predictivo, no causal."). Las figuras de predicción usan `subtitulo_observacional_predictivo`. | Mejor legibilidad y una sola oración sobre el alcance del análisis (predictivo, no causal) en lugar de dos redundantes. |
| 2026-10-24 | LASSO (`05_lasso_observacional.R`) evalúa solo el modelo final, no la escalera: diccionario de 74 términos únicos (variables del lineal final, tiempo continuo, su cuadrado y logaritmo, sesiones al cuadrado e interacciones de a pares), mismos 5 pliegues que el script 04 (`foldid`, `keep = TRUE`), λ titular `lambda.min` declarado antes de ver `test`. Los scripts siguientes se corren una posición: forma funcional pasa a `06_`; árboles, comparación, validación, ATE y heterogeneidad a `07_`–`11_`. | LASSO no agrega variables de a una, así que la escalera no aplica; los mismos pliegues permiten comparar su RMSE con el del lineal pliegue a pliegue. Chequeo con MCO sin penalización: la mejora viene del diccionario, no de la regularización. Solo dólares por ahora; falta `ln(Revenue)`. Ver `05_Notas/05_lasso_observacional/`. |
| 2026-10-24 | El análisis causal de `Revenue` en dólares sale de `03_punto_partida.R` y pasa a `06_ate_experimento_niveles.R`: cumplimiento, balance (diferencias de medias y prueba de Wald conjunta con `os_type`) y MCO sin controles y con los controles del lineal final de la predicción (indicador de más de 5 minutos, sesiones anteriores y su cruce, dispositivo, sistema operativo y usuario recurrente; sin `sign_up`, que coincide con el tratamiento). La forma funcional pasa a `07_`; los scripts previstos quedan `08_arboles`, `09_comparacion`, `10_ate_experimento` (logaritmo y bosque causal) y `11_heterogeneidad`; `09_validacion_experimento` se absorbe en el 06. | Un solo script con el experimento en dólares ordena la Parte B y deja el 03 como descriptiva pura. Los controles son los de la Parte A para comparar ambas partes; en un experimento aleatorizado solo ganan precisión (error estándar 0.073 a 0.051; efecto 0.491 a 0.454). Balance y cumplimiento valen para las dos escalas, así que no se repiten en el script en logaritmo. |
| 2026-10-24 | El efecto del registro en `ln(Revenue)` se reporta como cambio proporcional del usuario típico (`exp(coef) − 1`, media geométrica) y se lleva a dólares con el factor de smearing **por grupo**, nunca con un factor común; el efecto en dólares de referencia es la diferencia de medias directa. Script `10_ate_experimento.R` (creado antes que 08 y 09). Decisión de smearing para predicciones (P2.5) sigue abierta. | El tratamiento cambia la dispersión de `ln(Revenue)` (desviación 0.53 a 0.66): con un factor común el efecto en dólares sale 0.06 frente a 0.49 real. Ver `05_Notas/10_ate_experimento/`. |
| 2026-10-25 | Árboles de la Parte A en tres scripts: `09_arboles_observacional.R` (CART), `10_bosque_observacional.R` (bagging y bosque) y `11_comparacion_prediccion_observacional.R` (evaluación única en `test`); la heterogeneidad pasa a `12_`. Los árboles reciben las 6 variables crudas del Taller 1 (tiempo continuo, sin el indicador de 5 minutos ni el cruce) y se estiman en las dos escalas. El árbol titular es el de la regla 1-SE (declarado antes de ver resultados); el bosque se elige por error OOB en una rejilla `mtry` 1–6 × `min.node.size` 5, 25, 100 (300 árboles) y se reestima con 1,000. | Variables crudas para ver si el árbol encuentra solo el corte y la interacción (lo hace: primer corte en 5.0007 min) sin heredar el corte elegido con toda la base; un script por método da una carpeta de resultados y notas por método. Ver `05_Notas/09_arboles_observacional/` a `11_`. |
| 2026-10-25 | P2.5: las predicciones en `ln(Revenue)` se comparan de dos formas: mejora % frente a la media en su propia escala y RMSE en dólares tras retransformar con el *smearing* de Duan, un factor por modelo (`mean(exp(residuos de train))`; residuos fuera de bolsa en el bosque). No se usa dependencia parcial para describir el bosque (no se amplía el catálogo). | La mejora % evita comparar RMSE con unidades distintas; la versión en dólares es la única comparable con el 2.314 del Taller 1. En los árboles la retransformación deja el error en dólares igual (1.627); en los lineales simples lo empeora. |

## Análisis descartados

<!-- Especificaciones, variables o enfoques que se probaron y abandonaron, con
     la razón, para no repetir procedimientos ya infructuosos. -->

| Fecha      | Análisis/especificación descartada                                                    | Razón                                                                                                                                              |
| ---------- | -------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| (heredado) | IV/LATE con `easier_signup` como instrumento de `sign_up` (Taller 1)                   | Primer estadio exactamente 1 por correspondencia perfecta; LATE = ITT. No se retoma salvo que cambie la estructura de los datos.                  |
| (heredado) | Hipótesis de que `time_spent` sesgaba el ITT como mediador/mal control (Taller 1)      | `easier_signup` no afecta significativamente a `time_spent`.                                                                                       |
| 2026-10-23 | Árbol causal individual (Athey e Imbens 2016, implementación propia del Laboratorio 09) para la Parte B | Decisión del equipo: no se usará. La heterogeneidad (CATE, HTE) se estima solo con el bosque causal (`grf`). Retirado de `07_Recursos/catalogo_metodos.md`. |

## Definición de variables

<!-- Definición operativa de cada variable usada en el análisis: qué incluye,
     unidades, moneda, período y fuente. -->

Heredadas del Taller 1.

| Variable              | Definición                                                                                                                                         | Fuente                                                   |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `Revenue`           | Gasto del usuario en la sesión.                                                                                                                     | `observacional.Rds`, `experimento.Rds`               |
| `ln(Revenue)`       | Logaritmo natural de `Revenue`; variable dependiente del Taller 2 (en el Taller 1 se llamó `log_revenue`).                                         | Construida                                               |
| `sign_up`           | Si el usuario se registró (binaria).                                                                                                                | `observacional.Rds`, `experimento.Rds`               |
| `time_spent`        | Tiempo en el sitio en la sesión, en minutos.                                                                                                        | `observacional.Rds`, `experimento.Rds`               |
| `past_sessions`     | Número de sesiones anteriores.                                                                                                                      | `observacional.Rds`, `experimento.Rds`               |
| `device_type`       | Dispositivo usado: `mobile`, `desktop` o `tablet`.                                                                                                  | `observacional.Rds`, `experimento.Rds`               |
| `is_returning_user` | Si el usuario ya había visitado antes (binaria).                                                                                                    | `observacional.Rds`, `experimento.Rds`               |
| `os_type`           | Sistema operativo: `osx`, `windows` u `other` (hallada al explorar los datos en el Taller 1).                                                      | `observacional.Rds`, `experimento.Rds`               |
| `easier_signup`     | Asignación al tratamiento del experimento (registro facilitado, binaria).                                                                           | `experimento.Rds` (no existe en `observacional.Rds`) |

**Nota sobre covariables de heterogeneidad (Parte B):** las características
sobre las que se puede explorar HTE son las covariables pre-tratamiento
(`time_spent`, `past_sessions`, `device_type`, `is_returning_user`, `os_type`).
Antes de usar `time_spent` como moderador, recordar que en el Taller 1 se
documentó que se mide en la misma sesión y que su relación con `Revenue` es
correlacional (posible causalidad inversa); decidir y registrar si se trata
como covariable pre-tratamiento.

## Restricciones de muestra

<!-- Criterios de exclusión aplicados y el N resultante en cada paso, para que
     el N reportado sea verificable. -->

| Criterio de exclusión | N antes | N después |
| ---------------------- | ------- | ---------- |
| `Revenue > 0` para construir `ln(Revenue)`, base observacional (mín. 0.545) | 100,000 | 100,000 |
| `Revenue > 0` para construir `ln(Revenue)`, experimento (mín. 0.665)        | 10,000  | 10,000  |

Punto de partida (Taller 1): observacional 100,000 obs. y experimento 10,000
obs., sin pérdidas por NA.

## Entregable: presentación al cliente

<!-- Lineamientos del enunciado para la presentación final, estilo "McKinsey way". -->

- Estilo *answer-first*: empezar por la conclusión; no organizar la
  presentación como una secuencia de métodos.
- Cada sección responde una pregunta natural del cliente: ¿qué aprendimos?,
  ¿qué cambia respecto al Taller 1?, ¿por qué importa?, ¿qué debería hacer la
  empresa?
- Principio de la pirámide: mensaje principal arriba, argumentos y evidencia
  debajo.
- Una idea por slide: el título comunica la conclusión, no el método. Evitar
  títulos como "Random Forest", "Árbol causal" o "Resultados".
- MECE: cubrir lo importante sin repetir el mismo argumento.
- Enfocarse en el "so what?": incluir una cifra, figura, árbol o medida de
  desempeño solo si sostiene una conclusión o decisión.
- **Comparar explícitamente con el Taller 1:** dejar claro qué se aprende ahora
  que no era visible antes.
- **Ser claros sobre la incertidumbre:** distinguir entre mejoras predictivas,
  patrones descriptivos y evidencia sobre heterogeneidad causal.
- Cerrar con decisiones y próximos pasos: qué decisiones están respaldadas por
  la evidencia y qué preguntas requieren análisis o evidencia adicional.
- Ser explícitos sobre qué recomendación sostiene la evidencia histórica y qué
  agrega el experimento.
- **No incluir código en la presentación.**
- Tablas y figuras autocontenidas, exportadas desde el código en su formato
  final (ver "Reproducibilidad y salidas"); nunca pantallazos del software.
- Video: todos los integrantes exponen de forma equitativa y la duración no
  excede los 15 minutos (criterio de la rúbrica del Taller 1).
- Antes de cerrar la presentación, pase la lista de chequeo de
  `07_Recursos/heuristicas_retroalimentacion_taller1.md` (estimando declarado,
  conciliación nivel vs. log, RMSE interpretado en unidades del negocio,
  balance **y** cumplimiento del experimento, recomendación sí/no coherente con
  la evidencia).

## Estado actual

El estado de avance (qué existe hoy, qué sigue y el registro de sesiones) se
lleva en `HANDOFF.md`, no aquí. Ver la sección "`HANDOFF.md`" en "Reglas de
trabajo".

## Punto de partida: resultados del Taller 1

Referencia para las comparaciones; ver el repositorio `taller1/` para el detalle.

- **Experimento, ITT sobre `log_revenue`:** 0.0134 sin controles y 0.0042 con
  controles; ninguno distinguible de cero.
- **Experimento, ITT sobre `Revenue` en nivel:** 0.49 (p = 1.8e-11); medias 3.98
  vs. 4.47, pero medianas casi idénticas (3.15 vs. 3.14): la diferencia se
  concentra en la cola alta (p99: 14.4 vs. 24.9). **Esto sugiere que el
  efecto promedio en nivel lo jalan pocos usuarios y es una pista natural para
  la Parte B** (heterogeneidad / `ln(Revenue)` vs. `Revenue`).
- **Quiebre en `time_spent` = 5 minutos** en la relación con `Revenue`
  (salto de nivel ≈3.13 obs. / ≈3.42 exp.), confirmado fuera de muestra en
  ambas bases. Correlacional, no causal. Un árbol debería poder recuperar o
  matizar esta no linealidad.
- **Asociación `sign_up`–`log(Revenue)` observacional** (no causal): 0.102 sin
  controles, 0.080 con controles, 0.047 con `log(time_spent)`.
- **Elasticidad `Revenue`–`time_spent`:** ≈0.169.
- **Modelo predictivo lineal de `Revenue`** (fuera de muestra, 80,000/20,000):
  RMSE 2.314 vs. 2.716 de la referencia ingenua (mejora 14.8%). Es el
  benchmark de la Parte A; ojo con la escala (nivel vs. logaritmo).
- **Representatividad:** la muestra del experimento no se distingue de la
  población histórica en las características observables compartidas (F = 0.65,
  p = 0.712), lo que apoya la validez externa del ITT.

## Reglas estrictas

<!-- Acciones que requieren autorización previa del equipo antes de ejecutarse. -->

- No modificar ni sobrescribir archivos en `01_Datos/01_Crudos/`.
- No eliminar ni mover archivos fuera de la estructura del proyecto sin autorización.
- No usar métodos, paquetes ni funciones de estimación que no estén en
  `07_Recursos/catalogo_metodos.md`. Para agregar uno, primero se documenta en
  su "Registro de ampliaciones" con autorización del equipo (ver "Regla
  metodológica").
- No evaluar desempeño predictivo dentro de muestra ni omitir `set.seed(2026)`.
- No incluir código en la presentación final.
- No commitear ni hacer push a `main`: todo cambio va a la rama del integrante
  y llega a `main` solo cuando el integrante lo pide (ver "Flujo de versiones").
