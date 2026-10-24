# El ingreso típico casi no cambia por dispositivo ni sistema operativo; las diferencias están en el promedio y en la cola alta

- **Estado:** vigente
- **Parte / base:** A; observacional; descriptivo
- **Última verificación:** 2026-10-24, con `02_Scripts/03_punto_partida.R` y `02_Scripts/04_forma_funcional_observacional.R`

## Evidencia
- `03_Resultados/Figuras/03_punto_partida/observacional_revenue_dispositivo.png`
  y `.../observacional_revenue_sistema_operativo.png` (densidades del ingreso en
  dólares por grupo, escala log; n = 100,000).
- `03_Resultados/Figuras/04_forma_funcional_observacional/observacional_lnrevenue_dispositivo.png`
  y `.../observacional_lnrevenue_sistema_operativo.png` (las mismas densidades en
  `ln(Revenue)`).
- Cifras citadas en las notas al pie de las figuras: medianas del ingreso por
  dispositivo, 3.47 (computador, 40,009 usuarios), 2.88 (celular, 50,109) y 3.18
  dólares (tableta, 9,882). Medianas de `ln(Revenue)` por sistema operativo: 1.14
  en los tres (macOS 30,253; Windows 59,838; otro 9,909).

## Qué dice, en lenguaje intuitivo
Las distribuciones del ingreso de los distintos grupos se parecen mucho: el
usuario "típico" (la mediana) gasta casi lo mismo en cualquier sistema operativo.
Por dispositivo hay diferencias moderadas en el gasto típico, con el celular algo
por debajo del computador. La línea punteada de las figuras marca la mediana, no
el promedio: si dos grupos tienen la misma mediana pero uno tiene una cola de
gasto alto más larga, sus promedios difieren aunque las líneas coincidan.

## Por qué importa en el estudio
Responde a la Parte A ("¿qué variables resultan más útiles para predecir?"): las
dos variables distinguen poco al usuario típico, y se espera que un árbol las use
menos que el tiempo en el sitio. Las diferencias de promedio entre sistemas
operativos, que se observaron al calcularlas aparte, están en la cola alta y son
una pista para la conciliación entre nivel y logaritmo (el promedio en dólares es
sensible a la cola; el logaritmo no). Eso conecta con el Taller 1, donde el efecto
promedio en nivel también venía de pocos usuarios de gasto alto. Aquí no hay
tratamiento: es una descripción y no se atribuye a la transformación ni al método.

## Límites e incertidumbre
- Asociación descriptiva, no causal.
- Los promedios por sistema operativo y su contraste (≈4.27 dólares en macOS
  frente a ≈3.85 en Windows y otro; p < 0.001 en una prueba F de una vía) se
  calcularon fuera de los scripts y **no están respaldados por un archivo de
  `03_Resultados/`**; no deben citarse en la presentación hasta exportar la tabla
  de medias por covariable.
- Las densidades no muestran intervalos de confianza.

## Historial
- 2026-10-24: nota creada. Consistente con el Taller 1 en el sentido de que el
  promedio en dólares y las medianas pueden diferir; sin contraparte numérica.
