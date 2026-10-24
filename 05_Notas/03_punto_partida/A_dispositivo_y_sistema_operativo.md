# Las medianas del ingreso son parecidas entre grupos pero las medias difieren, lo que sugiere diferencias en la cola derecha

- **Estado:** vigente
- **Parte / base:** A; observacional; descriptivo
- **Script de origen:** `02_Scripts/03_punto_partida.R` (ingreso en dólares)
- **Última verificación:** 2026-10-24, con `02_Scripts/03_punto_partida.R`

## Evidencia
- `03_Resultados/Figuras/03_punto_partida/observacional_revenue_dispositivo.png`,
  `.../observacional_revenue_sistema_operativo.png` y
  `.../observacional_revenue_recurrente.png` (densidades del ingreso en dólares
  por grupo, escala log; n = 100,000). Cada panel marca la mediana (línea
  punteada gris) y la media (línea continua) con sus cifras; el n del grupo va en
  el título del panel.
- Cifras en dólares (mediana; media), base observacional, n = 100,000:

  | Grupo | n | Mediana | Media | Media − mediana |
  | --- | --- | --- | --- | --- |
  | Computador | 40,009 | 3.47 | 4.38 | 0.91 |
  | Celular | 50,109 | 2.88 | 3.65 | 0.77 |
  | Tableta | 9,882 | 3.18 | 4.03 | 0.85 |
  | macOS | 30,253 | 3.13 | 4.27 | 1.14 |
  | Windows | 59,838 | 3.14 | 3.86 | 0.72 |
  | Otro sistema | 9,909 | 3.14 | 3.82 | 0.68 |
  | Usuario nuevo | 4,930 | 2.97 | 3.17 | 0.20 |
  | Usuario recurrente | 95,070 | 3.15 | 4.02 | 0.87 |

## Qué dice, en lenguaje intuitivo
Entre sistemas operativos, el usuario "típico" (la mediana) gasta lo mismo, unos
3.13 a 3.14 dólares, pero el promedio de macOS (4.27) queda por encima del de
Windows y otro (3.86 y 3.82). Cuando la mediana coincide y la media no, la
diferencia suele venir de unos pocos usuarios de gasto alto: la cola derecha de
la distribución de macOS es más larga o más pesada. Por usuario nuevo o
recurrente pasa algo parecido, con medianas cercanas (2.97 y 3.15) y medias más
separadas (3.17 y 4.02). Por dispositivo las medianas sí difieren de forma
moderada (2.88 a 3.47), y las medias también (3.65 a 4.38); la brecha entre media
y mediana es parecida en los tres, así que ahí la diferencia es sobre todo un
desplazamiento de toda la distribución y menos de la cola.

La lectura de la cola es una sugerencia, no una medición: las figuras no
cuantifican la cola (por ejemplo con percentiles altos), solo muestran que la
media se separa de la mediana. Esa diferencia podría asociarse a un mayor ingreso
promedio por categoría, no a un gasto típico distinto.

## Por qué importa en el estudio
Responde a la Parte A ("¿qué variables resultan más útiles para predecir?"): el
sistema operativo y el tipo de visita distinguen poco al usuario típico, y su
aporte al promedio vendría de la cola alta. Conecta con el Taller 1, donde el
efecto promedio en nivel también venía de pocos usuarios de gasto alto, y es una
pista para la conciliación entre nivel y logaritmo (el promedio en dólares es
sensible a la cola). Esa comparación se hará con el script
`05_forma_funcional_observacional.R`; esta nota cubre solo el ingreso en dólares.
Aquí no hay tratamiento: es una descripción.

## Límites e incertidumbre
- Asociación descriptiva, no causal.
- Las figuras no muestran intervalos de confianza ni contrastes formales de las
  diferencias de medias; no se afirma que sean estadísticamente distintas.
- La cola derecha no está medida: haría falta una tabla de percentiles altos por
  grupo (p. ej. p90 y p99) para respaldar la lectura.

## Historial
- 2026-10-24: nota creada. Consistente con el Taller 1 en el sentido de que el
  promedio en dólares y las medianas pueden diferir; sin contraparte numérica.
- 2026-10-24: las figuras pasan a mostrar media y mediana con sus cifras junto a
  cada línea; las cifras de las medianas no cambian.
- 2026-10-24: se reformula el hallazgo (medianas parecidas, medias distintas,
  cola derecha como sugerencia), se agregan las medias respaldadas por las figuras
  y el grupo de usuario nuevo o recurrente. Se retira el contraste de medias que
  no tenía archivo de respaldo.
- 2026-10-24: la nota se limita al script 03 (se retiran las cifras en logaritmo)
  y se mueve a `05_Notas/03_punto_partida/`.
