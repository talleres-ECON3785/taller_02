# =============================================================================
# Auditoria: corre las secciones 1 a 3 de 00_main.R y despues solo el script 04
# (igual que 00_main.R: source en un entorno nuevo), y compara la escalera en
# ln(Revenue) que exporta 04 con la de la auditoria (aud_04).
# Uso (desde la raiz del proyecto):
#   Rscript --vanilla 10_Auditoria/scripts/aud_07_correr_04.R
# =============================================================================

options(warn = 1)
lineas <- readLines("00_main.R", encoding = "UTF-8")
fin_seccion_3 <- grep("^# 4\\. Orden de ejecucion", lineas) - 2
eval(parse(text = lineas[seq_len(fin_seccion_3)], encoding = "UTF-8"))

source("02_Scripts/04_prediccion_lineal_observacional.R", local = new.env(),
       encoding = "UTF-8")

pipeline <- read_csv(
  "03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_escalera_rmse_log.csv",
  show_col_types = FALSE
)
auditoria <- read_csv("10_Auditoria/salidas/aud_04_escalera_dos_escalas.csv",
                      show_col_types = FALSE) |>
  filter(respuesta == "log_revenue")

comparacion <- tibble(
  paso = pipeline$paso,
  rmse_pipeline = pipeline$rmse_cv, rmse_auditoria = auditoria$rmse_cv,
  caida_pipeline = pipeline$caida, caida_auditoria = auditoria$caida
) |>
  mutate(dif_rmse = abs(rmse_pipeline - rmse_auditoria),
         dif_caida = abs(caida_pipeline - caida_auditoria))
print(comparacion, width = Inf)
cat("Diferencia maxima RMSE:", max(comparacion$dif_rmse),
    "| caida:", max(comparacion$dif_caida, na.rm = TRUE), "\n")
cat("% de la caida total (pipeline):",
    paste(round(pipeline$caida_pct_total, 1), collapse = " / "), "\n")
