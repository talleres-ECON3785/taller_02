# =============================================================================
# Efecto del registro facilitado sobre ln(Revenue) y regreso a dolares
# Taller 2 - ECON-3785 (Parte B)
#
# Estimando: ITT de easier_signup sobre ln(Revenue) (cambio proporcional de la
# media geometrica del ingreso) y su relacion con el ITT en dolares del
# script 06 (diferencia de medias aritmeticas). Solo el experimento (asignacion
# aleatoria) sostiene una lectura causal. Estimador: MCO con errores estandar
# robustos HC1, sin controles y con los controles del script 06.
#
# Por que no basta con exp(coeficiente): el coeficiente en logaritmo mide el
# cambio de la media de ln(Revenue); para volver a dolares hay que multiplicar
# por el factor de smearing de Duan de cada grupo, y ese factor depende de la
# dispersion. Si el tratamiento cambia la dispersion, un factor comun a los dos
# grupos deshace el efecto en dolares. Este script mide ambas partes.
#
# El ATE con bosque causal y los CATE van en scripts posteriores.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema y funcion de guardado de las figuras; estilo de las tablas
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

set.seed(2026)

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "08_ate_experimento_log"

exp <- readRDS("01_Datos/03_Listos/experimento_listos.RDS") |>
  # mismo indicador del quiebre que en 04 y 06
  mutate(mas_5_min = as.integer(time_spent > 5))

n_exp <- nrow(exp)
stopifnot(all(exp$Revenue > 0))

formula_controles <- ~ easier_signup + mas_5_min + past_sessions +
  mas_5_min:past_sessions + device_type + os_type + is_returning_user

# -----------------------------------------------------------------------------
# 1. ITT en ln(Revenue): sin y con controles
# -----------------------------------------------------------------------------

# modelo simple: el coeficiente es la diferencia de medias de ln(Revenue); como
# solo hay una variable binaria, exp(coeficiente) es exactamente el cociente de
# medias geometricas (tratamiento / control)
log_simple <- lm(log_revenue ~ easier_signup, data = exp)
log_controles <- update(log_simple, update(formula_controles, log_revenue ~ .))

# mismos modelos en dolares que el script 06, para poner las dos escalas lado a
# lado
niv_simple <- lm(Revenue ~ easier_signup, data = exp)
niv_controles <- update(niv_simple, update(formula_controles, Revenue ~ .))

media_control <- mean(exp$Revenue[exp$easier_signup == 0])
media_tratado <- mean(exp$Revenue[exp$easier_signup == 1])

filas_extra <- tibble(
  term = "Controles",
  `Sin controles` = "No",
  `Con controles` = "Sí"
)
attr(filas_extra, "position") <- 3

tabla_itt_log <- modelsummary(
  list("Sin controles" = log_simple, "Con controles" = log_controles),
  vcov = "HC1",
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  statistic = "({std.error})",
  coef_map = c("easier_signup" = "Registro facilitado (efecto en logaritmo)"),
  gof_map = list(
    list(raw = "nobs", clean = "Observaciones",
         fmt = function(x) format(x, big.mark = ",")),
    list(raw = "r.squared", clean = "R²", fmt = 3)
  ),
  add_rows = filas_extra,
  fmt = 4,
  output = "gt"
) |>
  estilo_tabla(
    titulo = "En logaritmo, el registro facilitado casi no mueve el ingreso",
    subtitulo = "Efecto de la asignación sobre el logaritmo del ingreso, MCO",
    nota = nota_tabla(
      "experimento", NULL,
      extra = c(
        paste(
          "Errores estándar robustos (HC1) entre paréntesis. Un coeficiente de",
          "0.01 equivale a un cambio de alrededor de 1% en el ingreso de un",
          "usuario típico (media geométrica), no en el ingreso promedio."
        ),
        paste(
          "Controles: los del script de la escala en dólares (más de 5",
          "minutos, sesiones anteriores y su cruce, dispositivo, sistema",
          "operativo y usuario recurrente)."
        )
      )
    )
  )

guardar_tabla(
  "experimento_ols_registro_log", tabla_itt_log,
  bind_rows(
    get_estimates(log_simple, vcov = "HC1") |> mutate(modelo = "Sin controles"),
    get_estimates(log_controles, vcov = "HC1") |> mutate(modelo = "Con controles")
  ) |>
    filter(term == "easier_signup"),
  carpeta_salida
)

# -----------------------------------------------------------------------------
# 2. Del coeficiente en logaritmo al efecto en dolares
# -----------------------------------------------------------------------------

# Con el modelo ln(Y) = X b + e, el ingreso esperado es E[Y | X] = exp(X b) *
# E[exp(e) | X]. El factor E[exp(e)] se estima con el promedio de exp(residuo)
# (smearing de Duan, 1983). Dos formas de retransformar:
#   (a) un factor comun a los dos grupos (la practica habitual): supone que la
#       dispersion de e no depende del tratamiento
#   (b) un factor por grupo: no lo supone
retransformar <- function(modelo) {
  b <- coef(modelo)[["easier_signup"]]
  residuos <- resid(modelo)
  smear_comun <- mean(exp(residuos))
  smear_grupo <- tapply(exp(residuos), exp$easier_signup, mean)

  # contrafactuales de cada usuario: se apaga y se prende easier_signup en la
  # misma fila y se promedia la diferencia en dolares
  d0 <- mutate(exp, easier_signup = 0)
  d1 <- mutate(exp, easier_signup = 1)
  y0_log <- predict(modelo, newdata = d0)
  y1_log <- predict(modelo, newdata = d1)

  tibble(
    smear_control = smear_grupo[["0"]],
    smear_tratado = smear_grupo[["1"]],
    smear_comun = smear_comun,
    efecto_dolares_comun = mean(exp(y1_log) * smear_comun -
                                  exp(y0_log) * smear_comun),
    efecto_dolares_grupo = mean(exp(y1_log) * smear_grupo[["1"]] -
                                  exp(y0_log) * smear_grupo[["0"]])
  )
}

ret_simple <- retransformar(log_simple)
ret_controles <- retransformar(log_controles)

# efecto directo en dolares (script 06) con su IC de 95% (HC1)
ic_dolares <- function(modelo, nivel = 0.95) {
  est <- get_estimates(modelo, vcov = "HC1", conf_level = nivel) |>
    filter(term == "easier_signup")
  c(est = est$estimate, inf = est$conf.low, sup = est$conf.high)
}
dol_simple <- ic_dolares(niv_simple)
dol_controles <- ic_dolares(niv_controles)
ic_log_simple <- get_estimates(log_simple, vcov = "HC1") |>
  filter(term == "easier_signup")
ic_log_controles <- get_estimates(log_controles, vcov = "HC1") |>
  filter(term == "easier_signup")

# la cifra de dolares del modelo simple por retransformacion con factor por
# grupo debe coincidir con la diferencia de medias (identidad exacta)
stopifnot(abs(ret_simple$efecto_dolares_grupo - dol_simple[["est"]]) < 1e-8)

puente_log <- tibble(
  fila = c(
    "Coeficiente en logaritmo (efecto en la media del logaritmo)",
    "Cambio porcentual en el ingreso del usuario típico: exp(coef) − 1",
    "Efecto en dólares si se retransforma con un factor común",
    "Efecto en dólares si se retransforma con un factor por grupo",
    "Efecto en dólares estimado directamente (diferencia de medias / MCO)",
    "Cambio porcentual en el ingreso promedio (efecto directo / media del control)"
  ),
  sin_controles = c(
    ic_log_simple$estimate,
    100 * (exp(ic_log_simple$estimate) - 1),
    ret_simple$efecto_dolares_comun,
    ret_simple$efecto_dolares_grupo,
    dol_simple[["est"]],
    100 * dol_simple[["est"]] / media_control
  ),
  con_controles = c(
    ic_log_controles$estimate,
    100 * (exp(ic_log_controles$estimate) - 1),
    ret_controles$efecto_dolares_comun,
    ret_controles$efecto_dolares_grupo,
    dol_controles[["est"]],
    100 * dol_controles[["est"]] / media_control
  ),
  unidad = c("log", "%", "dólares", "dólares", "dólares", "%")
)

tabla_puente_log <- puente_log |>
  gt() |>
  cols_label(
    fila = "Cifra", sin_controles = "Sin controles",
    con_controles = "Con controles", unidad = "Unidad"
  ) |>
  fmt_number(c(sin_controles, con_controles), decimals = 3) |>
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_body(rows = c(5, 6))
  ) |>
  estilo_tabla(
    titulo = "Con un factor común, el efecto en dólares casi desaparece",
    subtitulo = "Del efecto en logaritmo al efecto en dólares del registro facilitado",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = c(
        paste(
          "Factor de corrección (smearing de Duan): promedio de exp(residuo).",
          "Con un factor común a los dos grupos se supone que el tratamiento no",
          "cambia la dispersión del logaritmo; con un factor por grupo no. Sin",
          "controles, la retransformación por grupo reproduce exactamente la",
          "diferencia de medias."
        ),
        paste(
          "Con controles, el modelo en logaritmo impone el mismo efecto",
          "proporcional a todos los usuarios; que la retransformación por grupo",
          "quede lejos del efecto directo indica que ese supuesto no se",
          "sostiene (el efecto proporcional difiere entre usuarios)."
        ),
        sprintf(
          "Promedio del grupo de control: %.3f dólares; del grupo tratado: %.3f.",
          media_control, media_tratado
        )
      )
    )
  )

guardar_tabla(
  "experimento_log_a_dolares", tabla_puente_log, puente_log, carpeta_salida
)

# -----------------------------------------------------------------------------
# 3. Descomposicion: media geometrica y dispersion
# -----------------------------------------------------------------------------

# Sin controles, el cambio proporcional de la media aritmetica se descompone
# exactamente: media1 / media0 = [media geom 1 / media geom 0] * [smearing 1 /
# smearing 0]. El primer factor es exp(coef) (el usuario tipico); el segundo
# recoge cuanto cambia la dispersion de ln(Revenue) entre grupos.
grupo <- exp |>
  group_by(easier_signup) |>
  summarise(
    n = n(), media = mean(Revenue), media_log = mean(log_revenue),
    media_geom = exp(media_log), sd_log = sd(log_revenue),
    smearing = mean(exp(log_revenue - media_log)), .groups = "drop"
  )
g0 <- filter(grupo, easier_signup == 0)
g1 <- filter(grupo, easier_signup == 1)
factor_geom <- g1$media_geom / g0$media_geom
factor_disp <- g1$smearing / g0$smearing
stopifnot(abs(factor_geom * factor_disp - g1$media / g0$media) < 1e-10)

# la diferencia de dispersion se prueba con una regresion auxiliar: el cuadrado
# del residuo respecto a la media de su grupo, sobre el tratamiento (HC1). Es
# la diferencia de varianzas de ln(Revenue) entre grupos con su error estandar.
exp <- exp |>
  mutate(
    dev2_log = (log_revenue - ave(log_revenue, easier_signup))^2
  )
aux_var <- get_estimates(
  lm(dev2_log ~ easier_signup, data = exp), vcov = "HC1"
) |>
  filter(term == "easier_signup")

descomposicion <- tibble(
  concepto = c(
    "Cociente de medias aritméticas (tratado / control)",
    "  Factor de la media geométrica: exp(coef)",
    "  Factor de la dispersión: smearing tratado / smearing control",
    "Desviación estándar del logaritmo, control",
    "Desviación estándar del logaritmo, tratado",
    "Diferencia de varianzas del logaritmo (tratado − control)",
    "  Error estándar (HC1)"
  ),
  valor = c(
    g1$media / g0$media, factor_geom, factor_disp, g0$sd_log, g1$sd_log,
    aux_var$estimate, aux_var$std.error
  )
)

tabla_descomposicion <- descomposicion |>
  gt() |>
  cols_label(concepto = "Cifra", valor = "Valor") |>
  fmt_number(valor, decimals = 3) |>
  estilo_tabla(
    titulo = "El efecto promedio en dólares viene de la dispersión, no del usuario típico",
    subtitulo = "Descomposición del cociente de medias del registro facilitado",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = paste(
        "Cociente de medias = factor de la media geométrica × factor de la",
        "dispersión (identidad exacta, sin controles). La diferencia de",
        "varianzas sale de una regresión del cuadrado de la desviación de",
        "cada usuario respecto a la media del logaritmo de su grupo sobre el",
        "tratamiento."
      )
    )
  )

guardar_tabla(
  "experimento_descomposicion_media", tabla_descomposicion, descomposicion,
  carpeta_salida
)

# -----------------------------------------------------------------------------
# 4. Donde se produce la diferencia: cuantiles y cola
# -----------------------------------------------------------------------------

# diferencia de cuantiles por grupo: descriptiva y sin intervalos (calcularlos
# con remuestreo no esta en el catalogo de metodos). Con asignacion aleatoria,
# cada diferencia estima el efecto del tratamiento en ese cuantil de la
# distribucion marginal.
niveles <- c(0.05, 0.10, 0.25, 0.50, 0.75, 0.90, 0.95, 0.99)
cuant_grupo <- function(x) quantile(x, niveles, names = FALSE)
cuantiles <- tibble(
  cuantil = paste0("Percentil ", niveles * 100),
  control = cuant_grupo(exp$Revenue[exp$easier_signup == 0]),
  tratado = cuant_grupo(exp$Revenue[exp$easier_signup == 1])
) |>
  mutate(
    cuantil = if_else(cuantil == "Percentil 50", "Mediana", cuantil),
    diferencia = tratado - control,
    cambio_pct = 100 * (tratado / control - 1),
    diferencia_log = log(tratado) - log(control)
  )

tabla_cuantiles <- cuantiles |>
  gt() |>
  cols_label(
    cuantil = "Posición en la distribución", control = "Control (dólares)",
    tratado = "Registro facilitado (dólares)", diferencia = "Diferencia (dólares)",
    cambio_pct = "Cambio (%)", diferencia_log = "Diferencia en logaritmo"
  ) |>
  fmt_number(c(control, tratado, diferencia), decimals = 2) |>
  fmt_number(cambio_pct, decimals = 1) |>
  fmt_number(diferencia_log, decimals = 3) |>
  estilo_tabla(
    titulo = "El efecto aparece en las colas, no en el centro",
    subtitulo = "Ingreso por usuario en cada grupo según su posición en la distribución",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = paste(
        "Cada fila compara los mismos percentiles de los dos grupos (control:",
        sprintf("%s usuarios; tratado: %s).",
                format(g0$n, big.mark = ","), format(g1$n, big.mark = ",")),
        "No incluye intervalos de confianza."
      )
    )
  )

guardar_tabla(
  "experimento_cuantiles_por_grupo", tabla_cuantiles, cuantiles, carpeta_salida
)

# efecto en dolares al limitar el ingreso de los usuarios mas altos al percentil
# 95 o 99 (comun a los dos grupos). Mide cuanto del efecto promedio depende de
# la cola, no es el efecto de ninguna intervencion
limitar <- function(corte) {
  tope <- quantile(exp$Revenue, corte, names = FALSE)
  datos <- mutate(exp, y = pmin(Revenue, tope))
  est <- get_estimates(lm(y ~ easier_signup, datos), vcov = "HC1") |>
    filter(term == "easier_signup")
  tibble(
    ingreso_maximo = tope, efecto = est$estimate,
    inferior = est$conf.low, superior = est$conf.high
  )
}
cola <- bind_rows(
  tibble(escenario = "Sin limitar", ingreso_maximo = max(exp$Revenue),
         efecto = dol_simple[["est"]], inferior = dol_simple[["inf"]],
         superior = dol_simple[["sup"]]),
  limitar(0.99) |> mutate(escenario = "Ingreso limitado al percentil 99"),
  limitar(0.95) |> mutate(escenario = "Ingreso limitado al percentil 95")
)

tabla_cola <- cola |>
  gt() |>
  cols_label(
    escenario = "Escenario", ingreso_maximo = "Ingreso máximo (dólares)",
    efecto = "Efecto (dólares)", inferior = "Límite inferior",
    superior = "Límite superior"
  ) |>
  fmt_number(c(ingreso_maximo, efecto, inferior, superior), decimals = 3) |>
  estilo_tabla(
    titulo = "Gran parte del efecto promedio depende de los usuarios de mayor gasto",
    subtitulo = "Efecto en dólares del registro facilitado al limitar el ingreso máximo",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = c(
        paste(
          "MCO con errores estándar robustos (HC1); intervalo del 95%. Los",
          "percentiles se calculan con los dos grupos juntos."
        ),
        paste(
          "Limitar el ingreso es una medida de descripción: no es el efecto",
          "de la intervención sobre ninguna población."
        )
      )
    )
  )

guardar_tabla("experimento_efecto_cola", tabla_cola, cola, carpeta_salida)

# -----------------------------------------------------------------------------
# 5. Figura: distribucion del logaritmo del ingreso por grupo
# -----------------------------------------------------------------------------

colores <- c("Control" = paleta_categorica[1],
             "Registro facilitado" = paleta_categorica[2])
datos_fig <- exp |>
  mutate(grupo = factor(easier_signup, c(0, 1), names(colores)))
resumen_fig <- datos_fig |>
  group_by(grupo) |>
  summarise(media = mean(log_revenue), mediana = median(log_revenue),
            n = n(), .groups = "drop")

grafica_grupos <- ggplot(
  datos_fig, aes(x = log_revenue, fill = grupo, color = grupo)
) +
  geom_density(alpha = 0.55, linewidth = 0.8) +
  geom_vline(
    data = resumen_fig, aes(xintercept = mediana), linetype = "dashed",
    color = gris_secundario, linewidth = 0.6
  ) +
  geom_vline(
    data = resumen_fig, aes(xintercept = media, color = grupo), linewidth = 0.8,
    show.legend = FALSE
  ) +
  # eje en logaritmo con las etiquetas en dolares: el eje muestra ln(Revenue)
  # y cada marca dice a cuantos dolares corresponde
  scale_x_continuous(
    breaks = log(c(1, 2, 3, 5, 10, 20, 40)),
    labels = c("1", "2", "3", "5", "10", "20", "40")
  ) +
  scale_fill_manual(values = colores) +
  scale_color_manual(values = colores) +
  labs(
    title = "El registro facilitado ensancha la distribución del ingreso",
    subtitle = subtitulo_experimento,
    x = "Ingreso por usuario (dólares, escala log)", y = "Densidad",
    fill = NULL, color = NULL,
    caption = paste(
      sprintf(
        "Nota: n = %s (control: %s; registro facilitado: %s).",
        format(n_exp, big.mark = ","),
        format(resumen_fig$n[1], big.mark = ","),
        format(resumen_fig$n[2], big.mark = ",")
      ),
      paste(
        "Línea continua: media del logaritmo de cada grupo. Línea punteada",
        "gris: mediana."
      ),
      sep = "\n"
    )
  ) +
  tema_presentacion +
  theme(legend.position = "top")

guardar_figura(
  "experimento_distribucion_lnrevenue_por_grupo.png", grafica_grupos,
  carpeta_salida
)

cat("\nListo. Resultados guardados en 03_Resultados/{Figuras,Tablas}/08_ate_experimento_log/.\n")
cat("Recordatorio: efectos del experimento (ITT); los cuantiles son descriptivos.\n")
