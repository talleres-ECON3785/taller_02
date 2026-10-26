# Ajustes a la presentación "CheMarket Encargo 2"

Instrucciones para editar la presentación en PowerPoint. La versión revisada tiene
16 diapositivas. Los números de diapositiva de este documento se refieren a **esa
versión** (antes de insertar las nuevas).

## Contexto para quien edita

- Presentación al cliente ficticio CheMarket (comercio electrónico), Taller 2 de
  Ciencia de Datos (Universidad de los Andes). Se graba en video, con un máximo de
  **15 minutos**, y los cuatro integrantes exponen por igual.
- Estilo *answer-first*: el título de cada diapositiva enuncia la conclusión, no
  el método. Una idea por diapositiva. Sin código.
- Hay que conservar el diseño actual: fondo blanco, títulos en serif azul oscuro,
  cifras destacadas en azul claro, línea azul bajo el título y subtítulo gris
  con el formato "Parte X · base · tipo de análisis".
- **Escalas:** "%" quiere decir cambio en el gasto del usuario típico, calculado
  sobre ln(Revenue) como exp(efecto) − 1. "Dólares" quiere decir dólares por
  usuario. Nunca hay que mezclarlas sin etiqueta.
- **No hay que inventar cifras.** Todas las cifras de este documento ya se
  verificaron contra los resultados del repositorio. Si falta una cifra, se deja
  un marcador `[POR CONFIRMAR]` y no se estima.
- La rúbrica tiene cinco criterios: Parte A métodos (30), Parte A recomendaciones
  (15), Parte B métodos (30), Parte B recomendaciones (15) y presentación (10).
  Cada ajuste indica qué criterio cubre.

---

## Prioridad 1: diapositivas que faltan (elementos obligatorios de la rúbrica)

### 1.1 Nueva diapositiva: el bosque causal (insertar entre la 10 y la 11 actuales)

**Cubre:** Parte B métodos, elemento 1 ("se implementa un bosque causal…
explicando la importancia del enfoque honesto y detallando el procedimiento del
entrenamiento, los hiperparámetros escogidos y la selección del modelo final").
Hoy no lo cubre ninguna diapositiva.

- **Título:** "Para medir el efecto por grupo, unos usuarios definen los grupos y
  otros miden el efecto"
- **Subtítulo:** "Parte B · Experimento A/B (n = 10,000) · Bosque causal · Causal"
- **Diseño:** igual al de la diapositiva 7 (tres tarjetas arriba y una franja
  abajo).

**Tarjeta 1: qué hace**
> Un conjunto de árboles que, en lugar de predecir el gasto, buscan grupos de
> usuarios en los que el registro facilitado tiene un efecto distinto. Cada
> usuario recibe un efecto estimado según sus características.

**Tarjeta 2: por qué es honesto**
> Cada árbol divide su muestra en dos: con una mitad decide dónde cortar y con la
> otra mide el efecto en cada grupo. Si los mismos datos eligieran los grupos y
> midieran su efecto, aparecerían diferencias que son ruido. Separarlos evita ese
> sesgo y da intervalos de confianza válidos.

**Tarjeta 3: cómo se entrenó**
> - 2,000 árboles, semilla 2026.
> - 5 características previas al tratamiento: tiempo en el sitio, sesiones
>   anteriores, dispositivo, usuario recurrente y sistema operativo.
> - Probabilidad de tratamiento fijada en la proporción tratada (la asignación
>   fue aleatoria).
> - Muestra honesta 50/50 y demás parámetros por defecto, sin ajuste fino.

**Franja inferior: selección del modelo final**
> Modelo principal: ln(Revenue). Se repite en dólares y sin el tiempo en el sitio
> como prueba de robustez. Los grupos se evalúan en una mitad del experimento que
> no se usó para elegirlos.

### 1.2 Diapositiva 7 actual: agregar los hiperparámetros de la Parte A

**Cubre:** Parte A métodos, elemento 1 ("detallando el procedimiento del
entrenamiento, los hiperparámetros escogidos y la selección del modelo final").
Hoy solo dice "árbol podado y bosque de 1,000 árboles".

- **Título nuevo:** "Un lineal bien especificado compite con los árboles bajo la
  misma validación del encargo 1"
  (el título actual, "Cada modelo responde a un patrón visto en la descriptiva",
  describe el método en vez de dar la conclusión).
- Se conservan las tres tarjetas actuales. En la tarjeta **Árboles (nuevo)**, se
  reemplaza el texto por:
  > Reciben las 6 variables sin corte ni cruce, para ver si los encuentran solos.
  >
  > **Árbol podado:** poda elegida con validación cruzada de 5 pliegues y la regla
  > de 1 error estándar (el árbol más simple cuyo error no se distingue del
  > mínimo): 10 hojas en log.
  >
  > **Bosque:** se probaron entre 1 y 6 variables por corte y tamaños mínimos de
  > hoja de 5, 25 y 100, con el error fuera de bolsa. Quedó con 3 variables por
  > corte y hojas de 100 usuarios, reestimado con 1,000 árboles. Le gana al
  > bagging (las 6 variables en cada corte): 0.350 frente a 0.354 en log.
- En la franja "Validación." se agrega una segunda línea:
  > **Modelo final: el árbol podado.** Empata con el bosque en prueba (1.627
  > frente a 1.626 dólares) y se puede leer y explicar al cliente.
- Si no cabe, se reduce el tamaño de letra de las tarjetas o se convierte la
  tarjeta de árboles en una tabla pequeña (Modelo | Hiperparámetro | Cómo se
  eligió | Valor elegido).

### 1.3 Nueva diapositiva: veredicto predictivo y limitaciones de los árboles (insertar después de la 10 actual)

**Cubre:** Parte A recomendaciones, elementos 1 ("se argumenta si el nuevo modelo
es preferible… o si debería mantenerse la regresión lineal") y 3 ("se discuten
las limitaciones de los métodos basados en árboles"). El elemento 3 no aparece en
ninguna parte de la presentación actual.

- **Título:** "Para predecir el gasto conviene el árbol podado, sabiendo dónde
  falla"
- **Subtítulo:** "Parte A · Datos históricos · Predictivo, no causal"
- **Columna izquierda, "Por qué el árbol":**
  > - Menor error en usuarios que no vio: 1.63 dólares, frente a 2.31 del lineal
  >   del encargo 1 y 1.85 del lineal con corte y cruce.
  > - Encuentra solo el corte de 5 minutos y el cruce con las sesiones: no
  >   depende de que el analista los adivine.
  > - Se puede explicar con 10 grupos de usuarios.
  > - El lineal con corte y cruce queda como referencia: logra el 68% de la
  >   mejora y es más fácil de mantener.
- **Columna derecha, "Limitaciones":**
  > - **Inestable:** con otra muestra, un solo árbol puede cortar distinto. El
  >   bosque, que promedia 1,000 árboles, da el mismo error y respalda el patrón.
  > - **Predice en escalones:** todos los usuarios de una hoja reciben la misma
  >   predicción, así que no capta diferencias finas dentro del grupo.
  > - **No extrapola:** fuera del rango observado (por ejemplo, más sesiones que
  >   las vistas) repite el valor de la última hoja.
  > - **Predice, no explica causas:** que el árbol use una variable no significa
  >   que cambiarla cambie el gasto. La importancia de variables mide uso
  >   predictivo, no efecto.
  > - **El bosque es una caja negra:** predice igual pero no se puede leer.

### 1.4 Nueva diapositiva: qué está respaldado y qué es exploratorio (insertar después de la 13 actual)

**Cubre:** Parte B recomendaciones, elementos 2 ("se argumenta si los patrones de
consumo son plausibles desde el punto de vista de la empresa") y 4 ("se argumenta
si los resultados son robustos o si deberían considerarse como hallazgos
exploratorios"). Hoy la diapositiva 15 solo los toca de forma parcial.

- **Título:** "Que el efecto cambia entre grupos está respaldado; el detalle por
  usuario es exploratorio"
- **Subtítulo:** "Parte B · Experimento A/B (n = 10,000) · Robustez · Causal"
- **Diseño:** dos columnas tipo tabla, con encabezado en azul de la paleta.

**Respaldado**
> - **Hay heterogeneidad:** prueba de calibración 1.01 (error estándar 0.031) y
>   AUTOC de 0.20 [0.18; 0.22] en la muestra dividida.
> - **Se sostiene sin el tiempo en el sitio** (por si se midió en la misma sesión
>   que el gasto): calibración 0.97 (error estándar 0.050).
> - **El mismo orden en las dos escalas:** los grupos que ganan y los que pierden
>   coinciden en % y en dólares (calibración en dólares: 1.06, error estándar
>   0.068).
> - **La regla vale más que dárselo a todos** en la mitad del experimento que no
>   la eligió: +0.235 dólares por usuario [0.192; 0.279].
> - El experimento está balanceado y se parece a la base histórica.

**Exploratorio**
> - El efecto estimado de cada usuario por separado.
> - Los efectos por número de sesiones.
> - Grupos cuyo intervalo toca el cero: computador con otro sistema y tableta con
>   Windows (en %).
> - Tableta con otro sistema: solo 84 usuarios.
> - No se ajustaron los p-valores por comparaciones múltiples. En su lugar, la
>   regla se validó en la otra mitad del experimento.

**Franja inferior: ¿es plausible para el negocio?**
> Que ganen computador y osx es coherente con quién gasta más: el gasto base es de
> 4.61 dólares en computador con osx frente a 3.62 en celular con Windows. Por qué
> el registro facilitado **baja** el gasto en celulares sin osx no lo sabemos: los
> datos no miden el mecanismo (fricción del formulario en esos dispositivos,
> abandono, etc.). Por eso es el primer punto por confirmar.

---

## Prioridad 2: cifras que deben corregirse

### 2.1 Diapositiva 12: la descomposición de 0.41 dólares mezcla dos muestras

La barra apilada dice 0.10 + 0.07 + 0.24. El 0.24 y el "como mucho 0.17 por la
transformación" vienen de una submuestra (9,601 usuarios en grupos finos con 100 o
más). El 0.10 y el total de 0.41 vienen de la muestra completa.

**Corrección (todo con la muestra completa, n = 10,000):**

| Segmento | Valor actual | Valor correcto | Texto de la leyenda |
| --- | --- | --- | --- |
| Azul oscuro | 0.10 | **0.10** | Efecto proporcional de cada grupo, con un gasto base común. |
| Azul medio | 0.07 | **0.06** | Los grupos que ganan gastan más (4.16 contra 3.64 dólares). |
| Azul claro | 0.24 | **0.25** | Dentro de cada grupo, el registro sube más el gasto promedio que el del usuario típico. |

- Etiqueta bajo los dos primeros segmentos: "0.17 por el efecto de cada grupo y su
  gasto base" (se mantiene).
- Etiqueta bajo el tercero: "0.25 dentro de cada grupo".
- La frase "como mucho 0.17 por la transformación" se cambia por: "Con grupos más
  finos (dispositivo × sistema × sesiones), como mucho 0.17 de ese resto se debe a
  la transformación." Otra opción es eliminarla.
- Se ajusta el ancho de los segmentos a 0.10 / 0.06 / 0.25 (proporcional a
  24% / 15% / 61%).

### 2.2 Diapositiva 14: la atribución del error de predicción está mal

En la fila "Error de predicción de 2.31 dólares", la columna "Por qué" dice
"Especificación (68%) y método (32%)". LASSO (12% de la mejora) es un modelo
lineal, así que cuenta como especificación y no como método.

**Corrección:** "Especificación (80%: corte y cruce 68%, LASSO 12%) y método
(20%)". Debe ser coherente con la diapositiva 10 ("el lineal con corte y cruce da
68%, LASSO 12% y el árbol 20%").

### 2.3 Diapositivas 2 y 13: precisar que la regla recomendada difiere un poco de la elegida en entrenamiento

La regla elegida en la mitad de entrenamiento excluía también a las tabletas con
otro sistema (64.1% de la base, 0.653 dólares por usuario). La recomendada las
incluye (65.1%, 0.657). Decir que "se eligió con una mitad y se evaluó con la
otra" sin esa precisión exagera un poco.

- **Diapositiva 13, recuadro oscuro:** se reemplaza por:
  > La regla se eligió con una mitad del experimento y se evaluó con la otra. La
  > elegida en entrenamiento vale 0.653 dólares por usuario; la recomendada agrega
  > 84 usuarios de tableta con otro sistema y vale 0.657. Frente a dárselo a
  > todos, gana 0.235 dólares por usuario [0.192; 0.279].
- **Diapositiva 13, columna "Estimando":** se agrega una nota bajo la tabla:
  "% = cambio en el gasto del usuario típico, promediado sobre toda la base
  (quienes no reciben el registro facilitado cuentan con efecto cero)."
- **Diapositiva 2, columna "Evidencia":** se cambia "el gasto típico sube +10.2%"
  por "el gasto típico de la base sube +10.2%".

### 2.4 Diapositiva 11: "cercano a cero" es impreciso

Computador con otro sistema tiene +7%, con intervalo de −0.3% a +15.6%. No está
cerca de cero; no se distingue de cero. Tableta con Windows sí es positiva en
dólares (0.39 [0.13; 0.65]).

**Texto nuevo del último bloque:**
> No distinguible de cero en %: computador con otro sistema y tableta con Windows
> (10%), ambos positivos en dólares o cerca de serlo. Tableta con otro sistema (84
> usuarios) no permite concluir.

---

## Prioridad 3: claridad y formato

### 3.1 Diapositiva 9: el árbol no se lee

- Se agranda la imagen del árbol todo lo posible: se quita el bloque de texto de
  la izquierda ("Árbol de regresión podado para el logaritmo del ingreso…") o se
  mueve al subtítulo.
- Se corrige la errata "Análisis predictico" por "Análisis predictivo".
- Se agrega un recuadro con dos hojas extremas en dólares (gasto típico =
  exp(log predicho)). Responde a la rúbrica, Parte A recomendaciones, elemento 2
  (subgrupos con distintos niveles de gasto):
  > **Gasto típico de los grupos extremos**
  > - 5 minutos o menos, desde celular (32% de los usuarios): **2.46 dólares**
  > - Más de 5 minutos, 4 o más sesiones, osx (4%): **10.75 dólares**
  >
  > Una diferencia de más de cuatro veces entre segmentos.
- Si la imagen sigue borrosa al ampliarla, se deja un comentario: "Reemplazar por
  la exportación en alta resolución de
  `03_Resultados/Figuras/09_arboles_observacional/`". No se intenta mejorarla con
  herramientas de imagen.

### 3.2 Diapositivas 8, 11 y 12: pies de página con rutas de archivo

Se eliminan las líneas "Fuente: 03_Resultados/… | Script XX | …". Son rutas del
repositorio y distraen al cliente. Se conserva solo lo que informa al lector:
- Diapositiva 8: "El aporte de cada variable depende del orden en que se agrega."
- Diapositiva 11: "Barras: intervalo de confianza del 95%."
- Diapositiva 12: nada.

### 3.3 Diapositiva 3: reformular la autocrítica

"No escalar todavía, sin precisar qué evidencia faltaba." se cambia por:
> No escalar todavía y esperar más evidencia.

### 3.4 Diapositiva 14: dos filas y el contraste

- Fila 6, columna "Encargo 1": "El efecto es el mismo para todos y no escalar
  todavía" se cambia por "Solo se estimó el efecto promedio; no escalar todavía".
  El encargo 1 no afirmó que el efecto fuera igual para todos.
- Fila 1, columna "Por qué": "Sin diferencia" se cambia por "El método lo
  confirma".
- Contraste: hoy toda la tabla tiene fondo azul claro. Se pone el encabezado en
  azul oscuro con texto blanco y las filas en blanco, alternando con gris muy
  claro. En la columna "Veredicto", "Cambia" va en negrita ocre (#B8863B) y "Se
  mantiene" en negrita azul (#2B5FA3).

### 3.5 Diapositiva 15: conectar con la nueva diapositiva de robustez

Bajo "Decisión respaldada", se agrega una línea: "Respaldo: heterogeneidad con
pruebas formales y regla validada en datos que no la eligieron." Así la decisión
queda enlazada con la evidencia.

---

## Cambios que NO se hacen en PowerPoint (se le avisan al equipo)

Estas figuras salen del código en R. Hay que corregirlas en el repositorio y
volver a insertar la imagen. **No se editan ni se tapan en PowerPoint.**

- **Diapositivas 5, 6 y 11:** el subtítulo de la figura dice "Datos historicos
  (sin asignacion aleatoria)" y "asignacion", sin tildes. Se corrige en
  `02_Scripts/00_formato_graficas.R` y se regenera con `00_main.R`.
- **Diapositiva 5:** el eje x del panel en dólares empieza en −10, aunque el gasto
  siempre es positivo.
- **Diapositivas 8 y 12:** las gráficas se rehicieron dentro de la presentación.
  Lo ideal es usar las figuras exportadas desde R. Si no da el tiempo, se deja
  así, pero con las cifras corregidas del punto 2.1.

---

## Orden final propuesto y tiempos (máximo 15 minutos)

| # | Diapositiva | Expone | Tiempo |
| --- | --- | --- | --- |
| 1 | Portada | Santiago | 0:15 |
| 2 | Recomendación | Santiago | 0:50 |
| 3 | Punto de partida y estimando | Santiago | 0:45 |
| 4 | Experimento válido y representativo | Santiago | 0:40 |
| 5 | El logaritmo cambia la pregunta | Douglas | 0:45 |
| 6 | Salto de 5 minutos | Douglas | 0:40 |
| 7 | Modelos e hiperparámetros (ajustada) | Douglas | 0:55 |
| 8 | Variables que predicen | Douglas | 0:35 |
| 9 | Árbol podado | Douglas | 0:40 |
| 10 | Error de predicción | Mateo | 0:45 |
| 11 | **Nueva:** veredicto y limitaciones de los árboles | Mateo | 0:45 |
| 12 | **Nueva:** bosque causal | Mateo | 0:50 |
| 13 | Efecto por dispositivo y sistema | Mateo | 0:45 |
| 14 | Conciliación log–dólares (corregida) | Samuel | 0:45 |
| 15 | La regla gana fuera de muestra | Samuel | 0:45 |
| 16 | **Nueva:** respaldado vs. exploratorio | Samuel | 0:50 |
| 17 | Contraste con el encargo 1 | Samuel | 0:45 |
| 18 | Decisión y próximos pasos | Santiago | 0:45 |
| 19 | Gracias | — | 0:05 |
|   | **Total** | | **≈ 13:30** |

Reparto aproximado: Santiago 3:15, Douglas 3:35, Mateo 3:05, Samuel 3:05.

**Advertencia para el equipo:** el guion actual (`04_Presentaciones/guion.md`)
tiene unas 3,500 palabras y otra numeración de diapositivas. A 140–150 palabras
por minuto, eso pasa de 20 minutos. Hay que recortarlo a unas 1,900–2,000
palabras y alinearlo con este orden antes de grabar.

## Lista de chequeo final

- [ ] Todos los títulos enuncian una conclusión (ninguno dice solo "Bosque
      causal", "Resultados" o "Validación").
- [ ] Cada cifra en % o en dólares tiene su escala explícita.
- [ ] Cada diapositiva dice si el resultado es predictivo/descriptivo (base
      histórica) o causal (experimento).
- [ ] Las cifras de las diapositivas 12 y 14 quedaron corregidas (0.10 / 0.06 /
      0.25; especificación 80%, método 20%).
- [ ] Están las tres diapositivas nuevas (bosque causal, limitaciones,
      respaldado vs. exploratorio).
- [ ] No quedan rutas de archivo ni código visibles.
- [ ] No quedan erratas ("predictico", tildes faltantes en texto de PowerPoint).
