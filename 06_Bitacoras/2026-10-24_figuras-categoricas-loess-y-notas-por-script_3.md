# Bitácora — 2026-10-24 (sesión 3): figuras construidas en cada script, loess del tiempo, categóricas con media y mediana y notas por script

## Resumen

Santiago Muñoz (`SantiagoMunozM`) hizo cambios de forma y de lectura sobre la
descriptiva de la base observacional (P1.2), sin estimar modelos:

1. **Figuras dentro de cada script.** Las figuras se construían en
   `00_formato_descriptivas.R` (una función `graficar_covariables()` compartida).
   Ahora los scripts `03_punto_partida.R` y `04_forma_funcional_observacional.R`
   dibujan sus propias figuras y `00_formato_graficas.R` queda como único auxiliar
   de formato. Se eliminó `00_formato_descriptivas.R`. Las 12 figuras salieron
   idénticas byte a byte antes de los cambios siguientes.
2. **Ingreso frente al tiempo con loess.** La figura `_tiempo_sesion.png` pasó de
   50 grupos de 2,000 usuarios con intervalos a una curva loess ajustada por
   separado a cada lado de los 5 minutos. Con banda de confianza falló: unas
   85,000 observaciones por debajo de los 5 minutos exigen más de 4 mil millones
   de celdas de memoria en `predLoess()`. Se dejó sin banda (`se = FALSE`) y la
   nota al pie lo declara.
3. **Categóricas con media y mediana.** Las figuras de dispositivo, sistema
   operativo y usuario recurrente muestran ahora la media (línea continua, color
   del grupo) y la mediana (línea punteada gris) con sus cifras escritas junto a
   cada línea, y el n del grupo en el título del panel. Primero se hicieron como
   versiones alternativas y, a pedido del usuario, reemplazaron a las anteriores
   (mismos nombres de archivo, sin sufijo).
4. **Notas por script.** Las tres notas de `05_Notas/` pasaron a
   `05_Notas/03_punto_partida/` y se reescribieron para hablar solo del ingreso en
   dólares (script 03); lo de `ln(Revenue)` queda para el script 04. La nota de
   dispositivo y sistema operativo se reformuló: medianas parecidas, medias
   distintas, lo que sugiere diferencias en la cola derecha.

Por restricciones del entorno de la sesión (edición aislada en worktrees), los
cambios se hicieron en worktrees temporales y se trajeron a `SantiagoMunozM`; los
worktrees y sus ramas se eliminaron. No se corrió `00_main.R` completo después de
estos cambios: se corrieron los scripts 03 y 04 y las secciones afectadas por
separado.

Objetivos que traía `HANDOFF.md`: P1.1, P1.3, el cierre de P1.2 (`sign_up`), P2.1
y P2.2 no se trabajaron y se mantienen. Se resolvió el bloqueo "decidir si las
figuras de densidad marcan también la media".

## Archivos

- Creados: esta bitácora; `05_Notas/03_punto_partida/` (carpeta).
- Modificados: `02_Scripts/03_punto_partida.R`,
  `02_Scripts/04_forma_funcional_observacional.R`, `05_Notas/README.md`,
  `README.md`, `PLAN.md`, `HANDOFF.md`, `CLAUDE.md`,
  `.claude/skills/registrar-hallazgo/SKILL.md`,
  `07_Recursos/catalogo_metodos.md`; las figuras `_tiempo_sesion`,
  `_dispositivo`, `_sistema_operativo` y `_recurrente` de
  `03_Resultados/Figuras/03_punto_partida/` y
  `03_Resultados/Figuras/04_forma_funcional_observacional/`.
- Movidos (con `git mv`): `05_Notas/A_quiebre_time_spent.md`,
  `A_sesiones_pasadas_interaccion_tiempo.md` y `A_dispositivo_y_sistema_operativo.md`
  a `05_Notas/03_punto_partida/`.
- Eliminados: `02_Scripts/00_formato_descriptivas.R`.

## Detalle por archivo

### `02_Scripts/03_punto_partida.R` y `02_Scripts/04_forma_funcional_observacional.R`
Casi idénticos: solo cambian la variable de resultado (`Revenue` o
`log_revenue`), las etiquetas, el eje x de las densidades (log en dólares, lineal
en logaritmo) y el prefijo de los archivos. Cada uno define sus parámetros
comunes (sección 1), `resumir_resultado()` (media con IC normal del 95 %, usada
solo en la figura de sesiones pasadas) y las figuras en cinco secciones: tiempo
(loess sin banda), sesiones pasadas, categóricas (`graficar_categorica()` local),
interacción tiempo × sesiones y mensajes finales. Decisión: duplicar el código
entre los dos scripts en vez de compartir una función, porque los auxiliares `00_`
son solo para formato (paleta, tema, guardado). Las densidades categóricas dejan
45 % de espacio libre sobre la curva (`expansion(mult = c(0, 0.45))`) para que las
etiquetas de media y mediana no se superpongan con ella; la etiqueta del valor
menor va a la izquierda de su línea y la del mayor a la derecha, para que no se
choquen cuando están cerca.

### `02_Scripts/00_formato_descriptivas.R`
Eliminado. Sus funciones se movieron a los scripts 03 y 04.

### `05_Notas/03_punto_partida/*.md` y `05_Notas/README.md`
Las tres notas se limitan al script 03. La de dispositivo y sistema operativo
incluye una tabla de n, mediana, media y diferencia entre ambas para ocho grupos,
con las cifras que escriben las figuras. Se retiró de esa nota el contraste de
medias (p < 0.001) que se había calculado fuera de los scripts. El índice se
agrupa por script y deja vacía la sección del script 04.

### `CLAUDE.md`, `.claude/skills/registrar-hallazgo/SKILL.md`
Regla nueva: las notas van en `05_Notas/<script>/` y declaran su "Script de
origen". Se registran dos decisiones en "Decisiones tomadas".

### `07_Recursos/catalogo_metodos.md`
La ampliación de `loess` (solo figuras) pasa a cubrir también el ingreso frente al
tiempo, sin errores estándar por límite de memoria.

## Resultados nuevos (tablas, figuras, gráficos)

- **`observacional_revenue_tiempo_sesion.png` y `observacional_lnrevenue_tiempo_sesion.png`**
  (regeneradas): ingreso promedio frente al tiempo en el sitio, con el escalón de
  5 minutos. Datos: curva loess (`span = 0.5`) sobre las 100,000 observaciones,
  por separado a cada lado de los 5 minutos. Rol: Parte A, patrón que un árbol
  debería recuperar. Nota: [A_quiebre_time_spent.md](../05_Notas/03_punto_partida/A_quiebre_time_spent.md).
  La versión en logaritmo no tiene aún nota (script 04).
- **`observacional_{revenue,lnrevenue}_{dispositivo,sistema_operativo,recurrente}.png`**
  (regeneradas, 6 figuras): densidad del ingreso por grupo con media, mediana y n.
  Rol: Parte A, mostrar que las medianas se parecen y las medias difieren. Nota:
  [A_dispositivo_y_sistema_operativo.md](../05_Notas/03_punto_partida/A_dispositivo_y_sistema_operativo.md)
  (solo la escala en dólares).
- Las figuras `_sesiones_pasadas` y `_tiempo_por_sesiones` no cambiaron.

## Pendientes

- Falta una tabla exportada con `guardar_tabla()` con medias, medianas e
  intervalos por covariable y escala, y una tabla de percentiles altos (p. ej. p90
  y p99) por grupo para respaldar la lectura de la cola derecha (P1.3). Las cifras
  de las notas siguen leídas de las figuras.
- Escribir las notas del script 04 en `05_Notas/04_forma_funcional_observacional/`,
  atribuyendo cada diferencia a la transformación.
- Correr `00_main.R` completo para confirmar que todo regenera junto (no se hizo
  tras estos cambios) y probar el borrado de `03_Resultados/` (P7.1).
- Pendiente de P1: densidad de `Revenue` frente a `ln(Revenue)` (P1.1) y relación
  con `sign_up` (cierre de P1.2).
- Corregir los subtítulos y notas al pie sin tilde en `00_formato_graficas.R` y en
  los scripts 03 y 04.
