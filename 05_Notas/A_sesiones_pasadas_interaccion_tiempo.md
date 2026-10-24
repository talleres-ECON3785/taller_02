# Las sesiones pasadas se asocian con más ingreso solo cuando el usuario pasa más de 5 minutos en el sitio

- **Estado:** vigente
- **Parte / base:** A; observacional; descriptivo
- **Última verificación:** 2026-10-24, con `02_Scripts/03_punto_de_partida_observacional.R` y `02_Scripts/04_forma_funcional_observacional.R`

## Evidencia
- `03_Resultados/Figuras/03_punto_de_partida_observacional/observacional_revenue_sesiones_pasadas.png`
  y `03_Resultados/Figuras/04_forma_funcional_observacional/observacional_lnrevenue_sesiones_pasadas.png`
  (ingreso promedio por número de sesiones anteriores, 0 a 10 o más; n = 100,000).
- `03_Resultados/Figuras/03_punto_de_partida_observacional/observacional_revenue_tiempo_por_sesiones.png`
  y `03_Resultados/Figuras/04_forma_funcional_observacional/observacional_lnrevenue_tiempo_por_sesiones.png`
  (ingreso promedio frente al tiempo en el sitio, en tres tramos de sesiones
  pasadas: 0 a 2, 3, y 4 o más; 42,264 / 22,462 / 35,274 usuarios).
- Cifras leídas de las figuras (aproximadas): con 0 a 2 sesiones el ingreso
  promedio es ≈3.15 dólares (≈1.07 en logaritmo) y con 4 o más ≈5.1 (≈1.4). Con
  menos de 5 minutos, los tres tramos tienen el mismo promedio (≈2.85 dólares;
  ≈0.98 en logaritmo). Con más de 5 minutos, ≈3.7 / ≈5.2 / ≈9 dólares y
  ≈1.23 / ≈1.58 / ≈2.12 en logaritmo, de 0 a 2 sesiones a 4 o más.

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
primero por tiempo y luego por sesiones. La diferencia entre modelos que se
observe más adelante vendrá del método (interacciones), no de la transformación:
el patrón se ve igual en dólares y en logaritmo. Para el benchmark lineal
flexible (P2.2) sugiere incluir el cruce entre "más de 5 minutos" y las sesiones.

## Límites e incertidumbre
- Asociación descriptiva; no hay asignación aleatoria ni evidencia causal.
- Los tramos de sesiones se eligieron mirando la figura de sesiones pasadas (0 a
  2 | 3 | 4 o más), así que son una descripción del patrón, no un contraste
  decidido de antemano. Con 3 sesiones el promedio queda en un nivel intermedio.
- Los intervalos de los grupos de 20 cuantiles no se ven en las figuras porque
  son más pequeños que los puntos.
- Cifras leídas de las figuras; falta la tabla exportada.

## Historial
- 2026-10-24: nota creada. Resultado nuevo, sin contraparte en el Taller 1.
