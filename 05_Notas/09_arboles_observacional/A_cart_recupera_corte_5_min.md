# Sin que se le indique, el árbol de regresión encuentra el corte de 5 minutos y la interacción con las sesiones anteriores, y predice con menos error que el lineal con corte y cruce

- **Estado:** vigente
- **Parte / base:** A; observacional; predictivo (ingreso en dólares y en logaritmo)
- **Script de origen:** `02_Scripts/09_arboles_observacional.R`
- **Última verificación:** 2026-10-25, con `02_Scripts/09_arboles_observacional.R`

## Evidencia
- `03_Resultados/Figuras/09_arboles_observacional/observacional_cart_arbol_dolares.png`
  y `observacional_cart_arbol_log.png`: árbol podado con la regla 1-SE (titular,
  declarado antes de ver los resultados), entrenamiento, n = 80,000. El árbol recibe
  las 6 variables del Taller 1, con el tiempo continuo y sin el indicador de 5
  minutos ni el cruce.
- `03_Resultados/Tablas/09_arboles_observacional/observacional_cart_cortes.png`:
  en las dos escalas, el primer corte es tiempo en el sitio < 5.001 minutos (el
  valor exacto es 5.0007). Del lado de 5 minutos o menos, el árbol solo parte por
  dispositivo. Del lado de más de 5 minutos parte por sesiones anteriores (< 3.5 y
  < 2.5), después por sistema operativo (macOS frente a otro o Windows) entre
  quienes tienen 4 sesiones o más, y por último por dispositivo. Son 9 hojas en
  dólares y 10 en logaritmo; la estructura es la misma, salvo un corte de
  dispositivo.
- `03_Resultados/Tablas/09_arboles_observacional/observacional_cart_poda.png`
  (validación cruzada con los 5 pliegues de los scripts 04 y 05, entrenamiento):
  - en dólares, el árbol 1-SE tiene un RMSE de 1.647 (error estándar 0.008) frente
    a 1.869 del lineal con corte y cruce, es decir, 0.222 dólares menos
    (error estándar 0.008);
  - en logaritmo, 0.350 frente a 0.370, es decir, 0.021 menos (error estándar
    0.001).
  - El árbol de la regla del mínimo (13 y 15 hojas) tiene casi el mismo error.
- `03_Resultados/Figuras/09_arboles_observacional/observacional_cart_importancia.png`:
  - en dólares, el tiempo en el sitio concentra el 45.9% de la importancia y las
    sesiones anteriores el 45.0%; sistema operativo y dispositivo, menos del 7%
    cada uno; registro y usuario recurrente, cerca de 0%;
  - en logaritmo, 58.8% y 34.9%, respectivamente.

## Qué dice, en lenguaje intuitivo
Un árbol de regresión parte a los usuarios en grupos con preguntas de sí o no y
predice para cada grupo el promedio del gasto. Nadie le dijo que mirara los 5
minutos: tenía el tiempo en minutos y podía cortar en cualquier valor. La primera
pregunta que eligió es "¿estuvo menos de 5 minutos?". Después, las sesiones
anteriores solo le sirven para quienes pasaron más de 5 minutos, que es la
interacción que las descriptivas y el lineal con cruce ya habían mostrado. Para
quienes estuvieron menos de 5 minutos, lo único que distingue al árbol es el
dispositivo.

El grupo con mayor gasto previsto (12.46 dólares en promedio, 1,524 usuarios de
entrenamiento) combina más de 5 minutos, 4 sesiones anteriores o más, macOS y
computador o tableta. El de menor gasto (2.62 dólares, 25,548 usuarios) es el de
menos de 5 minutos desde el móvil. Con 9 grupos, el árbol se equivoca en promedio
0.22 dólares menos por usuario que el lineal con corte y cruce, en usuarios que no
usó para ajustarse.

## Por qué importa en el estudio
Responde a la Parte A ("¿qué relaciones o patrones aparecen con los métodos
basados en árboles?"):

- **Se mantiene** el quiebre de 5 minutos del Taller 1. Ahora sale de un método
  que lo busca solo y con los datos de entrenamiento. Esto atiende una limitación
  de las notas de los scripts 04 y 05: allí el corte se había fijado mirando toda
  la base. Ver `03_punto_partida/A_quiebre_time_spent.md` y
  `04_prediccion_lineal_observacional/A_corte_5_minutos_captura_tiempo.md`.
- **Se mantiene** la interacción con las sesiones anteriores
  (`03_punto_partida/A_sesiones_pasadas_interaccion_tiempo.md`).
- **Se agrega** que el sistema operativo y el dispositivo importan dentro de
  ciertos grupos (interacciones de tres variables), algo que el lineal con cruce
  no incluye. En logaritmo el árbol usa dispositivo o sistema operativo en 6 de sus
  9 cortes (5 de dispositivo y 1 de sistema operativo), aunque su importancia por
  permutación en el bosque sea baja. Valores de las hojas del árbol en logaritmo
  (`observacional_cart_arbol_log.png`), leídos como `exp(diferencia) − 1`:
  - con 5 minutos o menos, el usuario típico de computador gasta +20% que el de
    celular (1.08 frente a 0.90 en logaritmo);
  - con más de 5 minutos y 4 sesiones o más, el de osx gasta +42% que el de
    Windows u otro sistema (2.38 frente a 2.03).

  Que el árbol use estas variables para predecir **cuánto** gasta un usuario no
  dice cómo responde al registro facilitado. Eso lo mide el experimento, y allí el
  sistema operativo sí cambia el signo del efecto
  (`05_Notas/13_focalizacion_experimento/B_regla_focalizacion.md`).

La ganancia frente al lineal se asocia al método: es la misma variable dependiente
y son las mismas variables, solo que el árbol arma las interacciones solo.
La estructura casi no cambia entre dólares y logaritmo, porque un corte no depende
de una transformación monótona de la variable dependiente. Lo que cambia entre las
dos escalas es cuánto pesa cada grupo en el error. Para CheMarket es una
segmentación descriptiva, no una palanca: no dice qué pasa si se alarga la sesión
de un usuario.

## Límites e incertidumbre
- Predicción, no causalidad: los cortes y la importancia describen cómo predice el
  árbol. No dicen que pasar de 4.9 a 5.1 minutos aumente el gasto. El tiempo se mide
  en la misma sesión que el gasto (posible causalidad inversa, Taller 1).
- La validación cruzada de 5 pliegues es levemente optimista para el árbol: el
  nivel de poda se eligió con todo el entrenamiento. La evaluación sin ese sesgo es
  la de prueba del script 11
  (`11_comparacion_prediccion_observacional/X_rmse_metodo_por_escala.md`).
- Un árbol es inestable: con otra muestra, los cortes de segundo nivel en adelante
  (dispositivo, sistema operativo) podrían cambiar. El primer corte, en 5 minutos,
  es el más robusto, porque coincide con las descriptivas y con el Taller 1.
- La importancia de `rpart` incluye cortes sustitutos y depende de la poda. No es
  comparable con la importancia por permutación del bosque
  (`10_bosque_observacional/A_importancia_bosque.md`).
- Los RMSE en dólares y en logaritmo tienen unidades distintas y no se comparan
  entre sí.

## Historial
- 2026-10-25: primera versión. Coherente con las notas de `03_punto_partida/`,
  `04_prediccion_lineal_observacional/` y `05_lasso_observacional/` (mismo corte,
  misma interacción, registro sin aporte predictivo). Lineal de referencia
  reproducido: 1.869 dólares en validación cruzada.
- 2026-10-25 (auditoría): se agregan los cortes por dispositivo y sistema operativo
  del árbol en logaritmo, con sus diferencias como `exp(diferencia) − 1`. Cifras sin
  cambios: la corrida completa de `00_main.R` reproduce las tablas.
- 2026-10-25 (auditoría): el corte de 5 minutos del lineal se eligió mirando la
  base completa; el árbol, que solo ve entrenamiento, encuentra el mismo corte
  (5.0007) y la misma interacción. Basta declararlo en una nota al pie de la
  diapositiva.
