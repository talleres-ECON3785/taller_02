# Bitácora — 2026-10-24 (sesión 5): LASSO como benchmark lineal flexible y renumeración de scripts

## Resumen

Santiago Muñoz (`SantiagoMunozM`) pidió evaluar un modelo LASSO para predecir el
ingreso (`Revenue`, dólares), siguiendo la predicción lineal del script 04 pero
evaluando solo el modelo final, no la escalera. Se creó
`05_lasso_observacional.R` y el script de forma funcional pasó de 05 a 06.

Desarrollo:

1. **Renumeración.** `05_forma_funcional_observacional.R` pasó a `06_` (con su
   carpeta de figuras) y los scripts planificados se corrieron una posición
   (árboles 07, comparación 08, validación 09, ATE 10, heterogeneidad 11).
2. **LASSO.** Diccionario de regresores, 5 pliegues idénticos a los del script 04,
   dos λ (`lambda.min` titular y `lambda.1se`) y evaluación única en `test`.
   RMSE de prueba (dólares): 1.765 y 1.770, frente a 1.845 del lineal con
   quiebre y cruce y 2.314 del Taller 1.
3. **Tabla adicional** con el título "Comparación de los modelos lineales" (misma
   tabla de RMSE de prueba), a pedido del usuario.
4. **Crítica de la comparación y chequeo.** A raíz de la pregunta de si el lineal
   final ya capturaba la mayor parte de la ganancia, se agregó el ajuste de MCO sin
   penalización con los mismos términos (solo validación cruzada): iguala a LASSO,
   así que la mejora viene del diccionario y no de la regularización. La nota se
   corrigió (la primera versión atribuía la mejora también a la regularización).
5. **Corrección del diccionario.** Se detectó que dos columnas (sesiones y su
   cuadrado, cruzadas con "usuario recurrente") repetían exactamente las sesiones,
   porque los usuarios no recurrentes tienen 0 sesiones anteriores; se quitaron
   (76 a 74 columnas) y se añadió una verificación. Las cifras se movieron poco.

Estado de los "Siguientes objetivos" que traía `HANDOFF.md`: (1) P1.1, P1.3 y cierre
de P1.2 no se trabajaron; (2) P2.2 (resto) avanzó: LASSO en dólares hecho, falta la
escala `ln(Revenue)` de todos los benchmarks; (3) P2.3 (CART) no se trabajó. Se cerró
la tarea pendiente de correr `00_main.R` completo y la de renumerar el plan y el
README. No se perdieron observaciones (100,000 en la base observacional; 80,000 en
entrenamiento y 20,000 en prueba).

## Archivos

- Creados: `02_Scripts/05_lasso_observacional.R`;
  `03_Resultados/Tablas/05_lasso_observacional/` (`observacional_rmse_prueba_lasso`,
  `observacional_rmse_prueba_comparacion_lineales`, `observacional_lasso_coeficientes`,
  `observacional_lasso_vs_mco_validacion`; `.png` y `.csv`);
  `03_Resultados/Figuras/05_lasso_observacional/observacional_lasso_cv_lambda.png`;
  `05_Notas/05_lasso_observacional/A_lasso_vs_lineal_flexible.md`; esta bitácora.
- Modificados: `00_main.R`, `README.md`, `PLAN.md`, `CLAUDE.md` (fila de decisiones),
  `HANDOFF.md`, `05_Notas/README.md`, `02_Scripts/03_punto_partida.R` (referencia al
  script 06) y las tres notas de `05_Notas/03_punto_partida/` que citaban el script 05.
- Renombrados (`git mv`): `02_Scripts/05_forma_funcional_observacional.R` a
  `06_forma_funcional_observacional.R` y la carpeta
  `03_Resultados/Figuras/05_forma_funcional_observacional/` a `06_...` (cambió
  también `carpeta_salida` y el mensaje final del script).
- Eliminados: ninguno.

## Detalle por archivo

### `02_Scripts/05_lasso_observacional.R`
**Estimando / estimador / estimación.** El estimando no es causal: predecir
`Revenue` (dólares) de un usuario nuevo. El estimador es LASSO (`cv.glmnet`,
`alpha = 1`). Las estimaciones son los RMSE y los coeficientes. Todo en dólares; el
RMSE de `ln(Revenue)` no es comparable.

**Diseño.** Misma partición 80/20 con `set.seed(2026)` que el Taller 1 y el script 04
(reproduce 2.716 y 2.314; el script se detiene si no). Los 5 pliegues se crean con
`caret::createFolds` y la misma semilla que el 04, y se pasan a `cv.glmnet` como
`foldid`, con `keep = TRUE`. `test` se toca una sola vez. El λ titular
(`lambda.min`) se declaró antes de ver `test`; `lambda.1se` se reporta en la misma
pasada, así que no se escoge entre los dos mirando `test`.

**Variables y piezas del estimador** (fuente: `07_Recursos/catalogo_metodos.md`,
sección 2, que resume el Lab 06, `03_lasso_sencillo.R` y `04_lasso_full.R`):
- *Diccionario de regresores* (`model.matrix(~ (...)^2)`): las variables del lineal
  final (indicador de más de 5 minutos, sesiones anteriores, dispositivo, sistema
  operativo, usuario recurrente, registro) más el tiempo continuo, su cuadrado y su
  logaritmo, el cuadrado de las sesiones y todas las interacciones de a pares.
  Rol: LASSO solo elige entre lo que se le ofrece (el catálogo lo dice
  explícitamente). El indicador y el cruce se incluyen para que la comparación con
  el lineal final sea justa; el cuadrado y el logaritmo le permiten aproximar el
  quiebre sin el indicador. Intuición: se le da una lista larga de variables y
  cruces y se deja que descarte los que no ayudan a predecir.
- *λ (`lambda.min`, `lambda.1se`)*: parámetro de penalización de la norma L1 de los
  coeficientes. `lambda.min` minimiza el error de validación cruzada; `lambda.1se` es
  el λ más regularizado cuyo error está a un error estándar del mínimo. Rol: controla
  cuántos términos se conservan (63 y 38) y cuánto se achican.
- *Estandarización*: `glmnet` estandariza las columnas por defecto (se deja así,
  como indica el catálogo); los coeficientes se devuelven en la escala original.
- *Coeficiente estandarizado* (coeficiente por la desviación estándar de la
  columna en entrenamiento): solo sirve para ordenar términos con escalas distintas;
  describe qué usa el modelo, no es un efecto ni una importancia causal.
- *RMSE por pliegue*: se calcula con las predicciones fuera de pliegue guardadas
  (`fit.preval`) en el λ elegido, para poder compararlo pliegue a pliegue con el
  lineal final y obtener errores estándar de diferencias pareadas.
- *Caída pareada*: RMSE del lineal final menos el del modelo, por pliegue; su error
  estándar es la desviación estándar entre los 5 pliegues dividida por la raíz de 5.
  El λ se elige con los mismos pliegues, así que la cifra de validación es algo
  optimista; la de prueba no tiene ese sesgo.

**Chequeo con MCO (sección 4b).** MCO sin penalización con (i) todos los términos del
diccionario y (ii) solo los que LASSO conserva, en los mismos pliegues. Intuición:
si MCO iguala a LASSO, la ganancia viene de lo que se ofrece, no de achicar
coeficientes. Con 80,000 observaciones y 74 columnas casi no hay sobreajuste que
corregir.

**Limpieza del diccionario.** Se quitan las columnas duplicadas
(`past_sessions:is_returning_user` y `I(past_sessions^2):is_returning_user`), con
`stopifnot` de que los usuarios no recurrentes tienen 0 sesiones y de que el rango de
`X` es completo. Al quitarlas el diccionario pasa de 76 a 74 columnas.

### `00_main.R`
Se agregaron el script a la lista `scripts` (antes del 06) y sus dos subcarpetas de
resultados a `carpetas_salida`; se actualizó la ruta del script 06. `glmnet` ya
estaba en `pacman::p_load()`.

### `README.md`, `PLAN.md`, `CLAUDE.md`, `05_Notas/README.md`
Mapa script → resultados con el script 05 y las rutas del 06; scripts planificados
renumerados (07 a 11); avance de P2.2 en `PLAN.md`; fila de "Decisiones tomadas"
(diccionario de 74 términos, solo modelo final, mismos pliegues, `lambda.min` titular,
renumeración); índice de notas con la del script 05.

## Resultados nuevos (tablas, figuras, gráficos)

Todos están explicados en la nota
[`A_lasso_vs_lineal_flexible.md`](../05_Notas/05_lasso_observacional/A_lasso_vs_lineal_flexible.md);
aquí solo qué busca comunicar cada uno y de dónde salen sus datos. Datos: base
observacional limpia (`observacional_limpio.Rds`), entrenamiento n = 80,000 y prueba
n = 20,000; `Revenue` en dólares.

- `Tablas/05_lasso_observacional/observacional_rmse_prueba_lasso` y
  `observacional_rmse_prueba_comparacion_lineales`: la misma tabla con dos títulos.
  Compara el error de prueba de la referencia ingenua, el lineal del Taller 1, el
  lineal con quiebre y cruce (estos tres leídos del `.csv` del script 04, no
  recalculados) y LASSO con los dos λ. Es el benchmark lineal contra el que se
  medirán los árboles.
- `observacional_lasso_coeficientes`: los 20 términos de mayor coeficiente
  estandarizado, con su coeficiente en cada λ. Busca mostrar qué usa el modelo
  (el cruce, el cuadrado de las sesiones) y que el tiempo continuo casi no se usa.
- `observacional_lasso_vs_mco_validacion`: validación cruzada del lineal final, MCO
  con 74 términos, MCO con los términos de LASSO y LASSO con los dos λ. Sustenta que
  la mejora viene del diccionario y no de la regularización.
- `Figuras/05_lasso_observacional/observacional_lasso_cv_lambda`: error de validación
  cruzada según log(λ), con los dos λ marcados; el eje se recorta a la zona de los λ
  elegidos (se declara en la nota al pie).

## Pendientes

- P2.2 (resto): la escalera lineal y LASSO en `ln(Revenue)`, incluida la prueba de si
  el tiempo continuo aporta algo en logaritmo; las notas deben decir qué cambia por
  la transformación.
- No se probó un diccionario sin el indicador de más de 5 minutos (mostraría si LASSO
  lo recupera solo). Es opcional; sería nota nueva.
- El corte de 5 minutos y el cruce se eligieron mirando la base completa (incluye
  `test`); sigue pendiente decidir si se redefinen solo con `train` para la
  comparación con árboles.
- Tareas heredadas sin hacer: P1.1, P1.3 y cierre de P1.2; P2.3 (CART); notas del
  script 06; borrar `03_Resultados/` y correr `00_main.R` a mano (P7.1); acentos
  faltantes en subtítulos y notas al pie; confirmar con el equipo la ampliación de
  `loess`; roles en `PLAN.md`; probar `guardar_tabla()` en la máquina de otro
  integrante; unir los `.jsonl` (P7.4).
- Supuesto sin confirmar: la sesión usó un worktree sin rama en
  `.claude/worktrees/lasso` por la protección de las sesiones en segundo plano; los
  commits se llevaron a `SantiagoMunozM` con avance rápido. El directorio
  `.claude/worktrees/` aparece como no versionado en el checkout principal.
