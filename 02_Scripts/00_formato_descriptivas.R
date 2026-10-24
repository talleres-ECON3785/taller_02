# =============================================================================
# Funciones compartidas de la descriptiva de la base observacional
# Taller 2 - ECON-3785
#
# Este script NO genera figuras por si mismo: define las funciones que usan
# '03_punto_de_partida_observacional.R' (Revenue en nivel) y
# '04_forma_funcional_observacional.R' (ln(Revenue)) para dibujar exactamente
# las mismas figuras en las dos escalas. Asi las dos partes solo difieren en la
# variable de resultado y la comparacion es limpia.
#
# Uso: source("02_Scripts/00_formato_descriptivas.R") despues de cargar
# 'observacional_limpio.Rds'. Requiere el formato de las graficas.
# =============================================================================

# los paquetes los carga 00_main.R con pacman

# paleta, tema, subtitulos por base y funcion de guardado de las figuras
source("02_Scripts/00_formato_graficas.R")

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 1. Funcion auxiliar: media del resultado con intervalo de confianza del 95%
# -----------------------------------------------------------------------------

# intervalo normal para la media (n grande en todos los grupos); el IC solo
# cuantifica la incertidumbre muestral de la media de cada grupo
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
# 2. Funcion que dibuja y guarda las cuatro figuras para un resultado
# -----------------------------------------------------------------------------

# `obs` es la base observacional limpia, `carpeta` es la subcarpeta de salida del script que la llama; `y` es la columna del resultado ("Revenue" o "log_revenue"), `prefijo` va en
# el nombre del archivo ("revenue" o "lnrevenue"), `etiqueta_y` es el nombre
# del eje en espanol. Si `eje_log` es TRUE (Revenue en nivel), las densidades
# llevan el eje x en escala logaritmica por su cola larga (convencion del
# proyecto); ln(Revenue) ya esta en logaritmo y va en escala lineal
graficar_covariables <- function(obs, y, prefijo, etiqueta_y, carpeta,
                                 eje_log = FALSE) {
  n_obs <- nrow(obs)
  media_global <- mean(obs[[y]])
  nota_referencia <- sprintf(
    "La linea punteada marca la media global de %s: %.2f.",
    etiqueta_y, media_global
  )
  nombre_eje <- paste("Promedio de", etiqueta_y)

  # eje x de las densidades (el resultado va en horizontal)
  eje_x <- if (eje_log) {
    scale_x_log10(breaks = c(1, 2, 5, 10, 20, 50))
  } else {
    scale_x_continuous()
  }
  etiqueta_x <- if (eje_log) paste(etiqueta_y, "(escala log)") else etiqueta_y

  # --- Tiempo en el sitio ----------------------------------------------------

  # time_spent es continua y de cola larga: se agrupa en 50 cuantiles (2,000
  # usuarios cada uno) y se grafica la media por grupo contra la mediana del
  # tiempo del grupo. Los cuantiles dan grupos del mismo tamano y, por eso,
  # intervalos comparables a lo largo del eje. El Taller 1 encontro un quiebre
  # en 5 minutos; se marca para ver si aparece tambien en esta escala
  n_grupos_tiempo <- 50

  por_tiempo <- obs |>
    mutate(grupo = ntile(time_spent, n_grupos_tiempo)) |>
    group_by(grupo) |>
    mutate(tiempo_mediano = median(time_spent)) |>
    group_by(grupo, tiempo_mediano) |>
    resumir_resultado(y)

  grafica_tiempo <- ggplot(por_tiempo, aes(x = tiempo_mediano, y = media)) +
    geom_hline(
      yintercept = media_global, linetype = "dashed",
      color = gris_secundario, linewidth = 0.5
    ) +
    geom_vline(
      xintercept = 5, linetype = "dotted",
      color = paleta_categorica[2], linewidth = 0.8
    ) +
    geom_linerange(
      aes(ymin = inferior, ymax = superior),
      color = paleta_categorica[1], linewidth = 0.6
    ) +
    geom_point(color = paleta_categorica[1], size = 2.2) +
    annotate(
      "text", x = 5.4, y = min(por_tiempo$inferior), label = "5 minutos",
      hjust = 0, vjust = 0, color = paleta_categorica[2], size = 3.6
    ) +
    scale_x_log10(
      breaks = c(0.01, 0.1, 1, 5, 10, 50),
      labels = c("0.01", "0.1", "1", "5", "10", "50")
    ) +
    labs(
      title = "Ingreso promedio según el tiempo en el sitio",
      subtitle = subtitulo_observacional,
      x = "Tiempo en el sitio en minutos (mediana de cada grupo, escala log)",
      y = nombre_eje,
      caption = paste(
        sprintf(
          paste(
            "Nota: n = %s usuarios, en %d grupos de igual tamano segun su",
            "tiempo en el sitio. Barras: IC del 95%% de la media del grupo."
          ),
          format(n_obs, big.mark = ","), n_grupos_tiempo
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
    paste0("observacional_", prefijo, "_tiempo_sesion.png"), grafica_tiempo,
    carpeta
  )

  # --- Sesiones pasadas ------------------------------------------------------

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
    paste0("observacional_", prefijo, "_sesiones_pasadas.png"),
    grafica_sesiones, carpeta
  )

  # --- Categoricas: densidad por grupo, con el resultado en horizontal -------

  # igual que en el Taller 1: una densidad por grupo en paneles (una por fila,
  # en vez de leyenda) y la mediana de cada grupo en linea punteada gris. Las
  # medias de cada grupo con su IC estan en las figuras de tiempo y sesiones;
  # aqui se muestra la forma completa de la distribucion
  graficar_categorica <- function(datos, columna, colores, titulo, sufijo) {
    resumen <- datos |>
      group_by(.data[[columna]]) |>
      summarise(n = n(), mediana = median(.data[[y]]), .groups = "drop")
    # la tabla de medianas conserva el nombre de la variable de los paneles:
    # asi ggplot dibuja en cada panel solo la mediana de su grupo
    nombres_grupo <- as.character(resumen[[columna]])

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
      eje_x +
      scale_fill_manual(values = colores) +
      scale_color_manual(values = colores) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
      facet_wrap(vars(.data[[columna]]), ncol = 1) +
      labs(
        title = titulo,
        subtitle = subtitulo_observacional,
        x = etiqueta_x, y = "Densidad",
        caption = paste(
          sprintf(
            "Nota: n = %s usuarios (%s).",
            format(n_obs, big.mark = ","),
            paste0(
              nombres_grupo, " ",
              format(resumen$n, big.mark = ",", trim = TRUE), collapse = ", "
            )
          ),
          sprintf(
            "La linea punteada marca la mediana de %s de cada grupo: %s.",
            etiqueta_y,
            paste0(nombres_grupo, " ", sprintf("%.2f", resumen$mediana),
                   collapse = ", ")
          ),
          sep = "\n"
        )
      ) +
      tema_presentacion +
      tema_paneles

    guardar_figura(paste0("observacional_", prefijo, "_", sufijo, ".png"), grafica,
      carpeta
    )
  }

  # --- Dispositivo -----------------------------------------------------------

  etiquetas_dispositivo <- c(
    desktop = "Computador", mobile = "Celular", tablet = "Tableta"
  )

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

  # --- Usuario recurrente ----------------------------------------------------

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

  # --- Sistema operativo -----------------------------------------------------

  etiquetas_os <- c(osx = "macOS", windows = "Windows", other = "Otro")

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

  # --- Interaccion: tiempo en el sitio segun sesiones pasadas ----------------

  # las figuras anteriores muestran que tiempo y sesiones pasadas tienen un
  # escalon cada una (5 minutos; entre 2 y 4 sesiones). Aqui se cruzan: la
  # media frente al tiempo, en un panel por tramo de sesiones. Si las lineas
  # fueran paralelas, los efectos serian aditivos; si la diferencia entre
  # paneles aparece solo despues de los 5 minutos, hay una interaccion que un
  # arbol puede capturar y un modelo lineal sin cruce no. Los tramos de
  # sesiones salen de la figura anterior (0 a 2 | 3 | 4 o mas)
  n_grupos_cruce <- 20

  por_cruce <- obs |>
    mutate(tramo = cut(
      past_sessions, breaks = c(-Inf, 2, 3, Inf),
      labels = c("0 a 2 sesiones", "3 sesiones", "4 o más sesiones")
    )) |>
    group_by(tramo) |>
    mutate(grupo = ntile(time_spent, n_grupos_cruce)) |>
    group_by(tramo, grupo) |>
    mutate(tiempo_mediano = median(time_spent)) |>
    group_by(tramo, grupo, tiempo_mediano) |>
    resumir_resultado(y)

  colores_tramo <- c(
    "0 a 2 sesiones" = paleta_categorica[1],
    "3 sesiones" = paleta_categorica[3],
    "4 o más sesiones" = paleta_categorica[2]
  )
  n_tramo <- obs |>
    count(tramo = cut(
      past_sessions, breaks = c(-Inf, 2, 3, Inf),
      labels = names(colores_tramo)
    ))

  grafica_cruce <- ggplot(
    por_cruce,
    aes(x = tiempo_mediano, y = media, color = tramo)
  ) +
    geom_hline(
      yintercept = media_global, linetype = "dashed",
      color = gris_secundario, linewidth = 0.5
    ) +
    geom_vline(
      xintercept = 5, linetype = "dotted",
      color = gris_nota, linewidth = 0.8
    ) +
    geom_linerange(aes(ymin = inferior, ymax = superior), linewidth = 0.6) +
    geom_point(size = 2, show.legend = FALSE) +
    scale_color_manual(values = colores_tramo, guide = "none") +
    scale_x_log10(
      breaks = c(0.1, 1, 5, 50), labels = c("0.1", "1", "5", "50")
    ) +
    facet_wrap(vars(tramo), ncol = 1) +
    labs(
      title = "Ingreso promedio según tiempo en el sitio y sesiones anteriores",
      subtitle = subtitulo_observacional,
      x = "Tiempo en el sitio en minutos (mediana de cada grupo, escala log)",
      y = nombre_eje,
      caption = paste(
        sprintf(
          "Nota: n = %s usuarios (%s).",
          format(n_obs, big.mark = ","),
          paste0(n_tramo$tramo, " ",
                 format(n_tramo$n, big.mark = ",", trim = TRUE),
                 collapse = ", ")
        ),
        sprintf(
          paste(
            "%d grupos de igual tamano por tramo segun su tiempo en el sitio.",
            "Barras: IC del 95%% de la media del grupo."
          ),
          n_grupos_cruce
        ),
        paste(
          nota_referencia,
          "La linea punteada gris vertical marca los 5 minutos."
        ),
        sep = "\n"
      )
    ) +
    tema_presentacion +
    tema_paneles

  guardar_figura(
    paste0("observacional_", prefijo, "_tiempo_por_sesiones.png"),
    grafica_cruce, carpeta, height = 8
  )
}
