# El efecto promedio cercano a cero en logaritmo esconde efectos de signo opuesto: hay evidencia formal de heterogeneidad

- **Estado:** vigente
- **Parte / base:** B; experimento; causal (ATE y CATE con bosque causal; prueba formal de heterogeneidad)
- **Script de origen:** `02_Scripts/12_heterogeneidad_experimento.R`
- **Última verificación:** 2026-10-25, con `00_main.R` completo

## Evidencia
Experimento, n = 10,000, bosque causal de 2,000 árboles honestos (`W.hat` estimado por el bosque, entre 0.303 y 0.739, media 0.497). Carpeta `03_Resultados/Tablas/12_heterogeneidad_experimento/` (cada tabla con `.csv`):
- `experimento_ate_lineal_vs_bosque.png`: ATE en `ln(Revenue)` del bosque 0.0037 (IC 95%: −0.011 a 0.019), frente a 0.0134 (−0.010 a 0.037) de MCO sin controles y 0.0065 (−0.009 a 0.022) con controles. Sin tiempo en el sitio: 0.0074 (−0.014 a 0.029).
- `experimento_calibracion_bosque.png` (muestra completa, predicciones fuera de bolsa): coeficiente de las diferencias entre usuarios 1.013 (error estándar 0.031; p unilateral < 0.001) en logaritmo; 0.965 (0.050) sin tiempo en el sitio. El coeficiente del promedio en logaritmo (1.04, error estándar 2.0) no es informativo porque el ATE es casi cero.
- `experimento_rate_autoc.png` (mitad de evaluación, n = 5,000; prioridades fijadas por un bosque estimado con la otra mitad): AUTOC 0.200 (IC 0.180 a 0.221) en logaritmo. Por tercil de prioridad: baja −0.257 (−0.292 a −0.222), media 0.037 (0.002 a 0.073), alta 0.238 (0.202 a 0.275).
- Figuras en `03_Resultados/Figuras/12_heterogeneidad_experimento/`: `experimento_toc.png` (curva TOC) y `experimento_cate_ordenados.png` (efecto fuera de bolsa por usuario con su intervalo: percentil 10 −0.276, mediana 0.046, percentil 90 0.316 en logaritmo; el intervalo excluye el cero por arriba para 35% de los usuarios y por abajo para 32%, sin corrección por comparaciones múltiples).

## Qué dice, en lenguaje intuitivo
El estimando es el efecto del registro facilitado sobre el ingreso de cada tipo de usuario (en logaritmo, un cambio porcentual aproximado). El estimador es un bosque causal, que agrupa a usuarios parecidos y compara tratados y no tratados dentro de cada grupo.

En promedio, el registro facilitado casi no cambia el ingreso del usuario típico (0.4%, intervalo que incluye el cero), como en el Taller 1. Pero ese promedio resulta de sumar efectos que van en direcciones opuestas: para cerca de un tercio de los usuarios el efecto estimado es una caída de alrededor de 25%, y para otro tercio una subida de alrededor de 24%.

Para que esto no sea solo ruido del método se hicieron dos pruebas. En la primera, la de calibración, se pregunta si los usuarios a los que el bosque asigna un efecto mayor efectivamente responden más. La respuesta es sí, y en la proporción que el bosque predice (coeficiente cercano a 1). En la segunda se separa a los usuarios en dos mitades: con una se decide a quién priorizar y con la otra se mide el efecto. Los priorizados de la segunda mitad tienen efectos mayores que el promedio (curva TOC por encima de cero).

## Por qué importa en el estudio
Responde "¿existe evidencia de HTE?" (Parte B). **Se mantiene** la conclusión del Taller 1 sobre el promedio: el ITT en logaritmo no se distingue de cero, y el bosque da lo mismo que MCO. **Cambia** la lectura: el efecto nulo en promedio esconde efectos grandes de signo opuesto. La diferencia se atribuye al **método**, porque la regresión lineal sin interacciones impone un solo efecto para todos. En la misma escala logarítmica, el bosque deja que el efecto varíe. Esto también explica lo que dejó abierto la nota del 08 (`05_Notas/08_ate_experimento_log/B_log_a_dolares_efecto_registro.md`): el tratamiento ensancha la distribución porque sube el ingreso de unos usuarios y baja el de otros. Para CheMarket, la pregunta deja de ser "¿registro facilitado sí o no?" y pasa a ser "¿para quién?" (ver `B_cate_por_grupo.md`).

## Límites e incertidumbre
- La prueba de calibración y la TOC indican que la heterogeneidad existe. No dicen cuáles características la causan: el bosque estima efectos condicionales a las características observadas, y una característica puede estar en lugar de otra no observada.
- Los intervalos de cada efecto individual no se corrigen por comparaciones múltiples. La evidencia formal es la calibración y la TOC, no el número de intervalos que excluyen el cero.
- El tiempo en el sitio se mide en la misma sesión. Sin él, la calibración y los efectos casi no cambian (`experimento_robustez_sin_tiempo.png`).
- `W.hat` estimado varía entre 0.30 y 0.74 por ruido del bosque de propensión. Con `W.hat = 0.5` el ATE en dólares es el mismo (0.414; chequeo de la sesión, no exportado).
- Toda la evidencia viene del experimento. Generalizar a la población histórica requiere que los grupos pesen allí lo mismo (ver los pesos en `B_cate_por_grupo.md`).

## Historial
- 2026-10-25: primera versión (P4.1, P4.2, P4.6 y ATE del bosque de P3.2).
