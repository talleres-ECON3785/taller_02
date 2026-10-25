# =============================================================================
# Comparacion fuera de muestra: lineales frente a arboles, en dolares y en log
# Taller 2 - ECON-3785 (Parte A)
#
# Estimando: ninguno causal; el objetivo es predecir el ingreso de un usuario
# nuevo con la base historica. Medida: RMSE en 'test', calculado una sola vez.
#
# Disenio (matriz 2x2 de PLAN.md: metodo x forma funcional):
#   - Misma particion 80/20 (set.seed(2026)) que 04, 05, 09 y 10.
#   - Modelos, cada uno en dolares (Revenue) y en logaritmo (log_revenue):
#     ingenuo (media de 'train'), lineal del Taller 1, lineal final de 04,
#     LASSO de 05 (mismo diccionario, mismos pliegues, lambda.min), arbol
#     podado de 09 (regla 1-SE, cp leido de su tabla) y bosque aleatorio de 10
#     (hiperparametros leidos de su tabla). Todos se reestiman con 'train' y
#     ningun hiperparametro se elige aqui.
#   - Dos comparaciones para los modelos en logaritmo (decision de P2.5):
#       (a) mejora % frente a la media en la escala del modelo;
#       (b) prediccion llevada a dolares con el factor de smearing de Duan
#           (exp(prediccion) x promedio de exp(residuo) en 'train'), para
#           compararla con el RMSE en dolares del Taller 1. En el bosque los
#           residuos son los fuera de bolsa: los de dentro de muestra
#           subestiman la dispersion.
#   - El RMSE en logaritmo y el RMSE en dolares tienen unidades distintas: no se
#     comparan directamente.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema y funcion de guardado de las figuras; estilo de las tablas
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "11_comparacion_prediccion_observacional"

rmse <- function(y, prediccion) sqrt(mean((y - prediccion)^2))

# -----------------------------------------------------------------------------
# 1. Datos y particion train/test (la del Taller 1)
# -----------------------------------------------------------------------------

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds") |>
  # indicador del quiebre de 5 minutos, como en 04 y 05
  mutate(mas_5_min = as.integer(time_spent > 5))

n <- nrow(obs)
set.seed(2026)
indices_train <- sample(seq_len(n), size = round(0.8 * n))
train <- obs[indices_train, ]
test  <- obs[-indices_train, ]

stopifnot(
  all(test$device_type %in% unique(train$device_type)),
  all(test$os_type %in% unique(train$os_type))
)
cat(sprintf("train = %s, test = %s\n",
            format(nrow(train), big.mark = ","),
            format(nrow(test), big.mark = ",")))

# 5 pliegues de 04 y 05 (los usa LASSO para elegir lambda)
set.seed(2026)
pliegues <- caret::createFolds(train$Revenue, k = 5)
foldid <- integer(nrow(train))
for (k in seq_along(pliegues)) foldid[pliegues[[k]]] <- k

# hiperparametros elegidos en 09 y 10 (solo con 'train')
poda_cart <- read_csv("03_Resultados/Tablas/09_arboles_observacional/observacional_cart_poda.csv",
                      show_col_types = FALSE) |>
  filter(titular)
bosque_elegido <- read_csv("03_Resultados/Tablas/10_bosque_observacional/observacional_bosque_elegido.csv",
                           show_col_types = FALSE) |>
  filter(titular)

# -----------------------------------------------------------------------------
# 2. Especificaciones (las de 04, 05, 09 y 10)
# -----------------------------------------------------------------------------

terminos_taller1 <- c("sign_up", "time_spent", "past_sessions", "device_type",
                      "is_returning_user", "os_type")
terminos_lineal <- c("mas_5_min", "past_sessions", "mas_5_min:past_sessions",
                     "device_type", "os_type", "is_returning_user", "sign_up")
predictores_arbol <- terminos_taller1

# diccionario de LASSO de 05 (sin las columnas duplicadas)
diccionario <- ~ (mas_5_min + time_spent + I(time_spent^2) + log(time_spent) +
                    past_sessions + I(past_sessions^2) + device_type +
                    os_type + is_returning_user + sign_up)^2
X_train <- model.matrix(diccionario, train)[, -1]
X_test  <- model.matrix(diccionario, test)[, -1]
columnas_repetidas <- duplicated(t(X_train))
X_train <- X_train[, !columnas_repetidas]
X_test  <- X_test[, !columnas_repetidas]
stopifnot(identical(colnames(X_train), colnames(X_test)), ncol(X_train) == 74)

escalas <- tribble(
  ~escala,       ~respuesta,
  "Dólares",     "Revenue",
  "Logaritmo",   "log_revenue"
)

# -----------------------------------------------------------------------------
# 3. Ajuste en 'train' y prediccion en 'test'
# -----------------------------------------------------------------------------

# cada funcion ajusta con 'train' y devuelve las predicciones de 'test' y los
# residuos de 'train' que usa el factor de smearing
ajustar_lineal <- function(terminos) {
  function(respuesta, escala) {
    ajuste <- lm(reformulate(terminos, response = respuesta), data = train)
    list(prueba = unname(predict(ajuste, newdata = test)),
         residuos = unname(residuals(ajuste)))
  }
}

ajustar_ingenuo <- function(respuesta, escala) {
  media <- mean(train[[respuesta]])
  list(prueba = rep(media, nrow(test)), residuos = train[[respuesta]] - media)
}

ajustar_lasso <- function(respuesta, escala) {
  y <- train[[respuesta]]
  set.seed(2026)
  cv_lasso <- cv.glmnet(X_train, y, alpha = 1, foldid = foldid)
  list(
    prueba = as.numeric(predict(cv_lasso, newx = X_test, s = "lambda.min")),
    residuos = y - as.numeric(predict(cv_lasso, newx = X_train, s = "lambda.min"))
  )
}

ajustar_cart <- function(respuesta, escala) {
  cp <- poda_cart$cp[poda_cart$escala == escala]
  set.seed(2026)
  grande <- rpart(
    reformulate(predictores_arbol, response = respuesta),
    data = train, method = "anova",
    control = rpart.control(cp = 0, minbucket = 7, xval = 10)
  )
  arbol <- prune(grande, cp = cp)
  list(prueba = unname(predict(arbol, newdata = test)),
       residuos = train[[respuesta]] - unname(predict(arbol, newdata = train)))
}

ajustar_bosque <- function(respuesta, escala) {
  h <- bosque_elegido |> filter(escala == !!escala)
  bosque <- ranger(
    reformulate(predictores_arbol, response = respuesta),
    data = train, num.trees = h$arboles, mtry = h$mtry,
    min.node.size = h$min_nodo, replace = TRUE, sample.fraction = 1,
    seed = 2026
  )
  list(prueba = predict(bosque, data = test)$predictions,
       # residuos fuera de bolsa
       residuos = train[[respuesta]] - bosque$predictions)
}

modelos <- tribble(
  ~familia,   ~modelo,                                   ~ajustar,
  "Lineal",   "Referencia ingenua (media del entrenamiento)", ajustar_ingenuo,
  "Lineal",   "Lineal del Taller 1 (tiempo lineal)",     ajustar_lineal(terminos_taller1),
  "Lineal",   "Lineal con corte de 5 minutos y cruce",   ajustar_lineal(terminos_lineal),
  "Lineal",   "LASSO (74 términos)",                     ajustar_lasso,
  "Árboles",  "Árbol de regresión podado",               ajustar_cart,
  "Árboles",  "Bosque aleatorio",                        ajustar_bosque
)

resultados <- expand_grid(select(modelos, familia, modelo), escalas) |>
  mutate(ajuste = pmap(
    list(modelo, respuesta, escala),
    function(modelo, respuesta, escala) {
      modelos$ajustar[[which(modelos$modelo == modelo)]](respuesta, escala)
    }
  ))

# -----------------------------------------------------------------------------
# 4. RMSE de prueba en la escala de cada modelo y en dolares
# -----------------------------------------------------------------------------

resultados <- resultados |>
  mutate(
    rmse_propio = map2_dbl(ajuste, respuesta, ~ rmse(test[[.y]], .x$prueba)),
    # factor de smearing de Duan: solo para los modelos en logaritmo
    smearing = map2_dbl(ajuste, escala,
                        ~ if (.y == "Logaritmo") mean(exp(.x$residuos)) else NA_real_),
    pred_dolares = pmap(list(ajuste, escala, smearing), function(a, escala, s) {
      if (escala == "Logaritmo") exp(a$prueba) * s else a$prueba
    }),
    rmse_dolares = map_dbl(pred_dolares, ~ rmse(test$Revenue, .x))
  ) |>
  group_by(escala) |>
  mutate(
    mejora_propia_pct = 100 * (1 - rmse_propio / rmse_propio[modelo == modelos$modelo[1]])
  ) |>
  ungroup() |>
  mutate(
    rmse_ingenuo_dolares = rmse_dolares[modelo == modelos$modelo[1] & escala == "Dólares"],
    mejora_dolares_pct = 100 * (1 - rmse_dolares / rmse_ingenuo_dolares)
  )

# verificacion: en dolares se reproducen los RMSE de prueba del Taller 1, de 04
# y de 05 (2.716 ingenuo, 2.314 Taller 1, 1.845 lineal final, 1.765 LASSO)
esperados <- c(2.716, 2.314, 1.845, 1.765)
obtenidos <- resultados |> filter(escala == "Dólares") |> slice(1:4) |> pull(rmse_propio)
cat("RMSE de prueba en dolares (lineales):", sprintf("%.4f", obtenidos), "\n")
stopifnot(all(abs(obtenidos - esperados) < 0.001))

comparacion <- resultados |>
  select(familia, modelo, escala, rmse_propio, mejora_propia_pct, smearing,
         rmse_dolares, mejora_dolares_pct)
print(comparacion, n = Inf, width = Inf)

media_train <- mean(train$Revenue)

# -----------------------------------------------------------------------------
# 5. Tabla 2x2: metodo x escala
# -----------------------------------------------------------------------------

datos_tabla <- comparacion |>
  select(familia, modelo, escala, rmse_propio, mejora_propia_pct,
         rmse_dolares, mejora_dolares_pct) |>
  pivot_wider(
    names_from = escala,
    values_from = c(rmse_propio, mejora_propia_pct, rmse_dolares, mejora_dolares_pct)
  ) |>
  select(familia, modelo,
         d_rmse = `rmse_propio_Dólares`, d_mejora = `mejora_propia_pct_Dólares`,
         l_rmse = rmse_propio_Logaritmo, l_mejora = mejora_propia_pct_Logaritmo,
         ld_rmse = rmse_dolares_Logaritmo, ld_mejora = mejora_dolares_pct_Logaritmo)

tabla_comparacion <- datos_tabla |>
  gt(groupname_col = "familia") |>
  tab_spanner("Modelo en dólares", c(d_rmse, d_mejora)) |>
  tab_spanner("Modelo en logaritmo", c(l_rmse, l_mejora)) |>
  tab_spanner("Logaritmo llevado a dólares", c(ld_rmse, ld_mejora)) |>
  cols_label(
    modelo = "Modelo",
    d_rmse = "RMSE (dólares)", d_mejora = "Mejora (%)",
    l_rmse = "RMSE (log)", l_mejora = "Mejora (%)",
    ld_rmse = "RMSE (dólares)", ld_mejora = "Mejora (%)"
  ) |>
  fmt_number(c(d_rmse, l_rmse, ld_rmse), decimals = decimales$rmse) |>
  fmt_number(c(d_mejora, l_mejora, ld_mejora), decimals = decimales$porcentaje) |>
  cols_align("center", -modelo) |>
  estilo_tabla(
    titulo = "Error de predicción fuera de muestra: modelos lineales y árboles",
    subtitulo = sprintf(
      "Ingreso en dólares y en logaritmo; ingreso promedio en entrenamiento: %.2f dólares",
      media_train
    ),
    nota = nota_tabla(
      "observacional", nrow(test), "prueba", enfoque = "predictivo",
      extra = c(
        paste0(
          "Modelos ajustados con la muestra de entrenamiento (n = ",
          format(nrow(train), big.mark = ","), ") y evaluados una sola vez en la",
          " muestra de prueba. Partición 80/20 con semilla 2026, como en el Taller 1."
        ),
        paste(
          "Mejora: reducción del RMSE frente a la referencia ingenua de la misma",
          "columna (media del entrenamiento; en la última columna, la media en dólares)."
        ),
        paste(
          "Logaritmo llevado a dólares: exponencial de la predicción multiplicada",
          "por el factor de smearing de Duan (promedio de la exponencial de los",
          "residuos de entrenamiento; residuos fuera de bolsa en el bosque)."
        ),
        paste(
          "El RMSE en logaritmo y el RMSE en dólares tienen unidades distintas y",
          "no se comparan directamente. Hiperparámetros del árbol, del bosque y de",
          "LASSO elegidos solo con la muestra de entrenamiento."
        )
      )
    )
  )

guardar_tabla("observacional_rmse_prueba_comparacion", tabla_comparacion,
              comparacion, carpeta_salida)

# -----------------------------------------------------------------------------
# 6. Figura: mejora frente a la referencia ingenua por modelo y escala
# -----------------------------------------------------------------------------

paneles <- c(
  "Dólares" = "Modelo en dólares",
  "Logaritmo" = "Modelo en logaritmo",
  "Logaritmo a dólares" = "Logaritmo llevado\na dólares"
)

datos_figura <- bind_rows(
  comparacion |> transmute(familia, modelo, panel = paneles[escala], mejora = mejora_propia_pct),
  comparacion |> filter(escala == "Logaritmo") |>
    transmute(familia, modelo, panel = paneles[["Logaritmo a dólares"]],
              mejora = mejora_dolares_pct)
) |>
  filter(modelo != modelos$modelo[1]) |>
  mutate(
    panel = factor(panel, levels = paneles),
    # lineal (referencia) en azul y arboles en ocre, en el orden de la tabla
    familia = factor(familia, levels = c("Lineal", "Árboles")),
    modelo = factor(modelo, levels = rev(modelos$modelo[-1]))
  )

grafica_comparacion <- ggplot(datos_figura, aes(x = mejora, y = modelo, fill = familia)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%", mejora)),
            hjust = -0.15, size = 3.4, color = gris_secundario) +
  facet_wrap(~ panel) +
  scale_fill_manual(values = paleta_categorica[1:2], name = NULL) +
  scale_x_continuous(breaks = c(0, 20, 40), expand = expansion(mult = c(0, 0.35))) +
  labs(
    title = "Reducción del error de predicción frente a predecir la media",
    subtitle = subtitulo_observacional_predictivo,
    x = "Mejora del RMSE de prueba frente a la media del entrenamiento (%)",
    y = NULL,
    caption = paste(
      sprintf(
        "Nota: modelos ajustados con %s usuarios de entrenamiento y evaluados una sola vez con %s usuarios de prueba.",
        format(nrow(train), big.mark = ","), format(nrow(test), big.mark = ",")
      ),
      "Cada panel compara contra la media en su propia escala; el tercero lleva las predicciones en logaritmo a dólares (smearing de Duan).",
      sep = "\n"
    )
  ) +
  tema_presentacion +
  tema_paneles +
  theme(
    plot.title.position = "plot", plot.caption.position = "plot",
    legend.position = "top", legend.justification = "left",
    axis.text.x = element_text(size = 10, color = gris_secundario, face = "plain"),
    axis.text.y = element_text(color = gris_texto)
  )

guardar_figura("observacional_rmse_prueba_comparacion.png", grafica_comparacion,
               carpeta_salida)
