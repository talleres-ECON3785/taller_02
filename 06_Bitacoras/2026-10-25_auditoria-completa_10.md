# Bitácora — 2026-10-25: auditoría completa del proyecto y regla de focalización (script 13)

## Resumen
Samuel Escandón hizo una auditoría completa del Taller 2 en una copia del proyecto,
la carpeta hermana `Taller_02_back Ups/`. Esa sesión corrió fuera de git: no usó
ramas, commits ni `cerrar-sesion`, y no tocó `PLAN.md`, `HANDOFF.md` ni las
bitácoras. En esta sesión el trabajo se trajo al repositorio, en la rama
`SamuelEscandonC`:
- la rama se puso al día con `origin/main` (fast-forward hasta el merge del PR #4);
- se copiaron los archivos nuevos o modificados de la copia, sin su `.Rproj`, sin
  `.Rproj.user/` y sin los respaldos duplicados
  `10_Auditoria/salidas/{resultados_originales,listos_originales}/`;
- se comprobó que la copia iba adelante de `main` (incluye el PR #4) y que no se
  revierte nada.

La fuente de esta bitácora es `10_Auditoria/informe_auditoria.md`. La auditoría
tuvo ocho fases (0 a 7) y cambios A y B aplicados con aprobación del usuario.

Hallazgos que cambiaban el mensaje del video, todos corregidos:
- **"osx es de computadores y tabletas" era falso** (H-01). El sistema operativo es
  casi independiente del dispositivo: dentro de cada dispositivo hay ≈ 30% osx. Los
  celulares con osx son el 15.2% de la base histórica.
- **La recomendación excluía un grupo con efecto positivo** (H-02). "Solo computador
  y tableta" deja fuera a los celulares con osx, cuyo efecto es +7.6% [+3.8%; +11.6%]
  del gasto típico. La regla nueva es "registro facilitado para todos, salvo
  celulares con Windows u otro SO".
- **Atribución nivel–log incompleta** (H-03). No es solo la transformación: los
  signos opuestos entre grupos (método) explican el ≈ 0 en log; el gasto base y el
  ensanchamiento dentro de cada grupo (transformación) explican parte del +0.41 en
  dólares. La atribución correcta es "ambos".
- **Cuentas y lecturas** (H-05, H-06): los puntos de log se leían como porcentajes
  (−0.257 es −22.7%, no −25%). La ganancia predictiva no se reparte en "dos
  tercios": el corte y el cruce dan el 68%, LASSO el 12% y el árbol el 20%.

Además:
- `W.hat` pasa a `mean(W)` en los bosques causales (H-07). No cambia ningún signo
  ni ningún intervalo que cruce el cero.
- Se agrega la escalera de RMSE en `ln(Revenue)` al script 04 (H-08).
- `00_main.R` acepta cualquier `.Rproj` en la raíz (H-10).

**Corridas.** La corrida completa de `00_main.R` con 12 scripts terminó sin errores
en 45.6 minutos en Windows (el script 10 toma 30.9). Ninguna cifra cambió en más
de 1e-9 frente a las versionadas. Después cambiaron los scripts 04 y 12 y se creó
el 13. Cada uno se corrió por separado, tras las secciones 1 a 3 de `00_main.R`, y
sin errores. **No hay una corrida de los 13 scripts juntos**: la última corrida
completa se detuvo a pedido del usuario durante el script 03.

**Objetivos de `HANDOFF.md`.** Los que traía estaban desactualizados: P3.1, P5.1 y
P5.2 ya los había cerrado Santiago Muñoz en `385ece2` (PR #4), sesión sin bitácora
propia.
- La auditoría cerró la escalera en logaritmo (avance sobre P2.6, ya marcado como
  cerrado).
- Rehízo P5.2 con la regla nueva.
- Pasó la lista de chequeo H1–H10 (P5.3).
- Avanzó P3.3 con la conciliación por grupos, pero sin intervalos de los cuantiles.

## Archivos
- **Creados:**
  - `02_Scripts/13_focalizacion_experimento.R`;
  - `03_Resultados/Tablas/13_focalizacion_experimento/` (4 tablas, `.png` y `.csv`) y `03_Resultados/Figuras/13_focalizacion_experimento/` (1 figura);
  - `03_Resultados/{Tablas,Figuras}/04_prediccion_lineal_observacional/observacional_escalera_rmse_log.*`;
  - `05_Notas/13_focalizacion_experimento/B_regla_focalizacion.md` y `X_conciliacion_por_celdas.md`;
  - `10_Auditoria/`: `informe_auditoria.md`, `respuestas_enunciado.md`, `propuestas/` (2), `scripts/` (8) y `salidas/` (26 archivos: `.csv`, `.log` y el inventario);
  - esta bitácora.
- **Modificados:**
  - `00_main.R`, `CLAUDE.md`, `README.md`, `PLAN.md` y `HANDOFF.md`;
  - `02_Scripts/04_prediccion_lineal_observacional.R` y `02_Scripts/12_heterogeneidad_experimento.R`;
  - `05_Notas/sintesis.md`, `05_Notas/README.md`, las tres notas de `05_Notas/12_heterogeneidad_experimento/`, `05_Notas/09_arboles_observacional/A_cart_recupera_corte_5_min.md` y `05_Notas/04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md`;
  - regenerados por las corridas: 62 `.png` y 29 `.csv` de `03_Resultados/`, y las dos bases de `01_Datos/03_Listos/`, con el mismo contenido (`all.equal` = TRUE).
- **Eliminados:** ninguno.

## Detalle por archivo

### `00_main.R`
- **Sección 1:** la verificación de la raíz ya no exige `taller_02.Rproj`. Exige que
  haya algún `.Rproj` y la carpeta `02_Scripts/`. Con la regla anterior, el
  pipeline no podía correr en la copia de respaldo, cuyo `.Rproj` tiene otro
  nombre. La nueva funciona en las dos carpetas sin renombrar nada. En esta sesión
  se comprobó que la sección 1 pasa en el repositorio (con `taller_02.Rproj`).
- **Script 13:** se agregó a `scripts`, y sus subcarpetas
  `03_Resultados/{Tablas,Figuras}/13_focalizacion_experimento` a `carpetas_salida`.

### `02_Scripts/12_heterogeneidad_experimento.R`
- `W.hat = mean(W)` (0.4957) en `estimar_bosque()`, también en cada mitad de la
  muestra dividida. Reemplaza la decisión de la sesión 9 de dejar que `grf` lo
  estimara.
- **Intuición:** la asignación del experimento es aleatoria con una probabilidad
  común. El bosque de propensión solo agregaba ruido: su `W.hat` iba de 0.30 a 0.74.
  Fijarlo en la proporción tratada usa lo que se sabe del diseño (Lab 10; heurística
  H7).
- **Efecto en las cifras:** cambian en decimales menores, sin cambios de signo ni
  intervalos que pasen a cruzar el cero. El mayor cambio es "otro SO" en dólares, de
  −0.08 a −0.13. Calibración diferencial 1.008 (ee 0.031) en log.

### `02_Scripts/13_focalizacion_experimento.R` (nuevo)
- **Estimando:** el CATE del registro facilitado sobre `ln(Revenue)` en cada celda
  dispositivo × sistema operativo. Se lee como `exp(τ) − 1`, el cambio porcentual
  del gasto del usuario típico de la celda. Complemento etiquetado: el mismo efecto
  en dólares por usuario.
- **Estimador:** bosque causal de `grf`, con 2,000 árboles honestos y las 5
  covariables del script 12. `W.hat = mean(W)`, `seed = 2026`, `num.threads = 4`.
- **Estimación:** las cifras de las tablas. Solo el experimento sostiene la lectura
  causal.
- **Variables del estimador** (`07_Recursos/catalogo_metodos.md`, sección 5; Lab 10):
  - *Efecto de una celda S:* `average_treatment_effect(cf, subset = S)`, el ATE
    doblemente robusto restringido a los usuarios de S (ampliación ya registrada).
    Es el promedio de los τ̂(Xᵢ) de esos usuarios, corregido con el residuo
    ponderado por la propensión.
  - *Mitades de entrenamiento y evaluación:* el experimento se parte en dos mitades
    por usuario (`set.seed(2026)`, 5,000 / 5,000).
    - `cf_ent` elige las celdas a tratar (efecto > 0, sin celdas pequeñas).
    - `cf_eva` es un bosque estimado solo con la otra mitad. Mide el valor de cada
      regla.
    - Así, elegir y evaluar no usan los mismos datos. Es como el curso trata la
      multiplicidad y el sesgo de selección de la regla (clase 18, Lab 10); no se
      ajustan p-valores.
  - *Valor de una regla S:* peso(S) × `average_treatment_effect(cf_eva, subset = S)`.
    peso(S) es la participación de las celdas S en la base histórica, así que el
    valor queda por usuario de la población y no de la muestra del experimento.
    - La diferencia entre dos reglas anidadas se estima con las celdas en que
      difieren.
    - Eso da su error estándar directamente, sin combinar varianzas a mano (fuera
      del alcance).
  - *Tamaño mínimo de celda:* las celdas con menos de 100 observaciones en alguna
    mitad se marcan y no sostienen conclusiones de focalización: tableta–otro SO
    (45 / 39).
  - *Conciliación:* se apoya en la identidad ATE = promedio de los efectos por
    celda, ponderado por el peso de cada celda. Lo implicado por los efectos
    proporcionales es Σ peso × gasto medio del control × (exp(τ) − 1). La
    diferencia entre ese número y el ATE en dólares es lo que ocurre dentro de las
    celdas. Se calcula con la partición dispositivo × SO y con la fina, dispositivo
    × SO × tramo de sesiones, con las celdas de n ≥ 100.
- **Decisión de la regla** (registrada en `CLAUDE.md`): se excluye solo donde hay
  daño distinguible de cero en las dos escalas. Esos grupos son los celulares con
  Windows y los celulares con otro SO.

### `02_Scripts/04_prediccion_lineal_observacional.R`
- **Nueva sección 9:** la misma escalera de RMSE de validación cruzada en
  `ln(Revenue)`, con la misma partición, los mismos 5 pliegues y el mismo orden de
  variables, solo con `train`. Se exporta como `observacional_escalera_rmse_log`
  (tabla y figura).
- **Comprobación:** coincide con `aud_04_escalera_dos_escalas.csv` con diferencia 0
  en todos los pasos. Las salidas en dólares no cambian (diferencia máxima 6e-13), y
  se reproducen el 2.314 y el 2.716 del Taller 1.

### Notas de `05_Notas/`
- `sintesis.md` se reescribió con la regla nueva, un estimando único, el valor de la
  regla fuera de la muestra de selección, la atribución "ambos", la cuenta del 68%,
  la lectura `exp(τ) − 1` y preguntas abiertas concretas (H10).
- `12_heterogeneidad_experimento/B_cate_por_grupo.md` pasa a `matizado`, con
  aprobación del usuario: los grupos de una característica se mantienen, pero la
  regla se define por dispositivo × SO. Las tres notas del 12 llevan las cifras con
  `W.hat` fijo y la lectura `exp(τ) − 1`.
- En la nota de `09_arboles_observacional`, el árbol en log usa dispositivo o SO en
  6 de sus 9 cortes, aunque su importancia por permutación sea baja. También queda
  declarado que el corte de 5 minutos se eligió mirando la base completa.
- En la nota de `04_prediccion_lineal_observacional`, se agrega la escalera en log.
- `README.md` de notas: la sección del 13, el estado de `B_cate_por_grupo` y la fila
  de la síntesis.
- La copia no tenía `.claude/`, así que el procedimiento de `registrar-hallazgo` se
  siguió a mano.
  - Las contradicciones (la regla, y "osx es de computadores") las resolvió el
    usuario.
  - El resto quedó consistente: la escalera en log, los cortes del árbol y las cifras
    del 12 con `W.hat` fijo.

### `CLAUDE.md`
- Paso 1 de "`00_main.R` es el único punto de entrada": acepta cualquier `.Rproj`.
- Cinco filas nuevas en "Decisiones tomadas": el `.Rproj`, `W.hat = mean(W)`, el
  script 13, la regla nueva y `num.threads` de `ranger` sin fijar como limitación
  conocida.

### `README.md`
- La auditoría agregó la fila del script 13 al mapa script → resultados.
- En esta sesión se agregaron `10_Auditoria/` al árbol de carpetas y una línea en
  "Documentación del trabajo". Esa línea dice que es la auditoría del 2026-10-25,
  que sus scripts no forman parte del pipeline y que las respuestas al enunciado
  están en `respuestas_enunciado.md`.

### `10_Auditoria/`
- Lo produjo la auditoría y queda fuera del pipeline: `00_main.R` no lo llama.
  - `informe_auditoria.md`: tabla de hallazgos H-01 a H-13 y verificación de las
    lecturas del usuario.
  - `respuestas_enunciado.md`: el mensaje en 30 segundos, las 12 preguntas del
    enunciado con su cifra, archivo y confianza, y la lista H1–H10.
  - Scripts `aud_*` con sus salidas: la comparación de corridas, las celdas
    dispositivo × SO, la conciliación fina, la predicción en log y las corridas de
    los scripts 04, 12 y 13.
- `aud_*` produce verificaciones, no cifras de la presentación. Si una cifra de
  auditoría y una de `03_Resultados/` difieren, manda la de `03_Resultados/`.

### `PLAN.md` y `HANDOFF.md`
- `PLAN.md`: avances en P2.6, P3.3 y P5.2; P5.3 marcado.
- `HANDOFF.md`: objetivos, estado y registro reescritos.

## Resultados nuevos (tablas, figuras, gráficos)
Todos los del 13 los genera `02_Scripts/13_focalizacion_experimento.R` en
`03_Resultados/{Tablas,Figuras}/13_focalizacion_experimento/`. Base: experimento,
n = 10,000; los pesos vienen de la base histórica (100,000).

| Archivo | Qué comunica | Nota |
| --- | --- | --- |
| Tabla y figura `experimento_efecto_celdas_dispositivo_so` | Efecto por celda dispositivo × SO en las dos escalas, con IC, n y peso histórico. Celular–Windows −22.4% y celular–otro −19.4%; computador–osx +44%. Las demás celdas grandes son positivas o cercanas a cero. | [B_regla_focalizacion.md](../05_Notas/13_focalizacion_experimento/B_regla_focalizacion.md) |
| Tabla `experimento_efecto_celdas_dispositivo_sesiones` | Partición alternativa (apéndice): los celulares son negativos en log en los tres tramos de sesiones. | [B_regla_focalizacion.md](../05_Notas/13_focalizacion_experimento/B_regla_focalizacion.md) |
| Tabla `experimento_valor_reglas` | Valor de cada regla en la mitad de evaluación, por usuario de la base histórica: regla recomendada 0.657 dólares y +10.2%; todos 0.416 y +0.8%; solo computador y tableta 0.578. | [B_regla_focalizacion.md](../05_Notas/13_focalizacion_experimento/B_regla_focalizacion.md) |
| Tabla `experimento_conciliacion_celdas` | Cuánto del ATE en dólares explican los efectos proporcionales y el gasto base de cada grupo (0.17 de 0.41), y cuánto ocurre dentro de los grupos. | [X_conciliacion_por_celdas.md](../05_Notas/13_focalizacion_experimento/X_conciliacion_por_celdas.md) |
| Tabla y figura `observacional_escalera_rmse_log` (script 04) | Escalera de RMSE de validación cruzada en `ln(Revenue)`, solo `train`: el indicador de más de 5 minutos da el 60% de la caída, sesiones y cruce el 33% y dispositivo el 6%. | [A_escalera_importancia_lineal.md](../05_Notas/04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md) |

Los efectos por celda son CATE estimados por grupo. Dependen de la partición
muestral y de las celdas elegidas. Que el sistema operativo separe a los grupos
no quiere decir que el sistema operativo cause la diferencia: no se conoce el
mecanismo.

## Pendientes
- **Corrida completa con los 13 scripts.** Falta una corrida de `00_main.R` con los
  13 scripts juntos. La última completa (12 scripts) terminó sin errores. Los
  scripts que cambiaron después (04, 12 y 13) corrieron por separado sin errores.
  Se cubre con P7.1, que borra `03_Resultados/`; tarda unos 46 minutos en Windows.
- **Presentación:** guion, slides y video (P6.1 a P6.4). `04_Presentaciones/` y
  `08_Entregables/` siguen vacíos. `10_Auditoria/respuestas_enunciado.md` es el
  insumo del guion.
- **P3.3:** faltan los intervalos de los cuantiles por grupo. Requieren ampliar el
  catálogo con remuestreo.
- **H8, H9:** no hay datos del costo de la intervención. Los supuestos de
  atribución (no interferencia, mismo periodo) hay que decirlos en el video.
- **P7.2:** en el README, los scripts existentes siguen bajo "Scripts previstos (por
  llenar)" (H-13).
- **Reproducibilidad:** `ranger` sin `num.threads` en los scripts 10 y 11 queda como
  limitación conocida. `geom_errorbarh()` está obsoleta en ggplot2 4.0 (una
  advertencia, en el script 12).
