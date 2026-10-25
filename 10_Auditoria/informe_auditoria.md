# Informe de auditoría del Taller 2 (ECON-3785, 2026-2)

- **Fecha:** 2026-10-25
- **Carpeta auditada:** `Taller_02_back Ups/` (copia de `../taller_02/`; subcarpetas y
  archivos de raíz idénticos byte a byte, ignorando `.git`, `.claude/`, `.gitignore`,
  `.Rhistory` y el `.Rproj`).
- **Estado:** cerrado. Fases 0 a 7 hechas; cambios A y B aplicados con aprobación
  del usuario (ver "Cambios hechos durante la auditoría").

## 1. Resumen ejecutivo

- **¿Responde a todo el enunciado?** Sí, en el análisis: las 12 preguntas tienen
  respuesta respaldada (`10_Auditoria/respuestas_enunciado.md`). Faltan el guion,
  los slides y el video (`04_Presentaciones/` y `08_Entregables/` vacíos). La
  escalera en log (H5) existe solo como salida de auditoría.
- **¿La HTE en log es sólida?** Sí: calibración diferencial 1.01 (ee 0.031) y AUTOC
  0.200 (IC 0.180 a 0.221) con muestra dividida, robusta sin tiempo en el sitio y
  con `W.hat` fijo o estimado.
- **¿Qué regla sostiene la evidencia?** "Registro facilitado para todos salvo
  celulares con Windows u otro SO". Se eligió en una mitad y se evaluó en la otra:
  0.657 dólares por usuario y +10.2% del gasto típico, frente a 0.416 y +0.8% de
  dárselo a todos. Supera a "solo computador y tableta" por 0.076 dólares (IC 0.031
  a 0.121). La confianza es alta en el signo por grupo; falta el mecanismo.
- **Errores que cambiaban el mensaje:**
  - "osx es de computadores y tabletas" era falso;
  - la atribución nivel–log ("solo transformación") estaba incompleta;
  - la cuenta de "dos tercios" era incorrecta;
  - los porcentajes leían puntos de log como %.

  Todos están corregidos.

## 2. Tabla de hallazgos

| ID | Severidad | Archivo o salida | Qué estaba mal | Evidencia | Corrección | Rúbrica |
| --- | --- | --- | --- | --- | --- | --- |
| H-01 | Crítico | `05_Notas/sintesis.md`; `12_…/B_cate_por_grupo.md` | "osx es de computadores y tabletas" | Dentro de cada dispositivo ≈ 30% osx; celular–osx 15.2% de la base (`aud_02_cruce_dispositivo_so.csv`) | Se elimina; regla por dispositivo × SO (script 13) | B. Análisis causal; B. Recomendación |
| H-02 | Crítico | Recomendación de la síntesis | La regla "solo computador y tableta" excluía un grupo con efecto positivo | Celular–osx +7.6% [+3.8; +11.6], +0.54 dólares; en evaluación +0.076 dólares por usuario (IC 0.031 a 0.121) | Regla nueva, evaluada fuera de la muestra de selección | B. Recomendación (H10) |
| H-03 | Alto | Síntesis, fila "Por qué las dos escalas difieren" | Atribuía todo a la transformación | Signos opuestos entre grupos (Σ peso × τ = 0.004); lo implicado por grupo explica 0.17 de 0.41 dólares; resto ≤ 0.17 | Atribución "ambos" (`X_conciliacion_por_celdas.md`) | B. Análisis causal (H2) |
| H-04 | Alto | Síntesis, aritmética de la regla | Valor de la regla sin intervalo y elegido con los mismos datos | — | Valor en la mitad de evaluación (`experimento_valor_reglas`) | B. Recomendación (H8, H10) |
| H-05 | Medio | Notas del 12 | Puntos de log leídos como % (−0.257 → "−25%") | −0.257 → −22.7% | `exp(τ) − 1` en todas las notas | B. Análisis causal (H8) |
| H-06 | Medio | Síntesis, Parte A | "Casi dos tercios… el resto del método (1.765 → 1.627)" | 68% corte y cruce, 12% LASSO, 20% árbol | Corregido | A. Análisis predictivo |
| H-07 | Medio | Script 12 | `W.hat` estimado (0.30 a 0.74) en un experimento con probabilidad común (H7) | Con `mean(W)` nada cambia de signo ni de significancia | `W.hat = mean(W)` en 12 y 13 | B. Validación (H7) |
| H-08 | Medio | Parte A en log | Sin escalera de RMSE en log (H5) | Corte 60%, sesiones y cruce 33%, dispositivo 6% | Agregada al script 04 (`observacional_escalera_rmse_log`) y a la nota | A. Análisis predictivo (H5) |
| H-09 | Bajo | Nota del 09 | Decía que dispositivo y SO aportan poco, pero el árbol en log los usa en 6 de 9 cortes | Hojas: computador +20% frente a celular; osx +42% (4 o más sesiones) | Agregado a la nota | A. Patrones de árboles |
| H-10 | Bajo | `00_main.R`, sección 1 | Exigía `taller_02.Rproj` | No corría en la copia de respaldo | Acepta cualquier `.Rproj` y exige `02_Scripts/` | Reproducibilidad |
| H-11 | Bajo | Scripts 10 y 11 | `ranger` sin `num.threads` | Las cifras coinciden en esta máquina | Limitación conocida (decisión del usuario) | Reproducibilidad |
| H-12 | Bajo | Script 10 | `min.node.size` = 100 en el borde de la rejilla | 200 a 800 bajan el error < 0.2% | Sin cambio | A. Análisis predictivo |
| H-13 | Bajo | `README.md` | Scripts existentes listados bajo "Scripts previstos (por llenar)" | — | Pendiente (P7.2) | Material de soporte |

## 3. Verificación de las lecturas del usuario

- **2a (ITT ≈ 0.49 en niveles, con balance, cumplimiento y representatividad):**
  confirmada. 0.491 (0.347 a 0.634); F = 0.96 y 0.66; cumplimiento perfecto.
- **2b (corte en 5 minutos, interacción con sesiones, diferencias por SO,
  dispositivo y recurrente):** confirmada. El árbol encuentra 5.0007 minutos solo
  con entrenamiento. El sesgo por haber elegido el corte mirando `test` no cambia el
  RMSE del lineal; basta declararlo.
- **2c (LASSO mejora poco sobre el lineal):** confirmada. λ por validación cruzada
  en `train`; 1.765 frente a 1.845 en la misma partición.
- **2d (en log el efecto desaparece):** confirmada. +1.3% (−1.0% a +3.8%).
- **"Hay HTE aun en log":** confirmada (sección 1).
- **Hipótesis de la Fase 5 (signos opuestos más ponderación por gasto):**
  matizada. Explica el ≈ 0 en log y una parte del efecto en dólares (0.17 de 0.41).
  El resto ocurre dentro de los grupos.
- **Regla de la otra revisión ("todos menos celular Windows u otro"):**
  confirmada, fuera de la muestra de selección.

## 4. Frente a la retroalimentación del Taller 1

- **Mejoró:**
  - descriptiva por covariable (H3);
  - escalera e importancia (H5);
  - especificación justificada (H4);
  - RMSE en unidades del negocio (H6);
  - balance y cumplimiento (H7);
  - conciliación nivel–log (H2);
  - recomendación sí/no con una pregunta abierta concreta (H10);
  - `pacman`, carpetas por script y tablas exportadas.
- **Sigue sin resolverse:**
  - la escalera en log está fuera del pipeline;
  - no hay costo de la intervención (H8);
  - faltan los supuestos de atribución en el video (H9);
  - faltan intervalos de los cuantiles (P3.3);
  - la presentación y el video no existen.

## 5. Pendientes para hoy (no ejecutados en la auditoría)

1. Guion y slides con las salidas del script 13, la conciliación y la
   recomendación nueva (P6.1 y P6.2): 2 a 3 h.
2. ~~Escalera en log~~: hecho. Se corrieron solo las secciones 1 a 3 de `00_main.R`
   y el script 04 (`10_Auditoria/scripts/aud_07_correr_04.R`, salida 0).
   - `observacional_escalera_rmse_log` (tabla y figura) coincide con
     `aud_04_escalera_dos_escalas.csv` con diferencia 0 en todos los pasos.
   - Las salidas en dólares del 04 no cambian (diferencia máxima 6e-13) y se
     reproduce el 2.314 / 2.716 del Taller 1.
   - La corrida final de `00_main.R` completo se detuvo por pedido del usuario
     durante el script 03. Reescribió las bases listas (mismo contenido:
     `all.equal` = TRUE) y 5 figuras del 03 (mismo código y datos). No hay una
     corrida completa de los 13 scripts juntos. La última completa (12 scripts)
     terminó sin errores. Los scripts que cambiaron después (04, 12 y 13) se
     corrieron por separado, tras las secciones 1 a 3, sin errores.
3. Ordenar el mapa del README (P7.2): 15 min.
4. Actualizar `PLAN.md` y `HANDOFF.md` (no se tocaron por instrucción del usuario).

## Alcance metodológico de la auditoría

Toda prueba, cálculo o recomendación de este informe usa solo métodos de
`07_Recursos/catalogo_metodos.md` y de clase (regla del usuario, 2026-10-25):

- Multiplicidad: se maneja como en la clase 18 y el Lab 10. El grupo o la regla
  se elige en una mitad del experimento (`cf_ent`) y se evalúa en la otra con un
  bosque independiente (`cf_eva`).
- Valor de una regla y diferencias entre reglas:
  `average_treatment_effect(cf_eva, subset = celdas)`, ponderado por el peso de
  esas celdas en la base histórica.
- `W.hat = mean(W)` en los bosques de verificación; lectura `exp(τ) − 1`; `feols`
  con interacciones y HC1; `test_calibration` y RATE con muestra dividida.

- La prueba F conjunta del balance y de la representatividad (`fixest::wald`,
  script 06) es econometría estándar del curso (Taller 1, F = 0.65) y se acepta.
- Tamaño mínimo de celda: toda tabla por celda o por mitad reporta el n de cada
  celda en cada mitad. Las celdas con menos de 100 observaciones en alguna mitad
  se marcan, y **no se sacan conclusiones de focalización a partir de ellas**.

**Fuera del alcance** (no se usa ni se recomienda): correcciones de p-valores por
comparaciones múltiples (p. ej. Bonferroni) y varianzas de combinaciones lineales
construidas a mano.

## Cambios hechos durante la auditoría

Cambios a archivos existentes del proyecto, cada uno con aprobación explícita del
usuario. Todo lo demás de la auditoría vive en `10_Auditoria/` y `00_main.R` no lo
llama.

### 1. `00_main.R`, sección 1: verificación de la raíz del proyecto

- **Aprobado por:** el usuario, en el chat de la sesión de auditoría (2026-10-25).
- **Motivo:** la verificación exigía `taller_02.Rproj`. Esta carpeta tiene
  `Taller_02_back Ups.Rproj`, así que `00_main.R` se detenía en la sección 1 y no
  podía correr aquí, ni tampoco los scripts de auditoría, que necesitan las secciones
  1 a 3. La nueva condición acepta cualquier `.Rproj` en la raíz y exige además
  `02_Scripts/`. Funciona en esta carpeta y en el repositorio original sin cambiar
  ningún nombre de archivo. Después se agregó el script 13 (ver la sección 3).
- **Antes:**

  ```r
  if (!file.exists("taller_02.Rproj")) {
    stop(
      "Este script debe ejecutarse con el directorio de trabajo en la raiz ",
      "del proyecto (donde esta taller_02.Rproj). Directorio actual: ", getwd()
    )
  }
  ```

- **Después:**

  ```r
  # la raiz es la carpeta que tiene un archivo .Rproj (con cualquier nombre, p. ej.
  # taller_02.Rproj o el de una copia de respaldo) y la carpeta 02_Scripts/
  if (length(list.files(pattern = "\\.Rproj$")) == 0 || !dir.exists("02_Scripts")) {
    stop("Ejecuta este script desde la raiz del proyecto (donde esta el .Rproj). ",
         "Directorio actual: ", getwd())
  }
  ```

- `CLAUDE.md` ("`00_main.R` es el único punto de entrada", paso 1) se actualizó
  después, por pedido del usuario.

### 2. Línea base de resultados antes de la corrida nativa

- `03_Resultados/` completo (98 archivos) se copió a
  `10_Auditoria/salidas/resultados_originales/` antes de correr `00_main.R` aquí,
  porque la corrida sobrescribe `03_Resultados/`. Copia verificada con `diff -rq`
  (idéntica).
- También se copiaron las bases listas (`01_Datos/03_Listos/*.Rds`), que la corrida
  regenera, a `10_Auditoria/salidas/listos_originales/`. No lo pidió el usuario; es
  solo una copia de respaldo y no cambia nada del proyecto.

### 3. Cambios A y B (aprobados por el usuario el 2026-10-25)

| Archivo | Cambio |
| --- | --- |
| `02_Scripts/12_heterogeneidad_experimento.R` | `W.hat = mean(W)` en `estimar_bosque()` (también en cada mitad). Se ajustan el encabezado, el mensaje de consola y la nota de la tabla del ATE. Corrido: las cifras cambian en decimales menores, sin cambios de signo ni de intervalos que crucen el cero; el mayor cambio es "otro SO" en dólares, de −0.08 a −0.13. |
| `02_Scripts/13_focalizacion_experimento.R` | Nuevo. Exporta `experimento_efecto_celdas_dispositivo_so` (tabla y figura), `experimento_efecto_celdas_dispositivo_sesiones`, `experimento_valor_reglas` y `experimento_conciliacion_celdas`. Corrido (1.4 min): reproduce exactamente las cifras de `aud_02` y `aud_03`. |
| `00_main.R` | Agregadas `03_Resultados/{Tablas,Figuras}/13_focalizacion_experimento` a `carpetas_salida` y el script 13 a `scripts`. Junto con el cambio de la sección 1, son los únicos cambios. Solo se corrieron las secciones 1 a 3 y los scripts 12 y 13 (`10_Auditoria/scripts/aud_05_correr_12_13.R`), no el pipeline completo. |
| `05_Notas/sintesis.md` | Reescrita según `propuestas/propuesta_sintesis.md`: regla nueva, estimando único, valor fuera de la muestra de selección, atribución "ambos", "dos tercios" corregido, `exp(τ) − 1` y preguntas abiertas según H10. |
| `05_Notas/13_focalizacion_experimento/` | Notas nuevas `B_regla_focalizacion.md` y `X_conciliacion_por_celdas.md`. |
| `05_Notas/12_heterogeneidad_experimento/` | `B_cate_por_grupo.md` pasa a `matizado` (sin "osx es de computadores y tabletas"); las tres notas, con cifras nuevas y `exp(τ) − 1`. |
| `05_Notas/09_arboles_observacional/A_cart_recupera_corte_5_min.md` | Cortes por dispositivo y SO del árbol en log, y la nota sobre el corte elegido con la base completa. |
| `05_Notas/04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md` | Escalera en `ln(Revenue)`, citada como salida de auditoría pendiente de pasar al script 04. |
| `05_Notas/README.md` | Índice: sección del 13, estado de `B_cate_por_grupo` y fila de la síntesis. |
| `CLAUDE.md` | La descripción de la verificación del `.Rproj` y cinco filas nuevas en "Decisiones tomadas": `.Rproj`, `W.hat`, script 13, regla nueva y `num.threads` como limitación conocida. |
| `README.md` | Fila del script 13 en el mapa script → resultados. |
| `10_Auditoria/respuestas_enunciado.md` | Nuevo: mensaje en 30 segundos, las 12 preguntas y la lista H1–H10. B4 corregido: el 61% y el 21% son la importancia de las variables dispositivo y sistema operativo en el bosque causal, no comparaciones entre categorías (misma corrección en `B_cate_por_grupo.md`). |
| `02_Scripts/04_prediccion_lineal_observacional.R` | Nueva sección 9: escalera de RMSE en `ln(Revenue)` (mismos pliegues y orden), exportada como `observacional_escalera_rmse_log` (tabla y figura). Las salidas en dólares no cambian. La nota de escalera, la síntesis, las respuestas y el README citan ahora esta salida del pipeline. |

**Procedimiento de notas:** la skill `registrar-hallazgo` no está disponible en esta
copia (`.claude/` no se copió), así que su procedimiento se siguió a mano. El
contraste quedó así:
- **Contradictorio con decisión del usuario:** la regla y "osx es de computadores".
- **Consistente:** escalera en log, cortes del árbol y cifras del 12 con `W.hat`
  fijo.

No se usó git ni `cerrar-sesion`. No se tocaron `PLAN.md`, `HANDOFF.md` ni las
bitácoras.

### 4. Efectos colaterales fuera del proyecto

- La primera corrida (en una copia en `Temp`, ya abandonada) hizo que `pacman`
  instalara `gt` y 9 dependencias (`V8`, `litedown`, `reactR`, `bigD`, `commonmark`,
  `htmlwidgets`, `juicyjuice`, `markdown`, `reactable`) en la librería de R del
  usuario (`C:/Users/Samue/AppData/Local/R/win-library/4.6`). Es el comportamiento
  esperado de `00_main.R` en una máquina sin `gt`.
- Las copias en `Temp` (`…/scratchpad/corrida/` y `…/Temp/aud_Econometría/`) ya no se
  usan. Sus corridas quedaron incompletas (la primera falló en el script 04 porque la
  ruta pasaba de 260 caracteres; la segunda se detuvo a mano en el 04) y no se usan
  como evidencia.

## Fase 0. Inventario

Ver `10_Auditoria/salidas/fase0_inventario.md`.

## Fase 1. Reproducibilidad

**Corrida:** `00_main.R` completo, nativo en esta carpeta, sesión limpia
(`Rscript --vanilla`), con `03_Resultados/` y las bases listas ya presentes (se
sobrescriben). Script `10_Auditoria/scripts/aud_00_correr_main.R`; registro
`10_Auditoria/salidas/aud_00_corrida.log`. Windows 11, R 4.6.1, grf 2.6.1,
ranger 0.18.0, rpart 4.1.27, glmnet 5.0, fixest 0.14.2, ggplot2 4.0.3, gt 1.4.0.

- **Resultado:** los 12 scripts corren sin errores (salida 0) en **45.6 min**
  (`HANDOFF.md` dice unos 17 min en otra máquina). Por script: 01–02 < 5 s; 03
  3.6 min; 04 0.4; 05 0.6; 06 0.6; 07 4.3; 08 0.4; 09 0.6; **10 30.9 min**; 11
  2.5; 12 1.5. El cuello de botella es la rejilla del bosque predictivo (36
  bosques de 300 árboles con 80,000 obs., más 4 de 1,000 con permutación).
- **Advertencias:** una sola, de forma (script 12: `geom_errorbarh()` está
  obsoleta en ggplot2 4.0). Las "14 advertencias" de `HANDOFF.md` no aparecen con
  estas versiones.
- **Ruta con tilde:** Chrome headless genera los `.png` de `guardar_tabla()` sin
  problema en `…\Econometría aplicada\…` en Windows (no probado antes según
  `HANDOFF.md`). Una ruta de más de 260 caracteres sí lo rompe (Chrome no
  escribe el archivo); no afecta esta carpeta.
- **Cifras regeneradas frente a la línea base**
  (`10_Auditoria/scripts/aud_01_comparar_corrida.R` →
  `10_Auditoria/salidas/aud_01_diferencias_csv.csv`): 34 `.csv` en las dos, ninguno
  falta ni sobra; 96 de 98 archivos se reescribieron. **Ninguna celda difiere en
  más de 1e-9**; 22 `.csv` cambian solo en los últimos dígitos de punto flotante
  (máximo 1.4e-10). Los 62 `.png` difieren byte a byte (render), no se revisaron
  a ojo.
- **Reproducibilidad entre máquinas:** las cifras de `ranger` (scripts 10 y 11,
  sin `num.threads`) y de `grf` (script 12, `num.threads = 4`) coinciden con las
  versionadas, generadas en otra máquina. El riesgo que señala `HANDOFF.md` no se
  materializó aquí, pero sigue abierto: `ranger` sin `num.threads` en
  `10_bosque_observacional.R:74` y `11_comparacion_prediccion_observacional.R:145`.
- **Cifras de `sintesis.md`:** como los `.csv` no cambian, las discrepancias son
  las de `fase0_inventario.md` §4 (afirmaciones sin `.csv`, la atribución "dos
  tercios" y "osx es de computadores y tabletas").
- **Reglas de `CLAUDE.md`:** ningún script de `02_Scripts/` llama a `library()`,
  `require()`, `p_load()` ni `dir.create()`; todo `::` es a paquetes del
  `p_load()`. Cada script escribe solo en su subcarpeta y todas están en
  `carpetas_salida`. Excepción menor: `00_formato_tablas.R` y `00_formato_graficas.R`
  no se verificaron línea por línea más allá de `guardar_tabla()`.

## Fases 2 y 3 (versión corta: solo lo que cambia una cifra o una conclusión del video)

Script `10_Auditoria/scripts/aud_04_prediccion_log.R` (1.8 min); árboles leídos de la
impresión del script 09 en `aud_00_corrida.log`.

- **Escalera de RMSE en `ln(Revenue)`** (`aud_04_escalera_dos_escalas.csv`; misma
  partición, mismos 5 pliegues y mismo orden que el 04; solo `train`). Es lo que
  faltaba para responder H5 en la escala del taller.

  | Paso | RMSE CV (log) | Caída | % de la caída total |
  | --- | --- | --- | --- |
  | Media | 0.5354 | — | — |
  | + más de 5 minutos | 0.4359 | 0.0995 | 60% |
  | + sesiones | 0.4167 | 0.0192 | 12% |
  | + cruce | 0.3810 | 0.0357 | 22% |
  | + dispositivo | 0.3715 | 0.0095 | 6% |
  | + SO, recurrente, registro | 0.3704 | < 0.001 cada uno | < 1% |

  Se reproduce el 0.3704 del lineal en `observacional_cart_poda.csv`. Mismo orden
  que en dólares y que la importancia del bosque. En log, el indicador de 5 minutos
  domina al tiempo continuo y a su logaritmo (0.370 frente a 0.434 y 0.448,
  `aud_04_robustez_forma_tiempo.csv`).
- **Árbol podado** (1-SE; log, 10 hojas; dólares, 9). Primer corte en 5.0007 min.
  - Con 5 minutos o menos, solo parte por dispositivo (log: celular 0.90, tableta
    1.00, computador 1.08; el usuario típico de computador gasta +20% que el de
    celular).
  - Con más de 5 minutos, parte por sesiones (< 2.5 y < 3.5) y, con 4 sesiones o
    más, por sistema operativo: osx 2.38 frente a 2.03, +42% (`exp(0.349) − 1`).
    Después parte otra vez por dispositivo.
  - **Usa dispositivo o SO en 6 de sus 9 cortes en log** (5 de dispositivo y 1 de
    SO), aunque su importancia por
    permutación sea baja. Corrige la nota del 09 en la lectura, no en las cifras.
  - No usa registro ni usuario recurrente; este último equivale a sesiones = 0.
- **Bosque, `min.node.size` en el borde** (`aud_04_rejilla_bosque_ampliada.csv`,
  mtry = 3, 300 árboles, `num.threads = 4`): RMSE OOB 1.6474 (100), 1.6462 (200),
  1.6447 (400) y 1.6447 (800) en dólares; en log, 0.3503 a 0.3498. Ampliar la rejilla
  baja el error menos de 0.2%: no cambia ninguna conclusión. El valor con nodo 100 es
  idéntico al del script 10 aun con `num.threads = 4`.
- **`num.threads`** sin fijar en `10_bosque_observacional.R:74` y
  `11_comparacion_prediccion_observacional.R:145`. En esta máquina las cifras
  coinciden con las versionadas. Corrección de una línea por script
  (`num.threads = 4`), solo si se exige igualdad garantizada entre máquinas.
- **Corte de 5 minutos elegido con la base completa** (incluye `test`). El árbol,
  que solo ve `train`, encuentra el mismo corte (5.0007) y la misma interacción con
  las sesiones; así que el RMSE de prueba del lineal (1.845) no depende de haber
  mirado `test`. Basta declararlo en una nota al pie de la diapositiva.
- **Atribución "dos tercios"**: de los 0.687 dólares que se ganan frente al lineal
  del Taller 1 (2.314 → 1.627), el corte y el cruce dan 0.469 (68%), el diccionario
  de LASSO 0.080 (12%) y el árbol 0.138 (20%). "El resto, del método (1.765 → 1.627)"
  es el 20%, no un tercio. La transformación es neutra en los árboles (1.6274 frente
  a 1.6265).
- **LASSO** (verificación breve): λ elegido con `cv.glmnet` y los pliegues de `train`
  (`foldid`); comparado en la misma partición y en las dos escalas (script 11). Sin
  hallazgos.
- **Fase 2 a y d**: ITT 0.491 dólares (0.347 a 0.634), balance F = 0.96 (p = 0.456),
  cumplimiento perfecto y representatividad F = 0.66 (p = 0.708) se reproducen
  exactamente. En log, 0.0134 (−0.010 a 0.037): **confirmado**.

## Fases 4 a 6 (verificaciones numéricas del bosque causal)

Script `10_Auditoria/scripts/aud_02_heterogeneidad_celdas.R` (corrido con
`aud_correr.R`, 1.8 min, sin advertencias). Salidas `10_Auditoria/salidas/aud_02_*.csv`.
Bosques de verificación con `W.hat = mean(W)` = 0.4957; dos bosques idénticos a los
del script 12 solo para comprobar que se reproducen. Partición en mitades con
`set.seed(2026)` (5,000 / 5,000). Todas las tablas traen el n de cada celda en cada
mitad. **Tableta–otro SO (45 / 39) y tableta–5 o más sesiones (71 / 83) tienen menos
de 100 observaciones en alguna mitad: de ellas no se saca ninguna conclusión de
focalización.**

### Fase 4. Especificación y ATE

- Se reproducen las cifras del script 12: ATE del bosque 0.00374 (log) y 0.4139
  dólares (`aud_02_ate_bosque_vs_mco.csv`).
- `W.hat` estimado por el script 12: mín. 0.303, p5 0.398, media 0.497, p95 0.596,
  máx. 0.739 (`aud_02_w_hat_script12.csv`). Con `W.hat = mean(W)`: ATE 0.0039 (IC
  −0.011 a 0.019) en log y 0.414 (0.330 a 0.498) en dólares; calibración diferencial
  1.008 (ee 0.031) en log y 1.062 (0.068) en dólares (`aud_02_calibracion_w_media.csv`).
  **La elección de `W.hat` no mueve nada**; la afirmación de la nota de 12, que no
  tenía tabla, queda respaldada.
- Bosque 0.414 frente a MCO 0.491 en dólares: no viene de `W.hat`. Los dos estiman
  el mismo ATE; la diferencia (0.077) es ≈ 1 error estándar de MCO (0.073) y los
  intervalos se traslapan. El bosque, como MCO con controles (0.454, ee 0.051), usa
  la variación que explican las covariables y es más preciso (ee 0.043).
- `time_spent`: balance sin diferencia (p = 0.247) y los efectos por grupo casi no
  cambian sin él (`experimento_robustez_sin_tiempo.csv`). Las conclusiones por
  dispositivo × SO no dependen de él.

### Fase 6.1. Dispositivo × SO (`aud_02_cruce_dispositivo_so.csv`)

**"Osx es de computadores y tabletas" es falso.** El SO es casi independiente del
dispositivo: dentro de cada dispositivo ≈ 30% osx, 10% otro y 60% Windows, en las
dos bases. Celular–osx son 1,486 usuarios del experimento (14.9%) y el 15.2% de la
base histórica, más que computador–osx (12.0%). Además, `is_returning_user = 0` si y
solo si `past_sessions = 0` en las dos bases (`aud_02_recurrente_vs_sesiones.csv`):
"usuario nuevo" está contenido en "0 a 2 sesiones" y no es un grupo aparte.

### Fase 6.2. Efecto por celda, muestra completa (`aud_02_efecto_por_celda.csv`, `aud_02_mco_por_celda.csv`)

Bosque (`average_treatment_effect(subset)`) y MCO saturado por celda (HC1); peso en
la base histórica.

| Celda | n | Peso hist. | Log, bosque | Log, MCO | Dólares, bosque | Dólares, MCO |
| --- | --- | --- | --- | --- | --- | --- |
| Computador–osx | 1,213 | 12.0% | 0.368 [0.327; 0.409] | 0.396 | 2.59 [2.23; 2.96] | 2.92 |
| Computador–Windows | 2,418 | 24.0% | 0.077 [0.049; 0.105] | 0.072 | 0.61 [0.44; 0.77] | 0.53 |
| Computador–otro | 398 | 4.0% | 0.071 [−0.003; 0.145] | 0.023 | 0.36 [−0.01; 0.73] | 0.08 |
| Celular–osx | 1,486 | 15.2% | 0.073 [0.037; 0.110] | 0.117 | 0.54 [0.31; 0.77] | 0.83 |
| Celular–Windows | 2,973 | 29.9% | −0.254 [−0.281; −0.228] | −0.255 | −0.67 [−0.77; −0.56] | −0.66 |
| Celular–otro | 516 | 5.0% | −0.216 [−0.277; −0.155] | −0.254 | −0.61 [−0.85; −0.36] | −0.76 |
| Tableta–osx | 312 | 3.0% | 0.300 [0.224; 0.376] | 0.365 | 1.93 [1.30; 2.56] | 2.49 |
| Tableta–Windows | 600 | 5.9% | 0.056 [−0.002; 0.114] | 0.079 | 0.39 [0.13; 0.65] | 0.55 |
| Tableta–otro (pequeña) | 84 | 1.0% | 0.116 [−0.034; 0.267] | −0.042 | 0.44 [−0.24; 1.13] | −0.56 |

- Bosque y MCO coinciden en signo en las 8 celdas grandes; solo difieren en
  tableta–otro, que es pequeña.
- **Aditividad** (`aud_02_mco_interacciones.csv`): en log, las cuatro triples
  interacciones registro × dispositivo × SO están cerca de 0, con IC que lo incluyen
  (estimaciones de −0.047 a 0.040). El efecto en log es aditivo: ≈ 0.41 − 0.31 ×
  celular − 0.35 × (no osx). En dólares no lo es (celular × Windows +0.89 [0.07;
  1.72]; celular × otro +1.25 [0.21; 2.29]): lo que es aditivo en proporciones deja
  de serlo en dólares cuando el gasto base difiere. **El SO separa tanto como el
  dispositivo**; el 61% de importancia del dispositivo en el bosque no lo refleja.

### Fase 5. Conciliación nivel vs. log (`aud_02_identidad_ate.csv`, `aud_02_efecto_por_celda.csv`)

- Identidad ATE = E[τ(X)]: el promedio de los efectos por celda, ponderado por el
  peso de cada celda en el experimento, reproduce el ATE global en las dos escalas y
  en las dos particiones (log 0.00388; dólares 0.4139). Con pesos históricos: 0.003
  y 0.410.
- **Signos opuestos en log**: las celdas positivas (65% del experimento) y las
  negativas (35%) se cancelan: Σ peso × τ_log = 0.004.
- **¿Las celdas positivas son las de mayor gasto base?** Sí, aunque con poca
  diferencia: gasto medio del control de 4.16 dólares en las celdas con efecto
  positivo frente a 3.64 en las negativas (dispositivo × SO); 4.25 frente a 3.72
  (dispositivo × sesiones). Correlación por celda entre gasto base y τ_log: 0.75 y
  0.60.
- **Cuánto del ATE en dólares explica eso** (solo con los efectos por celda,
  exp(τ) − 1 y el gasto medio del control):
  - con un gasto común (3.98): 3.98 × Σ peso × (exp(τ) − 1) = 0.10 dólares;
  - con el gasto del control de cada celda: Σ peso × gasto_c × (exp(τ) − 1) = 0.17;
  - ATE en dólares: 0.41.
  - En 8 de 9 celdas el efecto en dólares supera al implicado por su efecto
    proporcional (p. ej. computador–osx 2.59 frente a 2.05; celular–osx 0.54 frente
    a 0.29).
- **Lectura**: la explicación propuesta se sostiene en parte. Los signos opuestos
  entre celdas (método) explican por qué el ATE en log es ≈ 0, y la ponderación por
  gasto base empuja el promedio en dólares hacia arriba (de 0.10 a 0.17). Pero más
  de la mitad del ATE en dólares (≈ 0.24 de 0.41) ocurre **dentro** de las celdas:
  el tratamiento sube la media en dólares de cada celda más de lo que mueve su media
  geométrica. Es el ensanchamiento de la distribución de la nota del 08, ahora dentro
  de cada celda (transformación). La atribución correcta es "ambos": heterogeneidad
  de signo entre grupos (método), más ensanchamiento dentro de los grupos y gasto
  base distinto (transformación).

**Partición fina, dispositivo × SO × tramo de sesiones**
(`10_Auditoria/scripts/aud_03_conciliacion_celdas_finas.R`;
`aud_03_resumen.csv`, `aud_03_efecto_celdas_finas.csv`). De 27 celdas, 20 tienen
n ≥ 100 y cubren a 9,601 de 10,000 usuarios. En esa población el ATE es 0.391
dólares. Lo implicado por los efectos proporcionales y el gasto base suma 0.149 con
dispositivo × SO y 0.218 con la partición fina. El residuo dentro de las celdas baja
de 0.241 a 0.172 dólares: **las sesiones absorben 29% del residuo**. Lo que queda
(0.17 de 0.39) es una **cota superior** de lo atribuible a la transformación, porque
puede incluir heterogeneidad por otras variables (p. ej. el tiempo en el sitio).

### Fases 6.3 a 6.6. Reglas elegidas en una mitad y evaluadas en la otra

`cf_ent` elige las celdas con efecto > 0 (sin celdas pequeñas); `cf_eva`,
independiente, evalúa con `average_treatment_effect(cf_eva, subset)` × peso
histórico (`aud_02_mitades_por_celda.csv`, `aud_02_mitades_valor_reglas.csv`,
`aud_02_mitades_diferencias_reglas.csv`).

- **Regla elegida en entrenamiento (dispositivo × SO)**: tratar todo menos
  celular–Windows y celular–otro (y tableta–otro, excluida por tamaño). Coincide
  con la regla de la otra revisión.
- **Valor frente a "nadie" en la mitad de evaluación (dólares por usuario):** todos
  0.416 (ee 0.061); computador y tableta 0.578 (0.051); todos menos celular Windows
  u otro 0.657 (0.056); regla elegida por dispositivo × sesiones 0.535 (0.053); 3 o
  más sesiones 0.470 (0.056).
- **Diferencias entre reglas, solo con las celdas en que difieren** (mitad de
  evaluación):

  | Comparación | Celdas | n (ent. / eva.) | Efecto en esas celdas | × peso = por usuario |
  | --- | --- | --- | --- | --- |
  | Todos menos cel. Win/otro − computador y tableta | celular–osx | 746 / 740 | 0.50 dólares [0.21; 0.80]; log 0.089 [0.036; 0.141] | **+0.076 dólares (ee 0.023)**; log +0.013 (0.004) |
  | Todos − todos menos cel. Win/otro | celular–Windows y –otro | 1,727 / 1,762 | −0.67 [−0.80; −0.55]; log −0.252 | −0.235 (0.022) |
  | Todos − computador y tableta | celulares | 2,473 / 2,502 | −0.33 [−0.45; −0.20]; log −0.151 | −0.164 (0.032) |
  | Todos − 3 o más sesiones | 0 a 2 sesiones | 2,086 / 2,091 | −0.14 [−0.24; −0.04]; log −0.071 | −0.058 (0.022) |

- **Lo que sobrevive** (mismo signo en las dos mitades y IC de evaluación que excluye
  el cero, en las dos escalas): computador–osx, computador–Windows, celular–osx y
  tableta–osx positivos; celular–Windows y celular–otro negativos. Computador–otro y
  tableta–Windows son positivos en entrenamiento, pero su IC de evaluación incluye el
  cero: no hay evidencia ni de daño ni de beneficio.
- **Sesiones frente a dispositivo × SO**: la regla elegida por dispositivo ×
  sesiones incluye, en dólares, celular–5 o más por su estimación de entrenamiento
  (0.25, IC que incluye el cero), que en evaluación no se sostiene (−0.03). En log,
  los celulares son negativos en los tres tramos de sesiones. La regla por
  dispositivo × SO vale más (0.657 frente a 0.535) y sus celdas positivas se
  sostienen; la de sesiones sola, menos (0.470). Las tres variables son observables
  cuando el usuario entra.
- **Plausibilidad (H10)**: los datos no muestran ningún mecanismo que explique por
  qué el mismo formulario baja el gasto en celulares Windows u otro y lo sube en
  celulares osx. Va a "Preguntas abiertas". La evidencia que lo resolvería es una
  validación focalizada en celulares no osx (brazos: formulario facilitado frente al
  actual; métrica: ingreso por usuario). Si el efecto resulta ≥ 0, se extiende a
  todos.
