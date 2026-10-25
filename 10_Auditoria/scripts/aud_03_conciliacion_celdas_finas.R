# =============================================================================
# Auditoria, Fase 5: conciliacion nivel vs. log con celdas mas finas
# (dispositivo x SO x tramo de sesiones, solo celdas con n >= 100)
#
# No forma parte del pipeline. Solo herramientas del catalogo: causal_forest
# (W.hat = mean(W)), average_treatment_effect(subset), la lectura exp(tau) - 1
# y la media del gasto del grupo control por celda. Pregunta: cuanto del
# "residuo dentro de celda" de la particion dispositivo x SO (ATE en dolares
# menos lo implicado por los efectos proporcionales y el gasto base de cada
# celda) lo absorbe la particion mas fina.
#
# Uso (desde la raiz del proyecto):
#   Rscript --vanilla 10_Auditoria/scripts/aud_correr.R aud_03_conciliacion_celdas_finas.R
# Salidas: 10_Auditoria/salidas/aud_03_*.csv
# =============================================================================

# los paquetes los cargan las secciones 1 a 3 de 00_main.R (aud_correr.R)

set.seed(2026)
salida <- function(nombre) file.path("10_Auditoria/salidas", paste0("aud_03_", nombre, ".csv"))

experimento <- readRDS("01_Datos/03_Listos/experimento_listos.RDS") |>
  mutate(
    tramo_sesiones = case_when(past_sessions <= 2 ~ "0-2", past_sessions <= 4 ~ "3-4",
                               TRUE ~ "5+"),
    celda_so = paste(device_type, os_type, sep = "_"),
    celda_fina = paste(device_type, os_type, tramo_sesiones, sep = "_")
  )

X <- model.matrix(~ time_spent + past_sessions + device_type + is_returning_user +
                    os_type, experimento)[, -1]
W <- experimento$easier_signup

# mismos bosques de verificacion que aud_02 (W.hat = mean(W))
estimar_bosque <- function(Y) {
  causal_forest(X, Y, W, W.hat = mean(W), num.trees = 2000, seed = 2026,
                num.threads = 4)
}
cf_log <- estimar_bosque(experimento$log_revenue)
cf_niv <- estimar_bosque(experimento$Revenue)

ate <- function(cf, subset = NULL) {
  a <- average_treatment_effect(cf, subset = subset)
  c(estimacion = unname(a["estimate"]), ee = unname(a["std.err"]))
}

# efecto por celda de una particion, con gasto medio del control
por_celda <- function(var) {
  map_dfr(sort(unique(experimento[[var]])), function(c) {
    g <- experimento[[var]] == c
    d <- experimento[g, ]
    tl <- ate(cf_log, subset = g); tn <- ate(cf_niv, subset = g)
    tibble(particion = var, celda = c, n = sum(g),
           n_control = sum(d$easier_signup == 0), n_tratado = sum(d$easier_signup == 1),
           gasto_control = mean(d$Revenue[d$easier_signup == 0]),
           tau_log = tl[["estimacion"]], ee_log = tl[["ee"]],
           tau_dolares = tn[["estimacion"]], ee_dolares = tn[["ee"]])
  }) |>
    mutate(cambio_pct = 100 * (exp(tau_log) - 1),
           dolares_implicados = gasto_control * (exp(tau_log) - 1))
}

finas <- por_celda("celda_fina")
write_csv(finas, salida("efecto_celdas_finas"))
print(finas, n = Inf, width = Inf)

# poblacion cubierta: usuarios en celdas finas con n >= 100
cubiertas <- finas$celda[finas$n >= 100]
en_cubierta <- experimento$celda_fina %in% cubiertas
cat(sprintf("Celdas finas: %d; con n >= 100: %d; usuarios cubiertos: %d de %d\n",
            nrow(finas), length(cubiertas), sum(en_cubierta), nrow(experimento)))

# comparacion en la misma poblacion cubierta: ATE en dolares, implicado con la
# particion dispositivo x SO y con la particion fina
pob <- experimento[en_cubierta, ]
gruesas_cubiertas <- map_dfr(sort(unique(pob$celda_so)), function(c) {
  g_total <- en_cubierta & experimento$celda_so == c
  d <- experimento[g_total, ]
  tl <- ate(cf_log, subset = g_total)
  tibble(celda = c, n = sum(g_total),
         gasto_control = mean(d$Revenue[d$easier_signup == 0]),
         tau_log = tl[["estimacion"]])
}) |>
  mutate(dolares_implicados = gasto_control * (exp(tau_log) - 1))

finas_cubiertas <- finas |> filter(n >= 100)

resumen <- tibble(
  usuarios_cubiertos = sum(en_cubierta),
  ate_dolares = ate(cf_niv, subset = en_cubierta)[["estimacion"]],
  ate_log = ate(cf_log, subset = en_cubierta)[["estimacion"]],
  implicado_dispositivo_so = sum(gruesas_cubiertas$n * gruesas_cubiertas$dolares_implicados) /
    sum(gruesas_cubiertas$n),
  implicado_fino = sum(finas_cubiertas$n * finas_cubiertas$dolares_implicados) /
    sum(finas_cubiertas$n)
) |>
  mutate(
    residuo_dispositivo_so = ate_dolares - implicado_dispositivo_so,
    residuo_fino = ate_dolares - implicado_fino,
    absorbido_pct = 100 * (residuo_dispositivo_so - residuo_fino) / residuo_dispositivo_so
  )
write_csv(resumen, salida("resumen"))
print(resumen, width = Inf)

cat("\nListo: salidas en 10_Auditoria/salidas/aud_03_*.csv\n")
