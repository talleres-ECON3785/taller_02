# El registro facilitado aumenta el ingreso promedio en 0.49 dólares, y el cumplimiento es perfecto

- **Estado:** vigente
- **Parte / base:** B; experimento; causal (ITT, ingreso en dólares)
- **Script de origen:** `02_Scripts/03_punto_partida.R`
- **Última verificación:** 2026-10-24, con la sección final de `02_Scripts/03_punto_partida.R` (corrida por separado, no con `00_main.R` completo)

## Evidencia
- `03_Resultados/Tablas/03_punto_partida/experimento_ols_registro.png` (y su
  `.csv` con las cifras sin formato). Experimento, n = 10,000, muestra
  completa, `Revenue` en dólares, errores estándar robustos HC1.
- Efecto de `easier_signup` (registro facilitado): 0.491 dólares (error estándar
  0.073; intervalo del 95 % de 0.347 a 0.634, en el `.csv`). Promedio del grupo de
  control: 3.978 dólares (error estándar 0.038). R² de 0.005.
- Cumplimiento: 5,043 usuarios de control sin registro y 4,957 asignados al
  registro facilitado, todos registrados (la sección falla con `stopifnot` si
  `sign_up` y `easier_signup` dejan de coincidir).

## Qué dice, en lenguaje intuitivo
Los usuarios a quienes se les facilitó el registro gastan en promedio 0.49 dólares
más que los del grupo de control, que gastan unos 3.98. Como la asignación fue
aleatoria, esa diferencia se lee como el efecto de facilitar el registro (el
estimando es el efecto de la asignación, ITT). Como todos los asignados se
registraron y nadie del control lo hizo, es también el efecto de registrarse, por
la vía de esta intervención. El modelo usa solo el tratamiento: el coeficiente es
la diferencia de medias entre los dos grupos.

## Por qué importa en el estudio
Responde a la pregunta de negocio heredada (¿impulsar el registro?) y fija el
punto de partida de la Parte B: es el ATE en dólares que luego se contrasta con
`ln(Revenue)` y con los efectos heterogéneos. **Se mantiene** frente al Taller 1:
ITT sobre `Revenue` de 0.49 y medias de 3.98 y 4.47 (misma dirección, escala y
orden de magnitud; el p-valor es del orden de 1e-11 en ambos). Sigue abierta la
pista del Taller 1: medianas casi idénticas y medias distintas sugieren que el
promedio lo mueven pocos usuarios de la cola alta; eso lo evalúan la escala
logarítmica y el bosque causal.

## Límites e incertidumbre
- Solo `Revenue` en dólares y sin controles; no distingue si el efecto viene de
  una parte pequeña de usuarios.
- Que el cumplimiento sea perfecto implica que no se puede separar el efecto de
  la asignación del de registrarse.
- Validez externa: la muestra del experimento no se distingue de la histórica en
  las covariables observables (Taller 1), pero no se evaluó de nuevo aquí.
- El `.csv` trae un p-valor de 2.2e-11 frente al 1.8e-11 del Taller 1; la
  diferencia podría venir de la corrección de errores robustos usada (no se
  verificó); no cambia la lectura.

## Historial
- 2026-10-24: primera versión; coincide con el ITT en nivel del Taller 1.
