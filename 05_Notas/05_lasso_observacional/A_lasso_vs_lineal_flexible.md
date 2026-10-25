# LASSO reduce el error de prueba 4.3 % frente al lineal con quiebre y cruce, y la mejora viene de los términos que se le ofrecen, no de la regularización

- **Estado:** vigente
- **Parte / base:** A; observacional; predictivo (ingreso en dólares)
- **Script de origen:** `02_Scripts/05_lasso_observacional.R`
- **Última verificación:** 2026-10-24, con `02_Scripts/05_lasso_observacional.R`

## Evidencia
- `03_Resultados/Tablas/05_lasso_observacional/observacional_rmse_prueba_lasso.png`
  y `observacional_rmse_prueba_comparacion_lineales.png` (misma tabla con otro
  título; `.csv` con las cifras sin formato). `Revenue` en dólares; prueba,
  n = 20,000 (evaluada una sola vez); modelos ajustados con entrenamiento,
  n = 80,000; partición 80/20 con semilla 2026 y los mismos 5 pliegues del script 04.
- RMSE de prueba (dólares): referencia ingenua 2.716; lineal del Taller 1 2.314;
  lineal con quiebre, cruce y registro 1.845; LASSO con el λ de menor error de
  validación 1.765 (mejora de 35.0 % frente a la media); LASSO con el λ a un error
  estándar 1.770 (34.8 %). Frente al lineal con quiebre y cruce, 0.080 dólares
  menos (4.3 %, 2.0 % de la media de 3.98); frente al del Taller 1, 0.549 dólares
  menos (23.7 %).
- Parte de la mejora que ya captura el lineal con quiebre y cruce: 85 % de la
  diferencia de RMSE entre el lineal del Taller 1 y LASSO (0.469 de 0.549 dólares)
  y 93 % del error cuadrático que LASSO elimina frente a la media.
- Validación cruzada (entrenamiento): 1.793 (LASSO, λ de menor error) frente a
  1.869 (lineal con quiebre y cruce). Caída pareada por pliegue: 0.076 (error
  estándar 0.003) con el λ de menor error y 0.070 (0.003) con el más regularizado.
  Brecha prueba menos validación: −0.028 en LASSO, −0.024 en el lineal.
- `03_Resultados/Tablas/05_lasso_observacional/observacional_lasso_vs_mco_validacion.png`
  (validación cruzada, sin usar la muestra de prueba): MCO sin penalización con los
  74 términos del diccionario tiene un RMSE de 1.793 y MCO solo con los 63 términos
  que conserva LASSO, 1.793; LASSO con el λ de menor error, 1.793. La diferencia
  pareada entre MCO con los 74 términos y LASSO es de 0.0002 dólares (error
  estándar 0.0002).
- `03_Resultados/Tablas/05_lasso_observacional/observacional_lasso_coeficientes.png`:
  LASSO conserva 63 de 74 términos con el λ de menor error y 38 con el más
  regularizado. El término de mayor coeficiente estandarizado es el cruce (más de 5
  minutos × sesiones anteriores, 2.300 dólares por sesión adicional con el λ de
  menor error); le siguen sesiones anteriores al cuadrado (0.167), más de 5
  minutos × usuario recurrente (−3.237), más de 5 minutos × sesiones anteriores al
  cuadrado y el indicador de más de 5 minutos (1.871).
- `03_Resultados/Figuras/05_lasso_observacional/observacional_lasso_cv_lambda.png`:
  el RMSE de validación cruzada casi no cambia entre los dos λ elegidos y sube a
  medida que el λ aumenta.

## Qué dice, en lenguaje intuitivo
LASSO es una regresión lineal a la que se le ofrece una lista larga de variables y
cruces (74 columnas distintas) y que decide cuáles conservar, achicando los
coeficientes para no sobreajustar. Con ella el error de predicción sobre usuarios
nuevos baja de 1.845 a 1.765 dólares frente al mejor lineal anterior: una
reducción pequeña frente a la que ya había logrado agregar el corte de 5 minutos y
el cruce con las sesiones (de 2.314 a 1.845). El error sigue siendo 44 % de la
media del ingreso.

La mejora viene de términos que el lineal no incluía: cómo el salto de 5 minutos
cambia con el sistema operativo y el dispositivo, y que el efecto de las sesiones
no es una recta (el cuadrado de las sesiones). No viene de
la regularización: ajustar esos mismos términos por mínimos cuadrados, sin
penalización, da el mismo error que LASSO. Con 80,000 observaciones y 74 columnas
casi no hay sobreajuste que corregir, y por eso el λ elegido es muy pequeño.

El tiempo continuo apenas se usa: sus 33 términos tienen un coeficiente
estandarizado máximo de 0.060, frente a 4.093 del cruce. El efecto principal del
registro es prácticamente cero con los dos λ; con el λ de menor error LASSO usa
interacciones del registro con las sesiones anteriores (coeficiente estandarizado
0.268 para sesiones × registro) que desaparecen con el λ más regularizado.

## Por qué importa en el estudio
Responde a la Parte A ("¿cómo se compara con los modelos lineales?") y fija el
benchmark lineal más exigente del catálogo contra el que se medirán los árboles:
1.765, no 2.314 ni 1.845. **Se mantiene** lo de las notas del script 04: el cruce
con las sesiones sigue siendo lo que más usa el modelo, y el tiempo continuo no
aporta una vez que está el corte de 5 minutos. **Se matiza** el lineal con
quiebre y cruce como techo lineal: había interacciones secundarias por explotar,
aunque ya capturaba la mayor parte de la ganancia.

La diferencia se asocia a la especificación (el diccionario más amplio), no a la
regularización ni a la transformación, y tampoco a un método de árboles: sigue
siendo un modelo lineal en `Revenue`. Consecuencia para los árboles: una ganancia
frente a 1.765 mostraría estructura que ninguna especificación lineal con
interacciones de a pares recoge; una ganancia pequeña frente a 1.845 se explicaría
por las mismas interacciones secundarias. Para la decisión de CheMarket: nada de
esto es una conclusión causal sobre el registro.

## Límites e incertidumbre
- Predicción, no causalidad: los términos conservados indican qué usa el modelo,
  no efectos ni importancia causal. El coeficiente estandarizado depende de las
  columnas que se ofrecen (varias están correlacionadas), y los términos con
  coeficiente cercano a cero con un λ y no con el otro no son estables.
- El diccionario incluye el indicador de más de 5 minutos y el cruce, que se
  eligieron mirando la base completa (incluye `test`); la mejora de prueba puede
  estar algo inflada por ese conocimiento previo, en LASSO y en el lineal por igual.
  No se probó un diccionario sin el indicador, que mostraría si LASSO lo recupera
  solo.
- El λ se elige con los mismos pliegues con que se reporta el RMSE de validación
  cruzada, así que esa cifra es algo optimista frente a la del lineal (que no
  elige nada). La cifra de prueba no tiene ese problema. La diferencia de 0.080 es
  una sola partición, sin variabilidad entre particiones.
- El diccionario original tenía 76 columnas, de las cuales dos (el cruce de las
  sesiones y de su cuadrado con "usuario recurrente") repetían exactamente las
  sesiones, porque los usuarios no recurrentes tienen 0 sesiones anteriores; se
  quitaron y el diccionario tiene 74. Con las 76 columnas el RMSE de prueba de
  LASSO era 1.766 y los términos conservados, 49.
- "Usuario recurrente" es lo mismo que tener al menos una sesión anterior (ver
  `03_punto_partida/A_sesiones_pasadas_interaccion_tiempo.md`), así que su término
  (más de 5 minutos × usuario recurrente, −3.237) no se lee solo: compensa el
  efecto de las sesiones y del cruce para quien tiene una o pocas sesiones. Lo
  que el modelo usa es la combinación de los tres términos, no cada uno por
  separado.
- Solo `Revenue` en dólares; falta la escala logarítmica, y los RMSE de ambas
  escalas no son comparables entre sí.

## Historial
- 2026-10-24: primera versión. Coherente con `04_prediccion_lineal_observacional/`
  (misma dirección y escala; reproduce 2.716, 2.314 y 1.845).
- 2026-10-24: corregida la atribución. La primera versión decía que la mejora se
  asociaba "a la especificación y a la regularización"; el chequeo con MCO sin
  penalización muestra que la regularización no aporta. Además se quitaron del
  diccionario dos columnas duplicadas (76 a 74), lo que movió las cifras de
  LASSO: RMSE de prueba 1.766 a 1.765; términos conservados 49 a 63. La
  conclusión no cambia.
- 2026-10-24: se retiró la lectura de "más de 5 minutos × usuario recurrente" como factor propio del salto; es colineal con las sesiones anteriores (no hay recurrentes con 0 sesiones).
- 2026-10-25: contraste con `11_comparacion_prediccion_observacional/X_rmse_metodo_por_escala.md`: el 11 reproduce 1.765 en prueba y el árbol podado baja a 1.627. Es la ganancia "frente a 1.765" que esta nota anticipaba (interacciones de tres variables). Consistente; no cambia la nota.
