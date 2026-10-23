# Catálogo de métodos, librerías y funciones del Taller 2

Este documento fija **qué métodos se pueden usar en el Taller 2 y con qué
paquetes y funciones de R se estiman**. Se construyó revisando los
laboratorios del curso (Laboratorios 04 a 10, ECON-3785, 2026-2) y los scripts
con que el equipo los resolvió. Es la referencia obligatoria para escribir
cualquier script de análisis de este repositorio.

**Reglas de uso**

1. El trabajo del taller se limita a los métodos, paquetes y funciones de este
   catálogo. Si un método no aparece aquí, no se usa.
2. Si en algún momento el equipo decide agregar un método, un paquete o una
   función que no está aquí (p. ej. una opción de `grf` que no se vio en
   clase), **antes de usarlo** se documenta en la sección
   ["Registro de ampliaciones"](#registro-de-ampliaciones) al final de este
   archivo (qué se agrega, para qué, de dónde sale y quién lo aprobó) y se
   registra la decisión en la tabla "Decisiones tomadas" de `CLAUDE.md`.
3. Todos los paquetes se cargan **solo** en el `pacman::p_load()` de
   `00_main.R` (ver `CLAUDE.md`). Un paquete de este catálogo se agrega a esa
   lista en la misma sesión en que se crea el primer script que lo usa.

---

## Resumen

| Método | Laboratorio | Paquete | Funciones principales | Selección de hiperparámetros | Uso en el taller |
| --- | --- | --- | --- | --- | --- |
| Regresión lineal (MCO) | 02, 04, 05, 10; Taller 1 | `stats` (base), `sandwich`, `fixest` | `lm()`, `predict()`, `poly()`, `I()`, `vcovHC()`, `feols()`, `etable()` | No aplica. Para comparar especificaciones: partición train/validación (Lab 04) o CV con `caret` (Lab 05) | Referencia (benchmark) de las Partes A y B |
| Validación cruzada de modelos lineales | 05 | `caret` | `train(method = "lm")`, `trainControl()` | `method = "cv"`, `number = K`; `"LOOCV"` | Comparar especificaciones lineales sin tocar el conjunto de prueba |
| LASSO | 06 | `glmnet` | `model.matrix()`, `glmnet()`, `cv.glmnet()`, `coef()`, `predict()` | λ por validación cruzada (`lambda.min`, `lambda.1se`) | Benchmark lineal flexible de la Parte A (opcional) |
| Árbol de regresión (CART) | 07 | `rpart`, `rpart.plot` | `rpart()`, `rpart.control()`, `printcp()`, `prune()`, `predict()`, `rpart.plot()` | Poda por costo-complejidad: `cp` por CV interna (`xval`), regla del mínimo o 1-SE | Parte A: no linealidades e interacciones legibles |
| Bagging y bosque aleatorio | 08 | `ranger` | `ranger()`, `predict()`, `$prediction.error` | Error OOB sobre una rejilla de `mtry` × `min.node.size`; `num.trees` grande | Parte A: desempeño predictivo |
| Bosque causal | 10 | `grf`, `fixest` | `causal_forest()`, `average_treatment_effect()`, `predict()`, `test_calibration()`, `variable_importance()`, `rank_average_treatment_effect()`, `get_forest_weights()` | Valores por defecto de `grf` (honestidad activada), `num.trees ≥ 2000` | Parte B: ATE, CATE, evidencia formal de HTE y focalización |

El Laboratorio 11 (texto: tokens, TF-IDF, bigramas) no aplica al taller y no
se incluye.

---

## Convenciones comunes a todos los métodos

- **Semilla:** `set.seed(2026)` antes de cualquier paso aleatorio. Algunos
  paquetes tienen semilla propia y `set.seed()` **no basta**:
  `ranger(..., seed = 2026)` y `causal_forest(..., seed = 2026)` (Labs 08 y
  10). En `rpart` y `cv.glmnet` la validación cruzada es aleatoria, así que
  `set.seed(2026)` va justo antes de la llamada (Lab 07).
- **Partición train/test (Parte A):** la misma del Taller 1
  (`11_prediccion_revenue_observacional.R`), para que la comparación sea
  limpia:

  ```r
  set.seed(2026)
  indices_train <- sample(seq_len(n), size = round(0.8 * n))
  train <- datos[indices_train, ]
  test  <- datos[-indices_train, ]
  ```

  Ojo: los Labs 07 y 08 usan otra partición (70/30, `set.seed(123)`,
  `sample(c(TRUE, FALSE), ...)`). **No** se copia esa partición: en el taller
  manda la del Taller 1.
- **Métrica:** RMSE fuera de muestra (Lab 04).

  ```r
  rmse <- function(y, prediccion) sqrt(mean((y - prediccion)^2))
  ```

  La referencia ingenua es la media de `train` (como en el Taller 1 y el
  modelo M0 del Lab 04). El RMSE de `ln(Revenue)` está en unidades
  logarítmicas: para compararlo con el del Taller 1 hay que llevar las
  predicciones a dólares (Lab 04, Extensión A).
- **Hiperparámetros:** se eligen solo con `train` (CV interna, `xval` de
  `rpart`, `cv.glmnet` o error OOB de `ranger`). El conjunto de prueba se usa
  una sola vez, al final (Labs 07 y 08: "los carros de `test` no se tocan hasta
  el final").
- **Categóricas con pocas observaciones:** si una categoría aparece solo en
  `test`, `predict()` falla (Lab 04). Con `device_type` y `os_type` no debería
  pasar, pero se verifica.

---

## 1. Regresión lineal (referencia)

**Fuente:** Lab 02 (identificación por diseño, errores robustos), Lab 04
(sesgo-varianza, partición de validación), Lab 05 (validación cruzada),
Lab 10 (ATE con `fixest`); Taller 1.

**Estimación y predicción**

```r
modelo <- lm(log_revenue ~ sign_up + time_spent + past_sessions + device_type +
               is_returning_user + os_type, data = train)
prediccion <- predict(modelo, newdata = test)
rmse(test$log_revenue, prediccion)
```

- Para darle flexibilidad a la forma funcional: `poly(x, grado)`, `I(x^2)`,
  interacciones `a:b` o `a * b` (Lab 04, modelo M6).
- `lm()` usa como referencia la primera categoría de cada factor (orden
  alfabético salvo que se fije con `relevel()`/`factor(levels = ...)`).

**Errores estándar robustos (inferencia causal en el experimento)**

- Con `sandwich` (Lab 02):
  `vcovHC(modelo, type = "HC1")`, y la tabla con `modelsummary(..., vcov = "HC1")`.
- Con `fixest` (Lab 10):

  ```r
  itt     <- feols(log_revenue ~ easier_signup, data = experimento, vcov = "hc1")
  itt_x   <- feols(log_revenue ~ easier_signup + .[X], data = experimento, vcov = "hc1")
  etable(itt, itt_x, keep = "easier_signup", se.below = TRUE)
  ```

  `.[X]` agrega a la fórmula todas las variables cuyos nombres están en el
  vector `X`. En el Lab 10 se agrupan errores por colegio (`cluster`) porque
  la aleatorización fue por colegio; **en CheMarket la asignación es
  individual**, así que se usan errores robustos (`"hc1"`) sin agrupar.

**Validación cruzada de especificaciones lineales (Lab 05)**

```r
control <- trainControl(method = "cv", number = 10)   # o method = "LOOCV"
set.seed(2026)
ajuste <- train(formula, data = train, method = "lm", trControl = control)
ajuste$results$RMSE
```

En el Lab 05 la regla era hacer toda la CV con `caret` (`train()` y
`trainControl()`), sin `boot`, `rsample`, `tidymodels` ni ciclos escritos a
mano. Se mantiene.

---

## 2. LASSO

**Fuente:** Lab 06 (`03_lasso_sencillo.R`, `04_lasso_full.R`).

`glmnet` no recibe fórmulas: necesita una **matriz numérica** `X` y un
**vector** `y`. La matriz se arma con `model.matrix()` (se quita el
intercepto con `[, -1]`), y para `test` se usa la misma fórmula:

```r
formula <- ~ (time_spent + I(time_spent^2) + log(time_spent) + past_sessions) +
             (device_type + os_type + is_returning_user + sign_up)^2 + ...

X_train <- model.matrix(formula, train)[, -1]
y_train <- train$log_revenue
stopifnot(nrow(X_train) == length(y_train))     # cada fila de X es la misma obs. de y

trayectoria <- glmnet(X_train, y_train, alpha = 1)          # trayectoria completa de λ
plot(trayectoria, xvar = "lambda")

set.seed(2026)
cv_lasso <- cv.glmnet(X_train, y_train, alpha = 1)          # 10 pliegues por defecto
plot(cv_lasso)
coef(cv_lasso, s = "lambda.min")                            # o s = "lambda.1se"

X_test <- model.matrix(formula, test)[, -1]
prediccion <- predict(cv_lasso, newx = X_test, s = "lambda.min")
```

- `alpha = 1` es LASSO (`alpha = 0` es Ridge; 0 < `alpha` < 1, Elastic Net).
  En el curso se usa **siempre** `alpha = 1`.
- `glmnet` estandariza los regresores por defecto (`standardize = TRUE`); se
  deja así.
- Dos reglas para λ: `lambda.min` (mínimo error de CV) y `lambda.1se` (el
  modelo más regularizado a menos de un error estándar del mínimo).
- El diccionario de regresores (potencias, logaritmos, interacciones) lo
  propone el equipo con criterio económico; LASSO solo elige entre lo que se le
  ofrece (Lab 06, "el diccionario no sale de la nada").

---

## 3. Árbol de regresión (CART)

**Fuente:** Lab 07 (`04_rpart.R`, `05_poda.R`, `06_prediccion.R`).

```r
set.seed(2026)   # la CV interna de rpart es aleatoria
arbol_grande <- rpart(
  log_revenue ~ sign_up + time_spent + past_sessions + device_type +
    is_returning_user + os_type,
  data    = train,
  method  = "anova",                                   # y continua, pérdida cuadrática
  control = rpart.control(cp = 0, minbucket = 7, xval = 10)
)

printcp(arbol_grande)                 # secuencia de subárboles: CP, nsplit, rel error, xerror, xstd
secuencia <- as_tibble(arbol_grande$cptable)

cp_min <- secuencia %>% slice_min(xerror, n = 1, with_ties = FALSE)
cp_1se <- secuencia %>%
  filter(xerror <= cp_min$xerror + cp_min$xstd) %>%
  slice_min(nsplit, n = 1, with_ties = FALSE)

arbol_min <- prune(arbol_grande, cp = cp_min$CP)
arbol_1se <- prune(arbol_grande, cp = cp_1se$CP)

prediccion <- predict(arbol_min, newdata = test)       # promedio de la hoja de cada obs.
```

- Argumentos de `rpart.control()`: `minbucket` (mínimo de obs. por hoja,
  7 por defecto), `minsplit` (mínimo para intentar partir un nodo, 20 por
  defecto), `maxdepth`, `cp` (= α / SSR de la raíz; 0.01 por defecto) y `xval`
  (pliegues de la CV interna).
- Las categóricas se pasan como factores; no hay que construir indicadoras.
- Poda por costo-complejidad: se deja crecer un árbol grande (`cp = 0`) y se
  elige el subárbol con la regla del mínimo o la regla 1-SE.
- Gráfica del árbol:
  `rpart.plot(arbol, type = 2, extra = 101, digits = -5, roundint = FALSE, box.palette = ...)`.
  En el taller `box.palette` toma los colores de `00_formato_graficas.R`, no
  `"Greens"`, y la figura se guarda en `03_Resultados/Figuras/` siguiendo las
  reglas de formato de `CLAUDE.md`.

---

## 4. Bagging y bosque aleatorio

**Fuente:** Lab 08 (`03_bosque_a_mano.R`, `04_ranger.R`,
`05_hiperparametros.R`, `07_prediccion.R`).

```r
bosque <- ranger(
  log_revenue ~ sign_up + time_spent + past_sessions + device_type +
    is_returning_user + os_type,
  data            = train,
  num.trees       = 500,      # B: número de árboles
  mtry            = 6,        # = número de predictores -> bagging; menos -> bosque aleatorio
  min.node.size   = 5,        # un nodo con <= 5 obs. no se parte (5 por defecto en regresión)
  max.depth       = NULL,     # sin límite de profundidad
  replace         = TRUE,     # bootstrap con reemplazo...
  sample.fraction = 1,        # ...del mismo tamaño que train
  seed            = 2026      # ranger tiene su propia semilla
)

sqrt(bosque$prediction.error)                           # RMSE OOB (fuera de bolsa)
prediccion <- predict(bosque, data = test)$predictions  # ojo: data =, no newdata =
```

- **Bagging** es el caso `mtry` = número de predictores; el **bosque
  aleatorio** sortea `mtry` < p variables en cada corte. El valor por defecto
  de `ranger` es ⌊√p⌋, y el Lab 08 muestra que puede ser malo: se elige `mtry`.
- **Selección de hiperparámetros con el error OOB** (sin tocar `test`): se
  recorre una rejilla de `mtry` × `min.node.size` y se elige la combinación de
  menor RMSE OOB; luego se reestima con más árboles (p. ej. 1000).
- Lecciones del Lab 08 para fijar la rejilla: más árboles no sobreajustan
  (`num.trees` se fija grande, no se optimiza); árboles profundos son mejores
  dentro de un bosque (`min.node.size` pequeño, `max.depth` sin límite);
  `mtry` tiene un óptimo interior.
- El bagging "a mano" con `rpart` (muestras bootstrap con
  `sample(nrow(train), replace = TRUE)` y árboles con `cp = 0`, `minsplit = 6`,
  `minbucket = 1`, `xval = 0`) es ilustrativo; para resultados se usa `ranger`.
- Importancia de variables: el Lab 08 no la calcula (`Variable importance
  mode: none`). Ver ["Herramientas previstas, no cubiertas en los
  laboratorios"](#herramientas-previstas-no-cubiertas-en-los-laboratorios).

---

## 5. Bosque causal

**Fuente:** Lab 10 (`02_ate.R`, `03_cate.R`, `04_calibracion.R`,
`05_importancia.R`, `06_focalizar.R`). Paquete `grf` (Athey, Tibshirani y
Wager 2019, *Annals of Statistics*).

```r
X_mat <- model.matrix(~ time_spent + past_sessions + device_type +
                        is_returning_user + os_type, experimento)[, -1]  # grf exige matriz numérica
Y <- experimento$log_revenue
W <- experimento$easier_signup

cf <- causal_forest(X_mat, Y, W,
                    W.hat     = 0.5,     # probabilidad de asignación conocida (verificar en el diseño)
                    num.trees = 2000,    # 2000 o más
                    seed      = 2026)
```

| Función | Para qué | Lectura |
| --- | --- | --- |
| `average_treatment_effect(cf)` | ATE (estimación y error estándar) como promedio de los CATE | Comparar con `feols(... , vcov = "hc1")` con y sin controles |
| `predict(cf)$predictions` | CATE τ̂(Xᵢ) de cada obs., **fuera de bolsa** | La dispersión de los τ̂ por sí sola **no** prueba HTE |
| `get_forest_weights(cf)` | Pesos αᵢ(x) del bosque | Permite reconstruir un CATE a mano con las variables ortogonalizadas `Y - cf$Y.hat`, `W - cf$W.hat` |
| `test_calibration(cf)` | Prueba formal de heterogeneidad | `differential.forest.prediction`: H₀ β ≤ 0 (p unilateral); β ≈ 1 bien calibrado, 0 < β < 1 exagera la HTE. `mean.forest.prediction` ≈ 1: ATE bien calibrado |
| `variable_importance(cf)` | Frecuencia de cortes ponderada por profundidad | Dice dónde mira el bosque; **no** es un efecto ni el % de HTE explicado |
| `rank_average_treatment_effect(cf_eva, priorities, target = "AUTOC")`, `plot()` | Curva TOC y AUTOC: ¿priorizar por CATE predicho identifica a quienes más se benefician? | Requiere muestra dividida: bosque de entrenamiento para las prioridades y bosque de evaluación independiente |

- `grf` usa árboles **honestos** por defecto (`honesty = TRUE`).
- **Focalización (Lab 10):** se parte el experimento en dos mitades
  (`set.seed(2026)`; en CheMarket por usuario, no por grupo), se entrena
  `cf_ent` en una, se predicen las prioridades de la otra con
  `predict(cf_ent, X_eva)$predictions` y se evalúan con un `cf_eva` estimado
  solo en la segunda mitad. También se pueden evaluar reglas de una sola
  variable (elegidas con la mitad de entrenamiento; el signo según
  `cor(tau_ent, X)`).
- `W.hat`: en el Lab 10 se fijó en 0.5 porque la probabilidad de asignación era
  conocida. En CheMarket se fija en la probabilidad del diseño si se conoce;
  si no, se deja que `grf` la estime y se registra la decisión.
- El Lab 10 usa `clusters = colegio`; en CheMarket **no** se usa `clusters`
  (asignación individual).

---

## Herramientas previstas, no cubiertas en los laboratorios

Estas herramientas responden preguntas del enunciado, pero **no aparecen en el
código de los laboratorios**. No se usan hasta que se registren en
["Registro de ampliaciones"](#registro-de-ampliaciones):

| Herramienta | Por qué podría hacer falta | Estado |
| --- | --- | --- |
| Importancia de variables en `ranger` (`importance = "impurity"` o `"permutation"`, `$variable.importance`) y en `rpart` (`$variable.importance`) | Parte A: "¿qué variables resultan más útiles para predecir `ln(Revenue)`?" | Registrada (2026-10-23) |
| Varianza de los CATE en `grf`: `predict(cf, estimate.variance = TRUE)` | `CLAUDE.md` exige declarar la incertidumbre (intervalos) de cada CATE | Registrada (2026-10-23) |
| `average_treatment_effect(cf, subset = ...)` para el ATE de un subgrupo | Parte B: efectos por grupo con su error estándar | Registrada (2026-10-23) |

## Fuera del catálogo

No se usan, salvo que se registren como ampliación: boosting (`gbm`,
`xgboost`), el árbol causal individual (Athey e Imbens 2016, visto en el
Lab 09; el equipo decidió no usarlo y estimar la heterogeneidad solo con el
bosque causal), el paquete `causalTree`, `randomForest` (el Lab 08 lo menciona
como alternativa, pero no se usó), `tidymodels`/`rsample`/`boot` para la
validación cruzada, y cualquier familia de modelos ajena a la regresión lineal
y a los árboles (redes neuronales, SVM, matching, etc.).

---

## Registro de ampliaciones

Cada método, paquete o función que se agregue al catálogo se anota aquí
**antes** de usarlo, y la decisión se copia en "Decisiones tomadas" de
`CLAUDE.md`.

| Fecha | Qué se agrega (método / paquete / función) | Para qué (pregunta del taller) | Fuente (clase, paper, documentación) | Quién lo aprobó |
| --- | --- | --- | --- | --- |
| 2026-10-23 | Importancia de variables: `ranger(..., importance = "permutation")` y `$variable.importance`; `$variable.importance` de `rpart` | Parte A: "¿qué variables resultan más útiles para predecir `ln(Revenue)`?", como complemento de la escalera de RMSE (H5). Se lee como uso del modelo, no como efecto | Documentación de `ranger` y `rpart` | Equipo (Santiago Muñoz, sesión del plan de implementación) |
| 2026-10-23 | Varianza de los CATE: `predict(cf, estimate.variance = TRUE)` en `grf` | Parte B: intervalos de cada CATE, que exige `CLAUDE.md` | Documentación de `grf` (Athey, Tibshirani y Wager 2019) | Equipo (Santiago Muñoz, sesión del plan de implementación) |
| 2026-10-23 | ATE por subgrupo: `average_treatment_effect(cf, subset = ...)` en `grf` | Parte B: efecto por grupo de usuarios con su error estándar ("¿hay grupos con efecto mayor, menor o cercano a cero?") | Documentación de `grf` | Equipo (Santiago Muñoz, sesión del plan de implementación) |
| 2026-10-23 | Paquetes de formato de tablas: `gt` (estilo y HTML), `modelsummary` con `output = "gt"` (tablas de regresión con `vcov = "HC1"`). El `.png` se genera con Chrome o Chromium en modo headless desde `guardar_tabla()`, sin `webshot2`. Son herramientas de presentación, no estiman nada | Entregar las tablas en su formato final directamente desde el código (`guardar_tabla()` en `02_Scripts/00_formato_tablas.R`), como pide el profesor | Documentación de `gt`, `modelsummary` y `webshot2` | Equipo (Santiago Muñoz, sesión del formato de tablas) |
