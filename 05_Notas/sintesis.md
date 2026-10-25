# Síntesis del Taller 2: qué se mantiene, qué se matiza y qué cambia frente al Taller 1

- **Estado:** vigente (P5.1 y P5.2 de `PLAN.md`; la lista de chequeo P5.3 sigue pendiente)
- **Fuentes:** solo las notas de `05_Notas/` y las tablas y figuras que esas notas
  citan en `03_Resultados/`. Esta síntesis no agrega estimaciones nuevas.
- **Última verificación:** 2026-10-25

## Recomendación (P5.2)

> **Escalar el registro facilitado solo para los usuarios que entran desde
> computador o tableta, y no para los que entran desde celular.**

**Estimando que guía la decisión.** La recomendación se apoya en el efecto
causal del registro facilitado (ITT) **por grupo** (CATE). El efecto en dólares
es el que pesa en el ingreso total. El efecto en logaritmo indica si al usuario
típico del grupo le va mejor o peor. En la regla elegida las dos escalas
coinciden: positivas en computador y tableta, negativas en celular.

### Decisión respaldada

| Evidencia | Cifra (escala, base) | Nota |
| --- | --- | --- |
| Hay heterogeneidad y no es un artefacto del método: calibración y muestra dividida | Calibración de las diferencias 1.01 en log y 1.06 en dólares (p < 0.001); AUTOC 0.200 en log y 1.41 dólares (experimento, mitad de evaluación, n = 5,000) | [B_evidencia_hte](12_heterogeneidad_experimento/B_evidencia_hte.md), [X_hte_nivel_vs_log](12_heterogeneidad_experimento/X_hte_nivel_vs_log.md) |
| Computador: efecto positivo | +0.163 en log (IC 0.140 a 0.186); +1.18 dólares (1.03 a 1.34); 40.0% de la base histórica | [B_cate_por_grupo](12_heterogeneidad_experimento/B_cate_por_grupo.md) |
| Tableta: efecto positivo | +0.138 en log (0.093 a 0.183); +0.88 dólares (0.62 a 1.14); 9.9% de la base | ídem |
| Celular: efecto negativo | −0.152 en log (−0.173 a −0.131); −0.30 dólares (−0.40 a −0.20); 50.1% de la base | ídem |
| El dispositivo es lo que más usa el bosque causal para separar efectos | 61% de los cortes, en log (dónde corta, no qué causa la diferencia) | ídem |
| Los grupos del experimento pesan lo mismo en la población de CheMarket | Celular 50.1% frente a 49.8%; prueba conjunta F = 0.66, p = 0.708 | [B_representatividad_experimento](06_ate_experimento_niveles/B_representatividad_experimento.md) |
| El experimento es válido | Balance F = 0.96, p = 0.456; cumplimiento perfecto (5,043 / 4,957) | [B_balance_y_cumplimiento](06_ate_experimento_niveles/B_balance_y_cumplimiento.md) |

El dispositivo se elige como regla porque es la característica que más separa los
efectos, sus intervalos están lejos de cero en las dos escalas y CheMarket la
conoce cuando el usuario entra, antes de mostrarle el formulario de registro. El
sistema operativo apunta en la misma dirección (osx +0.213 en log y +1.50 dólares;
Windows −0.089 en log y −0.05 dólares). No se agrega a la regla porque se traslapa
con el dispositivo (osx es de computadores y tabletas) y en Windows el efecto en
dólares no se distingue de cero.

**Orden de magnitud de la regla** (aritmética con las cifras de la tabla
anterior; no es una estimación exportada y no tiene intervalo). Con los pesos de
la base histórica, dar el registro facilitado a todos promedia 0.40 × 1.18 + 0.50
× (−0.30) + 0.10 × 0.88 ≈ 0.41 dólares por usuario. La cifra coincide con el ATE
del bosque (0.414). Dárselo solo a computador y tableta deja a los usuarios de
celular sin cambio: ≈ 0.40 × 1.18 + 0.10 × 0.88 ≈ 0.56 dólares por usuario. La
regla evita la pérdida de unos 0.15 dólares por usuario que hoy se concentra en
la mitad de la base.

### Complemento predictivo: a quién priorizar dentro de la regla

La base histórica no dice qué hace el registro facilitado. Sí dice quién gasta
más, y eso sirve para ordenar la implementación.

- El árbol y el bosque predicen el gasto sobre todo con el **tiempo en el sitio y
  las sesiones anteriores**. Esas dos variables suman 93% de la importancia por
  permutación en dólares y 94.5% en logaritmo. El dispositivo y el sistema
  operativo aportan poco a la predicción del nivel de gasto: 2.2% y 4.7% en
  dólares ([A_importancia_bosque](10_bosque_observacional/A_importancia_bosque.md)).
  Las variables que predicen **cuánto** gasta un usuario no son las que separan
  **cómo responde** al registro facilitado. Por eso la regla sale del bosque
  causal y no del predictivo.
- El árbol de predicción separa a los usuarios de gasto alto con el corte de 5
  minutos y 3 o más sesiones
  ([A_cart_recupera_corte_5_min](09_arboles_observacional/A_cart_recupera_corte_5_min.md)).
  En esos usuarios, el efecto causal en dólares es mayor:
  - más de 5 minutos: 0.84 dólares frente a 0.16;
  - 5 o más sesiones: 1.28 dólares frente a −0.19 con 0 a 2 sesiones
    ([X_hte_nivel_vs_log](12_heterogeneidad_experimento/X_hte_nivel_vs_log.md)).

  La segmentación predictiva sirve para priorizar, dentro de computador y tableta,
  a los usuarios frecuentes, donde cada usuario aporta más dólares.
- El registro (`sign_up`) casi no aporta a la predicción: 0.03% de la importancia
  del bosque y −0.00001 dólares en la escalera lineal. Esto no dice nada sobre su
  efecto. El efecto lo mide el experimento.

### Preguntas abiertas (qué evidencia, sobre esta misma decisión, la cambiaría)

1. **Ingreso de la regla frente a darlo a todos.** No se estimó con su intervalo.
   La aritmética de arriba lo aproxima. La evidencia que falta es una
   **validación focalizada**:
   - población: usuarios de celular;
   - brazos: registro facilitado frente a control;
   - métrica: ingreso en dólares por usuario.

   Si el efecto en celular resulta mayor o igual a cero, la recomendación pasa a
   escalar para todos, porque el ATE en dólares es positivo (0.49). Si sale
   negativo, como estima el bosque (−0.30 dólares), se confirma la regla.
2. **Multiplicidad.** Son 13 grupos en dos escalas y no hay corrección. Los
   intervalos de dispositivo están lejos de cero, así que la corrección no cambia
   la regla. Sí puede cambiar la lectura de los grupos con intervalos cerca de
   cero (Windows y otro sistema en dólares, recurrentes en log).
3. **Mecanismo.** No se sabe por qué el formulario simplificado baja el gasto en
   celular. La regla se sostiene solo si la diferencia por dispositivo se mantiene
   fuera del periodo del experimento.

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
| El gasto da un salto en 5 minutos en el sitio | Salto ≈ 3.13 dólares, confirmado fuera de muestra | Salto y gasto plano a cada lado; el árbol encuentra solo el corte (5.0007 min) en las dos escalas | Se mantiene | — (el método lo recupera sin que se le indique) | [A_quiebre_time_spent](03_punto_partida/A_quiebre_time_spent.md), [A_cart_recupera_corte_5_min](09_arboles_observacional/A_cart_recupera_corte_5_min.md) |
| El tiempo entra de forma continua (elasticidad ≈ 0.169) | Tiempo lineal en el modelo | Con el corte incluido, el tiempo exacto no reduce el error | Cambia | Especificación | [A_corte_5_minutos_captura_tiempo](04_prediccion_lineal_observacional/A_corte_5_minutos_captura_tiempo.md) |
| Las sesiones anteriores se suman de forma independiente | Término lineal | Solo se asocian con más gasto pasados los 5 minutos (cruce); el árbol parte por sesiones solo de ese lado | Cambia | Especificación y método | [A_sesiones_pasadas_interaccion_tiempo](03_punto_partida/A_sesiones_pasadas_interaccion_tiempo.md), [A_cart_recupera_corte_5_min](09_arboles_observacional/A_cart_recupera_corte_5_min.md) |
| Error de predicción fuera de muestra | RMSE 2.314 dólares (14.8% menos que la media, 2.716) | Lineal con corte y cruce 1.845; LASSO 1.765; árbol 1.627 y bosque 1.626 (40.1%); en log, árbol 0.349 frente a 0.361 de LASSO | Cambia | Casi dos tercios de la ganancia vienen de la especificación; el resto, del método (1.765 → 1.627). La transformación es neutra en los árboles (1.627 al retransformar) y empeora los lineales simples (2.382 y 1.952) | [X_rmse_metodo_por_escala](11_comparacion_prediccion_observacional/X_rmse_metodo_por_escala.md), [A_lineal_flexible_vs_taller1](04_prediccion_lineal_observacional/A_lineal_flexible_vs_taller1.md), [A_lasso_vs_lineal_flexible](05_lasso_observacional/A_lasso_vs_lineal_flexible.md) |
| Qué variables predicen el gasto | Sin escalera ni importancia | Tiempo y sesiones (con su cruce) concentran casi toda la caída del error y más del 90% de la importancia del bosque en las dos escalas; dispositivo, sistema operativo, recurrente y registro aportan poco | Matiza (se cuantifica) | Método (importancia por permutación) | [A_escalera_importancia_lineal](04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md), [A_importancia_bosque](10_bosque_observacional/A_importancia_bosque.md) |
| Registro y gasto en la base histórica | Asociación 0.080 en log con controles (no causal) | El registro no reduce el error una vez incluidas las demás variables (−0.00001 dólares; 0.03% de importancia) | Matiza | Método y especificación | [A_escalera_importancia_lineal](04_prediccion_lineal_observacional/A_escalera_importancia_lineal.md), [A_importancia_bosque](10_bosque_observacional/A_importancia_bosque.md) |
| Forma de la distribución | Cola alta en dólares | El logaritmo comprime la cola; la media en dólares no se recupera con exp() sin un factor de corrección | Matiza | Transformación | [X_distribucion_dolares_vs_logaritmo](07_forma_funcional_observacional/X_distribucion_dolares_vs_logaritmo.md) |

### Parte B: efecto del registro facilitado (experimento, causal)

| Conclusión | Taller 1 | Taller 2 | Se mantiene / matiza / cambia | Atribución | Nota |
| --- | --- | --- | --- | --- | --- |
| Validez del experimento | Balance (sin `os_type`) y cumplimiento perfecto | Balance con `os_type`: F = 0.96, p = 0.456; cumplimiento 5,043 / 4,957 | Se mantiene | — | [B_balance_y_cumplimiento](06_ate_experimento_niveles/B_balance_y_cumplimiento.md) |
| Representatividad frente a la base histórica | F = 0.65, p = 0.712 | F = 0.66, p = 0.708 (especificación del balance) | Se mantiene | — | [B_representatividad_experimento](06_ate_experimento_niveles/B_representatividad_experimento.md) |
| Efecto promedio en dólares | ITT 0.49 (p = 1.8e-11) | MCO 0.491 (IC 0.347 a 0.634) y 0.454 con controles; bosque 0.414 (0.328 a 0.499) | Se mantiene | — | [B_ols_efecto_registro](06_ate_experimento_niveles/B_ols_efecto_registro.md), [X_hte_nivel_vs_log](12_heterogeneidad_experimento/X_hte_nivel_vs_log.md) |
| Efecto promedio en log | 0.0134, no distinguible de cero | 0.0134 (−0.010 a 0.037); bosque 0.004 (−0.011 a 0.019) | Se mantiene | — | [B_log_a_dolares_efecto_registro](08_ate_experimento_log/B_log_a_dolares_efecto_registro.md), [B_evidencia_hte](12_heterogeneidad_experimento/B_evidencia_hte.md) |
| Por qué las dos escalas difieren | Sin conciliar | El tratamiento ensancha la distribución (desviación de `ln(Revenue)` de 0.53 a 0.66): la media sube 12% y la mediana no cambia | Cambia (queda conciliado) | Transformación | [B_log_a_dolares_efecto_registro](08_ate_experimento_log/B_log_a_dolares_efecto_registro.md) |
| ¿El efecto es igual para todos? | Un solo efecto | Evidencia formal de HTE; efectos de signo opuesto (computador, tableta, osx y 3 o más sesiones positivos; celular, Windows, nuevos y 0 a 2 sesiones negativos) | Cambia | Método | [B_evidencia_hte](12_heterogeneidad_experimento/B_evidencia_hte.md), [B_cate_por_grupo](12_heterogeneidad_experimento/B_cate_por_grupo.md) |
| Hipótesis de que el efecto en dólares viene de pocos usuarios de la cola | Sugerida (p99: 14.4 frente a 24.9) | Hay heterogeneidad en las dos escalas con el mismo orden de grupos; en dólares se agranda en los usuarios de mayor gasto | Matiza | Método (existencia) y transformación (tamaño en dólares) | [X_hte_nivel_vs_log](12_heterogeneidad_experimento/X_hte_nivel_vs_log.md) |
| Recomendación | "Todavía no" escalar (criticada por la H10) | Escalar solo en computador y tableta | Cambia | Método (CATE), con apoyo de la transformación (dólares frente a log) | Esta nota |

## Límites de la síntesis
- Predicción no es causalidad. Las conclusiones de la Parte A describen quién
  gasta más, no qué palanca mueve el gasto. Solo la Parte B sostiene afirmaciones
  causales.
- Cada cifra conserva los límites de su nota de origen: una sola partición en la
  Parte A, cuantiles sin intervalos y grupos sin corrección por multiplicidad en la
  Parte B.
- Falta pasar la lista de chequeo H1–H10 (P5.3) sobre la presentación.

## Historial
- 2026-10-25: primera versión (P5.1 y P5.2). La recomendación se alinea con los
  CATE del bosque causal y se complementa con los bosques predictivos, por
  decisión del usuario.
