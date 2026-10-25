# =============================================================================
# Forma funcional: ln(Revenue) frente a las covariables
# Taller 2 - ECON-3785
#
# Descriptiva de la base observacional con ln(Revenue) = log(Revenue), la escala
# del Taller 2: las mismas figuras de '03_punto_partida.R' pero con el
# logaritmo del ingreso. Las diferencias se leen como cambios proporcionales
# aproximados, no como dolares. Comparar ambos scripts muestra que cambia por
# la forma funcional (aqui no hay metodo: solo medias condicionales).
#
# Puramente descriptivo: asociaciones en datos historicos (sin asignacion
# aleatoria), no efectos causales. Estimando: ninguno.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema, subtitulos por base y funcion de guardado de las figuras
source("02_Scripts/00_formato_graficas.R")
source("02_Scripts/00_formato_tablas.R")

set.seed(2026)

# subcarpeta de 03_Resultados/{Figuras,Tablas}/ de este script (nombre del script)
carpeta_salida <- "07_forma_funcional_observacional"

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds")

# en esta base is_returning_user == 1 exactamente cuando past_sessions > 0, asi
# que la figura de usuario recurrente no agrega informacion frente a la de
# sesiones pasadas: resume el contraste "0 sesiones" vs. "1 o mas"
stopifnot(all((obs$is_returning_user == 1) == (obs$past_sessions > 0)))

# -----------------------------------------------------------------------------
# 1. Parametros comunes de las figuras (ln(Revenue))
# -----------------------------------------------------------------------------

y <- "log_revenue"
etiqueta_y <- "ln(ingreso)"
nombre_eje <- paste("Promedio de", etiqueta_y)
etiqueta_x <- "Logaritmo natural del ingreso"

n_obs <- nrow(obs)
media_global <- mean(obs[[y]])
nota_referencia <- sprintf(
  "La linea punteada marca la media global de %s: %.2f.",
  etiqueta_y, media_global
)

# ln(Revenue) ya esta en logaritmo: las densidades llevan el eje x en escala
# lineal
eje_x <- scale_x_continuous()

# media del resultado por grupo con intervalo normal del 95% (n grande en todos
# los grupos); el IC solo cuantifica la incertidumbre muestral de la media
resumir_resultado <- function(datos, y) {
  datos |>
    summarise(
      n = n(),
      media = mean(.data[[y]]),
      ee = sd(.data[[y]]) / sqrt(n()),
      .groups = "drop"
    ) |>
    mutate(inferior = media - 1.96 * ee, superior = media + 1.96 * ee)
}

# -----------------------------------------------------------------------------
# 2. Tiempo en el sitio
# -----------------------------------------------------------------------------

# curva suavizada (loess) de la media del ingreso frente al tiempo, sobre todas
# las observaciones. El Taller 1 encontro un quiebre en 5 minutos: es un salto,
# y un suavizador lo redondearia, asi que la curva se ajusta por separado a
# cada lado de los 5 minutos. Sin banda de confianza: con ~85,000 usuarios a un
# lado, loess con errores estandar agota la memoria (la figura de interaccion
# si la lleva porque sus grupos son mas chicos)
grafica_tiempo <- obs |>
  mutate(lado = time_spent >= 5) |>
  ggplot(aes(x = time_spent, y = .data[[y]], group = lado)) +
  geom_hline(
    yintercept = media_global, linetype = "dashed",
    color = gris_secundario, linewidth = 0.5
  ) +
  geom_vline(
    xintercept = 5, linetype = "dotted",
    color = paleta_categorica[2], linewidth = 0.8
  ) +
  geom_smooth(
    method = "loess", formula = y ~ x, span = 0.5, se = FALSE,
    color = paleta_categorica[1], linewidth = 1
  ) +
  scale_x_log10(
    breaks = c(0.1, 1, 5, 10, 50), labels = c("0.1", "1", "5", "10", "50")
  ) +
  labs(
    title = "Ingreso promedio según el tiempo en el sitio",
    subtitle = subtitulo_observacional,
    x = "Tiempo en el sitio (minutos, escala log)",
    y = nombre_eje,
    caption = paste(
      sprintf(
        paste(
          "Nota: n = %s usuarios. Curva suavizada (loess) ajustada por",
          "separado a cada lado de los 5 minutos."
        ),
        format(n_obs, big.mark = ",")
      ),
      paste(
        nota_referencia,
        "La linea punteada ocre marca los 5 minutos (quiebre del Taller 1)."
      ),
      sep = "\n"
    )
  ) +
  tema_presentacion

guardar_figura(
  "observacional_lnrevenue_tiempo_sesion.png", grafica_tiempo, carpeta_salida
)

# -----------------------------------------------------------------------------
# 3. Sesiones pasadas
# -----------------------------------------------------------------------------

# past_sessions es un conteo (0 a 14). Los valores altos tienen muy pocos
# usuarios (de 10 en adelante hay 116 en total), asi que se agrupan en
# "10 o mas" para que los intervalos sean legibles
por_sesiones <- obs |>
  mutate(sesiones = factor(
    pmin(past_sessions, 10),
    levels = 0:10, labels = c(0:9, "10 o más")
  )) |>
  group_by(sesiones) |>
  resumir_resultado(y)

grafica_sesiones <- ggplot(por_sesiones, aes(x = sesiones, y = media)) +
  geom_hline(
    yintercept = media_global, linetype = "dashed",
    color = gris_secundario, linewidth = 0.5
  ) +
  geom_linerange(
    aes(ymin = inferior, ymax = superior),
    color = paleta_categorica[1], linewidth = 0.8
  ) +
  geom_point(color = paleta_categorica[1], size = 2.8) +
  labs(
    title = "Ingreso promedio según las sesiones anteriores",
    subtitle = subtitulo_observacional,
    x = "Sesiones anteriores del usuario", y = nombre_eje,
    caption = paste(
      sprintf(
        "Nota: n = %s usuarios. Barras: IC del 95%% de la media del grupo.",
        format(n_obs, big.mark = ",")
      ),
      sprintf(
        "Usuarios por grupo (de 0 a 10 o mas): %s.",
        paste(format(por_sesiones$n, big.mark = ",", trim = TRUE),
              collapse = ", ")
      ),
      nota_referencia,
      sep = "\n"
    )
  ) +
  tema_presentacion

guardar_figura(
  "observacional_lnrevenue_sesiones_pasadas.png", grafica_sesiones, carpeta_salida
)

# -----------------------------------------------------------------------------
# 4. Categoricas: densidad por grupo, con media y mediana
# -----------------------------------------------------------------------------

# etiquetas en espanol de las categorias
etiquetas_dispositivo <- c(
  desktop = "Computador", mobile = "Celular", tablet = "Tableta"
)
etiquetas_os <- c(osx = "macOS", windows = "Windows", other = "Otro")

# una densidad por grupo en paneles (una por fila, en vez de leyenda), con la
# media (linea continua, color del grupo) y la mediana (linea punteada gris) de cada grupo. Las cifras van escritas
# junto a su linea y el n de cada grupo en el titulo del panel, en vez de la
# nota al pie
graficar_categorica <- function(datos, columna, colores, titulo, sufijo) {
  resumen <- datos |>
    group_by(.data[[columna]]) |>
    summarise(
      n = n(), mediana = median(.data[[y]]), media = mean(.data[[y]]),
      .groups = "drop"
    ) |>
    mutate(
      grupo = .data[[columna]],
      # el n del grupo va en el titulo del panel
      panel = factor(
        paste0(grupo, " (n = ", format(n, big.mark = ",", trim = TRUE), ")"),
        levels = paste0(grupo, " (n = ", format(n, big.mark = ",", trim = TRUE), ")")
      ),
      # la etiqueta del valor menor va a la izquierda de su linea y la del
      # mayor a la derecha, para que no se superpongan cuando estan cerca
      hj_mediana = if_else(mediana <= media, 1.08, -0.08),
      hj_media = if_else(mediana <= media, -0.08, 1.08)
    )

  # cada observacion hereda el panel de su grupo para que las facetas coincidan
  datos <- datos |>
    left_join(select(resumen, all_of(columna), panel), by = columna)

  grafica <- ggplot(
    datos,
    aes(x = .data[[y]], fill = .data[[columna]], color = .data[[columna]])
  ) +
    geom_density(alpha = 0.55, linewidth = 0.8, show.legend = FALSE) +
    geom_vline(
      data = resumen, aes(xintercept = mediana),
      inherit.aes = FALSE, linetype = "dashed",
      color = gris_secundario, linewidth = 0.6
    ) +
    geom_vline(
      data = resumen, aes(xintercept = media, color = grupo),
      inherit.aes = FALSE, linewidth = 0.8, show.legend = FALSE
    ) +
    geom_text(
      data = resumen,
      aes(x = mediana, y = Inf, hjust = hj_mediana,
          label = paste0("Mediana: ", sprintf("%.2f", mediana))),
      inherit.aes = FALSE, vjust = 1.6, size = 3.4, color = gris_texto
    ) +
    geom_text(
      data = resumen,
      aes(x = media, y = Inf, hjust = hj_media, color = grupo,
          label = paste0("Media: ", sprintf("%.2f", media))),
      inherit.aes = FALSE, vjust = 3.4, size = 3.4, show.legend = FALSE
    ) +
    eje_x +
    scale_fill_manual(values = colores) +
    scale_color_manual(values = colores) +
    # espacio libre sobre la curva para que las etiquetas no la tapen
    scale_y_continuous(expand = expansion(mult = c(0, 0.45))) +
    facet_wrap(vars(panel), ncol = 1) +
    labs(
      title = titulo,
      subtitle = subtitulo_observacional,
      x = etiqueta_x, y = "Densidad",
      caption = sprintf(
        paste(
          "Nota: n = %s usuarios. Linea continua: media de %s del grupo;",
          "linea punteada gris: mediana."
        ),
        format(n_obs, big.mark = ","), etiqueta_y
      )
    ) +
    tema_presentacion +
    tema_paneles

  guardar_figura(
    paste0("observacional_lnrevenue_", sufijo, ".png"), grafica, carpeta_salida
  )
}

graficar_categorica(
  obs |> mutate(Dispositivo = factor(
    device_type,
    levels = names(etiquetas_dispositivo), labels = etiquetas_dispositivo
  )),
  "Dispositivo",
  c("Computador" = paleta_categorica[1], "Celular" = paleta_categorica[2],
    "Tableta" = paleta_categorica[3]),
  "Distribución del ingreso por tipo de dispositivo",
  "dispositivo"
)

graficar_categorica(
  obs |> mutate(Visita = factor(
    is_returning_user, levels = c(0, 1),
    labels = c("Usuario nuevo", "Usuario recurrente")
  )),
  "Visita",
  c("Usuario nuevo" = paleta_categorica[1],
    "Usuario recurrente" = paleta_categorica[2]),
  "Distribución del ingreso de usuarios nuevos y recurrentes",
  "recurrente"
)

graficar_categorica(
  obs |> mutate(SistemaOperativo = factor(
    os_type, levels = names(etiquetas_os), labels = etiquetas_os
  )),
  "SistemaOperativo",
  c("macOS" = paleta_categorica[1], "Windows" = paleta_categorica[2],
    "Otro" = paleta_categorica[3]),
  "Distribución del ingreso por sistema operativo",
  "sistema_operativo"
)

# registro: la asociacion entre sign_up y ln(Revenue) que el Taller 1 midio con
# MCO (0.102 sin controles) aqui se ve como dos distribuciones. Es una
# asociacion en datos historicos: los usuarios que se registran pueden diferir
# en otras caracteristicas (por eso el experimento, y no esta figura, es lo que
# identifica el efecto de facilitar el registro)
graficar_categorica(
  obs |> mutate(Registro = factor(
    sign_up, levels = c(0, 1), labels = c("No registrado", "Registrado")
  )),
  "Registro",
  c("No registrado" = paleta_categorica[1], "Registrado" = paleta_categorica[2]),
  "Distribución del ingreso de usuarios registrados y no registrados",
  "registro"
)

# -----------------------------------------------------------------------------
# 5. Interaccion: tiempo en el sitio segun sesiones pasadas
# -----------------------------------------------------------------------------

# las figuras anteriores muestran que tiempo y sesiones pasadas tienen un
# escalon cada una (5 minutos; entre 2 y 4 sesiones). Aqui se cruzan: la
# media frente al tiempo, con una curva por tramo de sesiones. Si las curvas
# fueran paralelas, los efectos serian aditivos; si la diferencia entre
# curvas aparece solo despues de los 5 minutos, hay una interaccion que un
# arbol puede capturar y un modelo lineal sin cruce no. Los tramos de
# sesiones salen de la figura anterior (0 a 2 | 3 | 4 o mas)
colores_tramo <- c(
  "0 a 2 sesiones" = paleta_categorica[1],
  "3 sesiones" = paleta_categorica[3],
  "4 o más sesiones" = paleta_categorica[2]
)

# sin agrupar a los usuarios: una curva suavizada (loess) por tramo de
# sesiones, sobre todas las observaciones. El quiebre de los 5 minutos es un
# salto, y un suavizador lo redondearia; por eso la curva se ajusta por
# separado a cada lado de los 5 minutos. La banda es el IC del 95% de la curva
datos_cruce <- obs |>
  mutate(
    tramo = cut(
      past_sessions, breaks = c(-Inf, 2, 3, Inf),
      labels = names(colores_tramo)
    ),
    lado = time_spent >= 5
  )
n_tramo <- count(datos_cruce, tramo)

grafica_cruce <- ggplot(
  datos_cruce,
  aes(x = time_spent, y = .data[[y]], color = tramo, fill = tramo,
      group = interaction(tramo, lado))
) +
  geom_hline(
    yintercept = media_global, linetype = "dashed",
    color = gris_secundario, linewidth = 0.5
  ) +
  geom_vline(
    xintercept = 5, linetype = "dotted",
    color = gris_nota, linewidth = 0.8
  ) +
  geom_smooth(
    method = "loess", formula = y ~ x, span = 0.5, level = 0.95,
    linewidth = 1, alpha = 0.2
  ) +
  scale_color_manual(values = colores_tramo) +
  scale_fill_manual(values = colores_tramo) +
  scale_x_log10(
    breaks = c(0.1, 1, 5, 50), labels = c("0.1", "1", "5", "50")
  ) +
  coord_cartesian(xlim = c(0.1, 25)) +
  labs(
    title = "Ingreso promedio según tiempo en el sitio y sesiones anteriores",
    subtitle = subtitulo_observacional,
    x = "Tiempo en el sitio (minutos, escala log)",
    y = nombre_eje,
    color = NULL, fill = NULL,
    caption = paste(
      sprintf(
        "Nota: n = %s usuarios (%s).",
        format(n_obs, big.mark = ","),
        paste0(n_tramo$tramo, " ",
               format(n_tramo$n, big.mark = ",", trim = TRUE),
               collapse = ", ")
      ),
      paste(
        "Curvas suavizadas (loess) ajustadas por separado a cada lado de los",
        "5 minutos; bandas: IC del 95%."
      ),
      paste(
        nota_referencia,
        "La linea punteada gris vertical marca los 5 minutos."
      ),
      sep = "\n"
    )
  ) +
  tema_presentacion +
  theme(legend.position = "top")

guardar_figura(
  "observacional_lnrevenue_tiempo_por_sesiones.png", grafica_cruce, carpeta_salida
)

# -----------------------------------------------------------------------------
# 8. Distribucion del ingreso: dolares frente a logaritmo
# -----------------------------------------------------------------------------

# Que cambia al pasar de Revenue a ln(Revenue) en la variable misma: la forma de
# la distribucion. Es el argumento para la transformacion (heuristica H4) y la
# base para leer despues los coeficientes como cambios proporcionales.
asimetria <- function(x) mean((x - mean(x))^3) / sd(x)^3
curtosis <- function(x) mean((x - mean(x))^4) / sd(x)^4

# figura: dos paneles con la misma muestra. Cada panel marca media y mediana; en
# el de logaritmo se superpone la normal con la misma media y desviacion para
# ver cuanto se aleja la distribucion de la simetria
dist_dolares <- tibble(
  panel = "Ingreso en dólares", x = obs$Revenue,
  media = mean(obs$Revenue), mediana = median(obs$Revenue)
)
dist_log <- tibble(
  panel = "Logaritmo natural del ingreso", x = obs$log_revenue,
  media = mean(obs$log_revenue), mediana = median(obs$log_revenue)
)
datos_dist <- bind_rows(dist_dolares, dist_log) |>
  mutate(panel = factor(panel, c("Ingreso en dólares",
                                 "Logaritmo natural del ingreso")))
resumen_dist <- datos_dist |>
  distinct(panel, media, mediana)

normal_log <- tibble(
  x = seq(min(obs$log_revenue), max(obs$log_revenue), length.out = 300)
) |>
  mutate(
    densidad = dnorm(x, mean(obs$log_revenue), sd(obs$log_revenue)),
    panel = factor("Logaritmo natural del ingreso",
                   levels(datos_dist$panel))
  )

grafica_distribucion <- ggplot(datos_dist, aes(x = x)) +
  geom_density(
    fill = paleta_categorica[1], color = paleta_categorica[1],
    alpha = 0.55, linewidth = 0.8
  ) +
  geom_line(
    data = normal_log, aes(y = densidad), color = paleta_categorica[2],
    linewidth = 0.8, linetype = "longdash"
  ) +
  geom_vline(
    data = resumen_dist, aes(xintercept = mediana), linetype = "dashed",
    color = gris_secundario, linewidth = 0.6
  ) +
  geom_vline(
    data = resumen_dist, aes(xintercept = media), color = gris_texto,
    linewidth = 0.8
  ) +
  geom_text(
    data = resumen_dist,
    aes(x = media, y = Inf, label = paste0("Media: ", sprintf("%.2f", media))),
    hjust = -0.1, vjust = 1.6, size = 3.4, color = gris_texto
  ) +
  geom_text(
    data = resumen_dist,
    aes(x = mediana, y = Inf,
        label = paste0("Mediana: ", sprintf("%.2f", mediana))),
    hjust = 1.1, vjust = 3.4, size = 3.4, color = gris_secundario
  ) +
  facet_wrap(~panel, scales = "free") +
  # espacio a la izquierda para que las etiquetas no se corten
  scale_x_continuous(expand = expansion(mult = c(0.35, 0.05))) +
  labs(
    title = "El ingreso tiene cola derecha larga; su logaritmo es mucho más simétrico",
    subtitle = subtitulo_observacional,
    x = NULL, y = "Densidad",
    caption = paste(
      sprintf("Nota: n = %s usuarios.", format(n_obs, big.mark = ",")),
      paste(
        "Línea continua: media. Línea punteada gris: mediana. Línea ocre:",
        "distribución normal con la misma media y desviación estándar que el",
        "logaritmo del ingreso."
      ),
      sep = "\n"
    )
  ) +
  tema_presentacion +
  tema_paneles

guardar_figura(
  "observacional_distribucion_ingreso_dos_escalas.png", grafica_distribucion,
  carpeta_salida
)

# tabla de forma de la distribucion en cada escala. Los cuantiles de ln(Revenue)
# son el logaritmo de los cuantiles de Revenue (el logaritmo es monotono), por
# eso mediana y percentiles coinciden entre escalas; la media no
cuantiles <- c(0.01, 0.10, 0.25, 0.50, 0.75, 0.90, 0.99)
resumir_escala <- function(x) {
  c(
    Media = mean(x), `Desviación estándar` = sd(x), Asimetría = asimetria(x),
    Curtosis = curtosis(x),
    setNames(quantile(x, cuantiles), paste0("p", cuantiles * 100))
  )
}
distribucion <- tibble(
  estadistico = names(resumir_escala(obs$Revenue)),
  dolares = unname(resumir_escala(obs$Revenue)),
  logaritmo = unname(resumir_escala(obs$log_revenue))
) |>
  mutate(
    estadistico = recode(
      estadistico, p1 = "Percentil 1", p10 = "Percentil 10",
      p25 = "Percentil 25", p50 = "Mediana", p75 = "Percentil 75",
      p90 = "Percentil 90", p99 = "Percentil 99"
    ),
    # percentiles del logaritmo, tambien llevados a dolares con exp()
    logaritmo_en_dolares = if_else(
      estadistico %in% c("Percentil 1", "Percentil 10", "Percentil 25",
                         "Mediana", "Percentil 75", "Percentil 90",
                         "Percentil 99"),
      exp(logaritmo), NA_real_
    )
  )

tabla_distribucion <- distribucion |>
  gt() |>
  cols_label(
    estadistico = "Estadístico",
    dolares = "Ingreso (dólares)",
    logaritmo = "Logaritmo del ingreso",
    logaritmo_en_dolares = "Logaritmo llevado a dólares con exp()"
  ) |>
  fmt_number(c(dolares, logaritmo, logaritmo_en_dolares), decimals = 2) |>
  sub_missing(missing_text = "—") |>
  estilo_tabla(
    titulo = "El logaritmo reduce la asimetría y la cola derecha",
    subtitulo = "Forma de la distribución del ingreso por usuario en cada escala",
    nota = nota_tabla(
      "observacional", n_obs,
      extra = c(
        paste(
          "Asimetría y curtosis: una distribución simétrica tiene asimetría 0;",
          "la normal, curtosis 3. Los percentiles del logaritmo, llevados a",
          "dólares con exp(), recuperan los percentiles del ingreso; la media",
          "no se recupera así."
        )
      )
    )
  )

guardar_tabla(
  "observacional_distribucion_ingreso", tabla_distribucion, distribucion,
  carpeta_salida
)

# puente entre medias: exp(media del logaritmo) es la media geometrica, que
# queda por debajo de la media aritmetica en dolares. Su cociente es el factor
# de smearing de Duan (promedio de exp(residuo)) del modelo sin covariables, y
# es lo que hay que multiplicar para volver de la escala log al promedio en
# dolares. Con una distribucion normal en log, el factor seria exp(var / 2)
media_log <- mean(obs$log_revenue)
puente <- tibble(
  concepto = c(
    "Media en dólares (media aritmética)",
    "Mediana en dólares",
    "exp(media del logaritmo) = media geométrica",
    "Factor de corrección (media aritmética / media geométrica)",
    "Factor si el logaritmo fuera normal: exp(varianza / 2)"
  ),
  valor = c(
    mean(obs$Revenue), median(obs$Revenue), exp(media_log),
    mean(obs$Revenue) / exp(media_log), exp(var(obs$log_revenue) / 2)
  ),
  unidad = c("dólares", "dólares", "dólares", "razón", "razón")
)

tabla_puente <- puente |>
  gt() |>
  cols_label(concepto = "Cifra", valor = "Valor", unidad = "Unidad") |>
  fmt_number(valor, decimals = 3) |>
  estilo_tabla(
    titulo = "Volver de logaritmo a dólares exige un factor de corrección",
    subtitulo = "La media geométrica subestima el ingreso promedio en dólares",
    nota = nota_tabla(
      "observacional", n_obs,
      extra = paste(
        "El factor de corrección es el de Duan (smearing) del modelo sin",
        "covariables. Que difiera de exp(varianza / 2) indica que el",
        "logaritmo no es exactamente normal (asimetría y curtosis en la tabla",
        "de distribución)."
      )
    )
  )

guardar_tabla(
  "observacional_puente_media_dolares", tabla_puente, puente, carpeta_salida
)

# -----------------------------------------------------------------------------
# 9. Punto de partida: cifras clave del Taller 1
# -----------------------------------------------------------------------------

# Cierra el punto de partida. La columna del Taller 1 son las cifras reportadas
# alla (el repositorio taller1/ no esta en este proyecto, asi que se transcriben
# de CLAUDE.md, "Punto de partida"); la del Taller 2 es lo que reproduce este
# proyecto con las mismas bases y la misma particion (80/20, semilla 2026). El
# RMSE sale del script 04 (corre antes); lo demas se calcula aqui, para que la
# tabla no dependa de scripts posteriores
rmse_t2 <- read_csv(
  "03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_rmse_prueba_lineal.csv",
  show_col_types = FALSE
)
rmse_lineal <- rmse_t2 |> filter(str_detect(modelo, "^Lineal del Taller 1"))
rmse_ingenuo <- rmse_t2 |> filter(str_detect(modelo, "^Referencia ingenua"))

exp_datos <- readRDS("01_Datos/03_Listos/experimento_listos.RDS")
n_exp <- nrow(exp_datos)

# ITT sin controles = diferencia de medias entre tratados y controles
itt <- function(y) {
  unname(coef(lm(reformulate("easier_signup", y), data = exp_datos))["easier_signup"])
}
# salto de nivel del ingreso en dolares entre usuarios con 5 minutos o mas y con
# menos de 5 (diferencia de medias simple, sin controles)
salto_5 <- function(datos) {
  m <- tapply(datos$Revenue, datos$time_spent >= 5, mean)
  unname(m["TRUE"] - m["FALSE"])
}

punto_partida <- tribble(
  ~tema, ~cifra, ~escala, ~base, ~taller1, ~taller2,
  "Predicción", "RMSE de la referencia ingenua", "Dólares", "Histórica",
    2.716, rmse_ingenuo$rmse_prueba,
  "Predicción", "RMSE del lineal del Taller 1", "Dólares", "Histórica",
    2.314, rmse_lineal$rmse_prueba,
  "Predicción", "Mejora del lineal frente a la ingenua (%)", "Porcentaje",
    "Histórica", 14.8, rmse_lineal$mejora_ingenuo_pct,
  "Efecto del registro", "ITT sin controles", "Dólares", "Experimento",
    0.49, itt("Revenue"),
  "Efecto del registro", "ITT sin controles", "Logaritmo", "Experimento",
    0.0134, itt("log_revenue"),
  "Efecto del registro", "ITT con controles", "Logaritmo", "Experimento",
    0.0042, NA_real_,
  "Quiebre en 5 minutos", "Salto del ingreso promedio", "Dólares", "Histórica",
    3.13, salto_5(obs),
  "Quiebre en 5 minutos", "Salto del ingreso promedio", "Dólares", "Experimento",
    3.42, salto_5(exp_datos)
)

tabla_punto_partida <- punto_partida |>
  gt(groupname_col = "tema") |>
  cols_label(
    cifra = "Cifra", escala = "Escala", base = "Base",
    taller1 = "Taller 1", taller2 = "Reproducido en el Taller 2"
  ) |>
  fmt_number(c(taller1, taller2), rows = escala == "Porcentaje", decimals = decimales$porcentaje) |>
  fmt_number(c(taller1, taller2), rows = escala == "Dólares", decimals = decimales$dolares) |>
  # el RMSE va con los decimales de RMSE, aunque este en dolares
  fmt_number(c(taller1, taller2), rows = str_detect(cifra, "^RMSE"), decimals = decimales$rmse) |>
  fmt_number(c(taller1, taller2), rows = escala == "Logaritmo", decimals = 4) |>
  sub_missing(missing_text = "—") |>
  estilo_tabla(
    titulo = "El Taller 1 deja tres resultados como punto de partida",
    subtitulo = "Error de predicción, efecto del registro y quiebre en 5 minutos",
    nota = nota_tabla(
      "observacional", n_obs,
      extra = c(
        sprintf(
          "Experimento A/B: n = %s. ITT: efecto de la asignación a registro facilitado.",
          format(n_exp, big.mark = ",")
        ),
        paste(
          "RMSE de la muestra de prueba (20%); en dólares, no comparable con",
          "un RMSE en logaritmo. Las cifras del Taller 1 son las reportadas allá."
        ),
        paste(
          "El salto del Taller 2 es la diferencia simple de medias entre 5",
          "minutos o más y menos de 5; el Taller 1 lo estimó con otro",
          "procedimiento. El ITT con controles no se reproduce aquí porque los",
          "controles del Taller 2 son otros (ver el script 08)."
        )
      )
    )
  )

guardar_tabla(
  "observacional_punto_partida_taller1", tabla_punto_partida, punto_partida,
  carpeta_salida
)

cat("\nListo. Resultados guardados en 03_Resultados/{Figuras,Tablas}/07_forma_funcional_observacional/.\n")
cat("Recordatorio: son asociaciones descriptivas, no efectos causales.\n")
