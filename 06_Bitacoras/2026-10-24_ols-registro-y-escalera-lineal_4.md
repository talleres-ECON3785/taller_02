# Bitácora — 2026-10-24 (sesión 4): MCO del efecto del registro y escalera de modelos lineales de la Parte A

## Resumen

Santiago Muñoz (`SantiagoMunozM`) hizo dos cosas, ambas en `Revenue` en dólares:

1. **MCO sencillo del efecto del registro (experimento).** Al final de
   `03_punto_partida.R` se estima `Revenue ~ easier_signup` con errores robustos HC1,
   se verifica el cumplimiento perfecto (5,043 control con `sign_up = 0`; 4,957
   tratados con `sign_up = 1`; el script se detiene si dejan de coincidir) y se exporta
   la tabla con estrellas de significancia. Efecto: 0.491 dólares (error estándar
   0.073); promedio del control: 3.978. Coincide con el ITT en nivel del Taller 1.
2. **Escalera de modelos lineales (P2.1 y parte lineal de P2.2 y P2.6).** Nuevo
   `04_prediccion_lineal_observacional.R`: partición 80/20 con semilla 2026, validación
   cruzada de 5 pliegues solo en `train`, y `test` evaluado una sola vez. Reproduce el
   RMSE del Taller 1 (2.314 y 2.716). Cada escalón agrega una idea de las
   descriptivas (corte de 5 minutos, sesiones anteriores, el cruce, dispositivo, sistema
   operativo, usuario recurrente) y `sign_up` va al final.

Decisiones tomadas durante la sesión: (i) el tiempo continuo sale de la escalera porque,
con el indicador del corte de 5 minutos, no reduce más el error (tabla de robustez y
figura del orden de entrada); (ii) el cruce se muestra aislado en la tabla de aporte y
va después de sesiones anteriores en la escalera; (iii) las notas de tablas pasan a
párrafos cortos y las dos oraciones de alcance se consolidan en "Análisis predictivo, no
causal"; (iv) los scripts 04 y 05 intercambian número (predicción lineal pasa a `04_`,
forma funcional a `05_`).

Por restricciones del entorno (edición aislada en worktrees), los cambios se hicieron en
worktrees temporales y se trajeron a `SantiagoMunozM` con avance rápido; no se corrió
`00_main.R` completo ni `05_forma_funcional_observacional.R` tras el cambio de nombre.
Se probaron el script 04 completo y la sección final del 03 por separado.

Objetivos que traía `HANDOFF.md`: P2.1 se cumplió (reproduce 2.314). P2.2 avanzó
(escalera lineal en dólares; faltan la escala logarítmica y LASSO, y el ingenuo y el
lineal del Taller 1 ya están). P1.1, P1.3 y el cierre de P1.2 no se trabajaron.

## Archivos

- Creados: `02_Scripts/04_prediccion_lineal_observacional.R`;
  `03_Resultados/Tablas/03_punto_partida/experimento_ols_registro.{png,csv}`;
  `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_{escalera_rmse,importancia_variables,rmse_prueba_lineal,robustez_forma_tiempo}.{png,csv}`;
  `03_Resultados/Figuras/04_prediccion_lineal_observacional/observacional_{escalera_rmse,orden_tiempo_corte}.png`;
  notas `05_Notas/03_punto_partida/B_ols_efecto_registro.md` y
  `05_Notas/04_prediccion_lineal_observacional/{A_escalera_importancia_lineal,A_corte_5_minutos_captura_tiempo,A_lineal_flexible_vs_taller1}.md`; esta bitácora.
- Modificados: `02_Scripts/03_punto_partida.R`, `02_Scripts/00_formato_tablas.R`,
  `02_Scripts/00_formato_graficas.R`, `00_main.R`, `README.md`, `PLAN.md`,
  `HANDOFF.md`, `CLAUDE.md`, `05_Notas/README.md`, `05_Notas/03_punto_partida/A_quiebre_time_spent.md`
  (historial) y las notas `03_punto_partida/` y `README.md` (nombres de scripts).
- Renombrados (`git mv`): `02_Scripts/04_forma_funcional_observacional.R` →
  `05_forma_funcional_observacional.R`; sus carpetas de resultados y la de notas
  asociadas.
- Eliminados: ninguno (una fila planificada duplicada del README sobre benchmarks
  lineales).

## Detalle por archivo

### `02_Scripts/03_punto_partida.R` (sección final)
Estimando: ITT de `easier_signup` sobre `Revenue` (dólares); como el cumplimiento es
perfecto es también el efecto de registrarse. Estimador: `lm(Revenue ~ easier_signup)`
con errores HC1 (`modelsummary(vcov = "HC1")`). Estimación: 0.491 (error estándar 0.073).
Solo el experimento sostiene la lectura causal. Se agrega `source` de
`00_formato_tablas.R` y se exporta con `guardar_tabla()`.

### `02_Scripts/04_prediccion_lineal_observacional.R`
- **Partición:** `sample(seq_len(n), round(0.8 * n))` con `set.seed(2026)`, la del Taller
  1 (catálogo de métodos). Se advierte con `warning()` si no se reproducen 2.314 y 2.716.
- **Validación cruzada:** `caret::createFolds(k = 5)`, pliegues fijos para todos los
  modelos; las diferencias entre modelos se calculan pliegue a pliegue (pareadas) y su
  error estándar es la desviación entre pliegues sobre `sqrt(5)`.
- **Variables y su rol:** `mas_5_min` = indicador de `time_spent > 5` (fuente: quiebre del
  Taller 1 y descriptiva, `05_Notas/03_punto_partida/A_quiebre_time_spent.md`; es un
  desplazamiento de nivel que absorbe el salto de ~3 dólares); `past_sessions`;
  `mas_5_min:past_sessions` (cruce, de `A_sesiones_pasadas_interaccion_tiempo.md`);
  `device_type`, `os_type`, `is_returning_user` (medias distintas en las descriptivas);
  `sign_up` al final para medir su aporte predictivo sin sesgar el de las demás.
- **Aporte sin depender del orden:** cada variable sola frente a la media, y el modelo
  completo sin ella; "Más de 5 minutos" y "Sesiones anteriores" quitan también el cruce, que
  tiene fila propia (comparado con el modelo de las dos variables sin cruce).
- **Prueba:** ingenuo, lineal del Taller 1 y lineal con corte, cruce y registro.
  Columnas: RMSE de CV y de prueba, brecha, RMSE como % de la media, mejora frente a
  la media y error cuadrático eliminado.
- **Robustez del tiempo y figura del orden:** muestran que el tiempo continuo no agrega
  nada una vez incluido el corte (1.869 en CV con corte; 1.873 con solo el tiempo).
- Notas al pie en párrafos; asterisco en la fila del cruce.

### `00_formato_tablas.R` y `00_formato_graficas.R`
`nota_tabla()` devuelve un vector (primera línea: "Datos históricos, muestra de
entrenamiento (n = 80,000). Análisis predictivo, no causal."; después, un párrafo por
elemento de `extra`) y `estilo_tabla()` agrega un `tab_source_note` por elemento. Nuevo
`subtitulo_observacional_predictivo` para las figuras de predicción. Las salidas
descriptivas del script 03 mantienen su frase.

### `00_main.R`, `README.md`, `PLAN.md`
Subcarpetas de salida y orden de ejecución con la numeración nueva; mapa script →
resultados con el script 04; P2.1 marcada en el plan.

## Resultados nuevos (tablas, figuras, gráficos)

- **`experimento_ols_registro`** (tabla): comunica el ITT en dólares y el cumplimiento
  perfecto. Datos: experimento, n = 10,000. Rol: punto de partida de la Parte B. Nota:
  [`B_ols_efecto_registro.md`](../05_Notas/03_punto_partida/B_ols_efecto_registro.md).
- **`observacional_escalera_rmse`** (tabla y figura): cuánto baja el RMSE de CV al
  agregar cada variable. Datos: observacional, entrenamiento n = 80,000. Rol: respuesta a
  "¿qué variables predicen más?" (H5). Nota:
  [`A_escalera_importancia_lineal.md`](../05_Notas/04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md).
- **`observacional_importancia_variables`** (tabla): aporte de cada variable sin depender
  del orden; mismas notas.
- **`observacional_robustez_forma_tiempo`** (tabla) y **`observacional_orden_tiempo_corte`**
  (figura): el corte de 5 minutos captura la información del tiempo. Nota:
  [`A_corte_5_minutos_captura_tiempo.md`](../05_Notas/04_prediccion_lineal_observacional/A_corte_5_minutos_captura_tiempo.md).
- **`observacional_rmse_prueba_lineal`** (tabla): RMSE de prueba, una sola vez: 2.716
  (ingenuo), 2.314 (Taller 1) y 1.845 (lineal con corte y cruce), con la lectura en
  dólares y como % de la media. Nota:
  [`A_lineal_flexible_vs_taller1.md`](../05_Notas/04_prediccion_lineal_observacional/A_lineal_flexible_vs_taller1.md).

Contraste con lo registrado: todo consistente con el Taller 1 (2.314, 2.716, 0.49 y 3.98
reproducidos); la diferencia de 0.469 dólares del lineal flexible se atribuye a la
especificación lineal. Sin contradicciones.

## Pendientes

- Repetir la escalera en `ln(Revenue)` (el usuario pidió no entrar todavía) y probar si
  en logaritmo el tiempo continuo aporta algo más allá del corte (el Taller 1 usó su
  logaritmo).
- Agregar LASSO (`cv.glmnet`) y los árboles (P2.3 y P2.4) para cerrar P2.2 y P2.6;
  la tabla 2×2 de RMSE (P2.5) y la decisión de retransformar a dólares siguen abiertas.
- Falta P1.1, P1.3 y la relación con el registro (P1.2) en la descriptiva.
- No se corrió `00_main.R` completo ni `05_forma_funcional_observacional.R` después del
  cambio de nombre (carpeta de salida renombrada); correrlos y probar borrar `03_Resultados/`
  (P7.1).
- `PLAN.md` y el README todavía anuncian scripts futuros (`05_arboles`, `06_comparacion`,
  `07_validacion`, …) con números que chocan con el nuevo 05; renumerar al crearlos.
- El cruce y el corte se eligieron mirando la base completa (incluye `test`); si se quiere
  una evaluación más estricta, definir el cruce solo con `train`.
- Supuesto sin confirmar: el p-valor del MCO (2.2e-11) frente al del Taller 1 (1.8e-11)
  difiere probablemente por la corrección robusta; no se verificó.
