# El logaritmo reduce la cola derecha del ingreso, pero la media en dólares no se recupera con exp()

- **Estado:** vigente
- **Parte / base:** A; observacional; descriptivo (transversal: transformación)
- **Script de origen:** `02_Scripts/07_forma_funcional_observacional.R`
- **Última verificación:** 2026-10-24, con `00_main.R` completo (el script 07 se volvió a correr solo tras un ajuste de formato de la figura)

## Evidencia
- `03_Resultados/Figuras/07_forma_funcional_observacional/observacional_distribucion_ingreso_dos_escalas.png`
- `03_Resultados/Tablas/07_forma_funcional_observacional/observacional_distribucion_ingreso.png` (y `.csv`)
- `03_Resultados/Tablas/07_forma_funcional_observacional/observacional_puente_media_dolares.png` (y `.csv`)
- Base observacional, n = 100,000, muestra completa. `Revenue` en dólares: media 3.98, mediana 3.14, desviación estándar 2.74, asimetría 2.66, curtosis 13.1, percentil 99 de 14.92. `ln(Revenue)`: media 1.22, mediana 1.14, desviación 0.54, asimetría 0.68, curtosis 3.45.
- Media geométrica exp(1.219) = 3.38 dólares frente a la media aritmética de 3.98: el factor de corrección (smearing de Duan sin covariables) es 1.175; con un logaritmo exactamente normal sería exp(varianza/2) = 1.154.

## Qué dice, en lenguaje intuitivo
El ingreso por usuario tiene muchos usuarios con gasto moderado y pocos con gasto muy alto, así que la media (3.98) queda por encima de la mediana (3.14). En logaritmo la distribución es mucho más simétrica y la media y la mediana se acercan (1.22 y 1.14), aunque todavía conserva una cola derecha leve (asimetría 0.68, no 0) y no es exactamente normal.

Cambiar de escala cambia lo que mide un promedio. La media del logaritmo, llevada a dólares con exp(), es la media geométrica: describe al usuario típico y queda cerca de la mediana, no de la media en dólares. Para volver al promedio en dólares hay que multiplicar por un factor de corrección (aquí 1.175). Los percentiles sí se recuperan exactamente con exp(), porque el logaritmo conserva el orden.

## Por qué importa en el estudio
Responde "¿qué cambia al usar `ln(Revenue)`?" (Parte A) y fija cómo leer los coeficientes de toda la Parte B: un coeficiente en logaritmo es un cambio proporcional del ingreso del usuario típico (semielasticidad), no del ingreso promedio en dólares. El cambio es atribuible a la transformación (no hay método aquí). Justifica la transformación con la forma de la distribución (H4); la nota `08_ate_experimento_log/B_log_a_dolares_efecto_registro.md` muestra la consecuencia sobre el efecto del registro.

## Límites e incertidumbre
- Es descriptivo: no hay estimando ni efecto. La diferencia entre medias de las dos escalas no es un sesgo de nadie, sino que cada escala mide una cosa distinta.
- El factor de corrección 1.175 es de la muestra completa; en predicción condicional a covariables el factor es otro (menor, pues los residuos tienen menos dispersión) y debe estimarse con `train`. Pendiente (P2.5).
- Una prueba formal de normalidad no se hizo; la comparación con la normal es visual.

## Historial
- 2026-10-24: primera versión (P1.1).
