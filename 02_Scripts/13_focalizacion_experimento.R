# =============================================================================
# Focalizacion del registro facilitado: efecto por celda dispositivo x sistema
# operativo, valor de las reglas y conciliacion entre dolares y logaritmo
# Taller 2 - ECON-3785 (Parte B)
#
# Estimando principal: el CATE de easier_signup sobre ln(Revenue) en cada celda
# dispositivo x sistema operativo, leido como exp(tau) - 1 (cambio porcentual
# del gasto del usuario tipico de la celda). Complemento etiquetado: el mismo
# efecto en dolares por usuario. Solo el experimento sostiene esta lectura.
# Estimador: bosque causal de grf (2,000 arboles honestos, las 5 covariables
# del script 12), W.hat = mean(W) (asignacion aleatoria con probabilidad comun;
# Lab 10). Efecto de una celda: average_treatment_effect(cf, subset = celda).
#
# Disenio:
#   - Regla final (decision del 2026-10-25): registro facilitado para todos,
#     salvo celulares con Windows u otro sistema operativo. Criterio: excluir
#     solo donde hay dano distinguible de cero en las dos escalas.
#   - Multiplicidad y sesgo de seleccion de la regla, como en el Lab 10: el
#     experimento se parte en dos mitades por usuario; un bosque estimado en la
#     mitad de entrenamiento elige las celdas a tratar (efecto > 0) y otro,
#     estimado solo en la mitad de evaluacion, mide el valor de cada regla:
#     peso(S) x average_treatment_effect(cf_eva, subset = S), con peso(S) la
#     participacion de las celdas S en la base historica. La diferencia entre
#     dos reglas anidadas es el efecto en las celdas en que difieren.
#   - Celdas con menos de 100 observaciones en alguna mitad se marcan y no
#     sostienen conclusiones de focalizacion.
#   - Conciliacion: identidad ATE = promedio de los efectos por celda; lo que
#     explican los efectos proporcionales y el gasto base de cada celda
#     (gasto medio del control x (exp(tau) - 1)) con la particion
#     dispositivo x SO y con la fina dispositivo x SO x tramo de sesiones
#     (celdas con n >= 100); el resto ocurre dentro de las celdas.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema y funcion de guardado de las figuras; estilo de las tablas
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "13_focalizacion_experimento"

n_arboles <- 2000
n_hilos <- 4
n_minimo <- 100

etiqueta_dispositivo <- c(desktop = "Computador", mobile = "Celular", tablet = "Tableta")
etiqueta_so <- c(osx = "osx", windows = "Windows", other = "Otro SO")

preparar <- function(d) {
  d |>
    mutate(
      tramo_sesiones = case_when(
        past_sessions <= 2 ~ "0 a 2 sesiones",
        past_sessions <= 4 ~ "3 a 4 sesiones",
        TRUE ~ "5 o más sesiones"
      ),
      celda_so = paste(etiqueta_dispositivo[as.character(device_type)],
                       etiqueta_so[as.character(os_type)], sep = "–"),
      celda_ses = paste(etiqueta_dispositivo[as.character(device_type)],
                        tramo_sesiones, sep = "–"),
      celda_fina = paste(celda_so, tramo_sesiones, sep = "–")
    )
}

experimento <- readRDS("01_Datos/03_Listos/experimento_listos.RDS") |> preparar()
historica <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds") |> preparar()
n_exp <- nrow(experimento)

# particion en dos mitades por usuario (Lab 10), antes de cualquier otro paso
# aleatorio para que sea la misma en todas las tablas
set.seed(2026)
idx_ent <- sample(n_exp, n_exp / 2)
idx_eva <- setdiff(seq_len(n_exp), idx_ent)
ent <- experimento[idx_ent, ]
eva <- experimento[idx_eva, ]

# celdas excluidas por la regla final
celdas_excluidas <- c("Celular–Windows", "Celular–Otro SO")

# -----------------------------------------------------------------------------
# 1. Bosques causales (muestra completa y mitades)
# -----------------------------------------------------------------------------

matriz_x <- function(d) {
  model.matrix(~ time_spent + past_sessions + device_type + is_returning_user +
                 os_type, d)[, -1]
}
X <- matriz_x(experimento)
W <- experimento$easier_signup

# W.hat fijo en la proporcion tratada de la muestra que recibe el bosque
estimar_bosque <- function(X, Y, W) {
  causal_forest(X, Y, W, W.hat = mean(W), num.trees = n_arboles, seed = 2026,
                num.threads = n_hilos)
}

cf_log <- estimar_bosque(X, experimento$log_revenue, W)
cf_niv <- estimar_bosque(X, experimento$Revenue, W)

ate <- function(cf, subset = NULL) {
  a <- average_treatment_effect(cf, subset = subset)
  tibble(estimacion = unname(a["estimate"]), error_estandar = unname(a["std.err"]))
}

# lectura log-lin: cambio porcentual del gasto del usuario tipico
pct <- function(x) 100 * (exp(x) - 1)

peso_historico <- function(var) {
  historica |> count(celda = .data[[var]]) |> mutate(pct_historica = 100 * n / sum(n)) |>
    select(celda, pct_historica)
}

tamano_mitades <- function(var, celdas) {
  tibble(
    celda = celdas,
    n_ent = map_int(celdas, ~ sum(ent[[var]] == .x)),
    n_eva = map_int(celdas, ~ sum(eva[[var]] == .x))
  ) |>
    mutate(pequena = pmin(n_ent, n_eva) < n_minimo)
}

# efecto de cada celda de una particion en la muestra completa, en las dos
# escalas, con el gasto medio del grupo control de la celda
efecto_celdas <- function(var) {
  celdas <- sort(unique(experimento[[var]]))
  map_dfr(celdas, function(c) {
    en_celda <- experimento[[var]] == c
    d <- experimento[en_celda, ]
    bind_cols(
      tibble(celda = c, n = sum(en_celda), peso_exp = mean(en_celda),
             gasto_control = mean(d$Revenue[d$easier_signup == 0])),
      ate(cf_log, subset = en_celda) |> rename(tau_log = estimacion, ee_log = error_estandar),
      ate(cf_niv, subset = en_celda) |> rename(tau_dolares = estimacion,
                                               ee_dolares = error_estandar)
    )
  }) |>
    left_join(peso_historico(var), by = "celda") |>
    left_join(tamano_mitades(var, celdas), by = "celda") |>
    mutate(
      particion = var,
      log_inf = tau_log - qnorm(0.975) * ee_log,
      log_sup = tau_log + qnorm(0.975) * ee_log,
      dolares_inf = tau_dolares - qnorm(0.975) * ee_dolares,
      dolares_sup = tau_dolares + qnorm(0.975) * ee_dolares,
      dolares_implicados = gasto_control * (exp(tau_log) - 1)
    )
}

# -----------------------------------------------------------------------------
# 2. Efecto por celda dispositivo x sistema operativo
# -----------------------------------------------------------------------------

celdas_so <- efecto_celdas("celda_so") |>
  mutate(tratada = !celda %in% celdas_excluidas)

# contraste transparente: MCO saturado por celda con errores HC1 (diferencia
# de medias dentro de cada celda)
mco_celda <- function(y) {
  m <- feols(as.formula(paste(y, "~ 0 + celda_so + celda_so:easier_signup")),
             data = experimento, vcov = "hc1")
  b <- coef(m)
  nombres <- grep(":easier_signup$", names(b), value = TRUE)
  tibble(celda = sub("^celda_so(.*):easier_signup$", "\\1", nombres),
         estimacion = unname(b[nombres]))
}
celdas_so <- celdas_so |>
  left_join(mco_celda("log_revenue") |> rename(mco_log = estimacion), by = "celda") |>
  left_join(mco_celda("Revenue") |> rename(mco_dolares = estimacion), by = "celda")

print(celdas_so, width = Inf)

texto_ic <- function(inf, sup, formato) sprintf(paste0("[", formato, "; ", formato, "]"), inf, sup)

tabla_celdas <- function(datos, titulo, subtitulo, con_mco = FALSE) {
  datos |>
    arrange(desc(tau_log)) |>
    mutate(
      grupo = if_else(pequena, paste0(celda, " *"), celda),
      n_txt = sprintf("%s (%s / %s)", format(n, big.mark = ","), n_ent, n_eva),
      log_txt = sprintf("%+.1f%%", pct(tau_log)),
      log_ic = texto_ic(pct(log_inf), pct(log_sup), "%+.1f%%"),
      dol_txt = sprintf("%+.2f", tau_dolares),
      dol_ic = texto_ic(dolares_inf, dolares_sup, "%+.2f"),
      mco_txt = if (con_mco) sprintf("%+.1f%% / %+.2f", pct(mco_log), mco_dolares) else NA
    ) |>
    select(grupo, n_txt, pct_historica, log_txt, log_ic, dol_txt, dol_ic,
           any_of(if (con_mco) "mco_txt" else character()),
           any_of(if ("tratada" %in% names(datos)) "tratada" else character())) |>
    mutate(across(any_of("tratada"), ~ if_else(.x, "Sí", "No"))) |>
    gt() |>
    cols_label(
      grupo = "Grupo", n_txt = "Usuarios (entren. / eval.)",
      pct_historica = "% de la base histórica",
      log_txt = "Efecto", log_ic = "Intervalo del 95%",
      dol_txt = "Efecto", dol_ic = "Intervalo del 95%"
    ) |>
    tab_spanner("Gasto del usuario típico (%)", c(log_txt, log_ic)) |>
    tab_spanner("Dólares por usuario", c(dol_txt, dol_ic)) |>
    fmt_number(pct_historica, decimals = decimales$porcentaje) |>
    (\(t) if (con_mco) cols_label(t, mco_txt = "MCO (% / dólares)") else t)() |>
    (\(t) if ("tratada" %in% names(datos)) cols_label(t, tratada = "Recibe el registro facilitado") else t)() |>
    estilo_tabla(
      titulo = titulo, subtitulo = subtitulo,
      nota = nota_tabla(
        "experimento", n_exp,
        extra = c(
          paste(
            "Efecto de cada grupo: promedio doblemente robusto de los efectos",
            "individuales del grupo (bosque causal de 2,000 árboles, probabilidad",
            "de asignación fija en la proporción tratada). Gasto del usuario típico:",
            "cambio porcentual exp(efecto en logaritmo) − 1, estimando principal.",
            "Dólares: complemento que mide el peso del grupo en el ingreso total."
          ),
          if (con_mco) paste(
            "MCO: diferencia de medias dentro de cada grupo (regresión con",
            "interacciones y errores robustos HC1), como contraste."
          ),
          paste(
            "Usuarios entre paréntesis: mitad de entrenamiento / mitad de",
            "evaluación. * Menos de 100 usuarios en alguna mitad: no sostiene",
            "conclusiones de focalización."
          ),
          sprintf(
            "%% de la base histórica: participación del grupo en los datos históricos (n = %s).",
            format(nrow(historica), big.mark = ",")
          )
        )
      )
    )
}

guardar_tabla(
  "experimento_efecto_celdas_dispositivo_so",
  tabla_celdas(
    celdas_so,
    titulo = "El registro facilitado baja el gasto solo en celulares con Windows u otro sistema operativo",
    subtitulo = "Efecto del registro facilitado por dispositivo y sistema operativo",
    con_mco = TRUE
  ),
  celdas_so |> select(celda, n, n_ent, n_eva, pequena, pct_historica, gasto_control,
                      tau_log, ee_log, log_inf, log_sup, tau_dolares, ee_dolares,
                      dolares_inf, dolares_sup, mco_log, mco_dolares, tratada),
  carpeta_salida
)

# figura: puntos con su intervalo, dos paneles (gasto del usuario tipico en %
# y dolares por usuario), color segun la regla final
datos_figura <- bind_rows(
  celdas_so |> transmute(celda, tratada, pequena, escala = "Gasto del usuario típico (%)",
                         estimacion = pct(tau_log), inf = pct(log_inf), sup = pct(log_sup)),
  celdas_so |> transmute(celda, tratada, pequena, escala = "Dólares por usuario",
                         estimacion = tau_dolares, inf = dolares_inf, sup = dolares_sup)
) |>
  mutate(
    escala = factor(escala, c("Gasto del usuario típico (%)", "Dólares por usuario")),
    celda = factor(celda, celdas_so$celda[order(celdas_so$tau_log)]),
    regla = case_when(
      pequena ~ "Menos de 100 usuarios por mitad",
      tratada ~ "Recibe el registro facilitado",
      TRUE ~ "Se mantiene el formulario actual"
    )
  )

grafica_celdas <- ggplot(datos_figura, aes(x = estimacion, y = celda, color = regla)) +
  geom_vline(xintercept = 0, color = gris_secundario, linewidth = 0.4) +
  geom_errorbar(aes(xmin = inf, xmax = sup), width = 0, linewidth = 0.8,
                orientation = "y") +
  geom_point(size = 2.4) +
  facet_wrap(~ escala, scales = "free_x") +
  scale_color_manual(values = c(
    "Recibe el registro facilitado" = paleta_categorica[1],
    "Se mantiene el formulario actual" = paleta_categorica[2],
    "Menos de 100 usuarios por mitad" = gris_nota
  )) +
  labs(
    title = "Efecto del registro facilitado por dispositivo y sistema operativo",
    subtitle = subtitulo_experimento,
    x = "Efecto (izquierda: cambio % del gasto del usuario típico; derecha: dólares por usuario)",
    y = NULL, color = NULL,
    caption = paste(
      sprintf("Nota: n = %s usuarios; el tamaño de cada grupo está en la tabla del efecto por grupo.",
              format(n_exp, big.mark = ",")),
      "Puntos: efecto del grupo estimado con el bosque causal (muestra completa). Barras: intervalo del 95%.",
      "Línea continua gris: cero. Color: grupo que recibe o no el registro facilitado según la regla recomendada.",
      sep = "\n"
    )
  ) +
  tema_presentacion +
  tema_paneles +
  theme(
    legend.position = "bottom",
    axis.text.y = element_text(color = gris_texto),
    axis.text.x = element_text(size = 10, face = "plain"),
    panel.grid.major.x = element_line(color = gris_grilla, linewidth = 0.4),
    panel.grid.major.y = element_blank()
  )

guardar_figura("experimento_efecto_celdas_dispositivo_so.png", grafica_celdas, carpeta_salida)

# -----------------------------------------------------------------------------
# 3. Efecto por celda dispositivo x tramo de sesiones (apendice)
# -----------------------------------------------------------------------------

celdas_ses <- efecto_celdas("celda_ses")
print(celdas_ses, width = Inf)

guardar_tabla(
  "experimento_efecto_celdas_dispositivo_sesiones",
  tabla_celdas(
    celdas_ses,
    titulo = "En celular el efecto es negativo en los tres tramos de sesiones anteriores",
    subtitulo = "Efecto del registro facilitado por dispositivo y sesiones anteriores"
  ),
  celdas_ses |> select(celda, n, n_ent, n_eva, pequena, pct_historica, gasto_control,
                       tau_log, ee_log, log_inf, log_sup, tau_dolares, ee_dolares,
                       dolares_inf, dolares_sup),
  carpeta_salida
)

# -----------------------------------------------------------------------------
# 4. Reglas: se eligen en una mitad y se evaluan en la otra (Lab 10)
# -----------------------------------------------------------------------------

peso_de <- function(var, celdas) {
  sum(peso_historico(var)$pct_historica[peso_historico(var)$celda %in% celdas]) / 100
}

evaluar_reglas <- function(y, escala) {
  cf_ent <- estimar_bosque(X[idx_ent, ], y[idx_ent], W[idx_ent])
  cf_eva <- estimar_bosque(X[idx_eva, ], y[idx_eva], W[idx_eva])

  # celdas que elige la mitad de entrenamiento (efecto > 0, sin celdas pequenas)
  elegir <- function(var) {
    tam <- tamano_mitades(var, sort(unique(experimento[[var]])))
    map_dfr(tam$celda, ~ ate(cf_ent, subset = ent[[var]] == .x) |> mutate(celda = .x)) |>
      left_join(tam, by = "celda") |>
      filter(estimacion > 0, !pequena) |>
      pull(celda)
  }
  todas_so <- sort(unique(experimento$celda_so))
  todas_ses <- sort(unique(experimento$celda_ses))
  reglas <- list(
    list("Todos los usuarios", "celda_so", todas_so),
    list("Recomendada: todos salvo celulares con Windows u otro SO", "celda_so",
         setdiff(todas_so, celdas_excluidas)),
    list("Solo computador y tableta", "celda_so",
         todas_so[!startsWith(todas_so, "Celular")]),
    list("Elegida en entrenamiento: dispositivo × sistema operativo", "celda_so",
         elegir("celda_so")),
    list("Elegida en entrenamiento: dispositivo × sesiones", "celda_ses",
         elegir("celda_ses")),
    list("Solo 3 o más sesiones anteriores", "celda_ses",
         todas_ses[!str_detect(todas_ses, "0 a 2")])
  )

  valor <- map_dfr(reglas, function(r) {
    en_S <- eva[[r[[2]]]] %in% r[[3]]
    ate(cf_eva, subset = en_S) |>
      mutate(tipo = "Valor frente a no dar el registro facilitado a nadie",
             regla = r[[1]], celdas = paste(r[[3]], collapse = "; "),
             peso = peso_de(r[[2]], r[[3]]), n_eva = sum(en_S))
  })

  # diferencias entre reglas anidadas: efecto de las celdas en que difieren
  diferencia <- function(nombre, var, D) {
    en_D <- eva[[var]] %in% D
    ate(cf_eva, subset = en_D) |>
      mutate(tipo = "Diferencia entre reglas (celdas en que difieren)",
             regla = nombre, celdas = paste(D, collapse = "; "),
             peso = peso_de(var, D), n_eva = sum(en_D))
  }
  difs <- bind_rows(
    diferencia("Recomendada − solo computador y tableta", "celda_so", "Celular–osx"),
    diferencia("Todos − recomendada", "celda_so", celdas_excluidas),
    diferencia("Todos − solo 3 o más sesiones", "celda_ses",
               todas_ses[str_detect(todas_ses, "0 a 2")])
  )

  bind_rows(valor, difs) |>
    mutate(
      escala = escala,
      valor = peso * estimacion, ee_valor = peso * error_estandar,
      valor_inf = valor - qnorm(0.975) * ee_valor,
      valor_sup = valor + qnorm(0.975) * ee_valor
    )
}

reglas_tabla <- bind_rows(
  evaluar_reglas(experimento$log_revenue, "Logaritmo del ingreso"),
  evaluar_reglas(experimento$Revenue, "Ingreso en dólares")
) |>
  # una regla elegida en entrenamiento puede elegir celdas distintas en cada
  # escala: entonces son dos reglas y se nombran por la escala que las eligio
  group_by(regla) |>
  mutate(distintas = n_distinct(celdas) > 1) |>
  ungroup() |>
  mutate(regla = if_else(
    distintas,
    paste0(regla, if_else(escala == "Logaritmo del ingreso",
                          " (elegida con el logaritmo)", " (elegida con dólares)")),
    regla
  )) |>
  select(-distintas)
print(reglas_tabla |> select(escala, tipo, regla, peso, n_eva, valor, ee_valor),
      n = Inf, width = Inf)

# la regla que elige la mitad de entrenamiento debe coincidir con la
# recomendada (salvo la celda pequena, que la elegida no puede incluir)
elegida_so <- reglas_tabla |>
  filter(escala == "Logaritmo del ingreso",
         regla == "Elegida en entrenamiento: dispositivo × sistema operativo") |>
  pull(celdas)
cat("Celdas elegidas en entrenamiento (logaritmo):", elegida_so, "\n")

tabla_reglas <- reglas_tabla |>
  mutate(
    escala = if_else(escala == "Ingreso en dólares", "niv", "log"),
    texto = if_else(
      escala == "log",
      sprintf("%+.1f%% %s", pct(valor), texto_ic(pct(valor_inf), pct(valor_sup), "%+.1f%%")),
      sprintf("%+.3f %s", valor, texto_ic(valor_inf, valor_sup, "%+.3f"))
    )
  ) |>
  select(tipo, regla, peso, n_eva, escala, texto) |>
  pivot_wider(names_from = escala, values_from = texto) |>
  mutate(peso = 100 * peso, tipo = factor(tipo, unique(tipo))) |>
  gt(groupname_col = "tipo") |>
  cols_label(
    regla = "Regla", peso = "% de la base histórica", n_eva = "Usuarios (evaluación)",
    log = "Gasto del usuario típico (%)", niv = "Dólares por usuario"
  ) |>
  fmt_number(peso, decimals = decimales$porcentaje) |>
  sub_missing(missing_text = "—") |>
  estilo_tabla(
    titulo = "Excluir solo a los celulares con Windows u otro sistema operativo da el mayor ingreso",
    subtitulo = "Valor de cada regla en la mitad de evaluación, por usuario de la base histórica",
    nota = c(
      sprintf(
        paste(
          "Datos del experimento A/B (asignación aleatoria), mitad de evaluación",
          "(n = %s). Las reglas \"elegidas\" las fija un bosque estimado con la",
          "otra mitad (n = %s); el valor lo mide un bosque estimado solo con la",
          "mitad de evaluación."
        ),
        format(length(idx_eva), big.mark = ","), format(length(idx_ent), big.mark = ",")
      ),
      paste(
        "Valor de una regla: participación en la base histórica de los grupos que",
        "reciben el registro facilitado × efecto promedio en esos grupos (cero para",
        "los demás). Gasto del usuario típico: exp(valor en logaritmo) − 1, estimando",
        "principal; dólares, complemento."
      ),
      paste(
        "Diferencia entre reglas: el efecto en los grupos que una regla trata y la",
        "otra no, por su participación. Intervalos del 95%. —: la regla se eligió",
        "con la otra escala."
      )
    )
  )

guardar_tabla("experimento_valor_reglas", tabla_reglas,
              reglas_tabla |> select(escala, tipo, regla, celdas, peso, n_eva,
                                     estimacion, error_estandar, valor, ee_valor,
                                     valor_inf, valor_sup),
              carpeta_salida)

# -----------------------------------------------------------------------------
# 5. Conciliacion entre dolares y logaritmo
# -----------------------------------------------------------------------------

gasto_control_total <- mean(experimento$Revenue[experimento$easier_signup == 0])
ate_log <- ate(cf_log)$estimacion
ate_niv <- ate(cf_niv)$estimacion

# particion fina: solo celdas con n >= 100; poblacion cubierta por ellas
celdas_finas <- efecto_celdas("celda_fina")
cubiertas <- celdas_finas$celda[celdas_finas$n >= n_minimo]
en_cubierta <- experimento$celda_fina %in% cubiertas
gruesas_cubiertas <- map_dfr(sort(unique(experimento$celda_so[en_cubierta])), function(c) {
  g <- en_cubierta & experimento$celda_so == c
  d <- experimento[g, ]
  tibble(n = sum(g), gasto_control = mean(d$Revenue[d$easier_signup == 0]),
         tau_log = ate(cf_log, subset = g)$estimacion)
})
implicado <- function(n, gasto, tau) sum(n * gasto * (exp(tau) - 1)) / sum(n)
finas_cubiertas <- celdas_finas |> filter(n >= n_minimo)

ate_cubierta <- ate(cf_niv, subset = en_cubierta)$estimacion
impl_so_cub <- implicado(gruesas_cubiertas$n, gruesas_cubiertas$gasto_control,
                         gruesas_cubiertas$tau_log)
impl_fino <- implicado(finas_cubiertas$n, finas_cubiertas$gasto_control, finas_cubiertas$tau_log)

conciliacion <- tribble(
  ~bloque, ~concepto, ~valor, ~unidad,
  "Todos los usuarios", "Efecto promedio en logaritmo (bosque)", ate_log, "log",
  "Todos los usuarios", "Promedio de los efectos por grupo dispositivo × SO", sum(celdas_so$peso_exp * celdas_so$tau_log), "log",
  "Todos los usuarios", "Grupos con efecto positivo en logaritmo (% de usuarios)", 100 * sum(celdas_so$peso_exp[celdas_so$tau_log > 0]), "%",
  "Todos los usuarios", "Gasto base de los grupos con efecto positivo", weighted.mean(celdas_so$gasto_control[celdas_so$tau_log > 0], celdas_so$n[celdas_so$tau_log > 0]), "dólares",
  "Todos los usuarios", "Gasto base de los grupos con efecto negativo", weighted.mean(celdas_so$gasto_control[celdas_so$tau_log <= 0], celdas_so$n[celdas_so$tau_log <= 0]), "dólares",
  "Todos los usuarios", "Efecto promedio en dólares (bosque)", ate_niv, "dólares",
  "Todos los usuarios", "Promedio de los efectos por grupo dispositivo × SO", sum(celdas_so$peso_exp * celdas_so$tau_dolares), "dólares",
  "Todos los usuarios", "Implicado por el efecto proporcional de cada grupo, con un gasto base común", gasto_control_total * sum(celdas_so$peso_exp * (exp(celdas_so$tau_log) - 1)), "dólares",
  "Todos los usuarios", "Implicado por el efecto proporcional de cada grupo, con su propio gasto base", sum(celdas_so$peso_exp * celdas_so$dolares_implicados), "dólares",
  "Usuarios en grupos finos con 100 o más", "Usuarios cubiertos", sum(en_cubierta), "usuarios",
  "Usuarios en grupos finos con 100 o más", "Efecto promedio en dólares (bosque)", ate_cubierta, "dólares",
  "Usuarios en grupos finos con 100 o más", "Implicado con grupos dispositivo × SO", impl_so_cub, "dólares",
  "Usuarios en grupos finos con 100 o más", "Implicado con grupos dispositivo × SO × sesiones", impl_fino, "dólares",
  "Usuarios en grupos finos con 100 o más", "Resto dentro de los grupos dispositivo × SO", ate_cubierta - impl_so_cub, "dólares",
  "Usuarios en grupos finos con 100 o más", "Resto dentro de los grupos finos (cota superior de la transformación)", ate_cubierta - impl_fino, "dólares",
  "Usuarios en grupos finos con 100 o más", "Parte del resto que absorben las sesiones (%)", 100 * (impl_fino - impl_so_cub) / (ate_cubierta - impl_so_cub), "%"
)
print(conciliacion, n = Inf, width = Inf)

tabla_conciliacion <- conciliacion |>
  mutate(
    texto = case_when(
      unidad == "log" ~ sprintf("%.4f", valor),
      unidad == "dólares" ~ sprintf("%.2f", valor),
      unidad == "%" ~ sprintf("%.1f%%", valor),
      TRUE ~ format(round(valor), big.mark = ",")
    ),
    bloque = factor(bloque, unique(bloque))
  ) |>
  select(bloque, concepto, texto, unidad) |>
  gt(groupname_col = "bloque") |>
  cols_label(concepto = "Concepto", texto = "Valor", unidad = "Unidad") |>
  estilo_tabla(
    titulo = "Por qué el efecto es casi cero en logaritmo y positivo en dólares",
    subtitulo = "Efectos por grupo, gasto base del grupo control y resto dentro de los grupos",
    nota = nota_tabla(
      "experimento", n_exp,
      extra = c(
        paste(
          "Los efectos de signo opuesto entre grupos se cancelan en logaritmo: el",
          "promedio de los efectos por grupo reproduce el efecto promedio (el",
          "efecto promedio es el promedio de los efectos individuales)."
        ),
        paste(
          "Implicado: gasto medio del grupo control × (exp(efecto en logaritmo) − 1),",
          "promediado con el peso de cada grupo. Lo que el efecto en dólares supera",
          "a lo implicado ocurre dentro de los grupos: el registro facilitado sube la",
          "media en dólares más de lo que mueve el gasto del usuario típico."
        ),
        paste(
          "Grupos finos: dispositivo × sistema operativo × sesiones anteriores (0 a 2,",
          "3 a 4, 5 o más), solo los de 100 usuarios o más. El resto dentro de ellos",
          "es una cota superior de lo atribuible a la transformación: puede incluir",
          "diferencias por otras características, como el tiempo en el sitio."
        )
      )
    )
  )

guardar_tabla("experimento_conciliacion_celdas", tabla_conciliacion, conciliacion,
              carpeta_salida)

cat("\nListo. Resultados guardados en 03_Resultados/{Figuras,Tablas}/13_focalizacion_experimento/.\n")
