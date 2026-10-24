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
      "experimento", n_exp,
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

cat("\nListo. Tablas guardadas en 03_Resultados/Tablas/06_ate_experimento_niveles/.\n")
cat("Recordatorio: el ITT es causal por la asignacion aleatoria; los controles solo ganan precision.\n")
