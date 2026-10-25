# Bitácora — 2026-10-24: análisis causal en dólares en su propio script (06) y forma funcional a 07

## Resumen
El usuario pidió mover el análisis causal sobre `Revenue` en niveles a su propio
script, ponerlo en el 06, pasar el de forma funcional al 07, hacer el modelo simple,
evaluar agregar los controles del lineal final de la predicción y agregar las
pruebas de balance y la verificación de cumplimiento perfecto. Ese análisis vivía
al final de `03_punto_partida.R` (MCO sin controles y verificación de cumplimiento);
no había balance en el Taller 2.

Se trabajó en un worktree (`worktree-ate-niveles`, reseteado a `SantiagoMunozM`) y
el commit se empujó a `SantiagoMunozM`. Se corrió `00_main.R` completo, con la
subcarpeta de tablas del 06 borrada antes: sin errores.

Objetivos de `HANDOFF.md`: ninguno de los tres (P1.1/P1.3, P2.2 resto, P2.3) se
trabajó; avanzaron P3.1 (balance y cumplimiento) y P3.2 (ITT en dólares con y sin
controles).

## Archivos
- Creados: `02_Scripts/06_ate_experimento_niveles.R`;
  `03_Resultados/Tablas/06_ate_experimento_niveles/` (`experimento_cumplimiento`,
  `experimento_balance`, `experimento_ols_registro`, cada una `.png` y `.csv`);
  `05_Notas/06_ate_experimento_niveles/B_balance_y_cumplimiento.md`.
- Modificados: `00_main.R`, `02_Scripts/03_punto_partida.R`, `CLAUDE.md` (decisión),
  `README.md`, `PLAN.md`, `HANDOFF.md`, `05_Notas/README.md`, notas de
  `05_Notas/03_punto_partida/` y `04_prediccion_lineal_observacional/` (rutas).
- Movidos (`git mv`): `06_forma_funcional_observacional.R` a `07_...` y su carpeta de
  figuras; `experimento_ols_registro.{png,csv}` y `B_ols_efecto_registro.md` a las
  subcarpetas del 06.
- Eliminados: carpeta vacía `03_Resultados/Tablas/03_punto_partida/`.

## Detalle por archivo
### `02_Scripts/06_ate_experimento_niveles.R`
- Estimando: ITT de `easier_signup` sobre `Revenue` en dólares. Estimador: MCO con
  errores HC1. Estimación: 0.491 (error estándar 0.073) sin controles y 0.454 (0.051)
  con controles.
- **Cumplimiento:** tabla `easier_signup` × `sign_up` y `stopifnot` de que coinciden;
  concluye LATE = ITT.
- **Balance:** por característica (tiempo, más de 5 minutos, sesiones, recurrente,
  dispositivo y sistema operativo por categoría), diferencia de medias con
  regresión sobre el tratamiento y error HC1 (a mano, para controlar formato en
  vez de `datasummary_balance`). Prueba conjunta: Wald con `fixest::feols` y HC1 de
  `easier_signup` sobre las covariables, incluyendo `os_type` (que el Taller 1
  omitió): F = 0.964, p = 0.456. Intuición: si la aleatorización funcionó, las
  covariables previas no deben predecir la asignación.
- **Controles:** los del lineal final de la predicción (`mas_5_min`, `past_sessions`,
  su cruce, `device_type`, `os_type`, `is_returning_user`), sin `sign_up` porque
  coincide con el tratamiento. `mas_5_min = time_spent > 5`, igual que en el script
  04. `time_spent` se trata como pre-tratamiento (decisión del 2026-10-23). En un
  experimento los controles ganan precisión, no corrigen sesgo; por eso se
  reportan lado a lado.

### `02_Scripts/03_punto_partida.R`
Se quitó la sección causal, el `source` de `00_formato_tablas.R` y las menciones;
queda puramente descriptivo. (Un borrado de más del `source` de las gráficas se
detectó y se restauró antes de correr.)

### `00_main.R`, `README.md`, `PLAN.md`, `CLAUDE.md`, notas
Nueva subcarpeta de tablas del 06, nueva entrada en `scripts`, scripts previstos
renumerados (08 árboles, 09 comparación, 10 ATE en logaritmo y bosque causal, 11
heterogeneidad; `09_validacion_experimento` absorbido por el 06), decisión
registrada en "Decisiones tomadas".

## Resultados nuevos (tablas, figuras, gráficos)
Notas: [B_ols_efecto_registro.md](../05_Notas/06_ate_experimento_niveles/B_ols_efecto_registro.md)
y [B_balance_y_cumplimiento.md](../05_Notas/06_ate_experimento_niveles/B_balance_y_cumplimiento.md).
- `experimento_cumplimiento`: 5,043 control sin registro y 4,957 tratados
  registrados; muestra el cumplimiento perfecto. Datos: conteos del experimento
  (n = 10,000).
- `experimento_balance`: diferencias de medias y prueba conjunta; sustenta la
  lectura causal.
- `experimento_ols_registro`: ITT sin y con controles, dólares, HC1.

Contraste: coincide con el ITT del Taller 1 (0.49); la diferencia con los
controles (0.037) es menor que un error estándar del modelo simple. Sin
contradicciones.

## Pendientes
- P3.1 falta la representatividad frente a la base histórica; P3.2 falta
  `ln(Revenue)` y el bosque causal; decidir `W.hat`.
- No se probó una especificación sin el indicador de más de 5 minutos como control.
- Notas del script 07 (`ln(Revenue)`) siguen sin escribirse.
- Los tres objetivos previos de `HANDOFF.md` se mantienen.
- El checkout principal sigue en 470b4e4: `git pull origin SantiagoMunozM`; luego
  borrar la rama `worktree-ate-niveles` y el worktree.
