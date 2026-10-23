# Bitácora — 2026-10-23: catálogo de métodos, librerías y funciones

## Resumen

Integrante: Santiago Muñoz (rama `SantiagoMunozM`).

Objetivo: delimitar qué métodos, paquetes y funciones de R se pueden usar en
el Taller 2, a partir de los laboratorios del curso, y dejar en `CLAUDE.md`
la regla de que el trabajo se limita a ese catálogo y de que toda ampliación
se documenta primero en él. No se estimó ningún modelo ni se construyó
`ln(Revenue)`.

Desarrollo:

1. Al empezar, `origin/main` iba tres commits adelante (el PR #1 ya fusionado,
   con un cambio de una línea en `CLAUDE.md`). Se trajo con un avance rápido
   (`git merge --ff-only origin/main`), sin conflictos. Esto resuelve el bloqueo
   del handoff anterior ("`SantiagoMunozM` está atrás de `main`").
2. Se revisaron los laboratorios 04 a 10 (las versiones en Markdown de los
   enunciados en `Insumos MD/` y los scripts con que el equipo los resolvió en
   `Laboratorios/`), el script de predicción del Taller 1 (para la partición
   80/20) y el `00_main.R` actual. El Laboratorio 11 (texto) se dejó fuera por
   no aplicar al taller.
3. Se escribió `07_Recursos/catalogo_metodos.md` con seis métodos: regresión
   lineal, LASSO, árbol de regresión, bagging y bosque aleatorio, árbol causal
   honesto y bosque causal.
4. Por decisión del equipo, se retiró después el **árbol causal individual**
   (Athey e Imbens 2016, Laboratorio 09): no se usará. La heterogeneidad de la
   Parte B se estimará solo con el bosque causal. Quedó en "Análisis
   descartados" de `CLAUDE.md` y en "Fuera del catálogo".
5. Se actualizó `CLAUDE.md` para que apunte al catálogo y para que las
   ampliaciones se registren antes de usarse.

Frente a los "Siguientes objetivos" del handoff anterior: ninguno de los tres
(descriptiva de `ln(Revenue)`, Parte A, Parte B) se trabajó directamente. Sí
avanzó el bloqueo "elegir paquetes de árboles y de bosques causales": el
catálogo fija las opciones (`rpart`, `ranger`, `grf`), aunque falta decidir qué
métodos entran a cada parte.

## Archivos

- Creados:
  - `07_Recursos/catalogo_metodos.md`
  - `06_Bitacoras/2026-10-23_catalogo-metodos.md`
- Modificados:
  - `CLAUDE.md`
  - `HANDOFF.md`
- Eliminados: ninguno.

## Detalle por archivo

### `07_Recursos/catalogo_metodos.md`

Documento de referencia obligatorio antes de escribir un script de
estimación. Estructura:

- **Reglas de uso.** El trabajo se limita a lo que está en el catálogo. Lo que
  se agregue se anota antes en el "Registro de ampliaciones" (qué, para qué,
  fuente, quién lo aprobó) y en "Decisiones tomadas". Los paquetes se cargan
  solo en el `p_load()` de `00_main.R`.
- **Tabla resumen:** método → laboratorio → paquete → funciones → cómo se
  eligen los hiperparámetros → para qué se usa en el taller.
- **Convenciones comunes.**
  - *Semilla:* `ranger` y `causal_forest` tienen su propio argumento `seed`,
    así que `set.seed()` no basta (Labs 08 y 10). En `rpart` y `cv.glmnet` la
    CV es aleatoria y la semilla va justo antes de la llamada.
  - *Partición:* manda la del Taller 1 (80/20, `set.seed(2026)`,
    `sample(seq_len(n), size = round(0.8 * n))`), no la de los Labs 07 y 08
    (70/30, semilla 123). Así la comparación con el Taller 1 queda limpia.
  - *Métrica:* RMSE fuera de muestra con la media de entrenamiento como
    referencia ingenua. El RMSE en `ln(Revenue)` está en unidades
    logarítmicas; para comparar con el Taller 1 hay que llevar las
    predicciones a dólares (Lab 04, Extensión A).
- **Por método:** la fuente (laboratorio y scripts), un bloque de código de
  referencia adaptado a las variables de CheMarket, los argumentos clave y las
  advertencias.
  - *Lineal:* `lm`, `sandwich::vcovHC("HC1")`, `fixest::feols(vcov = "hc1")`
    con `etable`, y CV con `caret` (regla del Lab 05).
  - *LASSO:* `model.matrix` → `glmnet(alpha = 1)` → `cv.glmnet`, con
    `lambda.min` o `lambda.1se`.
  - *CART:* `rpart(method = "anova", cp = 0, xval = 10)`, `printcp`/`cptable`,
    regla del mínimo o 1-SE y `prune`. `rpart.plot` toma la paleta de
    `00_formato_graficas.R`, no `"Greens"`.
  - *Bagging/bosque:* `ranger` con selección por error OOB sobre una rejilla de
    `mtry` × `min.node.size`, y `predict(..., data = test)$predictions`.
  - *Bosque causal:* `causal_forest`, `average_treatment_effect`,
    `predict(cf)` fuera de bolsa, `get_forest_weights`, `test_calibration`,
    `variable_importance` y `rank_average_treatment_effect` (TOC/AUTOC) con
    muestras de entrenamiento y evaluación separadas.
- **Adaptación a CheMarket.** En los Labs 09 y 10 la aleatorización era por
  colegio (errores agrupados, `clusters`). En el experimento de CheMarket
  `easier_signup` se asigna por usuario: errores robustos sin agrupar, sin
  `clusters` y particiones por usuario. En el Lab 10, `W.hat = 0.5` se fijó
  porque la probabilidad de asignación era conocida. En CheMarket se fija con
  la probabilidad del diseño si se conoce; si no, `grf` la estima y se
  registra la decisión.
- **Herramientas previstas, no cubiertas en los laboratorios.** Hay tres que
  el enunciado o `CLAUDE.md` parecen necesitar, pero que no aparecen en el
  código de los laboratorios: (i) importancia de variables en `ranger`/`rpart`
  (Parte A); (ii) `predict(cf, estimate.variance = TRUE)` (intervalos por
  CATE); (iii) `average_treatment_effect(cf, subset = ...)` (ATE por
  subgrupo). Quedaron "sin registrar": no se usan hasta que se anoten como
  ampliación.
- **Fuera del catálogo:** boosting, el árbol causal individual, `causalTree`,
  `randomForest`, `tidymodels`/`rsample`/`boot`, y familias ajenas a lo lineal
  y a los árboles.

Intuición: si el equipo usa las mismas funciones que el curso, cada
estimación se puede contrastar con lo visto en clase. Además, se evita que un
agente meta un método o una opción que nadie del equipo revisó.

### `CLAUDE.md`

- *Estructura del proyecto:* la descripción de `07_Recursos/` menciona el
  catálogo.
- *Regla metodológica:* se agregaron dos viñetas. "Catálogo cerrado de
  métodos" lista los paquetes y obliga a leer el catálogo antes de escribir un
  script de estimación. "Ampliar el catálogo" dice que todo lo nuevo se
  registra antes de usarse. Se quitó boosting de los ejemplos de ensambles y
  los árboles causales de lo que exige la Parte B (queda el bosque causal).
- *Reglas estrictas:* la regla sobre familias de modelos ahora remite al
  catálogo y a su registro de ampliaciones.
- *Decisiones tomadas:* nueva fila (2026-10-23) sobre el catálogo cerrado,
  que deja fuera boosting y el árbol causal individual.
- *Análisis descartados:* nueva fila (2026-10-23) para el árbol causal
  individual. Fue una decisión del equipo y en la sesión no se dio una razón
  adicional.

## Pendientes

- Decidir qué métodos del catálogo entran a cada parte (p. ej. si LASSO entra
  como benchmark adicional en la Parte A) y registrarlo en "Decisiones tomadas".
- Decidir si se registran las tres herramientas previstas (importancia de
  variables, varianza de los CATE, ATE por subgrupo). Sin ellas, hay preguntas
  del enunciado (qué variables predicen mejor, intervalos por CATE) que quedan
  sin herramienta.
- Confirmar la probabilidad de asignación de `easier_signup` en el diseño del
  experimento, que define el `W.hat` del bosque causal.
- Agregar los paquetes del catálogo (`glmnet`, `rpart`, `rpart.plot`,
  `ranger`, `grf`, `fixest`/`sandwich`, `caret`) al `p_load()` de `00_main.R`
  a medida que se creen los scripts que los usan.
- Siguen abiertos los objetivos anteriores: descriptiva de `ln(Revenue)`,
  Parte A y Parte B.
