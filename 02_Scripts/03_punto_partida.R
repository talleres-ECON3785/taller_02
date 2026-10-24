# =============================================================================
# Punto de partida: Revenue en nivel frente a las covariables
# Taller 2 - ECON-3785
#
# Descriptiva de la base observacional con Revenue en nivel (dolares), la escala
# del Taller 1: como varia el ingreso con time_spent, past_sessions,
# device_type, os_type e is_returning_user (heuristica H3). Es el punto de
# partida del Taller 2; el mismo analisis en logaritmo esta en
# '06_forma_funcional_observacional.R'.
#
# Las secciones 1 a 3 (figuras) son puramente descriptivas: asociaciones en
# datos historicos (sin asignacion aleatoria), no efectos causales. Estimando:
# ninguno; se describe la media condicional del ingreso dada cada covariable.
# La ultima seccion si estima un efecto causal, con el experimento: MCO del
# ingreso sobre el tratamiento solo (ver el encabezado de esa seccion).
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema, subtitulos por base y funcion de guardado de las figuras
source("02_Scripts/00_formato_graficas.R")
# estilo y exportacion de las tablas (guardar_tabla())
source("02_Scripts/00_formato_tablas.R")

set.seed(2026)

# subcarpeta de 03_Resultados/Figuras/ de este script (nombre del script)
carpeta_salida <- "03_punto_partida"

obs <- readRDS("01_Datos/03_Listos/observacional_limpio.Rds")

# en esta base is_returning_user == 1 exactamente cuando past_sessions > 0, asi
# que la figura de usuario recurrente no agrega informacion frente a la de
# sesiones pasadas: resume el contraste "0 sesiones" vs. "1 o mas"
stopifnot(all((obs$is_returning_user == 1) == (obs$past_sessions > 0)))

# -----------------------------------------------------------------------------
# 1. Parametros comunes de las figuras (Revenue en nivel, dolares)
# -----------------------------------------------------------------------------

y <- "Revenue"
etiqueta_y <- "ingreso (dólares)"
nombre_eje <- paste("Promedio de", etiqueta_y)
etiqueta_x <- "Ingreso (dólares, escala log)"

n_obs <- nrow(obs)
media_global <- mean(obs[[y]])
nota_referencia <- sprintf(
  "La linea punteada marca la media global de %s: %.2f.",
  etiqueta_y, media_global
)

# Revenue tiene cola larga: las densidades llevan el eje x en escala log
# (convencion del proyecto)
eje_x <- scale_x_log10(breaks = c(1, 2, 5, 10, 20, 50))

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
  "observacional_revenue_tiempo_sesion.png", grafica_tiempo, carpeta_salida
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
  "observacional_revenue_sesiones_pasadas.png", grafica_sesiones, carpeta_salida
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
    paste0("observacional_revenue_", sufijo, ".png"), grafica, carpeta_salida
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
  "observacional_revenue_tiempo_por_sesiones.png", grafica_cruce, carpeta_salida
)

# -----------------------------------------------------------------------------
# Efecto causal del registro: MCO sencillo con el experimento
# -----------------------------------------------------------------------------

# Estimando: ITT de easier_signup (registro facilitado) sobre el ingreso en
# dolares (escala del Taller 1). Estimador: MCO con el tratamiento como unico
# regresor, sin controles, y errores estandar robustos HC1. Solo el experimento
# sostiene una lectura causal (asignacion aleatoria); en la base observacional
# la misma regresion seria una asociacion.
exp <- readRDS("01_Datos/03_Listos/experimento_listos.RDS")

# cumplimiento perfecto: sign_up coincide con easier_signup en todas las filas
# (nadie asignado al tratamiento dejo de registrarse y nadie en control se
# registro), asi que el ITT es tambien el efecto de registrarse (LATE = ITT)
cumplimiento <- exp |>
  count(easier_signup, sign_up) |>
  mutate(easier_signup = factor(easier_signup, c(0, 1),
                                c("Control", "Registro facilitado")))
print(cumplimiento)
stopifnot(
  all(exp$sign_up == exp$easier_signup),
  nrow(cumplimiento) == 2 # solo las celdas (0, 0) y (1, 1)
)

ols_registro <- lm(Revenue ~ easier_signup, data = exp)

tabla_ols <- modelsummary(
  list("Ingreso (dólares)" = ols_registro),
  vcov = "HC1",
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  statistic = "({std.error})",
  coef_map = c(
    "easier_signup" = "Registro facilitado (efecto)",
    "(Intercept)"   = "Promedio del grupo de control"
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
    titulo = "Efecto del registro facilitado sobre el ingreso",
    subtitulo = "MCO con el tratamiento como único regresor (dólares)",
    nota = nota_tabla(
      "experimento", nrow(exp),
      extra = c(
        paste(
          "Errores estándar robustos (HC1) entre paréntesis. El efecto es la",
          "diferencia de medias entre grupos, en dólares. Sin controles."
        ),
        paste(
          "Cumplimiento perfecto: todos los usuarios asignados al registro",
          "facilitado se registraron y ninguno del control lo hizo."
        )
      )
    )
  )

guardar_tabla(
  "experimento_ols_registro", tabla_ols,
  get_estimates(ols_registro, vcov = "HC1"), carpeta_salida
)

cat("\nListo. Figuras y tablas guardadas en 03_Resultados/{Figuras,Tablas}/03_punto_partida/.\n")
cat("Recordatorio: las figuras son asociaciones descriptivas; solo la tabla del MCO viene del experimento.\n")
