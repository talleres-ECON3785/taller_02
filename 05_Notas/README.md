# Notas de hallazgos

Cada nota recopila un hallazgo principal del taller: qué evidencia lo sostiene
(tablas y figuras de `03_Resultados/`), qué dice en lenguaje intuitivo y por qué
importa en el estudio. Las bitácoras (`06_Bitacoras/`) cuentan qué se hizo en cada
sesión; las notas cuentan qué se encontró. Quien arme la presentación debe poder
leer solo estas notas y reconstruir los mensajes principales.

Las reglas están en la sección "Notas de hallazgos" de `CLAUDE.md`. Las notas se
crean y actualizan con la skill `registrar-hallazgo`, que también contrasta la
evidencia nueva con lo registrado aquí y con el Taller 1, y alerta si algo es
contradictorio.

## Convenciones

- Las notas se agrupan en una subcarpeta por script de origen, con el nombre del
  script sin `.R` (p. ej. `05_Notas/03_punto_partida/`). Una nota solo habla de lo
  que se sabe con los resultados de su script; si otro script (p. ej. el de
  `ln(Revenue)`) matiza o cambia el hallazgo, se registra en la subcarpeta de ese
  script y se enlaza.
- Nombre: `<parte>_<slug>.md`, con `<parte>` = `A` (predicción, base
  observacional), `B` (heterogeneidad, experimento) o `X` (transversal, p. ej.
  qué cambia por la transformación frente al método).
- Estado: `vigente`, `matizado` o `reemplazado` (con enlace a la nota que lo
  reemplaza).
- Una nota por hallazgo; toda cifra remite a un archivo de `03_Resultados/`.

## Índice

### `03_punto_partida/` (`03_punto_partida.R`: ingreso en dólares)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [A_quiebre_time_spent.md](03_punto_partida/A_quiebre_time_spent.md) | vigente | A / observacional / descriptivo | ¿Qué relaciones aparecen? ¿Qué conclusiones del Taller 1 se mantienen? (quiebre en 5 minutos) |
| [A_sesiones_pasadas_interaccion_tiempo.md](03_punto_partida/A_sesiones_pasadas_interaccion_tiempo.md) | vigente | A / observacional / descriptivo | ¿Qué patrones aparecen con los árboles? (interacción tiempo × sesiones) |
| [A_dispositivo_y_sistema_operativo.md](03_punto_partida/A_dispositivo_y_sistema_operativo.md) | vigente | A / observacional / descriptivo | ¿Qué variables resultan más útiles para predecir? (medianas parecidas, medias distintas: cola derecha) |

### `05_lasso_observacional/` (`05_lasso_observacional.R`: LASSO en dólares)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [A_lasso_vs_lineal_flexible.md](05_lasso_observacional/A_lasso_vs_lineal_flexible.md) | vigente | A / observacional / predictivo | ¿Cómo se compara con los modelos lineales? (RMSE de prueba 1.765 frente a 1.845 y 2.314) |

### `06_ate_experimento_niveles/` (`06_ate_experimento_niveles.R`: ITT en dólares, balance y cumplimiento)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [B_ols_efecto_registro.md](06_ate_experimento_niveles/B_ols_efecto_registro.md) | vigente | B / experimento / causal (ITT en dólares) | ¿Cambia el ATE y su interpretación? (punto de partida en dólares: 0.49 sin controles, 0.45 con controles) |
| [B_balance_y_cumplimiento.md](06_ate_experimento_niveles/B_balance_y_cumplimiento.md) | vigente | B / experimento / validación del diseño | ¿Se sostiene la lectura causal? (grupos comparables, cumplimiento perfecto) |
| [B_patrones_de_los_controles_en_experimento.md](06_ate_experimento_niveles/B_patrones_de_los_controles_en_experimento.md) | vigente | B / experimento vs. observacional / descriptivo y predictivo | ¿Los patrones que justifican los controles (corte de 5 minutos, cruce con sesiones) están en el experimento? (sí; cruce y aporte de dispositivo y sistema operativo, mayores) |

### `07_forma_funcional_observacional/` (`07_forma_funcional_observacional.R`: `ln(Revenue)`)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [X_distribucion_dolares_vs_logaritmo.md](07_forma_funcional_observacional/X_distribucion_dolares_vs_logaritmo.md) | vigente | A / observacional / descriptivo | ¿Qué cambia al usar `ln(Revenue)`? (cola derecha, media geométrica y factor de corrección) |

Faltan las notas que comparan, figura por figura, qué cambia frente al script 03.

### `08_ate_experimento_log/` (`08_ate_experimento_log.R`: ITT en `ln(Revenue)` y regreso a dólares)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [B_log_a_dolares_efecto_registro.md](08_ate_experimento_log/B_log_a_dolares_efecto_registro.md) | vigente | B / experimento / causal | ¿Cambia el ATE y su interpretación en log? (1.3% en logaritmo frente a 12% en dólares: dispersión) |

### `04_prediccion_lineal_observacional/` (`04_prediccion_lineal_observacional.R`: escalera lineal en dólares)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [A_escalera_importancia_lineal.md](04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md) | vigente | A / observacional / predictivo | ¿Qué variables resultan más útiles para predecir? ¿Cómo se compara con el lineal del Taller 1? |
| [A_corte_5_minutos_captura_tiempo.md](04_prediccion_lineal_observacional/A_corte_5_minutos_captura_tiempo.md) | vigente | A / observacional / predictivo | ¿Qué relaciones aparecen? ¿Qué cambia respecto al Taller 1? (el corte de 5 minutos reemplaza al tiempo lineal) |
| [A_lineal_flexible_vs_taller1.md](04_prediccion_lineal_observacional/A_lineal_flexible_vs_taller1.md) | vigente | A / observacional / predictivo | ¿Cómo se compara con el lineal del Taller 1? (RMSE de prueba 1.845 frente a 2.314) |

### `09_arboles_observacional/` (`09_arboles_observacional.R`: árbol de regresión en dólares y en logaritmo)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [A_cart_recupera_corte_5_min.md](09_arboles_observacional/A_cart_recupera_corte_5_min.md) | vigente | A / observacional / predictivo | ¿Qué patrones aparecen con los árboles? (el árbol encuentra solo el corte de 5 minutos y el cruce con las sesiones) |

### `10_bosque_observacional/` (`10_bosque_observacional.R`: bagging y bosque aleatorio)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [A_importancia_bosque.md](10_bosque_observacional/A_importancia_bosque.md) | vigente | A / observacional / predictivo | ¿Qué variables resultan más útiles para predecir? (tiempo y sesiones; el registro, cerca de 0) |

### `11_comparacion_prediccion_observacional/` (`11_comparacion_prediccion_observacional.R`: evaluación en prueba, método × escala)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [X_rmse_metodo_por_escala.md](11_comparacion_prediccion_observacional/X_rmse_metodo_por_escala.md) | vigente | A / observacional / predictivo | ¿Cómo se comparan árboles y lineales? ¿Qué cambia con `ln(Revenue)`? (árbol 1.627 frente a LASSO 1.765 dólares; ganancia del método, no de la transformación) |

### `12_heterogeneidad_experimento/` (`12_heterogeneidad_experimento.R`: bosque causal, ATE, CATE y evidencia de HTE)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [B_evidencia_hte.md](12_heterogeneidad_experimento/B_evidencia_hte.md) | vigente | B / experimento / causal | ¿Existe evidencia de HTE? (calibración 1.01, AUTOC 0.20 en log; el ATE ≈ 0 esconde efectos de signo opuesto) |
| [B_cate_por_grupo.md](12_heterogeneidad_experimento/B_cate_por_grupo.md) | vigente | B / experimento / causal | ¿Cómo varían los CATE y qué grupos difieren? (computador, osx y más sesiones positivos; celular, Windows y usuarios nuevos negativos) |
| [X_hte_nivel_vs_log.md](12_heterogeneidad_experimento/X_hte_nivel_vs_log.md) | vigente | B / experimento / causal | ¿Cómo se relaciona con el ATE del Taller 1? ¿Qué cambia en log? (heterogeneidad en las dos escalas; en dólares se agranda en los usuarios de mayor gasto) |

## Pendientes de conciliar

Contradicciones detectadas y aún sin decisión del equipo (nota afectada, resultado
nuevo y quién decide). Vacío por ahora.
