# El modelo lineal con corte de 5 minutos y cruce tiene un error de prueba 20.3 % menor que el lineal del Taller 1

- **Estado:** vigente
- **Parte / base:** A; observacional; predictivo (ingreso en dólares)
- **Script de origen:** `02_Scripts/04_prediccion_lineal_observacional.R`
- **Última verificación:** 2026-10-24, con `02_Scripts/04_prediccion_lineal_observacional.R`

## Evidencia
- `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_rmse_prueba_lineal.png`
  (prueba, evaluada una sola vez; `Revenue` en dólares; n = 20,000; modelos
  ajustados con n = 80,000, partición 80/20 con semilla 2026).
- RMSE de prueba (dólares): referencia ingenua 2.716; lineal del Taller 1 2.314
  (mejora de 14.8 % frente a la media, 27.4 % del error cuadrático eliminado);
  lineal con corte de 5 minutos, cruce y registro 1.845 (mejora de 32.1 %, 53.9 %
  del error cuadrático eliminado, RMSE de 46.4 % de la media de 3.98).
- Diferencia entre los dos modelos lineales: 0.469 dólares, 20.3 % del RMSE del
  Taller 1. Brecha prueba menos validación cruzada: −0.024 a −0.025 en los tres
  modelos.

## Qué dice, en lenguaje intuitivo
Con la misma partición y la misma métrica del Taller 1, el modelo del Taller 1
falla en promedio por 2.31 dólares por usuario. Agregarle el corte de 5 minutos y
el cruce entre ese corte y las sesiones anteriores baja ese error a 1.84, unos 47
centavos menos. El error sigue siendo casi la mitad del gasto promedio (3.98): el
modelo predice bastante mejor que antes, pero la mayor parte de la variación del
gasto entre usuarios queda sin explicar por estas variables.

## Por qué importa en el estudio
Responde a la Parte A ("¿cómo se compara con los modelos lineales?"): fija el
benchmark lineal contra el que se medirán los árboles. **Se mantiene** el RMSE del
Taller 1 (2.314 y 2.716, reproducidos); **cambia** el mejor lineal disponible. La
diferencia se atribuye a la especificación lineal (corte y cruce), no al método ni
a la transformación. Consecuencia para los árboles: su ventaja se medirá contra
1.845 y no contra 2.314, para no atribuirle al método lo que logra una especificación
lineal que incorpora la no linealidad y la interacción que la descriptiva mostró.

## Límites e incertidumbre
- La ganancia no implica que el modelo sea más útil para la decisión de negocio ni
  que las variables sean causales.
- El corte y el cruce se eligieron mirando las descriptivas de la base completa
  (incluye `test`): la mejora de prueba puede estar algo inflada por ese
  conocimiento previo, aunque los coeficientes se ajustaron solo con entrenamiento.
- Una sola partición; no se reporta la variabilidad entre particiones. La brecha
  entre prueba y validación cruzada es pequeña (−0.024).
- Solo `Revenue` en dólares; falta la escala logarítmica y no se pueden comparar
  los RMSE entre escalas.

## Historial
- 2026-10-24: primera versión; el modelo del Taller 1 se reproduce (2.314 y 2.716).
