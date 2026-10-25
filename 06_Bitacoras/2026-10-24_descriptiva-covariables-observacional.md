# Bitácora — 2026-10-24: descriptiva de la base observacional (ingreso frente a las covariables) y carpeta de resultados por script

## Resumen

Santiago Muñoz (`SantiagoMunozM`) trabajó P1.2 de `PLAN.md`: mostrar cómo varía
el ingreso con las covariables, algo que el Taller 1 no hizo (heurística H3). Se
pidió primero con `Revenue` en nivel (dólares, escala del Taller 1) y después con
`ln(Revenue)` (escala del Taller 2), para ver qué cambia solo por la forma
funcional (aquí no hay método: son medias condicionales).

Desarrollo:

1. Se adaptó el formato del Taller 1 (`02_descriptivas_observacional.R` y
   `07_graficas_experimento.R`): densidades con el resultado en horizontal, un
   panel por grupo y la mediana en línea punteada gris.
2. Primera versión con violines para las variables categóricas; el usuario pidió
   el formato de densidad del Taller 1. Se corrigió un error propio: la tabla de
   medianas no llevaba la variable de los paneles y cada panel mostraba las
   medianas de todos los grupos.
3. Se agregaron el sistema operativo y una figura de la interacción entre tiempo
   en el sitio y sesiones pasadas.
4. El usuario notó que las medias por sistema operativo difieren aunque las
   figuras se vean casi iguales: la línea punteada es la mediana, no el promedio.
   Se verificó (medias en dólares 4.27 / 3.82 / 3.86; medianas 3.13 / 3.14 / 3.14)
   y se propuso marcar también la media (pendiente de decisión).
5. El script se separó en dos (`03_punto_de_partida_observacional.R` para
   `Revenue` en nivel y `04_forma_funcional_observacional.R` para `ln(Revenue)`),
   con las funciones compartidas en `00_formato_descriptivas.R`.
6. Se estableció que cada script que genera figuras o tablas tiene su subcarpeta
   en `03_Resultados/{Figuras,Tablas}/<script>/`, y se registró la regla en
   `CLAUDE.md`.

Objetivos que traía `HANDOFF.md`: P1.1–P1.3 avanzaron solo en P1.2 (faltan P1.1,
P1.3 y la variable de registro de P1.2). P2.1 y P2.2 no se trabajaron.

## Archivos

- Creados: `02_Scripts/00_formato_descriptivas.R`,
  `02_Scripts/03_punto_de_partida_observacional.R`,
  `02_Scripts/04_forma_funcional_observacional.R`; 12 figuras en
  `03_Resultados/Figuras/03_punto_de_partida_observacional/` y
  `03_Resultados/Figuras/04_forma_funcional_observacional/`; notas
  `05_Notas/A_quiebre_time_spent.md`,
  `05_Notas/A_sesiones_pasadas_interaccion_tiempo.md`,
  `05_Notas/A_dispositivo_y_sistema_operativo.md`; esta bitácora.
- Modificados: `00_main.R`, `02_Scripts/00_formato_graficas.R`,
  `02_Scripts/00_formato_tablas.R`, `02_Scripts/01_limpieza_observacional.R`,
  `CLAUDE.md`, `README.md`, `PLAN.md`, `05_Notas/README.md`, `HANDOFF.md`.
- Movidos (`git mv`): los dos reportes de calidad a
  `03_Resultados/Tablas/01_limpieza_observacional/`.
- Eliminados: `02_Scripts/03_descriptivas_observacional.R` (nunca versionado; lo
  reemplazan los scripts 03 y 04).

## Detalle por archivo

### `02_Scripts/00_formato_descriptivas.R`
Define `resumir_resultado()` (media del resultado con IC normal del 95 %) y
`graficar_covariables(obs, y, prefijo, etiqueta_y, carpeta, eje_log)`, que dibuja
y guarda las seis figuras de una escala. Decisión: dejar las funciones en un
script de formato compartido (no se agrega a la lista de `00_main.R`) para que
las dos escalas usen exactamente el mismo diseño y para no duplicar ~350 líneas.
La función recibe `obs` como argumento porque `source()` la define en el entorno
global y no vería el `obs` local de cada script.

Figuras que produce, con el criterio de cada una:
- **Tiempo en el sitio:** `time_spent` es continua y de cola larga; se agrupa en
  50 cuantiles (2,000 usuarios cada uno) y se grafica la media del grupo contra la
  mediana del tiempo del grupo (eje x en log), con la línea de 5 minutos del
  Taller 1. Los cuantiles dan grupos del mismo tamaño y los intervalos son
  comparables.
- **Sesiones pasadas:** conteo de 0 a 14; se agrupa "10 o más" (116 usuarios) para
  que los intervalos sean legibles.
- **Dispositivo, sistema operativo y usuario recurrente:** densidades por panel
  con la mediana de cada grupo. En nivel el eje x va en escala log (`CLAUDE.md`);
  en `ln(Revenue)` va lineal porque ya está en logaritmo.
- **Interacción tiempo × sesiones:** tres paneles (0 a 2, 3, y 4 o más sesiones),
  20 grupos por tramo según el tiempo. Los tramos salen de la figura de sesiones
  pasadas (decisión descriptiva, no un contraste previo). La idea: si el efecto
  de las sesiones fuera aditivo con el del tiempo, las diferencias entre paneles
  serían iguales antes y después de 5 minutos.

Se verifica con `stopifnot` en los scripts que `is_returning_user == 1`
exactamente cuando `past_sessions > 0` (cumple en las 100,000 observaciones).

### `02_Scripts/03_punto_de_partida_observacional.R` y `04_forma_funcional_observacional.R`
Cada uno lee `observacional_limpio.Rds`, define `carpeta_salida` y llama a
`graficar_covariables()` con `Revenue` (con `eje_log = TRUE`) o con `log_revenue`.
Ambos están en la lista de `00_main.R`. No pierden observaciones (n = 100,000).

### `02_Scripts/00_formato_graficas.R` y `00_formato_tablas.R`
`guardar_figura()` y `guardar_tabla()` reciben `carpeta` y escriben en
`03_Resultados/{Figuras,Tablas}/<carpeta>/`. Siguen sin crear carpetas.

### `02_Scripts/01_limpieza_observacional.R`
Los dos `write_csv()` van ahora a `03_Resultados/Tablas/01_limpieza_observacional/`.

### `00_main.R`
`carpetas_salida` incluye las tres subcarpetas por script; la lista de scripts
reemplaza el nombre viejo por los scripts 03 y 04. Corrió completo sin errores
(4 scripts, 0 observaciones perdidas).

### `CLAUDE.md`, `README.md`, `PLAN.md`
`CLAUDE.md`: nueva regla "Una carpeta de resultados por script" y fila en
"Decisiones tomadas" (2026-10-24); se actualizaron las convenciones de nombre de
figuras y tablas. `README.md`: estructura y mapa script → resultados. `PLAN.md`:
nombres de script de H1 y avance de P1.2.

## Resultados nuevos (tablas, figuras, gráficos)

Doce figuras (seis por escala), todas de la base observacional completa
(n = 100,000), descriptivas y no causales. Los datos salen de
`01_Datos/03_Listos/observacional_limpio.Rds`. Su rol: son las hipótesis que
deben confirmar o matizar los árboles de la Parte A (H3). Las notas que las
explican:

- [A_quiebre_time_spent.md](../05_Notas/A_quiebre_time_spent.md): escalón en
  5 minutos en las dos escalas; consistente con el Taller 1.
- [A_sesiones_pasadas_interaccion_tiempo.md](../05_Notas/A_sesiones_pasadas_interaccion_tiempo.md):
  las sesiones pasadas se asocian con más ingreso solo con más de 5 minutos;
  resultado nuevo.
- [A_dispositivo_y_sistema_operativo.md](../05_Notas/A_dispositivo_y_sistema_operativo.md):
  medianas casi iguales; diferencias de promedio en la cola alta.

Contraste con el Taller 1: sin contradicciones. Las cifras de las notas están
leídas de las figuras o de las notas al pie; **no hay todavía una tabla
exportada** con las medias, por lo que las cifras de medias por sistema operativo
(≈4.27 / 3.82 / 3.86 dólares) y la prueba F quedaron fuera de las notas como
cifras citables.

## Pendientes

- **P1.1:** densidad de `Revenue` frente a `ln(Revenue)` (asimetría y cola alta).
- **P1.3:** tabla con las cifras clave del Taller 1; y una tabla de medias por
  covariable y escala (con `guardar_tabla()`) que respalde las cifras de las notas.
- **P1.2:** falta la variable de registro (`sign_up`); y decidir si se marca la
  media (además de la mediana) en las densidades, que ocultan las diferencias de
  promedio por la cola.
- Subtítulos de las figuras sin tilde ("historicos", "asignacion"): vienen de
  `00_formato_graficas.R`; corregir ahí.
- No se probó borrar `03_Resultados/` y regenerar (el `rm` con comodín fue
  bloqueado por la verificación de seguridad); la corrida fue sobre carpetas ya
  existentes pero vacías. Probarlo a mano antes de entregar (P7.1).
- Convención de `log_revenue` confirmada: el Taller 1 usa `log(Revenue)` sin
  constante (`10_regresion_correlacional_observacional.R`, `06_analisis_experimento.R`).
  El Taller 1 está en `../../Taller 1/taller1/`, no en `../taller1/`.
- Siguiente paso del plan: P2.1 (partición 80/20 que reproduce el RMSE 2.314).
