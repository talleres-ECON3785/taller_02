# El bosque aleatorio predice casi igual que el árbol podado, y casi todo lo que usa es el tiempo en el sitio y las sesiones anteriores

- **Estado:** vigente
- **Parte / base:** A; observacional; predictivo (ingreso en dólares y en logaritmo)
- **Script de origen:** `02_Scripts/10_bosque_observacional.R`
- **Última verificación:** 2026-10-25, con `02_Scripts/10_bosque_observacional.R`

## Evidencia
- `03_Resultados/Tablas/10_bosque_observacional/observacional_bosque_elegido.png`
  (error fuera de bolsa, entrenamiento, n = 80,000):
  - **Bosque titular:** en las dos escalas, 3 variables sorteadas por corte y tamaño
    mínimo de nodo 100, con 1,000 árboles. RMSE fuera de bolsa de 1.647 en dólares
    (40.0% menos que la media, 2.741) y de 0.350 en logaritmo (34.6% menos que
    0.535).
  - **Bagging** (las 6 variables en cada corte): 1.668 dólares y 0.354 en
    logaritmo.
- `03_Resultados/Figuras/10_bosque_observacional/observacional_bosque_rejilla.png`:
  - con una variable por corte el error es mucho mayor (2.07 dólares; 0.41 en
    logaritmo);
  - con 6 variables y nodos pequeños también sube (1.82 dólares con nodo 5);
  - con 3 variables por corte, el tamaño de nodo casi no cambia el error. El tamaño
    elegido (100) es el borde de la rejilla, y la nota de la tabla declara cuánto
    varía el error.
- `03_Resultados/Figuras/10_bosque_observacional/observacional_bosque_importancia.png`
  (importancia por permutación, % de la suma de cada bosque):
  - en dólares: tiempo en el sitio 57.3%, sesiones anteriores 35.6%, sistema
    operativo 4.7%, dispositivo 2.2%, usuario recurrente 0.3% y registro 0.03%;
  - en logaritmo: tiempo 65.9%, sesiones 28.6%, dispositivo 3.6% y sistema
    operativo 1.6%; usuario recurrente y registro, cerca de 0%.

## Qué dice, en lenguaje intuitivo
Un bosque promedia cientos de árboles, cada uno ajustado con una muestra distinta
de usuarios y con un sorteo de variables en cada corte. El error del bosque es
casi el mismo del árbol podado: 1.647 dólares frente a 1.647 en validación
cruzada. Promediar muchos árboles no agrega estructura que un solo árbol de 9
grupos no capture. La relación que hay que aprender es simple: un salto en 5
minutos, el efecto de las sesiones a partir de ese salto y diferencias menores
por dispositivo y sistema operativo.

La importancia por permutación mide cuánto empeora la predicción si se desordena
una variable al azar. Si se desordena el tiempo en el sitio o las sesiones
anteriores, la predicción empeora mucho. Si se desordena el registro o el usuario
recurrente, casi no cambia. Que el registro no sirva para predecir no quiere decir
que no tenga efecto: dice que, conociendo lo demás, no agrega información sobre el
gasto en la base histórica.

## Por qué importa en el estudio
Responde a la Parte A ("¿qué variables resultan más útiles para predecir
`ln(Revenue)`?"):

- **Se mantiene** el orden de la escalera lineal (tiempo, o su corte en 5 minutos,
  y sesiones primero, luego dispositivo y sistema operativo, y el registro al
  final). Ver `04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md`.
- **Se mantiene** la lectura del Taller 1 de que el registro, en la base
  histórica, no es lo que distingue a quienes gastan más.
- El bosque no mejora al árbol: la ganancia frente a los lineales viene de las
  interacciones que el árbol ya encuentra, no de promediar árboles.
- En logaritmo el tiempo pesa más y las sesiones menos que en dólares. Las sesiones
  están ligadas a los gastos más altos de la cola derecha, que el logaritmo comprime
  (`07_forma_funcional_observacional/X_distribucion_dolares_vs_logaritmo.md`). Es
  una diferencia de la transformación, no del método.

## Límites e incertidumbre
- La importancia indica uso del modelo para predecir, no efecto ni relevancia
  causal.
- La permutación reparte mal el crédito entre variables relacionadas: "usuario
  recurrente" es lo mismo que tener al menos una sesión anterior, así que su
  importancia queda absorbida por las sesiones.
- El error fuera de bolsa no es la validación cruzada de 5 pliegues de los lineales
  y del árbol, aunque mide lo mismo. La comparación limpia es la de prueba
  (`11_comparacion_prediccion_observacional/X_rmse_metodo_por_escala.md`).
- La rejilla se recorrió con 300 árboles. Las diferencias entre las mejores
  combinaciones son menores que 0.01 dólares, así que la elección exacta de los
  hiperparámetros no cambia la conclusión.
- `ranger` usa todos los núcleos disponibles. La semilla fija el resultado en una
  misma máquina, pero con otro número de núcleos las cifras pueden moverse en el
  tercer decimal.

## Historial
- 2026-10-25: primera versión. Coherente con la escalera lineal del script 04 y con
  el árbol del script 09 (mismo orden de importancia; el registro no aporta).
