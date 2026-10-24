# =============================================================================
# Forma funcional: ln(Revenue) frente a las covariables
# Taller 2 - ECON-3785
#
# Descriptiva de la base observacional con ln(Revenue) = log(Revenue), la escala
# del Taller 2: las mismas figuras de '03_punto_partida.R'
# pero con el logaritmo del ingreso. Las diferencias se leen como cambios
# proporcionales aproximados, no como dolares. Comparar ambos scripts muestra
# que cambia por la forma funcional (aqui no hay metodo: solo medias
# condicionales).
#
# Puramente descriptivo: asociaciones en datos historicos (sin asignacion
# aleatoria), no efectos causales. Estimando: ninguno.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# funciones de las figuras (y, a traves de ellas, el formato de las graficas)
source("02_Scripts/00_formato_descriptivas.R")

set.seed(2026)

# subcarpeta de 03_Resultados/Figuras/ de este script (nombre del script)
carpeta_salida <- "04_forma_funcional_observacional"

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds")

# en esta base is_returning_user == 1 exactamente cuando past_sessions > 0, asi
# que la figura de usuario recurrente no agrega informacion frente a la de
# sesiones pasadas: resume el contraste "0 sesiones" vs. "1 o mas"
stopifnot(all((obs$is_returning_user == 1) == (obs$past_sessions > 0)))

# -----------------------------------------------------------------------------
# ln(Revenue) (escala del Taller 2)
# -----------------------------------------------------------------------------

graficar_covariables(
  obs, y = "log_revenue", prefijo = "lnrevenue", etiqueta_y = "ln(ingreso)",
  etiqueta_x = "Logaritmo natural del ingreso",
  carpeta = carpeta_salida
)

cat("\nListo. Figuras guardadas en 03_Resultados/Figuras/04_forma_funcional_observacional/.\n")
cat("Recordatorio: son asociaciones descriptivas, no efectos causales.\n")
