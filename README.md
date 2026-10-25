# Taller 2: CheMarket Inc.

Ciencia de Datos y Econometría Aplicada (ECON-3785, 2026-2), Universidad de los
Andes. Continuación del Taller 1 (repositorio `taller1/`).

## Objetivo

CheMarket Inc., empresa de comercio electrónico, quiere saber si debería invertir
en impulsar el registro (`sign_up`) de sus usuarios para aumentar sus ingresos
(`Revenue`). El Taller 1 respondió con regresión lineal. Este taller pregunta:

> ¿Cambian las conclusiones del Taller 1 cuando se usan métodos más flexibles
> (basados en árboles), capaces de representar relaciones no lineales,
> interacciones y diferencias entre grupos de usuarios?

Se modifican **dos cosas a la vez**: la variable dependiente (`ln(Revenue)` en
lugar de `Revenue`) y el método (árboles en lugar de regresión lineal). Por eso el
análisis usa un diseño 2×2 (forma funcional × método), que permite atribuir cada
diferencia con el Taller 1 a la transformación, al método o a ambos.

- **Parte A, predicción (base observacional):** qué variables predicen mejor
  `ln(Revenue)`, qué patrones aparecen con árboles y bosques, y cómo se compara su
  desempeño fuera de muestra con el de los modelos lineales.
- **Parte B, heterogeneidad (experimento):** ATE de `easier_signup` sobre
  `ln(Revenue)`, evidencia formal de HTE y CATE por grupo con bosque causal.

Las dos bases tienen roles distintos y no intercambiables:

| Base | Archivo crudo | Obs. | Qué permite |
| --- | --- | --- | --- |
| Observacional | `datos_historicos.Rds` | 100,000 | Describir y predecir. No identifica el efecto causal de aumentar el registro. |
| Experimento (A/B) | `datos_experimento.Rds` | 10,000 | Estimar el efecto causal de `easier_signup` (registro facilitado), por asignación aleatoria. |

## Cómo ejecutar

Basta con correr `00_main.R`. No hay que instalar nada a mano.

1. Abrir `taller_02.Rproj` en RStudio (fija el directorio de trabajo en la raíz).
2. Ejecutar `00_main.R` completo, por ejemplo con `source("00_main.R")`.

`00_main.R` verifica que el directorio de trabajo es la raíz, instala y carga con
`pacman` todos los paquetes del proyecto, crea las carpetas de salida que falten y
ejecuta los scripts de `02_Scripts/` en el orden de su numeración. Borrar
`03_Resultados/` y volver a correr `00_main.R` regenera todo.

Notas:

- Los scripts de `02_Scripts/` no cargan paquetes ni crean carpetas. Para correr
  uno suelto, primero se ejecutan las secciones 1 a 3 de `00_main.R`.
- Cualquier análisis con componente aleatorio usa `set.seed(2026)`.
- Las tablas `.png` se generan con `gt` y Chrome/Chromium en modo headless. Si
  Chrome no está en la ruta habitual, definir la variable de entorno `CHROME_PATH`.
- Los datos crudos de `01_Datos/01_Crudos/` nunca se modifican.

## Estructura de carpetas

```
taller_02/
├── 00_main.R               script maestro: corre todo el pipeline
├── README.md               este archivo
├── PLAN.md                 plan de implementación (hitos H0–H7, tareas Pk.n)
├── HANDOFF.md              estado actual, siguientes objetivos y registro de sesiones
├── CLAUDE.md               reglas del proyecto
├── taller_02.Rproj         proyecto de RStudio
├── 01_Datos/
│   ├── 01_Crudos/          datos originales (no se modifican)
│   ├── 02_Procesados/      datos limpios o transformados
│   └── 03_Listos/          bases finales que ingresan al análisis
├── 02_Scripts/             scripts de R
├── 03_Resultados/
│   ├── Tablas/             tablas exportadas (.png de la diapositiva y .csv sin formato), en una subcarpeta por script
│   └── Figuras/            figuras exportadas (.png, 9×6 pulgadas, 300 dpi), en una subcarpeta por script
├── 04_Presentaciones/      borradores de la presentación
├── 05_Notas/               una nota por hallazgo principal (índice en su README)
├── 06_Bitacoras/           documentación de cada sesión de trabajo
├── 07_Recursos/            enunciado, retroalimentación del Taller 1, heurísticas
│                           y catálogo de métodos
├── 08_Entregables/         presentación final (slides y enlace al video)
└── 09_Conversaciones/      registros crudos de las conversaciones (no se versiona)
```

## Métodos

El trabajo se limita al catálogo `07_Recursos/catalogo_metodos.md`: regresión
lineal (`lm`, `sandwich`, `fixest`, validación cruzada con `caret`), LASSO
(`glmnet`), árboles de regresión (`rpart`, `rpart.plot`), bagging y bosques
aleatorios (`ranger`) y bosques causales (`grf`). La regresión lineal del Taller 1
se mantiene como modelo de referencia en las dos partes.

Para que la comparación con el Taller 1 sea limpia, la partición es 80/20 con
semilla 2026 y la métrica es el RMSE fuera de muestra. El RMSE en `Revenue` y en
`ln(Revenue)` tienen unidades distintas y no se comparan directamente.

## Mapa script → resultados

Cada tabla o figura de la presentación se rastrea al script que la genera.
Convención de nombres: `03_Resultados/{Tablas,Figuras}/<script>/<base>_<contenido>.<ext>`,
con `<script>` = nombre del script que lo genera (sin `.R`) y `<base>` =
`observacional` o `experimento`. Cada script que genera resultados tiene su
subcarpeta, creada por `00_main.R`.

### Scripts existentes

| Script | Qué hace | Entradas | Salidas |
| --- | --- | --- | --- |
| `00_formato_graficas.R` | Define paleta, tema y `guardar_figura()`. No genera figuras ni va en `00_main.R`; lo cargan con `source()` los scripts que grafican. | — | — |
| `00_formato_tablas.R` | Define estilo de tablas y `guardar_tabla()`. No genera tablas ni va en `00_main.R`; lo cargan con `source()` los scripts que exportan tablas. | — | — |
| `01_limpieza_observacional.R` | Limpia la base observacional y construye `log_revenue` (se detiene si algún `Revenue <= 0`). | `01_Datos/01_Crudos/datos_historicos.Rds` | `01_Datos/03_Listos/observacional_limpio.Rds`; `03_Resultados/Tablas/01_limpieza_observacional/reporte_calidad_observacional_embudo.csv`; `03_Resultados/Tablas/01_limpieza_observacional/reporte_calidad_observacional.csv` |
| `02_limpieza_experimento.R` | Limpia la base del experimento y construye `log_revenue`. | `01_Datos/01_Crudos/datos_experimento.Rds` | `01_Datos/03_Listos/experimento_listos.RDS` |

### Scripts previstos (por llenar)

Nombres tomados de `PLAN.md`; se agregan a la lista `scripts` de `00_main.R` y a
esta tabla en la misma sesión en que se crean.

| Script | Hito | Resultados esperados |
| --- | --- | --- |
| `03_punto_partida.R` | H1 | `Revenue` en nivel (dólares) frente a cada covariable: `03_Resultados/Figuras/03_punto_partida/`: `observacional_revenue_tiempo_sesion`, `_sesiones_pasadas`, `_dispositivo`, `_sistema_operativo`, `_recurrente` y `_tiempo_por_sesiones` (un solo panel, curvas loess; `.png`) |
| `05_lasso_observacional.R` | H2 | LASSO (`cv.glmnet`) de `Revenue` (dólares) con un diccionario de 74 términos, mismos pliegues que el script 04 y evaluación única en `test`: `03_Resultados/Tablas/05_lasso_observacional/`: `observacional_rmse_prueba_lasso`, `observacional_rmse_prueba_comparacion_lineales` (la misma tabla con título de comparación de los modelos lineales) y `observacional_lasso_coeficientes` y `observacional_lasso_vs_mco_validacion` (MCO sin penalización con los mismos términos, solo validación cruzada; `.png` y `.csv`); y `03_Resultados/Figuras/05_lasso_observacional/`: `observacional_lasso_cv_lambda` (`.png`) |
| `06_ate_experimento_niveles.R` | H3 | Efecto de `easier_signup` sobre `Revenue` en dólares, con balance, cumplimiento y representatividad, en `03_Resultados/Tablas/06_ate_experimento_niveles/` (`.png` y `.csv`): `experimento_cumplimiento` (`easier_signup` × `sign_up`), `experimento_balance` (diferencia de medias por característica y prueba conjunta), `experimento_representatividad` (experimento frente a la base histórica, diferencia de medias y prueba conjunta) y `experimento_ols_registro` (MCO sin controles y con los controles del lineal final de la predicción, errores HC1); y la comprobación de que los patrones de esos controles también están en el experimento: `experimento_patrones_quiebre_cruce` (salto de 5 minutos y cruce con sesiones, frente a la base histórica) y `experimento_escalera_rmse` (escalera de validación cruzada de ambas bases), y en `03_Resultados/Figuras/06_ate_experimento_niveles/`: `experimento_revenue_tiempo_sesion`, `experimento_revenue_tiempo_por_sesiones` y `experimento_escalera_caida_rmse` (`.png`). Lee las tablas de 04 |
| `07_forma_funcional_observacional.R` | H1 | Las mismas figuras con `ln(Revenue)` en `03_Resultados/Figuras/07_forma_funcional_observacional/`: `observacional_lnrevenue_*` (`.png`). Más `observacional_distribucion_ingreso_dos_escalas` (densidad de `Revenue` frente a `ln(Revenue)`) y, en `03_Resultados/Tablas/07_forma_funcional_observacional/`, `observacional_distribucion_ingreso` y `observacional_puente_media_dolares`. Más `observacional_lnrevenue_registro` (figura: ingreso de registrados y no registrados) y `observacional_punto_partida_taller1` (tabla: cifras del Taller 1 frente a su reproducción) |
| `08_ate_experimento_log.R` | H3 | ITT sobre `ln(Revenue)` y regreso a dólares, en `03_Resultados/Tablas/08_ate_experimento_log/`: `experimento_ols_registro_log`, `experimento_log_a_dolares`, `experimento_descomposicion_media`, `experimento_cuantiles_por_grupo` y `experimento_efecto_cola`; y en `.../Figuras/08_ate_experimento_log/`: `experimento_distribucion_lnrevenue_por_grupo`. El ATE del bosque causal está en el script 12 |
| `04_prediccion_lineal_observacional.R` | H2 | Escalera de modelos lineales de `Revenue` (dólares) con RMSE de validación cruzada en `train`, aporte de cada variable y evaluación única en `test`: `03_Resultados/Tablas/04_prediccion_lineal_observacional/`: `observacional_escalera_rmse`, `observacional_importancia_variables`, `observacional_rmse_prueba_lineal`, `observacional_robustez_forma_tiempo` (`.png` y `.csv`); y `03_Resultados/Figuras/04_prediccion_lineal_observacional/`: `observacional_escalera_rmse` y `observacional_orden_tiempo_corte` (`.png`) |
| `09_arboles_observacional.R` | H2 | Árbol de regresión (CART, `rpart`) con las 6 variables del Taller 1, en dólares y en logaritmo, podado con la regla del mínimo y la 1-SE (titular), solo con `train`: `03_Resultados/Tablas/09_arboles_observacional/`: `observacional_cart_poda` (RMSE de validación cruzada frente al lineal final; el `.csv` lo lee el 11) y `observacional_cart_cortes` (`.png` y `.csv`); y `03_Resultados/Figuras/09_arboles_observacional/`: `observacional_cart_arbol_dolares`, `observacional_cart_arbol_log` y `observacional_cart_importancia` (`.png`) |
| `10_bosque_observacional.R` | H2 | Bagging y bosque aleatorio (`ranger`) en dólares y en logaritmo, con rejilla de hiperparámetros por error fuera de bolsa e importancia por permutación, solo con `train`: `03_Resultados/Tablas/10_bosque_observacional/`: `observacional_bosque_elegido` (`.png` y `.csv`; el `.csv` lo lee el 11); y `03_Resultados/Figuras/10_bosque_observacional/`: `observacional_bosque_rejilla` y `observacional_bosque_importancia` (`.png`) |
| `11_comparacion_prediccion_observacional.R` | H2 | Evaluación única en `test` de la matriz método × forma funcional (ingenuo, lineal del Taller 1, lineal final, LASSO, árbol y bosque; dólares, logaritmo y logaritmo llevado a dólares con *smearing* de Duan): `03_Resultados/Tablas/11_comparacion_prediccion_observacional/observacional_rmse_prueba_comparacion` (`.png` y `.csv`) y `03_Resultados/Figuras/11_comparacion_prediccion_observacional/observacional_rmse_prueba_comparacion` (`.png`). Lee las tablas de 09 y 10 |
| `12_heterogeneidad_experimento.R` | H3, H4 | Bosque causal (`grf`, 2,000 árboles) sobre `ln(Revenue)`, sobre `Revenue` en dólares y sin `time_spent`: `03_Resultados/Tablas/12_heterogeneidad_experimento/`: `experimento_ate_lineal_vs_bosque` (ATE de MCO frente al bosque en las dos escalas), `experimento_calibracion_bosque` (prueba de calibración), `experimento_rate_autoc` (AUTOC y efecto por tercil de prioridad con muestra dividida), `experimento_cate_por_grupo` (efecto por grupo predefinido con su peso en la base histórica), `experimento_importancia_bosque_causal` y `experimento_robustez_sin_tiempo` (`.png` y `.csv`); y `03_Resultados/Figuras/12_heterogeneidad_experimento/`: `experimento_cate_ordenados`, `experimento_toc` y `experimento_cate_por_grupo` (`.png`). Lee las tablas de MCO de 06 y 08 |

## Documentación del trabajo

- `PLAN.md`: hitos y tareas con casillas de verificación.
- `HANDOFF.md`: dónde estamos y qué sigue; es el punto de entrada para retomar.
- `06_Bitacoras/`: qué se hizo en cada sesión y por qué.
- `05_Notas/`: qué se encontró, con referencia a tablas y figuras.
- `07_Recursos/heuristicas_retroalimentacion_taller1.md`: heurísticas H1–H11 y
  lista de chequeo derivadas de la retroalimentación del Taller 1.

## Trabajo en equipo

Repositorio: <https://github.com/talleres-ECON3785/taller_02>. Cada integrante
trabaja en su propia rama (nombre + primer apellido + inicial del segundo) y nadie
hace commit directo a `main`.

| Integrante | Rama |
| --- | --- |
| Samuel Escandón | `SamuelEscandonC` |
| Douglas Plazas Guzmán | `DouglasPlazasG` |
| Mateo Olmos Becerra | `MateoOlmosB` |
| Santiago Muñoz Martínez | `SantiagoMunozM` |

Entrega del video, los slides y el material de soporte: domingo 25 de octubre de
2026.
