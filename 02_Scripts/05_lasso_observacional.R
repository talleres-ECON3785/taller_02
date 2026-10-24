# =============================================================================
# LASSO como benchmark lineal flexible para predecir Revenue
# Taller 2 - ECON-3785 (Parte A)
#
# Estimando: ninguno causal; el objetivo es predecir Revenue (dolares) de un
# usuario nuevo con la base historica. Estimador: LASSO (cv.glmnet, alpha = 1).
# Medida: RMSE fuera de muestra. Los terminos que LASSO conserva indican que
# usa para predecir, no que variables tienen efecto (no hay asignacion
# aleatoria).
#
# Disenio:
#   - Misma particion 80/20 (set.seed(2026)) y mismos 5 pliegues que
#     04_prediccion_lineal_observacional.R: el RMSE de validacion cruzada de
#     LASSO se compara pliegue a pliegue con el del lineal final.
#   - Solo el modelo final, no la escalera: LASSO no agrega variables de a una.
#   - Diccionario: las variables del lineal final (indicador de mas de 5 minutos,
#     sesiones anteriores, dispositivo, sistema operativo, usuario recurrente y
#     registro) mas el tiempo continuo, su cuadrado y su logaritmo, el cuadrado
#     de las sesiones y todas las interacciones de a pares. Incluye el cruce
#     mas de 5 minutos x sesiones, asi que se puede ver si LASSO lo conserva.
#   - lambda se elige con los pliegues de 'train'; 'test' se toca una sola vez,
#     al final. El lambda titular (declarado antes de ver 'test') es lambda.min;
#     lambda.1se se reporta en la misma pasada.
#   - Solo Revenue en nivel. La escala logaritmica queda para otro script.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema y funcion de guardado de las figuras; estilo de las tablas
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "05_lasso_observacional"

rmse <- function(y, prediccion) sqrt(mean((y - prediccion)^2))

# media y error estandar de un vector por pliegue (o de una diferencia pareada)
resumir_cv <- function(x) c(media = mean(x), ee = sd(x) / sqrt(length(x)))

# -----------------------------------------------------------------------------
# 1. Datos y particion train/test (la del Taller 1 y la del script 04)
# -----------------------------------------------------------------------------

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds") |>
  # mismo indicador del quiebre que en 04 (corte de 5 minutos del Taller 1)
  mutate(mas_5_min = as.integer(time_spent > 5))

# log(time_spent) del diccionario requiere tiempo positivo
stopifnot(all(obs$time_spent > 0))

n <- nrow(obs)
set.seed(2026)
indices_train <- sample(seq_len(n), size = round(0.8 * n))
train <- obs[indices_train, ]
test  <- obs[-indices_train, ]

# model.matrix() arma columnas por categoria: deben existir las mismas en 'test'
stopifnot(
  all(test$device_type %in% unique(train$device_type)),
  all(test$os_type %in% unique(train$os_type))
)
cat(sprintf("train = %s, test = %s\n",
            format(nrow(train), big.mark = ","),
            format(nrow(test), big.mark = ",")))

media_train <- mean(train$Revenue)

# 5 pliegues fijos, los mismos de 04 (misma semilla, mismos datos)
set.seed(2026)
pliegues <- caret::createFolds(train$Revenue, k = 5)
foldid <- integer(nrow(train))
for (k in seq_along(pliegues)) foldid[pliegues[[k]]] <- k

# -----------------------------------------------------------------------------
# 2. Diccionario de regresores
# -----------------------------------------------------------------------------

# LASSO solo elige entre lo que se le ofrece (catalogo de metodos, seccion 2).
# El cuadrado y el logaritmo del tiempo le dejan aproximar el quiebre sin el
# indicador; el indicador y el cruce vienen del lineal final
diccionario <- ~ (mas_5_min + time_spent + I(time_spent^2) + log(time_spent) +
                    past_sessions + I(past_sessions^2) + device_type +
                    os_type + is_returning_user + sign_up)^2

X_train <- model.matrix(diccionario, train)[, -1]
X_test  <- model.matrix(diccionario, test)[, -1]
y_train <- train$Revenue
stopifnot(
  nrow(X_train) == length(y_train),
  identical(colnames(X_train), colnames(X_test))
)
cat(sprintf("Diccionario: %d columnas\n", ncol(X_train)))

# -----------------------------------------------------------------------------
# 3. LASSO con validacion cruzada en 'train'
# -----------------------------------------------------------------------------

# 'foldid' y 'keep = TRUE' guardan las predicciones fuera de pliegue de cada
# lambda (fit.preval), con las que se calcula el RMSE por pliegue
set.seed(2026)
cv_lasso <- cv.glmnet(X_train, y_train, alpha = 1, foldid = foldid, keep = TRUE)

lambdas <- c("lambda.min" = cv_lasso$lambda.min, "lambda.1se" = cv_lasso$lambda.1se)

# RMSE de cada pliegue en un lambda: predice el pliegue con el modelo ajustado
# sin ese pliegue
rmse_pliegues_lambda <- function(lambda) {
  columna <- which(cv_lasso$lambda == lambda)
  map_dbl(pliegues, ~ rmse(y_train[.x], cv_lasso$fit.preval[.x, columna]))
}
rmse_lasso_cv <- map(lambdas, rmse_pliegues_lambda)

# lineal final de 04, en los mismos pliegues
f_completo <- Revenue ~ mas_5_min + past_sessions + mas_5_min:past_sessions +
  device_type + os_type + is_returning_user + sign_up
rmse_lineal_cv <- map_dbl(pliegues, function(idx) {
  ajuste <- lm(f_completo, data = train[-idx, ])
  rmse(y_train[idx], predict(ajuste, newdata = train[idx, ]))
})

# diferencia pareada (positiva = LASSO tiene menos error que el lineal final)
dif_cv <- map(rmse_lasso_cv, ~ resumir_cv(rmse_lineal_cv - .x))

cat(sprintf(
  "lambda.min = %.5f, lambda.1se = %.5f\n", lambdas[["lambda.min"]], lambdas[["lambda.1se"]]
))
iwalk(rmse_lasso_cv, ~ cat(sprintf(
  "%s: RMSE CV %.4f; lineal final %.4f; caida pareada %.4f (ee %.4f)\n",
  .y, mean(.x), mean(rmse_lineal_cv), dif_cv[[.y]][["media"]], dif_cv[[.y]][["ee"]]
)))

# -----------------------------------------------------------------------------
# 4. Terminos que conserva LASSO
# -----------------------------------------------------------------------------

coef_min <- as.matrix(coef(cv_lasso, s = "lambda.min"))[-1, 1]
coef_1se <- as.matrix(coef(cv_lasso, s = "lambda.1se"))[-1, 1]
stopifnot(identical(names(coef_min), colnames(X_train)))

# nombre legible de cada columna del diccionario (sin nombres del codigo)
etiquetas_base <- c(
  "mas_5_min" = "Más de 5 minutos",
  "I(time_spent^2)" = "Tiempo²",
  "log(time_spent)" = "log(Tiempo)",
  "time_spent" = "Tiempo",
  "I(past_sessions^2)" = "Sesiones anteriores²",
  "past_sessions" = "Sesiones anteriores",
  "device_typemobile" = "Dispositivo: móvil",
  "device_typetablet" = "Dispositivo: tableta",
  "os_typeother" = "Sistema: otro",
  "os_typewindows" = "Sistema: Windows",
  "is_returning_user" = "Usuario recurrente",
  "sign_up" = "Registro"
)
etiquetar <- function(columna) {
  partes <- strsplit(columna, ":", fixed = TRUE)[[1]]
  paste(etiquetas_base[partes], collapse = " × ")
}
stopifnot(all(unlist(strsplit(colnames(X_train), ":", fixed = TRUE)) %in% names(etiquetas_base)))

# coeficiente estandarizado (coeficiente x desviacion de la columna): hace
# comparables entre si terminos con escalas distintas
coeficientes <- tibble(
  columna = colnames(X_train),
  termino = map_chr(columna, etiquetar),
  coef_min = unname(coef_min),
  coef_1se = unname(coef_1se),
  est_min = coef_min * apply(X_train, 2, sd),
  est_1se = coef_1se * apply(X_train, 2, sd)
) |>
  arrange(desc(abs(est_min)))

n_min <- sum(coeficientes$coef_min != 0)
n_1se <- sum(coeficientes$coef_1se != 0)
cat(sprintf(
  "Terminos conservados: %d (lambda.min) y %d (lambda.1se) de %d\n",
  n_min, n_1se, ncol(X_train)
))
cruce <- coeficientes |> filter(columna == "mas_5_min:past_sessions")
cat(sprintf(
  "Cruce mas de 5 minutos x sesiones: coef %.4f (lambda.min), %.4f (lambda.1se)\n",
  cruce$coef_min, cruce$coef_1se
))
print(head(coeficientes, 15))

# -----------------------------------------------------------------------------
# 5. Evaluacion en 'test' (una sola vez)
# -----------------------------------------------------------------------------

# los tres primeros modelos vienen de 04 (no se recalculan); aqui se verifica
# que reproducen el Taller 1 y el lineal final
ruta_04 <- "03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_rmse_prueba_lineal.csv"
prueba_lineal <- read_csv(ruta_04, show_col_types = FALSE)
stopifnot(
  abs(prueba_lineal$rmse_prueba[1] - 2.716) < 0.001,
  abs(prueba_lineal$rmse_prueba[2] - 2.314) < 0.001
)

rmse_ingenuo <- prueba_lineal$rmse_prueba[1]

prueba_lasso <- imap_dfr(lambdas, function(lambda, nombre) {
  prediccion <- as.numeric(predict(cv_lasso, newx = X_test, s = lambda))
  rmse_test <- rmse(test$Revenue, prediccion)
  rmse_val <- mean(rmse_lasso_cv[[nombre]])
  tibble(
    modelo = if (nombre == "lambda.min") "LASSO (λ de menor error de validación)"
             else "LASSO (λ más regularizado a un error estándar)",
    rmse_cv = rmse_val,
    rmse_prueba = rmse_test,
    brecha = rmse_test - rmse_val,
    rmse_media_pct = 100 * rmse_test / media_train,
    mejora_ingenuo_pct = 100 * (1 - rmse_test / rmse_ingenuo),
    explicado_pct = 100 * (1 - rmse_test^2 / rmse_ingenuo^2)
  )
})

prueba <- bind_rows(prueba_lineal, prueba_lasso)
print(prueba)

# -----------------------------------------------------------------------------
# 6. Tablas
# -----------------------------------------------------------------------------

tabla_prueba <- prueba |>
  gt() |>
  cols_label(
    modelo = "Modelo",
    rmse_cv = "RMSE entrenamiento, validación cruzada (dólares)",
    rmse_prueba = "RMSE prueba (dólares)",
    brecha = "Brecha prueba − validación (dólares)",
    rmse_media_pct = "RMSE como % de la media del ingreso",
    mejora_ingenuo_pct = "Mejora frente a la media (%)",
    explicado_pct = "Error cuadrático eliminado (%)"
  ) |>
  fmt_number(c(rmse_cv, rmse_prueba, brecha), decimals = decimales$rmse) |>
  fmt_number(c(rmse_media_pct, mejora_ingenuo_pct, explicado_pct),
             decimals = decimales$porcentaje) |>
  cols_align("center", -modelo) |>
  estilo_tabla(
    titulo = "Error de predicción fuera de muestra de LASSO frente a los modelos lineales",
    subtitulo = sprintf(
      "Ingreso en dólares; media del ingreso en entrenamiento: %.2f dólares",
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
        sprintf(
          paste(
            "LASSO elige entre %d términos (variables, tiempo en minutos, su cuadrado",
            "y logaritmo, sesiones anteriores al cuadrado e interacciones de a pares);",
            "conserva %d con el λ de menor error y %d con el más regularizado."
          ),
          ncol(X_train), n_min, n_1se
        ),
        sprintf(
          paste(
            "Caída pareada del RMSE de validación cruzada frente al lineal con quiebre",
            "y cruce (error estándar entre pliegues): %.3f (%.3f) dólares con el λ de",
            "menor error y %.3f (%.3f) con el más regularizado."
          ),
          dif_cv$lambda.min[["media"]], dif_cv$lambda.min[["ee"]],
          dif_cv$lambda.1se[["media"]], dif_cv$lambda.1se[["ee"]]
        )
      )
    )
  )

guardar_tabla("observacional_rmse_prueba_lasso", tabla_prueba, prueba, carpeta_salida)

# los 20 terminos con mayor coeficiente estandarizado en el λ de menor error
tabla_coef <- coeficientes |>
  slice_head(n = 20) |>
  select(termino, coef_min, coef_1se, est_min, est_1se) |>
  gt() |>
  cols_label(
    termino = "Término",
    coef_min = "Coeficiente, λ de menor error (dólares)",
    coef_1se = "Coeficiente, λ más regularizado (dólares)",
    est_min = "Estandarizado, λ de menor error",
    est_1se = "Estandarizado, λ más regularizado"
  ) |>
  fmt_number(c(coef_min, coef_1se, est_min, est_1se), decimals = decimales$rmse) |>
  cols_align("center", -termino) |>
  estilo_tabla(
    titulo = "Términos que LASSO usa más para predecir el ingreso",
    subtitulo = "LASSO; ingreso en dólares; ordenados por tamaño del coeficiente estandarizado",
    nota = nota_tabla(
      "observacional", nrow(train), "entrenamiento", enfoque = "predictivo",
      extra = c(
        sprintf(
          paste(
            "Se muestran los 20 términos con mayor coeficiente estandarizado en el λ de",
            "menor error, de %d conservados (%d con el λ más regularizado). Un coeficiente",
            "igual a 0.000 indica que el término se excluyó con ese λ."
          ),
          n_min, n_1se
        ),
        paste(
          "Coeficiente estandarizado: coeficiente por la desviación estándar del término.",
          "Describe qué usa el modelo para predecir; no es un efecto ni una importancia causal."
        )
      )
    )
  )

guardar_tabla(
  "observacional_lasso_coeficientes", tabla_coef, coeficientes, carpeta_salida
)

# -----------------------------------------------------------------------------
# 7. Figura: error de validacion cruzada segun lambda
# -----------------------------------------------------------------------------

curva <- tibble(
  log_lambda = log(cv_lasso$lambda),
  rmse_cv = sqrt(cv_lasso$cvm),
  inferior = sqrt(cv_lasso$cvlo),
  superior = sqrt(cv_lasso$cvup)
)

# el eje se recorta a la zona de los dos lambda elegidos: con lambda grande el
# modelo queda casi sin terminos y el RMSE sube hasta el de la media, lo que
# aplastaria la region que importa
limite_x <- c(log(lambdas[["lambda.min"]]) - 0.3, -0.5)
limite_y <- c(min(curva$inferior) - 0.01,
              max(curva$superior[curva$log_lambda <= limite_x[2]]))

grafica_lambda <- ggplot(curva, aes(x = log_lambda, y = rmse_cv)) +
  geom_ribbon(aes(ymin = inferior, ymax = superior), fill = paleta_categorica[1],
              alpha = 0.2) +
  geom_line(color = paleta_categorica[1], linewidth = 0.8) +
  geom_vline(xintercept = log(lambdas), linetype = "dotted", color = gris_nota) +
  annotate("text", x = log(lambdas[["lambda.min"]]), y = limite_y[2],
           label = "λ de menor error", hjust = -0.05, vjust = 1, color = gris_texto,
           size = 3.6) +
  annotate("text", x = log(lambdas[["lambda.1se"]]), y = limite_y[2],
           label = "λ a un error estándar", hjust = -0.05, vjust = 1,
           color = gris_texto, size = 3.6) +
  coord_cartesian(xlim = limite_x, ylim = limite_y) +
  labs(
    title = "Error de predicción de LASSO según la regularización",
    subtitle = subtitulo_observacional_predictivo,
    x = "Regularización: logaritmo de λ (más a la derecha, menos términos)",
    y = "RMSE de validación cruzada (dólares)",
    caption = paste(
      sprintf(
        "Nota: n = %s usuarios de entrenamiento; validación cruzada de 5 pliegues.",
        format(nrow(train), big.mark = ",")
      ),
      "La banda es ±1 error estándar entre pliegues; las líneas punteadas marcan los dos λ.",
      "El eje se recorta: con λ mayores que e^-0.5 el error sube hasta el de la media (2.74 dólares).",
      sep = "\n"
    )
  ) +
  tema_presentacion +
  theme(plot.title.position = "plot", plot.caption.position = "plot")

guardar_figura("observacional_lasso_cv_lambda.png", grafica_lambda, carpeta_salida)

cat("\nListo. Tablas y figuras en 03_Resultados/{Tablas,Figuras}/05_lasso_observacional/.\n")
cat("Recordatorio: terminos conservados = uso predictivo en datos historicos, no efecto causal.\n")
