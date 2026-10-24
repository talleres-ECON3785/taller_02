# Taller 2: CheMarket Inc.

Ciencia de Datos y Econometría Aplicada (ECON-3785, 2026-2), Universidad de los
Andes. Continuación del Taller 1 (repositorio `taller1/`).

## Objetivo

CheMarket Inc., empresa de comercio electrónico, quiere saber si debería invertir
en impulsar el registro (`sign_up`) de sus usuarios para aumentar sus ingresos
(`Revenue`). El Taller 1 respondió con regresión lineal. Este taller pregunta:

> ¿Cambian las conclusiones del Taller 1 cuando se usan métodos más flexibles
> (basados en árboles), capaces de representar relaciones no lineales,
> interacciones y diferencias entre grupos de usuarios?

Se modifican **dos cosas a la vez**: la variable dependiente (`ln(Revenue)` en
lugar de `Revenue`) y el método (árboles en lugar de regresión lineal). Por eso el
análisis usa un diseño 2×2 (forma funcional × método), que permite atribuir cada
diferencia con el Taller 1 a la transformación, al método o a ambos.

- **Parte A, predicción (base observacional):** qué variables predicen mejor
  `ln(Revenue)`, qué patrones aparecen con árboles y bosques, y cómo se compara su
  desempeño fuera de muestra con el de los modelos lineales.
- **Parte B, heterogeneidad (experimento):** ATE de `easier_signup` sobre
  `ln(Revenue)`, evidencia formal de HTE y CATE por grupo con bosque causal.

Las dos bases tienen roles distintos y no intercambiables:

| Base | Archivo crudo | Obs. | Qué permite |
| --- | --- | --- | --- |
| Observacional | `datos_historicos.Rds` | 100,000 | Describir y predecir. No identifica el efecto causal de aumentar el registro. |
| Experimento (A/B) | `datos_experimento.Rds` | 10,000 | Estimar el efecto causal de `easier_signup` (registro facilitado), por asignación aleatoria. |

## Cómo ejecutar

Basta con correr `00_main.R`. No hay que instalar nada a mano.

1. Abrir `taller_02.Rproj` en RStudio (fija el directorio de trabajo en la raíz).
2. Ejecutar `00_main.R` completo, por ejemplo con `source("00_main.R")`.

`00_main.R` verifica que el directorio de trabajo es la raíz, instala y carga con
`pacman` todos los paquetes del proyecto, crea las carpetas de salida que falten y
ejecuta los scripts de `02_Scripts/` en el orden de su numeración. Borrar
`03_Resultados/` y volver a correr `00_main.R` regenera todo.

Notas:

- Los scripts de `02_Scripts/` no cargan paquetes ni crean carpetas. Para correr
  uno suelto, primero se ejecutan las secciones 1 a 3 de `00_main.R`.
- Cualquier análisis con componente aleatorio usa `set.seed(2026)`.
- Las tablas `.png` se generan con `gt` y Chrome/Chromium en modo headless. Si
  Chrome no está en la ruta habitual, definir la variable de entorno `CHROME_PATH`.
- Los datos crudos de `01_Datos/01_Crudos/` nunca se modifican.

## Estructura de carpetas

```
taller_02/
├── 00_main.R               script maestro: corre todo el pipeline
├── README.md               este archivo
├── PLAN.md                 plan de implementación (hitos H0–H7, tareas Pk.n)
├── HANDOFF.md              estado actual, siguientes objetivos y registro de sesiones
├── CLAUDE.md               reglas del proyecto
├── taller_02.Rproj         proyecto de RStudio
├── 01_Datos/
│   ├── 01_Crudos/          datos originales (no se modifican)
│   ├── 02_Procesados/      datos limpios o transformados
│   └── 03_Listos/          bases finales que ingresan al análisis
├── 02_Scripts/             scripts de R
├── 03_Resultados/
│   ├── Tablas/             tablas exportadas (.png de la diapositiva y .csv sin formato), en una subcarpeta por script
│   └── Figuras/            figuras exportadas (.png, 9×6 pulgadas, 300 dpi), en una subcarpeta por script
├── 04_Presentaciones/      borradores de la presentación
├── 05_Notas/               una nota por hallazgo principal (índice en su README)
├── 06_Bitacoras/           documentación de cada sesión de trabajo
├── 07_Recursos/            enunciado, retroalimentación del Taller 1, heurísticas
│                           y catálogo de métodos
├── 08_Entregables/         presentación final (slides y enlace al video)
└── 09_Conversaciones/      registros crudos de las conversaciones (no se versiona)
```

## Métodos

El trabajo se limita al catálogo `07_Recursos/catalogo_metodos.md`: regresión
lineal (`lm`, `sandwich`, `fixest`, validación cruzada con `caret`), LASSO
(`glmnet`), árboles de regresión (`rpart`, `rpart.plot`), bagging y bosques
aleatorios (`ranger`) y bosques causales (`grf`). La regresión lineal del Taller 1
se mantiene como modelo de referencia en las dos partes.

Para que la comparación con el Taller 1 sea limpia, la partición es 80/20 con
semilla 2026 y la métrica es el RMSE fuera de muestra. El RMSE en `Revenue` y en
`ln(Revenue)` tienen unidades distintas y no se comparan directamente.

## Mapa script → resultados

Cada tabla o figura de la presentación se rastrea al script que la genera.
Convención de nombres: `03_Resultados/{Tablas,Figuras}/<script>/<base>_<contenido>.<ext>`,
con `<script>` = nombre del script que lo genera (sin `.R`) y `<base>` =
`observacional` o `experimento`. Cada script que genera resultados tiene su
subcarpeta, creada por `00_main.R`.

### Scripts existentes

| Script | Qué hace | Entradas | Salidas |
| --- | --- | --- | --- |
| `00_formato_graficas.R` | Define paleta, tema y `guardar_figura()`. No genera figuras ni va en `00_main.R`; lo cargan con `source()` los scripts que grafican. | — | — |
| `00_formato_tablas.R` | Define estilo de tablas y `guardar_tabla()`. No genera tablas ni va en `00_main.R`; lo cargan con `source()` los scripts que exportan tablas. | — | — |
| `01_limpieza_observacional.R` | Limpia la base observacional y construye `log_revenue` (se detiene si algún `Revenue <= 0`). | `01_Datos/01_Crudos/datos_historicos.Rds` | `01_Datos/03_Listos/observacional_limpio.Rds`; `03_Resultados/Tablas/01_limpieza_observacional/reporte_calidad_observacional_embudo.csv`; `03_Resultados/Tablas/01_limpieza_observacional/reporte_calidad_observacional.csv` |
| `02_limpieza_experimento.R` | Limpia la base del experimento y construye `log_revenue`. | `01_Datos/01_Crudos/datos_experimento.Rds` | `01_Datos/03_Listos/experimento_listos.RDS` |

### Scripts previstos (por llenar)

Nombres tomados de `PLAN.md`; se agregan a la lista `scripts` de `00_main.R` y a
esta tabla en la misma sesión en que se crean.

| Script | Hito | Resultados esperados |
| --- | --- | --- |
| `03_punto_partida.R` | H1 | `Revenue` en nivel (dólares) frente a cada covariable: `03_Resultados/Figuras/03_punto_partida/`: `observacional_revenue_tiempo_sesion`, `_sesiones_pasadas`, `_dispositivo`, `_sistema_operativo`, `_recurrente` y `_tiempo_por_sesiones` (un solo panel, curvas loess; `.png`); y `03_Resultados/Tablas/03_punto_partida/`: `experimento_ols_registro` (MCO de `Revenue` sobre el tratamiento solo, con verificación de cumplimiento perfecto; `.png` y `.csv`) |
| `04_forma_funcional_observacional.R` | H1 | Las mismas seis figuras con `ln(Revenue)` en `03_Resultados/Figuras/04_forma_funcional_observacional/`: `observacional_lnrevenue_*` (`.png`). Pendiente: densidad de `Revenue` frente a `ln(Revenue)` y tabla con las cifras del Taller 1 |
| `05_prediccion_lineal_observacional.R` | H2 | Escalera de modelos lineales de `Revenue` (dólares) con RMSE de validación cruzada en `train`, aporte de cada variable y evaluación única en `test`: `03_Resultados/Tablas/05_prediccion_lineal_observacional/`: `observacional_escalera_rmse`, `observacional_importancia_variables`, `observacional_rmse_prueba_lineal` (`.png` y `.csv`); y `03_Resultados/Figuras/05_prediccion_lineal_observacional/observacional_escalera_rmse.png` |
| `04_prediccion_lineal_observacional.R` | H2 | Benchmarks lineales (referencia ingenua, lineal, LASSO) |
| `05_arboles_observacional.R` | H2 | CART podado, bosque aleatorio, importancia de variables |
| `06_comparacion_prediccion_observacional.R` | H2 | Tabla 2×2 de RMSE (método × forma funcional) y escalera de RMSE |
| `07_validacion_experimento.R` | H3 | Balance y cumplimiento del experimento |
| `08_ate_experimento.R` | H3 | ATE en nivel y en logaritmo, conciliación nivel–log |
| `09_heterogeneidad_experimento.R` | H4 | Bosque causal: calibración, CATE, ATE por subgrupo |

## Documentación del trabajo

- `PLAN.md`: hitos y tareas con casillas de verificación.
- `HANDOFF.md`: dónde estamos y qué sigue; es el punto de entrada para retomar.
- `06_Bitacoras/`: qué se hizo en cada sesión y por qué.
- `05_Notas/`: qué se encontró, con referencia a tablas y figuras.
- `07_Recursos/heuristicas_retroalimentacion_taller1.md`: heurísticas H1–H11 y
  lista de chequeo derivadas de la retroalimentación del Taller 1.

## Trabajo en equipo

Repositorio: <https://github.com/talleres-ECON3785/taller_02>. Cada integrante
trabaja en su propia rama (nombre + primer apellido + inicial del segundo) y nadie
hace commit directo a `main`.

| Integrante | Rama |
| --- | --- |
| Samuel Escandón | `SamuelEscandonC` |
| Douglas Plazas Guzmán | `DouglasPlazasG` |
| Mateo Olmos Becerra | `MateoOlmosB` |
| Santiago Muñoz Martínez | `SantiagoMunozM` |

Entrega del video, los slides y el material de soporte: domingo 25 de octubre de
2026.
