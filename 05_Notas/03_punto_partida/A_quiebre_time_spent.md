# El ingreso promedio da un salto al pasar de 5 minutos en el sitio y es plano a cada lado

- **Estado:** vigente
- **Parte / base:** A; observacional; descriptivo
- **Script de origen:** `02_Scripts/03_punto_partida.R` (ingreso en dólares)
- **Última verificación:** 2026-10-24, con `02_Scripts/03_punto_partida.R`

## Evidencia
- `03_Resultados/Figuras/03_punto_partida/observacional_revenue_tiempo_sesion.png`
  (ingreso en dólares frente al tiempo en el sitio: curva suavizada loess
  ajustada por separado a cada lado de los 5 minutos, sin banda de confianza;
  n = 100,000, base observacional completa, sin partición de entrenamiento y
  prueba).
- Cifras leídas de la figura (aproximadas; la tabla con las cifras exactas está
  pendiente): el ingreso promedio es ≈2.85 dólares por debajo de 5 minutos y
  ≈5.9 por encima, con la media global en 3.98 dólares (nota al pie).

## Qué dice, en lenguaje intuitivo
Se estimó cómo cambia el ingreso promedio con el tiempo que el usuario pasa en el
sitio. Por debajo de 5 minutos el ingreso promedio es casi el mismo sin importar
cuánto tiempo pasen; por encima de 5 minutos también es casi plano, pero en un
nivel más alto. No es una pendiente suave: es un escalón. Es una asociación
entre dos variables medidas en la misma sesión; no dice que retener al usuario
más tiempo aumente su gasto.

## Por qué importa en el estudio
Responde a la Parte A ("¿qué relaciones aparecen?"). Se **mantiene** la
conclusión del Taller 1 (quiebre en 5 minutos; salto ≈3.13 dólares en la base
observacional frente a ≈3 leído aquí; el Taller 1 lo estimó con otro
procedimiento, así que las cifras no son idénticas). Es la hipótesis que un árbol
de regresión debería recuperar como primera partición; un modelo lineal en el
tiempo no la representa. Esta nota cubre solo el ingreso en dólares: la lectura
en logaritmo se registrará con el script `07_forma_funcional_observacional.R`.

## Límites e incertidumbre
- Asociación, no efecto. El tiempo y el gasto se miden en la misma sesión (posible
  causalidad inversa).
- Cifras leídas de la figura; falta la tabla exportada con medias e intervalos, y
  la curva no lleva banda de confianza (con unas 85,000 observaciones a un lado,
  loess con errores estándar agota la memoria).
- No se probó la ubicación exacta del quiebre en esta nota (el Taller 1 lo hizo, y
  lo confirmó fuera de muestra).

## Historial
- 2026-10-24: nota creada. Contraste con el Taller 1: consistente (misma
  dirección y orden de magnitud). Pendiente: exportar la tabla de medias.
- 2026-10-24: la figura pasa de 50 grupos con intervalos a una curva loess por
  lado de los 5 minutos; mismo patrón. La nota se limita al script 03 y se mueve a
  `05_Notas/03_punto_partida/`.
- 2026-10-24: el corte de 5 minutos se usa como predictor en el modelo lineal (ver `05_Notas/04_prediccion_lineal_observacional/A_corte_5_minutos_captura_tiempo.md`): el tiempo exacto no agrega predicción una vez incluido el corte.
