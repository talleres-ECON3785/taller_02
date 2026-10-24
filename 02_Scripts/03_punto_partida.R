# =============================================================================
# Punto de partida: Revenue en nivel frente a las covariables
# Taller 2 - ECON-3785
#
# Descriptiva de la base observacional con Revenue en nivel (dolares), la escala
# del Taller 1: como varia el ingreso con time_spent, past_sessions,
# device_type, os_type e is_returning_user (heuristica H3). Es el punto de
# partida del Taller 2; el mismo analisis en logaritmo esta en
# '04_forma_funcional_observacional.R'.
#
# Puramente descriptivo: asociaciones en datos historicos (sin asignacion
# aleatoria), no efectos causales. Estimando: ninguno; se describe la media
# condicional del ingreso dada cada covariable.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# funciones de las figuras (y, a traves de ellas, el formato de las graficas)
source("02_Scripts/00_formato_descriptivas.R")

set.seed(2026)

# subcarpeta de 03_Resultados/Figuras/ de este script (nombre del script)
carpeta_salida <- "03_punto_partida"

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds")

# en esta base is_returning_user == 1 exactamente cuando past_sessions > 0, asi
# que la figura de usuario recurrente no agrega informacion frente a la de
# sesiones pasadas: resume el contraste "0 sesiones" vs. "1 o mas"
stopifnot(all((obs$is_returning_user == 1) == (obs$past_sessions > 0)))

# -----------------------------------------------------------------------------
# Revenue en nivel (dolares, escala del Taller 1)
# -----------------------------------------------------------------------------

graficar_covariables(
  obs, y = "Revenue", prefijo = "revenue", etiqueta_y = "ingreso (dólares)",
  carpeta = carpeta_salida, eje_log = TRUE
)

cat("\nListo. Figuras guardadas en 03_Resultados/Figuras/03_punto_partida/.\n")
cat("Recordatorio: son asociaciones descriptivas, no efectos causales.\n")
