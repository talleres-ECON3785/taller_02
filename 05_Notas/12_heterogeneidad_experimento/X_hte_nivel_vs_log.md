# La heterogeneidad aparece en las dos escalas; en dólares se agranda en los usuarios de mayor gasto

- **Estado:** vigente. La conciliación cuantitativa está en
  [X_conciliacion_por_celdas](../13_focalizacion_experimento/X_conciliacion_por_celdas.md).
- **Parte / base:** B (transversal: transformación); experimento; causal
- **Script de origen:** `02_Scripts/12_heterogeneidad_experimento.R`
- **Última verificación:** 2026-10-25, con `12_heterogeneidad_experimento.R` (`W.hat` fijo en la proporción tratada)

## Evidencia

Experimento, n = 10,000. Bosques causales de 2,000 árboles sobre `ln(Revenue)` y
sobre `Revenue` en dólares. Las tablas están en
`03_Resultados/Tablas/12_heterogeneidad_experimento/`.

- **ATE** (`experimento_ate_lineal_vs_bosque.png`): en dólares, el bosque da 0.414
  (IC 0.330 a 0.498), frente a 0.491 (0.347 a 0.634) de MCO sin controles y 0.454
  (0.354 a 0.554) con controles. En logaritmo, +0.4% del gasto típico (−1.1% a
  +1.9%).
- **Calibración** (`experimento_calibracion_bosque.png`): coeficiente de las
  diferencias entre usuarios 1.06 (error estándar 0.068) en dólares y 1.01 (0.031)
  en logaritmo, ambos con p unilateral < 0.001. El coeficiente del promedio en
  dólares es 1.00 (0.096).
- **TOC y AUTOC** (`experimento_rate_autoc.png`; mitad de evaluación, n = 5,000):
  AUTOC 1.42 dólares (IC 1.15 a 1.70). Tercil de prioridad alta: 1.73 dólares
  (1.42 a 2.03); baja: −0.68 (−0.78 a −0.59).
- **Grupos** (`experimento_cate_por_grupo.png`):
  - tiempo en el sitio de 5 minutos o menos: +1.8% del gasto típico (−0.0% a
    +3.7%) y 0.16 dólares (0.10 a 0.22);
  - más de 5 minutos: −1.9% (−4.3% a +0.5%) y 0.84 dólares (0.64 a 1.05);
  - sesiones: el efecto en dólares crece de −0.18 (0 a 2) a 1.27 (5 o más), y en
    el gasto típico de −8.3% a +9.7%.
- **Efectos por usuario**
  (`03_Resultados/Figuras/12_heterogeneidad_experimento/experimento_cate_ordenados.png`):
  en dólares se concentran cerca de cero y tienen una cola derecha larga
  (percentil 90: 1.57 dólares). En logaritmo la distribución es más simétrica
  (percentiles 10 y 90: −24.2% y +37.7%).

## Qué dice, en lenguaje intuitivo

La hipótesis de la Parte B era que el efecto en dólares lo producen pocos usuarios
de la cola alta, y que la heterogeneidad se vería en dólares pero no en
logaritmo. El resultado es que hay heterogeneidad en las dos escalas, con el mismo
orden de grupos: computador, osx y muchas sesiones arriba; celular y pocas
sesiones abajo.

Lo que cambia con la escala es el tamaño. En dólares, los efectos se agrandan en
los grupos de mayor gasto, como los usuarios con más de 5 minutos en el sitio o
con más sesiones. El caso del tiempo en el sitio lo muestra: en porcentaje del
gasto típico no hay diferencia entre quienes pasan más o menos de 5 minutos, pero
en dólares el efecto es cinco veces mayor para quienes pasan más de 5 minutos.

Esa diferencia no se explica solo porque ese grupo gaste más. Un efecto
proporcional cercano a cero no produce 0.84 dólares. Dentro del grupo hay usuarios
con efectos de signo opuesto (por dispositivo y sistema operativo), y el
tratamiento sube la media en dólares más de lo que mueve el gasto típico. La
cuantificación está en
[X_conciliacion_por_celdas](../13_focalizacion_experimento/X_conciliacion_por_celdas.md).

## Por qué importa en el estudio

Responde "¿cómo se relaciona la heterogeneidad con el efecto promedio del Taller
1?" y "¿cambia la interpretación con `ln(Revenue)`?" (Parte B; P4.5).

- **Se mantiene** el efecto promedio en dólares del Taller 1: el bosque da 0.41,
  dentro del intervalo de MCO.
- **Se matiza** la hipótesis de la cola: la cola alta en dólares sí refleja
  usuarios con efectos grandes, pero detrás hay además efectos de signo opuesto que
  se ven en las dos escalas.
- La heterogeneidad viene del **método**. Su tamaño en dólares en cada grupo viene
  de la **transformación** (gasto base distinto y ensanchamiento de la
  distribución dentro del grupo).
- Para CheMarket, el ingreso total depende del efecto en dólares, y el logaritmo
  dice si al usuario típico de un grupo le va mejor o peor. La regla de
  focalización usa las dos escalas y coinciden
  ([B_regla_focalizacion](../13_focalizacion_experimento/B_regla_focalizacion.md)).

## Límites e incertidumbre

- Los efectos en dólares de la cola dependen de pocos usuarios con gasto alto. Los
  efectos individuales del extremo derecho tienen intervalos amplios (banda de la
  figura).
- El ATE del bosque en dólares (0.414) es algo menor que el de MCO sin controles
  (0.491). La diferencia equivale a un error estándar de MCO, los intervalos se
  traslapan y no depende de cómo se fije la probabilidad de asignación (0.414 con
  ella estimada o fija).
- Los grupos de tiempo y de sesiones usan cortes fijos (5 minutos; 0 a 2, 3 a 4, 5
  o más) definidos antes de estimar.

## Historial

- 2026-10-25: primera versión (P4.5).
- 2026-10-25: `W.hat` pasa a la proporción tratada (decisión del usuario, H7); las
  cifras cambian en decimales menores. Porcentajes con `exp(τ) − 1`. Se agrega que
  el efecto de 0.84 dólares con más de 5 minutos no se explica solo por el gasto
  base, con enlace a la conciliación del script 13.
