# Las sesiones pasadas se asocian con más ingreso solo cuando el usuario pasa más de 5 minutos en el sitio

- **Estado:** vigente
- **Parte / base:** A; observacional; descriptivo
- **Script de origen:** `02_Scripts/03_punto_partida.R` (ingreso en dólares)
- **Última verificación:** 2026-10-24, con `02_Scripts/03_punto_partida.R`

## Evidencia
- `03_Resultados/Figuras/03_punto_partida/observacional_revenue_sesiones_pasadas.png`
  (ingreso promedio en dólares por número de sesiones anteriores, 0 a 10 o más;
  n = 100,000).
- `03_Resultados/Figuras/03_punto_partida/observacional_revenue_tiempo_por_sesiones.png`
  (ingreso promedio frente al tiempo en el sitio, una curva suavizada por tramo
  de sesiones pasadas: 0 a 2, 3, y 4 o más; 42,264 / 22,462 / 35,274 usuarios;
  un solo panel, curvas loess ajustadas por separado a cada lado de los 5
  minutos, bandas del 95 %).
- Cifras leídas de las figuras (aproximadas, en dólares): con 0 a 2 sesiones el
  ingreso promedio es ≈3.15 y con 4 o más ≈5.1. Con menos de 5 minutos, los tres
  tramos tienen el mismo promedio (≈2.85). Con más de 5 minutos, ≈3.7 / ≈5.2 / ≈9
  dólares, de 0 a 2 sesiones a 4 o más.

## Qué dice, en lenguaje intuitivo
El ingreso promedio es más alto entre los usuarios con 4 o más visitas previas,
pero esa diferencia no aparece entre quienes pasan menos de 5 minutos en el
sitio: ahí todos gastan lo mismo en promedio. La diferencia por visitas previas
aparece entre quienes pasan más de 5 minutos. Es decir, el efecto de una
variable depende del nivel de la otra: es una interacción. En esta base ser
"usuario recurrente" equivale a tener al menos una sesión previa, así que esa
variable no agrega información por sí sola (la figura de usuario recurrente
resume el contraste entre 0 y 1 o más sesiones).

## Por qué importa en el estudio
Responde a la Parte A ("¿qué patrones aparecen con los árboles?"). Es una
conclusión **nueva** respecto al Taller 1, que describió las dos variables por
separado. Un modelo lineal sin término cruzado impone que el efecto de las
sesiones pasadas es el mismo para todos los tiempos; un árbol puede dividir
primero por tiempo y luego por sesiones. Para el benchmark lineal flexible
(P2.2) sugiere incluir el cruce entre "más de 5 minutos" y las sesiones. Esta nota
cubre solo el ingreso en dólares: si el patrón se mantiene en logaritmo se
registrará con el script `04_forma_funcional_observacional.R`.

## Límites e incertidumbre
- Asociación descriptiva; no hay asignación aleatoria ni evidencia causal.
- Los tramos de sesiones se eligieron mirando la figura de sesiones pasadas (0 a
  2 | 3 | 4 o más), así que son una descripción del patrón, no un contraste
  decidido de antemano. Con 3 sesiones el promedio queda en un nivel intermedio.
- Las curvas son suavizados (loess, `span = 0.5`) de las observaciones, no
  estimaciones de un modelo; el tramo de más de 25 minutos no se muestra porque
  tiene pocos usuarios y bandas muy anchas. El ajuste por separado a cada lado
  de los 5 minutos supone el quiebre que se quiere mostrar.
- Cifras leídas de las figuras; falta la tabla exportada.

## Historial
- 2026-10-24: nota creada. Resultado nuevo, sin contraparte en el Taller 1.
- 2026-10-24: la figura `_tiempo_por_sesiones` pasa de tres paneles con 20
  grupos por tramo a un solo panel con curvas loess (a pedido del usuario; se
  probó también un promedio móvil y se descartó). Mismo patrón; las cifras
  siguen leídas de las figuras.
- 2026-10-24: la nota se limita al script 03 (se retiran las cifras en logaritmo)
  y se mueve a `05_Notas/03_punto_partida/`.
