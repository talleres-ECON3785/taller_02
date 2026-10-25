# Bitácora — 2026-10-25: árboles para predicción (CART y bosque) y comparación en prueba con los lineales

## Resumen
El usuario pidió avanzar, en paralelo con la sesión que pasaba la escalera lineal y LASSO a `ln(Revenue)`, el siguiente paso del plan: evaluar métodos con árboles para predicción y compararlos con la regresión lineal. Antes de empezar se acordó con el usuario:
- **Coordinación:** solo archivos nuevos al principio; los compartidos (`00_main.R`, README, PLAN, CLAUDE.md), al final, después de traer `origin`.
- **Alcance:** CART, bosque y comparación en prueba.
- **Escalas:** las dos, dólares y `ln(Revenue)`.
- **Variables:** las 6 crudas del Taller 1, con el tiempo continuo y sin el indicador de 5 minutos ni el cruce.
- **Retransformación (P2.5):** se reportan las dos comparaciones, la mejora % frente a la media y el RMSE en dólares con smearing de Duan.
- **Scripts:** uno por método, 09 CART, 10 bosque y 11 comparación.
- **Dependencia parcial del bosque:** el usuario la rechazó (no se amplía el catálogo).

Resultados centrales (prueba, n = 20,000, evaluada una sola vez):
- **Dólares:** el árbol podado tiene un RMSE de 1.627 y el bosque de 1.626, frente a 1.765 de LASSO, 1.845 del lineal con corte y cruce y 2.314 del Taller 1.
- **Logaritmo llevado a dólares:**
  - los árboles quedan igual (1.627);
  - los lineales simples empeoran (2.382 y 1.952);
  - LASSO mejora un poco (1.746).
- **Atribución:** la ganancia frente a LASSO viene del método, no de la transformación.
- **Patrones:**
  - el árbol encuentra solo el corte en 5.0007 minutos, con datos de entrenamiento;
  - solo parte por sesiones anteriores del lado de más de 5 minutos;
  - agrega interacciones de tres variables con sistema operativo y dispositivo.
- **Importancia:** tiempo y sesiones concentran más del 90% en el árbol y en el bosque; el registro, cerca de 0.

El contenedor no traía R: se instalaron R 4.3 y los paquetes del `p_load()`, y se fijaron `LC_ALL=C.UTF-8` y `CHROME_PATH` (Chromium de Playwright) para correr los scripts y `guardar_tabla()`. `00_main.R` completo corre los 11 scripts sin errores (15.8 minutos), con las carpetas 09–11 borradas antes. Las salidas de los scripts 01–08 que se regeneraron en el contenedor se restauraron sin versionarlas: solo cambiaban por la versión de R y las fuentes.

Objetivos de `HANDOFF.md`:
1. P1.3 y cierre de P1.2: los cerró la sesión paralela (commit 34507eb).
2. P2.2 (resto): lo trabaja la sesión paralela.
3. P2.3: cerrado. También se cerraron P2.4 y P2.5, y avanzó P2.6 (importancia del árbol y del bosque).

## Archivos
- **Creados:**
  - `02_Scripts/09_arboles_observacional.R`, `02_Scripts/10_bosque_observacional.R` y `02_Scripts/11_comparacion_prediccion_observacional.R`;
  - `03_Resultados/{Tablas,Figuras}/{09_arboles_observacional,10_bosque_observacional,11_comparacion_prediccion_observacional}/`;
  - `05_Notas/09_arboles_observacional/A_cart_recupera_corte_5_min.md`, `05_Notas/10_bosque_observacional/A_importancia_bosque.md` y `05_Notas/11_comparacion_prediccion_observacional/X_rmse_metodo_por_escala.md`;
  - esta bitácora.
- **Modificados:**
  - `00_main.R`, `02_Scripts/00_formato_graficas.R`, `README.md`, `PLAN.md`, `CLAUDE.md`, `HANDOFF.md` y `05_Notas/README.md`;
  - las notas `05_Notas/03_punto_partida/A_sesiones_pasadas_interaccion_tiempo.md`, `05_Notas/04_prediccion_lineal_observacional/A_corte_5_minutos_captura_tiempo.md` y `05_Notas/05_lasso_observacional/A_lasso_vs_lineal_flexible.md` (solo el historial).
- **Eliminados:** ninguno.

## Detalle por archivo

### `02_Scripts/09_arboles_observacional.R` (CART)
- **Estimando, estimador y estimación:**
  - estimando: la predicción del ingreso de un usuario nuevo (no hay parámetro causal);
  - estimador: árbol de regresión podado por costo-complejidad;
  - estimación: el RMSE de validación cruzada y los cortes del árbol.
- **Datos:** la misma partición 80/20 con `set.seed(2026)` y los mismos 5 pliegues que los scripts 04 y 05. No se usa `test`; se verificó que el script no lo menciona. Sin pérdidas de observaciones.
- **Variables del estimador** (`07_Recursos/catalogo_metodos.md`, sección 3, Lab 07):
  - *Criterio de partición* (`method = "anova"`): en cada nodo se elige la variable y el punto de corte que más reducen la suma de cuadrados de los residuos. La predicción de cada lado es su promedio. Es la pérdida cuadrática, coherente con medir el desempeño con RMSE.
  - *Predicción de una hoja:* el promedio del ingreso (o de su logaritmo) de los usuarios de entrenamiento que caen en ella.
  - *`cp`* (parámetro de complejidad) = α / suma de cuadrados de la raíz. Un corte se conserva si reduce el error relativo en más de `cp`. `cp = 0` deja crecer el árbol hasta `minbucket = 7` observaciones por hoja (3,939 cortes en dólares y 4,492 en logaritmo).
  - *Poda:* se elige el subárbol con la tabla `cptable`:
    - `xerror` es el error relativo de la validación cruzada interna de 10 pliegues (`xval = 10`, con `set.seed(2026)` justo antes);
    - `xstd` es su error estándar;
    - la *regla del mínimo* toma el `xerror` más bajo;
    - la *regla 1-SE* toma el árbol con menos cortes cuyo `xerror` no supera el mínimo más un `xstd`.
  - El titular es el de la 1-SE, declarado antes de ver los resultados por ser el más legible: 9 hojas en dólares y 10 en logaritmo.
- **RMSE de validación cruzada en los 5 pliegues de 04 y 05:** el árbol se reajusta sin el pliegue (con `xval = 0`) y se poda con el `cp` elegido en todo el entrenamiento. Es levemente optimista para el árbol (el `cp` se eligió con todo el entrenamiento), y se declara así. La referencia es el lineal final del 04 en la misma escala.
- **Tabla de cortes:** se arma con `labels(arbol, pretty = 0)` (nombres completos de las categorías). La condición de la rama izquierda se traduce al español.
- **Importancia:** `variable.importance` de `rpart` (ampliación registrada), en % del total de cada árbol.
- **Figura del árbol:**
  - se dibuja con `rpart.plot` (tipo 2) y la rampa clara → azul de la paleta;
  - las etiquetas de los cortes (`split.fun`) y de los nodos (`node.fun`, con la predicción con los decimales de su escala, el n con separador de miles y el %) están en español, y la rama dice "sí/no";
  - título, subtítulo y nota van en márgenes externos (`oma`) para que el árbol no se monte sobre ellos.

### `02_Scripts/10_bosque_observacional.R` (bagging y bosque)
- **Variables del estimador** (`catalogo_metodos.md`, sección 4, Lab 08):
  - *Bootstrap:* cada árbol se ajusta con una muestra con reemplazo del tamaño del entrenamiento (`replace = TRUE`, `sample.fraction = 1`). Los usuarios que no entran a la muestra de un árbol son su "fuera de bolsa".
  - *`mtry`:* número de variables sorteadas en cada corte. Con 6 es bagging; con menos es un bosque aleatorio, y el sorteo descorrelaciona los árboles.
  - *`min.node.size`:* un nodo con menos observaciones no se parte. Controla la profundidad de cada árbol.
  - *Predicción:* el promedio de las predicciones de los árboles.
  - *Error fuera de bolsa:* `prediction.error` es el error cuadrático medio de predecir a cada usuario solo con los árboles que no lo usaron. Su raíz es el RMSE OOB, que sirve para elegir hiperparámetros sin tocar `test`.
  - *Importancia por permutación* (`importance = "permutation"`, ampliación registrada): aumento del error OOB al desordenar una variable. Se reporta como % de la suma; los valores negativos cuentan como 0.
  - *Semilla:* `seed = 2026` en cada llamada (`ranger` no usa `set.seed`).
- **Rejilla:** `mtry` de 1 a 6 por `min.node.size` 5, 25 y 100, con 300 árboles, en las dos escalas (36 bosques, unos 8 minutos). En las dos escalas se eligió `mtry = 3` con nodo 100, reestimado con 1,000 árboles; el bagging (`mtry = 6`) toma su mejor nodo. Como el nodo 100 es el borde de la rejilla, la nota de la tabla declara el rango del RMSE entre tamaños de nodo con `mtry = 3`: menos de 0.007 dólares y 0.002 en logaritmo.
- **Fallo corregido:** en la primera versión, los bosques finales quedaban en una lista con el orden previo al `arrange()`, así que la importancia del bosque en logaritmo se calculaba con el bagging en dólares. Se detectó porque el aumento del error en logaritmo era del mismo orden que en dólares. Se corrigió guardando cada bosque como columna de lista de `elegidos`.
- El `.csv` de la tabla de hiperparámetros elegidos lo lee el script 11.

### `02_Scripts/11_comparacion_prediccion_observacional.R` (evaluación en prueba)
- Reestima con el entrenamiento, en las dos escalas: ingenuo, lineal del Taller 1, lineal final del 04, LASSO del 05 (mismo diccionario de 74 columnas, mismo `foldid`, `lambda.min`), árbol del 09 (`cp` leído de su `.csv`) y bosque del 10 (hiperparámetros leídos de su `.csv`). Aquí no se elige ningún hiperparámetro. La prueba se usa una sola vez.
- **Smearing de Duan**, para llevar a dólares la predicción en logaritmo:
  - fórmula: `E[Revenue | X] = exp(predicción en log) × E[exp(residuo)]`;
  - el segundo factor se estima con el promedio de `exp(residuo)` en entrenamiento, uno por modelo;
  - en el bosque se usan los residuos fuera de bolsa (`bosque$predictions`), porque los de dentro de muestra son casi cero y subestimarían la dispersión;
  - factores: 1.18 en el ingenuo, 1.11 en el lineal del Taller 1, 1.07 en el lineal final y en LASSO, 1.06 en el árbol y el bosque;
  - en el ingenuo, la retransformación da exactamente la media en dólares;
  - es el mismo factor que la nota del script 08 usa para el ITT; allí se mostró que un factor común a grupos con dispersión distinta sesga el promedio, y aquí se reporta como límite.
- **Verificación con `stopifnot`:** en dólares se reproducen 2.716, 2.314, 1.845 y 1.765 (scripts 04 y 05, Taller 1).
- **Tabla:** filas agrupadas en lineal y árboles; tres bloques de columnas: modelo en dólares, modelo en logaritmo y logaritmo llevado a dólares.
- **Figura:** mejora % frente a la media por modelo, en tres paneles; lineal en azul y árboles en ocre.

### `02_Scripts/00_formato_graficas.R`
Se agregó `guardar_figura_base(nombre, dibujar, carpeta)` para las figuras de gráficos base (el árbol de `rpart.plot`), que `ggsave()` no guarda. Abre `png()` con 9×6 pulgadas, 300 dpi y fondo blanco, igual que `guardar_figura()`, y no crea carpetas. Se registró en "Formato de las gráficas" de `CLAUDE.md`.

### `00_main.R`, `README.md`, `PLAN.md`, `CLAUDE.md`, `05_Notas/README.md`
- `00_main.R`: 6 carpetas de salida nuevas y los 3 scripts en la lista.
- `README.md`: mapa script → resultados de 09, 10 y 11; la heterogeneidad pasa a `12_`.
- `PLAN.md`: P2.3, P2.4 y P2.5 marcados; avance de P2.6; scripts de H2 y H4 renumerados.
- `CLAUDE.md`: dos decisiones (organización y especificación de los árboles; P2.5 con smearing por modelo y sin dependencia parcial).
- `05_Notas/README.md`: índice de las tres notas nuevas.

## Resultados nuevos (tablas, figuras, gráficos)
- **Script 09** (entrenamiento, n = 80,000). Nota: [A_cart_recupera_corte_5_min.md](../05_Notas/09_arboles_observacional/A_cart_recupera_corte_5_min.md).
  - `Figuras/09_arboles_observacional/observacional_cart_arbol_dolares.png` y `observacional_cart_arbol_log.png`: muestran qué grupos arma el árbol y que el primer corte es el de 5 minutos.
  - `Tablas/09_arboles_observacional/observacional_cart_poda` y `observacional_cart_cortes`: error de validación cruzada del árbol frente al lineal final, y los cortes.
  - `Figuras/09_arboles_observacional/observacional_cart_importancia.png`: importancia de cada variable en el árbol.
- **Script 10** (entrenamiento). Nota: [A_importancia_bosque.md](../05_Notas/10_bosque_observacional/A_importancia_bosque.md).
  - `Tablas/10_bosque_observacional/observacional_bosque_elegido` y `Figuras/10_bosque_observacional/observacional_bosque_rejilla.png`: hiperparámetros por error fuera de bolsa.
  - `Figuras/10_bosque_observacional/observacional_bosque_importancia.png`: qué usa el bosque para predecir.
- **Script 11** (prueba, n = 20,000). Nota: [X_rmse_metodo_por_escala.md](../05_Notas/11_comparacion_prediccion_observacional/X_rmse_metodo_por_escala.md).
  - `Tablas/11_comparacion_prediccion_observacional/observacional_rmse_prueba_comparacion` y la figura del mismo nombre: la tabla de método por escala que responde "¿cómo se comparan árboles y lineales?" y "¿qué cambia con `ln(Revenue)`?".

**Contraste con las notas previas y el Taller 1:** consistente. Se mantienen el corte de 5 minutos, la interacción con las sesiones, el orden de importancia de la escalera lineal y que el registro no aporta a la predicción. Se reproducen los RMSE previos. Se dejó una línea en el historial de las notas del 03, 04 y 05. No hay contradicciones pendientes.

## Pendientes
- **Contraste con la sesión paralela:** cuando suba la escalera y LASSO en `ln(Revenue)` (scripts 04 y 05), contrastar sus cifras con la celda lineal × logaritmo del 11. Si usa otra especificación, ajustar el 11 o la nota `X_rmse_metodo_por_escala.md`. Al traer sus cambios pueden chocar `00_main.R`, `README.md`, `PLAN.md` y `CLAUDE.md`.
- **Variabilidad:** no hay variabilidad entre particiones. La diferencia árbol − LASSO (0.138 dólares) se lee frente a errores estándar entre pliegues de cerca de 0.01; la diferencia árbol − bosque (0.002) no se distingue.
- **Rejilla del bosque:** el tamaño de nodo elegido (100) es el borde de la rejilla. Probar 250 o más no cambiaría la conclusión (rango menor que 0.007 dólares), pero podría bajar el error del bosque en el tercer decimal.
- **Reproducibilidad de `ranger`:** usa todos los núcleos; con otro número de núcleos las cifras pueden moverse en el tercer decimal. Si se exige reproducibilidad exacta entre máquinas, fijar `num.threads` y registrarlo.
- **Entorno Linux:** en una máquina Linux sin locale UTF-8, `source(..., encoding = "UTF-8")` falla con los acentos; hay que correr con `LC_ALL=C.UTF-8`. `guardar_tabla()` necesita `CHROME_PATH` si Chrome no está en las rutas habituales. Probado aquí con el Chromium de Playwright.
- **Siguiente paso:** pasar a la Parte B: representatividad (P3.1), ATE del bosque causal y la decisión de `W.hat` (P3.2), y bosque causal y evidencia de heterogeneidad (P4.1 y P4.2) en `12_heterogeneidad_experimento.R`.
