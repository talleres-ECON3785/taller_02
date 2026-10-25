# =============================================================================
# Heterogeneidad del efecto del registro facilitado: bosque causal
# Taller 2 - ECON-3785 (Parte B)
#
# Estimandos: el ATE y los CATE(x) de easier_signup sobre ln(Revenue) (cambio
# proporcional aproximado del ingreso del usuario con caracteristicas x) y,
# para la comparacion con el Taller 1, sobre Revenue en dolares. Solo el
# experimento (asignacion aleatoria) sostiene esta lectura causal.
# Estimador: bosque causal de grf (arboles honestos, 2,000 arboles), con las 5
# covariables pre-tratamiento crudas (tiempo continuo, como los arboles de la
# Parte A). W.hat lo estima grf (decision del 2026-10-25).
#
# Que un bosque produzca CATE distintos entre usuarios no prueba que haya
# heterogeneidad: la evidencia formal es la prueba de calibracion y la curva
# TOC con muestra dividida (un bosque elige a quien priorizar y otro, estimado
# con usuarios distintos, mide si esos usuarios tienen un efecto mayor).
#
# Especificaciones:
#   - principal: ln(Revenue) con las 5 covariables
#   - nivel: Revenue en dolares con las 5 covariables (hipotesis de la cola)
#   - robustez: ln(Revenue) sin time_spent (se mide en la misma sesion)
# Los grupos de usuarios se fijaron en PLAN.md (P4.3) antes de ver los CATE.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema y funcion de guardado de las figuras; estilo de las tablas
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

set.seed(2026)

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "12_heterogeneidad_experimento"

# numero de arboles (el catalogo pide 2,000 o mas) y de hilos: grf solo
# reproduce las mismas cifras con la misma semilla si el numero de hilos es el
# mismo, asi que se fija para que coincidan en todas las maquinas
n_arboles <- 2000
n_hilos <- 4

experimento <- readRDS("01_Datos/03_Listos/experimento_listos.RDS") |>
  # mismo indicador del quiebre que en 04, 06 y 08 (solo para definir grupos)
  mutate(mas_5_min = as.integer(time_spent > 5))
historica <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds") |>
  mutate(mas_5_min = as.integer(time_spent > 5))

n_exp <- nrow(experimento)
stopifnot(all(experimento$Revenue > 0))

# grf exige una matriz numerica: las categoricas entran como indicadores
# (categoria de referencia: computador y osx)
matriz_x <- function(datos, con_tiempo = TRUE) {
  formula_x <- if (con_tiempo) {
    ~ time_spent + past_sessions + device_type + is_returning_user + os_type
  } else {
    ~ past_sessions + device_type + is_returning_user + os_type
  }
  model.matrix(formula_x, datos)[, -1]
}

X <- matriz_x(experimento)
X_sin_tiempo <- matriz_x(experimento, con_tiempo = FALSE)
W <- experimento$easier_signup

# nombres en espanol de las columnas de la matriz, para las tablas
etiquetas_x <- c(
  time_spent        = "Tiempo en el sitio (minutos)",
  past_sessions     = "Sesiones anteriores",
  device_typemobile = "Celular (frente a computador)",
  device_typetablet = "Tableta (frente a computador)",
  is_returning_user = "Usuario recurrente",
  os_typeother      = "Otro sistema operativo (frente a osx)",
  os_typewindows    = "Windows (frente a osx)"
)

# mismo bosque para todas las especificaciones: sin W.hat (lo estima grf con
# un bosque de regresion de W sobre X) y sin clusters (asignacion individual)
estimar_bosque <- function(X, Y, W) {
  causal_forest(
    X, Y, W,
    num.trees = n_arboles, seed = 2026, num.threads = n_hilos
  )
}

cf_log <- estimar_bosque(X, experimento$log_revenue, W)
cf_niv <- estimar_bosque(X, experimento$Revenue, W)
cf_sin_tiempo <- estimar_bosque(X_sin_tiempo, experimento$log_revenue, W)

# W.hat estimado: si la asignacion es aleatoria con probabilidad comun, debe
# quedar cerca de la proporcion tratada (4,957 / 10,000) para todos
rango_w_hat <- range(cf_log$W.hat)
cat(sprintf(
  "W.hat estimado: minimo %.3f, media %.3f, maximo %.3f (proporcion tratada %.3f)\n",
  rango_w_hat[1], mean(cf_log$W.hat), rango_w_hat[2], mean(W)
))

# ATE (o ATE de un subgrupo) con su intervalo del 95%
ate_bosque <- function(cf, subset = NULL) {
  ate <- average_treatment_effect(cf, subset = subset)
  tibble(
    estimacion = unname(ate["estimate"]),
    error_estandar = unname(ate["std.err"]),
    ic_inf = estimacion - qnorm(0.975) * error_estandar,
    ic_sup = estimacion + qnorm(0.975) * error_estandar
  )
}

# intervalo como texto para las tablas, con los decimales de cada escala
texto_ic <- function(inf, sup, dec) {
  sprintf(paste0("[%.", dec, "f; %.", dec, "f]"), inf, sup)
}

# -----------------------------------------------------------------------------
# 1. CATE fuera de bolsa con su intervalo (P4.1)
# -----------------------------------------------------------------------------

# predicciones fuera de bolsa: el CATE de cada usuario lo estiman arboles que
# no lo usaron; la varianza da un intervalo por usuario
cate_usuario <- function(cf, escala) {
  pred <- predict(cf, estimate.variance = TRUE)
  tibble(
    escala = escala,
    cate = pred$predictions,
    ic_inf = cate - qnorm(0.975) * sqrt(pred$variance.estimates),
    ic_sup = cate + qnorm(0.975) * sqrt(pred$variance.estimates)
  )
}

cates <- bind_rows(
  cate_usuario(cf_log, "Logaritmo del ingreso"),
  cate_usuario(cf_niv, "Ingreso en dólares")
)

# cuantos CATE individuales tienen un intervalo que excluye el cero (sin
# corregir por comparaciones multiples: es una descripcion, no una prueba)
resumen_cates <- cates |>
  group_by(escala) |>
  summarise(
    p10 = quantile(cate, 0.10), mediana = median(cate),
    p90 = quantile(cate, 0.90),
    pct_ic_positivo = 100 * mean(ic_inf > 0),
    pct_ic_negativo = 100 * mean(ic_sup < 0),
    .groups = "drop"
  )
print(resumen_cates)

# -----------------------------------------------------------------------------
# 2. ATE: MCO frente a bosque causal (P3.2)
# -----------------------------------------------------------------------------

# las cifras de MCO las generan 06 (dolares) y 08 (logaritmo); aqui se leen
# para no estimarlas dos veces
leer_mco <- function(ruta, escala) {
  read_csv(ruta, show_col_types = FALSE) |>
    transmute(
      escala = escala,
      estimador = paste("MCO,", tolower(modelo)),
      estimacion = estimate, error_estandar = std.error,
      ic_inf = conf.low, ic_sup = conf.high
    )
}

ate_tabla <- bind_rows(
  leer_mco(
    "03_Resultados/Tablas/08_ate_experimento_log/experimento_ols_registro_log.csv",
    "Logaritmo del ingreso"
  ),
  ate_bosque(cf_log) |>
    mutate(escala = "Logaritmo del ingreso", estimador = "Bosque causal"),
  ate_bosque(cf_sin_tiempo) |>
    mutate(escala = "Logaritmo del ingreso",
           estimador = "Bosque causal, sin tiempo en el sitio"),
  leer_mco(
    "03_Resultados/Tablas/06_ate_experimento_niveles/experimento_ols_registro.csv",
    "Ingreso en dólares"
  ),
  ate_bosque(cf_niv) |>
    mutate(escala = "Ingreso en dólares", estimador = "Bosque causal")
) |>
  select(escala, estimador, estimacion, error_estandar, ic_inf, ic_sup)

tabla_ate <- ate_tabla |>
  mutate(
    dec = if_else(escala == "Ingreso en dólares", decimales$dolares, decimales$log),
    ic = texto_ic(ic_inf, ic_sup, dec),
    estimacion_txt = sprintf("%.*f", dec, estimacion),
    error_txt = sprintf("%.*f", dec, error_estandar)
  ) |>
  select(escala, estimador, estimacion_txt, error_txt, ic) |>
  gt(groupname_col = "escala") |>
  cols_label(
    estimador = "Estimador", estimacion_txt = "Efecto promedio",
    error_txt = "Error estándar", ic = "Intervalo del 95%"
  ) |>
  estilo_tabla(
    titulo = "El bosque causal reproduce el efecto promedio de la regresión en las dos escalas",
    subtitulo = "Efecto promedio del registro facilitado (ATE) según el estimador",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = c(
        paste(
          "Logaritmo: el efecto se lee como cambio proporcional aproximado del",
          "ingreso (0.01 ≈ 1%). Dólares: cambio del ingreso promedio por usuario."
        ),
        paste(
          "MCO con errores estándar robustos (HC1); los controles son los del",
          "lineal final de la predicción (scripts 06 y 08). Bosque causal de",
          "2,000 árboles honestos con tiempo en el sitio, sesiones anteriores,",
          "dispositivo, usuario recurrente y sistema operativo; el ATE es el",
          "promedio doblemente robusto de los efectos individuales."
        ),
        sprintf(
          paste(
            "Probabilidad de asignación estimada por el bosque: entre %.3f y",
            "%.3f (proporción tratada: %.3f)."
          ),
          rango_w_hat[1], rango_w_hat[2], mean(W)
        )
      )
    )
  )

guardar_tabla(
  "experimento_ate_lineal_vs_bosque", tabla_ate, ate_tabla, carpeta_salida
)

# -----------------------------------------------------------------------------
# 3. Evidencia formal de heterogeneidad (P4.2)
# -----------------------------------------------------------------------------

# 3.1 Prueba de calibracion (muestra completa, predicciones fuera de bolsa).
# Coeficiente medio cercano a 1: el bosque acierta el promedio. Coeficiente
# diferencial: H0 beta <= 0 (p unilateral); si se rechaza, las diferencias
# entre los CATE predichos se asocian a diferencias reales del efecto
calibracion <- function(cf, especificacion) {
  prueba <- test_calibration(cf)
  tibble(
    especificacion = especificacion,
    termino = c("Promedio del bosque", "Diferencias entre usuarios"),
    coeficiente = prueba[, "Estimate"],
    error_estandar = prueba[, "Std. Error"],
    p_valor = prueba[, "Pr(>t)"]
  )
}

calibracion_tabla <- bind_rows(
  calibracion(cf_log, "Logaritmo del ingreso"),
  calibracion(cf_sin_tiempo, "Logaritmo del ingreso, sin tiempo en el sitio"),
  calibracion(cf_niv, "Ingreso en dólares")
)

tabla_calibracion <- calibracion_tabla |>
  gt(groupname_col = "especificacion") |>
  cols_label(
    termino = "Coeficiente", coeficiente = "Estimación",
    error_estandar = "Error estándar", p_valor = "p-valor (unilateral)"
  ) |>
  fmt_number(
    c(coeficiente, error_estandar, p_valor), decimals = decimales$estadistico
  ) |>
  estilo_tabla(
    titulo = "Prueba de calibración del bosque causal",
    subtitulo = "¿Las diferencias entre los efectos estimados por usuario son reales?",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = c(
        paste(
          "Regresión del resultado ortogonalizado sobre el efecto promedio y",
          "sobre la desviación de cada efecto individual respecto del promedio",
          "(predicciones fuera de bolsa). Promedio del bosque cercano a 1: el",
          "efecto promedio está bien calibrado."
        ),
        paste(
          "Diferencias entre usuarios: hipótesis nula de coeficiente menor o",
          "igual a 0 (sin heterogeneidad que el bosque detecte). Un coeficiente",
          "cercano a 1 indica que las diferencias estimadas tienen el tamaño",
          "correcto; entre 0 y 1, que el bosque las exagera."
        )
      )
    )
  )

guardar_tabla(
  "experimento_calibracion_bosque", tabla_calibracion, calibracion_tabla,
  carpeta_salida
)

# 3.2 Curva TOC y AUTOC con muestra dividida. Un bosque estimado en la mitad
# de entrenamiento ordena a los usuarios de la otra mitad por su CATE predicho
# (prioridad); un bosque estimado solo con la mitad de evaluacion mide si los
# usuarios priorizados tienen un efecto mayor que el promedio. Asi las
# prioridades y su evaluacion no usan los mismos datos
idx_ent <- sample(n_exp, n_exp / 2)
idx_eva <- setdiff(seq_len(n_exp), idx_ent)

evaluar_priorizacion <- function(Y, escala) {
  cf_ent <- estimar_bosque(X[idx_ent, ], Y[idx_ent], W[idx_ent])
  cf_eva <- estimar_bosque(X[idx_eva, ], Y[idx_eva], W[idx_eva])
  prioridad_eva <- predict(cf_ent, X[idx_eva, ])$predictions
  rate <- rank_average_treatment_effect(cf_eva, prioridad_eva, target = "AUTOC")

  # terciles de prioridad: los cortes se fijan con los CATE fuera de bolsa de
  # la mitad de entrenamiento y se aplican a la mitad de evaluacion
  cortes <- quantile(predict(cf_ent)$predictions, c(1 / 3, 2 / 3))
  tercil <- cut(
    prioridad_eva, c(-Inf, cortes, Inf),
    labels = c("Prioridad baja", "Prioridad media", "Prioridad alta")
  )
  por_tercil <- map_dfr(levels(tercil), function(nivel) {
    ate_bosque(cf_eva, subset = tercil == nivel) |>
      mutate(grupo = nivel, n = sum(tercil == nivel))
  })

  list(
    autoc = tibble(
      escala = escala, grupo = "AUTOC (área bajo la curva TOC)",
      n = length(idx_eva), estimacion = rate$estimate,
      error_estandar = rate$std.err,
      ic_inf = estimacion - qnorm(0.975) * error_estandar,
      ic_sup = estimacion + qnorm(0.975) * error_estandar
    ),
    terciles = mutate(por_tercil, escala = escala),
    toc = mutate(as_tibble(rate$TOC), escala = escala)
  )
}

prior_log <- evaluar_priorizacion(experimento$log_revenue, "Logaritmo del ingreso")
prior_niv <- evaluar_priorizacion(experimento$Revenue, "Ingreso en dólares")

rate_tabla <- bind_rows(
  prior_log$autoc, prior_log$terciles, prior_niv$autoc, prior_niv$terciles
) |>
  select(escala, grupo, n, estimacion, error_estandar, ic_inf, ic_sup)

tabla_rate <- rate_tabla |>
  mutate(
    dec = if_else(escala == "Ingreso en dólares", decimales$dolares, decimales$log),
    estimacion_txt = sprintf("%.*f", dec, estimacion),
    ic = texto_ic(ic_inf, ic_sup, dec),
    n = format(n, big.mark = ",")
  ) |>
  select(escala, grupo, n, estimacion_txt, ic) |>
  gt(groupname_col = "escala") |>
  cols_label(
    grupo = "Medida", n = "Usuarios", estimacion_txt = "Estimación",
    ic = "Intervalo del 95%"
  ) |>
  estilo_tabla(
    titulo = "¿Priorizar por el efecto estimado identifica a quienes más responden?",
    subtitulo = "Curva TOC y efecto por tercil de prioridad, en la mitad de evaluación",
    nota = c(
      sprintf(
        paste(
          "Datos del experimento A/B (asignación aleatoria), mitad de",
          "evaluación (n = %s); las prioridades las fija un bosque estimado con",
          "la otra mitad (n = %s)."
        ),
        format(length(idx_eva), big.mark = ","),
        format(length(idx_ent), big.mark = ",")
      ),
      paste(
        "AUTOC: promedio, sobre todas las fracciones priorizadas, de cuánto",
        "supera el efecto de los usuarios priorizados al efecto promedio. Cero",
        "significa que priorizar por el efecto estimado no identifica a nadie",
        "con un efecto distinto del promedio."
      ),
      paste(
        "Terciles: cortes fijados con los efectos estimados en la mitad de",
        "entrenamiento; efecto de cada tercil estimado con el bosque de",
        "evaluación. Logaritmo: cambio proporcional aproximado; dólares:",
        "cambio del ingreso promedio."
      )
    )
  )

guardar_tabla("experimento_rate_autoc", tabla_rate, rate_tabla, carpeta_salida)

# -----------------------------------------------------------------------------
# 4. Efecto por grupos predefinidos (P4.3)
# -----------------------------------------------------------------------------

# grupos fijados en PLAN.md antes de estimar. Las sesiones anteriores se
# parten en tramos cercanos a terciles del experimento (cuantiles 1/3 y 2/3:
# 2 y 4 sesiones). Cada elemento es "caracteristica|grupo"
indicadores_grupo <- function(d) {
  list(
    "Dispositivo|Computador" = d$device_type == "desktop",
    "Dispositivo|Celular" = d$device_type == "mobile",
    "Dispositivo|Tableta" = d$device_type == "tablet",
    "Sistema operativo|osx" = d$os_type == "osx",
    "Sistema operativo|Windows" = d$os_type == "windows",
    "Sistema operativo|Otro" = d$os_type == "other",
    "Usuario recurrente|No" = d$is_returning_user == 0,
    "Usuario recurrente|Sí" = d$is_returning_user == 1,
    "Tiempo en el sitio|5 minutos o menos" = d$mas_5_min == 0,
    "Tiempo en el sitio|Más de 5 minutos" = d$mas_5_min == 1,
    "Sesiones anteriores|0 a 2" = d$past_sessions <= 2,
    "Sesiones anteriores|3 a 4" = d$past_sessions %in% 3:4,
    "Sesiones anteriores|5 o más" = d$past_sessions >= 5
  )
}

grupos_exp <- indicadores_grupo(experimento)
grupos_hist <- indicadores_grupo(historica)

efecto_grupos <- function(cf, escala) {
  imap_dfr(grupos_exp, function(en_grupo, nombre) {
    ate_bosque(cf, subset = en_grupo) |>
      mutate(
        escala = escala,
        caracteristica = str_split_i(nombre, "\\|", 1),
        grupo = str_split_i(nombre, "\\|", 2),
        n = sum(en_grupo),
        pct_historica = 100 * mean(grupos_hist[[nombre]])
      )
  }) |>
    # fila de referencia: todos los usuarios
    bind_rows(
      ate_bosque(cf) |>
        mutate(escala = escala, caracteristica = "Todos", grupo = "Todos",
               n = n_exp, pct_historica = 100)
    )
}

grupos_tabla <- bind_rows(
  efecto_grupos(cf_log, "Logaritmo del ingreso"),
  efecto_grupos(cf_niv, "Ingreso en dólares")
) |>
  select(escala, caracteristica, grupo, n, pct_historica, estimacion,
         error_estandar, ic_inf, ic_sup)

# una fila por grupo y una columna por escala, para leer las dos a la vez
tabla_grupos <- grupos_tabla |>
  mutate(
    dec = if_else(escala == "Ingreso en dólares", decimales$dolares, decimales$log),
    efecto = sprintf("%.*f", dec, estimacion),
    ic = texto_ic(ic_inf, ic_sup, dec),
    escala = if_else(escala == "Ingreso en dólares", "niv", "log")
  ) |>
  select(caracteristica, grupo, n, pct_historica, escala, efecto, ic) |>
  pivot_wider(names_from = escala, values_from = c(efecto, ic)) |>
  mutate(
    caracteristica = factor(caracteristica, unique(caracteristica)),
    n = format(n, big.mark = ",")
  ) |>
  gt(groupname_col = "caracteristica") |>
  cols_label(
    grupo = "Grupo", n = "Usuarios (experimento)",
    pct_historica = "% de la base histórica",
    efecto_log = "Efecto", ic_log = "Intervalo del 95%",
    efecto_niv = "Efecto", ic_niv = "Intervalo del 95%"
  ) |>
  tab_spanner("Logaritmo del ingreso", c(efecto_log, ic_log)) |>
  tab_spanner("Ingreso en dólares", c(efecto_niv, ic_niv)) |>
  fmt_number(pct_historica, decimals = decimales$porcentaje) |>
  estilo_tabla(
    titulo = "Efecto del registro facilitado por grupo de usuarios",
    subtitulo = "Efecto promedio de cada grupo estimado con el bosque causal",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = c(
        paste(
          "Logaritmo: cambio proporcional aproximado del ingreso (0.01 ≈ 1%).",
          "Dólares: cambio del ingreso promedio por usuario. Efecto de cada",
          "grupo: promedio doblemente robusto de los efectos individuales del",
          "grupo (bosque de 2,000 árboles)."
        ),
        paste(
          "Los grupos se definieron antes de estimar. Con 13 grupos y dos",
          "escalas, a un nivel de 5% es esperable que algún intervalo excluya",
          "el cero por azar: los intervalos no se corrigen por comparaciones",
          "múltiples y no reemplazan la prueba de calibración."
        ),
        sprintf(
          "%% de la base histórica: participación del grupo en los datos históricos (n = %s).",
          format(nrow(historica), big.mark = ",")
        )
      )
    )
  )

guardar_tabla(
  "experimento_cate_por_grupo", tabla_grupos, grupos_tabla, carpeta_salida
)

# -----------------------------------------------------------------------------
# 5. Donde mira el bosque: importancia de variables (P4.4)
# -----------------------------------------------------------------------------

# frecuencia de cortes ponderada por profundidad: dice en que variables corta
# el bosque, no cuanto del efecto explica cada una ni que la variable cause
# el efecto
importancia <- function(cf, escala) {
  tibble(
    escala = escala,
    variable = unname(etiquetas_x[colnames(cf$X.orig)]),
    importancia = 100 * as.vector(variable_importance(cf))
  )
}

importancia_tabla <- bind_rows(
  importancia(cf_log, "log"), importancia(cf_niv, "niv")
) |>
  pivot_wider(names_from = escala, values_from = importancia) |>
  arrange(desc(log))

tabla_importancia <- importancia_tabla |>
  gt() |>
  cols_label(
    variable = "Variable", log = "Logaritmo del ingreso",
    niv = "Ingreso en dólares"
  ) |>
  fmt_number(c(log, niv), decimals = decimales$porcentaje) |>
  estilo_tabla(
    titulo = "En qué variables corta el bosque causal",
    subtitulo = "Participación de cada variable en los cortes del bosque (%)",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = paste(
        "Frecuencia de cortes ponderada por la profundidad (suma 100% por",
        "columna). Indica dónde mira el bosque al estimar los efectos; no es",
        "un efecto ni el porcentaje de la heterogeneidad que explica cada",
        "variable, y un bosque corta también en variables sin heterogeneidad."
      )
    )
  )

guardar_tabla(
  "experimento_importancia_bosque_causal", tabla_importancia, importancia_tabla,
  carpeta_salida
)

# -----------------------------------------------------------------------------
# 6. Robustez: bosque sin tiempo en el sitio (P4.6)
# -----------------------------------------------------------------------------

# el tiempo en el sitio se mide en la misma sesion que el gasto; si el bosque
# sin el cambia poco los efectos por grupo, la conclusion no depende de
# tratarlo como pre-tratamiento
robustez_tabla <- bind_rows(
  efecto_grupos(cf_log, "Con tiempo en el sitio"),
  efecto_grupos(cf_sin_tiempo, "Sin tiempo en el sitio")
) |>
  select(escala, caracteristica, grupo, n, estimacion, error_estandar,
         ic_inf, ic_sup)

tabla_robustez <- robustez_tabla |>
  mutate(
    efecto = sprintf("%.*f", decimales$log, estimacion),
    ic = texto_ic(ic_inf, ic_sup, decimales$log),
    escala = if_else(escala == "Con tiempo en el sitio", "con", "sin")
  ) |>
  select(caracteristica, grupo, n, escala, efecto, ic) |>
  pivot_wider(names_from = escala, values_from = c(efecto, ic)) |>
  mutate(
    caracteristica = factor(caracteristica, unique(caracteristica)),
    n = format(n, big.mark = ",")
  ) |>
  gt(groupname_col = "caracteristica") |>
  cols_label(
    grupo = "Grupo", n = "Usuarios",
    efecto_con = "Efecto", ic_con = "Intervalo del 95%",
    efecto_sin = "Efecto", ic_sin = "Intervalo del 95%"
  ) |>
  tab_spanner("Con tiempo en el sitio", c(efecto_con, ic_con)) |>
  tab_spanner("Sin tiempo en el sitio", c(efecto_sin, ic_sin)) |>
  estilo_tabla(
    titulo = "Los efectos por grupo con y sin el tiempo en el sitio",
    subtitulo = "Efecto en el logaritmo del ingreso, bosque causal",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = paste(
        "El tiempo en el sitio se mide en la misma sesión que el gasto. El",
        "bosque sin él usa sesiones anteriores, dispositivo, usuario",
        "recurrente y sistema operativo; los grupos de tiempo se siguen",
        "pudiendo evaluar porque el efecto de cada grupo promedia los efectos",
        "individuales de sus usuarios. Efectos en logaritmo (0.01 ≈ 1%)."
      )
    )
  )

guardar_tabla(
  "experimento_robustez_sin_tiempo", tabla_robustez, robustez_tabla,
  carpeta_salida
)

# -----------------------------------------------------------------------------
# 7. Figuras
# -----------------------------------------------------------------------------

escalas <- c("Logaritmo del ingreso", "Ingreso en dólares")

# 7.1 CATE ordenados de menor a mayor, con su intervalo y el ATE como
# referencia
ates_ref <- ate_tabla |>
  filter(estimador == "Bosque causal") |>
  mutate(escala = factor(escala, escalas))

datos_cates <- cates |>
  group_by(escala) |>
  arrange(cate, .by_group = TRUE) |>
  mutate(rango = 100 * (row_number() - 0.5) / n()) |>
  ungroup() |>
  mutate(escala = factor(escala, escalas))

grafica_cates <- ggplot(datos_cates, aes(x = rango)) +
  geom_ribbon(aes(ymin = ic_inf, ymax = ic_sup), fill = paleta_categorica[1],
              alpha = 0.25) +
  geom_line(aes(y = cate), color = paleta_categorica[1], linewidth = 0.8) +
  geom_hline(yintercept = 0, color = gris_secundario, linewidth = 0.4) +
  geom_hline(data = ates_ref, aes(yintercept = estimacion), linetype = "dashed",
             color = gris_secundario, linewidth = 0.6) +
  facet_wrap(~ escala, scales = "free_y") +
  labs(
    title = "Efecto estimado del registro facilitado para cada usuario",
    subtitle = subtitulo_experimento,
    x = "Usuarios ordenados por su efecto estimado (percentil)",
    y = "Efecto estimado (logaritmo o dólares)",
    caption = paste(
      sprintf("Nota: n = %s usuarios. Estimaciones fuera de bolsa del bosque causal (2,000 árboles).",
              format(n_exp, big.mark = ",")),
      paste(
        "Banda: intervalo del 95% de cada efecto individual. Línea punteada",
        "gris: efecto promedio del bosque. Línea continua gris: cero."
      ),
      paste(
        "Que los efectos estimados varíen no prueba heterogeneidad: ver la",
        "prueba de calibración y la curva TOC."
      ),
      sep = "\n"
    )
  ) +
  tema_presentacion +
  tema_paneles

guardar_figura("experimento_cate_ordenados.png", grafica_cates, carpeta_salida)

# 7.2 Curva TOC: cuanto supera el efecto de la fraccion priorizada al efecto
# promedio, para cada fraccion de usuarios priorizados
datos_toc <- bind_rows(prior_log$toc, prior_niv$toc) |>
  mutate(
    escala = factor(escala, escalas),
    ic_inf = estimate - qnorm(0.975) * std.err,
    ic_sup = estimate + qnorm(0.975) * std.err
  )

grafica_toc <- ggplot(datos_toc, aes(x = 100 * q)) +
  geom_ribbon(aes(ymin = ic_inf, ymax = ic_sup), fill = paleta_categorica[1],
              alpha = 0.25) +
  geom_line(aes(y = estimate), color = paleta_categorica[1], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = gris_secundario,
             linewidth = 0.6) +
  facet_wrap(~ escala, scales = "free_y") +
  labs(
    title = "Ganancia de priorizar usuarios por su efecto estimado",
    subtitle = subtitulo_experimento,
    x = "Fracción de usuarios priorizados (%)",
    y = "Efecto de los priorizados menos efecto promedio",
    caption = paste(
      sprintf(
        "Nota: mitad de evaluación (n = %s); las prioridades las fija un bosque estimado con la otra mitad (n = %s).",
        format(length(idx_eva), big.mark = ","),
        format(length(idx_ent), big.mark = ",")
      ),
      paste(
        "Banda: intervalo del 95%. Línea punteada gris: cero (priorizar no",
        "identifica usuarios con un efecto distinto del promedio)."
      ),
      sep = "\n"
    )
  ) +
  tema_presentacion +
  tema_paneles

guardar_figura("experimento_toc.png", grafica_toc, carpeta_salida)

# 7.3 Efecto por grupo con su intervalo, en las dos escalas
datos_grupos <- grupos_tabla |>
  mutate(
    escala = factor(escala, escalas),
    caracteristica = factor(caracteristica, rev(unique(caracteristica))),
    grupo = fct_rev(fct_inorder(if_else(
      caracteristica == "Todos", "Todos los usuarios",
      paste(caracteristica, grupo, sep = ": ")
    )))
  )

grafica_grupos <- ggplot(
  datos_grupos, aes(x = estimacion, y = grupo)
) +
  geom_vline(xintercept = 0, color = gris_secundario, linewidth = 0.4) +
  geom_vline(data = ates_ref, aes(xintercept = estimacion), linetype = "dashed",
             color = gris_secundario, linewidth = 0.6) +
  geom_errorbarh(aes(xmin = ic_inf, xmax = ic_sup), height = 0,
                 color = paleta_categorica[1], linewidth = 0.7) +
  geom_point(color = paleta_categorica[1], size = 2.2) +
  facet_wrap(~ escala, scales = "free_x") +
  labs(
    title = "Efecto del registro facilitado por grupo de usuarios",
    subtitle = subtitulo_experimento,
    x = "Efecto (logaritmo: cambio proporcional; dólares por usuario)",
    y = NULL,
    caption = paste(
      sprintf("Nota: n = %s usuarios; el tamaño de cada grupo está en la tabla del efecto por grupo.",
              format(n_exp, big.mark = ",")),
      "Puntos: efecto del grupo estimado con el bosque causal.",
      "Barras: intervalo del 95%, sin corregir por comparaciones múltiples.",
      "Línea punteada gris: efecto promedio de todos los usuarios. Línea continua gris: cero.",
      sep = "\n"
    )
  ) +
  tema_presentacion +
  tema_paneles +
  theme(
    axis.text.y = element_text(color = gris_texto),
    axis.text.x = element_text(size = 10, face = "plain"),
    panel.grid.major.x = element_line(color = gris_grilla, linewidth = 0.4),
    panel.grid.major.y = element_blank()
  )

guardar_figura(
  "experimento_cate_por_grupo.png", grafica_grupos, carpeta_salida
)

cat("\nListo. Resultados guardados en 03_Resultados/{Figuras,Tablas}/12_heterogeneidad_experimento/.\n")
cat("Recordatorio: los CATE son estimaciones causales condicionales; su dispersion no prueba HTE.\n")
