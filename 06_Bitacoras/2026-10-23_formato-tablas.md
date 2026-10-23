# Bitácora — 2026-10-23: formato de tablas (`gt`, `modelsummary` y exportación con Chrome)

## Resumen

Santiago Muñoz (`SantiagoMunozM`). Objetivo: cumplir P0.2 de `PLAN.md`, es decir,
elegir el paquete de formato de tablas y crear `02_Scripts/00_formato_tablas.R`
con `guardar_tabla()`, para que las tablas de las diapositivas salgan del código
en su formato final (mejora pedida por el profesor tras el Taller 1).

Desarrollo: se compararon cinco alternativas (`gt`, `flextable`, `kableExtra`,
`modelsummary`, dibujo con `ggplot2`/`tableGrob`) y el equipo eligió `gt` con
`modelsummary`. Al probar la exportación a `.png` con `webshot2`, su dependencia
`websocket` no compiló en la máquina de la sesión (incompatibilidad con la
versión de OpenSSL), así que se cambió la exportación a un método sin
`webshot2`: `gt` escribe un HTML y Chrome en modo headless lo mide y lo
fotografía. La función se probó con una tabla desechable generada fuera del
repositorio; esa tabla y su script no se versionan ni se cuentan como resultado
del taller.

Objetivos que traía `HANDOFF.md`: (1) P0.2–P0.3: P0.2 se cumplió; P0.3 avanzó
solo en parte (se agregaron `gt` y `modelsummary` al `p_load()`; faltan los
paquetes de árboles y estimación). (2) P0.4–P0.5 y (3) P1.1–P1.3 no se
trabajaron.

## Archivos

- Creados: `02_Scripts/00_formato_tablas.R`,
  `06_Bitacoras/2026-10-23_formato-tablas.md`.
- Modificados: `00_main.R`, `CLAUDE.md` ("Decisiones tomadas"),
  `07_Recursos/catalogo_metodos.md` ("Registro de ampliaciones"), `PLAN.md`
  (P0.2 marcada), `HANDOFF.md`.
- Eliminados: ninguno.

## Detalle por archivo

### `02_Scripts/00_formato_tablas.R`

Equivalente de `00_formato_graficas.R` para tablas: no genera tablas, solo define
estilo y exportación. Carga con `source()` el formato de las gráficas para reutilizar
la paleta (`paleta_categorica`, grises), de modo que figuras y tablas se vean como
una sola familia. Sin `library()` ni `p_load()`, según la regla del proyecto.

- **`decimales`:** lista con el número de decimales fijo por tipo de cifra
  (dólares 2, log 3, RMSE 3, porcentaje 1, estadístico 3, conteo 0). Intuición:
  una misma clase de cifra se ve igual en todas las tablas; si se quiere cambiar,
  se cambia en un solo lugar.
- **`nota_tabla(base, n, muestra, extra)`:** arma la nota al pie que `CLAUDE.md`
  exige: base (experimento u observacional, con la advertencia de que la
  observacional es descriptiva y no causal), `n` y si las cifras son de la
  muestra completa, de entrenamiento o de prueba.
- **`estilo_tabla(tabla, titulo, subtitulo, nota)`:** encabezado de columnas en
  azul del proyecto con texto blanco, título en negrita alineado a la izquierda,
  grilla fina, sin línea vertical en la columna de etiquetas y nota al pie en
  gris. Decisión de implementación: la negrita del título va con `tab_style()` y
  no con `tab_options(heading.title.font.weight)`, porque `gt` le pone al título la
  clase `gt_font_normal`, que anula esa opción.
- **`ruta_chrome()`:** busca Chrome o Chromium en `CHROME_PATH`, en las rutas
  habituales de macOS y Windows y en el `PATH` de Linux. Falla con un mensaje claro
  si no lo encuentra.
- **`guardar_tabla(nombre, tabla, datos, zoom, margen)`:** exporta
  `03_Resultados/Tablas/<nombre>.png` y `<nombre>.csv` (cifras sin formato, para
  trazabilidad). Pasos: `gt` guarda un HTML temporal; se le inyecta un script que
  deja el tamaño de la tabla en el título de la página; `Chrome --dump-dom` lee ese
  tamaño; y `Chrome --screenshot` toma la imagen con ese tamaño exacto, a zoom 2.
  Intuición: la imagen queda recortada a la tabla y es la que entra a la
  diapositiva, sin retoques. No llama a `dir.create()`: asume que `00_main.R` ya
  creó `03_Resultados/Tablas/`, como `guardar_figura()`.

Verificación: la función se ejecutó con éxito en esta máquina (macOS, Chrome
instalado) y generó el `.png` y el `.csv`; se revisó la imagen (título en negrita,
tildes de la nota, tamaño ajustado, nota al pie completa). No se ha probado en otra
máquina ni en Linux/Windows.

### `00_main.R`

Se agregaron `gt` (formato de tablas) y `modelsummary` (tablas de regresión con
errores robustos, `output = "gt"`) al `p_load()`, cada uno con su comentario.
`webshot2` se agregó y se retiró en la misma sesión al cambiar el método de
exportación. No se agregó verificación de Chrome en `00_main.R`, por indicación del
usuario (el equipo ya lo tiene instalado).

### `CLAUDE.md` y `07_Recursos/catalogo_metodos.md`

Se registró la decisión: formato con `gt`, `modelsummary` para tablas de regresión y
exportación a `.png` con Chrome headless sin `webshot2`; se descartan `flextable`,
`kableExtra` y el dibujo de tablas con `ggplot2`. Se anotó como ampliación del
catálogo (son herramientas de presentación, no estiman nada). Razón: `gt` da control
total de encabezados, decimales, etiquetas y notas desde el código, y evita el
cambio manual de formato que se hizo en el Taller 1.

### `PLAN.md`

P0.2 marcada como terminada. P0.3 queda abierta (ver Pendientes).

## Resultados nuevos (tablas, figuras, gráficos)

Ninguno. La tabla generada para probar `guardar_tabla()` no forma parte del
repositorio ni de los resultados del taller. No hay notas de hallazgo que crear o
actualizar.

## Pendientes

- **P0.3 (parcial):** agregar al `p_load()` `rpart`, `rpart.plot`, `ranger`,
  `glmnet`, `caret`, `fixest` y `grf`, con un comentario de para qué se usa cada
  uno. Ya están `gt` y `modelsummary`.
- **P0.4–P0.5:** `log_revenue` en las bases listas y `README.md` inicial (el README
  debe mencionar que `guardar_tabla()` requiere Chrome o Chromium, o `CHROME_PATH`).
- **P1.1–P1.3:** descriptiva de la Parte A, ya con `guardar_tabla()` disponible.
- **Sin confirmar:** que `guardar_tabla()` funcione en las máquinas de los otros
  integrantes (otro sistema operativo o ruta de Chrome). Conviene que alguien más lo
  pruebe antes del 25 de octubre.
- **Sin confirmar:** la fuente Inter se pide a Google Fonts; sin conexión, `gt` usa
  la fuente por defecto y el aspecto cambia un poco. Decidir si se fija una fuente
  del sistema.
- `webshot2` no compiló aquí por `websocket`/OpenSSL; no hace falta resolverlo
  mientras la exportación no dependa de él.
- Siguiente paso: `cerrar-sesion` (commit y push a `SantiagoMunozM`).
