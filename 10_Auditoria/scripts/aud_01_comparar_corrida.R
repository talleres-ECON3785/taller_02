# =============================================================================
# Auditoria, Fase 1: compara las tablas .csv de la linea base (03_Resultados/
# copiado antes de la corrida, en 10_Auditoria/salidas/resultados_originales/)
# con las que regenera una corrida limpia de 00_main.R en 03_Resultados/
#
# No forma parte del pipeline: 00_main.R no lo llama.
# Uso (desde la raiz del proyecto, despues de las secciones 1 a 3 de 00_main.R):
#   source("10_Auditoria/scripts/aud_01_comparar_corrida.R", encoding = "UTF-8")
# Salida: 10_Auditoria/salidas/aud_01_diferencias_csv.csv
# =============================================================================

# los paquetes los cargan las secciones 1 a 3 de 00_main.R (correrlas antes)

dir_original   <- "10_Auditoria/salidas/resultados_originales/Tablas"
dir_regenerado <- "03_Resultados/Tablas"

csv_o <- list.files(dir_original, pattern = "\\.csv$", recursive = TRUE)
csv_r <- list.files(dir_regenerado, pattern = "\\.csv$", recursive = TRUE)

faltan_en_corrida <- setdiff(csv_o, csv_r)
nuevos_en_corrida <- setdiff(csv_r, csv_o)

# compara dos tablas columna a columna: numericas por diferencia absoluta y
# relativa maxima; texto por igualdad exacta
comparar <- function(archivo) {
  o <- read_csv(file.path(dir_original, archivo), show_col_types = FALSE,
                guess_max = 1e5)
  r <- read_csv(file.path(dir_regenerado, archivo), show_col_types = FALSE,
                guess_max = 1e5)
  if (!identical(dim(o), dim(r)) || !identical(names(o), names(r))) {
    return(tibble(archivo, columna = "(estructura)", tipo = "estructura",
                  dif_abs_max = NA_real_, dif_rel_max = NA_real_,
                  celdas_distintas = NA_integer_,
                  detalle = sprintf("original %s x %s; regenerado %s x %s",
                                    nrow(o), ncol(o), nrow(r), ncol(r))))
  }
  map_dfr(names(o), function(col) {
    a <- o[[col]]; b <- r[[col]]
    if (is.numeric(a) && is.numeric(b)) {
      d <- abs(a - b)
      rel <- d / pmax(abs(a), 1e-12)
      distintas <- sum(xor(is.na(a), is.na(b)) | (!is.na(d) & d > 1e-9))
      tibble(archivo, columna = col, tipo = "numerica",
             dif_abs_max = suppressWarnings(max(d, na.rm = TRUE)),
             dif_rel_max = suppressWarnings(max(rel, na.rm = TRUE)),
             celdas_distintas = distintas, detalle = NA_character_)
    } else {
      distintas <- sum(xor(is.na(a), is.na(b)) |
                         (!is.na(a) & !is.na(b) & as.character(a) != as.character(b)))
      tibble(archivo, columna = col, tipo = "texto",
             dif_abs_max = NA_real_, dif_rel_max = NA_real_,
             celdas_distintas = distintas, detalle = NA_character_)
    }
  })
}

diferencias <- map_dfr(intersect(csv_o, csv_r), comparar) |>
  mutate(across(c(dif_abs_max, dif_rel_max), ~ ifelse(is.infinite(.x), NA, .x)))

write_csv(diferencias, "10_Auditoria/salidas/aud_01_diferencias_csv.csv")

cat("Archivos .csv originales:", length(csv_o), "| regenerados:", length(csv_r), "\n")
cat("Faltan en la corrida:", if (length(faltan_en_corrida)) paste(faltan_en_corrida, collapse = ", ") else "ninguno", "\n")
cat("Nuevos en la corrida:", if (length(nuevos_en_corrida)) paste(nuevos_en_corrida, collapse = ", ") else "ninguno", "\n\n")
cat("Columnas con alguna diferencia (> 1e-9):\n")
diferencias |>
  filter(celdas_distintas > 0 | tipo == "estructura") |>
  arrange(desc(dif_rel_max)) |>
  print(n = Inf, width = Inf)
