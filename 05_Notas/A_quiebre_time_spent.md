# El ingreso promedio da un salto al pasar de 5 minutos en el sitio y es plano a cada lado, en dólares y en logaritmo

- **Estado:** vigente
- **Parte / base:** A; observacional; descriptivo
- **Última verificación:** 2026-10-24, con `02_Scripts/03_punto_partida.R` y `02_Scripts/04_forma_funcional_observacional.R`

## Evidencia
- `03_Resultados/Figuras/03_punto_partida/observacional_revenue_tiempo_sesion.png`
  (ingreso en dólares, media de 50 grupos de 2,000 usuarios cada uno, n = 100,000).
- `03_Resultados/Figuras/04_forma_funcional_observacional/observacional_lnrevenue_tiempo_sesion.png`
  (el mismo análisis en `ln(Revenue)`).
- Cifras leídas de las figuras (aproximadas; la tabla con las cifras exactas
  está pendiente): en dólares, la media pasa de ≈2.85 por debajo de 5 minutos a
  ≈5.9 por encima. En `ln(Revenue)`, de ≈0.98 a ≈1.62. La media global es 3.98
  dólares y 1.22 en `ln(Revenue)` (nota al pie de cada figura). Base
  observacional completa, sin partición de entrenamiento y prueba.

## Qué dice, en lenguaje intuitivo
Se ordenó a los usuarios por el tiempo que pasaron en el sitio y se calculó el
ingreso promedio de cada grupo. Por debajo de 5 minutos el ingreso promedio es
casi el mismo sin importar cuánto tiempo pasen; por encima de 5 minutos también,
pero en un nivel más alto. No es una pendiente suave: es un escalón. En
logaritmo el salto equivale a un aumento proporcional grande del ingreso
promedio (alrededor de 90 %, leído de la figura). Es una asociación entre dos
variables medidas en la misma sesión; no dice que retener al usuario más tiempo
aumente su gasto.

## Por qué importa en el estudio
Responde a la Parte A ("¿qué relaciones aparecen?"). Se **mantiene** la
conclusión del Taller 1 (quiebre en 5 minutos; salto ≈3.13 dólares en la base
observacional frente a ≈3 leído aquí; el Taller 1 lo estimó con otro
procedimiento, así que las cifras no son idénticas). La forma del patrón es la
misma en las dos escalas, así que la transformación a logaritmo no cambia esta
conclusión descriptiva; solo cambia la lectura (dólares frente a porcentaje). Es
la hipótesis que un árbol de regresión debería recuperar como primera partición;
un modelo lineal en el tiempo no la representa.

## Límites e incertidumbre
- Asociación, no efecto. El tiempo y el gasto se miden en la misma sesión (posible
  causalidad inversa).
- Cifras leídas de la figura; falta la tabla exportada con medias e intervalos.
- Los grupos de 2,000 usuarios dan intervalos del 95 % angostos; no se probó la
  ubicación exacta del quiebre en esta nota (el Taller 1 lo hizo, y lo confirmó
  fuera de muestra).

## Historial
- 2026-10-24: nota creada. Contraste con el Taller 1: consistente (misma
  dirección y orden de magnitud). Pendiente: exportar la tabla de medias.
