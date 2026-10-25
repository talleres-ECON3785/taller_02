# Bitácora — 2026-10-25: bosque causal, CATE y evidencia de heterogeneidad (script 12)

## Resumen
El usuario pidió el siguiente paso para evaluar los CATE con bosques causales: primero el plan y después las preguntas. El plan propuso un script nuevo, `12_heterogeneidad_experimento.R`, que cubre H4 (P4.1–P4.6) y el ATE del bosque que faltaba en P3.2. El usuario decidió:
- **`W.hat`:** lo estima `grf` (no se fija en 0.5).
- **Multiplicidad:** los grupos solo llevan advertencia, sin ajustar p-valores (no se amplía el catálogo).
- **Un solo script** para logaritmo, dólares y robustez.
- **Hilos fijos:** `num.threads = 4`, para reproducir las cifras entre máquinas.
- **Responsable de H4:** Santiago Muñoz.

Resultados centrales (experimento, n = 10,000):
- **ATE:** el bosque reproduce el promedio de la regresión. En `ln(Revenue)` da 0.004 (IC −0.011 a 0.019), frente a 0.013 de MCO. En dólares da 0.414 (0.328 a 0.499), frente a 0.491.
- **Evidencia formal de HTE:**
  - calibración: coeficiente diferencial 1.01 en logaritmo (error estándar 0.031) y 1.06 en dólares, ambos con p unilateral < 0.001;
  - muestra dividida: AUTOC 0.200 (0.180 a 0.221) en logaritmo.
- **Efectos por grupo** (en logaritmo):
  - positivos: computador (+0.163), tableta (+0.138), osx (+0.213) y 3 o más sesiones;
  - negativos: celular (−0.152), Windows (−0.089), usuario nuevo (−0.112) y 0 a 2 sesiones (−0.087).
- **Dos escalas:** la heterogeneidad aparece en logaritmo y en dólares. En dólares se agranda en los grupos de mayor gasto (más de 5 minutos: 0.84 frente a 0.16 dólares, aunque en logaritmo no hay diferencia).
- **Robustez:** sin tiempo en el sitio, los efectos por grupo casi no cambian.

`00_main.R` completo corre los 12 scripts sin errores. Al repetir la corrida, las cifras del script 12 coinciden hasta el quinto decimal: las tablas muestran 3 decimales, así que se ven idénticas. Las salidas de los scripts 01–08 regeneradas en el contenedor (Linux) solo cambiaban en los últimos dígitos y en el render de las fuentes; se restauraron sin versionarlas.

Objetivos de `HANDOFF.md`:
1. P2.2 (resto) y P2.6 en `ln(Revenue)`: no se trabajó aquí (sesión paralela).
2. P3.1 y P3.2:
   - P3.2 cerrado: ATE del bosque y decisión de `W.hat`;
   - P3.1 (representatividad) no se trabajó.
3. P4.1 y P4.2: cerrados, junto con P4.3–P4.6.

## Archivos
- **Creados:**
  - `02_Scripts/12_heterogeneidad_experimento.R`;
  - `03_Resultados/Tablas/12_heterogeneidad_experimento/` (6 tablas, `.png` y `.csv`);
  - `03_Resultados/Figuras/12_heterogeneidad_experimento/` (3 figuras);
  - `05_Notas/12_heterogeneidad_experimento/B_evidencia_hte.md`, `B_cate_por_grupo.md` y `X_hte_nivel_vs_log.md`;
  - esta bitácora.
- **Modificados:**
  - `00_main.R`, `CLAUDE.md`, `PLAN.md`, `README.md`, `HANDOFF.md`;
  - `07_Recursos/catalogo_metodos.md` y `05_Notas/README.md`;
  - `05_Notas/08_ate_experimento_log/B_log_a_dolares_efecto_registro.md` (solo el historial).
- **Eliminados:** ninguno.

## Detalle por archivo

### `02_Scripts/12_heterogeneidad_experimento.R`
- **Estimando, estimador y estimación:**
  - estimando: el ATE y los CATE(x) del registro facilitado sobre `ln(Revenue)` (cambio proporcional aproximado) y, para comparar con el Taller 1, sobre `Revenue` en dólares;
  - estimador: bosque causal de `grf` con árboles honestos;
  - estimación: las cifras de las tablas.
  - Solo el experimento sostiene la lectura causal.
- **Datos:** `experimento_listos.RDS` (10,000 obs., sin pérdidas). La base histórica (100,000 obs.) se usa solo para el peso de cada grupo.
- **Covariables:** las 5 pre-tratamiento crudas, con el tiempo continuo, como los árboles de la Parte A. Las categóricas entran como indicadores, con computador y osx como referencia.
- **Especificaciones:** las tres usan la misma función `estimar_bosque()`, con 2,000 árboles, `seed = 2026` y `num.threads = 4`, sin `W.hat` y sin `clusters`.
  - principal: `ln(Revenue)`;
  - nivel: `Revenue` en dólares (P4.5);
  - robustez: `ln(Revenue)` sin `time_spent` (P4.6), porque el tiempo se mide en la misma sesión que el gasto.
- **Variables del estimador** (`07_Recursos/catalogo_metodos.md`, sección 5, Lab 10; Athey, Tibshirani y Wager 2019):
  - *`Y.hat` (m̂(x))*: predicción del resultado con un bosque de regresión de Y sobre X, fuera de bolsa. Se resta del resultado (Y − Ŷ) para ortogonalizar: el efecto se estima con la variación del resultado que las covariables no explican.
  - *`W.hat` (ê(x))*: probabilidad de tratamiento estimada con un bosque de regresión de W sobre X. Se resta de W (W − Ŵ). Por diseño debería ser constante cerca de 0.5. Estimada va de 0.303 a 0.739 (media 0.497) por ruido del bosque de propensión. Con `W.hat = 0.5`, el ATE en dólares es el mismo (0.414; chequeo de la sesión, no exportado).
  - *Pesos αᵢ(x)*: cuánto pesa cada usuario de entrenamiento en el efecto de un punto x. Es la fracción de árboles en que el usuario cae en la misma hoja que x, dividida por el tamaño de la hoja. La honestidad hace que la mitad de cada submuestra elija los cortes y la otra mitad estime dentro de las hojas.
  - *CATE τ̂(x)*: resuelve un problema de momentos ponderado por αᵢ(x): τ̂(x) = Σ αᵢ(x)(Wᵢ − Ŵᵢ)(Yᵢ − Ŷᵢ) / Σ αᵢ(x)(Wᵢ − Ŵᵢ)². Es una regresión local del resultado ortogonalizado sobre el tratamiento ortogonalizado. Se usa fuera de bolsa (`predict(cf)`), así que el efecto de cada usuario lo estiman árboles que no lo usaron.
  - *Varianza del CATE* (`estimate.variance = TRUE`, ampliación registrada): estimada con grupos de árboles (`ci.group.size = 2`). Da el intervalo τ̂ ± 1.96·√var de cada usuario.
  - *ATE doblemente robusto* (`average_treatment_effect`): promedio de τ̂(Xᵢ) más una corrección con el residuo ponderado por la propensión. Es consistente si el modelo del resultado o el de la propensión es correcto. Con `subset` da el ATE de un grupo (ampliación registrada).
  - *Prueba de calibración* (`test_calibration`): regresión de Y − Ŷ sobre dos términos, cada uno multiplicado por (W − Ŵ): el CATE promedio y la desviación de cada τ̂ respecto de ese promedio.
    - Coeficiente medio ≈ 1: el ATE está bien calibrado.
    - Coeficiente diferencial > 0 (p unilateral): las diferencias predichas se asocian a diferencias reales; ≈ 1 indica el tamaño correcto.
  - *TOC/AUTOC* (`rank_average_treatment_effect`): con muestra dividida 50/50 por usuario (`sample` con la semilla), un bosque de entrenamiento fija las prioridades de la otra mitad. Un bosque estimado solo en esa mitad evalúa la curva TOC(q) = ATE del q% priorizado − ATE total. AUTOC es el área bajo la curva. Así, priorizar y evaluar no usan los mismos datos.
- **Grupos (P4.3):** fijados en `PLAN.md` antes de estimar: dispositivo, sistema operativo, recurrente, más o menos de 5 minutos y sesiones en 0–2, 3–4 y 5 o más (los cuantiles 1/3 y 2/3 del experimento son 2 y 4). Los grupos son efectos condicionales estimados: no son aditivos, y una característica que separa grupos no es la causa de la diferencia.
- **ATE de MCO:** se lee de los `.csv` de 06 y 08 para no estimarlo dos veces.

### `00_main.R`
Se agregó el script 12 a `scripts` y sus dos subcarpetas a `carpetas_salida`. No hacen falta paquetes nuevos: `grf` ya estaba.

### `CLAUDE.md`, `07_Recursos/catalogo_metodos.md`
- `CLAUDE.md`: decisión del 2026-10-25 en "Decisiones tomadas" (un script, tres especificaciones, `W.hat` estimado, hilos fijos, multiplicidad solo con advertencia).
- Catálogo: nota en la sección 5 de que `W.hat` se dejó estimar, porque el enunciado no da la probabilidad del diseño. No es una ampliación.

### `PLAN.md`, `README.md`, `05_Notas/README.md`
- `PLAN.md`: P3.2 y P4.1–P4.6 marcados.
- `README.md`: mapa del script 12; en la fila del 08, el bosque causal pasa al 12.
- `05_Notas/README.md`: índice con las tres notas nuevas.

## Resultados nuevos (tablas, figuras, gráficos)
Todos los genera `02_Scripts/12_heterogeneidad_experimento.R` en `03_Resultados/{Tablas,Figuras}/12_heterogeneidad_experimento/`. La lectura de cada uno está en las notas.

| Archivo | Qué comunica | Nota |
| --- | --- | --- |
| Tabla `experimento_ate_lineal_vs_bosque` | El bosque y MCO dan el mismo efecto promedio en las dos escalas (responde "¿cambia el ATE?") | [B_evidencia_hte.md](../05_Notas/12_heterogeneidad_experimento/B_evidencia_hte.md), [X_hte_nivel_vs_log.md](../05_Notas/12_heterogeneidad_experimento/X_hte_nivel_vs_log.md) |
| Tabla `experimento_calibracion_bosque` | Prueba formal: las diferencias entre usuarios son reales (tres especificaciones) | [B_evidencia_hte.md](../05_Notas/12_heterogeneidad_experimento/B_evidencia_hte.md) |
| Tabla `experimento_rate_autoc` y figura `experimento_toc` | Priorizar por el efecto estimado identifica a quienes más responden, en datos que no se usaron para priorizar | [B_evidencia_hte.md](../05_Notas/12_heterogeneidad_experimento/B_evidencia_hte.md) |
| Tabla y figura `experimento_cate_por_grupo` | Qué grupos ganan y cuáles pierden, con su peso en la base histórica | [B_cate_por_grupo.md](../05_Notas/12_heterogeneidad_experimento/B_cate_por_grupo.md) |
| Tabla `experimento_importancia_bosque_causal` | Dónde corta el bosque (no es un efecto) | [B_cate_por_grupo.md](../05_Notas/12_heterogeneidad_experimento/B_cate_por_grupo.md) |
| Tabla `experimento_robustez_sin_tiempo` | Los efectos por grupo no dependen de incluir el tiempo en el sitio | [B_evidencia_hte.md](../05_Notas/12_heterogeneidad_experimento/B_evidencia_hte.md) |
| Figura `experimento_cate_ordenados` | Efecto fuera de bolsa por usuario con su intervalo; en dólares, con cola derecha larga | [X_hte_nivel_vs_log.md](../05_Notas/12_heterogeneidad_experimento/X_hte_nivel_vs_log.md) |

El contraste con las notas previas es consistente. El ATE del bosque cae dentro de los intervalos de MCO de 06 y 08, y el patrón por dispositivo y sistema operativo confirma la exploración de la nota del 08. No hay contradicciones pendientes.

## Pendientes
- **P3.1:** representatividad del experimento frente a la base histórica (sin hacer).
- **Focalización:** "dar el registro facilitado solo en computador y tableta" es una implicación por evaluar. No se estimó el ingreso de esa regla frente a darlo a todos.
- **Síntesis y recomendación (H5):** incorporar la heterogeneidad a la recomendación sí/no.
- **Advertencias de R:** la corrida completa dejó 14 advertencias que no se revisaron. No se sabe de qué script vienen.
- **Reproducibilidad:** con los hilos fijos, las cifras se mueven desde el sexto decimal entre corridas (aparece en los `.csv`, no en las tablas).
- **`CHROME_PATH` en el contenedor Linux:** `/opt/pw-browsers/chromium-1243/chrome-linux64/chrome` (con `LC_ALL=C.UTF-8`).
