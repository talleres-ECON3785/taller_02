# =============================================================================
# Auditoria, Fases 2 y 3: escalera de RMSE en ln(Revenue) y rejilla ampliada
# del bosque (min.node.size en el borde)
#
# No forma parte del pipeline. Replica el disenio de 04 (particion 80/20 con
# set.seed(2026), 5 pliegues de caret::createFolds, lm por pliegue) y de 10
# (ranger, error OOB, 300 arboles) solo con 'train'. 'test' no se toca.
#
# Uso (desde la raiz del proyecto):
#   Rscript --vanilla 10_Auditoria/scripts/aud_correr.R aud_04_prediccion_log.R
# Salidas: 10_Auditoria/salidas/aud_04_*.csv
# =============================================================================

# los paquetes los cargan las secciones 1 a 3 de 00_main.R (aud_correr.R)

salida <- function(nombre) file.path("10_Auditoria/salidas", paste0("aud_04_", nombre, ".csv"))
rmse <- function(y, prediccion) sqrt(mean((y - prediccion)^2))

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds") |>
  mutate(mas_5_min = as.integer(time_spent > 5))
n <- nrow(obs)
set.seed(2026)
indices_train <- sample(seq_len(n), size = round(0.8 * n))
train <- obs[indices_train, ]

# mismos 5 pliegues que 04 (se generan con Revenue, como alli)
set.seed(2026)
pliegues <- caret::createFolds(train$Revenue, k = 5)

cv_rmse <- function(formula, respuesta) {
  map_dbl(pliegues, function(idx) {
    ajuste <- lm(formula, data = train[-idx, ])
    rmse(train[[respuesta]][idx], predict(ajuste, newdata = train[idx, ]))
  })
}
resumir_cv <- function(x) c(media = mean(x), ee = sd(x) / sqrt(length(x)))

# -----------------------------------------------------------------------------
# 1. Escalera de 04 en las dos escalas (mismo orden de escalones)
# -----------------------------------------------------------------------------

escalones <- tribble(
  ~termino,                    ~variable,
  NA,                          "Ninguna (media del entrenamiento)",
  "mas_5_min",                 "Más de 5 minutos en el sitio",
  "past_sessions",             "Sesiones anteriores",
  "mas_5_min:past_sessions",   "Más de 5 minutos × sesiones anteriores",
  "device_type",               "Dispositivo",
  "os_type",                   "Sistema operativo",
  "is_returning_user",         "Usuario recurrente",
  "sign_up",                   "Registro"
)

escalera <- map_dfr(c("Revenue", "log_revenue"), function(y) {
  formula_hasta <- function(k) {
    terminos <- na.omit(escalones$termino[seq_len(k)])
    reformulate(if (length(terminos) == 0) "1" else terminos, response = y)
  }
  por_pliegue <- map(seq_len(nrow(escalones)), ~ cv_rmse(formula_hasta(.x), y))
  map_dfr(seq_along(por_pliegue), function(k) {
    actual <- resumir_cv(por_pliegue[[k]])
    dif <- if (k == 1) c(media = NA_real_, ee = NA_real_)
           else resumir_cv(por_pliegue[[k - 1]] - por_pliegue[[k]])
    tibble(respuesta = y, paso = k - 1, variable = escalones$variable[k],
           rmse_cv = actual[["media"]], ee_rmse_cv = actual[["ee"]],
           caida = dif[["media"]], ee_caida = dif[["ee"]])
  }) |>
    mutate(caida_pct_total = 100 * caida / (rmse_cv[1] - min(rmse_cv)),
           mejora_ingenuo_pct = 100 * (1 - rmse_cv / rmse_cv[1]))
})
write_csv(escalera, salida("escalera_dos_escalas"))
print(escalera, n = Inf, width = Inf)

# forma del tiempo en log (como observacional_robustez_forma_tiempo de 04)
base <- "past_sessions + device_type + os_type + is_returning_user + sign_up"
formas <- tribble(
  ~especificacion, ~terminos,
  "Solo el indicador de más de 5 minutos", "mas_5_min + mas_5_min:past_sessions",
  "Solo el tiempo en minutos (lineal)", "time_spent + time_spent:past_sessions",
  "Logaritmo del tiempo", "log(time_spent) + log(time_spent):past_sessions",
  "Indicador y tiempo en minutos", "mas_5_min + time_spent + mas_5_min:past_sessions"
)
robustez <- map_dfr(c("Revenue", "log_revenue"), function(y) {
  formas |> mutate(respuesta = y, rmse_cv = map_dbl(terminos, function(t) {
    mean(cv_rmse(as.formula(paste(y, "~", t, "+", base)), y))
  }))
})
write_csv(robustez, salida("robustez_forma_tiempo"))
print(robustez, width = Inf)

# -----------------------------------------------------------------------------
# 2. Rejilla ampliada del bosque: mtry = 3 (el elegido) y nodos mas grandes
# -----------------------------------------------------------------------------
# 10 eligio min.node.size = 100, el borde de su rejilla (5, 25, 100). Aqui se
# amplia a 200, 400 y 800 con mtry = 3 y se repite 100 en las mismas
# condiciones (num.threads fijo) para comparar

predictores <- c("sign_up", "time_spent", "past_sessions", "device_type",
                 "is_returning_user", "os_type")
rejilla <- expand_grid(respuesta = c("Revenue", "log_revenue"), mtry = 3,
                       min_nodo = c(100, 200, 400, 800)) |>
  mutate(rmse_oob = pmap_dbl(list(respuesta, mtry, min_nodo), function(y, m, nodo) {
    b <- ranger(reformulate(predictores, response = y), data = train,
                num.trees = 300, mtry = m, min.node.size = nodo, replace = TRUE,
                sample.fraction = 1, seed = 2026, num.threads = 4)
    sqrt(b$prediction.error)
  }))
write_csv(rejilla, salida("rejilla_bosque_ampliada"))
print(rejilla)

cat("\nListo: salidas en 10_Auditoria/salidas/aud_04_*.csv\n")
