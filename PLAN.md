# PLAN: plan de implementación del Taller 2

Hoja de ruta de punta a punta del Taller 2, desde la infraestructura hasta la
entrega. Cada tarea es una casilla: se marca `[x]` en la misma sesión en que
se termina. `HANDOFF.md` deriva sus "Siguientes objetivos" de las primeras
tareas sin marcar y las cita por número (p. ej. **P2.3**). El cómo de cada
estimación está en `07_Recursos/catalogo_metodos.md` y el porqué en
`07_Recursos/heuristicas_retroalimentacion_taller1.md` (H1–H11). Este plan
los cita, no los repite.

**Entrega: domingo 25 de octubre de 2026** (video, slides y material de
soporte). Calendario objetivo:

| Día            | Hitos                                    |
| -------------- | ---------------------------------------- |
| Viernes 23 oct | H0 y H1                                  |
| Sábado 24 oct  | H2 (Parte A) y H3–H4 (Parte B), en paralelo |
| Domingo 25 oct | H5, H6 y H7                              |

**Responsables:** el equipo llena la columna "Resp." de cada hito.

---

## Diseño central: separar la transformación del método

El enunciado pide distinguir si cada diferencia con el Taller 1 viene de usar
`ln(Revenue)`, de usar árboles o de ambas cosas. Las dos partes se organizan
en la misma matriz 2×2:

|                  | `Revenue` (nivel)          | `ln(Revenue)`                     |
| ---------------- | -------------------------- | --------------------------------- |
| **Lineal**       | Taller 1 (referencia)      | aísla el efecto de la transformación |
| **Árboles**      | aísla el efecto del método | Taller 2 (análisis principal)     |

**Estimandos (H1)**, que se declaran en una diapositiva temprana:

- **Parte A:** predecir `ln(Revenue)` en la base observacional. Medida:
  RMSE de prueba. No hay parámetro causal.
- **Parte B:** ATE y CATE(x) de `easier_signup` sobre `ln(Revenue)` (cambio
  proporcional aproximado del gasto). El ITT en dólares del Taller 1 es la
  referencia de comparación, no el estimando.

**Hechos ya verificados:** `Revenue` > 0 en las dos bases (mín. 0.545 obs.,
0.665 exp.), así que el logaritmo no pierde observaciones. El cumplimiento en
el experimento es perfecto (`easier_signup` × `sign_up`: 5,043 / 0 / 0 / 4,957).

---

## H0. Infraestructura y decisiones · Resp.: ____

- [x] **P0.1** Registrar las ampliaciones del catálogo (importancia de
  variables, varianza de los CATE, ATE por subgrupo) y las decisiones de
  alcance (LASSO en la Parte A, `time_spent` como moderador, diseño 2×2) en
  `catalogo_metodos.md` y en "Decisiones tomadas".
- [x] **P0.2** Crear `02_Scripts/00_formato_tablas.R` con `guardar_tabla()`
  (`.png` para la diapositiva más `.csv` sin formato). Elegir el paquete (p. ej.
  `gt`) y registrarlo.
- [x] **P0.3** Agregar al `p_load()` de `00_main.R` `rpart`, `rpart.plot`,
  `ranger`, `glmnet`, `caret`, `fixest`, `grf` y el paquete de tablas, con un
  comentario de para qué se usa cada uno.
- [x] **P0.4** Construir `log_revenue` en las bases listas (scripts `01_` y
  `02_`, convención del Taller 1) y verificar en el código que no se pierden
  observaciones (ya anotado en "Restricciones de muestra").
- [x] **P0.5** Crear el `README.md` inicial: objetivo, estructura, ejecución
  (solo `00_main.R`) y el mapa script → resultado, por llenar.

*Terminado cuando:* `00_main.R` corre desde cero con los paquetes nuevos y las
bases listas traen `log_revenue`.

## H1. Punto de partida y descriptiva (H3, H4) · Resp.: ____

Script: `03_descriptivas_observacional.R`.

- [ ] **P1.1** Densidad de `Revenue` frente a `ln(Revenue)`: asimetría y cola
  alta. Es el argumento para usar la transformación.
- [ ] **P1.2** Cómo varía `ln(Revenue)` con cada covariable (`time_spent` y su
  quiebre en 5 min, `past_sessions`, dispositivo, sistema operativo, usuario
  recurrente, registro), más una interacción candidata. Son las hipótesis que
  deben confirmar o matizar los árboles.
- [ ] **P1.3** Tabla con las cifras clave del Taller 1 (RMSE, ITT en nivel y
  en log, quiebre en 5 min) como punto de partida de la presentación.

*Terminado cuando:* las figuras y la tabla salen con `guardar_figura()` /
`guardar_tabla()` desde `00_main.R`.

## H2. Parte A: ¿predicen mejor los árboles? · Resp.: ____

Scripts: `04_prediccion_lineal_observacional.R`, `05_arboles_observacional.R`,
`06_comparacion_prediccion_observacional.R`.

- [ ] **P2.1** Partición 80/20 con `set.seed(2026)`, idéntica a la del
  Taller 1. Se verifica reproduciendo el RMSE 2.314 del lineal en nivel.
- [ ] **P2.2** Benchmarks en las dos escalas: ingenuo (media de `train`),
  lineal del Taller 1, lineal flexible (quiebre en 5 min, log del tiempo,
  interacciones de la descriptiva) y LASSO (`cv.glmnet`).
- [ ] **P2.3** CART (`rpart`, `cp = 0`, poda por CV con la regla del mínimo y
  la 1-SE) y la figura del árbol podado. ¿Recupera el quiebre en 5 min?
  ¿Qué interacciones aparecen?
- [ ] **P2.4** Bosque (`ranger`): rejilla `mtry` × `min.node.size` por error
  OOB (bagging = `mtry` igual al número de predictores) e importancia por
  permutación.
- [ ] **P2.5** Evaluación en `test`, una sola vez: tabla 2×2 de RMSE (método ×
  escala) con la mejora % frente al ingenuo en cada escala y la lectura en
  unidades del negocio (H6). **Decidir y registrar** si las predicciones en log
  se retransforman a dólares (*smearing*) o si solo se comparan mejoras
  relativas.
- [ ] **P2.6** Escalera de RMSE fuera de muestra al agregar variables (H5),
  junto con la importancia del bosque, para responder qué variables predicen.

*Terminado cuando:* existen la tabla 2×2 de RMSE de prueba, la escalera, la
figura del árbol y la de importancia, y la decisión de P2.5 está registrada.

## H3. Parte B: validez del experimento y ATE · Resp.: ____

Scripts: `07_validacion_experimento.R`, `08_ate_experimento.R`.

- [ ] **P3.1** Validación: tabla de balance, tabla de cumplimiento
  (`easier_signup` × `sign_up`) y representatividad frente a la base histórica
  (H7, H9).
- [ ] **P3.2** ATE en las dos escalas: ITT con `feols` (errores `hc1`, con y
  sin controles) y ATE del bosque causal (`average_treatment_effect`).
  **Decidir y registrar** `W.hat` (0.5 por diseño o la proporción observada).
- [ ] **P3.3** Conciliación nivel–log (H2): cuantiles de `Revenue` por brazo y
  efecto en nivel sin la cola alta. Sostiene la diapositiva "por qué los dos
  números no se contradicen".

*Terminado cuando:* la tabla de ATE (lineal y bosque, nivel y log, con IC) y
las de validación salen desde `00_main.R`.

## H4. Parte B: ¿el efecto es igual para todos? · Resp.: ____

Script: `09_heterogeneidad_experimento.R`.

- [ ] **P4.1** `causal_forest` sobre `ln(Revenue)` (≥2000 árboles,
  `seed = 2026`, las 5 covariables pre-tratamiento con `time_spent`), con los
  CATE fuera de bolsa y su varianza (`estimate.variance = TRUE`).
- [ ] **P4.2** Evidencia formal de HTE: `test_calibration()` y TOC/AUTOC con
  muestra dividida (bosque de entrenamiento para priorizar y bosque de
  evaluación independiente).
- [ ] **P4.3** ATE por subgrupo con IC (`subset`): dispositivo, sistema
  operativo, usuario recurrente, `time_spent` < 5 / ≥ 5 min y terciles de
  `past_sessions`, cada uno con su tamaño y su peso en la base histórica (H8,
  H9). Advertencia de multiplicidad.
- [ ] **P4.4** `variable_importance()` del bosque causal, leída como "dónde
  mira el bosque", no como efecto.
- [ ] **P4.5** Bosque causal sobre `Revenue` en nivel, para probar la
  hipótesis de la cola alta: ¿hay heterogeneidad en nivel que no aparece en
  log?
- [ ] **P4.6** Robustez: bosque sin `time_spent`.

*Terminado cuando:* existen la prueba de calibración, la figura TOC, la tabla de
CATE por grupo con IC y la comparación nivel–log de la heterogeneidad.

## H5. Síntesis y recomendación (H10) · Resp.: ____

- [ ] **P5.1** Tabla de conclusiones en `05_Notas/sintesis.md`: qué se
  mantiene, qué se matiza y qué cambia frente al Taller 1, y si se debe a la
  transformación, al método o a ambos (Partes A y B).
- [ ] **P5.2** Recomendación sí/no en una frase ("escalar / no escalar el
  registro facilitado [para todos | para el grupo G]"), separando la decisión
  respaldada de las preguntas abiertas (qué evidencia y qué resultado la
  cambiarían).
- [ ] **P5.3** Pasar la lista de chequeo H1–H10 sobre todos los resultados.

## H6. Presentación y video · Resp.: ____

- [ ] **P6.1** Guion *answer-first* en `04_Presentaciones/guion.md`: para cada
  diapositiva, el título-conclusión, la figura o tabla de `03_Resultados/` que
  lo sostiene y quién la expone.
- [ ] **P6.2** Slides en PowerPoint o Google Slides con los `.png` exportados,
  sin retoques y sin código.
- [ ] **P6.3** Ensayo de 15 min o menos, con reparto equitativo entre los
  cuatro integrantes.
- [ ] **P6.4** Grabar el video y guardar el PDF de los slides y el enlace al
  video en `08_Entregables/`.

## H7. Entrega (domingo 25 oct) · Resp.: ____

- [ ] **P7.1** Borrar `03_Resultados/` y correr `00_main.R` desde cero sin
  errores.
- [ ] **P7.2** README con el mapa completo script → tablas/figuras.
- [ ] **P7.3** Integrar las ramas en `main` con pull requests (cuando cada
  integrante lo pida).
- [ ] **P7.4** Unir los `.jsonl` de los cuatro integrantes, fuera de git.
- [ ] **P7.5** Subir a Bloque Neón: video y slides, material de soporte y video
  para pares.

---

## Cobertura del enunciado: pregunta → paso

| Pregunta del enunciado                                         | Pasos              |
| -------------------------------------------------------------- | ------------------ |
| **A.** ¿Qué variables predicen mejor `ln(Revenue)`?            | P2.4, P2.6         |
| **A.** ¿Qué patrones aparecen con los árboles?                 | P1.2, P2.3         |
| **A.** ¿Desempeño frente a los modelos lineales?               | P2.2, P2.5         |
| **A.** ¿Qué cambia al usar `ln(Revenue)` en vez de `Revenue`?  | P1.1, P2.5         |
| **A.** ¿Qué conclusiones del Taller 1 se mantienen o cambian?  | P1.3, P5.1         |
| **B.** ¿Cambia el ATE y su interpretación en log?              | P3.2, P3.3         |
| **B.** ¿Hay evidencia de HTE?                                  | P4.2               |
| **B.** ¿Cómo varían los CATE entre usuarios?                   | P4.1, P4.3         |
| **B.** ¿Qué características identifican grupos distintos?      | P4.3, P4.4         |
| **B.** ¿Grupos con efecto mayor, menor o cercano a cero?       | P4.3               |
| **B.** ¿Relación con el efecto promedio del Taller 1?          | P3.3, P4.5         |
| **B.** ¿Implicaciones para CheMarket?                          | P5.2               |
| Estructura sugerida (pasos 1 a 5) y presentación *McKinsey way* | H1, H5, H6         |
| Reproducibilidad (fuera de muestra, semilla 2026)              | P2.1, P2.5, P7.1   |
