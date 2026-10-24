# HANDOFF

Resumen accionable del Taller 2 para retomar el trabajo. El detalle de cada
sesión está en `06_Bitacoras/`; aquí solo va lo necesario para saber dónde
estamos y qué sigue. Las reglas para mantener este archivo están en
`CLAUDE.md` (sección "`HANDOFF.md`").

**Fecha de entrega (video, slides y material de soporte): domingo 25 de
octubre de 2026.**

## Siguientes objetivos

<!-- Dos a tres tareas concretas, en orden de prioridad, cada una con el
     archivo que debe producirse, un criterio de terminado verificable y, si
     aplica, el integrante a cargo. Cuando exista el plan de implementación,
     cada objetivo cita el paso del plan del que sale. Se reescribe al cerrar
     cada sesión. -->

Objetivos derivados de [`PLAN.md`](PLAN.md) (primeras casillas sin marcar).

1. **P1.1, P1.3 y cierre de P1.2: descriptiva pendiente.** Agregar a
   `03_punto_de_partida_observacional.R` / `04_forma_funcional_observacional.R`
   la densidad de `Revenue` frente a `ln(Revenue)` (P1.1) y la relación con
   `sign_up` (P1.2); y exportar con `guardar_tabla()` la tabla de medias por
   covariable y escala y la tabla de cifras del Taller 1 (P1.3).
   *Terminado cuando:* esas figuras y tablas salen de `00_main.R` en las
   subcarpetas de su script y las cifras de las notas de `05_Notas/` (hoy leídas
   de las figuras) remiten a una tabla exportada.
2. **P2.1: partición 80/20 del lineal.** Primer script de la Parte A
   (`05_prediccion_lineal_observacional.R`) con `set.seed(2026)`.
   *Terminado cuando:* reproduce el RMSE 2.314 del lineal en nivel del Taller 1.
3. **P2.2: benchmarks en las dos escalas.** En el mismo script: ingenuo (media
   de `train`), lineal del Taller 1, lineal flexible (con el cruce "más de 5
   minutos" × sesiones pasadas, ver `A_sesiones_pasadas_interaccion_tiempo.md`) y
   LASSO (`cv.glmnet`).
   *Terminado cuando:* hay RMSE de `train`/CV para cada uno en `Revenue` y en
   `ln(Revenue)`, sin tocar `test`.

**Bloqueos / preguntas abiertas:**

- Decidir si las figuras de densidad marcan también la media (además de la mediana): hoy ocultan las diferencias de promedio por la cola alta (p. ej. por sistema operativo).
- Probar a mano borrar `03_Resultados/` y correr `00_main.R` (el `rm` con comodín fue bloqueado esta sesión); verifica que las subcarpetas por script se recrean (P7.1).
- Corregir los subtítulos sin tilde en `00_formato_graficas.R` ("historicos", "asignacion").
- Roles: llenar la columna "Resp." de cada hito en `PLAN.md`. Con la entrega
  el 25 de octubre, las Partes A (H2) y B (H3–H4) tienen que avanzar en
  paralelo el sábado.
- Decisiones pendientes dentro del plan: retransformar a dólares con
  *smearing* o comparar solo mejoras relativas (P2.5); `W.hat` igual a 0.5 o a
  la proporción observada, 4,957 / 10,000 (P3.2).
- Rama `SantiagoMartinezL` todavía en GitHub (Santiago Martínez salió del
  equipo; borrarla requiere permiso del usuario). Confirmar el nombre de la rama
  de Samuel (`SamuelEscandonC`, inferido de su correo).
- Escribir la primera nota de `05_Notas/` con `registrar-hallazgo` apenas exista
  el primer resultado (H1) y comprobar que `model: haiku` de `cerrar-sesion`
  se aplica.
- `guardar_tabla()` (Chrome headless, sin `webshot2`) solo se probó en la máquina
  de Santiago Muñoz (macOS). Un segundo integrante debe probarlo antes del 25 de
  octubre; si Chrome está en otra ruta, definir `CHROME_PATH`. Decidir si se fija
  una fuente del sistema en lugar de Inter (Google Fonts).
- Antes del 25 de octubre, unir por aparte los `.jsonl` de todos los
  integrantes para el material de soporte (P7.4).

## Estado actual

<!-- Qué existe y funciona hoy: datos, scripts, resultados. Se reescribe al
     cerrar cada sesión; no es un historial. -->

- **Plan:** [`PLAN.md`](PLAN.md) con los hitos H0–H7 y 33 tareas con casilla,
  el diseño 2×2 (forma funcional × método), los estimandos de cada parte y la
  tabla pregunta del enunciado → paso. Hecho: P0.1 a P0.5 (H0 completo); P1.2
  avanzó (falta `sign_up`).
- **Repositorio:** estructura de carpetas del Taller 1, `taller_02.Rproj`,
  `.gitignore`, `CLAUDE.md`, `README.md` (objetivo, ejecución, estructura y mapa
  script → resultados por llenar) y este `HANDOFF.md`. Una rama por integrante en
  GitHub; nada se commitea en `main` directamente.
- **Skills** (`.claude/skills/`): `bitacora-sesion` (bitácora, notas y handoff),
  `cerrar-sesion` (commit, push y `.jsonl`; `model: haiku`) y
  `registrar-hallazgo` (notas de `05_Notas/` y contraste con lo registrado). Aún
  sin probar con un resultado real.
- **Notas:** tres notas de la Parte A en `05_Notas/` (quiebre en 5 minutos,
  interacción entre sesiones pasadas y tiempo, dispositivo y sistema operativo),
  indexadas en `05_Notas/README.md`. Sus cifras salen de las figuras; falta la
  tabla exportada que las respalde.
- **Datos:** crudos en `01_Datos/01_Crudos/` (`datos_historicos.Rds`, 100,000
  obs.; `datos_experimento.Rds`, 10,000 obs.). Bases listas en
  `01_Datos/03_Listos/` (`observacional_limpio.Rds`,
  `experimento_listos.RDS`), sin pérdidas. `Revenue` > 0 en las dos bases, así
  que `ln(Revenue)` no pierde observaciones y ya está construido como
  `log_revenue` en las dos bases (convención `log(Revenue)` confirmada con el
  Taller 1). Cumplimiento del experimento perfecto (5,043 / 0 / 0 / 4,957).
- **Scripts:** `00_main.R` (raíz) verifica la raíz del proyecto, carga los
  paquetes con `pacman`, crea las carpetas de salida (incluida una subcarpeta por
  script, ver `CLAUDE.md`) y corre `01_limpieza_observacional.R`,
  `02_limpieza_experimento.R`, `03_punto_de_partida_observacional.R` (`Revenue`
  en nivel) y `04_forma_funcional_observacional.R` (`ln(Revenue)`); corre completo
  sin errores. `00_formato_graficas.R` (paleta, tema, `guardar_figura()`),
  `00_formato_tablas.R` (`guardar_tabla()`, aún sin uso en análisis) y
  `00_formato_descriptivas.R` (funciones de las figuras de la descriptiva) no
  van en la lista.
- **Resultados:** reportes de calidad de la base observacional en
  `03_Resultados/Tablas/01_limpieza_observacional/` y 12 figuras descriptivas
  (6 por escala, ingreso frente a tiempo en el sitio, sesiones pasadas,
  dispositivo, sistema operativo, usuario recurrente e interacción tiempo ×
  sesiones) en `03_Resultados/Figuras/03_punto_de_partida_observacional/` y
  `.../04_forma_funcional_observacional/`. Ningún modelo estimado.
- **Métodos permitidos:** catálogo cerrado en `07_Recursos/catalogo_metodos.md`
  (lineal, LASSO, CART, bagging y bosque con `ranger`, bosque causal con
  `grf`), más cuatro ampliaciones registradas: importancia de variables, varianza
  de los CATE, ATE por subgrupo y paquetes de formato de tablas (`gt`,
  `modelsummary`, Chrome headless). LASSO entra en la Parte A; `time_spent` es
  moderador en la Parte B (con robustez sin ella).
- **Guías:** heurísticas H1–H11 en
  `07_Recursos/heuristicas_retroalimentacion_taller1.md`; reglas de
  reproducibilidad, tablas y entregas en `CLAUDE.md`.

## Registro de sesiones

<!-- Una entrada por sesión, la más reciente arriba. Tres a cinco líneas con lo
     que se hizo, quién y en qué rama, el enlace a la bitácora y, al final, los
     dos a tres siguientes objetivos que quedaron al cerrar esa sesión. Las
     entradas anteriores no se editan. -->

### 2026-10-24: descriptiva del ingreso frente a las covariables y carpeta de resultados por script

- Santiago Muñoz (`SantiagoMunozM`). Se hicieron las figuras de P1.2 de la base
  observacional en dos escalas (primero `Revenue` en nivel y luego `ln(Revenue)`)
  con el formato de densidades del Taller 1: tiempo en el sitio (escalón en 5
  minutos), sesiones pasadas, dispositivo, sistema operativo, usuario recurrente
  y la interacción tiempo × sesiones. Tres notas nuevas en `05_Notas/`.
- Se separó el script en `03_punto_de_partida_observacional.R` y
  `04_forma_funcional_observacional.R` (funciones en `00_formato_descriptivas.R`),
  y se fijó la regla de una subcarpeta de resultados por script (en `CLAUDE.md`).
- P1.2 avanzó pero no se cerró (falta `sign_up`); P1.1, P1.3 y P2.1 no se
  trabajaron y se mantienen.
- Bitácora: [2026-10-24_descriptiva-covariables-observacional.md](06_Bitacoras/2026-10-24_descriptiva-covariables-observacional.md)
- **Siguientes objetivos:** (1) P1.1, P1.3 y cierre de P1.2 (densidad
  `Revenue`/`ln(Revenue)`, `sign_up`, tablas exportadas); (2) P2.1: partición
  80/20 que reproduce el RMSE 2.314; (3) P2.2: benchmarks en las dos escalas.

### 2026-10-23: README inicial

- Santiago Muñoz (`SantiagoMunozM`). Se creó `README.md` (objetivo, ejecución solo
  con `00_main.R`, estructura de carpetas y mapa script → resultados: los cuatro
  scripts existentes más los previstos de `PLAN.md`, por llenar). Cerrado P0.5;
  H0 completo.
- P1.1–P1.3 y P2.1 no se trabajaron; se mantienen.
- Bitácora: [2026-10-23_readme-inicial.md](06_Bitacoras/2026-10-23_readme-inicial.md)
- **Siguientes objetivos:** (1) P1.1–P1.3: descriptiva de la Parte A; (2) P2.1:
  partición 80/20 que reproduce el RMSE 2.314; (3) P2.2: benchmarks en las dos
  escalas.

### 2026-10-23: paquetes de árboles en `p_load()` y `log_revenue`

- Santiago Muñoz (`SantiagoMunozM`). Se agregaron `sandwich`, `fixest`, `caret`,
  `glmnet`, `rpart`, `rpart.plot`, `ranger` y `grf` al `p_load()` y se construyó
  `log_revenue` en los scripts `01_` y `02_` (con `stopifnot(Revenue > 0)`, 0 obs.
  perdidas). `00_main.R` corrió completo sin errores. Cerrados P0.3 y P0.4.
- P0.5 (README) y P1.1–P1.3 no se trabajaron; se mantienen.
- Bitácora: [2026-10-23_paquetes-y-log-revenue.md](06_Bitacoras/2026-10-23_paquetes-y-log-revenue.md)
- **Siguientes objetivos:** (1) P0.5: README inicial; (2) P1.1–P1.3: descriptiva
  de la Parte A; (3) P2.1: partición 80/20 que reproduce el RMSE 2.314.

### 2026-10-23: formato de tablas con `gt` y `modelsummary`

- Santiago Muñoz (`SantiagoMunozM`). Se compararon alternativas de paquetes y se
  eligió `gt` con `modelsummary`; se creó `02_Scripts/00_formato_tablas.R`
  (estilo, decimales, notas al pie y `guardar_tabla()`) y se agregaron ambos
  paquetes al `p_load()`. Cerrado P0.2; P0.3 avanzó solo con los paquetes de tablas.
- `webshot2` no compiló (dependencia `websocket` con OpenSSL), así que `.png` se
  genera con Chrome headless; probado en una máquina. Decisión y ampliación del
  catálogo registradas.
- Los objetivos P0.4–P0.5 y P1.1–P1.3 no se trabajaron; se mantienen.
- Bitácora: [2026-10-23_formato-tablas.md](06_Bitacoras/2026-10-23_formato-tablas.md)
- **Siguientes objetivos:** (1) P0.3: paquetes de árboles y estimación en
  `p_load()`; (2) P0.4–P0.5: `log_revenue` en las bases listas y README; (3)
  P1.1–P1.3: descriptiva de la Parte A.

### 2026-10-23: notas de hallazgos y división de las skills de cierre

- Santiago Muñoz (`SantiagoMunozM`). `05_Notas/` pasa a ser memoria de hallazgos
  (una nota por hallazgo, con tablas/figuras, explicación intuitiva e
  importancia) y los agentes contrastan la evidencia nueva con ellas y alertan
  ante contradicciones. Skill nueva `registrar-hallazgo`.
- `registrar-sesion` se renombra `bitacora-sesion` (solo bitácora, notas y
  handoff, leyendo solo la última bitácora); `cerrar-sesion` hace commit, push y
  `.jsonl` con `model: haiku`. Se borró la skill global `cerrar-sesion`.
- Los tres objetivos anteriores no se trabajaron; se mantienen (sin pasos nuevos
  del plan).
- Bitácora: [2026-10-23_notas-hallazgos-y-skills.md](06_Bitacoras/2026-10-23_notas-hallazgos-y-skills.md)
- **Siguientes objetivos:** (1) P0.2–P0.3: `00_formato_tablas.R` y paquetes en
  `p_load()`; (2) P0.4–P0.5: `log_revenue` en las bases listas y README; (3)
  P1.1–P1.3: descriptiva de la Parte A.

### 2026-10-23: plan de implementación

- Santiago Muñoz (`SantiagoMunozM`). Se creó `PLAN.md`: hitos H0–H7 con tareas
  `Pk.n` y casillas, calendario hasta el 25 de octubre, diseño 2×2 (forma
  funcional × método) y tabla pregunta del enunciado → paso.
- Decisiones registradas en `CLAUDE.md` y en el catálogo: las tres
  ampliaciones, LASSO en la Parte A y `time_spent` como moderador (con
  robustez). Se verificó que `Revenue` > 0 (0 pérdidas) y que el cumplimiento
  del experimento es perfecto. Cerrado P0.1.
- Los objetivos anteriores (descriptiva, Parte A, Parte B) no se trabajaron;
  quedaron dentro del plan (H1–H4).
- Bitácora: [2026-10-23_plan-implementacion.md](06_Bitacoras/2026-10-23_plan-implementacion.md)
- **Siguientes objetivos:** (1) P0.2–P0.3: `00_formato_tablas.R` y paquetes en
  `p_load()`; (2) P0.4–P0.5: `log_revenue` en las bases listas y README; (3)
  P1.1–P1.3: descriptiva de la Parte A.

### 2026-10-23: catálogo de métodos, librerías y funciones

- Santiago Muñoz (`SantiagoMunozM`). Se trajo `origin/main` (avance rápido,
  sin conflictos). Se revisaron los laboratorios 04 a 10 y se creó
  `07_Recursos/catalogo_metodos.md`: métodos, paquetes y funciones
  permitidos, con convenciones y adaptación a CheMarket.
- `CLAUDE.md` ahora limita el trabajo al catálogo y exige documentar cualquier
  ampliación antes de usarla. El árbol causal individual se descartó por
  decisión del equipo; la Parte B usará solo el bosque causal.
- Los tres objetivos anteriores no se trabajaron; avanzó el bloqueo de
  elección de paquetes.
- Bitácora: [2026-10-23_catalogo-metodos.md](06_Bitacoras/2026-10-23_catalogo-metodos.md)
- **Siguientes objetivos:** (1) construir `ln(Revenue)` y la descriptiva de la
  Parte A; (2) Parte A: lineal, CART y bosque con el catálogo sobre
  `ln(Revenue)`; (3) Parte B: ATE y CATE con `grf`, validación del
  experimento y conciliación nivel–log.

### 2026-10-23: retroalimentación del Taller 1, `00_main.R`, ramas por integrante y handoff

- Santiago Muñoz (`SantiagoMunozM`). La retroalimentación del Taller 1 quedó
  en heurísticas H1–H11 (`07_Recursos/`) y en reglas de reproducibilidad en
  `CLAUDE.md`, junto con las entregas y fechas del curso.
- Se creó `00_main.R` (paquetes con `pacman` y verificación de carpetas una
  sola vez). Se probó desde cero sin errores.
- Se crearon las ramas por integrante, el flujo de versiones y `HANDOFF.md`.
  `registrar-sesion` ahora actualiza el handoff y hace commit y push a la rama.
  Santiago Martínez salió del equipo.
- Del objetivo anterior se cumplió `00_main.R`; `ln(Revenue)`, README, roles y
  paquetes no se trabajaron.
- Bitácora: [2026-10-23_retroalimentacion-taller1-main-ramas-handoff.md](06_Bitacoras/2026-10-23_retroalimentacion-taller1-main-ramas-handoff.md)
- **Siguientes objetivos:** (1) construir `ln(Revenue)` y la descriptiva de la
  Parte A; (2) Parte A: árboles frente al lineal sobre `ln(Revenue)`; (3)
  Parte B: ATE y CATE con bosque causal, validación del experimento y
  conciliación nivel–log.

### 2026-10-22: rol de Douglas en `CLAUDE.md`

- Douglas Plazas (commits `f68e30f` y `fa12f74`, directo en `main`, antes de
  que existiera la regla de ramas). Asignó su rol ("análisis histórico") en la
  tabla de integrantes de `CLAUDE.md`. Sin bitácora.
- **Siguientes objetivos:** no se registraron.

### 2026-10-21: datos, limpieza y formato de gráficas traídos del Taller 1

- Santiago Muñoz (`main`, commit `da76ed3`). Se copiaron los crudos y los
  scripts de limpieza del Taller 1, se regeneraron las bases listas (0 obs.
  perdidas) y se trajo `00_formato_graficas.R`.
- Bitácora: [2026-10-21_traer-datos-y-limpieza.md](06_Bitacoras/2026-10-21_traer-datos-y-limpieza.md)
- **Siguientes objetivos:** (1) verificar `Revenue > 0` y fijar la
  convención de `ln(Revenue)`; (2) crear `README.md` y `00_main.R`; (3)
  definir roles y paquetes de árboles.

### 2026-10-21: configuración inicial del proyecto

- Santiago Muñoz. Se replicó la estructura del Taller 1, se escribió
  `CLAUDE.md` adaptado al Taller 2 y se trajo la skill `registrar-sesion` del
  Laboratorio 9, con `09_Conversaciones/` fuera de git.
- Bitácora: [2026-10-21_configuracion-inicial.md](06_Bitacoras/2026-10-21_configuracion-inicial.md)
- **Siguientes objetivos:** (1) copiar los datos crudos y confirmar sus
  nombres; (2) copiar `00_formato_graficas.R` del Taller 1; (3) definir roles
  y los algoritmos de árboles.
