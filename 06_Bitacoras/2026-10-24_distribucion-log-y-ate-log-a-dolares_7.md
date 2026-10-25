# Bitácora — 2026-10-24: distribución de `Revenue` frente a `ln(Revenue)` y del ITT en logaritmo a dólares

## Resumen
El usuario pidió analizar la diferencia de distribución entre `Revenue` y `ln(Revenue)` y sus implicaciones para las estimaciones: los coeficientes en logaritmo son semielasticidades y devolverlos a dólares exige manejo cuidadoso. Se trabajó P1.1 (densidad en las dos escalas) y la parte en logaritmo de P3.2 y P3.3 (ITT en `ln(Revenue)`, retransformación, cuantiles por grupo y cola).

Hallazgo central: el tratamiento (`easier_signup`) casi no mueve la media de `ln(Revenue)` (coeficiente 0.0134, +1.35% en el usuario típico, IC 95% de −0.010 a 0.037) pero sube la media en dólares 12.3% (0.491). La media de `ln(Revenue)` no cambia casi nada porque el tratamiento ensancha la distribución (desviación estándar de 0.53 a 0.66). Una retransformación con un factor de smearing común a los dos grupos da 0.057 dólares; con un factor por grupo recupera 0.491.

El script nuevo salió primero como `10_ate_experimento.R` (nombre previsto), se renombró a `08_ate_experimento.R` por pedido del usuario (los previstos se corrieron una posición) y luego a `08_ate_experimento_log.R`. `00_main.R` completo corre sin errores (8 scripts), con las carpetas del 08 vaciadas antes.

Objetivos de `HANDOFF.md`: (1) P1.1 cerrado; P1.3 y cierre de P1.2 no se trabajaron. (2) y (3) no se trabajaron. Avanzaron P3.2 (ITT en log) y P3.3 (cuantiles, cola).

## Archivos
- Creados: `02_Scripts/08_ate_experimento_log.R`; `03_Resultados/{Tablas,Figuras}/08_ate_experimento_log/`; `03_Resultados/Tablas/07_forma_funcional_observacional/`; `03_Resultados/Figuras/07_forma_funcional_observacional/observacional_distribucion_ingreso_dos_escalas.png`; `05_Notas/07_forma_funcional_observacional/X_distribucion_dolares_vs_logaritmo.md`; `05_Notas/08_ate_experimento_log/B_log_a_dolares_efecto_registro.md`.
- Modificados: `02_Scripts/07_forma_funcional_observacional.R`, `00_main.R`, `CLAUDE.md` (decisión), `README.md`, `PLAN.md`, `HANDOFF.md`, `05_Notas/README.md`.
- Eliminados: ninguno.

## Detalle por archivo
### `02_Scripts/07_forma_funcional_observacional.R` (sección 8)
Figura de dos paneles con la misma muestra (densidad de `Revenue` y de `ln(Revenue)`, con media, mediana y una normal con la misma media y desviación superpuesta), tabla de forma de la distribución (media, desviación, asimetría, curtosis, percentiles; los del logaritmo llevados a dólares con `exp()`) y tabla "puente": media aritmética, mediana, media geométrica `exp(media del log)` y el factor entre ambas medias (1.175; con logaritmo normal sería `exp(varianza/2)` = 1.154). Ese factor es el smearing de Duan del modelo sin covariables. Se agregó `source("02_Scripts/00_formato_tablas.R")`. Intuición: cada escala promedia algo distinto; solo los percentiles se conservan al transformar.

### `02_Scripts/08_ate_experimento_log.R`
- Estimando: ITT de `easier_signup` sobre `ln(Revenue)` (cambio proporcional de la media geométrica); referencia, el ITT en dólares del script 06. Estimador: MCO (`lm`) con errores HC1, sin controles y con los controles del script 06. Estimación: 0.0134 y 0.0065.
- Retransformación: `E[Y|X] = exp(Xb)·E[exp(e)]`; el factor de smearing (promedio de `exp(residuo)`) se estimó común y por grupo. Los contrafactuales se promedian prendiendo y apagando el tratamiento. Sin controles, el factor por grupo reproduce exactamente la diferencia de medias (`stopifnot`).
- Descomposición exacta sin controles: cociente de medias 1.123 = 1.0135 (media geométrica) × 1.108 (dispersión); diferencia de varianzas de `ln(Revenue)` 0.153 (error estándar 0.012, regresión auxiliar del cuadrado de la desviación al grupo sobre el tratamiento).
- Cuantiles por grupo y efecto en dólares con el ingreso limitado al percentil 99 y 95 (comunes a los dos grupos). Los cuantiles no tienen intervalos: el remuestreo no está en el catálogo.
- Figura de densidades de `ln(Revenue)` por grupo con el eje rotulado en dólares.

### `00_main.R`, `README.md`, `PLAN.md`, `CLAUDE.md`, `05_Notas/README.md`
Se agregaron las carpetas de salida y el script a la lista; mapa script → resultados; P1.1 marcado, avance de P3.2 y P3.3; fila en "Decisiones tomadas" (efecto en log reportado como cambio proporcional del usuario típico y llevado a dólares con factor por grupo; scripts previstos corridos una posición: árboles `09_`, comparación `10_`).

## Resultados nuevos (tablas, figuras, gráficos)
- `observacional_distribucion_ingreso_dos_escalas.png`, `observacional_distribucion_ingreso`, `observacional_puente_media_dolares`: muestran por qué se usa el logaritmo y qué mide cada media. Datos: base observacional completa (n = 100,000). Nota: [X_distribucion_dolares_vs_logaritmo.md](../05_Notas/07_forma_funcional_observacional/X_distribucion_dolares_vs_logaritmo.md).
- `experimento_ols_registro_log`, `experimento_log_a_dolares`, `experimento_descomposicion_media`, `experimento_cuantiles_por_grupo`, `experimento_efecto_cola` y `experimento_distribucion_lnrevenue_por_grupo.png`: concilian el ITT en logaritmo (≈1%) con el de dólares (12%) y localizan la diferencia en la dispersión y las colas. Datos: experimento completo (n = 10,000). Nota: [B_log_a_dolares_efecto_registro.md](../05_Notas/08_ate_experimento_log/B_log_a_dolares_efecto_registro.md).

Contraste con notas previas y Taller 1: consistente (ITT 0.0134 en logaritmo y 0.491 en dólares son los del Taller 1; con controles 0.0065 frente a 0.0042 del Taller 1, que usaba otros controles). No hay contradicciones pendientes.

## Pendientes
- Exploración descriptiva (hecha en consola, sin tabla exportada) de efectos en logaritmo con signo opuesto por dispositivo y sistema operativo; está mencionada en la nota como no registrada y sin evidencia de HTE. Debe pasar por el bosque causal (P4).
- Sin intervalos para los cuantiles: requiere ampliar el catálogo (remuestreo) con autorización del equipo.
- Smearing de las predicciones de la Parte A (P2.5) sigue abierto.
- Con controles, la retransformación por grupo da 0.077 frente a 0.454 directo; falta un modelo en logaritmo con interacciones o el bosque causal para ver si lo cierra.
- P1.3, cierre de P1.2, P2.2 (resto) y P2.3 no se trabajaron.
