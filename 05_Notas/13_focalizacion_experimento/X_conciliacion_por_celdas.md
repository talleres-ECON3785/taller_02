# El efecto es ≈ 0 en logaritmo y +0.41 dólares porque los grupos tienen efectos de signo opuesto (método) y, en dólares, pesan más los que gastan más y el tratamiento ensancha el gasto dentro de cada grupo (transformación)

- **Estado:** vigente
- **Parte / base:** B (transversal: transformación frente a método); experimento; causal
- **Script de origen:** `02_Scripts/13_focalizacion_experimento.R`
- **Última verificación:** 2026-10-25, con `13_focalizacion_experimento.R`

## Evidencia

Fuente: `03_Resultados/Tablas/13_focalizacion_experimento/experimento_conciliacion_celdas.png`
y `.csv`. Experimento, n = 10,000; bosque causal de 2,000 árboles; efectos por grupo
dispositivo × sistema operativo (9 grupos).

- **Signos opuestos:** el promedio ponderado de los efectos por grupo reproduce el
  efecto promedio en las dos escalas: 0.0039 en logaritmo y 0.414 dólares. El 65%
  de los usuarios está en grupos con efecto positivo en logaritmo y el 35% en
  grupos con efecto negativo.
- **Gasto base:** el gasto medio del grupo control es de 4.16 dólares en los grupos
  con efecto positivo y de 3.64 en los negativos.
- **Lo implicado por el efecto proporcional de cada grupo** (gasto medio del
  control × (exp(τ) − 1)):
  - con un gasto base común (3.98): 0.10 dólares;
  - con el gasto base de cada grupo: 0.17 dólares;
  - frente a un efecto en dólares de 0.41.
- **Partición más fina** (dispositivo × sistema operativo × sesiones anteriores;
  solo grupos con 100 usuarios o más, que cubren a 9,601). En esa población el
  efecto en dólares es 0.391, y lo implicado sube de 0.149 a 0.218 dólares. El resto
  dentro de los grupos baja de 0.241 a 0.172: las sesiones absorben el 29%.

## Qué dice, en lenguaje intuitivo

El efecto en logaritmo responde "¿cuánto cambia el gasto del usuario típico?", y
el efecto en dólares, "¿cuánto cambia el gasto promedio?". Los dos números no se
contradicen. Tres cosas los separan:

1. **Signos opuestos (método).** Un tercio de los usuarios gasta menos con el
   registro facilitado y dos tercios gastan igual o más. En porcentaje, eso se
   cancela casi por completo. Solo un método que deja variar el efecto entre
   grupos lo ve.
2. **Quién gasta más (transformación).** Los grupos que ganan ya gastaban algo más,
   así que un mismo porcentaje vale más dólares en ellos. Esto lleva el efecto
   implicado de 0.10 a 0.17 dólares.
3. **Ensanchamiento dentro de los grupos (transformación).** Dentro de cada grupo el
   registro facilitado sube más la media en dólares que el gasto típico: los que
   más gastan aumentan su gasto más que el resto. Parte de esto son diferencias por
   sesiones anteriores dentro del grupo. Lo que queda (0.17 de 0.39 dólares) es lo
   máximo que puede atribuirse a la transformación.

## Por qué importa en el estudio

Responde "¿cambia el ATE y su interpretación con `ln(Revenue)`?" y "¿cómo se
relaciona la heterogeneidad con el efecto promedio del Taller 1?" (Parte B, H2).
**Cambia** frente al Taller 1, que dejó sin conciliar el 0.49 en dólares y el 0.013
en logaritmo, y frente a la primera versión de la síntesis, que atribuía toda la
diferencia a la transformación. La atribución correcta es **ambos**: la
heterogeneidad de signo entre grupos (método) explica por qué el efecto en
logaritmo es ≈ 0, y el gasto base distinto y el ensanchamiento dentro de los grupos
(transformación) explican por qué en dólares queda positivo.

Para CheMarket, la decisión se toma con el efecto en el gasto típico de cada
grupo, y el efecto en dólares dice cuánto pesa cada grupo en el ingreso. Las dos
escalas llevan a la misma regla
([B_regla_focalizacion](B_regla_focalizacion.md)).

## Límites e incertidumbre

- El resto dentro de los grupos finos (0.17 dólares) es una cota superior de la
  transformación: puede incluir diferencias por características que no se usaron
  para formar los grupos, como el tiempo en el sitio.
- La partición fina deja fuera 399 usuarios de grupos con menos de 100.
- Las cantidades "implicadas" no tienen intervalo. Son una descomposición contable
  de efectos estimados, no estimaciones nuevas.

## Historial

- 2026-10-25: primera versión, a partir de la auditoría
  (`10_Auditoria/informe_auditoria.md`) y del script 13, aprobado por el usuario.
