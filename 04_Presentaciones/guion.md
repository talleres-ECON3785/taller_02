# Guion del video: Taller 2 (CheMarket Inc.)

Borrador para grabar. Mock de las diapositivas:
https://claude.ai/artifact/U5qAtLTZhQ6yHEiwYboUDT (18 diapositivas; el texto
hablado está también en las notas de cada una).

- **Mensaje central (answer-first):** usar árboles cambia la decisión de
  CheMarket. Predicen mejor el gasto (árbol podado: 1.63 frente a 2.31 dólares
  del Taller 1) y muestran a quién no darle el registro facilitado. La
  recomendación es darlo a todos, salvo a los celulares con Windows u otro sistema
  operativo: 0.66 dólares por usuario frente a 0.42 de dárselo a todos, en datos
  que no se usaron para elegir la regla.
- **Fuente de las cifras:** `05_Notas/sintesis.md` y
  `10_Auditoria/respuestas_enunciado.md`. Toda figura o tabla sale de
  `03_Resultados/` tal cual la exporta `00_main.R`.
- **Duración estimada:** unos 13:25 minutos (límite: 15).

## Reparto (propuesta, a confirmar con el equipo)

| Bloque | Diapositivas | Expone | Tiempo |
| --- | --- | --- | --- |
| Recomendación y punto de partida | 1–3 | Santiago Muñoz | 2:20 |
| Parte A: predicción | 4–9 | Douglas Plazas | 4:05 |
| Parte B: efecto y heterogeneidad | 10–13 | Mateo Olmos | 3:10 |
| Parte B: regla, conciliación, confianza | 14–17 | Samuel Escandón | 3:05 |
| Cierre | 18 | Santiago Muñoz | 0:45 |

El bloque de Douglas es el más largo (4:05 frente a unos 3:05 de los demás). Si se
quiere equilibrar, la diapositiva 8 (entrenamiento) puede pasar a Santiago.

## Diapositivas

### 1. Usar árboles cambia la decisión de CheMarket

- **Expone:** Santiago Muñoz (0:20)
- **Evidencia:** ninguna (portada).
- **Texto:** Buenas. Somos el equipo de consultoría de CheMarket. En el primer
  informe les dijimos que el registro facilitado sube el gasto promedio, pero no
  recomendamos escalarlo. Hoy volvemos con métodos más flexibles, basados en
  árboles, y la respuesta corta es esta: usar árboles sí cambia la decisión.
  Predicen mejor cuánto va a gastar un usuario y, sobre todo, muestran a quién no
  conviene darle el registro facilitado.

### 2. Recomendamos usar árboles: predicen mejor el gasto y muestran a quién no darle el registro facilitado

- **Expone:** Santiago Muñoz (1:00)
- **Evidencia:** `03_Resultados/Tablas/11_comparacion_prediccion_observacional/observacional_rmse_prueba_comparacion.png`
  y `03_Resultados/Tablas/13_focalizacion_experimento/experimento_valor_reglas.png`
  (cifras en tarjetas).
- **Texto:** Empezamos por la recomendación. Recomendamos usar árboles, por dos
  razones. Primera, para predecir el gasto: en 20,000 usuarios que el modelo nunca
  vio, el árbol podado se equivoca en promedio 1.63 dólares, frente a 2.31 del
  modelo lineal del Taller 1; es un error 30% menor. Segunda, y más importante,
  para decidir el registro facilitado: el promedio escondía grupos que ganan y
  grupos que pierden. Si se lo damos a todos menos a quienes entran desde un
  celular con Windows u otro sistema operativo, que son el 35% de los usuarios, el
  gasto sube 0.66 dólares por usuario, frente a 0.42 si se lo damos a todos. Ese
  valor se midió con una mitad del experimento que no se usó para elegir la regla.
  Lo único que no sabemos es el costo de mostrar dos formularios: si supera 0.235
  dólares por usuario, conviene dárselo a todos.

### 3. Frente al Taller 1, el diagnóstico se mantiene; lo que cambia es la decisión

- **Expone:** Santiago Muñoz (1:00)
- **Evidencia:** tabla construida en la diapositiva con las cifras de
  `05_Notas/sintesis.md` (tabla de conclusiones). Declara el estimando de la
  Parte B (H1).
- **Texto:** ¿Qué cambia frente al primer informe? Cambiamos dos cosas a la vez:
  el método, de regresión lineal a árboles, y la escala, del gasto en dólares a su
  logaritmo, que mide el cambio porcentual del usuario típico. En esta tabla
  separamos de dónde viene cada diferencia. Se mantiene el diagnóstico: el gasto
  salta a los 5 minutos en el sitio, y el árbol encuentra ese corte solo. Cambia el
  error de predicción, por el método. El efecto promedio en dólares es el mismo,
  pero en el gasto típico es casi cero: eso viene de la transformación. Y cambia
  la decisión: el efecto no es uno solo, va de menos 22% a más 45% según el
  dispositivo y el sistema operativo, y eso lo revela el método. Douglas les
  muestra primero la predicción.

### 4. En usuarios que no vio, el árbol se equivoca 30% menos que el modelo del Taller 1

- **Expone:** Douglas Plazas (0:45)
- **Evidencia:** `03_Resultados/Figuras/11_comparacion_prediccion_observacional/observacional_rmse_prueba_comparacion.png`
  (prueba, n = 20,000).
- **Texto:** Primera pregunta: ¿los árboles predicen mejor? Sí. Evaluamos todos
  los modelos una sola vez, en 20,000 usuarios que ningún modelo vio al
  entrenarse. El árbol se equivoca en promedio 1.63 dólares, frente a 2.31 del
  modelo del Taller 1, con un gasto medio de 3.98. Ojo con de dónde viene la
  mejora: el 68% se consigue con un modelo lineal al que le agregamos a mano el
  corte de los 5 minutos y su cruce con las sesiones. La ventaja del árbol es que
  llega a eso por sí solo, y agrega el resto. Un bosque de mil árboles no mejora a
  un solo árbol. En logaritmo el orden es el mismo: un error de 0.35 significa que
  la predicción del gasto típico se desvía en un factor cercano a 1.4.

### 5. Sin indicárselo, el árbol encuentra el salto de 5 minutos y que las sesiones solo pesan después

- **Expone:** Douglas Plazas (0:45)
- **Evidencia:** `03_Resultados/Figuras/09_arboles_observacional/observacional_cart_arbol_log.png`
  (entrenamiento, n = 80,000).
- **Texto:** ¿Qué patrones encuentra el árbol? Le dimos las seis variables tal como
  vienen, con el tiempo continuo, y su primer corte es exactamente en 5 minutos en
  el sitio. Es el mismo salto del Taller 1, pero ahora lo encuentra un método que
  solo vio los datos de entrenamiento. Luego el árbol arma solo las interacciones:
  con 5 minutos o menos, lo único que distingue es el dispositivo, y el usuario
  típico de computador gasta 20% más que el de celular. Con más de 5 minutos,
  importan las sesiones anteriores y, entre los usuarios frecuentes, el sistema
  operativo: el de osx gasta 42% más. El modelo lineal del Taller 1 no podía verlo,
  porque trataba el tiempo como una recta y cada variable por separado. Todo esto
  describe quién gasta más, no qué hace gastar más.

### 6. Tiempo en el sitio y sesiones anteriores concentran más del 90% de la predicción; el registro, casi nada

- **Expone:** Douglas Plazas (0:35)
- **Evidencia:** `03_Resultados/Figuras/10_bosque_observacional/observacional_bosque_importancia.png`
  (error fuera de bolsa, entrenamiento).
- **Texto:** ¿Qué variables sirven para predecir? Dos: el tiempo en el sitio y las
  sesiones anteriores, que juntas concentran más del 90% de la importancia en el
  bosque. Dispositivo y sistema operativo aportan poco, y el registro, casi nada:
  0.03%. Lo mismo dicen el modelo lineal construido paso a paso, el árbol y el
  bosque, en las dos escalas. Una advertencia: esto mide cuánto usa el modelo cada
  variable para predecir, no cuál mueve el gasto. Que el registro no ayude a
  predecir no dice nada sobre su efecto; eso solo lo mide el experimento.

### 7. El árbol separa grupos de usuarios cuyo gasto difiere casi cinco veces

- **Expone:** Douglas Plazas (0:35)
- **Evidencia:** `03_Resultados/Tablas/09_arboles_observacional/observacional_cart_cortes.png`.
- **Texto:** ¿Hay subgrupos con niveles de gasto distintos? Sí, y el árbol los
  entrega listos. El grupo que más gasta, 12.46 dólares en promedio, son 1,524
  usuarios que pasan más de 5 minutos, tienen 4 o más sesiones anteriores y entran
  con osx desde computador o tableta. El que menos gasta, 2.62 dólares, son más de
  25,000 usuarios que pasan 5 minutos o menos y entran desde un celular. Casi cinco
  veces de diferencia, con grupos que CheMarket puede reconocer con lo que ya
  observa. Sirven para priorizar, pero son descriptivos: no dicen qué haría gastar
  más a un usuario.

### 8. Todo se eligió con datos de entrenamiento; los 20,000 usuarios de prueba se usaron una sola vez

- **Expone:** Douglas Plazas (0:40)
- **Evidencia:** `03_Resultados/Tablas/09_arboles_observacional/observacional_cart_poda.png`
  y `03_Resultados/Tablas/10_bosque_observacional/observacional_bosque_elegido.png`
  (cifras resumidas en una tabla de la diapositiva).
- **Texto:** ¿Cómo se entrenaron? Usamos la misma partición del Taller 1: 80% para
  entrenar y 20% para probar, con semilla 2026, para que la comparación sea limpia.
  Para el árbol, lo dejamos crecer y lo podamos con validación cruzada de 10
  pliegues. Antes de ver los resultados fijamos la regla de un error estándar: nos
  quedamos con el árbol más simple cuyo error no se distingue del mínimo. Quedó con
  10 hojas en logaritmo y 9 en dólares. Para el bosque probamos 18 combinaciones de
  cuántas variables mira cada corte y qué tan pequeñas pueden ser las hojas, y
  elegimos con el error fuera de bolsa, que no usa los datos de prueba. Ganó un
  bosque de 3 variables por corte y hojas de al menos 100 usuarios. El error de
  entrenamiento coincide con el de prueba, así que no hay sobreajuste visible.

### 9. Para predecir el gasto conviene el árbol podado; el modelo lineal queda como referencia

- **Expone:** Douglas Plazas (0:45)
- **Evidencia:** `03_Resultados/Tablas/11_comparacion_prediccion_observacional/observacional_rmse_prueba_comparacion.png`;
  inestabilidad en `05_Notas/09_arboles_observacional/A_cart_recupera_corte_5_min.md`.
- **Texto:** Nuestro veredicto para la Parte A: para predecir el gasto conviene el
  árbol podado. Tiene el menor error de todos los modelos, igual al del bosque, y a
  diferencia del bosque se puede leer y explicar. Además encuentra solo el corte y
  las interacciones que al modelo lineal hay que dárselas a mano. El modelo lineal
  queda como referencia: un lineal bien especificado se acerca bastante, con 1.85
  dólares. El árbol tiene límites. Es inestable: con otra muestra, los cortes más
  profundos pueden cambiar. Predice por escalones, así que no distingue dentro de
  un grupo ni extrapola fuera de lo observado. Usamos una sola partición, así que
  el error no tiene intervalo. Y predice, no explica: nada de esto dice qué hacer
  para que un usuario gaste más. Para eso está el experimento, que les presenta
  Mateo.

### 10. El registro facilitado sube el gasto promedio 0.49 dólares, pero el del usuario típico casi no cambia

- **Expone:** Mateo Olmos (0:45)
- **Evidencia:** `03_Resultados/Tablas/12_heterogeneidad_experimento/experimento_ate_lineal_vs_bosque.png`;
  balance y cumplimiento en `03_Resultados/Tablas/06_ate_experimento_niveles/`.
- **Texto:** Pasamos al experimento, que sí permite hablar de causas. Primero, el
  experimento es válido: los dos grupos son comparables en todo lo observable y
  todos los asignados al registro facilitado se registraron. En dólares, el
  resultado del Taller 1 se mantiene: el registro facilitado sube el gasto promedio
  0.49 dólares por usuario. Pero si miramos el logaritmo, es decir, cuánto cambia el
  gasto del usuario típico en porcentaje, el efecto es de apenas 1.3% y no se
  distingue de cero. Las dos cifras no se contradicen: miden cosas distintas. El
  promedio en dólares pesa más a quienes gastan más; el logaritmo trata igual a
  todos. El bosque causal da cifras parecidas: 0.41 dólares y 0.4%. La pregunta es
  entonces por qué difieren.

### 11. El bosque causal es honesto: unos usuarios definen los grupos y otros miden el efecto

- **Expone:** Mateo Olmos (0:50)
- **Evidencia:** especificación de `02_Scripts/12_heterogeneidad_experimento.R`
  (sin figura).
- **Texto:** Para ver si el efecto cambia entre usuarios usamos un bosque causal.
  Es un conjunto de árboles que, en vez de predecir el gasto, buscan grupos de
  usuarios en los que el efecto del registro facilitado es distinto. La clave es
  que es honesto: cada árbol divide su muestra en dos; con una mitad decide dónde
  cortar y con la otra mide el efecto en cada grupo. ¿Por qué importa? Si los
  mismos datos eligen los grupos y miden su efecto, el método tiende a encontrar
  diferencias que son puro ruido. Separarlos evita ese sesgo y nos da intervalos
  válidos. Usamos 2,000 árboles y semilla 2026, y las cinco características que
  existen antes del tratamiento. Como la asignación fue aleatoria, fijamos la
  probabilidad de tratamiento en la proporción tratada. El resto son los valores
  por defecto del paquete, como en el laboratorio, sin ajuste fino. El modelo final
  es el de logaritmo; lo repetimos en dólares y sin el tiempo en el sitio como
  prueba de robustez.

### 12. El efecto no es igual para todos, y dos pruebas formales muestran que la diferencia es real

- **Expone:** Mateo Olmos (0:45)
- **Evidencia:** `03_Resultados/Figuras/12_heterogeneidad_experimento/experimento_toc.png`;
  `03_Resultados/Tablas/12_heterogeneidad_experimento/experimento_calibracion_bosque.png`
  y `experimento_rate_autoc.png`.
- **Texto:** Que un método encuentre grupos no prueba que existan; puede estar
  ajustando ruido. Por eso hicimos dos pruebas formales. La primera, de
  calibración: si el bosque dice que un usuario tiene un efecto mayor, ¿responde
  realmente más? Sí, y en la proporción predicha: el coeficiente es 1.01, con un
  error estándar de 0.03. La segunda usa muestras separadas: con una mitad del
  experimento ordenamos a los usuarios por prioridad y con la otra medimos. La
  curva muestra que los primeros en la fila sí responden más. El tercio con mayor
  prioridad sube su gasto típico 27.6%; el de menor prioridad lo baja 22.9%. Y el
  resultado se mantiene si quitamos el tiempo en el sitio, que se mide en la misma
  sesión. La heterogeneidad es real.

### 13. El registro facilitado baja el gasto cerca de 20% en celulares sin osx y lo sube hasta 45% con osx

- **Expone:** Mateo Olmos (0:50)
- **Evidencia:** `03_Resultados/Figuras/13_focalizacion_experimento/experimento_efecto_celdas_dispositivo_so.png`.
- **Texto:** ¿Quién gana y quién pierde? El bosque corta sobre todo por dos
  características: el dispositivo y el sistema operativo. En celulares con Windows
  u otro sistema, que son el 35% de los usuarios, el registro facilitado baja el
  gasto típico cerca de 20%. En computadores y tabletas con osx, el 15%, lo sube
  entre 35% y 45%. En computadores con Windows y en celulares con osx sube poco,
  cerca de 8%. Y hay dos grupos pequeños donde no podemos distinguir el efecto de
  cero. Lo importante para el negocio: dispositivo y sistema operativo se conocen
  antes de mostrarle el formulario al usuario, así que la regla se puede aplicar.
  Samuel les cuenta cuánto vale.

### 14. La regla deja 0.66 dólares por usuario, frente a 0.42 de dárselo a todos, en datos que no la eligieron

- **Expone:** Samuel Escandón (0:50)
- **Evidencia:** `03_Resultados/Tablas/13_focalizacion_experimento/experimento_valor_reglas.png`
  (mitad de evaluación, n = 5,000).
- **Texto:** ¿Cuánto vale la regla? Para no engañarnos, la elegimos con una mitad
  del experimento y la medimos con la otra, usando un bosque estimado de nuevo. Así
  el valor no está inflado por haber escogido los grupos que mejor salieron. En esa
  mitad, dar el registro facilitado a todos salvo a los celulares con Windows u
  otro sistema deja 0.66 dólares por usuario y sube el gasto típico 10.2%. Dárselo a
  todos deja 0.42 dólares y casi no mueve el gasto típico: 0.8%. La diferencia,
  0.235 dólares por usuario, tiene un intervalo lejos de cero. Y la regla también
  le gana a la alternativa más obvia, darlo solo en computador y tableta, porque
  los celulares con osx sí ganan.

### 15. Los 0.49 dólares del Taller 1 son el promedio de grupos que ganan y grupos que pierden

- **Expone:** Samuel Escandón (0:45)
- **Evidencia:** `03_Resultados/Tablas/13_focalizacion_experimento/experimento_conciliacion_celdas.png`
  (conciliación nivel–log, H2).
- **Texto:** Esto también explica el resultado del Taller 1. Los 0.49 dólares eran
  un promedio de grupos que van en direcciones opuestas: el 65% de los usuarios
  está en grupos que ganan y el 35% en grupos que pierden. En el gasto típico,
  ganancias y pérdidas se cancelan y el promedio queda prácticamente en cero. En
  dólares queda positivo por dos razones: los grupos que ganan ya gastaban algo
  más, 4.16 frente a 3.64 dólares, y dentro de cada grupo el tratamiento sube más la
  media que el gasto típico. Por eso decimos que la diferencia entre escalas viene
  de ambos lados: del método, que revela los signos opuestos, y de la
  transformación. En el Taller 1 sospechábamos que el promedio lo movían pocos
  usuarios de gasto alto; ahora sabemos que son grupos enteros.

### 16. Que ganen computador y osx es coherente con quién gasta más; por qué pierde el celular sin osx no lo sabemos

- **Expone:** Samuel Escandón (0:45)
- **Evidencia:** `03_Resultados/Figuras/09_arboles_observacional/observacional_cart_arbol_log.png`
  (gasto por dispositivo y sistema operativo) y
  `03_Resultados/Tablas/13_focalizacion_experimento/experimento_conciliacion_celdas.png`
  (gasto base).
- **Texto:** ¿Es creíble este patrón desde el negocio? En parte sí. Los grupos que
  ganan con el registro facilitado son los mismos que, en los datos históricos, ya
  gastan más: el usuario típico de computador gasta 20% más que el de celular, y
  entre los usuarios frecuentes el de osx gasta 42% más. En el experimento, los
  grupos que ganan parten de 4.16 dólares y los que pierden de 3.64. Lo que no
  sabemos es por qué el gasto baja en celulares con Windows u otro sistema. Tenemos
  hipótesis: puede que un registro más fácil sirva más a quien ya llega con
  intención de compra, o que el formulario facilitado se vea o funcione distinto en
  esos celulares. Pero son hipótesis, no hallazgos: con estos datos no podemos
  distinguirlas. Por eso proponemos validarlo.

### 17. La heterogeneidad y el valor de la regla están respaldados; el detalle por usuario es exploratorio

- **Expone:** Samuel Escandón (0:45)
- **Evidencia:** tabla construida en la diapositiva con las cifras de los scripts
  06, 12 y 13 (ver `10_Auditoria/respuestas_enunciado.md`, columnas "Confianza").
- **Texto:** ¿Qué tan seguros estamos? Separamos lo respaldado de lo exploratorio.
  Respaldado: que el efecto cambia entre usuarios, con dos pruebas formales; que el
  dispositivo y el sistema operativo separan el efecto, con el mismo orden en las
  dos escalas; que la regla vale más que dárselo a todos, medido con datos que no
  la eligieron; que el resultado se sostiene sin el tiempo en el sitio; y que el
  experimento es válido y se parece a la población de CheMarket. Exploratorio: los
  efectos de cada usuario, el efecto por número de sesiones, dos grupos pequeños
  cuyos intervalos tocan el cero, el grupo de tableta con otro sistema, que tiene
  solo 84 usuarios, y los cuantiles por grupo, que no tienen intervalos. Tampoco
  ajustamos los p-valores por comparaciones múltiples; en su lugar, validamos la
  regla con la otra mitad del experimento.

### 18. Decisión: usar árboles, escalar el registro facilitado salvo en celulares sin osx y validar ese grupo

- **Expone:** Santiago Muñoz (0:45)
- **Evidencia:** `05_Notas/sintesis.md` (recomendación y preguntas abiertas).
- **Texto:** Cerramos con las decisiones. Primero, usar árboles: para predecir el
  gasto, el árbol podado es el mejor de los modelos que probamos y se puede
  explicar; el modelo lineal queda como referencia. Segundo, escalar el registro
  facilitado a todos los usuarios, salvo a quienes entran desde un celular con
  Windows u otro sistema operativo. Esto está respaldado por un experimento válido
  y medido con datos que no se usaron para elegir la regla. Nos faltan tres cosas.
  Por qué pierden esos celulares: proponemos una prueba A/B solo en ese grupo, de
  unos 3,500 usuarios como el actual; si el efecto no resulta negativo, se extiende
  el registro facilitado a todos. El costo de mantener dos formularios: si supera
  0.235 dólares por usuario, conviene dárselo a todos. Y si el resultado se sostiene
  en otro periodo, porque el experimento es de uno solo y supone que un usuario no
  afecta a otro. Gracias.

## Cobertura de la rúbrica

| Criterio | Elemento | Diapositivas |
| --- | --- | --- |
| A. Métodos (30) | Árboles para predecir, entrenamiento, hiperparámetros y modelo final | 5, 8 |
| | Diferencias con los lineales del Taller 1 | 3, 4, 5 |
| | Variables más relevantes | 6 |
| | Error de generalización con validación, semilla | 4, 8 |
| | Interpretación del error | 4 (factor 1.4; 1.63 de 3.98 dólares) |
| A. Recomendaciones (15) | ¿Árbol o lineal? | 9 |
| | Subgrupos con distinto nivel de gasto | 7 |
| | Limitaciones de los árboles | 9 |
| B. Bosques causales (30) | Bosque causal, enfoque honesto, entrenamiento e hiperparámetros | 11 |
| | Subgrupos con efecto mayor o menor | 13 |
| | ¿Cambia el ATE en niveles o en logaritmos? | 10, 15 |
| B. Recomendaciones (15) | Comparación con el Taller 1 | 3, 10, 15 |
| | Plausibilidad para la empresa | 16 |
| | Implicaciones para la estrategia | 2, 14, 18 |
| | Robusto o exploratorio | 17 |
| Presentación (10) | Recomendación como primer mensaje; títulos como conclusiones; sin código | 1–2; todas |

## Pendientes antes de grabar

- Confirmar el reparto: la tabla de integrantes de `CLAUDE.md` no asigna roles,
  salvo a Douglas (análisis histórico).
- Ensayar con cronómetro. El texto está escrito para unas 130 palabras por minuto.
- Pasar los slides finales al formato del equipo (PowerPoint o Google Slides) con
  los `.png` de `03_Resultados/` sin retoques. Las diapositivas 3, 8 y 17 son tablas
  armadas en la diapositiva con cifras de las notas; si el equipo prefiere tablas
  exportadas desde R, hay que agregarlas al script correspondiente.
- Antes de grabar, correr `00_main.R` completo (P7.1) y confirmar que ninguna cifra
  del guion cambia.
