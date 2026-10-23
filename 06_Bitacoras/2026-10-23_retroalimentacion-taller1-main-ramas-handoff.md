# Bitácora — 2026-10-23: retroalimentación del Taller 1, `00_main.R`, ramas por integrante y `HANDOFF.md`

## Resumen

Integrante: Santiago Muñoz (rama `SantiagoMunozM`).

Objetivo: incorporar la retroalimentación del Taller 1 a las reglas del proyecto
y dejar la infraestructura de trabajo en equipo lista antes del análisis. No se
estimó ningún modelo ni se construyó `ln(Revenue)`.

Desarrollo:

1. Se revisaron los dos PDF de retroalimentación del Taller 1 (video 73.9/100,
   material de soporte 100/100). Las correcciones de método se convirtieron en
   once heurísticas accionables (H1–H11) en un archivo de `07_Recursos/`, y las
   correcciones de código (paquetes, carpetas, tablas) en reglas de `CLAUDE.md`.
2. Se integraron a `CLAUDE.md` las instrucciones generales del curso (objetivo
   del taller, entregas y fechas: todo vence el domingo 25 de octubre) y se
   registró que las conversaciones se guardan localmente y se unen por aparte.
3. Se pasaron los scripts a `pacman` y luego se centralizó la carga de paquetes
   en un `00_main.R` nuevo, con la estructura del Taller 1, que también verifica
   y crea las carpetas de salida una sola vez al comienzo.
4. Se crearon en GitHub las ramas de los demás integrantes y se estableció en
   `CLAUDE.md` el flujo de versiones (cada integrante trabaja en su rama; nada se
   commitea en `main` directamente). Se modificó la skill `registrar-sesion`
   para que haga commit y push a la rama del integrante.
5. Se retiró a Santiago Martínez López del equipo en `CLAUDE.md`. Su rama
   remota no se pudo borrar: el sistema de permisos bloqueó la acción.
6. Se creó `HANDOFF.md` y se movió allí el estado del proyecto que estaba en
   `CLAUDE.md`; la skill ahora también actualiza el handoff.

Los objetivos anteriores (bitácora del 2026-10-21: verificar `Revenue > 0`,
crear `README.md` y `00_main.R`, definir roles y paquetes) se cumplieron en
parte: `00_main.R` quedó hecho. `ln(Revenue)`, el README, los roles y los
paquetes no se trabajaron. No había `HANDOFF.md` al empezar la sesión.

## Archivos

- Creados:
  - `07_Recursos/heuristicas_retroalimentacion_taller1.md`
  - `00_main.R`
  - `HANDOFF.md`
  - Esta bitácora
  - Los dos PDF de retroalimentación en `07_Recursos/` (los agregó el usuario
    antes de la sesión; se versionan en esta sesión)
  - Ramas remotas `SamuelEscandonC`, `DouglasPlazasG`, `MateoOlmosB` y
    `SantiagoMartinezL` (esta última sobra; ver Pendientes)
- Modificados:
  - `CLAUDE.md`
  - `.claude/skills/registrar-sesion/SKILL.md`
  - `02_Scripts/00_formato_graficas.R`, `02_Scripts/01_limpieza_observacional.R`,
    `02_Scripts/02_limpieza_experimento.R`
- Eliminados: ninguno.

## Detalle por archivo

### `07_Recursos/heuristicas_retroalimentacion_taller1.md`

Traduce los comentarios del profesor a principios para el Taller 2. Incluye una
tabla de puntajes por criterio para ver dónde se perdieron puntos: análisis
predictivo (9/18), exploratorio (12.6/18), validación del experimento
(12.6/18), análisis causal (14.4/18) y recomendación de la Parte B (6.3/9). La
presentación y el repositorio obtuvieron el puntaje completo. La intuición: lo
que falló fue el razonamiento (el porqué de cada decisión), no la forma.

Cada heurística tiene la cita de la corrección, el principio y cómo aplicarlo en
las Partes A y B:

- H1: declarar un solo estimando.
- H2: conciliar los resultados en nivel y en logaritmo. Es la pregunta central
  del taller, y la Parte B sirve para probar la explicación de la cola alta.
- H3: la estadística descriptiva relaciona cada covariable con el resultado.
- H4: justificar la especificación.
- H5: medir la importancia de las variables con el RMSE escalonado.
- H6: interpretar el RMSE en unidades del negocio.
- H7: validar el experimento con balance **y** cumplimiento.
- H8: lectura estadística y económica de cada estimación.
- H9: generalización y supuestos de atribución.
- H10: recomendación sí/no coherente con la evidencia.
- H11: lo que conviene mantener.

Cierra con una lista de chequeo.

H6 deja abierta una decisión que debe tomar el equipo: cómo comparar el RMSE
en `ln(Revenue)` con el RMSE en dólares del Taller 1. Las opciones son
retransformar las predicciones (p. ej. *smearing* de Duan) o reportar cada RMSE
solo en su escala.

### `CLAUDE.md`

Secciones nuevas o cambiadas:

- **Contexto y "Entregas y fechas":** el objetivo del curso (semanas 5 a 8,
  no linealidades y efectos heterogéneos con árboles) y una tabla de entregas.
  Video con slides, material de soporte y video para pares vencen el domingo 25
  de octubre; la retroalimentación de pares, el 3 de noviembre; la lectura de
  comentarios, el 4. Los enlaces del enunciado eran solo texto, así que se
  remite a Bloque Neón.
- **Heurísticas:** instrucción en "Reglas de trabajo" para que los agentes lean
  las heurísticas antes de definir estimandos, diseñar la descriptiva,
  interpretar modelos, validar el experimento o redactar conclusiones.
- **"Reproducibilidad y salidas":**
  - `00_main.R` carga todos los paquetes con `pacman`; los scripts no cargan
    paquetes.
  - `00_main.R` verifica las carpetas de salida una sola vez; las funciones
    auxiliares no llaman a `dir.create()`. La regla de una sola verificación la
    pidió el usuario: así la lógica no se repite en cada función.
  - Las tablas se exportan en el formato final de la diapositiva.
  - `00_main.R` es el único punto de entrada.
  - Subsecciones "Formato de las tablas" (un `00_formato_tablas.R` con
    `guardar_tabla()`, pendiente) y "README".
- **"Flujo de versiones":** tabla integrante → rama y cinco reglas obligatorias
  para los agentes:
  1. Ubicarse en la rama del integrante.
  2. Sincronizar con `main` al empezar.
  3. Commitear y hacer push solo en esa rama.
  4. Nunca escribir en `main`; los cambios llegan por pull request cuando el
     integrante lo pide.
  5. No crear ramas por tarea.

  La tabla de ramas va aparte de la de integrantes porque Douglas editó esta
  última en `main`, y cambiarla aquí provocaría un conflicto al unir.
- **"`HANDOFF.md`":** reglas del handoff:
  - Leerlo al iniciar la sesión.
  - Al cerrar, reescribir dos a tres siguientes objetivos y el estado actual.
  - Cada entrada del registro termina con sus siguientes objetivos.
  - Cuando exista el plan de implementación, los objetivos se derivan de sus
    próximos pasos.
  - Si dos ramas chocan en el handoff, se conservan todas las entradas.
- **Conversaciones:** cada integrante guarda sus `.jsonl` localmente y el equipo
  los une por aparte. Quedó registrado como fila en "Decisiones tomadas".
- **Otros cambios:**
  - "Estado actual" ahora remite a `HANDOFF.md`, y el punto de partida del
    Taller 1 quedó como sección propia. El objetivo es que el estado viva en un
    solo lugar.
  - Se retiró a Santiago Martínez López de las tablas de integrantes y de
    ramas.
  - En "Entregable" se agregaron dos requisitos de la rúbrica: todos exponen y
    el video dura máximo 15 minutos.
  - En "Reglas estrictas" se agregó la prohibición de escribir en `main`.

### `00_main.R`

Script maestro en la raíz, con la estructura del Taller 1 en cinco secciones:

1. Verifica que el directorio de trabajo es la raíz (`taller_02.Rproj`).
2. Instala y carga los paquetes con `pacman`. Por ahora solo `tidyverse`, que
   incluye `ggplot2`.
3. Recorre `carpetas_salida` (`01_Datos/02_Procesados`, `01_Datos/03_Listos`,
   `03_Resultados/Tablas`, `03_Resultados/Figuras`) y crea las que falten.
4. Lista los scripts en orden: por ahora los dos de limpieza.
5. Ejecuta cada script con `source(..., local = new.env())`.

`01_Datos/01_Crudos/` queda fuera de la lista porque nunca se escribe en ella.
Al cargar los paquetes en el main, quedan adjuntos a la sesión de R y los ve
cualquier script ejecutado en un entorno nuevo. La consecuencia es que un
script suelto ya no carga paquetes: para depurarlo hay que correr antes las
secciones 1 a 3.

### `02_Scripts/00_formato_graficas.R`, `01_limpieza_observacional.R`, `02_limpieza_experimento.R`

Se reemplazó `library(...)` por el comentario
`# los paquetes los carga 00_main.R con pacman`. La lógica de los scripts no
cambió.

### `.claude/skills/registrar-sesion/SKILL.md`

Pasó de dos a cuatro pasos:

1. Bitácora.
2. Actualizar `HANDOFF.md`, con la plantilla de la entrada del registro y la
   regla de tomar los objetivos del plan cuando exista.
3. Commit y push a la rama del integrante:
   - Identifica la rama con la tabla de `CLAUDE.md`; si está en `main`, cambia
     de rama antes de commitear.
   - Agrega los archivos por nombre y excluye `09_Conversaciones/`.
   - Nunca usa `--force` ni empuja a `main`.
4. Copia del `.jsonl`.

### `HANDOFF.md`

Formato tomado del proyecto de IA Aplicada: en el Laboratorio 9 no había
handoff, solo un `TODO.md`. Se adaptó para tener dos a tres siguientes
objetivos en lugar de uno solo. Tiene cuatro secciones: siguientes objetivos
con bloqueos, estado actual y registro de sesiones. Las entradas del registro
de sesiones anteriores se reconstruyeron a partir de las bitácoras del
2026-10-21 y de los commits de Douglas del 2026-10-22, que no tienen bitácora.

## Resultados nuevos (tablas, figuras, gráficos)

No hubo resultados nuevos. `00_main.R` se corrió en el proyecto y en una copia
sin `03_Resultados/` ni `01_Datos/03_Listos/`. En ambos casos regeneró las
bases listas y los reportes de calidad sin errores, y git no mostró cambios en
las salidas versionadas. La regeneración no perdió observaciones (0, igual que
antes).

## Pendientes

- **`ln(Revenue)` y descriptiva de la Parte A** (primer objetivo): verificar
  `Revenue > 0` y construir `log_revenue`. Luego describir `ln(Revenue)` según
  cada covariable (H3).
- **Partes A y B:** primero decidir los paquetes (árboles y bosques causales)
  y registrarlos en "Decisiones tomadas".
- **Roles del equipo:** con la entrega el 25 de octubre, solo Douglas tiene uno
  asignado.
- **`00_formato_tablas.R` y `README.md`:** crear el primero con
  `guardar_tabla()`, y el segundo con el mapa script → resultados.
- **Rama `SantiagoMartinezL`:** sigue en GitHub. No tiene trabajo propio, pero
  borrarla requiere el permiso del usuario.
- **Rama de Samuel:** confirmar `SamuelEscandonC`. La "C" se dedujo de su
  correo.
- **Sincronizar `SantiagoMunozM` con `main`:** está dos commits atrás (cambio
  de rol de Douglas). Hacer `git merge origin/main` después del commit de esta
  sesión.
- **Conversaciones:** unir por aparte los `.jsonl` de todos antes del 25 de
  octubre.
- **Plan de implementación:** pendiente. Cuando exista, registrar su ruta en la
  sección "`HANDOFF.md`" de `CLAUDE.md`.
