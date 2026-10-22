# Bitácora — 2026-10-21: datos, limpieza y formato de gráficas traídos del Taller 1

## Resumen

Objetivo: dejar disponibles en el Taller 2 los datos y los scripts de preparación del
Taller 1 (pendientes listados en `CLAUDE.md`). No se ajustó ningún modelo ni se
construyó `ln(Revenue)`.

Desarrollo: (1) se copiaron los dos archivos crudos del Taller 1 a
`01_Datos/01_Crudos/`; (2) se copiaron los scripts de limpieza de la base
observacional y del experimento y se renombraron como `01_limpieza_observacional.R`
y `02_limpieza_experimento.R`; (3) se corrieron ambos desde la raíz del proyecto
para regenerar las bases en `01_Datos/03_Listos/`; (4) se copió
`00_formato_graficas.R` y se cambió su encabezado a "Taller 2".

## Archivos

- Creados:
  - `01_Datos/01_Crudos/datos_historicos.Rds`, `01_Datos/01_Crudos/datos_experimento.Rds` (copias)
  - `01_Datos/03_Listos/observacional_limpio.Rds`, `01_Datos/03_Listos/experimento_listos.RDS` (generados por los scripts)
  - `02_Scripts/00_formato_graficas.R`, `02_Scripts/01_limpieza_observacional.R`,
    `02_Scripts/02_limpieza_experimento.R`
  - `03_Resultados/Tablas/reporte_calidad_observacional.csv`,
    `03_Resultados/Tablas/reporte_calidad_observacional_embudo.csv`
  - Esta bitácora
- Modificados: solo el encabezado de `02_Scripts/00_formato_graficas.R` (de "Taller 1" a "Taller 2") y la sección "Estado actual" de `CLAUDE.md`.
- Eliminados: ninguno. (El script del experimento se renombró desde
  `03_procesar_datos_experimento.R` antes de versionarse.)

## Detalle por archivo

### Datos crudos
Copia sin modificación de `taller1/01_Datos/01_Crudos/`. Conservan los nombres del
Taller 1 (`datos_historicos.Rds`, `datos_experimento.Rds`), distintos de los del
enunciado (`observacional.Rds`, `experimento.Rds`); se mantuvieron para no tocar los
scripts. Mismos tamaños en bytes que los originales.

### `02_Scripts/01_limpieza_observacional.R`
Copia sin cambios. Revisa NA, negativos, valores atípicos por IQR (1.5x), binarias
fuera de {0,1}, categorías de `device_type`, duplicados exactos y dos
inconsistencias entre variables; estandariza `sign_up` e `is_returning_user` a
entero. No elimina nada: los atípicos se reportan, no se excluyen (la decisión
quedó "pendiente del equipo" en el reporte). Embudo: 100,000 → 100,000 → 100,000
(0 observaciones perdidas). Hallazgos reportados: atípicos por IQR en `Revenue`
(8,510), `time_spent` (4,949) y `past_sessions` (1,186); el límite inferior de
`Revenue` por IQR es negativo (-0.93) porque el criterio es simétrico, no porque
haya valores negativos (negativos = 0).

### `02_Scripts/02_limpieza_experimento.R`
Copia con otro nombre (antes `03_procesar_datos_experimento.R`). Elimina NA
(`drop_na`), verifica rangos, binarias y categorías. Resultado: 10,000 → 10,000
(0 perdidas). Mínimo de `Revenue` = 0.66, por lo que `ln(Revenue)` está definido en
el experimento.

### `02_Scripts/00_formato_graficas.R`
Copia del Taller 1; solo se cambió el encabezado. Define paleta, tema y
exportación según la sección "Formato de las gráficas" de `CLAUDE.md`. No genera
figuras.

## Resultados nuevos (tablas, figuras, gráficos)

- **`reporte_calidad_observacional_embudo.csv`:** muestra cuántas observaciones
  quedan tras cada paso de limpieza (100,000 en los tres pasos). Lo genera el script
  01 a partir de la base cruda. Rol: cumplir la regla de reportar pérdidas por
  limpieza.
- **`reporte_calidad_observacional.csv`:** lista los hallazgos de calidad (atípicos)
  con alternativas de tratamiento. Misma fuente. Rol: documentar la decisión
  pendiente sobre atípicos.

## Pendientes

- Verificar `Revenue > 0` en la base observacional y fijar la convención de
  `ln(Revenue)` (el Taller 1 la construyó como `log_revenue` en otros scripts, no
  traídos aún); registrar en "Decisiones tomadas".
- Decidir el tratamiento de los atípicos (el reporte los deja como "pendiente de
  decisión del equipo").
- Crear `README.md` y `00_main.R` cuando haya más scripts.
- Definir roles del equipo y algoritmos/paquetes de árboles.
- Parte A (predicción con árboles) y Parte B (HTE).
