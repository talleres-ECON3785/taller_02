# Una vez incluido el corte de 5 minutos, el tiempo exacto en el sitio no reduce más el error de predicción

- **Estado:** vigente
- **Parte / base:** A; observacional; predictivo (ingreso en dólares)
- **Script de origen:** `02_Scripts/04_prediccion_lineal_observacional.R`
- **Última verificación:** 2026-10-24, con `02_Scripts/04_prediccion_lineal_observacional.R`

## Evidencia
- `03_Resultados/Figuras/04_prediccion_lineal_observacional/observacional_orden_tiempo_corte.png`
  (modelos solo de tiempo; RMSE de validación cruzada de 5 pliegues; `Revenue` en
  dólares; entrenamiento, n = 80,000). Con el corte primero: media 2.741, corte
  2.305, corte y tiempo 2.305; agregar el tiempo baja el RMSE 0.000 dólares (error
  estándar 0.000). Con el tiempo primero: 2.500, y agregar el corte lo baja 0.195
  (error estándar 0.002).
- `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_robustez_forma_tiempo.png`
  (resto del modelo igual: sesiones, dispositivo, sistema operativo, usuario
  recurrente, cruce y registro): RMSE de CV 1.869 con solo el corte; 1.873 con solo
  el tiempo lineal; 1.869 con corte y tiempo; 1.869 con corte y una pendiente a cada
  lado (errores estándar entre pliegues de 0.008).

## Qué dice, en lenguaje intuitivo
En las descriptivas el ingreso es casi plano a cada lado de los 5 minutos y salta
al cruzarlos. Saber si el usuario pasó más de 5 minutos resume lo que el tiempo
aporta para predecir: agregar los minutos exactos después de eso no baja el error.
Si el tiempo entra primero, parece muy útil, pero solo porque aproxima el salto: al
agregar el corte el error baja otros 0.195 dólares, y el modelo termina en el mismo
punto.

## Por qué importa en el estudio
Responde a la Parte A ("¿qué relaciones aparecen?, ¿qué se mantiene del Taller
1?"). **Matiza** el Taller 1, que incluyó el tiempo en forma lineal (elasticidad
≈0.17 en logaritmo): en dólares la información del tiempo está en el corte.
Atribución: de forma funcional lineal, no del método ni de la transformación. Para
los árboles: un árbol debería recuperar el corte por sí solo (P2.3). Para el modelo
flexible del taller, el tiempo continuo sale de la especificación.

## Límites e incertidumbre
- Solo en dólares y con un modelo lineal; en `ln(Revenue)` no se probó (el Taller 1
  usó el tiempo en logaritmo).
- El corte de 5 minutos viene del Taller 1 y de la descriptiva, no se eligió por
  validación cruzada.
- No dice que el tiempo "no importe": dice que, dado el corte, los minutos exactos
  no mejoran la predicción. Es una asociación, no un efecto causal.

## Historial
- 2026-10-24: primera versión, a partir de la tabla de robustez y la figura del
  orden de entrada.
- 2026-10-25: contraste con `09_arboles_observacional/A_cart_recupera_corte_5_min.md`: el árbol, con el tiempo continuo y solo con entrenamiento, pone su primer corte en 5.0007 minutos. Consistente; no cambia la nota.
