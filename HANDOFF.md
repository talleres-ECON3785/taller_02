# HANDOFF

Resumen accionable del Taller 2 para retomar el trabajo. El detalle de cada
sesión está en `06_Bitacoras/`; aquí solo va lo necesario para saber dónde
estamos y qué sigue. Las reglas para mantener este archivo están en
`CLAUDE.md` (sección "`HANDOFF.md`").

**Fecha de entrega (video, slides y material de soporte): domingo 25 de
octubre de 2026.**

## Siguientes objetivos

<!-- Dos a tres tareas concretas, en orden de prioridad, cada una con el
     archivo que debe producirse, un criterio de terminado verificable y, si
     aplica, el integrante a cargo. Cuando exista el plan de implementación,
     cada objetivo cita el paso del plan del que sale. Se reescribe al cerrar
     cada sesión. -->

Todavía no hay plan de implementación; estos objetivos salen de los pendientes
de las bitácoras y de `CLAUDE.md`.

1. **Construir `ln(Revenue)` y la estadística descriptiva de la Parte A.**
   Script `02_Scripts/03_descriptivas_observacional.R` que verifica
   `Revenue > 0` (reporta cuántas observaciones se pierden), construye
   `log_revenue` (convención del Taller 1) y describe cómo varía
   `ln(Revenue)` con cada covariable (heurística H3).
   *Terminado cuando:* el script está en la lista de `00_main.R`, corre sin
   errores y exporta sus tablas y figuras con `guardar_tabla()` /
   `guardar_figura()`, y la decisión sobre `Revenue <= 0` está en "Decisiones
   tomadas".
2. **Parte A: árboles frente al benchmark lineal sobre `ln(Revenue)`.** Antes,
   decidir y registrar los paquetes (p. ej. `rpart`, `ranger`). Misma
   partición 80/20 con semilla 2026 que el Taller 1, hiperparámetros por
   validación cruzada solo en entrenamiento, RMSE de prueba escalonado e
   interpretado en unidades del negocio (H4–H6).
   *Terminado cuando:* existe la tabla de RMSE de prueba (ingenuo, lineal,
   árbol, bosque) en la escala de `ln(Revenue)` y la decisión sobre cómo
   comparar con el RMSE en dólares del Taller 1 está registrada.
3. **Parte B: ATE y CATE de `easier_signup` sobre `ln(Revenue)`.** Validación
   del experimento con balance **y** cumplimiento (H7), bosque causal (p. ej.
   `grf`) con evidencia formal de heterogeneidad (calibración o muestras
   separadas) e intervalos por grupo (H8), y la conciliación con el ITT en
   nivel del Taller 1 (H2).
   *Terminado cuando:* existen las tablas de ATE (nivel y log) y de CATE por
   grupo con intervalos, y la prueba de heterogeneidad, todas regeneradas por
   `00_main.R`.

**Bloqueos / preguntas abiertas:**

- Falta el plan de implementación del proyecto completo (se hará más
  adelante); cuando exista, los objetivos de arriba se reemplazan por sus
  próximos pasos.
- Definir roles: ningún integrante tiene responsabilidad asignada salvo
  Douglas Plazas ("análisis histórico", en `main`). Con la entrega el 25 de
  octubre, hace falta repartir Partes A, B, presentación y video.
- Elegir paquetes de árboles (Parte A) y de árboles o bosques causales (Parte
  B) y registrarlos en "Decisiones tomadas".
- Crear `02_Scripts/00_formato_tablas.R` (con `guardar_tabla()`) y
  `README.md` antes de que haya resultados que mostrar.
- Rama `SantiagoMartinezL` todavía en GitHub (Santiago Martínez salió del
  equipo; borrarla requiere permiso del usuario). Confirmar el nombre de la rama
  de Samuel (`SamuelEscandonC`, inferido de su correo).
- `SantiagoMunozM` está dos commits atrás de `main` (cambio de rol de Douglas):
  traerlos con `git merge origin/main` después del próximo commit.
- Antes del 25 de octubre, unir por aparte los `.jsonl` de todos los
  integrantes para el material de soporte.

## Estado actual

<!-- Qué existe y funciona hoy: datos, scripts, resultados. Se reescribe al
     cerrar cada sesión; no es un historial. -->

- **Repositorio:** estructura de carpetas del Taller 1, `taller_02.Rproj`,
  `.gitignore`, `CLAUDE.md`, este `HANDOFF.md` y la skill `registrar-sesion`
  (bitácora, handoff, commit y push a la rama del integrante, copia del
  `.jsonl`). Una rama por integrante en GitHub; nada se commitea en `main`
  directamente.
- **Datos:** crudos en `01_Datos/01_Crudos/` (`datos_historicos.Rds`, 100,000
  obs.; `datos_experimento.Rds`, 10,000 obs.). Bases listas en
  `01_Datos/03_Listos/` (`observacional_limpio.Rds`,
  `experimento_listos.RDS`), sin pérdidas de observaciones. `ln(Revenue)`
  todavía no se ha construido.
- **Scripts:** `00_main.R` (raíz) verifica la raíz del proyecto, carga los
  paquetes con `pacman` (hoy solo `tidyverse`), crea las carpetas de salida que
  falten y corre `01_limpieza_observacional.R` y `02_limpieza_experimento.R`.
  Probado desde cero (sin `03_Resultados/` ni `01_Datos/03_Listos/`): corre sin
  errores. `00_formato_graficas.R` define paleta, tema y `guardar_figura()`.
- **Resultados:** solo los reportes de calidad de la base observacional
  (`03_Resultados/Tablas/reporte_calidad_observacional*.csv`). Ningún modelo
  estimado todavía.
- **Guías:** retroalimentación del Taller 1 (video 73.9/100, material 100/100)
  convertida en heurísticas H1–H11 en
  `07_Recursos/heuristicas_retroalimentacion_taller1.md`; reglas de
  reproducibilidad, tablas y entregas en `CLAUDE.md`.

## Registro de sesiones

<!-- Una entrada por sesión, la más reciente arriba. Tres a cinco líneas con lo
     que se hizo, quién y en qué rama, el enlace a la bitácora y, al final, los
     dos a tres siguientes objetivos que quedaron al cerrar esa sesión. Las
     entradas anteriores no se editan. -->

### 2026-10-23: retroalimentación del Taller 1, `00_main.R`, ramas por integrante y handoff

- Santiago Muñoz (`SantiagoMunozM`). La retroalimentación del Taller 1 quedó
  en heurísticas H1–H11 (`07_Recursos/`) y en reglas de reproducibilidad en
  `CLAUDE.md`, junto con las entregas y fechas del curso.
- Se creó `00_main.R` (paquetes con `pacman` y verificación de carpetas una
  sola vez). Se probó desde cero sin errores.
- Se crearon las ramas por integrante, el flujo de versiones y `HANDOFF.md`.
  `registrar-sesion` ahora actualiza el handoff y hace commit y push a la rama.
  Santiago Martínez salió del equipo.
- Del objetivo anterior se cumplió `00_main.R`; `ln(Revenue)`, README, roles y
  paquetes no se trabajaron.
- Bitácora: [2026-10-23_retroalimentacion-taller1-main-ramas-handoff.md](06_Bitacoras/2026-10-23_retroalimentacion-taller1-main-ramas-handoff.md)
- **Siguientes objetivos:** (1) construir `ln(Revenue)` y la descriptiva de la
  Parte A; (2) Parte A: árboles frente al lineal sobre `ln(Revenue)`; (3)
  Parte B: ATE y CATE con bosque causal, validación del experimento y
  conciliación nivel–log.

### 2026-10-22: rol de Douglas en `CLAUDE.md`

- Douglas Plazas (commits `f68e30f` y `fa12f74`, directo en `main`, antes de
  que existiera la regla de ramas). Asignó su rol ("análisis histórico") en la
  tabla de integrantes de `CLAUDE.md`. Sin bitácora.
- **Siguientes objetivos:** no se registraron.

### 2026-10-21: datos, limpieza y formato de gráficas traídos del Taller 1

- Santiago Muñoz (`main`, commit `da76ed3`). Se copiaron los crudos y los
  scripts de limpieza del Taller 1, se regeneraron las bases listas (0 obs.
  perdidas) y se trajo `00_formato_graficas.R`.
- Bitácora: [2026-10-21_traer-datos-y-limpieza.md](06_Bitacoras/2026-10-21_traer-datos-y-limpieza.md)
- **Siguientes objetivos:** (1) verificar `Revenue > 0` y fijar la
  convención de `ln(Revenue)`; (2) crear `README.md` y `00_main.R`; (3)
  definir roles y paquetes de árboles.

### 2026-10-21: configuración inicial del proyecto

- Santiago Muñoz. Se replicó la estructura del Taller 1, se escribió
  `CLAUDE.md` adaptado al Taller 2 y se trajo la skill `registrar-sesion` del
  Laboratorio 9, con `09_Conversaciones/` fuera de git.
- Bitácora: [2026-10-21_configuracion-inicial.md](06_Bitacoras/2026-10-21_configuracion-inicial.md)
- **Siguientes objetivos:** (1) copiar los datos crudos y confirmar sus
  nombres; (2) copiar `00_formato_graficas.R` del Taller 1; (3) definir roles
  y los algoritmos de árboles.
