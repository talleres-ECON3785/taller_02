# El registro facilitado sube el ingreso en computador, osx y usuarios con más sesiones, y lo baja en celular, Windows y usuarios nuevos

- **Estado:** matizado. Los grupos de una sola característica se mantienen; la
  regla de focalización se define con los grupos cruzados dispositivo × sistema
  operativo en [B_regla_focalizacion](../13_focalizacion_experimento/B_regla_focalizacion.md).
- **Parte / base:** B; experimento; causal (efecto por grupo predefinido, bosque causal)
- **Script de origen:** `02_Scripts/12_heterogeneidad_experimento.R`
- **Última verificación:** 2026-10-25, con `12_heterogeneidad_experimento.R` (`W.hat` fijo en la proporción tratada)

## Evidencia

Experimento, n = 10,000. Bosque causal de 2,000 árboles, con la probabilidad de
asignación fija en la proporción tratada (0.496). El efecto de cada grupo es el
promedio doblemente robusto de los efectos individuales del grupo.

Fuentes:
- `03_Resultados/Tablas/12_heterogeneidad_experimento/experimento_cate_por_grupo.png` (y `.csv`);
- `03_Resultados/Figuras/12_heterogeneidad_experimento/experimento_cate_por_grupo.png`.

Columnas: efecto en el gasto del usuario típico, `exp(τ) − 1` (IC 95%; entre
paréntesis, τ en logaritmo) | en dólares (IC 95%) | % de la base histórica.

| Grupo | n | Gasto típico | Dólares | % histórico |
| --- | --- | --- | --- | --- |
| Computador | 4,029 | +17.8% [+15.2%; +20.5%] (0.164) | +1.18 [1.02; 1.33] | 40.0 |
| Celular | 4,975 | −14.1% [−15.9%; −12.4%] (−0.153) | −0.30 [−0.40; −0.20] | 50.1 |
| Tableta | 996 | +14.7% [+9.7%; +19.9%] (0.137) | +0.88 [0.62; 1.14] | 9.9 |
| osx | 3,011 | +24.0% [+20.8%; +27.3%] (0.215) | +1.51 [1.31; 1.71] | 30.3 |
| Windows | 5,991 | −8.6% [−10.3%; −6.8%] (−0.090) | −0.05 [−0.14; 0.04] | 59.8 |
| Otro sistema | 998 | −7.1% [−11.3%; −2.7%] (−0.073) | −0.13 [−0.33; 0.07] | 9.9 |
| Usuario nuevo | 519 | −10.2% [−15.8%; −4.1%] (−0.107) | −0.32 [−0.52; −0.11] | 4.9 |
| Usuario recurrente | 9,481 | +1.0% [−0.5%; +2.5%] (0.010) | +0.45 [0.37; 0.54] | 95.1 |
| 0 a 2 sesiones | 4,177 | −8.3% [−10.3%; −6.1%] (−0.086) | −0.18 [−0.26; −0.11] | 42.3 |
| 3 a 4 sesiones | 3,967 | +5.9% [+3.5%; +8.4%] (0.057) | +0.64 [0.50; 0.78] | 39.2 |
| 5 o más sesiones | 1,856 | +9.7% [+6.0%; +13.5%] (0.092) | +1.27 [0.98; 1.57] | 18.5 |
| Todos | 10,000 | +0.4% [−1.1%; +1.9%] (0.004) | +0.41 [0.33; 0.50] | 100 |

Los grupos de tiempo están en `X_hte_nivel_vs_log.md`. La importancia de las
variables en el bosque causal (`experimento_importancia_bosque_causal.png`) es la
frecuencia con que el bosque corta en cada una, ponderada por la profundidad del
corte. En logaritmo: dispositivo 61% (indicador de celular; 62% con el de tableta),
sistema operativo 21% (indicador de Windows; 24% con el de otro sistema), sesiones
anteriores 9% y tiempo en el sitio 5%.

## Qué dice, en lenguaje intuitivo

Se fijaron de antemano grupos de usuarios y se estimó el efecto del registro
facilitado dentro de cada uno. Hay dos bloques claros:

- **Sube el gasto:** en computador o tableta, con osx o con tres sesiones o más,
  el registro facilitado sube el gasto del usuario típico entre 6% y 24%, y entre
  0.6 y 1.5 dólares por usuario.
- **Lo baja:** en celular, en usuarios que llegan por primera vez o con pocas
  sesiones, lo baja entre 8% y 14%, y entre 0.2 y 0.3 dólares por usuario.
- **Windows:** en logaritmo el efecto es negativo (−8.6%); en dólares, cercano a
  cero.

Los grupos se traslapan entre características, así que no son efectos
independientes que se puedan sumar. Dos traslapes concretos:

- El usuario nuevo es exactamente el que tiene 0 sesiones anteriores, así que está
  contenido en el grupo de 0 a 2 sesiones.
- El sistema operativo **no** es un sustituto del dispositivo. Dentro de cada
  dispositivo, cerca de 30% usa osx, 10% otro sistema y 60% Windows. Por eso el
  efecto por sistema operativo agrega información al del dispositivo, y la regla
  de focalización se define con los dos a la vez
  ([B_regla_focalizacion](../13_focalizacion_experimento/B_regla_focalizacion.md)).

La importancia de variables dice dónde corta el bosque, no qué característica
causa la diferencia.

## Por qué importa en el estudio

Responde tres preguntas de la Parte B: "¿cómo varían los CATE?", "¿qué
características identifican grupos distintos?" y "¿hay grupos con efecto mayor,
menor o cercano a cero?". **Cambia** respecto al Taller 1, que reportó un solo
efecto, y la diferencia se atribuye al **método**. Confirma, ahora con grupos
fijados de antemano e intervalos, la exploración informal de la nota del 08
(`05_Notas/08_ate_experimento_log/B_log_a_dolares_efecto_registro.md`).

Para CheMarket, dar el registro facilitado a todos promedia ganancias en unos
usuarios con pérdidas en otros. La regla que sale de estos resultados, refinada
con los grupos cruzados y evaluada fuera de la muestra en que se eligió, está en
[B_regla_focalizacion](../13_focalizacion_experimento/B_regla_focalizacion.md).

## Límites e incertidumbre

- Son 13 grupos en dos escalas, y los intervalos no se corrigen por comparaciones
  múltiples. La regla de focalización trata la multiplicidad eligiendo los grupos
  en una mitad del experimento y evaluándolos en la otra (Lab 10). Los grupos con
  intervalos que incluyen el cero deben leerse con cautela: usuario recurrente y
  tiempo en el sitio en logaritmo; Windows y otro sistema en dólares.
- Los efectos por grupo no son aditivos y no aíslan qué característica produce la
  diferencia.
- Usuarios nuevos: solo 519 en el experimento (4.9% de la base histórica); su
  intervalo es amplio.

## Historial

- 2026-10-25: primera versión (P4.3 y P4.4).
- 2026-10-25: `W.hat` pasa a la proporción tratada (decisión del usuario, H7). Las
  cifras cambian en decimales menores, sin cambios de signo ni de intervalos que
  crucen el cero; el mayor cambio es "otro sistema" en dólares, de −0.08 a −0.13.
  - Porcentajes con `exp(τ) − 1`.
  - Se elimina "osx es de computadores y tabletas", que es falso según la tabla
    cruzada de la auditoría y `experimento_efecto_celdas_dispositivo_so`.
  - Estado `matizado` con aprobación del usuario: la regla se define en el
    script 13.
