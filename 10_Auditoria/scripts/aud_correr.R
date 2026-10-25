# =============================================================================
# Auditoria: corre las secciones 1 a 3 de 00_main.R (raiz, paquetes, carpetas)
# y despues el script de auditoria que se pase como argumento.
# Uso (desde la raiz del proyecto):
#   Rscript --vanilla 10_Auditoria/scripts/aud_correr.R aud_02_heterogeneidad_celdas.R
# =============================================================================

options(warn = 1)
lineas <- readLines("00_main.R", encoding = "UTF-8")
fin_seccion_3 <- grep("^# 4\\. Orden de ejecucion", lineas) - 2
eval(parse(text = lineas[seq_len(fin_seccion_3)], encoding = "UTF-8"))

script <- commandArgs(trailingOnly = TRUE)[1]
t0 <- Sys.time()
source(file.path("10_Auditoria/scripts", script), encoding = "UTF-8")
cat("\nTIEMPO_MIN:", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 2), "\n")
