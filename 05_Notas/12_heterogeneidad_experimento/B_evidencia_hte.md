# El efecto promedio cercano a cero en logaritmo esconde efectos de signo opuesto: hay evidencia formal de heterogeneidad

- **Estado:** vigente
- **Parte / base:** B; experimento; causal (ATE y CATE con bosque causal; prueba formal de heterogeneidad)
- **Script de origen:** `02_Scripts/12_heterogeneidad_experimento.R`
- **Última verificación:** 2026-10-25, con `12_heterogeneidad_experimento.R` (`W.hat` fijo en la proporción tratada)

## Evidencia

Experimento, n = 10,000. Bosque causal de 2,000 árboles honestos, con la
probabilidad de asignación fija en la proporción tratada (0.496). Las tablas están
en `03_Resultados/Tablas/12_heterogeneidad_experimento/` (cada una con `.csv`).

- **ATE** (`experimento_ate_lineal_vs_bosque.png`): en `ln(Revenue)` el bosque da
  0.0039, +0.4% del gasto típico (IC −1.1% a +1.9%). MCO da 0.0134, +1.3% (−1.0% a
  +3.8%), sin controles, y 0.0065 con controles. Sin tiempo en el sitio, el bosque
  da 0.0077 (−0.014 a 0.029).
- **Calibración** (`experimento_calibracion_bosque.png`; muestra completa,
  predicciones fuera de bolsa):
  - coeficiente de las diferencias entre usuarios: 1.01 (error estándar 0.031; p
    unilateral < 0.001) en logaritmo; 0.97 (0.050) sin tiempo en el sitio;
  - el coeficiente del promedio en logaritmo (1.02, error estándar 1.86) no es
    informativo, porque el ATE es casi cero.
- **TOC y AUTOC** (`experimento_rate_autoc.png`; mitad de evaluación, n = 5,000;
  prioridades fijadas por un bosque estimado con la otra mitad):
  - AUTOC 0.200 (IC 0.180 a 0.221) en logaritmo;
  - por tercil de prioridad: baja −22.9% (−25.5% a −20.2%), media +3.7% (+0.2% a
    +7.3%), alta +27.6% (+23.1% a +32.3%).
- **Figuras** en `03_Resultados/Figuras/12_heterogeneidad_experimento/`:
  - `experimento_toc.png`: curva TOC;
  - `experimento_cate_ordenados.png`: efecto fuera de bolsa por usuario con su
    intervalo. En logaritmo, percentil 10 −24.2%, mediana +4.7% y percentil 90
    +37.7%. El intervalo excluye el cero por arriba para el 34% de los usuarios y
    por abajo para el 31%, sin corrección por comparaciones múltiples.

## Qué dice, en lenguaje intuitivo

El estimando es el efecto del registro facilitado sobre el gasto del usuario
típico de cada tipo de usuario (cambio porcentual). El estimador es un bosque
causal, que agrupa a usuarios parecidos y compara tratados y no tratados dentro de
cada grupo.

En promedio, el registro facilitado casi no cambia el gasto del usuario típico
(+0.4%, con un intervalo que incluye el cero), como en el Taller 1. Pero ese
promedio suma efectos que van en direcciones opuestas. Para el tercio de usuarios
con menor prioridad el gasto típico cae cerca de 23%, y para el tercio con mayor
prioridad sube cerca de 28%.

Para comprobar que esto no es solo ruido del método se hicieron dos pruebas:

- **Calibración:** pregunta si los usuarios a los que el bosque asigna un efecto
  mayor responden más. La respuesta es sí, y en la proporción que el bosque predice
  (coeficiente cercano a 1).
- **Muestra dividida:** se separa a los usuarios en dos mitades; con una se decide
  a quién priorizar y con la otra se mide el efecto. Los priorizados de la segunda
  mitad tienen efectos mayores que el promedio (curva TOC por encima de cero).

## Por qué importa en el estudio

Responde "¿existe evidencia de HTE?" (Parte B).

- **Se mantiene** la conclusión del Taller 1 sobre el promedio: el ITT en
  logaritmo no se distingue de cero, y el bosque da lo mismo que MCO.
- **Cambia** la lectura: el efecto nulo en promedio esconde efectos grandes de
  signo opuesto.
- La diferencia se atribuye al **método**. La regresión lineal sin interacciones
  impone un solo efecto para todos; el bosque, en la misma escala logarítmica, deja
  que el efecto varíe.

Esto explica en parte lo que dejó abierto la nota del 08
(`05_Notas/08_ate_experimento_log/B_log_a_dolares_efecto_registro.md`): el
tratamiento ensancha la distribución porque sube el gasto de unos usuarios y baja
el de otros. La conciliación completa entre escalas está en
[X_conciliacion_por_celdas](../13_focalizacion_experimento/X_conciliacion_por_celdas.md).
Para CheMarket, la pregunta deja de ser "¿registro facilitado sí o no?" y pasa a
ser "¿para quién?" (ver
[B_regla_focalizacion](../13_focalizacion_experimento/B_regla_focalizacion.md)).

## Límites e incertidumbre

- La calibración y la TOC indican que la heterogeneidad existe, pero no dicen qué
  características la causan. El bosque estima efectos condicionales a las
  características observadas, y una característica puede estar en lugar de otra no
  observada.
- Los intervalos de cada efecto individual no se corrigen por comparaciones
  múltiples. La evidencia formal es la calibración y la TOC, no el número de
  intervalos que excluyen el cero.
- El tiempo en el sitio se mide en la misma sesión. Sin él, la calibración y los
  efectos casi no cambian (`experimento_robustez_sin_tiempo.png`).
- Toda la evidencia viene del experimento. Generalizar a la población histórica
  requiere que los grupos pesen allí lo mismo (ver los pesos en `B_cate_por_grupo.md`).

## Historial

- 2026-10-25: primera versión (P4.1, P4.2, P4.6 y ATE del bosque de P3.2).
- 2026-10-25: `W.hat` pasa de estimado (rango 0.30 a 0.74) a la proporción tratada
  (decisión del usuario, H7). Las cifras cambian en decimales menores (ATE en log
  de 0.0037 a 0.0039; AUTOC 0.200 igual). Porcentajes con `exp(τ) − 1` (antes
  "caída de 25%" y "subida de 24%" leían puntos de log como porcentajes).
