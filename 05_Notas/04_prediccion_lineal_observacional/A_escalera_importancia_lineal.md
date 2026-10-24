# En el modelo lineal, pasar más de 5 minutos en el sitio y su cruce con las sesiones anteriores concentran la mejora predictiva; dispositivo, sistema operativo y registro aportan casi nada

- **Estado:** vigente
- **Parte / base:** A; observacional; predictivo (ingreso en dólares)
- **Script de origen:** `02_Scripts/04_prediccion_lineal_observacional.R`
- **Última verificación:** 2026-10-24, con `02_Scripts/04_prediccion_lineal_observacional.R`

## Evidencia
- `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_escalera_rmse.png`
  (RMSE de validación cruzada de 5 pliegues por paso; `Revenue` en dólares;
  entrenamiento, n = 80,000) y su figura
  `03_Resultados/Figuras/04_prediccion_lineal_observacional/observacional_escalera_rmse.png`.
- `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_importancia_variables.png`
  (cada variable sola frente a la media y el modelo completo sin ella).
- `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_rmse_prueba_lineal.png`
  (prueba, una sola vez; n = 20,000).
- Escalera (RMSE de CV, dólares): media 2.741; + más de 5 minutos 2.305;
  + sesiones 2.171; + dispositivo 2.145; + sistema operativo 2.136; + usuario
  recurrente 2.132; + cruce (más de 5 min × sesiones) 1.869; + registro 1.869
  (cambio de −0.00001). El tiempo en minutos (continuo) no es un escalón: la tabla
  `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_robustez_forma_tiempo.png`
  muestra que, con el resto del modelo igual, el RMSE de CV es 1.869 con solo el
  indicador, 1.869 con indicador y tiempo, 1.869 con indicador y una pendiente por
  lado, y 1.873 con solo el tiempo lineal (errores estándar entre pliegues de
  0.008).
- Al quitar una variable del modelo completo, el RMSE sube: más de 5 minutos 0.724,
  sesiones 0.394 (ambas incluyen el cruce), dispositivo 0.030, sistema operativo 0.011, usuario
  recurrente 0.005, registro 0.000 (dólares; errores estándar entre pliegues de
  0.0001 a 0.006).
- Prueba (dólares): ingenuo 2.716; lineal del Taller 1 2.314 (mejora 14.8 %);
  lineal con quiebre, cruce y registro 1.845 (mejora 32.1 %; elimina 53.9 % del
  error cuadrático del ingenuo; RMSE = 46.4 % de la media de 3.98). Brecha prueba
  menos validación: −0.024 a −0.025 en los tres modelos.

## Qué dice, en lenguaje intuitivo
Se armó la predicción del gasto de un usuario agregando una variable a la vez y
midiendo cuánto baja el error en datos que el modelo no usó para ajustarse. El
error típico de la media sola es 2.74 dólares por usuario. Saber si el usuario pasó
más de 5 minutos en el sitio lo baja a 2.31: en las descriptivas el ingreso es plano a cada lado
de ese corte y salta al cruzarlo, así que el tiempo exacto en minutos no agrega
información (ver la tabla de robustez). Las sesiones anteriores lo bajan a 2.17. Dispositivo, sistema operativo y usuario recurrente
apenas lo mueven (entre 0.004 y 0.026 dólares cada uno). El mayor salto
individual viene de permitir que el efecto de las sesiones anteriores dependa de
si el usuario superó los 5 minutos (el cruce): baja el error de 2.13 a 1.87. El
registro, agregado al final, no cambia la predicción. Las medias distintas por
dispositivo y sistema operativo de las descriptivas existen, pero explican muy
poco de la variación del gasto entre usuarios. Fuera de muestra, el modelo con el
cruce tiene un error típico de 1.85 dólares frente a una media de 3.98, por debajo
del lineal del Taller 1 (2.31).

## Por qué importa en el estudio
Responde a la Parte A ("¿qué variables resultan más útiles para predecir?" y "¿qué
se mantiene del Taller 1?"). Se **mantiene** el RMSE del Taller 1 (2.314 y 2.716,
reproducidos con la partición 80/20 y semilla 2026) y la lectura de que el tiempo
en el sitio, a través del corte de 5 minutos, es la variable más informativa. Se
**matiza** su forma: el Taller 1 usó el tiempo en forma lineal; aquí el corte
reemplaza al tiempo continuo. **Cambia** la imagen del modelo
lineal: con el quiebre de 5 minutos y el cruce con las sesiones, el RMSE de prueba
baja de 2.314 a 1.845 sin usar árboles. Esa diferencia es de especificación
lineal, no del método ni de la transformación: sirve de benchmark más exigente
para los árboles (H4), de modo que su ventaja no se infle (ver
`05_Notas/03_punto_partida/A_sesiones_pasadas_interaccion_tiempo.md`, que
sugirió el cruce). Para CheMarket: el registro no mejora la predicción del ingreso
una vez que se conocen tiempo y sesiones, pero esto es predictivo y no dice nada
sobre el efecto causal de impulsarlo (eso lo da el experimento).

## Límites e incertidumbre
- Aporte predictivo en datos históricos, no efecto causal ni importancia causal.
- Los aportes por paso dependen del orden; por eso se reportan también la variable
  sola y el modelo completo sin ella. Quitar el tiempo o las sesiones quita su
  cruce: los 0.724 y 0.394 incluyen esa interacción.
- El corte de 5 minutos viene del Taller 1 y de la descriptiva, no se eligió por
  validación cruzada; el cruce se propuso mirando las figuras de la base completa
  (puede haber algo de ajuste a la descriptiva).
- Esta decisión (dejar solo el indicador) se tomó con la escala en dólares y un
  modelo lineal; en `ln(Revenue)` falta repetir la prueba. Un árbol recupera el
  corte por sí solo.
- `is_returning_user` equivale a `past_sessions > 0`: su aporte residual es
  mínimo por construcción.
- Solo `Revenue` en dólares; falta repetirlo en `ln(Revenue)` y compararlo con
  árboles y LASSO. Los errores estándar entre 5 pliegues son una medida aproximada
  de la variabilidad.

## Historial
- 2026-10-24: el tiempo continuo sale de la escalera (queda el indicador de más de
  5 minutos) por ser redundante con él; cifras de la escalera actualizadas; el
  RMSE de prueba no cambia (1.845). Los scripts 04 y 05 intercambiaron número
  (este es ahora `04_`).
- 2026-10-24: primera versión; reproduce el RMSE del Taller 1 (2.314 y 2.716) y
  agrega la escalera lineal con quiebre y cruce.
