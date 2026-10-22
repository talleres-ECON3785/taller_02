# CLAUDE.md: reglas del proyecto

## Contexto del proyecto

Taller 2 de Ciencia de Datos y Econometría Aplicada (ECON-3785, 2026-2, Universidad
de los Andes). Cliente ficticio: CheMarket Inc., empresa de comercio electrónico.
Es la continuación del Taller 1 (repositorio `taller1/`, carpeta hermana de este
proyecto).

- **Pregunta del taller:** ¿cambian las conclusiones del Taller 1 cuando se usan
  métodos más flexibles (basados en árboles), capaces de representar relaciones
  no lineales, interacciones y diferencias entre grupos de usuarios? La mesa
  directiva quiere saber qué cambia, qué se mantiene y qué nuevas implicaciones
  surgen para CheMarket.
- **Pregunta de negocio de fondo (heredada):** ¿debería CheMarket invertir en
  impulsar el registro (`sign_up`) de sus usuarios para aumentar sus ingresos
  (`Revenue`)?
- **Dos fuentes de datos**, las mismas del Taller 1, con roles distintos y no
  intercambiables:
  - `observacional.Rds`: datos históricos del comportamiento de los usuarios. Permite
    describir/predecir, pero no identifica el efecto causal de aumentar el registro.
  - `experimento.Rds`: prueba A/B con asignación aleatoria a `easier_signup`
    (registro facilitado). Permite estimar el efecto causal de esa intervención.
- Hay que ser explícitos, como en el Taller 1, sobre qué conclusiones se pueden
  extraer de cada base y cuáles no.
- **El Taller 2 no es una colección de modelos nuevos.** Su objetivo es evaluar
  qué cambia en las conclusiones del Taller 1 al modificar **dos cosas a la vez**:
  la forma funcional de la variable dependiente (`ln(Revenue)` en lugar de
  `Revenue`) y el método (árboles en lugar de regresión lineal). Siempre hay que
  distinguir si una diferencia viene de la transformación, del método, o de ambos.
- **Entregable final:** una presentación al cliente en `08_Entregables/`, sin
  código, estilo *answer-first* (ver sección "Entregable: presentación al
  cliente"), más el video si el curso lo pide (confirmar con el enunciado de la
  entrega).

### Parte A: predicción (base observacional)

Variable dependiente: `ln(Revenue)`. Preguntas que la presentación debe poder responder:

- ¿Qué variables resultan más útiles para predecir `ln(Revenue)`?
- ¿Qué relaciones o patrones aparecen con los métodos basados en árboles?
- ¿Cómo se compara su desempeño predictivo con el de los modelos lineales?
- ¿Qué cambia en el análisis al usar `ln(Revenue)` en lugar de `Revenue`?
- ¿Qué conclusiones del Taller 1 se mantienen y cuáles cambian?

### Parte B: heterogeneidad del efecto (experimento)

Variable dependiente: `ln(Revenue)`; tratamiento: `easier_signup`. Métodos causales
basados en árboles. Además del ATE, se analizan los CATE y la evidencia de HTE.
Preguntas:

- ¿Cambia el ATE y su interpretación si se usa `ln(Revenue)` en lugar de `Revenue`?
- ¿Existe evidencia de heterogeneidad en los efectos del tratamiento (HTE)?
- ¿Cómo varían los CATE entre usuarios con distintas características?
- ¿Qué características permiten identificar grupos con efectos diferentes?
- ¿Hay grupos con efecto sustancialmente mayor, menor o cercano a cero?
- ¿Cómo se relaciona la heterogeneidad con el efecto promedio del Taller 1?
- ¿Qué implicaciones tiene esto para la decisión de CheMarket?

### Estructura sugerida del análisis (del enunciado)

1. Recordar el punto de partida (qué se aprendió en el Taller 1).
2. Evaluar qué cambia con la forma funcional (`ln(Revenue)` vs. `Revenue`).
3. Evaluar qué agregan los métodos basados en árboles (no linealidades,
   interacciones, heterogeneidad).
4. Contrastar la evidencia: qué se mantiene, qué se matiza y qué cambia, y si la
   diferencia se asocia a la transformación, al método o a ambos.
5. Integrar los hallazgos: implicaciones para CheMarket, separando conclusiones
   bien respaldadas de resultados que aún requieren evidencia.

## Estructura del proyecto

- `01_Datos/01_Crudos/`      datos originales. NUNCA se modifican
- `01_Datos/02_Procesados/`  datos limpios o transformados
- `01_Datos/03_Listos/`      bases finales que ingresan al análisis
- `02_Scripts/`              scripts de R
- `03_Resultados/`           Tablas/ y Figuras/ generadas
- `04_Presentaciones/`       borradores de la presentación
- `05_Notas/`                notas e ideas preliminares
- `06_Bitacoras/`            documentación de cada sesión de trabajo
- `07_Recursos/`             referencias externas y documentación (aquí está el
  enunciado, `Problem_Set_2.pdf`)
- `08_Entregables/`          presentación final y video
- `09_Conversaciones/`       registro crudo (`.jsonl`) de las conversaciones con los agentes; en `.gitignore`, no se versiona
- `.claude/skills/`          skills del proyecto (`registrar-sesion`)
- `taller_02.Rproj`          proyecto de RStudio (raíz del proyecto)

## Reglas de trabajo

- Lenguaje principal: R. Utilice `tidyverse` cuando resulte apropiado.
- Explique lo que va a hacer ANTES de editar o crear archivos.
- Utilice rutas relativas ancladas a la carpeta del proyecto.
- Redacte los comentarios del código en español.
- **Semilla:** `set.seed(2026)` en cualquier análisis con componente aleatorio
  (partición muestral, validación cruzada, bosques aleatorios, bosques causales,
  submuestreo, etc.). Es requisito explícito del enunciado.
- **Evaluación fuera de muestra:** el desempeño predictivo se evalúa siempre
  fuera de muestra (train/test o validación cruzada), nunca dentro de muestra.
  La selección de hiperparámetros (profundidad, poda, número de árboles, etc.)
  se hace solo con datos de entrenamiento; el conjunto de prueba se toca una
  vez, al final.
- **Comparabilidad con el Taller 1:** para que la comparación sea limpia, la
  partición train/test, la métrica y la referencia ingenua deben ser definidas
  de forma explícita y, cuando se compare con el Taller 1, equivalentes a las de
  allá (80/20, semilla 2026, RMSE). Si algo se cambia, se registra en
  "Decisiones tomadas".
- Al cerrar una sesión, registre la sesión con la skill `registrar-sesion` (ver
  "Registro de sesión de trabajo").

### Registro de sesión de trabajo

- Cada sesión de trabajo debe quedar documentada en un archivo `.md` en
  `06_Bitacoras/` y sus cambios versionarse en el repositorio de GitHub asociado.
  Nombre: `YYYY-MM-DD_slug-descriptivo.md`.
- Estructura de cada bitácora:
  - **Resumen:** objetivo y desarrollo de la sesión, al inicio.
  - **Archivos:** lista de archivos creados, modificados y eliminados.
  - **Detalle por archivo:** explicación de los cambios en cada archivo
    involucrado, con las decisiones de implementación, los supuestos usados y la
    intuición en lenguaje natural de cada decisión.
  - Para las variables que construyen los estimadores (p. ej. el criterio de
    partición, los pesos o la estimación del efecto en una hoja), explicar cada
    una por aparte y a detalle: citar la página o sección del recurso de donde
    se obtiene (`07_Recursos/`), cómo se calcula y qué rol cumple dentro de la
    fórmula que compone.
  - **Resultados nuevos (tablas, figuras, gráficos):** para cada uno, qué busca
    comunicar, cómo se generan los datos que lo alimentan y qué rol cumple
    dentro del taller. Se omite si la sesión no generó resultados.
  - **Pendientes:** lo que quedó sin hacer, los supuestos sin confirmar y el
    siguiente paso.
- Las bitácoras son el insumo de las sesiones posteriores: deben permitir
  entender qué ya se hizo y qué quedó pendiente, para mantener un desarrollo
  coherente del taller. Léalas al empezar una sesión.
- Las decisiones metodológicas relevantes también se registran en las tablas
  "Decisiones tomadas" / "Análisis descartados" de este archivo, y se actualiza
  "Estado actual".

### Skill de Claude Code: `registrar-sesion`

Definida en `.claude/skills/registrar-sesion/SKILL.md`. Se invoca al terminar
una sesión (pidiendo "cerrar sesión", "registrar la sesión", "escribir la
bitácora" o "guardar la conversación") y hace dos cosas, en orden:

1. Escribe la bitácora de la sesión en `06_Bitacoras/` con la estructura de
   arriba.
2. Copia el registro crudo (`.jsonl`) de la conversación a
   `09_Conversaciones/`. Esa carpeta está en `.gitignore`: las conversaciones
   se guardan localmente y **no se suben a GitHub**.

Si algo no es inferible con certeza (p. ej. quién del equipo trabajó en la
sesión), la skill pregunta al usuario en vez de adivinar.

## Regla metodológica: regresión lineal como referencia, árboles como extensión

- A diferencia del Taller 1, **este taller sí exige métodos basados en árboles**:
  árboles de regresión y/o ensambles (p. ej. bosques aleatorios, boosting) para
  la Parte A, y métodos causales basados en árboles (árboles causales, bosques
  causales) para la Parte B.
- La regresión lineal del Taller 1 se mantiene como **modelo de referencia**
  (benchmark) en ambas partes: toda mejora predictiva o hallazgo de
  heterogeneidad se reporta contra ella.
- No proponga ni ajuste familias de modelos ajenas al enfoque del enunciado
  (redes neuronales, SVM, matching, etc.) sin autorización del equipo. Dentro de
  los métodos basados en árboles, la elección concreta de algoritmos y paquetes
  queda por definir y debe registrarse en "Decisiones tomadas" con su
  justificación.
- Distinga siempre tres cosas al reportar un resultado: el **estimando** (lo que
  se quiere conocer: p. ej. el ATE o el CATE(x) sobre `ln(Revenue)`), el
  **estimador** (la regresión lineal, el árbol, el bosque causal) y la
  **estimación** (el número obtenido).
- **Predicción no es causalidad.** En la base observacional los árboles solo
  predicen y describen patrones; la importancia de variables y las particiones
  no son efectos causales. Solo el experimento sostiene afirmaciones causales, y
  los CATE son estimaciones de efectos causales condicionales, no descripciones.
- **Importancia de variables:** no es un efecto ni una medida de relevancia
  causal; solo indica cuánto usa el modelo cada variable para predecir.
- **Heterogeneidad (Parte B):** que un método encuentre grupos no prueba que
  haya HTE. Antes de afirmar heterogeneidad hay que evaluarla con evidencia
  formal (p. ej. muestras separadas para construir y para estimar los efectos,
  o pruebas de calibración), y declarar la incertidumbre de cada CATE
  (intervalos). Cuidado con el sobreajuste y con la multiplicidad de
  comparaciones entre subgrupos.
- **`ln(Revenue)` vs. `Revenue`:** los coeficientes y efectos en logaritmo se
  leen como cambios porcentuales aproximados, no en dólares. Al comparar con el
  Taller 1, aclare siempre en qué escala está cada número, y no compare RMSE de
  modelos con distinta variable dependiente como si fueran comparables
  directamente (el RMSE en `ln(Revenue)` y en `Revenue` tienen unidades
  distintas).

## Datos

- El flujo es Crudos, Procesados, Listos. Nunca en sentido inverso.
- Reporte siempre cuántas observaciones se pierden al limpiar o filtrar.
- Son las mismas bases del Taller 1. Ahí los archivos crudos se llaman
  `datos_historicos.Rds` (100,000 obs.) y `datos_experimento.Rds` (10,000 obs.),
  no `observacional.Rds`/`experimento.Rds` como dice el enunciado.
  **Pendiente:** copiarlos a `01_Datos/01_Crudos/` y confirmar los nombres.
- `ln(Revenue)` requiere `Revenue > 0`; verificar y documentar qué pasa con
  valores cero o negativos (el Taller 1 construyó `log_revenue`; revisar allí la
  convención usada y mantenerla).

## Formato de las gráficas

Se mantiene el formato del Taller 1 para que las figuras de ambos talleres se
vean como una sola familia. El formato debe vivir en un único lugar,
`02_Scripts/00_formato_graficas.R` (**pendiente: copiarlo desde el Taller 1**);
ese script no genera figuras, solo define paleta, tema y exportación.

- **Regla:** cualquier script que produzca figuras debe empezar con
  `source("02_Scripts/00_formato_graficas.R")` y usar lo que ahí se define.
  No redefina colores, temas ni tamaños dentro de un script de análisis: si
  algo del formato debe cambiar, cámbielo en `00_formato_graficas.R` para que
  el cambio aplique a todas las figuras a la vez.
- **Paleta:** `paleta_categorica`, terna sobria de azul (`#2B5FA3`), ocre
  (`#B8863B`) y verde-azulado (`#0E8A6C`), distinguibles entre sí incluso con
  daltonismo. Los grises (`gris_texto`, `gris_secundario`, `gris_nota`,
  `gris_grilla`) son estructura, no categorías. Una misma categoría conserva su
  color entre bases y entre talleres (p. ej. "No registrado" azul y "Registrado"
  ocre).
- **Tema:** `tema_presentacion` (más `tema_paneles` si la gráfica usa facetas).
- **Título:** describe qué muestra la figura, en español y sin tecnicismos del
  código (no se nombran variables como `Revenue` o `sign_up`). La regla de
  "el título comunica la conclusión" aplica a los títulos de las diapositivas,
  no a los de las figuras.
- **Subtítulo:** declara siempre de qué base viene la figura, usando
  `subtitulo_experimento` o `subtitulo_observacional`. Las dos bases no permiten
  afirmar lo mismo, y quien vea la figura suelta debe poder saber si está
  viendo un efecto causal o una asociación/predicción descriptiva.
- **Nota al pie (`caption`):** reporta el `n` de cada grupo y, cuando hay una
  línea de referencia punteada, qué marca. En figuras de CATE o de predicción,
  indique también si los resultados son de entrenamiento o de prueba.
- **Convenciones:** ejes en español y con unidades explícitas. Se prefieren
  paneles (`facet_wrap`) sobre leyendas. Distribuciones como densidad continua
  (`geom_density`, `alpha = 0.55`, `linewidth = 0.8`), nunca histograma, con la
  mediana de cada grupo en línea punteada gris; `Revenue` y `time_spent` van en
  escala logarítmica en el eje x.
- **Nombres de archivo:** `03_Resultados/Figuras/<base>_<contenido>.png`, donde
  `<base>` es `experimento` u `observacional`. Para distinguir partes del
  taller puede agregarse el contenido (p. ej. `observacional_importancia_variables.png`,
  `experimento_cate_por_grupo.png`).
- **Exportación:** siempre con `guardar_figura()` (8×6 pulgadas, 300 dpi, fondo
  blanco explícito).
- Las figuras de árboles (diagramas de particiones) y de importancia de
  variables siguen las mismas reglas de paleta, tema y exportación.

## Primero el diseño, después los resultados

- No emita juicios sobre si un resultado es "bueno" o "malo".
- No exprese entusiasmo por una métrica, un coeficiente ni por su significancia.
- Mientras el diseño no esté resuelto, lo único relevante es si la especificación es correcta.
- Un mejor desempeño predictivo fuera de muestra no implica que el modelo sea
  "mejor" para la decisión de negocio; reporte la magnitud y la incertidumbre.

## Integrantes

| Nombre                    | Rol / responsabilidad                    | Contacto                                                         |
| ------------------------- | ---------------------------------------- | ---------------------------------------------------------------- |
| Samuel Escandón          | Por definir                              | [s.escandoc@uniandes.edu.co](mailto:s.escandoc@uniandes.edu.co)   |
| Douglas Plazas Guzmán    | analisis historico                              | [d.plazasg@uniandes.edu.co](mailto:d.plazasg@uniandes.edu.co)     |
| Mateo Olmos Becerra       | Por definir                              | [m.olmosb@uniandes.edu.co](mailto:m.olmosb@uniandes.edu.co)       |
| Santiago Martínez López | Por definir                              | [s.martinezl@uniandes.edu.co](mailto:s.martinezl@uniandes.edu.co) |
| Santiago Muñoz Martínez | Por definir                              | [s.munozm234@uniandes.edu.co](mailto:s.munozm234@uniandes.edu.co) |

<!-- Roles del Taller 2 sin asignar todavía; en el Taller 1 estaban divididos
     entre datos históricos y experimento A/B. -->

## Decisiones tomadas

<!-- Registro acumulado de decisiones metodológicas y su justificación, para no
     perder de vista por qué se hizo algo varias semanas después. -->

| Fecha      | Decisión                                                                                                                                      | Justificación                                                                                                                                                                  |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| (heredada) | `time_spent` está en minutos, en las dos bases.                                                                                                | Confirmado en el Taller 1.                                                                                                                                                     |
| (heredada) | El estimando central del experimento es el efecto de `easier_signup` sobre el ingreso (ITT); `sign_up` es un mecanismo, no la palanca.         | `easier_signup` es lo que CheMarket puede manipular. En el Taller 1, `sign_up` y `easier_signup` coinciden perfectamente en el experimento (primer estadio = 1, LATE = ITT).      |
| 2026-10-21 | Variable dependiente de las Partes A y B: `ln(Revenue)`; `Revenue` en nivel se conserva solo para la comparación con el Taller 1.              | Lo exige el enunciado; permite separar el efecto de la transformación del efecto del método.                                                                                  |

## Análisis descartados

<!-- Especificaciones, variables o enfoques que se probaron y abandonaron, con
     la razón, para no repetir procedimientos ya infructuosos. -->

| Fecha      | Análisis/especificación descartada                                                    | Razón                                                                                                                                              |
| ---------- | -------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| (heredado) | IV/LATE con `easier_signup` como instrumento de `sign_up` (Taller 1)                   | Primer estadio exactamente 1 por correspondencia perfecta; LATE = ITT. No se retoma salvo que cambie la estructura de los datos.                  |
| (heredado) | Hipótesis de que `time_spent` sesgaba el ITT como mediador/mal control (Taller 1)      | `easier_signup` no afecta significativamente a `time_spent`.                                                                                       |

## Definición de variables

<!-- Definición operativa de cada variable usada en el análisis: qué incluye,
     unidades, moneda, período y fuente. -->

Heredadas del Taller 1.

| Variable              | Definición                                                                                                                                         | Fuente                                                   |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `Revenue`           | Gasto del usuario en la sesión.                                                                                                                     | `observacional.Rds`, `experimento.Rds`               |
| `ln(Revenue)`       | Logaritmo natural de `Revenue`; variable dependiente del Taller 2 (en el Taller 1 se llamó `log_revenue`).                                         | Construida                                               |
| `sign_up`           | Si el usuario se registró (binaria).                                                                                                                | `observacional.Rds`, `experimento.Rds`               |
| `time_spent`        | Tiempo en el sitio en la sesión, en minutos.                                                                                                        | `observacional.Rds`, `experimento.Rds`               |
| `past_sessions`     | Número de sesiones anteriores.                                                                                                                      | `observacional.Rds`, `experimento.Rds`               |
| `device_type`       | Dispositivo usado: `mobile`, `desktop` o `tablet`.                                                                                                  | `observacional.Rds`, `experimento.Rds`               |
| `is_returning_user` | Si el usuario ya había visitado antes (binaria).                                                                                                    | `observacional.Rds`, `experimento.Rds`               |
| `os_type`           | Sistema operativo: `osx`, `windows` u `other` (hallada al explorar los datos en el Taller 1).                                                      | `observacional.Rds`, `experimento.Rds`               |
| `easier_signup`     | Asignación al tratamiento del experimento (registro facilitado, binaria).                                                                           | `experimento.Rds` (no existe en `observacional.Rds`) |

**Nota sobre covariables de heterogeneidad (Parte B):** las características
sobre las que se puede explorar HTE son las covariables pre-tratamiento
(`time_spent`, `past_sessions`, `device_type`, `is_returning_user`, `os_type`).
Antes de usar `time_spent` como moderador, recordar que en el Taller 1 se
documentó que se mide en la misma sesión y que su relación con `Revenue` es
correlacional (posible causalidad inversa); decidir y registrar si se trata
como covariable pre-tratamiento.

## Restricciones de muestra

<!-- Criterios de exclusión aplicados y el N resultante en cada paso, para que
     el N reportado sea verificable. -->

| Criterio de exclusión | N antes | N después |
| ---------------------- | ------- | ---------- |
| (sin análisis todavía) | —       | —          |

Punto de partida (Taller 1): observacional 100,000 obs. y experimento 10,000
obs., sin pérdidas por NA.

## Entregable: presentación al cliente

<!-- Lineamientos del enunciado para la presentación final, estilo "McKinsey way". -->

- Estilo *answer-first*: empezar por la conclusión; no organizar la
  presentación como una secuencia de métodos.
- Cada sección responde una pregunta natural del cliente: ¿qué aprendimos?,
  ¿qué cambia respecto al Taller 1?, ¿por qué importa?, ¿qué debería hacer la
  empresa?
- Principio de la pirámide: mensaje principal arriba, argumentos y evidencia
  debajo.
- Una idea por slide: el título comunica la conclusión, no el método. Evitar
  títulos como "Random Forest", "Árbol causal" o "Resultados".
- MECE: cubrir lo importante sin repetir el mismo argumento.
- Enfocarse en el "so what?": incluir una cifra, figura, árbol o medida de
  desempeño solo si sostiene una conclusión o decisión.
- **Comparar explícitamente con el Taller 1:** dejar claro qué se aprende ahora
  que no era visible antes.
- **Ser claros sobre la incertidumbre:** distinguir entre mejoras predictivas,
  patrones descriptivos y evidencia sobre heterogeneidad causal.
- Cerrar con decisiones y próximos pasos: qué decisiones están respaldadas por
  la evidencia y qué preguntas requieren análisis o evidencia adicional.
- Ser explícitos sobre qué recomendación sostiene la evidencia histórica y qué
  agrega el experimento.
- **No incluir código en la presentación.**

## Estado actual

<!-- Punto de avance del proyecto al cierre de la última sesión: qué está
     hecho, qué sigue, dónde se quedó el trabajo. -->

**Última actualización: 2026-10-21 (rama `main`).**

### Hecho

- Estructura de carpetas creada (igual a la del Taller 1), con `.gitkeep` en las
  carpetas vacías, `taller_02.Rproj`, `.gitignore` y el enunciado en
  `07_Recursos/Problem_Set_2.pdf`.
- Datos crudos en `01_Datos/01_Crudos/` (`datos_historicos.Rds`,
  `datos_experimento.Rds`); bases listas regeneradas en `01_Datos/03_Listos/` con
  `02_Scripts/01_limpieza_observacional.R` y `02_limpieza_experimento.R` (0 obs.
  perdidas). `02_Scripts/00_formato_graficas.R` copiado del Taller 1.
- Skill `registrar-sesion` (traída del Laboratorio 9) en `.claude/skills/` y
  carpeta `09_Conversaciones/` para los `.jsonl`, ignorada por git.

### Pendiente

- Verificar `Revenue > 0` en la base observacional y construir `ln(Revenue)`
  (convención del Taller 1: `log_revenue`).
- Crear `README.md` y `00_main.R` (script maestro) cuando haya scripts.
- Definir roles del equipo y registrar en "Decisiones tomadas" los algoritmos y
  paquetes de árboles a usar.
- Parte A (predicción con árboles) y Parte B (HTE con árboles causales).

### Punto de partida: resultados del Taller 1

Referencia para las comparaciones; ver el repositorio `taller1/` para el detalle.

- **Experimento, ITT sobre `log_revenue`:** 0.0134 sin controles y 0.0042 con
  controles; ninguno distinguible de cero.
- **Experimento, ITT sobre `Revenue` en nivel:** 0.49 (p = 1.8e-11); medias 3.98
  vs. 4.47, pero medianas casi idénticas (3.15 vs. 3.14): la diferencia se
  concentra en la cola alta (p99: 14.4 vs. 24.9). **Esto sugiere que el
  efecto promedio en nivel lo jalan pocos usuarios y es una pista natural para
  la Parte B** (heterogeneidad / `ln(Revenue)` vs. `Revenue`).
- **Quiebre en `time_spent` = 5 minutos** en la relación con `Revenue`
  (salto de nivel ≈3.13 obs. / ≈3.42 exp.), confirmado fuera de muestra en
  ambas bases. Correlacional, no causal. Un árbol debería poder recuperar o
  matizar esta no linealidad.
- **Asociación `sign_up`–`log(Revenue)` observacional** (no causal): 0.102 sin
  controles, 0.080 con controles, 0.047 con `log(time_spent)`.
- **Elasticidad `Revenue`–`time_spent`:** ≈0.169.
- **Modelo predictivo lineal de `Revenue`** (fuera de muestra, 80,000/20,000):
  RMSE 2.314 vs. 2.716 de la referencia ingenua (mejora 14.8%). Es el
  benchmark de la Parte A; ojo con la escala (nivel vs. logaritmo).
- **Representatividad:** la muestra del experimento no se distingue de la
  población histórica en las características observables compartidas (F = 0.65,
  p = 0.712), lo que apoya la validez externa del ITT.

## Reglas estrictas

<!-- Acciones que requieren autorización previa del equipo antes de ejecutarse. -->

- No modificar ni sobrescribir archivos en `01_Datos/01_Crudos/`.
- No eliminar ni mover archivos fuera de la estructura del proyecto sin autorización.
- No usar familias de modelos fuera de los métodos basados en árboles y la
  regresión lineal de referencia sin autorización del equipo (ver "Regla
  metodológica").
- No evaluar desempeño predictivo dentro de muestra ni omitir `set.seed(2026)`.
- No incluir código en la presentación final.
