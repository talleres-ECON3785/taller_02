# El registro facilitado sube el ingreso en computador, osx y usuarios con más sesiones, y lo baja en celular, Windows y usuarios nuevos

- **Estado:** vigente
- **Parte / base:** B; experimento; causal (efecto por grupo predefinido, bosque causal)
- **Script de origen:** `02_Scripts/12_heterogeneidad_experimento.R`
- **Última verificación:** 2026-10-25, con `00_main.R` completo

## Evidencia
Experimento, n = 10,000. Bosque causal de 2,000 árboles; el efecto de cada grupo es el promedio doblemente robusto de los efectos individuales del grupo. `03_Resultados/Tablas/12_heterogeneidad_experimento/experimento_cate_por_grupo.png` (y `.csv`) y `03_Resultados/Figuras/12_heterogeneidad_experimento/experimento_cate_por_grupo.png`. Efecto en `ln(Revenue)` (IC 95%) | en dólares (IC 95%) | % de la base histórica:

| Grupo | n | Log | Dólares | % histórico |
| --- | --- | --- | --- | --- |
| Computador | 4,029 | 0.163 (0.140 a 0.186) | 1.18 (1.03 a 1.34) | 40.0 |
| Celular | 4,975 | −0.152 (−0.173 a −0.131) | −0.30 (−0.40 a −0.20) | 50.1 |
| Tableta | 996 | 0.138 (0.093 a 0.183) | 0.88 (0.62 a 1.14) | 9.9 |
| osx | 3,011 | 0.213 (0.186 a 0.240) | 1.50 (1.30 a 1.70) | 30.3 |
| Windows | 5,991 | −0.089 (−0.108 a −0.070) | −0.05 (−0.14 a 0.04) | 59.8 |
| Otro sistema | 998 | −0.070 (−0.117 a −0.023) | −0.08 (−0.29 a 0.12) | 9.9 |
| Usuario nuevo | 519 | −0.112 (−0.178 a −0.045) | −0.33 (−0.55 a −0.12) | 4.9 |
| Usuario recurrente | 9,481 | 0.010 (−0.005 a 0.025) | 0.45 (0.37 a 0.54) | 95.1 |
| 0 a 2 sesiones | 4,177 | −0.087 (−0.110 a −0.064) | −0.19 (−0.26 a −0.11) | 42.3 |
| 3 a 4 sesiones | 3,967 | 0.057 (0.034 a 0.081) | 0.64 (0.50 a 0.78) | 39.2 |
| 5 o más sesiones | 1,856 | 0.093 (0.058 a 0.128) | 1.28 (0.98 a 1.57) | 18.5 |
| Todos | 10,000 | 0.004 (−0.011 a 0.019) | 0.41 (0.33 a 0.50) | 100 |

Los grupos de tiempo están en `X_hte_nivel_vs_log.md`. Importancia (`experimento_importancia_bosque_causal.png`): en logaritmo, el bosque corta 61% de las veces en celular frente a computador, 21% en Windows frente a osx, 9% en sesiones anteriores y 5% en tiempo en el sitio.

## Qué dice, en lenguaje intuitivo
Se fijaron de antemano grupos de usuarios y se estimó el efecto del registro facilitado dentro de cada uno. Hay dos bloques claros. En computador o tableta, con osx o con tres sesiones o más, el registro facilitado sube el ingreso del usuario típico entre 6% y 21%, y en dólares entre 0.6 y 1.5 por usuario. En celular, en usuarios que llegan por primera vez o en usuarios con pocas sesiones, lo baja entre 9% y 15%, y entre 0.2 y 0.3 dólares por usuario. En Windows, el efecto en logaritmo es negativo (−9%) y en dólares es cercano a cero.

Los grupos se traslapan (dispositivo y sistema operativo van juntos: osx es de computadores y tabletas), así que no son efectos independientes que se puedan sumar. La importancia de variables dice que el bosque separa sobre todo por dispositivo y sistema operativo. Eso indica dónde corta el bosque, no que el dispositivo cause la diferencia.

## Por qué importa en el estudio
Responde "¿cómo varían los CATE?", "¿qué características identifican grupos distintos?" y "¿hay grupos con efecto mayor, menor o cercano a cero?" (Parte B). **Cambia** respecto al Taller 1, que reportó un solo efecto. La diferencia se atribuye al **método**. Confirma, ahora con grupos fijados de antemano e intervalos, la exploración informal de la nota del 08 (`05_Notas/08_ate_experimento_log/B_log_a_dolares_efecto_registro.md`).

Para CheMarket, hacer el registro facilitado para todos promedia ganancias en unos usuarios con pérdidas en otros. Los usuarios de celular son la mitad de la base histórica (50%) y su efecto es negativo en las dos escalas. Una implementación focalizada en computador y tableta (50% de la base histórica) evitaría esa pérdida, siempre que el mecanismo detrás de la diferencia por dispositivo se mantenga fuera del experimento.

## Límites e incertidumbre
- Son 13 grupos en dos escalas, y los intervalos no se corrigen por comparaciones múltiples. Para dispositivo, sistema operativo y sesiones, los intervalos quedan lejos del cero, así que la corrección no cambiaría la conclusión. Los grupos con intervalos cerca de cero (recurrentes en logaritmo, Windows y otro sistema en dólares) deben leerse con cautela.
- Los efectos por grupo no son aditivos y no aíslan qué característica produce la diferencia.
- Usuarios nuevos: solo 519 en el experimento (4.9% de la base histórica). Su intervalo es amplio.
- La propuesta de focalizar es una implicación por evaluar, no un resultado probado: no se ha estimado el ingreso de una regla de focalización frente a dar el registro a todos.

## Historial
- 2026-10-25: primera versión (P4.3 y P4.4).
