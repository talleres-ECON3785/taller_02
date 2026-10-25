# =============================================================================
# Auditoria, Fase 1: corre 00_main.R completo en una sesion limpia
#
# No forma parte del pipeline. Muestra cada advertencia en el momento en que
# ocurre (options(warn = 1)), para poder atribuirla a su script, y reporta el
# tiempo total y la version de R y de los paquetes.
# Uso (desde la raiz del proyecto):
#   Rscript --vanilla 10_Auditoria/scripts/aud_00_correr_main.R
# =============================================================================

options(warn = 1)
t0 <- Sys.time()
source("00_main.R", encoding = "UTF-8")
cat("\nTIEMPO_TOTAL_MIN:",
    round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 2), "\n")
print(sessionInfo())
