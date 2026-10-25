# Los patrones que sostienen los controles (corte de 5 minutos y cruce con sesiones) también aparecen en el experimento, con magnitudes algo distintas

- **Estado:** vigente
- **Parte / base:** B (comprobación de los controles); experimento frente a observacional; descriptivo y predictivo, no causal
- **Script de origen:** `02_Scripts/06_ate_experimento_niveles.R` (sección 4)
- **Última verificación:** 2026-10-24, con `02_Scripts/06_ate_experimento_niveles.R` (secciones 1 a 3 de `00_main.R` más el script)

## Evidencia
- Figuras (experimento, n = 10,000, ambos grupos, `Revenue` en dólares), en
  `03_Resultados/Figuras/06_ate_experimento_niveles/`:
  `experimento_revenue_tiempo_sesion.png` (curva loess a cada lado de los 5
  minutos) y `experimento_revenue_tiempo_por_sesiones.png` (una curva por tramo de
  sesiones: 4,177 / 2,234 / 3,589 usuarios).
- Tabla `03_Resultados/Tablas/06_ate_experimento_niveles/experimento_patrones_quiebre_cruce.png`
  (y `.csv`): MCO con los controles del lineal final, errores HC1. Cruce
  (sesiones adicionales con más de 5 minutos): 1.232 (error estándar 0.011) en la
  base histórica, n = 100,000, y 1.690 (0.051) en el experimento. Sesiones con 5
  minutos o menos: 0.032 y 0.044. Salto de más de 5 minutos con 0 sesiones: −0.620
  y −1.582.
- Tabla `.../experimento_escalera_rmse.png` (y `.csv`) y figura
  `.../experimento_escalera_caida_rmse.png`: caída del RMSE de validación cruzada
  (5 pliegues, dólares). Experimento (n = 10,000; media 3.653): más de 5 minutos
  0.415, sesiones 0.180, cruce 0.341, dispositivo 0.080, sistema operativo 0.067,
  usuario recurrente 0.007, asignación 0.010. Base histórica (entrenamiento,
  n = 80,000; media 2.741): 0.436, 0.134, 0.257, 0.029, 0.010, 0.005, 0.000.
  Tiempo en minutos agregado después del corte: −0.001 (error estándar 0.001) en el
  experimento y −0.000 en la histórica.

## Qué dice, en lenguaje intuitivo
En el experimento ocurre lo mismo que en los datos históricos: por debajo de 5
minutos el ingreso es plano (unos 2.9 dólares) sin importar las sesiones previas;
por encima salta, y el salto crece con las sesiones (≈3.4, ≈5.3 y ≈10.5 dólares
para 0 a 2, 3 y 4 o más sesiones, leídos de la figura). Las tres piezas del
modelo lineal (corte, sesiones y cruce) siguen siendo las que más reducen el error,
y el tiempo exacto no agrega nada una vez incluido el corte. Lo que cambia es el
tamaño: el cruce y el aporte de dispositivo y sistema operativo son mayores en el
experimento que en la base histórica, y el aporte de la asignación al registro es
pequeño (0.010), aunque su efecto promedio sea de 0.45 dólares.

## Por qué importa en el estudio
Respalda usar los controles de la Parte A en el experimento (Parte B): son
patrones de la población de usuarios, no un artefacto de la base histórica. Esto
**no** cambia la lectura del ITT (los controles solo ganan precisión). Para el
bosque causal, indica que `time_spent` aporta su información por el corte de 5
minutos y que las sesiones moderan el gasto solo con más de 5 minutos: son
candidatos naturales a moderadores, pero esto es el patrón del ingreso, no
heterogeneidad del efecto (eso lo evalúa el script de heterogeneidad). Diferencia
atribuible a la forma funcional lineal; no involucra el método de árboles ni
`ln(Revenue)`.

## Límites e incertidumbre
- Las dos escalas de RMSE no son directamente comparables en nivel: el ingreso del
  experimento tiene mayor dispersión (media de 3.653 frente a 2.741 de RMSE sin
  covariables), por lo que se comparan las caídas y su orden, no los niveles.
- Los aportes de dispositivo y sistema operativo (0.080 y 0.067 frente a 0.029 y
  0.010) difieren más allá del error estándar entre pliegues (≈0.005); no se
  investigó la causa (muestra de 10,000, otra composición o efecto del
  tratamiento por grupo). No cambia el orden de las variables, pero conviene
  tenerlo presente al estudiar heterogeneidad.
- Validación cruzada sobre toda la muestra del experimento, sin conjunto de prueba:
  no se elige un modelo para predecir.
- Las cifras de las curvas se leyeron de las figuras. Asociaciones, no efectos
  causales.

## Historial
- 2026-10-24: primera versión. Misma dirección y orden de magnitud que
  `04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md` y
  `A_corte_5_minutos_captura_tiempo.md`; magnitudes de cruce, dispositivo y
  sistema operativo mayores en el experimento.
