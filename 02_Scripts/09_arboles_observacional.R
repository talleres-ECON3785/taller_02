# =============================================================================
# Arbol de regresion (CART) para predecir el ingreso, en dolares y en logaritmo
# Taller 2 - ECON-3785 (Parte A)
#
# Estimando: ninguno causal; el objetivo es predecir el ingreso de un usuario
# nuevo con la base historica. Estimador: arbol de regresion (rpart, perdida
# cuadratica) podado por costo-complejidad. Medida: RMSE fuera de muestra
# (validacion cruzada dentro de 'train'). Los cortes del arbol describen como
# predice el modelo, no efectos de las variables.
#
# Disenio:
#   - Misma particion 80/20 (set.seed(2026)) y mismos 5 pliegues que 04 y 05.
#   - Las 6 variables crudas del Taller 1, con el tiempo continuo y sin el
#     indicador de mas de 5 minutos ni el cruce con las sesiones: se quiere ver
#     si el arbol encuentra solo el corte y la interaccion de la descriptiva.
#   - Las dos escalas: Revenue (dolares) y ln(Revenue). Asi la celda
#     "arboles x dolares" aisla el efecto del metodo y "arboles x log" es el
#     analisis principal.
#   - Se deja crecer un arbol grande (cp = 0) y se poda con la validacion
#     cruzada interna de rpart (10 pliegues). El arbol titular (declarado antes
#     de ver los resultados) es el de la regla 1-SE, por ser el mas simple a
#     menos de un error estandar del minimo; el de la regla del minimo se
#     reporta al lado.
#   - 'test' no se usa en este script: la evaluacion en prueba es del 11.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema y funciones de guardado de las figuras; estilo de las tablas
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "09_arboles_observacional"

rmse <- function(y, prediccion) sqrt(mean((y - prediccion)^2))

# media y error estandar de un vector por pliegue (o de una diferencia pareada)
resumir_cv <- function(x) c(media = mean(x), ee = sd(x) / sqrt(length(x)))

# -----------------------------------------------------------------------------
# 1. Datos y particion train/test (la del Taller 1 y la de 04 y 05)
# -----------------------------------------------------------------------------

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds") |>
  # solo para el lineal final con el que se compara el arbol (el arbol no lo usa)
  mutate(mas_5_min = as.integer(time_spent > 5))

n <- nrow(obs)
set.seed(2026)
indices_train <- sample(seq_len(n), size = round(0.8 * n))
train <- obs[indices_train, ]
# 'test' no se define aqui: este script solo usa 'train'

cat(sprintf("train = %s\n", format(nrow(train), big.mark = ",")))

# 5 pliegues fijos, los mismos de 04 y 05 (misma semilla, mismos datos)
set.seed(2026)
pliegues <- caret::createFolds(train$Revenue, k = 5)

# -----------------------------------------------------------------------------
# 2. Especificacion
# -----------------------------------------------------------------------------

predictores <- c("sign_up", "time_spent", "past_sessions", "device_type",
                 "is_returning_user", "os_type")

# lineal final de 04 (indicador de 5 minutos, sesiones y su cruce, dispositivo,
# sistema operativo, recurrente y registro): la referencia del arbol en 'train'
terminos_lineal <- c("mas_5_min", "past_sessions", "mas_5_min:past_sessions",
                     "device_type", "os_type", "is_returning_user", "sign_up")

escalas <- tribble(
  ~escala,       ~respuesta,     ~unidad,
  "Dólares",     "Revenue",      "dólares",
  "Logaritmo",   "log_revenue",  "log"
)

# arbol grande: cp = 0 deja crecer el arbol hasta que las hojas tengan 7 obs.
# (minbucket por defecto); xval = 10 es la validacion cruzada interna con la
# que se poda. La CV interna es aleatoria: set.seed(2026) justo antes
ajustar_arbol_grande <- function(respuesta, datos, xval = 10) {
  set.seed(2026)
  rpart(
    reformulate(predictores, response = respuesta),
    data    = datos,
    method  = "anova",
    control = rpart.control(cp = 0, minbucket = 7, xval = xval)
  )
}

# -----------------------------------------------------------------------------
# 3. Arbol grande y poda (regla del minimo y regla 1-SE)
# -----------------------------------------------------------------------------

arboles <- pmap(escalas, function(escala, respuesta, unidad) {
  grande <- ajustar_arbol_grande(respuesta, train)
  secuencia <- as_tibble(grande$cptable)

  cp_min <- secuencia |> slice_min(xerror, n = 1, with_ties = FALSE)
  cp_1se <- secuencia |>
    filter(xerror <= cp_min$xerror + cp_min$xstd) |>
    slice_min(nsplit, n = 1, with_ties = FALSE)

  list(
    escala = escala, respuesta = respuesta, unidad = unidad,
    grande = grande, secuencia = secuencia,
    cp = c("Mínimo" = cp_min$CP, "1-SE" = cp_1se$CP),
    podado = list(
      "Mínimo" = prune(grande, cp = cp_min$CP),
      "1-SE"   = prune(grande, cp = cp_1se$CP)
    )
  )
})
names(arboles) <- escalas$escala

iwalk(arboles, function(a, escala) {
  cat(sprintf(
    "%s: arbol grande con %d cortes; minimo %d cortes, 1-SE %d cortes\n",
    escala, max(a$secuencia$nsplit),
    a$secuencia$nsplit[a$secuencia$CP == a$cp[["Mínimo"]]],
    a$secuencia$nsplit[a$secuencia$CP == a$cp[["1-SE"]]]
  ))
  print(a$podado[["1-SE"]])
})

# -----------------------------------------------------------------------------
# 4. RMSE de validacion cruzada en los pliegues de 04 y 05
# -----------------------------------------------------------------------------

# el arbol se reajusta sin el pliegue y se poda con el cp elegido en todo
# 'train' (xval = 0: dentro del pliegue no hace falta otra CV). El cp se eligio
# con todo 'train', asi que esta CV es levemente optimista para el arbol; la
# evaluacion sin ese sesgo es la de 'test' (script 11)
rmse_arbol_cv <- function(a, regla) {
  map_dbl(pliegues, function(idx) {
    ajuste <- prune(ajustar_arbol_grande(a$respuesta, train[-idx, ], xval = 0),
                    cp = a$cp[[regla]])
    rmse(train[[a$respuesta]][idx], predict(ajuste, newdata = train[idx, ]))
  })
}

rmse_lineal_cv <- function(respuesta) {
  formula <- reformulate(terminos_lineal, response = respuesta)
  map_dbl(pliegues, function(idx) {
    ajuste <- lm(formula, data = train[-idx, ])
    rmse(train[[respuesta]][idx], predict(ajuste, newdata = train[idx, ]))
  })
}

poda <- map_dfr(arboles, function(a) {
  lineal <- rmse_lineal_cv(a$respuesta)
  # desviacion de la media en 'train': convierte el error relativo de rpart a RMSE
  ecm_raiz <- mean((train[[a$respuesta]] - mean(train[[a$respuesta]]))^2)
  map_dfr(c("Mínimo", "1-SE"), function(regla) {
    fila <- a$secuencia |> filter(CP == a$cp[[regla]])
    arbol <- rmse_arbol_cv(a, regla)
    dif <- resumir_cv(arbol - lineal)
    tibble(
      escala = a$escala,
      regla = regla,
      cp = a$cp[[regla]],
      cortes = fila$nsplit,
      hojas = fila$nsplit + 1,
      rmse_xval = sqrt(fila$xerror * ecm_raiz),
      rmse_cv = mean(arbol),
      ee_rmse_cv = sd(arbol) / sqrt(length(arbol)),
      rmse_lineal_cv = mean(lineal),
      dif_lineal = dif[["media"]],
      ee_dif_lineal = dif[["ee"]],
      titular = regla == "1-SE"
    )
  })
})

print(poda)

# -----------------------------------------------------------------------------
# 5. Cortes del arbol titular (1-SE)
# -----------------------------------------------------------------------------

# nombres legibles de las variables y de las categorias, para las tablas y la
# figura del arbol (sin nombres del codigo)
etiquetas_variables <- c(
  "time_spent" = "Tiempo en el sitio (min)",
  "past_sessions" = "Sesiones anteriores",
  "device_type" = "Dispositivo",
  "os_type" = "Sistema operativo",
  "is_returning_user" = "Usuario recurrente",
  "sign_up" = "Registro"
)
etiquetas_categorias <- c(
  "desktop" = "escritorio", "mobile" = "móvil", "tablet" = "tableta",
  "osx" = "macOS", "windows" = "Windows", "other" = "otro"
)

traducir <- function(texto) {
  for (v in names(etiquetas_variables)) {
    texto <- gsub(v, etiquetas_variables[[v]], texto, fixed = TRUE)
  }
  for (k in names(etiquetas_categorias)) {
    texto <- gsub(paste0("\\b", k, "\\b"), etiquetas_categorias[[k]], texto)
  }
  # espacios alrededor de "=" y despues de las comas entre categorias
  texto <- gsub("\\s*=\\s*", " = ", texto)
  gsub(",(?=\\S)", ", ", texto, perl = TRUE)
}

# un renglon por corte: nodo, profundidad, observaciones y la condicion de la
# rama izquierda (la derecha es su complemento). labels() de rpart da la
# condicion de cada nodo hijo
cortes_arbol <- function(arbol) {
  marco <- arbol$frame
  nodos <- as.integer(rownames(marco))
  # pretty = 0: nombres completos de las categorias (no letras)
  condiciones <- labels(arbol, digits = 4, pretty = 0)
  internos <- which(marco$var != "<leaf>")
  tibble(
    nodo = nodos[internos],
    profundidad = floor(log2(nodos[internos])),
    variable = unname(etiquetas_variables[as.character(marco$var[internos])]),
    # solo la condicion (la variable ya esta en su columna)
    condicion_izquierda = sub(
      "^.*?(<|>=|=)", "\\1",
      traducir(condiciones[match(2 * nodos[internos], nodos)])
    ) |> str_trim(),
    observaciones = marco$n[internos]
  ) |>
    arrange(profundidad, nodo)
}

cortes <- map_dfr(arboles, ~ cortes_arbol(.x$podado[["1-SE"]]) |>
                    mutate(escala = .x$escala, .before = 1))
print(cortes, n = Inf)

# donde corta el tiempo en el titular de cada escala
print(cortes |> filter(variable == etiquetas_variables[["time_spent"]]))

# -----------------------------------------------------------------------------
# 6. Importancia de variables de rpart (arbol titular)
# -----------------------------------------------------------------------------

# reduccion de la suma de cuadrados atribuida a cada variable, incluidos los
# cortes sustitutos; se reporta como % del total de cada arbol. Es uso del
# modelo para predecir, no efecto
importancia <- map_dfr(arboles, function(a) {
  imp <- a$podado[["1-SE"]]$variable.importance
  tibble(
    escala = a$escala,
    variable = unname(etiquetas_variables[names(imp)]),
    importancia = unname(imp),
    importancia_pct = 100 * unname(imp) / sum(imp)
  )
}) |>
  # una variable que el arbol nunca usa ni como sustituto queda en 0
  complete(escala, variable = unname(etiquetas_variables),
           fill = list(importancia = 0, importancia_pct = 0))
print(importancia)

# -----------------------------------------------------------------------------
# 7. Tablas
# -----------------------------------------------------------------------------

fmt_ee <- function(x, ee, dec = decimales$rmse) {
  sprintf("%.*f (%.*f)", dec, round(x, dec) + 0, dec, ee)
}

tabla_poda <- poda |>
  transmute(
    escala,
    regla = if_else(titular, paste(regla, "(titular)"), regla),
    hojas,
    rmse_cv_txt = fmt_ee(rmse_cv, ee_rmse_cv),
    rmse_lineal_cv,
    dif_txt = fmt_ee(dif_lineal, ee_dif_lineal)
  ) |>
  gt(groupname_col = "escala") |>
  cols_label(
    regla = "Regla de poda", hojas = "Hojas",
    rmse_cv_txt = "RMSE del árbol",
    rmse_lineal_cv = "RMSE del lineal final",
    dif_txt = "Árbol − lineal"
  ) |>
  fmt_number(rmse_lineal_cv, decimals = decimales$rmse) |>
  cols_align("center", -regla) |>
  estilo_tabla(
    titulo = "Error de validación cruzada del árbol de regresión podado",
    subtitulo = "Ingreso en dólares y en logaritmo; cada RMSE en la escala de su modelo",
    nota = nota_tabla(
      "observacional", nrow(train), "entrenamiento", enfoque = "predictivo",
      extra = c(
        paste(
          "RMSE de validación cruzada de 5 pliegues (los mismos de los modelos",
          "lineales y de LASSO), en dólares o en unidades de logaritmo según la",
          "escala. Error estándar entre paréntesis, calculado entre los pliegues."
        ),
        paste(
          "Árbol con las 6 variables del Taller 1 (tiempo continuo, sin el corte",
          "de 5 minutos). Poda elegida con la validación cruzada interna de 10",
          "pliegues de rpart; regla 1-SE: el árbol más pequeño a menos de un error",
          "estándar del mínimo."
        ),
        paste(
          "Lineal final: corte de 5 minutos, sesiones anteriores y su cruce,",
          "dispositivo, sistema operativo, usuario recurrente y registro.",
          "Árbol − lineal negativo: el árbol tiene menos error."
        ),
        "Los RMSE en dólares y en logaritmo no son comparables entre sí."
      )
    )
  )

guardar_tabla("observacional_cart_poda", tabla_poda, poda, carpeta_salida)

tabla_cortes <- cortes |>
  select(escala, profundidad, variable, condicion_izquierda, observaciones) |>
  gt(groupname_col = "escala") |>
  cols_label(
    profundidad = "Nivel", variable = "Variable",
    condicion_izquierda = "Condición de la rama izquierda",
    observaciones = "Usuarios en el nodo"
  ) |>
  fmt_number(observaciones, decimals = decimales$conteo) |>
  cols_align("center", c(profundidad, observaciones)) |>
  estilo_tabla(
    titulo = "Cortes del árbol de regresión podado (regla 1-SE)",
    subtitulo = "Ingreso en dólares y en logaritmo",
    nota = nota_tabla(
      "observacional", nrow(train), "entrenamiento", enfoque = "predictivo",
      extra = c(
        "Nivel 0 es el primer corte (todos los usuarios); cada nivel parte los nodos del anterior.",
        "La rama derecha de cada corte es el complemento de la condición mostrada.",
        "Los cortes describen cómo predice el árbol, no efectos de las variables."
      )
    )
  )

guardar_tabla("observacional_cart_cortes", tabla_cortes, cortes, carpeta_salida)

# -----------------------------------------------------------------------------
# 8. Figuras: arbol titular de cada escala
# -----------------------------------------------------------------------------

# rampa de la paleta del proyecto: hojas con prediccion baja en tono claro y
# alta en azul
rampa_azul <- colorRampPalette(c("#EEF2F8", paleta_categorica[1]))(9)

# reemplaza los nombres del codigo en las etiquetas de los cortes
etiquetar_cortes <- function(x, labs, digits, varlen, faclen) traducir(labs)

# etiqueta de cada nodo: prediccion con los decimales de su escala, n con
# separador de miles y porcentaje de los usuarios de entrenamiento
etiquetar_nodos <- function(dec) {
  function(x, labs, digits, varlen) {
    sprintf("%.*f\nn = %s (%.1f%%)", dec, x$frame$yval,
            format(x$frame$n, big.mark = ",", trim = TRUE),
            100 * x$frame$n / x$frame$n[1])
  }
}

dibujar_arbol <- function(a, titulo, unidad_hojas, dec) {
  function() {
    # margenes externos para titulo, subtitulo y nota: el arbol no se monta sobre ellos
    par(family = "sans", oma = c(3.5, 1, 4.5, 1))
    rpart.plot(
      a$podado[["1-SE"]],
      type = 2, roundint = FALSE,
      box.palette = rampa_azul, split.fun = etiquetar_cortes,
      node.fun = etiquetar_nodos(dec), yes.text = "sí", no.text = "no",
      shadow.col = 0, branch.col = gris_secundario, split.col = gris_texto,
      tweak = 1
    )
    title(main = titulo, adj = 0, line = 2.4, cex.main = 1.3, col.main = gris_texto,
          outer = TRUE)
    mtext(subtitulo_observacional_predictivo, side = 3, adj = 0, line = 1, outer = TRUE,
          cex = 0.85, col = gris_secundario)
    mtext(
      paste0(
        "Nota: n = ", format(nrow(train), big.mark = ","),
        " usuarios de entrenamiento. Cada hoja muestra la predicción (", unidad_hojas,
        "), el número de usuarios y su porcentaje.\n",
        "Árbol podado con la regla 1-SE (validación cruzada de 10 pliegues). ",
        "Los cortes describen cómo predice el modelo, no efectos."
      ),
      side = 1, adj = 0, line = 2.2, cex = 0.7, col = gris_nota, outer = TRUE
    )
  }
}

guardar_figura_base(
  "observacional_cart_arbol_dolares.png",
  dibujar_arbol(arboles[["Dólares"]],
                "Árbol de regresión podado para el ingreso en dólares",
                "ingreso promedio en dólares", decimales$dolares),
  carpeta_salida
)
guardar_figura_base(
  "observacional_cart_arbol_log.png",
  dibujar_arbol(arboles[["Logaritmo"]],
                "Árbol de regresión podado para el logaritmo del ingreso",
                "promedio del logaritmo del ingreso", decimales$log),
  carpeta_salida
)

# -----------------------------------------------------------------------------
# 9. Figura: importancia de variables del arbol titular
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
    title = "Qué variables usa el árbol de regresión para predecir el ingreso",
    subtitle = subtitulo_observacional_predictivo,
    x = "Importancia en el árbol (% de la reducción total del error cuadrático)",
    y = NULL,
    caption = paste(
      sprintf("Nota: n = %s usuarios de entrenamiento; árbol podado con la regla 1-SE.",
              format(nrow(train), big.mark = ",")),
      "La importancia incluye los cortes sustitutos de rpart. Indica cuánto usa el árbol cada variable, no su efecto.",
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

guardar_figura("observacional_cart_importancia.png", grafica_importancia, carpeta_salida)
