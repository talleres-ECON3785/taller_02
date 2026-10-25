# =============================================================================
# Auditoria: corre las secciones 1 a 3 de 00_main.R y despues solo los scripts
# 12 y 13 del pipeline, igual que 00_main.R (source en un entorno nuevo), sin
# re-correr el pipeline completo.
# Uso (desde la raiz del proyecto):
#   Rscript --vanilla 10_Auditoria/scripts/aud_05_correr_12_13.R
# =============================================================================

options(warn = 1)
lineas <- readLines("00_main.R", encoding = "UTF-8")
fin_seccion_3 <- grep("^# 4\\. Orden de ejecucion", lineas) - 2
eval(parse(text = lineas[seq_len(fin_seccion_3)], encoding = "UTF-8"))

for (script in c("02_Scripts/12_heterogeneidad_experimento.R",
                 "02_Scripts/13_focalizacion_experimento.R")) {
  t0 <- Sys.time()
  message("Ejecutando: ", script)
  source(script, local = new.env(), encoding = "UTF-8")
  message("Tiempo (min): ", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 2))
}
