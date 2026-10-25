# =============================================================================
# Efecto del registro facilitado sobre Revenue en nivel (dolares)
# Taller 2 - ECON-3785 (Parte B)
#
# Estimando: ITT de easier_signup (registro facilitado) sobre el ingreso en
# dolares, la escala del Taller 1. Solo el experimento (asignacion aleatoria)
# sostiene una lectura causal. Estimador: MCO con errores estandar robustos HC1,
# sin controles y con los controles del lineal final de la prediccion
# (04_prediccion_lineal_observacional.R, sin sign_up).
#
# Antes de estimar se verifican las dos condiciones que sostienen la lectura
# del ITT (heuristicas H6 y H7): balance de las covariables pre-tratamiento
# entre grupos y cumplimiento (si sign_up sigue a easier_signup).
#
# Como los controles salen de patrones hallados en la base historica, la
# seccion 4 comprueba que esos patrones (quiebre en 5 minutos, cruce con las
# sesiones anteriores, tiempo exacto redundante, aporte pequeno del resto)
# tambien aparecen en la muestra del experimento.
#
# La escala logaritmica y el ATE con bosque causal van en scripts posteriores.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema y funcion de guardado de las figuras; estilo de las tablas
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

set.seed(2026)

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "06_ate_experimento_niveles"

exp <- readRDS("01_Datos/03_Listos/experimento_listos.RDS") |>
  # mismo indicador del quiebre que en 04: el corte de 5 minutos viene del
  # Taller 1 y de la descriptiva
  mutate(mas_5_min = as.integer(time_spent > 5))

n_exp <- nrow(exp)

# -----------------------------------------------------------------------------
# 1. Cumplimiento: sign_up frente a easier_signup
# -----------------------------------------------------------------------------

# si sign_up coincide con easier_signup en todas las filas, nadie asignado al
# tratamiento dejo de registrarse y nadie en control se registro: el ITT es
# tambien el efecto de registrarse (LATE = ITT)
cumplimiento <- exp |>
  count(easier_signup, sign_up) |>
  mutate(easier_signup = factor(easier_signup, c(0, 1),
                                c("Control", "Registro facilitado")),
         sign_up = factor(sign_up, c(0, 1), c("Sin registro", "Registrado")))
print(cumplimiento)
stopifnot(
  all(exp$sign_up == exp$easier_signup),
  nrow(cumplimiento) == 2 # solo las celdas (0, 0) y (1, 1)
)

tabla_cumplimiento <- exp |>
  count(easier_signup, sign_up) |>
  mutate(
    grupo = if_else(easier_signup == 1, "Registro facilitado", "Control"),
    estado = if_else(sign_up == 1, "Registrado", "Sin registro")
  ) |>
  select(grupo, estado, n) |>
  pivot_wider(names_from = estado, values_from = n, values_fill = 0) |>
  mutate(Total = `Sin registro` + `Registrado`) |>
  mutate(grupo = factor(grupo, c("Control", "Registro facilitado"))) |>
  arrange(grupo) |>
  mutate(grupo = as.character(grupo))

tabla_cumplimiento_gt <- tabla_cumplimiento |>
  gt() |>
  cols_label(grupo = "Grupo asignado", `Sin registro` = "Sin registro",
             Registrado = "Registrado", Total = "Total") |>
  fmt_number(columns = -grupo, decimals = decimales$conteo) |>
  cols_align(align = "left", columns = grupo) |>
  estilo_tabla(
    titulo = "Todos los asignados al registro facilitado se registraron",
    subtitulo = "Usuarios según el grupo asignado y su estado de registro",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = paste(
        "Cumplimiento perfecto: ningún usuario de control se registró y",
        "ninguno de los asignados al registro facilitado dejó de hacerlo. Por",
        "eso el efecto de la asignación es también el efecto de registrarse."
      )
    )
  )

guardar_tabla(
  "experimento_cumplimiento", tabla_cumplimiento_gt,
  tabla_cumplimiento, carpeta_salida
)

# -----------------------------------------------------------------------------
# 2. Balance de covariables pre-tratamiento
# -----------------------------------------------------------------------------

# covariables medidas antes (o al margen) del tratamiento; time_spent se trata
# como pre-tratamiento (decision del 2026-10-23). Cada fila es una variable o
# una categoria; las categoricas y binarias se reportan como porcentaje.
# El valor p es el de la regresion de la covariable sobre easier_signup (HC1),
# que equivale a una prueba de diferencia de medias con varianzas desiguales.
covariables <- exp |>
  transmute(
    easier_signup,
    `Tiempo en el sitio (minutos)` = time_spent,
    `Más de 5 minutos en el sitio (%)` = 100 * mas_5_min,
    `Sesiones anteriores (número)` = past_sessions,
    `Usuario recurrente (%)` = 100 * is_returning_user,
    `Computador de escritorio (%)` = 100 * (device_type == "desktop"),
    `Celular (%)` = 100 * (device_type == "mobile"),
    `Tableta (%)` = 100 * (device_type == "tablet"),
    `Sistema osx (%)` = 100 * (os_type == "osx"),
    `Sistema windows (%)` = 100 * (os_type == "windows"),
    `Otro sistema operativo (%)` = 100 * (os_type == "other")
  )

balance <- covariables |>
  pivot_longer(-easier_signup, names_to = "variable", values_to = "valor") |>
  group_by(variable = factor(variable, names(covariables)[-1])) |>
  group_modify(~ {
    ajuste <- lm(valor ~ easier_signup, data = .x)
    ee <- sqrt(diag(sandwich::vcovHC(ajuste, type = "HC1")))[["easier_signup"]]
    b <- coef(ajuste)[["easier_signup"]]
    tibble(
      media_control = mean(.x$valor[.x$easier_signup == 0]),
      media_tratamiento = mean(.x$valor[.x$easier_signup == 1]),
      diferencia = b,
      error_estandar = ee,
      valor_p = 2 * pt(-abs(b / ee), df = ajuste$df.residual)
    )
  }) |>
  ungroup() |>
  mutate(variable = as.character(variable))

# prueba conjunta: ¿las covariables predicen la asignacion? Regresion de
# easier_signup sobre todas ellas (con os_type, que el Taller 1 omitio) y
# prueba de Wald de que todos los coeficientes son cero, con errores HC1
ajuste_conjunto <- fixest::feols(
  easier_signup ~ time_spent + past_sessions + is_returning_user +
    device_type + os_type,
  data = exp, vcov = "hc1"
)
prueba_conjunta <- fixest::wald(
  ajuste_conjunto, keep = "time_spent|past_sessions|is_returning_user|device|os",
  print = FALSE
)
f_conjunta <- prueba_conjunta$stat
p_conjunta <- prueba_conjunta$p
cat(sprintf("\nPrueba conjunta de balance: F = %.3f, valor p = %.3f\n",
            f_conjunta, p_conjunta))

tabla_balance <- balance |>
  gt() |>
  cols_label(
    variable = "Característica",
    media_control = "Control",
    media_tratamiento = "Registro facilitado",
    diferencia = "Diferencia",
    error_estandar = "Error estándar",
    valor_p = "Valor p"
  ) |>
  fmt_number(
    columns = c(media_control, media_tratamiento, diferencia, error_estandar),
    decimals = 2
  ) |>
  fmt_number(columns = valor_p, decimals = decimales$estadistico) |>
  cols_align(align = "left", columns = variable) |>
  estilo_tabla(
    titulo = "Las características de los usuarios son similares entre grupos",
    subtitulo = "Promedios por grupo asignado, antes del tratamiento",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = c(
        paste(
          "Diferencia = registro facilitado menos control; error estándar y",
          "valor p robustos (HC1). Los porcentajes están en puntos."
        ),
        sprintf(
          paste(
            "Prueba conjunta de que las características no predicen la",
            "asignación: F = %.2f, valor p = %.3f."
          ),
          f_conjunta, p_conjunta
        )
      )
    )
  )

guardar_tabla(
  "experimento_balance", tabla_balance,
  balance |> mutate(f_conjunta = f_conjunta, p_conjunta = p_conjunta),
  carpeta_salida
)

# -----------------------------------------------------------------------------
# 3. Efecto del registro facilitado: sin y con controles
# -----------------------------------------------------------------------------

# modelo simple: el coeficiente es la diferencia de medias entre grupos
ols_simple <- lm(Revenue ~ easier_signup, data = exp)

# modelo con los controles del lineal final de la prediccion (04), sin sign_up
# porque coincide con el tratamiento. En un experimento aleatorizado los
# controles no corrigen sesgo; solo pueden ganar precision, asi que se compara
# el coeficiente y su error estandar con el del modelo simple.
ols_controles <- lm(
  Revenue ~ easier_signup + mas_5_min + past_sessions +
    mas_5_min:past_sessions + device_type + os_type + is_returning_user,
  data = exp
)

media_control <- mean(exp$Revenue[exp$easier_signup == 0])

filas_extra <- tibble(
  term = c("Promedio del grupo de control (dólares)", "Controles"),
  `Sin controles` = c(sprintf("%.3f", media_control), "No"),
  `Con controles` = c(sprintf("%.3f", media_control), "Sí")
)
attr(filas_extra, "position") <- c(3, 4)

tabla_itt <- modelsummary(
  list(
    "Sin controles" = ols_simple,
    "Con controles" = ols_controles
  ),
  vcov = "HC1",
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  statistic = "({std.error})",
  coef_map = c("easier_signup" = "Registro facilitado (efecto en dólares)"),
  gof_map = list(
    list(raw = "nobs", clean = "Observaciones",
         fmt = function(x) format(x, big.mark = ",")),
    list(raw = "r.squared", clean = "R²", fmt = 3)
  ),
  add_rows = filas_extra,
  fmt = 3,
  output = "gt"
) |>
  estilo_tabla(
    titulo = "El registro facilitado aumenta el ingreso en dólares",
    subtitulo = "Efecto de la asignación sobre el ingreso, MCO (dólares)",
    nota = nota_tabla(
      "experimento", NULL,
      extra = c(
        paste(
          "Errores estándar robustos (HC1) entre paréntesis. El efecto es el de",
          "la asignación (ITT) y, por el cumplimiento perfecto, también el de",
          "registrarse."
        ),
        paste(
          "Controles: más de 5 minutos en el sitio, sesiones anteriores y su",
          "cruce, dispositivo, sistema operativo y usuario recurrente (los del",
          "modelo lineal final de la predicción, sin el registro)."
        )
      )
    )
  )

guardar_tabla(
  "experimento_ols_registro", tabla_itt,
  bind_rows(
    get_estimates(ols_simple, vcov = "HC1") |> mutate(modelo = "Sin controles"),
    get_estimates(ols_controles, vcov = "HC1") |> mutate(modelo = "Con controles")
  ) |>
    filter(term == "easier_signup"),
  carpeta_salida
)

# -----------------------------------------------------------------------------
# 4. ¿Los patrones de la especificacion tambien estan en el experimento?
# -----------------------------------------------------------------------------

# Los controles de la seccion 3 vienen del lineal final de la prediccion, que se
# armo con la base historica (corte de 5 minutos, cruce con sesiones anteriores,
# aporte pequeno de dispositivo, sistema operativo y usuario recurrente). Aqui se
# verifica que cada patron aparezca tambien en el experimento. Es una
# comprobacion descriptiva/predictiva del modelo de controles, no un resultado
# causal: la aleatorizacion ya garantiza que el ITT no depende de ella.
obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds") |>
  mutate(mas_5_min = as.integer(time_spent > 5))
n_obs <- nrow(obs)

# --- 4.1 Quiebre en 5 minutos y cruce con sesiones (figuras) -----------------

# mismas figuras de 03_punto_partida.R, ahora con el experimento. Con la
# asignacion aleatoria los dos grupos estan balanceados en las covariables
# (seccion 2), asi que se usa la muestra completa; el efecto del tratamiento
# (unos 0.49 dolares) desplaza ambos lados del quiebre por igual
media_global_exp <- mean(exp$Revenue)
nota_referencia_exp <- sprintf(
  "La línea punteada gris horizontal marca el promedio global (%.2f dólares).",
  media_global_exp
)

grafica_tiempo_exp <- exp |>
  mutate(lado = time_spent >= 5) |>
  ggplot(aes(x = time_spent, y = Revenue, group = lado)) +
  geom_hline(yintercept = media_global_exp, linetype = "dashed",
             color = gris_secundario, linewidth = 0.5) +
  geom_vline(xintercept = 5, linetype = "dotted",
             color = paleta_categorica[2], linewidth = 0.8) +
  geom_smooth(method = "loess", formula = y ~ x, span = 0.5, level = 0.95,
              color = paleta_categorica[1], fill = paleta_categorica[1],
              linewidth = 1, alpha = 0.2) +
  scale_x_log10(breaks = c(0.1, 1, 5, 10, 50),
                labels = c("0.1", "1", "5", "10", "50")) +
  # los pocos usuarios con menos de 0.1 minutos ensanchan la banda sin aportar
  coord_cartesian(xlim = c(0.1, 50)) +
  labs(
    title = "Ingreso promedio según el tiempo en el sitio, en el experimento",
    subtitle = subtitulo_experimento,
    x = "Tiempo en el sitio (minutos, escala log)",
    y = "Promedio de ingreso (dólares)",
    caption = paste(
      sprintf(paste("Nota: n = %s usuarios (ambos grupos). Curva suavizada",
                    "(loess) ajustada por separado a cada lado de los 5",
                    "minutos; banda: IC del 95%%."),
              format(n_exp, big.mark = ",")),
      paste(nota_referencia_exp,
            "La línea punteada ocre marca los 5 minutos (quiebre del Taller 1)."),
      sep = "\n"
    )
  ) +
  tema_presentacion

guardar_figura("experimento_revenue_tiempo_sesion.png", grafica_tiempo_exp,
               carpeta_salida)

# mismos tramos de sesiones que en 03_punto_partida.R
colores_tramo <- c(
  "0 a 2 sesiones" = paleta_categorica[1],
  "3 sesiones" = paleta_categorica[3],
  "4 o más sesiones" = paleta_categorica[2]
)
datos_cruce_exp <- exp |>
  mutate(
    tramo = cut(past_sessions, breaks = c(-Inf, 2, 3, Inf),
                labels = names(colores_tramo)),
    lado = time_spent >= 5
  )
n_tramo_exp <- count(datos_cruce_exp, tramo)

grafica_cruce_exp <- ggplot(
  datos_cruce_exp,
  aes(x = time_spent, y = Revenue, color = tramo, fill = tramo,
      group = interaction(tramo, lado))
) +
  geom_hline(yintercept = media_global_exp, linetype = "dashed",
             color = gris_secundario, linewidth = 0.5) +
  geom_vline(xintercept = 5, linetype = "dotted",
             color = gris_nota, linewidth = 0.8) +
  geom_smooth(method = "loess", formula = y ~ x, span = 0.5, level = 0.95,
              linewidth = 1, alpha = 0.2) +
  scale_color_manual(values = colores_tramo) +
  scale_fill_manual(values = colores_tramo) +
  scale_x_log10(breaks = c(0.1, 1, 5, 50), labels = c("0.1", "1", "5", "50")) +
  coord_cartesian(xlim = c(0.1, 25)) +
  labs(
    title = "Ingreso según tiempo y sesiones anteriores, en el experimento",
    subtitle = subtitulo_experimento,
    x = "Tiempo en el sitio (minutos, escala log)",
    y = "Promedio de ingreso (dólares)",
    color = NULL, fill = NULL,
    caption = paste(
      sprintf("Nota: n = %s usuarios, ambos grupos (%s).",
              format(n_exp, big.mark = ","),
              paste0(n_tramo_exp$tramo, " ",
                     format(n_tramo_exp$n, big.mark = ",", trim = TRUE),
                     collapse = ", ")),
      paste("Curvas suavizadas (loess) ajustadas por separado a cada lado de",
            "los 5 minutos; bandas: IC del 95%."),
      paste(nota_referencia_exp, "La línea punteada gris vertical marca los 5",
            "minutos."),
      sep = "\n"
    )
  ) +
  tema_presentacion +
  theme(legend.position = "top")

guardar_figura("experimento_revenue_tiempo_por_sesiones.png",
               grafica_cruce_exp, carpeta_salida)

# --- 4.2 Coeficientes del quiebre y del cruce en las dos bases ---------------

# el mismo modelo de controles en las dos bases; el experimento suma la
# asignacion (la base historica no lleva sign_up: no aporta, ver script 04). Si
# los patrones son los mismos, el salto de los 5 minutos y el cruce tienen el
# mismo signo y orden de magnitud
ols_patrones_obs <- lm(
  Revenue ~ mas_5_min + past_sessions + mas_5_min:past_sessions +
    device_type + os_type + is_returning_user,
  data = obs
)
ols_patrones_exp <- lm(
  Revenue ~ easier_signup + mas_5_min + past_sessions +
    mas_5_min:past_sessions + device_type + os_type + is_returning_user,
  data = exp
)

tabla_patrones <- modelsummary(
  list("Datos históricos" = ols_patrones_obs,
       "Experimento" = ols_patrones_exp),
  vcov = "HC1",
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  statistic = "({std.error})",
  coef_map = c(
    "mas_5_min" = "Más de 5 minutos (con 0 sesiones anteriores)",
    "past_sessions" = "Sesiones anteriores (con 5 minutos o menos)",
    "mas_5_min:past_sessions" =
      "Sesiones anteriores adicionales con más de 5 minutos"
  ),
  gof_map = list(
    list(raw = "nobs", clean = "Observaciones",
         fmt = function(x) format(x, big.mark = ",")),
    list(raw = "r.squared", clean = "R²", fmt = 3)
  ),
  fmt = 3,
  output = "gt"
) |>
  estilo_tabla(
    titulo = "Las sesiones anteriores se asocian con más ingreso solo después de los 5 minutos, en ambas bases",
    subtitulo = "Ingreso (dólares), MCO con los controles del modelo lineal final",
    nota = c(
      paste("Datos históricos, muestra completa, y datos del experimento A/B",
            "(asignación aleatoria), muestra completa."),
      paste("Errores estándar robustos (HC1) entre paréntesis. Controles no",
            "mostrados: dispositivo, sistema operativo y usuario recurrente;",
            "en el experimento, también la asignación al registro facilitado."),
      paste("El último renglón es la diferencia en la asociación de cada sesión",
            "anterior con el ingreso entre quienes pasan más de 5 minutos y",
            "quienes no. Son asociaciones, no efectos causales."),
      paste("El primer renglón no es el salto de los 5 minutos: compara a",
            "usuarios sin sesiones anteriores, que son pocos. Como las sesiones",
            "suben el ingreso solo después del corte, el salto depende del",
            "número de sesiones y se ve en la figura del ingreso frente al",
            "tiempo, no en este coeficiente.")
    )
  )

guardar_tabla(
  "experimento_patrones_quiebre_cruce", tabla_patrones,
  bind_rows(
    get_estimates(ols_patrones_obs, vcov = "HC1") |>
      mutate(base = "Datos históricos"),
    get_estimates(ols_patrones_exp, vcov = "HC1") |>
      mutate(base = "Experimento")
  ) |>
    filter(term %in% c("mas_5_min", "past_sessions", "mas_5_min:past_sessions")),
  carpeta_salida
)

# --- 4.3 Escalera de validacion cruzada en el experimento --------------------

# misma escalera de 04_prediccion_lineal_observacional.R, con 5 pliegues sobre
# toda la muestra del experimento (n = 10,000). No se separa un test porque aqui
# no se elige un modelo para predecir: se compara si cada paso aporta algo
# parecido. Las cifras de la base historica se leen de las tablas que exporta
# 04 (RMSE de validacion cruzada en entrenamiento, n = 80,000)
set.seed(2026)
pliegues_exp <- caret::createFolds(exp$Revenue, k = 5)

rmse_pliegues_exp <- function(formula) {
  map_dbl(pliegues_exp, function(idx) {
    ajuste <- lm(formula, data = exp[-idx, ])
    sqrt(mean((exp$Revenue[idx] - predict(ajuste, newdata = exp[idx, ]))^2))
  })
}

# mismos escalones que 04; el ultimo es la asignacion (en la historica, sign_up)
escalones_exp <- tribble(
  ~termino,                    ~variable,
  NA,                          "Ninguna (media de la muestra)",
  "mas_5_min",                 "Más de 5 minutos en el sitio",
  "past_sessions",             "Sesiones anteriores",
  "mas_5_min:past_sessions",   "Más de 5 minutos × sesiones anteriores",
  "device_type",               "Dispositivo",
  "os_type",                   "Sistema operativo",
  "is_returning_user",         "Usuario recurrente",
  "easier_signup",             "Registro (asignación o registro)"
)

formula_hasta_exp <- function(k) {
  terminos <- na.omit(escalones_exp$termino[seq_len(k)])
  reformulate(if (length(terminos) == 0) "1" else terminos, response = "Revenue")
}

# una lista con el RMSE de los 5 pliegues de cada escalon (no se llama igual
# que la columna de abajo para que tibble() no la tape)
pliegues_por_paso <- map(seq_len(nrow(escalones_exp)),
                         ~ rmse_pliegues_exp(formula_hasta_exp(.x)))

# robustez: el tiempo exacto despues del modelo con el corte (sin asignacion)
rmse_con_corte <- rmse_pliegues_exp(formula_hasta_exp(7))
rmse_con_corte_tiempo <- rmse_pliegues_exp(
  update(formula_hasta_exp(7), . ~ . + time_spent)
)

escalera_exp <- tibble(
  paso = seq_along(pliegues_por_paso) - 1,
  variable = escalones_exp$variable,
  rmse_exp = map_dbl(pliegues_por_paso, mean),
  caida_exp = c(NA, map_dbl(seq_along(pliegues_por_paso)[-1],
                            ~ mean(pliegues_por_paso[[.x - 1]] -
                                     pliegues_por_paso[[.x]]))),
  ee_caida_exp = c(NA, map_dbl(seq_along(pliegues_por_paso)[-1], function(k) {
    d <- pliegues_por_paso[[k - 1]] - pliegues_por_paso[[k]]
    sd(d) / sqrt(length(d))
  }))
)

escalera_obs <- read_csv(
  "03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_escalera_rmse.csv",
  show_col_types = FALSE
) |>
  transmute(paso, rmse_obs = rmse_cv, caida_obs = caida, ee_caida_obs = ee_caida)
stopifnot(nrow(escalera_obs) == nrow(escalera_exp))

escalera_comparada <- left_join(escalera_exp, escalera_obs, by = "paso")
print(escalera_comparada)

# tiempo exacto despues del corte en la base historica (tabla de robustez de 04)
robustez_obs <- read_csv(
  "03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_robustez_forma_tiempo.csv",
  show_col_types = FALSE
)
caida_tiempo_obs <- robustez_obs$rmse_cv[1] - robustez_obs$rmse_cv[3]
d_tiempo_exp <- rmse_con_corte - rmse_con_corte_tiempo
caida_tiempo_exp <- mean(d_tiempo_exp)
ee_tiempo_exp <- sd(d_tiempo_exp) / sqrt(length(d_tiempo_exp))

tabla_escalera_exp <- escalera_comparada |>
  select(variable, rmse_obs, caida_obs, rmse_exp, caida_exp, ee_caida_exp) |>
  gt() |>
  cols_label(
    variable = "Variable agregada",
    rmse_obs = "RMSE", caida_obs = "Caída",
    rmse_exp = "RMSE", caida_exp = "Caída",
    ee_caida_exp = "Error est. caída"
  ) |>
  tab_spanner("Datos históricos (entrenamiento)",
              columns = c(rmse_obs, caida_obs)) |>
  tab_spanner("Experimento", columns = c(rmse_exp, caida_exp, ee_caida_exp)) |>
  fmt_number(columns = -variable, decimals = decimales$rmse) |>
  sub_missing(missing_text = "—") |>
  cols_align(align = "left", columns = variable) |>
  estilo_tabla(
    titulo = "Los mismos pasos reducen el error de predicción en el experimento",
    subtitulo = "RMSE de validación cruzada de 5 pliegues y caída por paso (dólares)",
    nota = c(
      sprintf(paste("Datos históricos, entrenamiento (n = 80,000), y datos del",
                    "experimento A/B, muestra completa (n = %s). Predicción,",
                    "no causalidad."), format(n_exp, big.mark = ",")),
      paste("Cada fila agrega una variable al modelo de la fila anterior; la",
            "caída es la reducción del RMSE frente a esa fila. El último paso",
            "es el registro en la base histórica y la asignación al registro",
            "facilitado en el experimento."),
      sprintf(paste("Tiempo en minutos agregado después del corte de 5",
                    "minutos: la caída del RMSE es de %+.3f dólares en el",
                    "experimento (error estándar %.3f) y de %+.3f en la base",
                    "histórica; un valor negativo es un aumento del error."),
              caida_tiempo_exp, ee_tiempo_exp, caida_tiempo_obs)
    )
  )

guardar_tabla(
  "experimento_escalera_rmse", tabla_escalera_exp,
  escalera_comparada |>
    mutate(caida_tiempo_exp = caida_tiempo_exp, ee_tiempo_exp = ee_tiempo_exp,
           caida_tiempo_obs = caida_tiempo_obs),
  carpeta_salida
)

# figura: caida del RMSE por paso en las dos bases (misma unidad: dolares)
datos_caida <- escalera_comparada |>
  filter(paso > 0) |>
  mutate(variable = factor(variable, rev(variable))) |>
  select(variable, `Datos históricos` = caida_obs, Experimento = caida_exp,
         ee_obs = ee_caida_obs, ee_exp = ee_caida_exp) |>
  pivot_longer(c(`Datos históricos`, Experimento),
               names_to = "base", values_to = "caida") |>
  mutate(ee = if_else(base == "Experimento", ee_exp, ee_obs))

grafica_caida <- ggplot(datos_caida, aes(x = caida, y = variable, fill = base)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_errorbar(aes(xmin = caida - ee, xmax = caida + ee),
                position = position_dodge(width = 0.8), width = 0.25,
                color = gris_secundario) +
  geom_vline(xintercept = 0, color = gris_secundario, linewidth = 0.4) +
  scale_fill_manual(values = c("Datos históricos" = paleta_categorica[1],
                               "Experimento" = paleta_categorica[2])) +
  scale_y_discrete(labels = function(x) str_wrap(x, 28)) +
  labs(
    title = "Cuánto reduce cada variable el error de predicción del ingreso",
    subtitle = "Datos históricos y experimento A/B. Predicción, no causalidad.",
    x = "Caída del RMSE de validación cruzada (dólares)",
    y = NULL, fill = NULL,
    caption = paste(
      sprintf("Nota: datos históricos, entrenamiento (n = 80,000); experimento, muestra completa (n = %s).",
              format(n_exp, big.mark = ",")),
      "Cada paso se agrega al modelo del paso anterior. Barras de error: ± 1 error estándar entre los 5 pliegues.",
      "El último paso es el registro en la base histórica y la asignación al registro facilitado en el experimento.",
      sep = "\n"
    )
  ) +
  tema_presentacion +
  theme(legend.position = "top",
        panel.grid.major.x = element_line(color = gris_grilla, linewidth = 0.4),
        panel.grid.major.y = element_blank(),
        axis.text.y = element_text(color = gris_texto, size = 10.5))

guardar_figura("experimento_escalera_caida_rmse.png", grafica_caida,
               carpeta_salida)

cat("\nListo. Tablas y figuras guardadas en 03_Resultados/{Tablas,Figuras}/06_ate_experimento_niveles/.\n")
cat("Recordatorio: el ITT es causal por la asignacion aleatoria; los controles solo ganan precision.\n")
