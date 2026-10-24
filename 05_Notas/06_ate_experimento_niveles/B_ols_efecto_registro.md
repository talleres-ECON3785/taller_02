# El registro facilitado aumenta el ingreso promedio en 0.49 dólares; con controles, 0.45

- **Estado:** vigente
- **Parte / base:** B; experimento; causal (ITT, ingreso en dólares)
- **Script de origen:** `02_Scripts/06_ate_experimento_niveles.R`
- **Última verificación:** 2026-10-24, con `02_Scripts/06_ate_experimento_niveles.R` (secciones 1 a 3 de `00_main.R` más el script, no `00_main.R` completo)

## Evidencia
- `03_Resultados/Tablas/06_ate_experimento_niveles/experimento_ols_registro.png`
  (y su `.csv`, con el efecto de cada modelo). Experimento, n = 10,000, muestra
  completa, `Revenue` en dólares, errores estándar robustos HC1.
- Sin controles: efecto de `easier_signup` de 0.491 dólares (error estándar 0.073;
  intervalo del 95 % de 0.347 a 0.634). Promedio del grupo de control: 3.978
  dólares. R² de 0.005.
- Con los controles del lineal final de la predicción (más de 5 minutos, sesiones
  anteriores y su cruce, dispositivo, sistema operativo y usuario recurrente):
  0.454 dólares (error estándar 0.051; intervalo de 0.354 a 0.554). R² de 0.511.
- Cumplimiento: ver `B_balance_y_cumplimiento.md` (tabla
  `experimento_cumplimiento`).

## Qué dice, en lenguaje intuitivo
Los usuarios a quienes se les facilitó el registro gastan en promedio unos 0.49
dólares más que los del grupo de control, que gastan unos 3.98. Como la asignación
fue aleatoria, esa diferencia se lee como el efecto de facilitar el registro (el
estimando es el efecto de la asignación, ITT). Como todos los asignados se
registraron y nadie del control lo hizo, es también el efecto de registrarse, por
la vía de esta intervención. El modelo simple usa solo el tratamiento: el
coeficiente es la diferencia de medias entre los dos grupos.

Agregar los controles cambia poco la estimación (0.49 a 0.45; la diferencia es
menor que un error estándar del modelo simple) pero reduce el error estándar de
0.073 a 0.051. Los controles explican buena parte de las diferencias de ingreso
entre usuarios (R² de 0.51) y por eso la comparación entre grupos queda más
precisa. No corrigen ningún sesgo: con asignación aleatoria el modelo simple ya
estima el mismo efecto.

## Por qué importa en el estudio
Responde a la pregunta de negocio heredada (¿impulsar el registro?) y fija el
punto de partida de la Parte B: es el ATE en dólares que luego se contrasta con
`ln(Revenue)` y con los efectos heterogéneos. **Se mantiene** frente al Taller 1:
ITT sobre `Revenue` de 0.49 y medias de 3.98 y 4.47 (misma dirección, escala y
orden de magnitud; el p-valor es del orden de 1e-11 en ambos). Sigue abierta la
pista del Taller 1: medianas casi idénticas y medias distintas sugieren que el
promedio lo mueven pocos usuarios de la cola alta; eso lo evalúan la escala
logarítmica y el bosque causal. Los controles eligen la misma especificación que
el lineal de la Parte A, así que ambas partes se pueden comparar.

## Límites e incertidumbre
- Solo `Revenue` en dólares; no distingue si el efecto viene de una parte pequeña
  de usuarios.
- Que el cumplimiento sea perfecto implica que no se puede separar el efecto de
  la asignación del de registrarse.
- `time_spent` se mide en la misma sesión: se trata como covariable
  pre-tratamiento (decisión del 2026-10-23) y entra a los controles solo como el
  indicador de más de 5 minutos. Con asignación aleatoria el balance en esa
  variable respalda su uso (ver la nota de balance); no se probó una
  especificación sin ella.
- Validez externa: la muestra del experimento no se distingue de la histórica en
  las covariables observables (Taller 1), pero no se evaluó de nuevo aquí.
- El `.csv` trae un p-valor de 2.2e-11 frente al 1.8e-11 del Taller 1; la
  diferencia podría venir de la corrección de errores robustos usada (no se
  verificó); no cambia la lectura.

## Historial
- 2026-10-24: primera versión (script 03); coincide con el ITT en nivel del Taller 1.
- 2026-10-24: el análisis pasa al script `06_ate_experimento_niveles.R`; se agrega
  el modelo con controles (0.454, error estándar 0.051). El modelo simple repite
  0.491 (0.073).
