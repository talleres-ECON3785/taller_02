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
| [B_ols_efecto_registro.md](03_punto_partida/B_ols_efecto_registro.md) | vigente | B / experimento / causal (ITT en dólares) | ¿Cambia el ATE y su interpretación? (punto de partida en dólares; cumplimiento perfecto) |

### `05_lasso_observacional/` (`05_lasso_observacional.R`: LASSO en dólares)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [A_lasso_vs_lineal_flexible.md](05_lasso_observacional/A_lasso_vs_lineal_flexible.md) | vigente | A / observacional / predictivo | ¿Cómo se compara con los modelos lineales? (RMSE de prueba 1.766 frente a 1.845 y 2.314) |

### `06_forma_funcional_observacional/` (`06_forma_funcional_observacional.R`: `ln(Revenue)`)

Sin notas todavía. Las figuras ya existen; falta registrar qué cambia frente al
script 03 y atribuirlo a la transformación.

### `04_prediccion_lineal_observacional/` (`04_prediccion_lineal_observacional.R`: escalera lineal en dólares)

| Nota | Estado | Parte / base | Pregunta del taller que responde |
| --- | --- | --- | --- |
| [A_escalera_importancia_lineal.md](04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md) | vigente | A / observacional / predictivo | ¿Qué variables resultan más útiles para predecir? ¿Cómo se compara con el lineal del Taller 1? |
| [A_corte_5_minutos_captura_tiempo.md](04_prediccion_lineal_observacional/A_corte_5_minutos_captura_tiempo.md) | vigente | A / observacional / predictivo | ¿Qué relaciones aparecen? ¿Qué cambia respecto al Taller 1? (el corte de 5 minutos reemplaza al tiempo lineal) |
| [A_lineal_flexible_vs_taller1.md](04_prediccion_lineal_observacional/A_lineal_flexible_vs_taller1.md) | vigente | A / observacional / predictivo | ¿Cómo se compara con el lineal del Taller 1? (RMSE de prueba 1.845 frente a 2.314) |

## Pendientes de conciliar

Contradicciones detectadas y aún sin decisión del equipo (nota afectada, resultado
nuevo y quién decide). Vacío por ahora.
