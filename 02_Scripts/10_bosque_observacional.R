# =============================================================================
# Bagging y bosque aleatorio para predecir el ingreso, en dolares y en logaritmo
# Taller 2 - ECON-3785 (Parte A)
#
# Estimando: ninguno causal; el objetivo es predecir el ingreso de un usuario
# nuevo con la base historica. Estimador: bosque aleatorio (ranger), con
# bagging como caso particular (mtry = numero de predictores). Medida: RMSE
# fuera de bolsa (OOB) dentro de 'train'. La importancia por permutacion indica
# cuanto usa el bosque cada variable para predecir, no su efecto.
#
# Disenio:
#   - Misma particion 80/20 (set.seed(2026)) que 04, 05 y 09.
#   - Las 6 variables crudas del Taller 1 (como en el arbol del 09).
#   - Las dos escalas: Revenue (dolares) y ln(Revenue).
#   - Hiperparametros elegidos solo con 'train', por error OOB, en una rejilla
#     mtry (1 a 6) x min.node.size (5, 25, 100) con 300 arboles (mas arboles no
#     sobreajustan; el Lab 08 muestra que 300 bastan para ordenar la rejilla).
#     La combinacion elegida se reestima con 1000 arboles y con importancia por
#     permutacion (ampliacion registrada en el catalogo).
#   - 'test' no se usa en este script: la evaluacion en prueba es del 11, que
#     lee los hiperparametros elegidos de la tabla que exporta este script.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema y funcion de guardado de las figuras; estilo de las tablas
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "10_bosque_observacional"

# -----------------------------------------------------------------------------
# 1. Datos y particion train/test (la del Taller 1 y la de 04, 05 y 09)
# -----------------------------------------------------------------------------

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds")

n <- nrow(obs)
set.seed(2026)
indices_train <- sample(seq_len(n), size = round(0.8 * n))
train <- obs[indices_train, ]
# 'test' no se define aqui: este script solo usa 'train'

cat(sprintf("train = %s\n", format(nrow(train), big.mark = ",")))

# -----------------------------------------------------------------------------
# 2. Especificacion
# -----------------------------------------------------------------------------

predictores <- c("sign_up", "time_spent", "past_sessions", "device_type",
                 "is_returning_user", "os_type")

escalas <- tribble(
  ~escala,       ~respuesta,
  "Dólares",     "Revenue",
  "Logaritmo",   "log_revenue"
)

etiquetas_variables <- c(
  "time_spent" = "Tiempo en el sitio (min)",
  "past_sessions" = "Sesiones anteriores",
  "device_type" = "Dispositivo",
  "os_type" = "Sistema operativo",
  "is_returning_user" = "Usuario recurrente",
  "sign_up" = "Registro"
)

# ranger tiene su propia semilla (set.seed() no basta). Bootstrap con
# reemplazo del tamano de 'train' y arboles sin limite de profundidad, como en
# el catalogo (seccion 4)
ajustar_bosque <- function(respuesta, mtry, min_nodo, arboles,
                           importancia = "none") {
  ranger(
    reformulate(predictores, response = respuesta),
    data            = train,
    num.trees       = arboles,
    mtry            = mtry,
    min.node.size   = min_nodo,
    replace         = TRUE,
    sample.fraction = 1,
    importance      = importancia,
    seed            = 2026
  )
}

# -----------------------------------------------------------------------------
# 3. Rejilla de hiperparametros por error OOB
# -----------------------------------------------------------------------------

rejilla <- expand_grid(
  escalas,
  mtry = seq_along(predictores),
  min_nodo = c(5, 25, 100)
)

rejilla <- rejilla |>
  mutate(rmse_oob = pmap_dbl(
    list(respuesta, mtry, min_nodo),
    function(respuesta, mtry, min_nodo) {
      sqrt(ajustar_bosque(respuesta, mtry, min_nodo, arboles = 300)$prediction.error)
    }
  ))

print(rejilla, n = Inf)

# referencia: RMSE de la media de 'train' en cada escala (la referencia ingenua
# del Taller 1, dentro de 'train')
rmse_media <- map_dbl(set_names(escalas$respuesta, escalas$escala),
                      ~ sqrt(mean((train[[.x]] - mean(train[[.x]]))^2)))

# -----------------------------------------------------------------------------
# 4. Combinacion elegida (y bagging) reestimada con 1000 arboles
# -----------------------------------------------------------------------------

# bagging: mtry = 6 (todas las variables en cada corte), con su mejor tamano
# de nodo; bosque: la combinacion de menor RMSE OOB de toda la rejilla
elegidos <- bind_rows(
  rejilla |> group_by(escala) |> slice_min(rmse_oob, n = 1, with_ties = FALSE) |>
    mutate(modelo = "Bosque aleatorio"),
  rejilla |> filter(mtry == length(predictores)) |> group_by(escala) |>
    slice_min(rmse_oob, n = 1, with_ties = FALSE) |>
    mutate(modelo = "Bagging")
) |>
  ungroup()

# cada bosque final queda en una columna de lista de 'elegidos', para que
# siga a su fila al reordenar
elegidos <- elegidos |>
  mutate(bosque = pmap(
    list(respuesta, mtry, min_nodo),
    function(respuesta, mtry, min_nodo) {
      ajustar_bosque(respuesta, mtry, min_nodo, arboles = 1000,
                     importancia = "permutation")
    }
  )) |>
  mutate(
    rmse_oob_300 = rmse_oob,
    rmse_oob = map_dbl(bosque, ~ sqrt(.x$prediction.error)),
    rmse_media = rmse_media[escala],
    mejora_media_pct = 100 * (1 - rmse_oob / rmse_media),
    arboles = 1000,
    titular = modelo == "Bosque aleatorio"
  ) |>
  arrange(escala, desc(titular))

print(select(elegidos, -bosque))

# el tamano de nodo elegido puede quedar en el borde de la rejilla: cuanto
# cambia el RMSE OOB entre tamanos de nodo con el mtry elegido
sensibilidad_nodo <- rejilla |>
  semi_join(filter(elegidos, titular), by = c("escala", "mtry")) |>
  group_by(escala) |>
  summarise(rango = max(rmse_oob) - min(rmse_oob))
print(sensibilidad_nodo)

# -----------------------------------------------------------------------------
# 5. Importancia por permutacion del bosque titular
# -----------------------------------------------------------------------------

# aumento del error cuadratico OOB al permutar cada variable (rompe su relacion
# con el ingreso y deja las demas igual). Se reporta como % de la suma de las
# importancias de cada bosque. Es uso del modelo, no efecto
importancia <- elegidos |>
  filter(titular) |>
  select(escala, bosque) |>
  pmap_dfr(function(escala, bosque) {
    imp <- bosque$variable.importance
    tibble(
      escala = escala,
      variable = unname(etiquetas_variables[names(imp)]),
      aumento_ecm = unname(imp),
      # una importancia negativa (permutar no empeora el error) cuenta como 0
      importancia_pct = 100 * pmax(unname(imp), 0) / sum(pmax(imp, 0))
    )
  })
print(importancia)

# -----------------------------------------------------------------------------
# 6. Tabla: hiperparametros elegidos y error OOB
# -----------------------------------------------------------------------------

tabla_elegidos <- elegidos |>
  transmute(
    escala,
    modelo = if_else(titular, paste(modelo, "(titular)"), modelo),
    mtry, min_nodo, rmse_media, rmse_oob, mejora_media_pct
  ) |>
  gt(groupname_col = "escala") |>
  cols_label(
    modelo = "Modelo",
    mtry = "Variables sorteadas por corte",
    min_nodo = "Tamaño mínimo de nodo",
    rmse_media = "RMSE de la media",
    rmse_oob = "RMSE fuera de bolsa",
    mejora_media_pct = "Mejora frente a la media (%)"
  ) |>
  fmt_number(c(rmse_media, rmse_oob), decimals = decimales$rmse) |>
  fmt_number(mejora_media_pct, decimals = decimales$porcentaje) |>
  cols_align("center", -modelo) |>
  estilo_tabla(
    titulo = "Error fuera de bolsa del bosque aleatorio y del bagging",
    subtitulo = "Ingreso en dólares y en logaritmo; cada RMSE en la escala de su modelo",
    nota = nota_tabla(
      "observacional", nrow(train), "entrenamiento", enfoque = "predictivo",
      extra = c(
        paste(
          "Hiperparámetros elegidos por el menor RMSE fuera de bolsa en una rejilla",
          "de 1 a 6 variables sorteadas por corte × tamaño mínimo de nodo 5, 25 y",
          "100 (300 árboles); el modelo elegido se reestima con 1,000 árboles."
        ),
        paste(
          "Bagging: las 6 variables disponibles en cada corte. Variables del",
          "Taller 1: tiempo en el sitio (continuo), sesiones anteriores,",
          "dispositivo, sistema operativo, usuario recurrente y registro."
        ),
        paste(
          "RMSE en dólares o en unidades de logaritmo según la escala; los de",
          "escalas distintas no son comparables entre sí. El error fuera de bolsa",
          "no es la validación cruzada de 5 pliegues de los modelos lineales."
        ),
        sprintf(
          paste(
            "Con las variables sorteadas elegidas, el RMSE fuera de bolsa cambia",
            "menos de %.3f (dólares) y %.3f (logaritmo) entre los tamaños de nodo",
            "de la rejilla."
          ),
          ceiling(1000 * sensibilidad_nodo$rango[sensibilidad_nodo$escala == "Dólares"]) / 1000,
          ceiling(1000 * sensibilidad_nodo$rango[sensibilidad_nodo$escala == "Logaritmo"]) / 1000
        )
      )
    )
  )

# el .csv lleva solo las cifras y los hiperparametros (lo lee el script 11)
guardar_tabla(
  "observacional_bosque_elegido", tabla_elegidos,
  select(elegidos, escala, respuesta, modelo, titular, mtry, min_nodo, arboles,
         rmse_oob_300, rmse_oob, rmse_media, mejora_media_pct),
  carpeta_salida
)

# -----------------------------------------------------------------------------
# 7. Figura: rejilla de hiperparametros
# -----------------------------------------------------------------------------

grafica_rejilla <- rejilla |>
  mutate(min_nodo = factor(min_nodo, levels = c(5, 25, 100))) |>
  ggplot(aes(x = mtry, y = rmse_oob, color = min_nodo)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.2) +
  geom_point(
    data = elegidos |> filter(titular),
    aes(x = mtry, y = rmse_oob_300), inherit.aes = FALSE,
    shape = 21, size = 5, stroke = 1, color = gris_texto
  ) +
  facet_wrap(~ escala, scales = "free_y") +
  scale_color_manual(values = paleta_categorica, name = "Tamaño mínimo de nodo") +
  scale_x_continuous(breaks = seq_along(predictores)) +
  labs(
    title = "Error fuera de bolsa según los hiperparámetros del bosque",
    subtitle = subtitulo_observacional_predictivo,
    x = "Variables sorteadas en cada corte (6 = bagging)",
    y = "RMSE fuera de bolsa (escala del panel)",
    caption = paste(
      sprintf("Nota: n = %s usuarios de entrenamiento; 300 árboles por combinación.",
              format(nrow(train), big.mark = ",")),
      "El círculo marca la combinación elegida. Panel de dólares en dólares; panel de logaritmo en unidades de logaritmo.",
      sep = "\n"
    )
  ) +
  tema_presentacion +
  tema_paneles +
  theme(
    plot.title.position = "plot", plot.caption.position = "plot",
    legend.position = "top", legend.justification = "left"
  )

guardar_figura("observacional_bosque_rejilla.png", grafica_rejilla, carpeta_salida)

# -----------------------------------------------------------------------------
# 8. Figura: importancia por permutacion
# -----------------------------------------------------------------------------

orden_variables <- importancia |>
  filter(escala == "Logaritmo") |>
  arrange(importancia_pct) |>
  pull(variable)

grafica_importancia <- importancia |>
  mutate(variable = factor(variable, levels = orden_variables)) |>
  ggplot(aes(x = importancia_pct, y = variable)) +
  geom_col(fill = paleta_categorica[1], width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%", importancia_pct)),
            hjust = -0.15, size = 3.6, color = gris_secundario) +
  facet_wrap(~ escala) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.18))) +
  labs(
    title = "Qué variables usa el bosque aleatorio para predecir el ingreso",
    subtitle = subtitulo_observacional_predictivo,
    x = "Importancia por permutación (% de la suma de cada bosque)",
    y = NULL,
    caption = paste(
      sprintf(
        "Nota: n = %s usuarios de entrenamiento; bosque titular de cada escala (1,000 árboles).",
        format(nrow(train), big.mark = ",")
      ),
      "Importancia: aumento del error fuera de bolsa al permutar la variable. Indica cuánto usa el bosque cada variable, no su efecto.",
      sep = "\n"
    )
  ) +
  tema_presentacion +
  tema_paneles +
  theme(
    plot.title.position = "plot", plot.caption.position = "plot",
    axis.text.x = element_text(size = 10, color = gris_secundario, face = "plain"),
    axis.text.y = element_text(color = gris_texto)
  )

guardar_figura("observacional_bosque_importancia.png", grafica_importancia, carpeta_salida)
