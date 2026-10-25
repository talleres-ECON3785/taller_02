# Síntesis del Taller 2: qué se mantiene, qué se matiza y qué cambia frente al Taller 1

- **Estado:** vigente (P5.1 y P5.2 de `PLAN.md`; la lista de chequeo P5.3 está en
  `10_Auditoria/respuestas_enunciado.md`)
- **Fuentes:** las notas de `05_Notas/` y las tablas y figuras que esas notas
  citan en `03_Resultados/`. Esta síntesis no agrega estimaciones nuevas.
- **Última verificación:** 2026-10-25, con `12_heterogeneidad_experimento.R` y
  `13_focalizacion_experimento.R`
- **Porcentajes:** los efectos en logaritmo se leen como `exp(τ) − 1`, el cambio
  porcentual del gasto del usuario típico.

## Recomendación (P5.2)

> **Escalar el registro facilitado para todos los usuarios, salvo los que entran
> desde un celular con Windows u otro sistema operativo (35% de la base
> histórica). A esos usuarios se les mantiene el formulario actual.**

**Estimando (H1).** El estimando es el efecto causal del registro facilitado
sobre `ln(Revenue)` en cada grupo de usuarios definido por dispositivo × sistema
operativo (CATE por grupo). Se lee como el cambio porcentual del gasto del
usuario típico del grupo. **Complemento etiquetado:** el mismo efecto en dólares
por usuario, que dice cuánto pesa cada grupo en el ingreso total.

**Criterio de la regla.** Se excluye solo donde hay daño distinguible de cero en
las dos escalas. Los dos grupos excluidos son los únicos con efecto negativo
distinguible, y lo es en logaritmo y en dólares. Ningún grupo tratado tiene
efecto negativo en ninguna escala, así que la regla es la misma en las dos.

### Decisión respaldada

Fuente: `03_Resultados/Tablas/13_focalizacion_experimento/` y
`03_Resultados/Figuras/13_focalizacion_experimento/experimento_efecto_celdas_dispositivo_so.png`
(experimento, n = 10,000), salvo donde se indica otra.

| Evidencia | Cifra (escala, base) | Nota |
| --- | --- | --- |
| Hay heterogeneidad y no es un artefacto del método | Calibración de las diferencias 1.01 (p < 0.001); AUTOC 0.200 en log con muestra dividida (mitad de evaluación, n = 5,000) | [B_evidencia_hte](12_heterogeneidad_experimento/B_evidencia_hte.md) |
| Celular–Windows: el registro facilitado baja el gasto | −22.5% [−24.5%; −20.4%]; −0.67 dólares [−0.77; −0.56]; 29.9% de la base histórica | [B_regla_focalizacion](13_focalizacion_experimento/B_regla_focalizacion.md) |
| Celular–otro SO: lo baja | −19.4% [−24.2%; −14.3%]; −0.61 dólares [−0.85; −0.36]; 5.0% | ídem |
| Computador–osx y tableta–osx: lo suben mucho | +44.5% [+38.7%; +50.5%] y +35.0% [+25.1%; +45.6%]; +2.59 y +1.93 dólares; 15.0% de la base | ídem |
| Computador–Windows y celular–osx: lo suben poco | +8.0% [+5.0%; +11.1%] y +7.6% [+3.8%; +11.6%]; +0.61 y +0.54 dólares; 39.2% | ídem |
| Computador–otro y tableta–Windows: sin efecto distinguible en log | +7.4% [−0.3%; +15.6%] y +5.8% [−0.2%; +12.0%]; en dólares +0.36 [−0.01; 0.73] y +0.39 [0.13; 0.65]; 9.9%. Se tratan porque no hay evidencia de daño en ninguna escala | ídem |
| La regla se elige en una mitad y se evalúa en la otra (Lab 10) | La mitad de entrenamiento elige exactamente estos grupos. En la mitad de evaluación, con un bosque independiente, el gasto del usuario típico de la población sube +10.2% [+8.4%; +12.0%] (todos: +0.8%; solo computador y tableta: +8.7%). En dólares, 0.66 por usuario [0.55; 0.77] (todos: 0.42; computador y tableta: 0.58) | ídem (`experimento_valor_reglas`) |
| Ventaja sobre "solo computador y tableta" | El efecto en celular–osx en la mitad de evaluación, por su peso (15.2%): +1.4% [+0.6%; +2.2%] del gasto típico; +0.076 dólares por usuario [0.031; 0.121] | ídem |
| Los grupos pesan lo mismo en la población de CheMarket | Prueba conjunta experimento frente a base histórica F = 0.66, p = 0.708 | [B_representatividad_experimento](06_ate_experimento_niveles/B_representatividad_experimento.md) |
| El experimento es válido | Balance F = 0.96, p = 0.456; cumplimiento perfecto (5,043 / 4,957) | [B_balance_y_cumplimiento](06_ate_experimento_niveles/B_balance_y_cumplimiento.md) |

**Por qué dispositivo × sistema operativo.** El sistema operativo separa tanto
como el dispositivo, y no se traslapa con él: dentro de cada dispositivo, cerca de
30% de los usuarios usa osx, 10% otro sistema y 60% Windows. En logaritmo el
efecto se comporta como la suma de las dos características: es menor en celular y
menor fuera de osx, y en celular con Windows u otro sistema se vuelve negativo.
Las dos características son observables cuando el usuario entra, antes de ver el
formulario.

**Por qué no por sesiones anteriores.** La regla que elige la mitad de
entrenamiento por dispositivo × sesiones vale menos en la mitad de evaluación
(0.54 dólares frente a 0.66). En celular, el efecto en logaritmo es negativo en
los tres tramos de sesiones (`experimento_efecto_celdas_dispositivo_sesiones`).

**Grupos pequeños.** Tableta–otro sistema tiene 84 usuarios (45 / 39 por mitad).
De ese grupo no se concluye nada. La regla lo trata porque no hay evidencia de
daño en ninguna escala.

### Complemento predictivo: qué predice el gasto no es lo que separa el efecto

La base histórica no dice qué hace el registro facilitado; sí dice quién gasta
más. El árbol y el bosque predicen el gasto sobre todo con el tiempo en el sitio y
las sesiones anteriores ([A_importancia_bosque](10_bosque_observacional/A_importancia_bosque.md)).
En `ln(Revenue)`, la escalera de validación cruzada atribuye el 60% de la caída del
error al corte de 5 minutos, el 33% a las sesiones y su cruce con el corte, el 6%
al dispositivo y menos del 1% al sistema operativo
([A_escalera_importancia_lineal](04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md)).
El sistema operativo casi no predice cuánto gasta un usuario, pero cambia el signo
de cómo responde al registro facilitado. Por eso la regla sale del experimento y no
de la base histórica. El registro (`sign_up`) tampoco aporta a la predicción: es
0.03% de la importancia del bosque. Eso no dice nada sobre su efecto, que lo mide
el experimento.

### Preguntas abiertas (H10)

1. **Mecanismo en celulares no osx.** Los datos no explican por qué el mismo
   formulario baja el gasto en celulares con Windows u otro sistema y lo sube en
   celulares con osx. La evidencia que lo resolvería es una **validación
   focalizada**:
   - **Población:** usuarios que entran desde celular con Windows u otro sistema
     operativo.
   - **Brazos:** formulario facilitado frente al actual, con asignación aleatoria
     individual.
   - **Métrica principal:** `ln(Revenue)` por usuario; complemento: ingreso en
     dólares.
   - **Tamaño de referencia:** en el experimento actual ese grupo tuvo 3,489
     usuarios; solo con la mitad de evaluación (1,762), el error estándar de su
     efecto en log fue 0.017.
   - **Qué cambiaría la regla:** si el efecto resulta mayor o igual a cero, con un
     intervalo que descarte una caída, se extiende el registro facilitado a todos.
     Si sale negativo, como estima el bosque (−22.5% en celular–Windows), se
     confirma la exclusión.
2. **Estabilidad en el tiempo.** El experimento es de un solo periodo. La regla se
   sostiene si la diferencia por dispositivo × sistema operativo se mantiene; la
   misma validación lo comprueba en otro periodo.

## Tabla de conclusiones (P5.1)

La última columna dice de dónde viene la diferencia con el Taller 1:

- **transformación:** pasar de `Revenue` a `ln(Revenue)`;
- **método:** pasar de regresión lineal a árboles o bosques;
- **especificación:** el lineal con corte y cruce, que mejora sin cambiar de
  método ni de escala;
- **—:** no hay diferencia.

### Parte A: predicción (base observacional, sin lectura causal)

| Conclusión | Taller 1 | Taller 2 | Se mantiene / matiza / cambia | Atribución | Nota |
| --- | --- | --- | --- | --- | --- |
| El gasto da un salto en 5 minutos en el sitio | Salto ≈ 3.13 dólares, confirmado fuera de muestra | Salto y gasto plano a cada lado; el árbol encuentra solo el corte (5.0007 min) en las dos escalas, usando solo entrenamiento | Se mantiene | — (el método lo recupera sin que se le indique) | [A_quiebre_time_spent](03_punto_partida/A_quiebre_time_spent.md), [A_cart_recupera_corte_5_min](09_arboles_observacional/A_cart_recupera_corte_5_min.md) |
| El tiempo entra de forma continua (elasticidad ≈ 0.169) | Tiempo lineal en el modelo | Con el corte incluido, el tiempo exacto no reduce el error, en dólares ni en log | Cambia | Especificación | [A_corte_5_minutos_captura_tiempo](04_prediccion_lineal_observacional/A_corte_5_minutos_captura_tiempo.md) |
| Las sesiones anteriores se suman de forma independiente | Término lineal | Solo se asocian con más gasto pasados los 5 minutos (cruce); el árbol parte por sesiones solo de ese lado | Cambia | Especificación y método | [A_sesiones_pasadas_interaccion_tiempo](03_punto_partida/A_sesiones_pasadas_interaccion_tiempo.md), [A_cart_recupera_corte_5_min](09_arboles_observacional/A_cart_recupera_corte_5_min.md) |
| Dispositivo y sistema operativo | Términos lineales | El árbol en log los usa en 6 de sus 9 cortes: con 5 minutos o menos, el usuario típico de computador gasta +20% que el de celular; con 4 o más sesiones, el de osx +42% que el de Windows u otro | Matiza | Método | [A_cart_recupera_corte_5_min](09_arboles_observacional/A_cart_recupera_corte_5_min.md) |
| Error de predicción fuera de muestra | RMSE 2.314 dólares (14.8% menos que la media, 2.716) | Lineal con corte y cruce 1.845; LASSO 1.765; árbol 1.627 y bosque 1.626 (40.1%); en log, árbol 0.349 frente a 0.361 de LASSO | Cambia | Especificación y método. De los 0.687 dólares que se ganan frente al Taller 1, el corte y el cruce dan 0.469 (68%), el diccionario de LASSO 0.080 (12%) y el árbol 0.138 (20%). El árbol llega a la misma especificación por sí solo, así que el reparto depende del camino. La transformación es neutra en los árboles (1.627 al retransformar) y empeora los lineales simples (2.382 y 1.952) | [X_rmse_metodo_por_escala](11_comparacion_prediccion_observacional/X_rmse_metodo_por_escala.md), [A_lineal_flexible_vs_taller1](04_prediccion_lineal_observacional/A_lineal_flexible_vs_taller1.md), [A_lasso_vs_lineal_flexible](05_lasso_observacional/A_lasso_vs_lineal_flexible.md) |
| Qué variables predicen el gasto | Sin escalera ni importancia | Escalera en las dos escalas: en log, corte de 5 minutos 60% de la caída del error, sesiones y cruce 33%, dispositivo 6%, el resto < 1%. Tiempo y sesiones concentran más del 90% de la importancia del bosque en las dos escalas | Matiza (se cuantifica) | Especificación (escalera) y método (importancia) | [A_escalera_importancia_lineal](04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md), [A_importancia_bosque](10_bosque_observacional/A_importancia_bosque.md) |
| Registro y gasto en la base histórica | Asociación 0.080 en log con controles (no causal) | El registro no reduce el error una vez incluidas las demás variables (−0.00001 dólares; 0.03% de importancia) | Matiza | Método y especificación | [A_escalera_importancia_lineal](04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md), [A_importancia_bosque](10_bosque_observacional/A_importancia_bosque.md) |
| Forma de la distribución | Cola alta en dólares | El logaritmo comprime la cola; la media en dólares no se recupera con exp() sin un factor de corrección | Matiza | Transformación | [X_distribucion_dolares_vs_logaritmo](07_forma_funcional_observacional/X_distribucion_dolares_vs_logaritmo.md) |

### Parte B: efecto del registro facilitado (experimento, causal)

| Conclusión | Taller 1 | Taller 2 | Se mantiene / matiza / cambia | Atribución | Nota |
| --- | --- | --- | --- | --- | --- |
| Validez del experimento | Balance (sin `os_type`) y cumplimiento perfecto | Balance con `os_type`: F = 0.96, p = 0.456; cumplimiento 5,043 / 4,957 | Se mantiene | — | [B_balance_y_cumplimiento](06_ate_experimento_niveles/B_balance_y_cumplimiento.md) |
| Representatividad frente a la base histórica | F = 0.65, p = 0.712 | F = 0.66, p = 0.708 (especificación del balance) | Se mantiene | — | [B_representatividad_experimento](06_ate_experimento_niveles/B_representatividad_experimento.md) |
| Efecto promedio en dólares | ITT 0.49 (p = 1.8e-11) | MCO 0.491 (IC 0.347 a 0.634) y 0.454 con controles; bosque 0.414 (0.330 a 0.498) | Se mantiene | — | [B_ols_efecto_registro](06_ate_experimento_niveles/B_ols_efecto_registro.md), [X_hte_nivel_vs_log](12_heterogeneidad_experimento/X_hte_nivel_vs_log.md) |
| Efecto promedio en log | 0.0134, no distinguible de cero | +1.3% (−1.0% a +3.8%) con MCO; bosque +0.4% (−1.1% a +1.9%) | Se mantiene | — | [B_log_a_dolares_efecto_registro](08_ate_experimento_log/B_log_a_dolares_efecto_registro.md), [B_evidencia_hte](12_heterogeneidad_experimento/B_evidencia_hte.md) |
| Por qué las dos escalas difieren | Sin conciliar | Los efectos por grupo tienen signo opuesto y se cancelan en log: el promedio de los efectos por grupo reproduce el ATE (0.004). En dólares quedan positivos por dos razones. Primera, los grupos con efecto positivo gastan algo más (4.16 frente a 3.64 dólares de base). Segunda, dentro de cada grupo el tratamiento sube la media más que el gasto típico. En los usuarios de grupos finos con 100 o más (9,601), los efectos proporcionales por dispositivo × SO explican 0.15 de 0.39 dólares; al partir también por sesiones, 0.22; quedan 0.17 dentro de los grupos | Cambia (queda conciliado) | **Ambos.** Método: la heterogeneidad de signo entre grupos. Transformación: el gasto base distinto entre grupos y, como mucho, los 0.17 dólares que quedan dentro de los grupos finos (cota superior: pueden incluir diferencias por otras características, como el tiempo en el sitio) | [X_conciliacion_por_celdas](13_focalizacion_experimento/X_conciliacion_por_celdas.md), [B_log_a_dolares_efecto_registro](08_ate_experimento_log/B_log_a_dolares_efecto_registro.md) |
| ¿El efecto es igual para todos? | Un solo efecto | Evidencia formal de HTE. Por dispositivo × SO: −22.5% en celular–Windows y −19.4% en celular–otro; de +5.8% a +44.5% en los demás grupos grandes | Cambia | Método | [B_evidencia_hte](12_heterogeneidad_experimento/B_evidencia_hte.md), [B_regla_focalizacion](13_focalizacion_experimento/B_regla_focalizacion.md) |
| Hipótesis de que el efecto en dólares viene de pocos usuarios de la cola | Sugerida (p99: 14.4 frente a 24.9) | Hay heterogeneidad en las dos escalas con el mismo orden de grupos; en dólares se agranda en los usuarios de mayor gasto | Matiza | Método (existencia) y transformación (tamaño en dólares) | [X_hte_nivel_vs_log](12_heterogeneidad_experimento/X_hte_nivel_vs_log.md) |
| Recomendación | "Todavía no" escalar (criticada por la H10) | Escalar para todos salvo celulares con Windows u otro SO; valor evaluado fuera de la muestra de selección | Cambia | Método (CATE). La regla es la misma en log y en dólares | Esta nota |

## Límites de la síntesis

- Predicción no es causalidad. Las conclusiones de la Parte A describen quién
  gasta más, no qué palanca mueve el gasto. Solo la Parte B sostiene afirmaciones
  causales.
- Cada cifra conserva los límites de su nota de origen: una sola partición en la
  Parte A y cuantiles sin intervalos en la Parte B. La multiplicidad de grupos se
  trata eligiendo la regla en una mitad y evaluándola en la otra (Lab 10), no
  ajustando p-valores.
- La escalera en logaritmo sale del script 04
  (`03_Resultados/Tablas/04_prediccion_lineal_observacional/observacional_escalera_rmse_log.png`).

## Historial

- 2026-10-25: primera versión (P5.1 y P5.2). La recomendación se alinea con los
  CATE del bosque causal y se complementa con los bosques predictivos, por
  decisión del usuario.
- 2026-10-25: corregida tras la auditoría (`10_Auditoria/informe_auditoria.md`),
  con aprobación del usuario.
  - La regla pasa de "solo computador y tableta" a "todos salvo celulares con
    Windows u otro SO", con su valor evaluado fuera de la muestra de selección
    (script 13).
  - Se elimina "osx es de computadores y tabletas", que es falso.
  - La conciliación nivel–log pasa a "ambos" (método y transformación).
  - Se corrige "casi dos tercios" (68%, 12% y 20%).
  - Porcentajes con `exp(τ) − 1`.
