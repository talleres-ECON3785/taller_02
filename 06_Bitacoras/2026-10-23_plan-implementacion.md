# Bitácora — 2026-10-23: plan de implementación del Taller 2

## Resumen

Integrante: Santiago Muñoz (rama `SantiagoMunozM`).

Objetivo: armar un plan de punta a punta para implementar el Taller 2, con
hitos, tareas y una lista de verificación. Debía tener en cuenta el enunciado
(`07_Recursos/Problem_Set_2.pdf`), sus preguntas, las herramientas permitidas
(`07_Recursos/catalogo_metodos.md`) y las heurísticas de la retroalimentación
del Taller 1 (H1–H11). El plan tenía que ser corto para que se pueda usar con la
entrega del domingo 25 de octubre. No se estimó ningún modelo.

Desarrollo:

1. Al empezar, `git fetch origin`: `main` no había avanzado frente a la rama.
2. Se leyeron el enunciado, `CLAUDE.md`, `HANDOFF.md`, el catálogo de métodos,
   las heurísticas y `00_main.R`. Se inspeccionaron, solo para leer, las bases
   listas (`01_Datos/03_Listos/`).
   - `Revenue` es estrictamente positivo en las dos bases (mínimo 0.545 en la
     observacional y 0.665 en el experimento). Construir `ln(Revenue)` no
     pierde observaciones (100,000 → 100,000 y 10,000 → 10,000).
   - En el experimento, la tabla `easier_signup` × `sign_up` es 5,043 / 0 / 0 /
     4,957: el cumplimiento es perfecto y el reparto es casi 50/50.
3. Antes de escribir el plan se hicieron cuatro preguntas al usuario. Las
   respuestas:
   - El plan va en `PLAN.md`, en la raíz.
   - Los responsables quedan sin asignar (columna vacía por hito).
   - Quedan fijadas tres decisiones de alcance: registrar las tres
     ampliaciones del catálogo, incluir LASSO en la Parte A y tratar
     `time_spent` como moderador en la Parte B.
   - La retransformación del RMSE a dólares (*smearing*) **no** se fijó y
     quedó como tarea por decidir (P2.5).
   - Los slides se harán en PowerPoint o Google Slides.
4. Se escribió `PLAN.md`, se registraron su ruta y las decisiones en
   `CLAUDE.md` y se anotaron las ampliaciones en el catálogo.

Frente a los "Siguientes objetivos" del handoff anterior (descriptiva de
`ln(Revenue)`, Parte A, Parte B): ninguno se trabajó directamente. Ahora están
dentro del plan como H1, H2 y H3–H4. Se resolvieron tres bloqueos:

- faltaba el plan de implementación;
- faltaba decidir qué métodos del catálogo entran a cada parte (LASSO entra en
  la A);
- faltaba decidir si se registraban las tres herramientas previstas.

## Archivos

- Creados:
  - `PLAN.md`
  - `06_Bitacoras/2026-10-23_plan-implementacion.md`
- Modificados:
  - `CLAUDE.md`
  - `07_Recursos/catalogo_metodos.md`
  - `HANDOFF.md`
- Eliminados: ninguno.

## Detalle por archivo

### `PLAN.md`

Plan de implementación del proyecto completo. Cada tarea es una casilla
numerada `Pk.n` (hito *k*, tarea *n*) para que `HANDOFF.md` la cite. Decisiones
de diseño del documento:

- **Encabezado con calendario por días** (23 oct: H0–H1; 24 oct: H2 y H3–H4 en
  paralelo; 25 oct: H5–H7). Con dos días de margen, las Partes A y B solo caben
  si se trabajan a la vez y si ninguna depende de la otra. Así está armado: la
  única dependencia común es H0.
- **Diseño central 2×2: forma funcional × método.**
  - Filas: lineal o árboles. Columnas: `Revenue` o `ln(Revenue)`.
  - La celda lineal–`Revenue` es el Taller 1 y la celda árboles–`ln(Revenue)`
    es el análisis principal del Taller 2.
  - Las otras dos celdas aíslan cada cambio: lineal–`ln(Revenue)` muestra el
    efecto de la transformación con el método fijo, y árboles–`Revenue` muestra
    el efecto del método con la escala fija.
  - Es la forma de responder lo que el enunciado pide en "Contrastar la
    evidencia" (si una diferencia viene de la transformación, del método o de
    ambos) sin mezclar las dos fuentes de cambio.
  - Las comparaciones de RMSE se hacen dentro de cada escala o como mejora
    relativa frente al ingenuo de la misma escala, porque el RMSE en log y en
    dólares tienen unidades distintas.
- **Estimandos declarados arriba (H1).** Parte A: predicción de `ln(Revenue)`,
  medida con el RMSE de prueba, sin parámetro causal. Parte B: ATE y CATE(x) de
  `easier_signup` sobre `ln(Revenue)`. El ITT en dólares del Taller 1 queda como
  referencia, no como estimando. Responde a la corrección del Taller 1
  ("estimaron *unos* efectos, no *el* efecto").
- **Hitos:**
  - **H0, infraestructura:** tablas, paquetes, `log_revenue` y README.
  - **H1, descriptiva (H3):** antes de modelar se muestra cómo varía
    `ln(Revenue)` con cada covariable, porque esa fue la principal pérdida de
    puntos en la Parte A del Taller 1.
  - **H2, Parte A:**
    - verificar la partición reproduciendo el RMSE 2.314 del Taller 1, la
      prueba más directa de que la partición es la misma;
    - benchmarks lineales, incluido LASSO, para que la ventaja de los árboles
      no se infle (H4);
    - CART con poda, bosque con OOB;
    - tabla 2×2 de prueba;
    - escalera de RMSE más importancia de variables (H5).
  - **H3, Parte B (validez y ATE):** balance **y** cumplimiento (H7), ATE en
    las dos escalas con `feols` y con el bosque causal, y conciliación
    nivel–log (H2).
  - **H4, Parte B (heterogeneidad):**
    - CATE con varianza;
    - evidencia formal con `test_calibration()` y TOC/AUTOC en muestras
      separadas, porque que el bosque encuentre grupos no prueba HTE;
    - ATE por subgrupo con IC, tamaño del grupo y peso en la base histórica
      (H8, H9);
    - importancia de variables;
    - bosque en nivel para probar la hipótesis de la cola alta del Taller 1;
    - robustez sin `time_spent`.
  - **H5, síntesis:** tabla "se mantiene / se matiza / cambia" con su origen, y
    recomendación sí/no (H10), que fue la otra pérdida de puntos del Taller 1.
  - **H6, presentación:** guion *answer-first*, slides, ensayo de 15 min o
    menos.
  - **H7, entrega:** correr desde cero, README, PR, `.jsonl` y Bloque Neón.
- **Tabla final pregunta → paso:** cada pregunta de las Partes A y B del
  enunciado tiene al menos un paso que la responde. Es la verificación de que el
  plan es completo.
- **Qué quedó fuera a propósito.** El plan no repite cómo se estima cada cosa:
  cita el catálogo y las heurísticas, para que siga siendo una lista usable.
- P0.1 quedó marcada como hecha en esta sesión.

### `CLAUDE.md`

- **Párrafo "Plan de implementación"** (sección `HANDOFF.md`): ahora apunta a
  `PLAN.md`. Dice que los siguientes objetivos se derivan de las primeras
  casillas sin marcar, que se citan por número y que las casillas se marcan en
  la misma sesión en que se termina la tarea. Se quitó la regla transitoria de
  derivar los objetivos de los pendientes de la última bitácora.
- **"Decisiones tomadas"**, cinco filas nuevas:
  1. **El plan vive en `PLAN.md`.**
  2. **El diseño 2×2.** Razón: es la forma de atribuir cada diferencia con el
     Taller 1 a la transformación o al método.
  3. **Las tres ampliaciones del catálogo.** Razón: sin ellas, la pregunta "¿qué
     variables predicen mejor?" y los intervalos de los CATE y de los grupos se
     quedan sin herramienta.
  4. **LASSO en la Parte A.** Razón: un benchmark solo lineal inflaría la
     ventaja de los árboles (H4).
  5. **`time_spent` como covariable pre-tratamiento en el bosque causal, con
     robustez sin ella.** Razón: en el Taller 1, `easier_signup` no afectó
     significativamente a `time_spent`. Como se mide en la misma sesión que el
     gasto, la robustez cubre el riesgo de que funcione como mediador.
- **"Restricciones de muestra"**: se reemplazó "(sin análisis todavía)" por las
  dos filas de `Revenue > 0`, con los N antes y después (sin pérdidas).

### `07_Recursos/catalogo_metodos.md`

- **"Registro de ampliaciones"**, tres filas con fecha, qué se agrega, para qué
  pregunta del taller, la fuente (documentación del paquete) y quién lo aprobó:
  1. **Importancia de variables en `ranger` y `rpart`.**
     - Función: `ranger(..., importance = "permutation")` con
       `$variable.importance`, y `$variable.importance` en `rpart`.
     - Uso: responde la pregunta de la Parte A "¿qué variables son más útiles?"
       como complemento de la escalera de RMSE.
     - Lectura: mide cuánto usa el modelo cada variable, no un efecto.
  2. **Varianza de los CATE en `grf`.**
     - Función: `predict(cf, estimate.variance = TRUE)`.
     - Uso: da la varianza de cada τ̂(x) y con ella los intervalos que exige
       `CLAUDE.md`.
  3. **ATE por subgrupo en `grf`.**
     - Función: `average_treatment_effect(cf, subset = ...)`.
     - Uso: estima el efecto promedio dentro de un grupo, con su error
       estándar, para la pregunta "¿hay grupos con efecto mayor, menor o
       cercano a cero?".
- **"Herramientas previstas"**: el estado de las tres pasó de "Sin registrar" a
  "Registrada (2026-10-23)".

## Pendientes

- **Siguiente paso: H0.** P0.2 (`00_formato_tablas.R` y elección del paquete de
  tablas), P0.3 (paquetes en `p_load()`), P0.4 (`log_revenue` en las bases
  listas) y P0.5 (README inicial). Después, H1 (descriptiva).
- **Decisiones por tomar dentro del plan:**
  - P2.5: retransformar las predicciones en log a dólares (*smearing* de Duan)
    o comparar solo mejoras relativas.
  - P3.2: `W.hat`, 0.5 por diseño o la proporción observada (4,957 / 10,000).
  - P0.2: el paquete de tablas.
- **Supuesto sin confirmar:** que la partición del Taller 1 se reproduce con la
  misma muestra; se verifica en P2.1 recuperando el RMSE 2.314.
- **Roles:** llenar la columna "Resp." de cada hito en `PLAN.md`.
