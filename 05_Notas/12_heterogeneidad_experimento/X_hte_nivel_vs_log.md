# La heterogeneidad aparece en las dos escalas; en dólares se agranda en los usuarios de mayor gasto

- **Estado:** vigente
- **Parte / base:** B (transversal: transformación); experimento; causal
- **Script de origen:** `02_Scripts/12_heterogeneidad_experimento.R`
- **Última verificación:** 2026-10-25, con `00_main.R` completo

## Evidencia
Experimento, n = 10,000, bosques causales de 2,000 árboles sobre `ln(Revenue)` y sobre `Revenue` en dólares. Carpeta `03_Resultados/Tablas/12_heterogeneidad_experimento/`:
- `experimento_ate_lineal_vs_bosque.png`: ATE en dólares del bosque 0.414 (IC 0.328 a 0.499), frente a 0.491 (0.347 a 0.634) de MCO sin controles y 0.454 (0.354 a 0.554) con controles. En logaritmo 0.0037 (−0.011 a 0.019).
- `experimento_calibracion_bosque.png`: coeficiente de diferencias entre usuarios 1.059 (error estándar 0.064) en dólares y 1.013 (0.031) en logaritmo, ambos con p unilateral < 0.001. El coeficiente del promedio en dólares es 1.000 (0.094).
- `experimento_rate_autoc.png` (mitad de evaluación, n = 5,000): AUTOC 1.41 dólares (IC 1.13 a 1.69). Tercil de prioridad alta 1.72 dólares (1.41 a 2.03), baja −0.70 (−0.81 a −0.60).
- `experimento_cate_por_grupo.png`: tiempo en el sitio de 5 minutos o menos, 0.018 en log (−0.001 a 0.036) y 0.16 dólares (0.10 a 0.22); más de 5 minutos, −0.020 en log (−0.045 a 0.006) y 0.84 dólares (0.64 a 1.05). Sesiones: el efecto en dólares crece de −0.19 (0 a 2) a 1.28 (5 o más), y en logaritmo de −0.087 a 0.093.
- `03_Resultados/Figuras/12_heterogeneidad_experimento/experimento_cate_ordenados.png`: en dólares, los efectos estimados por usuario se concentran cerca de cero y tienen una cola derecha larga (percentil 90: 1.55 dólares; hasta unos 10 dólares en el extremo). En logaritmo la distribución es más simétrica (percentiles 10 y 90: −0.28 y 0.32).

## Qué dice, en lenguaje intuitivo
La hipótesis de la Parte B era que el efecto en dólares lo producen pocos usuarios de la cola alta, y que la heterogeneidad se vería en dólares pero no en logaritmo. El resultado es que hay heterogeneidad en las dos escalas, con el mismo orden de grupos: computador, osx y muchas sesiones arriba; celular y pocas sesiones abajo.

Lo que cambia con la escala es el tamaño. Un mismo cambio porcentual vale más dólares en un usuario que gasta mucho. Por eso, en dólares, los efectos se agrandan en los grupos de mayor gasto, como los usuarios con más de 5 minutos en el sitio o con más sesiones. El caso del tiempo en el sitio lo muestra: en porcentaje no hay diferencia entre quienes pasan más o menos de 5 minutos, pero en dólares el efecto es cinco veces mayor para quienes pasan más de 5 minutos, porque gastan más.

## Por qué importa en el estudio
Responde "¿cómo se relaciona la heterogeneidad con el efecto promedio del Taller 1?" y "¿cambia la interpretación con `ln(Revenue)`?" (Parte B; P4.5). **Se mantiene** el efecto promedio en dólares del Taller 1: el bosque da 0.41, dentro del intervalo de MCO. **Se matiza** la hipótesis de la cola: la cola alta en dólares sí refleja usuarios con efectos grandes, pero detrás hay además efectos de signo opuesto que se ven en las dos escalas. La heterogeneidad viene del **método**. Su tamaño en dólares en cada grupo viene de la **transformación**. Para CheMarket, el ingreso total depende del efecto en dólares, que se concentra en computador, osx y usuarios frecuentes. El logaritmo dice si al usuario típico de un grupo le va mejor o peor.

## Límites e incertidumbre
- Los efectos en dólares de la cola dependen de pocos usuarios con gasto alto. Los efectos individuales del extremo derecho tienen intervalos amplios (banda de la figura).
- El ATE del bosque en dólares (0.414) es algo menor que el de MCO sin controles (0.491). Los intervalos se traslapan y con `W.hat = 0.5` sale lo mismo (0.414).
- Los grupos de tiempo y de sesiones usan cortes fijos (5 minutos; 0 a 2, 3 a 4, 5 o más) definidos antes de estimar.

## Historial
- 2026-10-25: primera versión (P4.5).
