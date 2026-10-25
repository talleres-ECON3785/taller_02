# Los usuarios del experimento se parecen a los de la base histórica, así que el efecto del experimento se puede llevar a la población de CheMarket

- **Estado:** vigente
- **Parte / base:** B; experimento frente a observacional; validación del diseño (validez externa)
- **Script de origen:** `02_Scripts/06_ate_experimento_niveles.R` (sección 2b)
- **Última verificación:** 2026-10-25, con `02_Scripts/06_ate_experimento_niveles.R` (secciones 1 a 3 de `00_main.R` más el script)

## Evidencia
- `03_Resultados/Tablas/06_ate_experimento_niveles/experimento_representatividad.png`
  (y su `.csv`). Experimento, n = 10,000, frente a la base histórica, n = 100,000;
  muestras completas. Diferencia de medias (experimento menos histórico) con
  errores estándar HC1 en tiempo en el sitio, más de 5 minutos, sesiones
  anteriores, usuario recurrente, dispositivo y sistema operativo.
- Ninguna diferencia individual tiene valor p menor que 0.26. La mayor en
  porcentaje es en celular: 50.1 % en la base histórica y 49.8 % en el experimento.
  El tiempo promedio es 4.99 frente a 5.03 minutos y las sesiones anteriores, 3.00
  frente a 3.02.
- Prueba conjunta (Wald con errores HC1 de que las características no predicen la
  base, con la misma especificación que la prueba de balance, `os_type` incluido):
  F = 0.66, valor p = 0.708.

## Qué dice, en lenguaje intuitivo
El experimento se hizo con 10,000 usuarios. La pregunta es si esos usuarios se
parecen a los clientes habituales de CheMarket. La tabla compara las dos bases en
lo que se observa antes del tratamiento. Las proporciones de dispositivo, sistema
operativo, usuarios recurrentes y usuarios que pasan más de 5 minutos son
prácticamente las mismas, y las diferencias son del tamaño que produciría el azar.
Las características, en conjunto, no permiten adivinar de qué base viene un usuario.

## Por qué importa en el estudio
- Sostiene que el ITT (`B_ols_efecto_registro.md`, `../08_ate_experimento_log/`) y
  los CATE por grupo (`../12_heterogeneidad_experimento/B_cate_por_grupo.md`) se
  pueden extrapolar a la población histórica. Esto pesa en la recomendación: la
  regla de focalización se evalúa con los pesos de cada grupo en la base histórica
  (por ejemplo, celular es el 50 % de la base y el 49.8 % del experimento).
- **Se mantiene** frente al Taller 1 (F = 0.65, p = 0.712). Aquí no se replicó la
  especificación del Taller 1: se usa la del balance (con `os_type` y el indicador
  de más de 5 minutos en la tabla). La conclusión no cambia y la cifra casi
  coincide (F = 0.66, p = 0.708). No depende de la transformación ni del método.

## Límites e incertidumbre
- Solo compara las características observadas. No descarta que el experimento
  haya ocurrido en un momento con otra demanda (estacionalidad, precios) ni que
  difieran en variables no medidas.
- Medias parecidas no garantizan las mismas combinaciones de características
  (por ejemplo, la proporción de celular con Windows). Los pesos de cada categoría
  por separado coinciden; las combinaciones no se compararon.
- Con 100,000 observaciones históricas la prueba detectaría diferencias pequeñas.
  Que no las detecte es informativo, pero no prueba igualdad exacta.

## Historial
- 2026-10-25: primera versión (P3.1). Consistente con el Taller 1 y con
  `B_balance_y_cumplimiento.md`.
