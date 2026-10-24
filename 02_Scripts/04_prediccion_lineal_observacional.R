# =============================================================================
# Prediccion lineal de Revenue: escalera de modelos y aporte de cada variable
# Taller 2 - ECON-3785 (Parte A)
#
# Estimando: ninguno causal; el objetivo es predecir Revenue (dolares) de un
# usuario nuevo con la base historica. Estimador: regresion lineal (MCO).
# Medida: RMSE fuera de muestra. La "importancia" de una variable es cuanto
# baja el RMSE al agregarla (heuristicas H4 y H5): aporte predictivo, no efecto
# causal (no hay asignacion aleatoria).
#
# Disenio:
#   - Particion 80/20 con set.seed(2026), la del Taller 1 (catalogo de metodos).
#   - La escalera y los aportes se evaluan con validacion cruzada de 5 pliegues
#     dentro de 'train'; 'test' se toca una sola vez, al final.
#   - Cada escalon agrega algo que mostro la descriptiva (03_punto_partida.R):
#     quiebre en 5 minutos, diferencias por dispositivo, sistema operativo y
#     usuario recurrente, e interaccion entre el quiebre y las sesiones pasadas.
#   - El tiempo entra solo como indicador de mas de 5 minutos: el ingreso es
#     plano a cada lado del corte (pendientes cercanas a cero, el salto es de
#     ~3 dolares), asi que time_spent continuo no agrega nada una vez que esta
#     el indicador (el RMSE de CV es igual con indicador, con tiempo lineal o
#     con ambos). Si se incluyera como primer escalon, "inflaria" la importancia
#     del tiempo al hacer de aproximacion del salto. time_spent continuo solo
#     aparece en el lineal del Taller 1, que es la referencia.
#   - Solo Revenue en nivel. La escala logaritmica queda para otro script.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema y funcion de guardado de las figuras; estilo de las tablas
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "04_prediccion_lineal_observacional"

rmse <- function(y, prediccion) sqrt(mean((y - prediccion)^2))

# -----------------------------------------------------------------------------
# 1. Datos y particion train/test (la del Taller 1)
# -----------------------------------------------------------------------------

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds") |>
  # indicador del quiebre: el corte de 5 minutos viene del Taller 1 y de la
  # descriptiva (quiebre de nivel confirmado fuera de muestra); no se afina aqui
  mutate(mas_5_min = as.integer(time_spent > 5))

n <- nrow(obs)
set.seed(2026)
indices_train <- sample(seq_len(n), size = round(0.8 * n))
train <- obs[indices_train, ]
test  <- obs[-indices_train, ]

# 'predict()' falla si una categoria aparece solo en 'test'
stopifnot(
  all(test$device_type %in% unique(train$device_type)),
  all(test$os_type %in% unique(train$os_type))
)
cat(sprintf("train = %s, test = %s\n",
            format(nrow(train), big.mark = ","),
            format(nrow(test), big.mark = ",")))

media_train <- mean(train$Revenue)

# -----------------------------------------------------------------------------
# 2. Validacion cruzada dentro de 'train'
# -----------------------------------------------------------------------------

# 5 pliegues, fijos para todos los modelos, de modo que las diferencias entre
# modelos se calculan pliegue a pliegue (pareadas) y su ruido es menor
set.seed(2026)
pliegues <- caret::createFolds(train$Revenue, k = 5)

# RMSE de cada pliegue para una formula: ajusta con los otros 4 y predice el
# pliegue retenido. Devuelve un vector de 5 RMSE
cv_rmse <- function(formula) {
  map_dbl(pliegues, function(idx) {
    ajuste <- lm(formula, data = train[-idx, ])
    rmse(train$Revenue[idx], predict(ajuste, newdata = train[idx, ]))
  })
}

# media y error estandar de un vector por pliegue (o de una diferencia pareada)
resumir_cv <- function(x) c(media = mean(x), ee = sd(x) / sqrt(length(x)))

# -----------------------------------------------------------------------------
# 3. Escalera de modelos: de la media al modelo completo (H5)
# -----------------------------------------------------------------------------

# un termino por escalon, en el orden de la descriptiva: de lo mas fuerte a lo
# mas especifico (el cruce lleva tambien el efecto principal del indicador); 'sign_up' va al final para medir cuanto agrega a lo demas
escalones <- tribble(
  ~termino,                    ~variable,
  NA,                          "Ninguna (media del entrenamiento)",
  "mas_5_min",                 "Más de 5 minutos en el sitio",
  "past_sessions",             "Sesiones anteriores",
  "device_type",               "Dispositivo",
  "os_type",                   "Sistema operativo",
  "is_returning_user",         "Usuario recurrente",
  "mas_5_min:past_sessions",   "Más de 5 minutos × sesiones anteriores",
  "sign_up",                   "Registro"
)

formula_hasta <- function(k) {
  terminos <- na.omit(escalones$termino[seq_len(k)])
  reformulate(if (length(terminos) == 0) "1" else terminos, response = "Revenue")
}

rmse_pliegues <- map(seq_len(nrow(escalones)), ~ cv_rmse(formula_hasta(.x)))

escalera <- map_dfr(seq_along(rmse_pliegues), function(k) {
  actual <- resumir_cv(rmse_pliegues[[k]])
  # caida frente al escalon anterior, pareada por pliegue (positiva = baja el RMSE)
  dif <- if (k == 1) c(media = NA_real_, ee = NA_real_)
           else resumir_cv(rmse_pliegues[[k - 1]] - rmse_pliegues[[k]])
  tibble(
    paso = k - 1,
    variable_agregada = escalones$variable[k],
    rmse_cv = actual[["media"]],
    ee_rmse_cv = actual[["ee"]],
    caida = dif[["media"]],
    ee_caida = dif[["ee"]]
  )
}) |>
  mutate(
    caida_pct = 100 * caida / lag(rmse_cv),
    mejora_ingenuo_pct = 100 * (1 - rmse_cv / rmse_cv[1])
  )

print(escalera, n = Inf)

# -----------------------------------------------------------------------------
# 4. Aporte de cada variable sin depender del orden de la escalera
# -----------------------------------------------------------------------------

# el aporte de una variable en la escalera depende de en que orden entra; por
# eso se calcula tambien (a) la variable sola frente a la media y (b) el modelo
# completo sin ella. Una "variable" agrupa todos sus terminos: quitar el tiempo
# quita el indicador de 5 minutos y su interaccion con las sesiones
terminos_completo <- na.omit(escalones$termino)
grupos <- tribble(
  ~variable,             ~sola,                         ~quita,
  "Más de 5 minutos",    "mas_5_min",                   c("mas_5_min", "mas_5_min:past_sessions"),
  "Sesiones anteriores", "past_sessions",               c("past_sessions", "mas_5_min:past_sessions"),
  "Usuario recurrente",  "is_returning_user",           "is_returning_user",
  "Dispositivo",         "device_type",                 "device_type",
  "Sistema operativo",   "os_type",                     "os_type",
  "Registro",            "sign_up",                     "sign_up"
)

rmse_completo <- rmse_pliegues[[nrow(escalones)]]
rmse_media    <- rmse_pliegues[[1]]

importancia <- pmap_dfr(grupos, function(variable, sola, quita) {
  sola_cv <- cv_rmse(reformulate(sola, response = "Revenue"))
  sin_cv  <- cv_rmse(reformulate(setdiff(terminos_completo, quita), response = "Revenue"))
  mejora  <- resumir_cv(rmse_media - sola_cv)
  perdida <- resumir_cv(sin_cv - rmse_completo)
  tibble(
    variable = variable,
    mejora_sola = mejora[["media"]],
    ee_mejora_sola = mejora[["ee"]],
    aumento_sin = perdida[["media"]],
    ee_aumento_sin = perdida[["ee"]]
  )
})

# fila del cruce (mas de 5 minutos x sesiones anteriores). No puede entrar "sola"
# sin sus dos variables, asi que su aporte se mide (a) frente al modelo que ya
# tiene las dos variables sin cruce y (b) quitandolo del modelo completo, dejando
# las dos variables. Es lo que el cruce agrega a lo que las dos explican por
# separado
sin_cruce_cv <- cv_rmse(reformulate(
  setdiff(terminos_completo, "mas_5_min:past_sessions"), response = "Revenue"
))
dos_variables_cv <- cv_rmse(reformulate(c("mas_5_min", "past_sessions"), response = "Revenue"))
con_dos_y_cruce_cv <- cv_rmse(reformulate(
  c("mas_5_min", "past_sessions", "mas_5_min:past_sessions"), response = "Revenue"
))
mejora_cruce  <- resumir_cv(dos_variables_cv - con_dos_y_cruce_cv)
perdida_cruce <- resumir_cv(sin_cruce_cv - rmse_completo)

importancia <- importancia |>
  add_row(
    variable = "Cruce: más de 5 minutos × sesiones anteriores",
    mejora_sola = mejora_cruce[["media"]],
    ee_mejora_sola = mejora_cruce[["ee"]],
    aumento_sin = perdida_cruce[["media"]],
    ee_aumento_sin = perdida_cruce[["ee"]],
    .after = 2
  )

print(importancia)

# -----------------------------------------------------------------------------
# 4b. Por que el tiempo entra solo como indicador de 5 minutos
# -----------------------------------------------------------------------------

# el resto del modelo completo se deja igual y solo cambia como entra el tiempo:
# solo el indicador, solo el tiempo lineal, ambos, o el indicador con una
# pendiente a cada lado del corte. Si el RMSE no cambia, el tiempo continuo no
# agrega nada una vez que esta el indicador
train <- train |>
  mutate(t_bajo = pmin(time_spent, 5), t_alto = pmax(time_spent - 5, 0))
resto <- setdiff(terminos_completo, c("mas_5_min", "time_spent"))

forma_tiempo <- tribble(
  ~especificacion,                                  ~terminos,
  "Solo el indicador de más de 5 minutos",          "mas_5_min",
  "Solo el tiempo en minutos (lineal)",             "time_spent",
  "Indicador y tiempo en minutos",                  c("mas_5_min", "time_spent"),
  "Indicador y una pendiente a cada lado del corte", c("mas_5_min", "t_bajo", "t_alto")
)
robustez_tiempo <- pmap_dfr(forma_tiempo, function(especificacion, terminos) {
  r <- cv_rmse(reformulate(c(terminos, resto), response = "Revenue"))
  tibble(especificacion = especificacion, rmse_cv = mean(r), ee_rmse_cv = sd(r) / sqrt(5))
})
print(robustez_tiempo)

# salto y pendientes por lado (ajustado con todo 'train', solo descriptivo)
ajuste_salto <- lm(Revenue ~ mas_5_min + t_bajo + t_alto, data = train)
print(summary(ajuste_salto)$coefficients)

# -----------------------------------------------------------------------------
# 5. Evaluacion en 'test' (una sola vez)
# -----------------------------------------------------------------------------

# modelos: ingenuo, el lineal del Taller 1 (todo lineal, con sign_up) y el
# modelo completo de la escalera (sin time_spent continuo)
f_taller1 <- Revenue ~ sign_up + time_spent + past_sessions + device_type +
  is_returning_user + os_type
f_completo <- formula_hasta(nrow(escalones))

modelos_prueba <- list(
  "Referencia ingenua (media del entrenamiento)" = Revenue ~ 1,
  "Lineal del Taller 1 (con tiempo lineal)" = f_taller1,
  "Lineal con quiebre, interacción y registro" = f_completo
)

rmse_ingenuo <- rmse(test$Revenue, rep(media_train, nrow(test)))

prueba <- imap_dfr(modelos_prueba, function(formula, nombre) {
  ajuste <- lm(formula, data = train)
  rmse_test <- rmse(test$Revenue, predict(ajuste, newdata = test))
  rmse_val <- mean(cv_rmse(formula))
  tibble(
    modelo = nombre,
    rmse_cv = rmse_val,
    rmse_prueba = rmse_test,
    brecha = rmse_test - rmse_val,
    rmse_media_pct = 100 * rmse_test / media_train,
    mejora_ingenuo_pct = 100 * (1 - rmse_test / rmse_ingenuo),
    # proporcion del error cuadratico del ingenuo que el modelo elimina
    explicado_pct = 100 * (1 - rmse_test^2 / rmse_ingenuo^2)
  )
})

print(prueba)

# verificacion con el Taller 1: RMSE de prueba 2.314 (lineal) y 2.716 (ingenuo)
rmse_t1 <- prueba$rmse_prueba[2]
cat(sprintf(
  "Verificacion Taller 1: lineal %.3f (esperado 2.314), ingenuo %.3f (esperado 2.716)\n",
  rmse_t1, rmse_ingenuo
))
if (abs(rmse_t1 - 2.314) > 0.001 || abs(rmse_ingenuo - 2.716) > 0.001) {
  warning("No se reproduce el RMSE del Taller 1: revisar la particion o la especificacion.")
}

# -----------------------------------------------------------------------------
# 6. Tablas
# -----------------------------------------------------------------------------

tabla_escalera <- escalera |>
  transmute(
    paso, variable_agregada, rmse_cv,
    caida_txt = if_else(is.na(caida), "",
      sprintf("%.*f (%.*f)", decimales$rmse, round(caida, decimales$rmse) + 0, decimales$rmse, ee_caida)),
    caida_pct, mejora_ingenuo_pct
  ) |>
  gt() |>
  cols_label(
    paso = "Paso", variable_agregada = "Variable agregada",
    rmse_cv = "RMSE (dólares)", caida_txt = "Caída (dólares)",
    caida_pct = "Caída (%)", mejora_ingenuo_pct = "Mejora frente a la media (%)"
  ) |>
  fmt_number(rmse_cv, decimals = decimales$rmse) |>
  fmt_number(c(caida_pct, mejora_ingenuo_pct), decimals = decimales$porcentaje) |>
  sub_missing(missing_text = "") |>
  cols_align("center", -variable_agregada) |>
  estilo_tabla(
    titulo = "Cuánto baja el error de predicción al agregar cada variable",
    subtitulo = "Regresión lineal; ingreso en dólares; validación cruzada",
    nota = nota_tabla(
      "observacional", nrow(train), "entrenamiento", enfoque = "predictivo",
      extra = paste(
        "RMSE de validación cruzada de 5 pliegues, en dólares. La caída es la",
        "diferencia con el paso anterior, calculada pliegue a pliegue; entre",
        "paréntesis, su error estándar entre pliegues. Depende del orden de los",
        "pasos."
      )
    )
  )

guardar_tabla("observacional_escalera_rmse", tabla_escalera, escalera, carpeta_salida)

tabla_robustez <- robustez_tiempo |>
  gt() |>
  cols_label(
    especificacion = "Forma del tiempo en el modelo",
    rmse_cv = "RMSE (dólares)", ee_rmse_cv = "Error estándar entre pliegues"
  ) |>
  fmt_number(c(rmse_cv, ee_rmse_cv), decimals = decimales$rmse) |>
  cols_align("center", -especificacion) |>
  estilo_tabla(
    titulo = "El tiempo en minutos no agrega nada una vez incluido el corte de 5 minutos",
    subtitulo = "Regresión lineal; ingreso en dólares; validación cruzada",
    nota = nota_tabla(
      "observacional", nrow(train), "entrenamiento", enfoque = "predictivo",
      extra = paste(
        "Mismo modelo en todas las filas (sesiones anteriores, dispositivo,",
        "sistema operativo, usuario recurrente, cruce con las sesiones y",
        "registro); solo cambia cómo entra el tiempo. RMSE de validación",
        "cruzada de 5 pliegues."
      )
    )
  )

guardar_tabla(
  "observacional_robustez_forma_tiempo", tabla_robustez, robustez_tiempo, carpeta_salida
)

tabla_importancia <- importancia |>
  transmute(
    variable,
    sola_txt = sprintf("%.*f (%.*f)", decimales$rmse, round(mejora_sola, decimales$rmse) + 0,
                       decimales$rmse, ee_mejora_sola),
    sin_txt = sprintf("%.*f (%.*f)", decimales$rmse, round(aumento_sin, decimales$rmse) + 0,
                      decimales$rmse, ee_aumento_sin)
  ) |>
  gt() |>
  cols_label(
    variable = "Variable",
    sola_txt = "Baja del RMSE usándola sola (dólares)",
    sin_txt = "Alza del RMSE al quitarla del modelo completo (dólares)"
  ) |>
  cols_align("center", c(sola_txt, sin_txt)) |>
  estilo_tabla(
    titulo = "Aporte predictivo de cada variable, sin depender del orden",
    subtitulo = "Regresión lineal; ingreso en dólares; validación cruzada",
    nota = nota_tabla(
      "observacional", nrow(train), "entrenamiento", enfoque = "predictivo",
      extra = paste(
        "Cambio del RMSE de validación cruzada (5 pliegues) frente a la media",
        "(columna 2) y frente al modelo completo (columna 3); entre paréntesis,",
        "el error estándar entre pliegues. Quitar el tiempo o las sesiones",
        "anteriores quita también el cruce. Para el cruce, la columna 2 compara",
        "el modelo con las dos variables y el cruce frente al modelo con las dos",
        "variables sin cruce, y la columna 3 es el modelo completo sin el cruce."
      )
    )
  )

guardar_tabla(
  "observacional_importancia_variables", tabla_importancia, importancia, carpeta_salida
)

tabla_prueba <- prueba |>
  gt() |>
  cols_label(
    modelo = "Modelo",
    rmse_cv = "RMSE entrenamiento, validación cruzada (dólares)",
    rmse_prueba = "RMSE prueba (dólares)",
    brecha = "Brecha prueba − validación (dólares)",
    rmse_media_pct = "RMSE como % de la media del ingreso",
    mejora_ingenuo_pct = "Mejora frente a la media (%)",
    explicado_pct = "Error cuadrático eliminado (%)"
  ) |>
  fmt_number(c(rmse_cv, rmse_prueba, brecha), decimals = decimales$rmse) |>
  fmt_number(c(rmse_media_pct, mejora_ingenuo_pct, explicado_pct),
             decimals = decimales$porcentaje) |>
  cols_align("center", -modelo) |>
  estilo_tabla(
    titulo = "Error de predicción fuera de muestra del modelo lineal",
    subtitulo = sprintf(
      "Ingreso en dólares; media del ingreso en entrenamiento: %.2f dólares",
      media_train
    ),
    nota = nota_tabla(
      "observacional", nrow(test), "prueba", enfoque = "predictivo",
      extra = paste0(
        "Modelos ajustados con la muestra de entrenamiento (n = ",
        format(nrow(train), big.mark = ","), ") y evaluados una sola vez en la",
        " muestra de prueba. Partición 80/20 con semilla 2026, como en el",
        " Taller 1."
      )
    )
  )

guardar_tabla("observacional_rmse_prueba_lineal", tabla_prueba, prueba, carpeta_salida)

# -----------------------------------------------------------------------------
# 7. Figura: RMSE de validacion cruzada por escalon
# -----------------------------------------------------------------------------

datos_figura <- escalera |>
  mutate(etiqueta = factor(
    paste0(paso, ". ", variable_agregada),
    levels = rev(paste0(paso, ". ", variable_agregada))
  ))

grafica_escalera <- ggplot(datos_figura, aes(x = rmse_cv, y = etiqueta)) +
  geom_vline(xintercept = escalera$rmse_cv[1], linetype = "dotted",
             color = gris_nota) +
  geom_point(color = paleta_categorica[1], size = 3) +
  labs(
    title = "Error de predicción al agregar cada variable",
    subtitle = subtitulo_observacional_predictivo,
    x = "RMSE de validación cruzada (dólares)", y = NULL,
    caption = paste(
      sprintf(
        "Nota: n = %s usuarios de entrenamiento; validación cruzada de 5 pliegues.",
        format(nrow(train), big.mark = ",")
      ),
      "El error estándar entre pliegues (menos de 0.01 dólares) no se distingue en la escala.\nLa línea punteada marca el RMSE de la media.",
      "Cada paso agrega una variable a las anteriores.",
      sep = "\n"
    )
  ) +
  tema_presentacion +
  theme(plot.title.position = "plot", plot.caption.position = "plot")

guardar_figura(
  "observacional_escalera_rmse.png", grafica_escalera, carpeta_salida
)

# -----------------------------------------------------------------------------
# 8. Figura: el orden de entrada del tiempo (corte de 5 minutos y tiempo lineal)
# -----------------------------------------------------------------------------

# modelos solo con terminos de tiempo, para ver el efecto sin otras variables:
# si se agrega primero el corte de 5 minutos, el tiempo en minutos ya no baja el
# RMSE; si se agrega primero el tiempo, el corte todavia baja el RMSE. En ambos
# ordenes se llega al mismo modelo (indicador + tiempo)
formula_tiempo <- function(terminos) {
  reformulate(if (length(terminos) == 0) "1" else terminos, response = "Revenue")
}
rmse_tiempo <- list(
  media        = cv_rmse(formula_tiempo(character(0))),
  indicador    = cv_rmse(formula_tiempo("mas_5_min")),
  tiempo       = cv_rmse(formula_tiempo("time_spent")),
  ambos        = cv_rmse(formula_tiempo(c("mas_5_min", "time_spent")))
)

orden_tiempo <- tribble(
  ~orden,                                          ~paso, ~etiqueta,                      ~modelo,
  "Primero el corte de 5 minutos, luego el tiempo", 0,    "Media",                        "media",
  "Primero el corte de 5 minutos, luego el tiempo", 1,    "+ Más de 5 minutos",           "indicador",
  "Primero el corte de 5 minutos, luego el tiempo", 2,    "+ Tiempo en minutos",          "ambos",
  "Primero el tiempo, luego el corte de 5 minutos", 0,    "Media",                        "media",
  "Primero el tiempo, luego el corte de 5 minutos", 1,    "+ Tiempo en minutos",          "tiempo",
  "Primero el tiempo, luego el corte de 5 minutos", 2,    "+ Más de 5 minutos",           "ambos"
) |>
  mutate(
    rmse_cv = map_dbl(modelo, ~ mean(rmse_tiempo[[.x]])),
    orden = factor(orden, levels = unique(orden))
  )

# caida del ultimo paso de cada orden, pareada por pliegue (dolares)
caida_corte_luego_tiempo <- resumir_cv(rmse_tiempo$indicador - rmse_tiempo$ambos)
caida_tiempo_luego_corte <- resumir_cv(rmse_tiempo$tiempo - rmse_tiempo$ambos)
cat(sprintf(
  "Ultimo paso: tiempo despues del corte baja %.4f (ee %.4f); corte despues del tiempo baja %.4f (ee %.4f)\n",
  caida_corte_luego_tiempo[["media"]], caida_corte_luego_tiempo[["ee"]],
  caida_tiempo_luego_corte[["media"]], caida_tiempo_luego_corte[["ee"]]
))

grafica_orden <- ggplot(orden_tiempo, aes(x = paso, y = rmse_cv)) +
  geom_line(color = paleta_categorica[1], linewidth = 0.8) +
  geom_point(color = paleta_categorica[1], size = 3) +
  geom_text(aes(label = sprintf("%.3f", rmse_cv)), hjust = 0, nudge_x = 0.06,
            nudge_y = 0.025, color = gris_texto, size = 3.6) +
  facet_wrap(~ orden) +
  scale_x_continuous(
    breaks = 0:2, labels = NULL, expand = expansion(add = 0.45)
  ) +
  geom_text(aes(y = min(rmse_cv) - 0.09, label = etiqueta),
            color = gris_secundario, size = 3.4, lineheight = 0.9) +
  scale_y_continuous(expand = expansion(mult = c(0.02, 0.1))) +
  labs(
    title = "El tiempo en minutos no baja el error una vez incluido el corte de 5 minutos",
    subtitle = subtitulo_observacional_predictivo,
    x = NULL, y = "RMSE de validación cruzada (dólares)",
    caption = paste(
      sprintf(
        "Nota: n = %s usuarios de entrenamiento; validación cruzada de 5 pliegues.",
        format(nrow(train), big.mark = ",")
      ),
      sprintf(
        paste(
          "Último paso, caída pareada del RMSE (error estándar entre pliegues):",
          "tiempo tras el corte, %.3f (%.3f); corte tras el tiempo, %.3f (%.3f) dólares."
        ),
        caida_corte_luego_tiempo[["media"]], caida_corte_luego_tiempo[["ee"]],
        caida_tiempo_luego_corte[["media"]], caida_tiempo_luego_corte[["ee"]]
      ),
      "Modelos solo con términos de tiempo; ambos órdenes terminan en el mismo modelo.",
      sep = "\n"
    )
  ) +
  tema_presentacion + tema_paneles

guardar_figura(
  "observacional_orden_tiempo_corte.png", grafica_orden, carpeta_salida
)

cat("\nListo. Tablas y figuras en 03_Resultados/{Tablas,Figuras}/04_prediccion_lineal_observacional/.\n")
cat("Recordatorio: aporte predictivo en datos historicos, no efecto causal.\n")
