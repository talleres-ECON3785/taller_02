# Respuestas al enunciado del Taller 2 (CheMarket Inc.)

Documento para la mesa directiva y para armar el guion del video. Todas las cifras
están verificadas contra los archivos citados (auditoría del 2026-10-25). Las
salidas del pipeline (`03_Resultados/`) tienen prioridad sobre las de la
auditoría (`10_Auditoria/salidas/`), que se marcan como tales.

## Mensaje en 30 segundos

**Recomendación: dar el registro facilitado a todos los usuarios, salvo a los que
entran desde un celular con Windows u otro sistema operativo (35% de los
usuarios). A ellos se les deja el formulario actual.**

Tres razones:

1. **El efecto no es igual para todos, y eso está probado.** En promedio, el
   registro facilitado casi no cambia el gasto del usuario típico (+0.4%). Pero
   ese promedio esconde efectos opuestos: sube el gasto en computadores, tabletas y
   celulares con osx (de +6% a +45%) y lo baja cerca de 20% en celulares con
   Windows u otro sistema. Dos pruebas formales confirman que estas diferencias son
   reales y no ruido del método.
2. **La regla vale más que dárselo a todos, medido con datos que no se usaron para
   elegirla.** Con la mitad del experimento que no participó en la elección, la
   regla sube el gasto del usuario típico cerca de 10% y deja 0.66 dólares por
   usuario. Dárselo a todos deja 0.42 dólares y casi no mueve el gasto típico
   (+0.8%).
3. **Es aplicable y coherente en las dos medidas.** CheMarket conoce el dispositivo
   y el sistema operativo antes de mostrar el formulario. Los grupos excluidos son
   los únicos en los que el registro facilitado hace daño, y lo hace tanto en el
   gasto típico como en dólares.

## Estimando (Parte B)

**Estimando principal:** el efecto causal del registro facilitado sobre el
logaritmo del gasto de cada grupo de usuarios (dispositivo × sistema operativo),
leído como el cambio porcentual del gasto del usuario típico del grupo
(`exp(efecto) − 1`). **Complemento etiquetado:** el mismo efecto en dólares por
usuario, que mide cuánto pesa cada grupo en el ingreso total. En la Parte A no hay
parámetro causal: el objetivo es predecir el logaritmo del gasto.

---

## Parte A. ¿Los árboles predicen mejor el gasto?

Base histórica (100,000 usuarios; entrenamiento 80,000, prueba 20,000; partición
del Taller 1, semilla 2026). **Todo es predictivo, sin lectura causal:** dice
quién gasta más, no qué hace que alguien gaste más.

### A1. ¿Qué variables resultan más útiles para predecir el logaritmo del gasto?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | El tiempo en el sitio (si pasó más de 5 minutos) y las sesiones anteriores, sobre todo combinadas. Dispositivo y sistema operativo aportan poco; usuario recurrente y registro, casi nada. |
| Cifra clave | Escalera de validación cruzada en log (entrenamiento): el corte de 5 minutos da el 60% de la caída del error, las sesiones y su combinación con el corte el 33%, el dispositivo el 6% y el resto menos del 1%. Importancia por permutación del bosque en log: tiempo 65.9%, sesiones 28.6%, dispositivo 3.6%, sistema operativo 1.6%. |
| De dónde sale | Escalera en log: `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_escalera_rmse_log.png` y la figura del mismo nombre en `03_Resultados/Figuras/04_prediccion_lineal_observacional/`; importancia: `03_Resultados/Figuras/10_bosque_observacional/observacional_bosque_importancia.png`; escalera en dólares: `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_escalera_rmse.png` |
| Confianza | Respaldada. Tres métodos coinciden en el orden (escalera lineal, árbol y bosque) y en las dos escalas. |
| ¿Transformación, método o ambos? | Ninguno cambia el orden: es el mismo en dólares y en log, con lineales y con árboles. |

### A2. ¿Qué relaciones o patrones aparecen con los árboles?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | Sin que se le indique, el árbol corta primero en 5 minutos en el sitio. Del lado de 5 minutos o menos solo distingue por dispositivo; del lado de más de 5 minutos distingue por sesiones anteriores y, con 4 o más sesiones, por sistema operativo. Las sesiones solo importan después de los 5 minutos. |
| Cifra clave | Primer corte: 5.0007 minutos (solo entrenamiento). En log, el usuario típico de computador gasta +20% que el de celular entre quienes pasan 5 minutos o menos; con más de 5 minutos y 4 o más sesiones, el de osx gasta +42% que el de Windows u otro. El grupo de mayor gasto (12.46 dólares, 1,524 usuarios) combina más de 5 minutos, 4 o más sesiones, osx y computador o tableta; el de menor gasto (2.62 dólares, 25,548 usuarios), 5 minutos o menos desde celular. Árbol de 10 hojas en log y 9 en dólares. |
| De dónde sale | `03_Resultados/Figuras/09_arboles_observacional/observacional_cart_arbol_log.png` y `_dolares.png`; `03_Resultados/Tablas/09_arboles_observacional/observacional_cart_cortes.png` |
| Confianza | Respaldada para el corte de 5 minutos y la interacción con las sesiones (coinciden con las descriptivas y con el Taller 1). Con matices para los cortes de dispositivo y sistema operativo, que un árbol puede cambiar con otra muestra. |
| ¿Transformación, método o ambos? | Método: el árbol arma solo las interacciones. La estructura casi no cambia entre dólares y log. |

### A3. ¿Cómo se compara su desempeño con el de los modelos lineales?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | Los árboles se equivocan menos que todos los lineales, en usuarios que no vieron. En dólares, el error típico baja de 2.31 dólares (modelo del Taller 1) a 1.63 (árbol), frente a un gasto medio de 3.98. Un bosque de 1,000 árboles no mejora a un solo árbol. |
| Cifra clave | RMSE de prueba (n = 20,000), en dólares: media 2.716; lineal del Taller 1 2.314; lineal con corte y combinación 1.845; LASSO 1.765; árbol 1.627; bosque 1.626 (40.1% menos que la media). En log: 0.534, 0.452, 0.369, 0.361, 0.349 y 0.350. Un error de 0.35 en log equivale a que la predicción del gasto típico se desvía en un factor cercano a 1.4 (≈ +42% o −30%). De la ganancia frente al Taller 1 (0.687 dólares), el corte y la combinación dan 68%, LASSO 12% y el árbol 20%. |
| De dónde sale | `03_Resultados/Tablas/11_comparacion_prediccion_observacional/observacional_rmse_prueba_comparacion.png` y la figura del mismo nombre |
| Confianza | Respaldada (una sola evaluación en prueba, hiperparámetros elegidos solo con entrenamiento). Con un matiz: el corte de 5 minutos del lineal se eligió mirando la base completa, pero el árbol, que solo ve entrenamiento, encuentra el mismo corte. |
| ¿Transformación, método o ambos? | Especificación y método: la mayor parte la gana un lineal bien especificado; el árbol agrega el resto y llega a esa especificación por sí solo. |

### A4. ¿Qué cambia al usar el logaritmo del gasto en lugar del gasto en dólares?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | El logaritmo comprime la cola de gastos altos y hace que el análisis hable del usuario típico, no del promedio. Para predecir, no cambia el orden de las variables ni la ventaja de los árboles, y llevar la predicción de los árboles a dólares deja el mismo error. En el experimento, cambia la pregunta que responde el efecto: del promedio en dólares al cambio porcentual del usuario típico. |
| Cifra clave | Asimetría del gasto: 2.66 en dólares frente a 0.68 en log. Árbol: 1.627 dólares ajustado en dólares y 1.627 ajustado en log y retransformado (corrección de Duan). Los lineales simples empeoran al retransformar (2.314 → 2.382; 1.845 → 1.952). Mejora frente a la media: 40.1% en dólares y 34.7% en log (cada escala contra su propia media). |
| De dónde sale | `03_Resultados/Tablas/07_forma_funcional_observacional/observacional_distribucion_ingreso.png`; `03_Resultados/Tablas/11_comparacion_prediccion_observacional/observacional_rmse_prueba_comparacion.png` |
| Confianza | Respaldada. |
| ¿Transformación, método o ambos? | Transformación. En los árboles es neutra para el error en dólares; en los lineales simples lo empeora. |

### A5. ¿Qué conclusiones del Taller 1 se mantienen y cuáles cambian?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | **Se mantiene** que el tiempo en el sitio es lo que más predice el gasto, con un salto a los 5 minutos, y que el registro no ayuda a predecir el gasto una vez conocidos tiempo y sesiones. **Cambia** la forma: el tiempo exacto deja de importar una vez se sabe si pasó los 5 minutos, y las sesiones solo cuentan después de ese corte. **Cambia** el error: de 2.31 a 1.63 dólares. |
| Cifra clave | Salto en 5 minutos: 3.13 dólares en el Taller 1 y 3.07 ahora. Con el corte incluido, el tiempo exacto no reduce el error de validación (1.869 frente a 1.869). Registro: −0.00001 dólares en la escalera y 0.03% de la importancia del bosque. |
| De dónde sale | `03_Resultados/Tablas/07_forma_funcional_observacional/observacional_punto_partida_taller1.png`; `03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_robustez_forma_tiempo.png`; `05_Notas/sintesis.md` (tabla de conclusiones) |
| Confianza | Respaldada. |
| ¿Transformación, método o ambos? | Especificación y método; la transformación no cambia estas conclusiones. |

---

## Parte B. ¿El efecto de facilitar el registro es igual para todos?

Experimento A/B (10,000 usuarios, asignación aleatoria). **Lectura causal.**
Validez: grupos comparables (balance F = 0.96, p = 0.456), cumplimiento perfecto
(5,043 controles sin registro y 4,957 tratados registrados) y muestra parecida a la
base histórica (F = 0.66, p = 0.708). Fuente:
`03_Resultados/Tablas/06_ate_experimento_niveles/`.

### B1. ¿Cambia el efecto promedio y su interpretación en logaritmo?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | Sí. En dólares, el registro facilitado sube el gasto promedio 0.49 dólares por usuario (+12%). En el gasto del usuario típico, el cambio es de apenas +1.3%, no distinguible de cero. Las dos cifras no se contradicen: miden cosas distintas. Los efectos de distintos grupos tienen signo opuesto y se cancelan en el usuario típico; en dólares pesan más los grupos que gastan más, y dentro de cada grupo el tratamiento sube más la media que el gasto típico. |
| Cifra clave | Dólares: 0.491 (IC 0.347 a 0.634), con el modelo lineal; 0.414 (0.330 a 0.498) con el bosque. Gasto típico: +1.3% (−1.0% a +3.8%) con el modelo lineal; +0.4% (−1.1% a +1.9%) con el bosque. Conciliación: los efectos proporcionales por grupo explican 0.17 de 0.41 dólares; al separar también por sesiones, 0.22 de 0.39. Quedan como mucho 0.17 dólares dentro de los grupos. |
| De dónde sale | `03_Resultados/Tablas/12_heterogeneidad_experimento/experimento_ate_lineal_vs_bosque.png`; `03_Resultados/Tablas/13_focalizacion_experimento/experimento_conciliacion_celdas.png`; `03_Resultados/Tablas/08_ate_experimento_log/experimento_descomposicion_media.png` |
| Confianza | Respaldada. |
| ¿Transformación, método o ambos? | Ambos. Método: los signos opuestos entre grupos explican por qué el efecto es ≈ 0 en log. Transformación: el gasto base distinto y el ensanchamiento dentro de los grupos explican por qué en dólares queda positivo. |

### B2. ¿Existe evidencia de heterogeneidad en los efectos?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | Sí, con evidencia formal. Los usuarios a los que el método les asigna un efecto mayor sí responden más, en la proporción predicha. Además, al elegir con una mitad del experimento a quién priorizar, la otra mitad confirma que esos usuarios responden más. |
| Cifra clave | Prueba de calibración: coeficiente de las diferencias 1.01 (error estándar 0.031; p < 0.001); 0.97 sin el tiempo en el sitio. Muestra dividida (5,000 usuarios de evaluación): AUTOC 0.200 (IC 0.180 a 0.221). Tercio de mayor prioridad +27.6% (+23.1% a +32.3%); de menor prioridad −22.9% (−25.5% a −20.2%). |
| De dónde sale | `03_Resultados/Tablas/12_heterogeneidad_experimento/experimento_calibracion_bosque.png`, `experimento_rate_autoc.png`; `03_Resultados/Figuras/12_heterogeneidad_experimento/experimento_toc.png` |
| Confianza | Respaldada. |
| ¿Transformación, método o ambos? | Método (la regresión lineal sin interacciones impone un solo efecto). |

### B3. ¿Cómo varían los efectos entre usuarios con distintas características?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | Mucho, y con signos opuestos. Uno de cada diez usuarios tiene un efecto estimado de −24% o menos y otro de cada diez, de +38% o más; la mediana es +4.7%. Los efectos se ordenan sobre todo por dispositivo y sistema operativo: son mayores fuera del celular y con osx. |
| Cifra clave | Efectos individuales (en log, leídos como %): percentil 10 −24.2%, mediana +4.7%, percentil 90 +37.7%. Por grupo: computador +17.8%, tableta +14.7%, celular −14.1%; osx +24.0%, Windows −8.6%, otro sistema −7.1%; 0 a 2 sesiones −8.3%, 5 o más +9.7%. |
| De dónde sale | `03_Resultados/Figuras/12_heterogeneidad_experimento/experimento_cate_ordenados.png`; `03_Resultados/Tablas/12_heterogeneidad_experimento/experimento_cate_por_grupo.png` |
| Confianza | Respaldada para dispositivo, sistema operativo y sesiones. Con matices para los efectos individuales (sin corrección por comparaciones múltiples). |
| ¿Transformación, método o ambos? | Método. |

### B4. ¿Qué características permiten identificar grupos con efectos diferentes?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | El dispositivo y el sistema operativo, juntos. Son casi independientes entre sí (dentro de cada dispositivo, cerca de 30% usa osx) y sus efectos se suman: el efecto baja si el usuario está en celular y baja otra vez si no usa osx. Las sesiones anteriores ordenan el efecto dentro de cada dispositivo, pero no cambian la regla. El tiempo en el sitio y ser usuario recurrente no agregan grupos distintos. |
| Cifra clave | Importancia de las variables en el bosque causal, en log (frecuencia con que el bosque corta en cada una, ponderada por la profundidad del corte): dispositivo 61% (indicador de celular; 62% con el de tableta), sistema operativo 21% (indicador de Windows; 24% con el de otro sistema), sesiones anteriores 9%, tiempo en el sitio 5%. En celular, el efecto es negativo en los tres tramos de sesiones (de −22.1% a −7.5%). Usuario nuevo es lo mismo que 0 sesiones anteriores. |
| De dónde sale | `03_Resultados/Tablas/12_heterogeneidad_experimento/experimento_importancia_bosque_causal.png`; `03_Resultados/Tablas/13_focalizacion_experimento/experimento_efecto_celdas_dispositivo_so.png` y `experimento_efecto_celdas_dispositivo_sesiones.png`; suma de efectos: `10_Auditoria/salidas/aud_02_mco_interacciones.csv` (auditoría) |
| Confianza | Respaldada. La importancia de variables dice dónde corta el método, no qué causa la diferencia. |
| ¿Transformación, método o ambos? | Método. En dólares los efectos de dispositivo y sistema operativo dejan de sumarse porque el gasto base difiere (transformación). |

### B5. ¿Hay grupos con efecto sustancialmente mayor, menor o cercano a cero?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | **Mayor:** computador y tableta con osx (+45% y +35%), 15% de la base. **Menor (negativo):** celulares con Windows (−22.5%) y con otro sistema (−19.4%), 35% de la base. **Positivo pequeño:** computador con Windows y celular con osx (+8%), 39%. **Cercano a cero:** computador con otro sistema y tableta con Windows (+7% y +6%, intervalos que tocan el cero), 10%. |
| Cifra clave | Gasto típico (IC 95%) y dólares, % de la base histórica: computador–osx +44.5% [+38.7; +50.5], +2.59, 12.0%; tableta–osx +35.0% [+25.1; +45.6], +1.93, 3.0%; computador–Windows +8.0% [+5.0; +11.1], +0.61, 24.0%; celular–osx +7.6% [+3.8; +11.6], +0.54, 15.2%; computador–otro +7.4% [−0.3; +15.6], +0.36, 4.0%; tableta–Windows +5.8% [−0.2; +12.0], +0.39, 5.9%; celular–otro −19.4% [−24.2; −14.3], −0.61, 5.0%; celular–Windows −22.5% [−24.5; −20.4], −0.67, 29.9%. Tableta–otro (84 usuarios, 1.0%) no permite concluir. |
| De dónde sale | `03_Resultados/Tablas/13_focalizacion_experimento/experimento_efecto_celdas_dispositivo_so.png`; `03_Resultados/Figuras/13_focalizacion_experimento/experimento_efecto_celdas_dispositivo_so.png` |
| Confianza | Respaldada para los grupos de signo claro: la otra mitad del experimento los confirma. Con matices para computador–otro y tableta–Windows (intervalos que incluyen el cero en la mitad de evaluación). Requiere evidencia para tableta–otro. |
| ¿Transformación, método o ambos? | Método. El orden de los grupos es el mismo en las dos escalas. |

### B6. ¿Cómo se relaciona la heterogeneidad con el efecto promedio del Taller 1?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | El efecto promedio del Taller 1 (0.49 dólares) es el promedio de efectos que van en direcciones opuestas. En el gasto típico, ese promedio es ≈ 0 porque un tercio de los usuarios pierde y dos tercios ganan o se quedan igual. La sospecha del Taller 1 (pocos usuarios de gasto alto mueven el promedio) se matiza: hay grupos enteros que ganan y grupos enteros que pierden. |
| Cifra clave | El promedio ponderado de los efectos por grupo reproduce el efecto promedio: 0.0039 en log y 0.414 dólares. 65% de los usuarios está en grupos con efecto positivo y 35% en grupos con efecto negativo. Gasto base: 4.16 dólares en los grupos que ganan y 3.64 en los que pierden. |
| De dónde sale | `03_Resultados/Tablas/13_focalizacion_experimento/experimento_conciliacion_celdas.png` |
| Confianza | Respaldada (identidad exacta). Lo que queda dentro de los grupos (como mucho 0.17 dólares) es una cota superior. |
| ¿Transformación, método o ambos? | Ambos. |

### B7. ¿Qué implica para la decisión de CheMarket?

| Campo | Contenido |
| --- | --- |
| Respuesta corta | **Sí, escalar el registro facilitado, salvo para los usuarios que entran desde un celular con Windows u otro sistema operativo.** |
| Cifra clave | Mitad de evaluación, por usuario de la base histórica, frente a no darlo a nadie: regla recomendada +10.2% del gasto típico [+8.4%; +12.0%] y 0.657 dólares [0.547; 0.766]; darlo a todos +0.8% [−1.3%; +2.9%] y 0.416 dólares [0.296; 0.535]; solo computador y tableta +8.7% y 0.578. Ganancia de la regla frente a darlo a todos: 0.235 dólares por usuario [0.192; 0.279]. Frente a solo computador y tableta: 0.076 [0.031; 0.121]. |
| De dónde sale | `03_Resultados/Tablas/13_focalizacion_experimento/experimento_valor_reglas.png` |
| Confianza | Respaldada: la regla se eligió con una mitad del experimento y se evaluó con la otra. Requiere evidencia sobre el mecanismo (ver abajo). |
| ¿Transformación, método o ambos? | Método (efectos por grupo). La regla es la misma en las dos escalas. |

**Decisión respaldada:** dar el registro facilitado a todos salvo a los celulares
con Windows u otro sistema operativo. Es el único grupo con daño distinguible de
cero, en el gasto típico y en dólares, y la regla vale más que dárselo a todos en
datos que no se usaron para elegirla.

**Preguntas abiertas (H10):**

1. **Mecanismo en celulares no osx.** No se sabe por qué el mismo formulario baja
   el gasto ahí.
   - **Evidencia que lo resolvería:** una validación focalizada.
   - **Población:** usuarios que entran desde celular con Windows u otro sistema.
   - **Brazos:** formulario facilitado frente al actual, con asignación aleatoria
     individual.
   - **Métrica:** logaritmo del gasto por usuario; dólares como complemento.
   - **Tamaño de referencia:** ese grupo tuvo 3,489 usuarios en el experimento
     actual.
   - **Qué cambiaría la decisión:** si el efecto resulta mayor o igual a cero, con
     un intervalo que descarte una caída, se extiende el registro facilitado a
     todos. Si sale negativo, se confirma la exclusión.
2. **Estabilidad en el tiempo.** El experimento es de un solo periodo; la misma
   validación lo comprueba en otro periodo.
3. **Costo de la intervención.** No hay datos de costo. [PENDIENTE] Si mostrar
   formularios distintos según el dispositivo tiene un costo por usuario mayor que
   la ganancia frente a darlo a todos (0.235 dólares), conviene dárselo a todos.

---

## Lista de chequeo H1–H10: lo que aún no se cumple

| # | Heurística | Estado | Qué falta |
| --- | --- | --- | --- |
| H1 | Estimando declarado y escala de cada número | Cumple en notas y aquí | Llevar el estimando a una diapositiva temprana del video. |
| H2 | Conciliación nivel vs. log | Cumple | Una diapositiva con la tabla de conciliación del script 13. |
| H3 | Descriptiva de cada covariable con el resultado | Cumple (scripts 03 y 07) | — |
| H4 | Especificación justificada | Cumple | Declarar en una nota al pie que el corte de 5 minutos se eligió mirando la base completa (el árbol lo reproduce solo con entrenamiento). |
| H5 | Importancia por caída de RMSE fuera de muestra | Cumple | Escalera en las dos escalas en el script 04 (`observacional_escalera_rmse` y `observacional_escalera_rmse_log`), generada y verificada contra la auditoría (diferencia 0). |
| H6 | RMSE en unidades del negocio | Cumple | En el video, decir el RMSE en log como factor (≈ 1.4) y el de dólares frente al gasto medio (1.63 de 3.98). |
| H7 | Balance y cumplimiento | Cumple | — |
| H8 | Magnitud, IC y lectura económica | Parcial | Falta el costo de la intervención para la relevancia económica. Los intervalos de los cuantiles por grupo (P3.3) siguen sin calcular. |
| H9 | Generalización y supuestos de atribución | Parcial | Representatividad y pesos por grupo, cubiertos. [PENDIENTE] Decir en el video los supuestos: no interferencia entre usuarios y mismo periodo. |
| H10 | Recomendación sí/no y "falta evidencia" concreta | Cumple | — |

Fuera de la lista: `04_Presentaciones/` y `08_Entregables/` siguen vacíos (guion,
slides y video; P6.1 a P6.4).
