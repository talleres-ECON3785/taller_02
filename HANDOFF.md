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

Objetivos derivados de [`PLAN.md`](PLAN.md) (primeras casillas sin marcar). P3.3
queda en bloqueos: le faltan los intervalos de los cuantiles, que requieren
ampliar el catálogo.

1. **P6.1 y P6.2: guion y slides** (vence hoy).
   - Archivo: `04_Presentaciones/guion.md`, con un título-conclusión por
     diapositiva, la figura o tabla de `03_Resultados/` que la sostiene y quién
     la expone.
   - Insumos: `10_Auditoria/respuestas_enunciado.md` (mensaje en 30 segundos, las
     12 preguntas y lo que falta de H1–H10) y `05_Notas/sintesis.md`.
   - Debe incluir la regla nueva (script 13), la conciliación nivel–log y, en el
     video, los supuestos de atribución (no interferencia, mismo periodo).
   - Slides con los `.png` exportados, sin retoques.
   - *Terminado cuando:* el guion cubre las 12 preguntas en 15 minutos o menos,
     con reparto entre los cuatro integrantes, y los slides usan solo archivos de
     `03_Resultados/`.
2. **P7.1: corrida completa con los 13 scripts.** Borrar `03_Resultados/` y correr
   `00_main.R` desde cero (unos 46 minutos en Windows; el script 10 toma 31).
   - *Terminado cuando:* termina sin errores. Los `.csv` coinciden con los
     versionados (las diferencias de punto flotante menores que 1e-9 no cuentan) y
     las cifras de `sintesis.md` y `respuestas_enunciado.md` no cambian.
3. **P7.2: mapa del README.** Pasar los scripts 03 a 13 de "Scripts previstos (por
   llenar)" a "Scripts existentes", en orden de numeración (hallazgo H-13 de la
   auditoría).
   - *Terminado cuando:* cada tabla o figura de los slides aparece en el mapa con
     su script.

**Bloqueos / preguntas abiertas:**

- **Falta una corrida de `00_main.R` con los 13 scripts juntos.** La última
  completa (12 scripts) terminó sin errores. Los scripts que cambiaron después (04,
  12 y 13) corrieron por separado sin errores.
- P3.3: autorizar (o no) ampliar el catálogo con remuestreo, para dar intervalos a
  los cuantiles por grupo. Hoy son descriptivos y no tienen intervalos.
- H8: no hay datos del costo de la intervención. Si mostrar formularios distintos
  según el dispositivo cuesta más de 0.235 dólares por usuario (lo que gana la
  regla frente a dárselo a todos), conviene dárselo a todos. Decirlo como pregunta
  abierta.
- Mecanismo de la regla: no se sabe por qué el formulario facilitado baja el gasto
  en celulares con Windows u otro SO. La evidencia que lo resolvería es una
  validación focalizada en ese grupo (ver `05_Notas/sintesis.md`).
- El corte de 5 minutos y el cruce de los lineales se eligieron mirando la base
  completa (incluye `test`). El árbol encuentra el mismo corte (5.0007 min) solo
  con `train`. Declararlo en una nota al pie de la diapositiva.
- `ranger` sin `num.threads` en los scripts 10 y 11 (limitación conocida; en
  Windows las cifras coinciden con las versionadas). `geom_errorbarh()` está
  obsoleta en ggplot2 4.0 (una advertencia, en el script 12).
- La sesión de Santiago Muñoz que cerró P3.1, P5.1 y P5.2 (`385ece2`, PR #4) no
  tiene bitácora ni entrada en el registro.
- `.claude/worktrees/` quedó como directorio no versionado en el checkout
  principal: quitarlo con `git worktree remove` o ignorarlo en `.gitignore`.
- En Linux, correr R con `LC_ALL=C.UTF-8` y definir `CHROME_PATH` para
  `guardar_tabla()`. En Windows, Chrome headless funciona con la ruta con tilde,
  pero falla si la ruta pasa de 260 caracteres.
- Faltan las notas del script 07 que comparan, figura por figura, qué cambia frente
  al script 03 (hoy solo está la de distribución).
- Corregir los subtítulos y notas al pie sin tilde ("historicos", "asignacion",
  "linea punteada", "tamano") en `00_formato_graficas.R` y en los scripts 03 y 04.
- Roles: llenar la columna "Resp." de cada hito en `PLAN.md`.
- Rama `SantiagoMartinezL` todavía en GitHub (Santiago Martínez salió del equipo;
  borrarla requiere permiso del usuario).
- Antes de la entrega, unir por aparte los `.jsonl` de todos los integrantes para el
  material de soporte (P7.4).

## Estado actual

<!-- Qué existe y funciona hoy: datos, scripts, resultados. Se reescribe al
     cerrar cada sesión; no es un historial. -->

- **Plan:** [`PLAN.md`](PLAN.md) con los hitos H0–H7.
  - Hecho: H0, H1, H2, H4 y H5 completos; P3.1 y P3.2.
  - Sin terminar: P3.3 (faltan los intervalos de los cuantiles) y todo H6
    (presentación) y H7 (entrega). La corrida completa de P7.1 está hecha con 12
    scripts, falta con 13.
- **Repositorio:**
  - Estructura de carpetas del Taller 1, `taller_02.Rproj`, `.gitignore`,
    `CLAUDE.md`, `README.md` y este `HANDOFF.md`.
  - `10_Auditoria/` guarda la auditoría del 2026-10-25: informe, respuestas al
    enunciado, scripts `aud_*` y sus salidas. No forma parte del pipeline.
  - Una rama por integrante en GitHub; nada se commitea en `main` directamente.
- **Skills** (`.claude/skills/`): `bitacora-sesion`, `cerrar-sesion` (`model:
  haiku`) y `registrar-hallazgo`.
- **Datos:**
  - Crudos en `01_Datos/01_Crudos/` (`datos_historicos.Rds`, 100,000 obs.;
    `datos_experimento.Rds`, 10,000 obs.).
  - Bases listas en `01_Datos/03_Listos/`, sin pérdidas, con `log_revenue =
    log(Revenue)` (`Revenue` > 0 en las dos bases).
  - Cumplimiento del experimento perfecto (5,043 / 0 / 0 / 4,957).
- **Scripts:** `00_main.R` verifica la raíz (cualquier `.Rproj` más `02_Scripts/`),
  carga los paquetes con `pacman`, crea las carpetas de salida (una subcarpeta por
  script) y corre 13 scripts:
  - `01_` y `02_`: limpieza.
  - `03_punto_partida`: descriptiva en dólares.
  - `04_prediccion_lineal_observacional`: escalera lineal en dólares y en
    `ln(Revenue)`.
  - `05_lasso_observacional`.
  - `06_ate_experimento_niveles`: balance, cumplimiento, representatividad e ITT en
    dólares.
  - `07_forma_funcional_observacional`.
  - `08_ate_experimento_log`: ITT en log y paso a dólares.
  - `09_arboles_observacional`, `10_bosque_observacional` y
    `11_comparacion_prediccion_observacional`.
  - `12_heterogeneidad_experimento`: bosque causal, `W.hat = mean(W)`,
    `num.threads = 4`.
  - `13_focalizacion_experimento`: efecto por dispositivo × SO, valor de las reglas
    con muestra dividida y conciliación por grupos.
  - `00_formato_graficas.R` y `00_formato_tablas.R` no van en la lista.
- **Parte A (predicción, base observacional):**
  - RMSE de prueba en dólares: 2.716 (ingenuo), 2.314 (lineal del Taller 1), 1.845
    (lineal con corte y cruce), 1.765 (LASSO), 1.627 (árbol podado) y 1.626 (bosque).
  - En logaritmo: 0.534 (ingenuo), 0.452 (lineal del Taller 1), 0.369 (lineal con corte y cruce), 0.361 (LASSO),
    0.349 (árbol) y 0.350 (bosque).
  - De la ganancia frente al Taller 1, el corte y el cruce dan el 68%, LASSO el 12% y
    el árbol el 20%. La transformación es neutra en los árboles.
  - Escalera en log: el indicador de más de 5 minutos da el 60% de la caída,
    sesiones y cruce el 33% y dispositivo el 6%.
  - El árbol encuentra solo el corte de 5.0007 minutos. En log usa dispositivo o SO
    en 6 de sus 9 cortes.
- **Parte B (experimento):**
  - ITT 0.491 dólares (0.347 a 0.634) y 0.0134 en log (−0.010 a 0.037).
  - Bosque causal: 0.414 dólares y 0.004 en log.
  - Evidencia formal de HTE: calibración diferencial 1.01 (ee 0.031) y AUTOC 0.200
    con muestra dividida.
  - Por celda dispositivo × SO, en log:
    - negativos: celular–Windows (−22%) y celular–otro (−19%);
    - positivos: computador–osx (+44%), tableta–osx (+35%) y celular–osx (+8%).
  - En log el efecto es aditivo en dispositivo y SO; en dólares, no.
- **Recomendación** (`05_Notas/sintesis.md`): registro facilitado para todos, salvo
  celulares con Windows u otro SO.
  - Mitad de evaluación: 0.657 dólares por usuario y +10.2% del gasto típico.
  - Dárselo a todos: 0.416 dólares y +0.8%.
  - La regla le gana a "solo computador y tableta" por 0.076 dólares (IC 0.031 a
    0.121).
  - La diferencia entre escalas se atribuye a "ambos":
    - método: signos opuestos entre grupos;
    - transformación: gasto base y ensanchamiento dentro de los grupos.
- **Notas:** índice en `05_Notas/README.md`, una subcarpeta por script (03 a 13) más
  `sintesis.md`. `B_cate_por_grupo.md` (script 12) está matizado por la regla del 13.
- **Métodos permitidos:** catálogo cerrado en `07_Recursos/catalogo_metodos.md`, con
  ampliaciones registradas: importancia de variables, varianza de los CATE, ATE por
  subgrupo, formato de tablas y `loess` descriptivo.
- **Presentación:** `04_Presentaciones/` y `08_Entregables/` vacíos.

## Registro de sesiones

<!-- Una entrada por sesión, la más reciente arriba. Tres a cinco líneas con lo
     que se hizo, quién y en qué rama, el enlace a la bitácora y, al final, los
     dos a tres siguientes objetivos que quedaron al cerrar esa sesión. Las
     entradas anteriores no se editan. -->

### 2026-10-25 (sesión 10): auditoría completa y regla de focalización (script 13)

- Samuel Escandón (`SamuelEscandonC`). La auditoría corrió en la copia `Taller_02_back Ups/` (fuera de git) y aquí se trajo al repositorio. Corrige "osx es de computadores y tabletas", la atribución nivel–log ("ambos") y la cuenta de "dos tercios" (68 / 12 / 20%). Fija `W.hat = mean(W)` en el 12 y agrega la escalera en log al 04.
- Nuevo `13_focalizacion_experimento.R`. La regla pasa a "todos salvo celulares con Windows u otro SO": 0.657 dólares por usuario frente a 0.416 de dárselo a todos, en la mitad de evaluación. `00_main.R` acepta cualquier `.Rproj`. Nueva carpeta `10_Auditoria/` (fuera del pipeline).
- Plan: P5.3 cerrado; P5.2 rehecho; avances en P2.6, P3.3 y P7.1. Corrida completa solo con 12 scripts: 04, 12 y 13 corrieron por separado, sin errores.
- Bitácora: [2026-10-25_auditoria-completa_10.md](06_Bitacoras/2026-10-25_auditoria-completa_10.md)
- **Siguientes objetivos:** (1) P6.1 y P6.2: guion y slides; (2) P7.1: corrida completa con los 13 scripts; (3) P7.2: mapa del README.

### 2026-10-25 (sesión 9): bosque causal, CATE y evidencia de heterogeneidad

- Santiago Muñoz (`SantiagoMunozM`). Nuevo `12_heterogeneidad_experimento.R`: bosque causal (`grf`, 2,000 árboles, `W.hat` estimado, `num.threads = 4`) en `ln(Revenue)`, dólares y sin tiempo. El ATE coincide con MCO (0.004 log; 0.414 dólares). Calibración y TOC con muestra dividida dan evidencia formal de HTE: computador, osx y usuarios frecuentes ganan; celular, Windows y usuarios nuevos pierden. `00_main.R` corre los 12 scripts sin errores. P3.2 y P4.1–P4.6 cerrados; P3.1 sin trabajar.
- Bitácora: [2026-10-25_bosque-causal-heterogeneidad_9.md](06_Bitacoras/2026-10-25_bosque-causal-heterogeneidad_9.md)
- **Siguientes objetivos:** (1) P2.2 (resto) y P2.6 en `ln(Revenue)` (sesión paralela); (2) P3.1: representatividad del experimento; (3) P5.1 y P5.2: síntesis y recomendación con la heterogeneidad.

### 2026-10-25 (sesión 8): árboles para predicción y comparación en prueba con los lineales

- Santiago Muñoz (`SantiagoMunozM`), en paralelo con la sesión de `ln(Revenue)` (que cerró P1.2 y P1.3 en 34507eb). Nuevos `09_arboles_observacional.R` (CART, regla 1-SE), `10_bosque_observacional.R` (rejilla OOB, bagging, importancia) y `11_comparacion_prediccion_observacional.R` (prueba única, dólares, log y log a dólares con smearing de Duan): árbol 1.627 frente a LASSO 1.765 dólares; la ganancia viene del método. El árbol encuentra solo el corte de 5 minutos. `00_main.R` corre los 11 scripts sin errores. P2.3, P2.4 y P2.5 cerrados; P2.6 avanzó.
- Bitácora: [2026-10-25_arboles-prediccion-y-comparacion_8.md](06_Bitacoras/2026-10-25_arboles-prediccion-y-comparacion_8.md)
- **Siguientes objetivos:** (1) P2.2 (resto) y P2.6: escalera y LASSO en `ln(Revenue)`, contrastados con el script 11; (2) P3.1 y P3.2: representatividad y ATE del bosque causal (`W.hat`); (3) P4.1 y P4.2: bosque causal y evidencia de HTE en `12_heterogeneidad_experimento.R`.

### 2026-10-24 (sesión 7): distribución en log y dólares, y del ITT en logaritmo a dólares

- Santiago Muñoz (`SantiagoMunozM`). Sección de distribución de `Revenue` frente a `ln(Revenue)` en el script 07 y nuevo `08_ate_experimento_log.R` (ITT en log 0.0134, retransformación con factor por grupo que reproduce 0.491, descomposición media geométrica × dispersión, cuantiles y cola). Scripts previstos corridos una posición (árboles `09_`, comparación `10_`). `00_main.R` completo corre sin errores. P1.1 cerrado; P3.2 y P3.3 avanzaron.
- Bitácora: [2026-10-24_distribucion-log-y-ate-log-a-dolares_7.md](06_Bitacoras/2026-10-24_distribucion-log-y-ate-log-a-dolares_7.md)
- **Siguientes objetivos:** (1) P1.3 y cierre de P1.2; (2) P2.2 (resto): escalera y LASSO en `ln(Revenue)`; (3) P2.3: CART en `09_arboles_observacional.R`.

### 2026-10-24 (sesión 6): análisis causal en dólares al script 06 y forma funcional a 07

- Santiago Muñoz (`SantiagoMunozM`). Nuevo `06_ate_experimento_niveles.R` (cumplimiento, balance con prueba conjunta F = 0.96, p = 0.456, e ITT en dólares: 0.491 sin controles, 0.454 con los controles del lineal final, error estándar de 0.073 a 0.051); la sección causal salió del 03 y la forma funcional pasó a `07_`. Scripts previstos renumerados. `00_main.R` completo corre sin errores. P3.1 y P3.2 avanzaron.
- Bitácora: [2026-10-24_ate-niveles-balance-cumplimiento_6.md](06_Bitacoras/2026-10-24_ate-niveles-balance-cumplimiento_6.md)
- **Siguientes objetivos:** (1) P1.1, P1.3 y cierre de P1.2; (2) P2.2 (resto): escalera y LASSO en `ln(Revenue)`; (3) P2.3: CART en `08_arboles_observacional.R`.

### 2026-10-24 (sesión 5): LASSO como benchmark lineal flexible y renumeración de scripts

- Santiago Muñoz (`SantiagoMunozM`). Nuevo `05_lasso_observacional.R` (solo el modelo
  final, diccionario de 74 términos, mismos pliegues que el 04): RMSE de prueba 1.765
  frente a 1.845 del lineal con quiebre y cruce y 2.314 del Taller 1. Chequeo con MCO sin
  penalización: la mejora viene del diccionario, no de la regularización (nota corregida);
  se quitaron dos columnas duplicadas (76 a 74). El script de forma funcional pasó a
  `06_` y los planificados se renumeraron (07 a 11). `00_main.R` completo corre sin
  errores. P2.2 avanzó (falta `ln(Revenue)`).
- Bitácora: [2026-10-24_lasso-benchmark-y-renumeracion_5.md](06_Bitacoras/2026-10-24_lasso-benchmark-y-renumeracion_5.md)
- **Siguientes objetivos:** (1) P1.1, P1.3 y cierre de P1.2 (descriptiva pendiente); (2) P2.2
  (resto): escalera y LASSO en `ln(Revenue)`; (3) P2.3: CART en `07_arboles_observacional.R`.

### 2026-10-24 (sesión 4): MCO del efecto del registro y escalera de modelos lineales

- Santiago Muñoz (`SantiagoMunozM`). MCO del efecto del registro en el experimento (0.491
  dólares, cumplimiento perfecto) en `03_punto_partida.R`; nuevo
  `04_prediccion_lineal_observacional.R` con la escalera lineal en dólares (corte de 5
  minutos, sesiones, cruce, dispositivo, sistema operativo, recurrente y `sign_up` al
  final), validación cruzada en `train` y prueba única (1.845 frente a 2.314 del Taller 1).
  El tiempo continuo sale de la escalera por redundante con el corte. Notas al pie en
  párrafos; scripts 04 y 05 intercambiaron numeración. P2.1 cerrado; P2.2 y P2.6 avanzaron.
  No se corrió `00_main.R` completo.
- Bitácora: [2026-10-24_ols-registro-y-escalera-lineal_4.md](06_Bitacoras/2026-10-24_ols-registro-y-escalera-lineal_4.md)
- **Siguientes objetivos:** (1) P1.1, P1.3 y cierre de P1.2 (descriptiva pendiente); (2) P2.2
  (resto): escalera en `ln(Revenue)` y LASSO; (3) P2.3: CART.

### 2026-10-24 (sesión 3): figuras en cada script, loess del tiempo, categóricas con media y mediana y notas por script

- Santiago Muñoz (`SantiagoMunozM`). Las figuras se construyen ahora dentro de los
  scripts 03 y 04 (se eliminó `00_formato_descriptivas.R`); el ingreso frente al
  tiempo usa loess por lado de los 5 minutos, sin banda por memoria; las
  categóricas muestran media y mediana con sus cifras; las tres notas pasaron a
  `05_Notas/03_punto_partida/` y se limitaron al script 03 (medianas parecidas,
  medias distintas, cola derecha como sugerencia). No se corrió `00_main.R`
  completo.
- P1.2 sigue abierto (falta `sign_up`); P1.1, P1.3, P2.1 y P2.2 no se trabajaron.
- Bitácora: [2026-10-24_figuras-categoricas-loess-y-notas-por-script_3.md](06_Bitacoras/2026-10-24_figuras-categoricas-loess-y-notas-por-script_3.md)
- **Siguientes objetivos:** (1) P1.1, P1.3 y cierre de P1.2 (densidad
  `Revenue`/`ln(Revenue)`, `sign_up`, tablas exportadas con percentiles altos);
  (2) P2.1: partición 80/20 que reproduce el RMSE 2.314; (3) P2.2: benchmarks en
  las dos escalas.

### 2026-10-24 (sesión 2): renombre del script 03, ejes y figura continua de interacción

- Santiago Muñoz (`SantiagoMunozM`). Se renombró `03_punto_de_partida_observacional.R`
  a `03_punto_partida.R` (con su carpeta de figuras y todas las referencias), las
  figuras pasaron a 9×6 y los ejes a mayúscula inicial con un solo paréntesis. La
  figura de interacción tiempo × sesiones pasó a un panel con curvas loess (se
  probó y descartó el promedio móvil); se regeneró todo con `00_main.R`.
- P1.2 sigue abierto (falta `sign_up`); P1.1, P1.3, P2.1 y P2.2 no se trabajaron.
- Bitácora: [2026-10-24_ajustes-figuras-y-renombre-script_2.md](06_Bitacoras/2026-10-24_ajustes-figuras-y-renombre-script_2.md)
- **Siguientes objetivos:** (1) P1.1, P1.3 y cierre de P1.2 (densidad
  `Revenue`/`ln(Revenue)`, `sign_up`, tablas exportadas); (2) P2.1: partición
  80/20 que reproduce el RMSE 2.314; (3) P2.2: benchmarks en las dos escalas.

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
