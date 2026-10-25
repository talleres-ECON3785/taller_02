# Para predecir el ingreso en el modelo lineal, pasar más de 5 minutos, las sesiones anteriores y su cruce aportan casi toda la reducción del error; dispositivo, sistema operativo, usuario recurrente y registro aportan poco

- **Estado:** vigente
- **Parte / base:** A; observacional; predictivo (ingreso en dólares y en logaritmo)
- **Script de origen:** `02_Scripts/04_prediccion_lineal_observacional.R`
- **Última verificación:** 2026-10-24, con `02_Scripts/04_prediccion_lineal_observacional.R`

## Evidencia
- `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_escalera_rmse.png`
  (RMSE de validación cruzada de 5 pliegues por paso; `Revenue` en dólares;
  entrenamiento, n = 80,000) y su figura
  `03_Resultados/Figuras/04_prediccion_lineal_observacional/observacional_escalera_rmse.png`.
- `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_importancia_variables.png`
  (cada variable sola frente a la media, y el modelo completo sin ella; el cruce
  tiene fila propia).
- Escalera (RMSE de CV, dólares; entre paréntesis la caída frente al paso
  anterior): media 2.741; + más de 5 minutos 2.305 (0.436); + sesiones anteriores
  2.171 (0.134); + cruce más de 5 minutos × sesiones 1.913 (0.257); + dispositivo
  1.884 (0.029); + sistema operativo 1.873 (0.010); + usuario recurrente 1.869
  (0.005); + registro 1.869 (−0.00001). Errores estándar entre pliegues de las
  caídas: de 0.0001 a 0.005.
- Al quitar una variable del modelo completo, el RMSE sube (dólares): más de 5
  minutos 0.724 y sesiones anteriores 0.394 (ambas incluyen el cruce), cruce 0.263,
  dispositivo 0.030, sistema operativo 0.010, usuario recurrente 0.005, registro
  0.000.
- El cruce aislado: agregarlo al modelo que ya tiene las dos variables baja el
  RMSE 0.257 dólares (error estándar 0.004).
- **Escalera en `ln(Revenue)`** (misma partición, mismos 5 pliegues y mismo orden;
  entrenamiento, n = 80,000):
  `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_escalera_rmse_log.png`
  (y `.csv`) y la figura
  `03_Resultados/Figuras/04_prediccion_lineal_observacional/observacional_escalera_rmse_log.png`.
  RMSE de CV en log (entre paréntesis, caída y % de la caída total):
  - media: 0.535;
  - + más de 5 minutos: 0.436 (0.100; 60%);
  - + sesiones anteriores: 0.417 (0.019; 12%);
  - + cruce: 0.381 (0.036; 22%);
  - + dispositivo: 0.371 (0.010; 6%);
  - + sistema operativo, usuario recurrente y registro: 0.370 (menos de 0.001 cada
    uno).

  En log, el indicador de 5 minutos también domina al tiempo continuo y a su
  logaritmo (0.370 frente a 0.434 y 0.448). Este contraste es solo de auditoría
  (`10_Auditoria/salidas/aud_04_robustez_forma_tiempo.csv`) y no sostiene ninguna
  conclusión de la presentación.

## Qué dice, en lenguaje intuitivo
Se armó la predicción del gasto de un usuario agregando una variable a la vez y
midiendo cuánto baja el error en datos que el modelo no usó para ajustarse. El
error típico de la media sola es 2.74 dólares por usuario. Saber si el usuario
pasó más de 5 minutos en el sitio lo baja a 2.31; las sesiones anteriores, a
2.17; y permitir que el efecto de las sesiones dependa de si pasó más de 5 minutos
(el cruce), a 1.91. Con esas tres piezas el error ya es 1.91 de los 1.87 que
alcanza el modelo completo: dispositivo, sistema operativo y usuario recurrente
bajan el error en 0.005 a 0.029 dólares cada uno, y el registro no lo cambia. Las
medias distintas por dispositivo y sistema operativo de las descriptivas existen,
pero explican poco de la variación del gasto entre usuarios. El orden importa: por
eso la tabla de "aporte sin depender del orden" muestra lo mismo con cada
variable sola y con el modelo completo sin ella, y las tres piezas siguen siendo
las mayores.

## Por qué importa en el estudio
Responde a la Parte A ("¿qué variables resultan más útiles para predecir?"). Para
CheMarket: el registro no mejora la predicción del ingreso una vez que se conocen
el tiempo y las sesiones, pero esto es predictivo y no dice nada sobre el efecto
causal de impulsarlo (eso lo da el experimento; ver
`05_Notas/06_ate_experimento_niveles/B_ols_efecto_registro.md`). Se **mantiene** del Taller 1
la lectura de que el tiempo en el sitio es la variable más informativa; **cambia**
su forma (corte de 5 minutos en lugar de tiempo lineal, ver
`A_corte_5_minutos_captura_tiempo.md`) y **se agrega** el cruce con las sesiones,
que el Taller 1 no consideró (ver `A_lineal_flexible_vs_taller1.md`). La
diferencia es de especificación lineal, no del método ni de la transformación;
sirve de benchmark para los árboles (H4) y para la comparación de importancia que
harán el bosque y LASSO.

## Límites e incertidumbre
- Aporte predictivo en datos históricos, no efecto causal ni importancia causal.
- Los aportes por paso dependen del orden; se reportan también la variable sola y
  el modelo completo sin ella. Quitar el tiempo o las sesiones quita su cruce: los
  0.724 y 0.394 lo incluyen.
- El corte de 5 minutos y el cruce se eligieron mirando las descriptivas de la base
  completa (incluye lo que luego es `test`), no por validación cruzada: puede haber
  algo de ajuste a esas figuras.
- `is_returning_user` equivale a `past_sessions > 0`: su aporte residual es mínimo
  por construcción.
- Los errores estándar entre 5 pliegues son una medida aproximada de la
  variabilidad.

## Historial
- 2026-10-25: la escalera en `ln(Revenue)` pasa al script 04 (sección 9) y sale de
  `00_main.R` (`observacional_escalera_rmse_log`); las cifras son las mismas que
  las de la auditoría. "Parte / base" pasa a incluir el logaritmo.
- 2026-10-25 (auditoría): se agrega la escalera en `ln(Revenue)` (H5 en la escala
  del taller). Mismo orden de aportes que en dólares. Consistente con la importancia
  del árbol y del bosque. El corte de 5 minutos da el 60% de la caída en log, frente
  al 50% en dólares.
- 2026-10-24: la escalera pasa a poner el cruce después de sesiones anteriores
  (pasos 1 a 7); cifras por paso actualizadas. El modelo completo, su RMSE y la
  tabla de prueba no cambian.
- 2026-10-24: se agrega la fila del cruce a la tabla de aporte de cada variable.
- 2026-10-24: el tiempo continuo sale de la escalera (queda el indicador de más de
  5 minutos) por ser redundante con él; los scripts 04 y 05 intercambiaron número.
- 2026-10-24: primera versión; reproduce el RMSE del Taller 1 (2.314 y 2.716).
