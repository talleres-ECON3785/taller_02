# Bitácora — 2026-10-21: configuración inicial del proyecto del Taller 2

## Resumen

Objetivo: dejar el repositorio del Taller 2 listo para empezar el análisis,
reutilizando la organización del Taller 1 y el flujo de registro de sesiones del
Laboratorio 9. No se tocó ningún dato ni se corrió ningún análisis.

Desarrollo: (1) se replicó la estructura de carpetas del Taller 1 y se creó el
proyecto de R; (2) se movió el enunciado a `07_Recursos/`; (3) se escribió un
`CLAUDE.md` adaptado al enunciado del Taller 2 (métodos basados en árboles,
`ln(Revenue)`, Partes A y B), tomando como base el del Taller 1; (4) se trajo la
skill `registrar-sesion` del Laboratorio 9, se creó la carpeta de conversaciones
y se agregó a `.gitignore`; (5) se reflejó en `CLAUDE.md` la estructura de
bitácoras del Laboratorio 9.

## Archivos

- Creados:
  - `taller_02.Rproj`, `.gitignore`, `CLAUDE.md`
  - `.claude/skills/registrar-sesion/SKILL.md`
  - `.gitkeep` en las carpetas vacías: `01_Datos/01_Crudos`, `01_Datos/02_Procesados`,
    `01_Datos/03_Listos`, `02_Scripts`, `03_Resultados/Tablas`, `03_Resultados/Figuras`,
    `04_Presentaciones`, `05_Notas`, `06_Bitacoras`, `08_Entregables`
  - Carpeta `09_Conversaciones/` (ignorada por git; no aparece en el repositorio)
  - Esta bitácora
- Modificados: `Problem_Set_2.pdf` se movió de la raíz a `07_Recursos/` (el archivo
  no tenía historial git; no hay commits todavía).
- Eliminados: ninguno.

## Detalle por archivo

### Estructura de carpetas, `.gitkeep`, `taller_02.Rproj`, `.gitignore`
Se copió la estructura numerada del Taller 1 (`01_Datos/` con Crudos, Procesados y
Listos; `02_Scripts`; `03_Resultados` con Tablas y Figuras; `04_Presentaciones`;
`05_Notas`; `06_Bitacoras`; `07_Recursos`; `08_Entregables`). Git no versiona
carpetas vacías, por eso cada una lleva un `.gitkeep`; `07_Recursos` no lo
necesita porque contiene el enunciado. `taller_02.Rproj` y `.gitignore` son
copias de los del Taller 1 (UTF-8, 2 espacios de sangría; se ignoran
`.Rproj.user`, `.Rhistory`, `.RData`, `.Ruserdata`).

### `CLAUDE.md`
Base: el del Taller 1. Cambios principales y su razón:
- **Contexto:** se describen las Partes A (predicción de `ln(Revenue)` con árboles,
  base observacional) y B (heterogeneidad del efecto de `easier_signup`, base del
  experimento) y la estructura de trabajo sugerida por el enunciado. Se deja
  explícito que hay que separar el efecto de la transformación logarítmica del
  efecto del método.
- **Regla metodológica:** la restricción "solo regresión lineal" del Taller 1 se
  reemplazó. Ahora los métodos basados en árboles son parte del enunciado y la
  regresión lineal queda como modelo de referencia. Otras familias de modelos
  requieren autorización del equipo.
- **Reglas añadidas:** predicción no es causalidad; la importancia de variables no
  es un efecto; que un método encuentre grupos no prueba HTE; los RMSE de
  `ln(Revenue)` y `Revenue` no son comparables; `set.seed(2026)` y evaluación
  fuera de muestra, con hiperparámetros elegidos solo con datos de entrenamiento.
- **Estado actual:** se incluyó un resumen de los resultados del Taller 1 como
  punto de partida (ITT, quiebre en `time_spent`, desempeño predictivo lineal,
  representatividad) para poder compararlos después.
- **Integrantes:** se conservaron nombres y contactos; los roles quedaron "Por
  definir" porque los del Taller 1 dependían de la división datos
  históricos/experimento.
- **Registro de sesión:** se agregó la estructura de bitácora del Laboratorio 9
  (Resumen, Archivos, Detalle por archivo, Resultados nuevos, Pendientes), la
  regla de explicar por separado cada variable que construye un estimador citando
  su fuente, y la descripción de la skill `registrar-sesion`.

### `.claude/skills/registrar-sesion/SKILL.md`
Copia de la skill del Laboratorio 9 con estos ajustes: rutas a `06_Bitacoras/` y
`09_Conversaciones/`; el `.jsonl` no se versiona (la carpeta está en `.gitignore`;
en el laboratorio sí se subía); reglas de contenido propias del Taller 2
(estimando/estimador/estimación, escala de cada número, CATE como estimaciones).

### `09_Conversaciones/` y `.gitignore`
La carpeta guarda localmente el registro crudo de las conversaciones. Se numeró
09 para no renumerar las carpetas existentes (en el laboratorio era 06, que aquí
ya es de bitácoras). Se verificó con `git check-ignore` que git la ignora.

## Pendientes

- No hay ningún commit todavía en `main` (el remoto es
  `https://github.com/talleres-ECON3785/taller_02.git`). Pendiente decidir el
  primer commit y push; esta sesión no hizo commit.
- Copiar los datos crudos a `01_Datos/01_Crudos/` y confirmar los nombres: en el
  Taller 1 eran `datos_historicos.Rds` y `datos_experimento.Rds`, y el enunciado
  los llama `observacional.Rds` y `experimento.Rds`.
- Copiar `02_Scripts/00_formato_graficas.R` desde el Taller 1 (el `CLAUDE.md` lo
  referencia).
- Definir los roles del equipo (cuadro de integrantes en `CLAUDE.md`).
- Definir y registrar en "Decisiones tomadas" los algoritmos y paquetes de árboles
  para la Parte A y los métodos causales para la Parte B.
- Confirmar si el enunciado de entrega exige video (el enunciado de este taller
  solo menciona la presentación).
- Crear `README.md` y `00_main.R` cuando existan scripts.
- Durante la sesión el sistema avisó de que `CLAUDE.md` cambió en disco entre dos
  ediciones; no se revisó qué cambió. Conviene que el equipo lo lea completo
  antes de la próxima sesión.
- No se pudo confirmar quién del equipo trabajó en esta sesión.
