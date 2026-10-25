# Fase 0. Inventario (auditoría, 2026-10-25)

Fuente: lectura de `02_Scripts/*.R` (grep de `readRDS`, `read_csv`, `guardar_tabla`,
`guardar_figura`, `write_csv`), de `03_Resultados/` y de `05_Notas/`. Los archivos de
raíz (`00_main.R`, `CLAUDE.md`, `PLAN.md`, `HANDOFF.md`, `README.md`) se agregaron a
esta carpeta durante la auditoría; son idénticos byte a byte a los de `../taller_02/`,
y todo el contenido (scripts, notas, datos, resultados, bitácoras, recursos) también
(`diff -rq`, ignorando `.git`). Solo faltan aquí `.claude/` (skills), `.gitignore` y
`.Rhistory`. En las dos carpetas falta el PDF "Comentarios para Material de soporte"
que cita `heuristicas_retroalimentacion_taller1.md`.

## 1. Mapa de scripts

T = `03_Resultados/Tablas/<script>/`, F = `03_Resultados/Figuras/<script>/`.
Preguntas: A1 variables útiles, A2 patrones de árboles, A3 desempeño vs. lineales,
A4 qué cambia con ln, A5 qué se mantiene del T1; B1 ATE en log, B2 HTE, B3 cómo
varían los CATE, B4 características que separan, B5 grupos mayor/menor/≈0,
B6 relación con el ATE del T1, B7 implicaciones; E1–E5 estructura sugerida.

| Script | Lee | Produce | Responde |
| --- | --- | --- | --- |
| 01_limpieza_observacional | `01_Crudos/datos_historicos.Rds` | `03_Listos/observacional_limpio.Rds`; T: `reporte_calidad_observacional{,_embudo}.csv` (sin .png) | Soporte. Encabezado dice "Taller 1". Atípicos marcados "Pendiente de decision del equipo" |
| 02_limpieza_experimento | `01_Crudos/datos_experimento.Rds` | `03_Listos/experimento_listos.RDS` | Soporte. Sin tabla de pérdidas exportada |
| 03_punto_partida | `observacional_limpio` | F: 6 figuras de `Revenue` vs. tiempo, sesiones, dispositivo, SO, recurrente, tiempo×sesiones | E1, H3 en dólares |
| 04_prediccion_lineal_observacional | `observacional_limpio` | T: `escalera_rmse`, `importancia_variables`, `rmse_prueba_lineal`, `robustez_forma_tiempo`; F: `escalera_rmse`, `orden_tiempo_corte` | A1 y A3, **solo en dólares** |
| 05_lasso_observacional | `observacional_limpio`; T04 `rmse_prueba_lineal.csv` | T: `lasso_coeficientes`, `lasso_vs_mco_validacion`, `rmse_prueba_lasso`, `rmse_prueba_comparacion_lineales`; F: `lasso_cv_lambda` | A3 (benchmark lineal flexible), solo dólares |
| 06_ate_experimento_niveles | `experimento_listos`, `observacional_limpio`; T04 `escalera_rmse`, `robustez_forma_tiempo` | T: `balance`, `cumplimiento`, `representatividad`, `ols_registro`, `patrones_quiebre_cruce`, `escalera_rmse`; F: `revenue_tiempo_sesion`, `revenue_tiempo_por_sesiones`, `escalera_caida_rmse` | Validez (H7, H9), ATE en dólares (E1, B6) |
| 07_forma_funcional_observacional | `observacional_limpio`, `experimento_listos`, T04 | F: 7 `lnrevenue_*` + `distribucion_ingreso_dos_escalas`; T: `distribucion_ingreso`, `puente_media_dolares`, `punto_partida_taller1` | A4, E1, E2 |
| 08_ate_experimento_log | `experimento_listos` | T: `ols_registro_log`, `log_a_dolares`, `descomposicion_media`, `cuantiles_por_grupo`, `efecto_cola`; F: `distribucion_lnrevenue_por_grupo` | B1, B6, H2 |
| 09_arboles_observacional | `observacional_limpio` (solo `train`) | T: `cart_poda` (lo lee 11), `cart_cortes`; F: `cart_arbol_dolares`, `cart_arbol_log`, `cart_importancia` | A1, A2 |
| 10_bosque_observacional | `observacional_limpio` (solo `train`) | T: `bosque_elegido` (lo lee 11); F: `bosque_rejilla`, `bosque_importancia` | A1, A3 (OOB) |
| 11_comparacion_prediccion_observacional | `observacional_limpio`; T09 `cart_poda`, T10 `bosque_elegido` | T y F: `rmse_prueba_comparacion` | A3, A4, E2–E4 |
| 12_heterogeneidad_experimento | `experimento_listos`, `observacional_limpio` (pesos); T06 `ols_registro`, T08 `ols_registro_log` | T: `ate_lineal_vs_bosque`, `calibracion_bosque`, `rate_autoc`, `cate_por_grupo`, `importancia_bosque_causal`, `robustez_sin_tiempo`; F: `cate_ordenados`, `toc`, `cate_por_grupo` | B1–B7 |

Dependencias por lectura de `.csv`: 05←04, 06←04, 07←04, 11←09 y 10, 12←06 y 08.
El orden de `00_main.R` las respeta.

## 2. Preguntas sin respuesta (o con respuesta parcial)

| Pregunta | Estado | Qué falta |
| --- | --- | --- |
| A1 en `ln(Revenue)` con caída de RMSE fuera de muestra (H5) | Parcial | La escalera de RMSE existe solo en dólares (04). En log, A1 se responde solo con importancia por permutación (09, 10), que es uso del modelo y no caída de RMSE. La rúbrica del T1 pidió explícitamente la escalera. |
| B7 implicaciones: valor de la regla de focalización | Falta | Ninguna tabla estima el ingreso por usuario de "computador y tableta" frente a "todos" o "nadie", ni su IC. La síntesis lo hace a mano. |
| B6 / H2: descomposición del ATE en efectos por grupo y pesos | Falta | Nada muestra que Σ peso × CATE reproduce el ATE en cada escala, ni el puente log→dólares por grupo (Fase 5). |
| B3/B5: tabla dispositivo × SO | Falta | Los grupos son marginales; no hay celdas cruzadas ni su tamaño (Fase 6). |
| P3.3: intervalos de los cuantiles por brazo | Falta | Abierto en `PLAN.md`. |
| E5 / presentación | Falta | `04_Presentaciones/` y `08_Entregables/` vacíos: sin guion (P6.1), slides (P6.2) ni video (P6.4). Es el bloqueo principal de hoy. |
| P5.3 lista de chequeo H1–H10 | Falta | Pendiente en la síntesis. |
| P7.1 / P7.2 | Parcial | README: el mapa pone scripts existentes bajo "Scripts previstos (por llenar)". |

## 3. Salidas que no responden a ninguna pregunta o duplican otra

| Salida | Observación |
| --- | --- |
| T05 `rmse_prueba_lasso` y `rmse_prueba_comparacion_lineales` | Mismo contenido (`.csv` idénticos salvo título). Duplicado. |
| T04 `rmse_prueba_lineal` | Contenida en T05 y T11. |
| T06 `escalera_rmse`, `patrones_quiebre_cruce` y F06 `revenue_tiempo_*`, `escalera_caida_rmse` | Justifican los controles del ITT (que solo ganan precisión). No responden una pregunta del enunciado; material de apéndice. |
| F03 y F07 `*_recurrente` | El propio script dice que no agrega información: en la base histórica `is_returning_user = 1` sii `past_sessions > 0`. |
| T01 `reporte_calidad_observacional` | Deja "Pendiente de decisión del equipo" sobre atípicos; la decisión (mantenerlos) nunca se registró. |
| T12 `importancia_bosque_causal` | Útil como apoyo (dónde corta el bosque), no responde por sí sola. |

## 4. Cifras de `05_Notas/sintesis.md` y su fuente

✓ = la cifra coincide con el `.csv` versionado; ⚠ = sin `.csv` o con problema.

| Cifra en la síntesis | Fuente | Estado |
| --- | --- | --- |
| Calibración 1.01 (log), 1.06 (dólares), p < 0.001 | T12 `experimento_calibracion_bosque.csv` (1.0129; 1.0586) | ✓ |
| AUTOC 0.200 (log), 1.41 dólares, n = 5,000 | T12 `experimento_rate_autoc.csv` | ✓ |
| Computador +0.163 (0.140–0.186); +1.18 (1.03–1.34); 40.0% | T12 `experimento_cate_por_grupo.csv` | ✓ |
| Tableta +0.138 (0.093–0.183); +0.88 (0.62–1.14); 9.9% | ídem | ✓ |
| Celular −0.152 (−0.173 a −0.131); −0.30 (−0.40 a −0.20); 50.1% | ídem | ✓ |
| osx +0.213 / +1.50; Windows −0.089 / −0.05 | ídem | ✓ |
| Dispositivo 61% de los cortes | T12 `experimento_importancia_bosque_causal.csv` (61.08) | ✓ |
| Celular 50.1% vs. 49.8%; F = 0.66, p = 0.708 | T06 `experimento_representatividad.csv` | ✓ |
| Balance F = 0.96, p = 0.456; cumplimiento 5,043 / 4,957 | T06 `experimento_balance.csv`, `experimento_cumplimiento.csv` | ✓ |
| "osx es de computadores y tabletas" | Ninguna | ⚠ Afirmación sin tabla (Fase 6) |
| 0.41 y 0.56 dólares por usuario; pérdida evitada 0.15 | Aritmética con T12 (0.4089; 0.5601; 0.1512) | ⚠ Sin tabla ni IC (lo declara la síntesis) |
| Tiempo + sesiones 93% (dólares) y 94.5% (log); SO 4.7%, dispositivo 2.2%; registro 0.03% | Solo F10 `observacional_bosque_importancia.png` vía nota `A_importancia_bosque` | ⚠ Sin `.csv` de respaldo |
| Más de 5 min 0.84 vs. 0.16; 5+ sesiones 1.28 vs. 0–2 −0.19 | T12 `experimento_cate_por_grupo.csv` | ✓ |
| Registro −0.00001 en la escalera | T04 `observacional_escalera_rmse.csv` (−8.2e-6) | ✓ |
| Salto ≈ 3.13 (T1); corte 5.0007 min | T1 en `CLAUDE.md`; T07 `punto_partida_taller1.csv` da 3.07 en T2; 5.0007 solo en notas (T09 muestra "< 5.001") | ⚠ 5.0007 sin `.csv` |
| Elasticidad 0.169; asociación 0.080 en log | `CLAUDE.md` (Taller 1) | T1, no se reproduce |
| RMSE 2.716, 2.314 (14.8%), 1.845, 1.765, 1.627, 1.626 (40.1%); log 0.349 vs. 0.361; retransformados 2.382, 1.952, 1.627 | T11 `observacional_rmse_prueba_comparacion.csv` | ✓ |
| "Casi dos tercios de la ganancia vienen de la especificación; el resto del método (1.765 → 1.627)" | Aritmética con T11 | ⚠ Inconsistente: ver Fase 3 |
| MCO 0.491 (0.347–0.634), 0.454; bosque 0.414 (0.328–0.499) | T06 `experimento_ols_registro.csv`, T12 `experimento_ate_lineal_vs_bosque.csv` | ✓ |
| Log 0.0134 (−0.010–0.037); bosque 0.004 (−0.011–0.019) | T08 `experimento_ols_registro_log.csv`, T12 | ✓ |
| Desviación de ln 0.53 → 0.66; media +12%; mediana sin cambio | T08 `experimento_descomposicion_media.csv` (1.123), `experimento_cuantiles_por_grupo.csv` (−0.17%) | ✓ |
| p99 14.4 vs. 24.9 | T08 `experimento_cuantiles_por_grupo.csv` | ✓ |
