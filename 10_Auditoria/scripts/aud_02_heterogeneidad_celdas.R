# =============================================================================
# Auditoria, Fases 4 a 6: verificaciones numericas del bosque causal (script 12)
#
# No forma parte del pipeline: 00_main.R no lo llama. Solo usa herramientas del
# catalogo (07_Recursos/catalogo_metodos.md) y de clase: feols con HC1 e
# interacciones, causal_forest, average_treatment_effect (con subset),
# test_calibration y la muestra dividida del Lab 10 (bosque de entrenamiento
# para elegir, bosque de evaluacion independiente para medir).
#
# Bosques:
#   - cf_*_12: identicos a los del script 12 (W.hat estimado por grf), solo
#     para comprobar que se reproducen sus cifras;
#   - cf_*: W.hat = mean(W), la probabilidad de asignacion observada (mismo
#     argumento del Lab 10, que fija la probabilidad conocida). Son los que se
#     usan en el resto de verificaciones.
#
# Uso (desde la raiz del proyecto):
#   Rscript --vanilla 10_Auditoria/scripts/aud_correr.R aud_02_heterogeneidad_celdas.R
# Salidas: 10_Auditoria/salidas/aud_02_*.csv
# =============================================================================

# los paquetes los cargan las secciones 1 a 3 de 00_main.R (aud_correr.R)

set.seed(2026)
salida <- function(nombre) file.path("10_Auditoria/salidas", paste0("aud_02_", nombre, ".csv"))

n_arboles <- 2000
n_hilos <- 4

preparar <- function(d) {
  d |> mutate(
    mas_5_min = as.integer(time_spent > 5),
    tramo_sesiones = case_when(past_sessions <= 2 ~ "0-2", past_sessions <= 4 ~ "3-4",
                               TRUE ~ "5+"),
    celda_so = paste(device_type, os_type, sep = "_"),
    celda_ses = paste(device_type, tramo_sesiones, sep = "_")
  )
}
experimento <- readRDS("01_Datos/03_Listos/experimento_listos.RDS") |> preparar()
historica <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds") |> preparar()
n_exp <- nrow(experimento)

# particion en dos mitades del Lab 10 (seccion 3); se fija aqui para reportar
# el n de cada celda en cada mitad en todas las tablas por celda. Una celda con
# menos de 100 observaciones en alguna mitad se marca y no sostiene
# conclusiones de focalizacion
idx_ent <- sample(n_exp, n_exp / 2)
idx_eva <- setdiff(seq_len(n_exp), idx_ent)
ent <- experimento[idx_ent, ]
eva <- experimento[idx_eva, ]
n_minimo <- 100

n_mitades <- function(var, cel) {
  tibble(celda = cel,
         n_ent = map_int(cel, ~ sum(ent[[var]] %in% .x)),
         n_eva = map_int(cel, ~ sum(eva[[var]] %in% .x))) |>
    mutate(celda_pequena = pmin(n_ent, n_eva) < n_minimo)
}

# -----------------------------------------------------------------------------
# 0. Tablas cruzadas (Fase 6.1) y relacion recurrente / sesiones
# -----------------------------------------------------------------------------

cruce <- bind_rows(
  experimento |> count(device_type, os_type) |> mutate(base = "experimento"),
  historica |> count(device_type, os_type) |> mutate(base = "historica")
) |>
  group_by(base) |> mutate(pct_base = 100 * n / sum(n)) |>
  group_by(base, device_type) |> mutate(pct_dentro_dispositivo = 100 * n / sum(n)) |>
  ungroup()
write_csv(cruce, salida("cruce_dispositivo_so"))
print(cruce, n = Inf)

recurrente <- bind_rows(
  experimento |> count(is_returning_user, sesiones_cero = past_sessions == 0) |>
    mutate(base = "experimento"),
  historica |> count(is_returning_user, sesiones_cero = past_sessions == 0) |>
    mutate(base = "historica")
)
write_csv(recurrente, salida("recurrente_vs_sesiones"))
print(recurrente)

# -----------------------------------------------------------------------------
# 1. Bosques y ATE (Fase 4)
# -----------------------------------------------------------------------------

X <- model.matrix(~ time_spent + past_sessions + device_type + is_returning_user +
                    os_type, experimento)[, -1]
W <- experimento$easier_signup

estimar_bosque <- function(X, Y, W, ...) {
  causal_forest(X, Y, W, num.trees = n_arboles, seed = 2026,
                num.threads = n_hilos, ...)
}

cf_log_12 <- estimar_bosque(X, experimento$log_revenue, W)
cf_niv_12 <- estimar_bosque(X, experimento$Revenue, W)
cf_log <- estimar_bosque(X, experimento$log_revenue, W, W.hat = mean(W))
cf_niv <- estimar_bosque(X, experimento$Revenue, W, W.hat = mean(W))

# una celda vacia o casi vacia en una mitad devuelve NA en lugar de detener
# el script (de todas formas queda marcada como celda pequena)
ate <- function(cf, subset = NULL) {
  a <- tryCatch(average_treatment_effect(cf, subset = subset),
                error = function(e) c(estimate = NA_real_, std.err = NA_real_))
  tibble(estimacion = unname(a["estimate"]), ee = unname(a["std.err"]))
}
con_ic <- function(d) mutate(d, ic_inf = estimacion - 1.96 * ee, ic_sup = estimacion + 1.96 * ee)

mco <- function(formula) {
  m <- feols(formula, data = experimento, vcov = "hc1")
  tibble(estimacion = unname(coef(m)["easier_signup"]),
         ee = unname(se(m)["easier_signup"]))
}

fase4 <- bind_rows(
  ate(cf_log_12) |> mutate(escala = "log", estimador = "bosque, W.hat estimado (script 12)"),
  ate(cf_log) |> mutate(escala = "log", estimador = "bosque, W.hat = mean(W)"),
  mco(log_revenue ~ easier_signup) |> mutate(escala = "log", estimador = "MCO sin controles (HC1)"),
  ate(cf_niv_12) |> mutate(escala = "dolares", estimador = "bosque, W.hat estimado (script 12)"),
  ate(cf_niv) |> mutate(escala = "dolares", estimador = "bosque, W.hat = mean(W)"),
  mco(Revenue ~ easier_signup) |> mutate(escala = "dolares", estimador = "MCO sin controles (HC1)")
) |>
  con_ic() |>
  relocate(escala, estimador)
write_csv(fase4, salida("ate_bosque_vs_mco"))
print(fase4, width = Inf)

w_hat <- tibble(min = min(cf_log_12$W.hat), p05 = quantile(cf_log_12$W.hat, 0.05),
                media = mean(cf_log_12$W.hat), p95 = quantile(cf_log_12$W.hat, 0.95),
                max = max(cf_log_12$W.hat), mean_W = mean(W))
write_csv(w_hat, salida("w_hat_script12"))
print(w_hat)

calibracion <- bind_rows(
  as_tibble(test_calibration(cf_log)[, 1:4], rownames = "termino") |> mutate(escala = "log"),
  as_tibble(test_calibration(cf_niv)[, 1:4], rownames = "termino") |> mutate(escala = "dolares")
)
write_csv(calibracion, salida("calibracion_w_media"))
print(calibracion)

# -----------------------------------------------------------------------------
# 2. Efecto por celda dispositivo x SO y dispositivo x sesiones (Fases 5 y 6.2)
# -----------------------------------------------------------------------------
# Bosque: average_treatment_effect(subset). Para cada celda se agrega la media
# del gasto del grupo control, la lectura log-lin exp(tau) - 1 y su traduccion
# a dolares con el gasto base de la celda.

pesos <- function(var) {
  historica |> count(celda = .data[[var]]) |> mutate(peso_hist = n / sum(n)) |>
    select(celda, peso_hist)
}

efecto_celdas <- function(var) {
  cel <- sort(unique(experimento[[var]]))
  map_dfr(cel, function(c) {
    g <- experimento[[var]] == c
    d <- experimento[g, ]
    bind_cols(
      tibble(particion = var, celda = c, n = sum(g), peso_exp = mean(g),
             gasto_control = mean(d$Revenue[d$easier_signup == 0])),
      ate(cf_log, subset = g) |> rename(tau_log = estimacion, ee_log = ee),
      ate(cf_niv, subset = g) |> rename(tau_dolares = estimacion, ee_dolares = ee)
    )
  }) |>
    left_join(pesos(var), by = "celda") |>
    left_join(n_mitades(var, cel), by = "celda") |>
    mutate(
      cambio_pct = 100 * (exp(tau_log) - 1),
      dolares_implicados = gasto_control * (exp(tau_log) - 1),
      ic_log = sprintf("[%.3f; %.3f]", tau_log - 1.96 * ee_log, tau_log + 1.96 * ee_log),
      ic_dolares = sprintf("[%.2f; %.2f]", tau_dolares - 1.96 * ee_dolares,
                           tau_dolares + 1.96 * ee_dolares)
    )
}

celdas <- bind_rows(efecto_celdas("celda_so"), efecto_celdas("celda_ses"))
write_csv(celdas, salida("efecto_por_celda"))
print(celdas, n = Inf, width = Inf)

# identidad ATE = E[tau(X)]: el promedio de los efectos por celda, ponderado
# por el peso de cada celda en el experimento, reproduce el ATE global
identidad <- celdas |>
  group_by(particion) |>
  summarise(suma_log = sum(peso_exp * tau_log), suma_dolares = sum(peso_exp * tau_dolares),
            suma_log_pesos_hist = sum(peso_hist * tau_log),
            suma_dolares_pesos_hist = sum(peso_hist * tau_dolares), .groups = "drop") |>
  mutate(ate_log = ate(cf_log)$estimacion, ate_dolares = ate(cf_niv)$estimacion)
write_csv(identidad, salida("identidad_ate"))
print(identidad, width = Inf)

# MCO con interacciones (HC1): efecto por celda (diferencia de medias dentro de
# cada celda) y modelo aditivo dispositivo + SO frente al completo
mco_celdas <- map_dfr(c("log_revenue", "Revenue"), function(y) {
  m <- feols(as.formula(paste(y, "~ 0 + celda_so + celda_so:easier_signup")),
             data = experimento, vcov = "hc1")
  b <- coef(m); s <- se(m)
  nombres <- grep(":easier_signup", names(b), value = TRUE)
  tibble(resultado = y, celda = sub("^celda_so(.*):easier_signup$", "\\1", nombres),
         estimacion = unname(b[nombres]), ee = unname(s[nombres]))
}) |>
  con_ic() |>
  mutate(n = as.integer(table(experimento$celda_so)[celda])) |>
  left_join(n_mitades("celda_so", sort(unique(experimento$celda_so))), by = "celda")
write_csv(mco_celdas, salida("mco_por_celda"))
print(mco_celdas, n = Inf)

interacciones <- map_dfr(c("log_revenue", "Revenue"), function(y) {
  completo <- feols(as.formula(paste(y, "~ easier_signup * device_type * os_type")),
                    data = experimento, vcov = "hc1")
  aditivo <- feols(as.formula(paste(y, "~ easier_signup * (device_type + os_type)")),
                   data = experimento, vcov = "hc1")
  bind_rows(
    tibble(modelo = "completo", termino = names(coef(completo)),
           estimacion = coef(completo), ee = se(completo)),
    tibble(modelo = "aditivo", termino = names(coef(aditivo)),
           estimacion = coef(aditivo), ee = se(aditivo))
  ) |>
    filter(str_detect(termino, "easier_signup")) |>
    mutate(resultado = y)
}) |> con_ic()
write_csv(interacciones, salida("mco_interacciones"))
print(interacciones, n = Inf, width = Inf)

# -----------------------------------------------------------------------------
# 3. Reglas elegidas en una mitad y evaluadas en la otra (Fases 6.3 a 6.6)
# -----------------------------------------------------------------------------
# Como en el Lab 10: cf_ent se estima en la mitad de entrenamiento y con el se
# eligen las celdas a tratar (efecto estimado > 0); cf_eva, independiente, se
# estima en la mitad de evaluacion y mide:
#   - valor frente a "nadie" = peso(S) x ATE(cf_eva, subset = S);
#   - diferencia entre dos reglas = peso(D) x ATE(cf_eva, subset = D), con D
#     las celdas en que difieren (cuando una regla agrega celdas a la otra).

# la particion (idx_ent, idx_eva) se fijo al comienzo del script

peso_hist_de <- function(var, cel) sum(pesos(var)$peso_hist[pesos(var)$celda %in% cel])

evaluar_mitades <- function(y, escala) {
  cf_ent <- estimar_bosque(X[idx_ent, ], y[idx_ent], W[idx_ent], W.hat = mean(W[idx_ent]))
  cf_eva <- estimar_bosque(X[idx_eva, ], y[idx_eva], W[idx_eva], W.hat = mean(W[idx_eva]))

  # efecto por celda en cada mitad (para ver que se elige y que sobrevive)
  por_celda <- map_dfr(c("celda_so", "celda_ses"), function(var) {
    map_dfr(sort(unique(experimento[[var]])), function(c) {
      bind_rows(
        ate(cf_ent, subset = ent[[var]] == c) |> mutate(mitad = "entrenamiento"),
        ate(cf_eva, subset = eva[[var]] == c) |> mutate(mitad = "evaluacion")
      ) |> mutate(particion = var, celda = c)
    }) |>
      left_join(n_mitades(var, sort(unique(experimento[[var]]))), by = "celda")
  }) |>
    mutate(escala = escala) |> con_ic()

  # solo se eligen celdas con al menos n_minimo observaciones en cada mitad
  elegidas <- function(var) {
    por_celda |>
      filter(particion == var, mitad == "entrenamiento", estimacion > 0,
             !celda_pequena) |>
      pull(celda)
  }
  cel_so <- sort(unique(experimento$celda_so))
  cel_ses <- sort(unique(experimento$celda_ses))
  reglas <- list(
    list(nombre = "todos", var = "celda_so", S = cel_so),
    list(nombre = "computador y tableta", var = "celda_so",
         S = cel_so[!startsWith(cel_so, "mobile_")]),
    list(nombre = "todos menos celular Windows u otro", var = "celda_so",
         S = setdiff(cel_so, c("mobile_windows", "mobile_other"))),
    list(nombre = "elegida en entrenamiento (dispositivo x SO)", var = "celda_so",
         S = elegidas("celda_so")),
    list(nombre = "elegida en entrenamiento (dispositivo x sesiones)", var = "celda_ses",
         S = elegidas("celda_ses")),
    list(nombre = "3 o mas sesiones", var = "celda_ses",
         S = cel_ses[!str_ends(cel_ses, "0-2")])
  )

  valor <- map_dfr(reglas, function(r) {
    en_S <- eva[[r$var]] %in% r$S
    tam <- n_mitades(r$var, r$S)
    ate(cf_eva, subset = en_S) |>
      mutate(regla = r$nombre, celdas = paste(r$S, collapse = ";"),
             peso_hist = peso_hist_de(r$var, r$S),
             n_ent = sum(ent[[r$var]] %in% r$S), n_eva = sum(en_S),
             celdas_pequenas = paste(tam$celda[tam$celda_pequena], collapse = ";"))
  }) |>
    mutate(escala = escala, valor_vs_nadie = peso_hist * estimacion,
           ee_valor = peso_hist * ee) |>
    con_ic()

  # diferencias entre reglas anidadas: el efecto de las celdas que una agrega
  diferencia <- function(nombre, var, D) {
    en_D <- eva[[var]] %in% D
    tam <- n_mitades(var, D)
    ate(cf_eva, subset = en_D) |>
      mutate(comparacion = nombre, celdas = paste(D, collapse = ";"),
             peso_hist = peso_hist_de(var, D),
             n_ent = sum(ent[[var]] %in% D), n_eva = sum(en_D),
             celdas_pequenas = paste(tam$celda[tam$celda_pequena], collapse = ";"))
  }
  difs <- bind_rows(
    diferencia("todos menos celular Windows u otro - computador y tableta",
               "celda_so", "mobile_osx"),
    diferencia("todos - computador y tableta (celulares)", "celda_so",
               cel_so[startsWith(cel_so, "mobile_")]),
    diferencia("todos - todos menos celular Windows u otro", "celda_so",
               c("mobile_windows", "mobile_other")),
    diferencia("todos - 3 o mas sesiones (0 a 2 sesiones)", "celda_ses",
               cel_ses[str_ends(cel_ses, "0-2")])
  ) |>
    mutate(escala = escala, valor_diferencia = peso_hist * estimacion,
           ee_diferencia = peso_hist * ee) |>
    con_ic()

  list(por_celda = por_celda, valor = valor, difs = difs)
}

mitades <- list(
  evaluar_mitades(experimento$log_revenue, "log"),
  evaluar_mitades(experimento$Revenue, "dolares")
)

write_csv(map_dfr(mitades, "por_celda"), salida("mitades_por_celda"))
write_csv(map_dfr(mitades, "valor"), salida("mitades_valor_reglas"))
write_csv(map_dfr(mitades, "difs"), salida("mitades_diferencias_reglas"))
print(map_dfr(mitades, "por_celda"), n = Inf, width = Inf)
print(map_dfr(mitades, "valor"), n = Inf, width = Inf)
print(map_dfr(mitades, "difs"), n = Inf, width = Inf)

cat("\nListo: salidas en 10_Auditoria/salidas/aud_02_*.csv\n")
