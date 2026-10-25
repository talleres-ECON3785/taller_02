# Fuera de muestra, los árboles predicen el ingreso con 8% menos error que el mejor lineal (LASSO); la ganancia viene del método, y pasar al logaritmo no cambia el error de los árboles en dólares

- **Estado:** vigente
- **Parte / base:** A; observacional; predictivo (ingreso en dólares y en logaritmo)
- **Script de origen:** `02_Scripts/11_comparacion_prediccion_observacional.R`
- **Última verificación:** 2026-10-25, con `02_Scripts/11_comparacion_prediccion_observacional.R`

## Evidencia
- `03_Resultados/Tablas/11_comparacion_prediccion_observacional/observacional_rmse_prueba_comparacion.png`
  y la figura del mismo nombre en `03_Resultados/Figuras/11_comparacion_prediccion_observacional/`.
  Muestra de prueba, n = 20,000, evaluada una sola vez. Modelos ajustados con
  entrenamiento, n = 80,000. Partición 80/20 con semilla 2026, como en el Taller 1.
  Hiperparámetros elegidos solo con entrenamiento (scripts 05, 09 y 10).
- El script reproduce las cifras previas en dólares: 2.716, 2.314, 1.845 y 1.765.
- **RMSE de prueba**: en dólares para el modelo en dólares, en log para el modelo en
  log, y en dólares para el modelo en log retransformado con *smearing*. Entre
  paréntesis, la mejora frente a la media de la misma columna.

  | Modelo | Modelo en dólares | Modelo en log | Log retransformado a dólares |
  | --- | --- | --- | --- |
  | Media del entrenamiento | 2.716 | 0.534 | 2.716 |
  | Lineal del Taller 1 | 2.314 (14.8%) | 0.452 (15.4%) | 2.382 (12.3%) |
  | Lineal con corte y cruce | 1.845 (32.1%) | 0.369 (30.9%) | 1.952 (28.1%) |
  | LASSO | 1.765 (35.0%) | 0.361 (32.4%) | 1.746 (35.7%) |
  | Árbol podado | 1.627 (40.1%) | 0.349 (34.7%) | 1.627 (40.1%) |
  | Bosque aleatorio | 1.626 (40.1%) | 0.350 (34.6%) | 1.627 (40.1%) |

- Factores de *smearing* de Duan (promedio de la exponencial de los residuos de
  entrenamiento; residuos fuera de bolsa en el bosque): 1.18 en la media, 1.11 en
  el lineal del Taller 1, 1.07 en el lineal con corte y cruce y en LASSO, y 1.06 en
  el árbol y el bosque.

## Qué dice, en lenguaje intuitivo
Con usuarios que los modelos nunca vieron, predecir con un árbol de 9 grupos deja
un error típico de 1.63 dólares por usuario (41% de la media de 3.98 dólares),
frente a 1.76 del mejor modelo lineal y 2.31 del modelo del Taller 1. Un bosque de
1,000 árboles no se equivoca menos que un solo árbol.

Hay dos preguntas distintas en la tabla:

- **El método** (leer la tabla por filas). En la misma escala, los árboles superan
  a todos los lineales. En dólares, el árbol tiene 0.138 dólares menos de error que
  LASSO (7.8%) y 0.218 menos que el lineal con corte y cruce. En logaritmo, 0.012
  menos que LASSO (3.3%).
- **La transformación** (leer la tabla por columnas). Si el modelo se ajusta en
  logaritmo y la predicción se lleva a dólares, el error en dólares de los árboles
  es el mismo, el de los lineales simples empeora y el de LASSO mejora un poco:
  - árboles: 1.627 en las dos versiones;
  - lineal del Taller 1: 2.382 frente a 2.314;
  - lineal con corte y cruce: 1.952 frente a 1.845;
  - LASSO: 1.746 frente a 1.765.

La mejora porcentual frente a la media en logaritmo (34.7% en el árbol) es menor
que en dólares (40.1%). Eso no quiere decir que el modelo en logaritmo prediga peor:
cada escala se compara contra su propia media, y la media en logaritmo ya es una
referencia más difícil de superar, porque la cola derecha queda comprimida.

## Por qué importa en el estudio
Responde a la Parte A: "¿cómo se compara el desempeño de los árboles con el de los
modelos lineales?" y "¿qué cambia al usar `ln(Revenue)`?".

- **Cambia** la mejora sobre la media frente al Taller 1, que pasa de 14.8% a
  40.1%. La atribución es:
  - casi dos tercios vienen de especificar bien el tiempo (corte de 5 minutos y
    cruce, ya en el script 04);
  - un poco más, de las interacciones secundarias (LASSO, script 05);
  - el resto, de que el árbol arme solo interacciones de tres variables. Esa
    última parte es la que aporta el **método** (de 1.765 a 1.627 en dólares).
- La **transformación** no explica la ganancia:
  - en los árboles es neutra para el error en dólares;
  - en los lineales simples cuesta error en dólares, porque el modelo en
    logaritmo predice bien la media geométrica y el factor de *smearing* común no
    alcanza a corregir que la dispersión cambia entre grupos;
  - en LASSO la ganancia es pequeña (0.019 dólares).

  Esto conecta con lo que se vio en la Parte B
  (`08_ate_experimento_log/B_log_a_dolares_efecto_registro.md`): con un factor
  común se pierde la parte del promedio que viene de la dispersión.
- **Se mantiene** del Taller 1 que el modelo explica una parte limitada del gasto:
  el mejor error sigue siendo de 1.63 dólares, el 41% de la media.

Para CheMarket, el árbol es la predicción más precisa de esta comparación y además
se puede leer como una segmentación de 9 grupos. Es una herramienta de predicción
y priorización, no evidencia de qué palanca mueve el gasto.

## Límites e incertidumbre
- Es una sola partición, sin variabilidad entre particiones. La diferencia entre el
  árbol y LASSO en dólares (0.138) es grande frente a los errores estándar entre
  pliegues de entrenamiento (cerca de 0.01). La diferencia entre el árbol y el
  bosque (0.002) no es distinguible.
- El corte de 5 minutos y el cruce de los lineales se eligieron mirando la base
  completa (incluye prueba). Los árboles no reciben esa ayuda, así que, si algo, la
  comparación favorece a los lineales.
- El *smearing* usa un solo factor por modelo, calculado con los residuos de
  entrenamiento (fuera de bolsa en el bosque). Si la dispersión de los residuos
  cambia entre grupos, un factor común sesga la predicción en dólares de algunos
  grupos; esto pesa más en los lineales simples que en los árboles, cuyos grupos
  ya separan a los usuarios de gasto alto.
- Los RMSE en logaritmo y en dólares tienen unidades distintas. La columna "log
  retransformado a dólares" es la única comparable con el Taller 1.
- Predicción, no causalidad.

## Historial
- 2026-10-25: primera versión. Coherente con `04_prediccion_lineal_observacional/`
  y `05_lasso_observacional/` (reproduce 2.716, 2.314, 1.845 y 1.765) y con el
  Taller 1. La celda lineal × logaritmo de esta tabla se calcula aquí con las mismas
  especificaciones del 04 y 05. Si la sesión que pasa esos scripts a logaritmo usa
  otra especificación, hay que contrastarla con esta nota.
