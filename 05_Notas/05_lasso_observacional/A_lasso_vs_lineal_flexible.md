# LASSO reduce el error de prueba 4.3 % frente al lineal con quiebre y cruce, y lo hace con interacciones que ese lineal no tenía

- **Estado:** vigente
- **Parte / base:** A; observacional; predictivo (ingreso en dólares)
- **Script de origen:** `02_Scripts/05_lasso_observacional.R`
- **Última verificación:** 2026-10-24, con `02_Scripts/05_lasso_observacional.R`

## Evidencia
- `03_Resultados/Tablas/05_lasso_observacional/observacional_rmse_prueba_lasso.png`
  (`.csv` con las cifras sin formato). `Revenue` en dólares; prueba, n = 20,000
  (evaluada una sola vez); modelos ajustados con entrenamiento, n = 80,000;
  partición 80/20 con semilla 2026 y los mismos 5 pliegues del script 04.
- RMSE de prueba (dólares): referencia ingenua 2.716; lineal del Taller 1 2.314;
  lineal con quiebre, cruce y registro 1.845; LASSO con el λ de menor error de
  validación 1.766 (mejora de 35.0 % frente a la media); LASSO con el λ a un error
  estándar 1.771 (34.8 %). Frente al lineal con quiebre y cruce, 0.079 dólares
  menos (4.3 %); frente al del Taller 1, 0.548 dólares menos (23.7 %).
- Validación cruzada (entrenamiento): 1.794 (LASSO, λ de menor error) frente a
  1.869 (lineal con quiebre y cruce). Caída pareada por pliegue: 0.075 (error
  estándar 0.003) con el λ de menor error y 0.069 (0.003) con el más regularizado.
  Brecha prueba menos validación: −0.028 en LASSO, −0.024 en el lineal.
- `03_Resultados/Tablas/05_lasso_observacional/observacional_lasso_coeficientes.png`:
  LASSO conserva 49 de 76 términos con el λ de menor error y 38 con el más
  regularizado. El término de mayor coeficiente estandarizado es el cruce
  (más de 5 minutos × sesiones anteriores, 2.204 dólares por sesión adicional con
  el λ de menor error); le siguen más de 5 minutos × usuario recurrente (−2.995),
  sesiones anteriores al cuadrado, más de 5 minutos × sesiones anteriores al cuadrado
  y el indicador de más de 5 minutos (1.749).
- `03_Resultados/Figuras/05_lasso_observacional/observacional_lasso_cv_lambda.png`:
  el RMSE de validación cruzada casi no cambia entre los dos λ elegidos
  (1.794 a 1.799) y sube a medida que el λ aumenta.

## Qué dice, en lenguaje intuitivo
LASSO es una regresión lineal a la que se le ofrece una lista larga de variables y
cruces (76) y que decide cuáles conservar, achicando los coeficientes para no
sobreajustar. Con ella el error de predicción sobre usuarios nuevos baja de 1.85 a
1.77 dólares frente al mejor lineal anterior: una reducción pequeña frente a la
que ya había logrado agregar el corte de 5 minutos y el cruce con las sesiones
(de 2.31 a 1.85). El error sigue siendo 44 % de la media del ingreso.

La mejora viene de términos que el lineal no incluía: cómo el salto de 5 minutos
cambia con el usuario recurrente, el sistema operativo y el dispositivo, y que
el efecto de las sesiones no es una recta (el cuadrado de las sesiones). El
tiempo continuo apenas se usa: sus términos conservados tienen un coeficiente
estandarizado máximo de 0.024, frente a 3.922 del cruce. El efecto principal del
registro es cero con los dos λ; sus interacciones tienen coeficientes estandarizados
de hasta 0.076.

## Por qué importa en el estudio
Responde a la Parte A ("¿cómo se compara con los modelos lineales?") y fija el
benchmark lineal más exigente del catálogo contra el que se medirán los árboles:
1.766, no 2.314 ni 1.845. **Se mantiene** lo de las notas del script 04: el cruce
con las sesiones sigue siendo lo que más usa el modelo, y el tiempo continuo no
aporta una vez que está el corte de 5 minutos. **Se matiza** el lineal con
quiebre y cruce como techo lineal: había interacciones adicionales por explotar.
La diferencia se asocia a la especificación (el diccionario más amplio) y a la
regularización, no a la transformación ni a un método de árboles: sigue siendo un
modelo lineal en `Revenue`. Para la decisión de CheMarket: no hay evidencia en este
script sobre el registro más allá de que no mejora la predicción como efecto
principal; no es una conclusión causal.

## Límites e incertidumbre
- Predicción, no causalidad: los términos conservados indican qué usa el modelo,
  no efectos ni importancia causal. El coeficiente estandarizado depende de las
  columnas que se ofrecen (varias están correlacionadas).
- El diccionario incluye el indicador de más de 5 minutos y el cruce, que se
  eligieron mirando la base completa (incluye `test`); la mejora de prueba puede
  estar algo inflada por ese conocimiento previo. No se probó un diccionario sin
  el indicador, que mostraría si LASSO lo recupera solo.
- El λ se elige con los mismos pliegues con que se reporta el RMSE de validación
  cruzada, así que esa cifra es algo optimista frente a la del lineal (que no
  elige nada). La cifra de prueba no tiene ese problema. La diferencia de 0.079 es
  una sola partición, sin variabilidad entre particiones.
- Solo `Revenue` en dólares; falta la escala logarítmica, y los RMSE de ambas
  escalas no son comparables entre sí.

## Historial
- 2026-10-24: primera versión. Coherente con `04_prediccion_lineal_observacional/`
  (misma dirección y escala; reproduce 2.716, 2.314 y 1.845).
