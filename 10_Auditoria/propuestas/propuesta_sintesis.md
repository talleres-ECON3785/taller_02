# Propuesta A: corrección de `05_Notas/sintesis.md`

Estado: **propuesta, sin aplicar**. Reemplaza las secciones indicadas de la síntesis.
Todas las cifras salen de `10_Auditoria/salidas/aud_02_*`, `aud_03_*` y `aud_04_*`.
Cuando se apruebe la propuesta B, las cifras se citarán desde
`03_Resultados/{Tablas,Figuras}/13_focalizacion_experimento/`, porque una nota solo
cita lo que está en `03_Resultados/`. Los porcentajes usan `exp(τ) − 1`.

---

## Recomendación (P5.2) — reemplaza la sección completa

> **Escalar el registro facilitado para todos los usuarios, salvo los que entran
> desde un celular con Windows u otro sistema operativo (35% de la base histórica).
> A esos usuarios se les mantiene el formulario actual.**

**Estimando (H1).** El estimando es el efecto causal del registro facilitado sobre
`ln(Revenue)` en cada grupo de usuarios definido por dispositivo × sistema operativo
(CATE por celda). Se lee como el cambio porcentual del gasto del usuario típico del
grupo, `exp(τ) − 1`. **Complemento etiquetado:** el mismo efecto en dólares por
usuario, que dice cuánto pesa cada grupo en el ingreso total. La regla es la misma en
las dos escalas: los grupos que se excluyen son los únicos con efecto negativo
distinguible de cero, y es negativo en log y en dólares. Ningún grupo que se trata
tiene efecto negativo en ninguna escala.

### Decisión respaldada

| Evidencia | Cifra (escala, base) |
| --- | --- |
| Hay heterogeneidad y no es un artefacto del método | Calibración de las diferencias 1.01 (p < 0.001); AUTOC 0.200 en log con muestra dividida (experimento, mitad de evaluación, n = 5,000) |
| Celular–Windows: el registro facilitado baja el gasto | −22.5% [−24.5%; −20.4%]; −0.67 dólares [−0.77; −0.56]; 29.9% de la base histórica |
| Celular–otro SO: lo baja | −19.4% [−24.2%; −14.3%]; −0.61 dólares [−0.85; −0.36]; 5.0% |
| Computador–osx, tableta–osx: lo suben mucho | +44.5% [+38.7%; +50.5%] y +35.0% [+25.1%; +45.6%]; +2.59 y +1.93 dólares; 15.0% de la base |
| Computador–Windows y celular–osx: lo suben poco | +8.0% [+5.0%; +11.1%] y +7.6% [+3.8%; +11.6%]; +0.61 y +0.54 dólares; 39.2% |
| Computador–otro, tableta–Windows: sin efecto distinguible en log | +7.4% [−0.3%; +15.6%] y +5.8% [−0.2%; +12.0%]; en dólares +0.36 [−0.01; 0.73] y +0.39 [0.13; 0.65]; 9.9%. Se tratan porque no hay evidencia de daño en ninguna escala |
| La regla se elige en una mitad y se evalúa en la otra (Lab 10) | La mitad de entrenamiento elige exactamente esta regla. En la de evaluación, con un bosque independiente, sube el gasto del usuario típico de la población ≈ +10.2% (dar el registro a todos: +0.8%; solo a computador y tableta: +8.7%). En dólares, 0.66 por usuario (todos: 0.42; computador y tableta: 0.58) |
| Ventaja sobre "solo computador y tableta" | Es el efecto en celular–osx en la mitad de evaluación: +9.3% [+3.7%; +15.1%]; +0.50 dólares [0.21; 0.80]; ponderado por su peso (15.2%), +0.076 dólares por usuario (ee 0.023) |
| Los grupos pesan lo mismo en la población de CheMarket | Experimento frente a base histórica, celda por celda (p. ej. celular–Windows 29.7% frente a 29.9%); prueba conjunta F = 0.66, p = 0.708 |
| El experimento es válido | Balance F = 0.96, p = 0.456; cumplimiento perfecto (5,043 / 4,957) |

**Por qué dispositivo × sistema operativo.** En `ln(Revenue)` el efecto es aditivo en
las dos características (las triples interacciones de `feols` con HC1 son ≈ 0): 0.41
en log para computador–osx (+50%), menos 0.31 si es celular y menos 0.35 si no es
osx. Por eso celular–Windows queda en −0.25 (−22%). El sistema
operativo separa tanto como el dispositivo: no se puede omitir. Además, el sistema
operativo **no** se traslapa con el dispositivo: dentro de cada dispositivo ≈ 30% es
osx, 10% otro y 60% Windows. Las dos variables son observables cuando el usuario
entra, antes de ver el formulario.

**Por qué no por sesiones anteriores.** La regla elegida por dispositivo × sesiones
vale menos en la mitad de evaluación (0.54 dólares frente a 0.66). Los celulares tienen
efecto negativo en log en los tres tramos de sesiones. Las tableta con 5 o más
sesiones son muy pocas (71 / 83 por mitad) y no sostienen ninguna conclusión.

**Celdas pequeñas.** Tableta–otro SO tiene 84 usuarios (45 / 39 por mitad). Sobre ella
no se concluye nada; la regla la trata porque en ninguna escala hay evidencia de daño.

### Complemento predictivo — reemplaza "a quién priorizar dentro de la regla"

La base histórica no dice qué hace el registro facilitado; sí dice quién gasta más.
El árbol y el bosque predicen el gasto sobre todo con el tiempo en el sitio y las
sesiones anteriores. En `ln(Revenue)`, la escalera de validación cruzada atribuye al
corte de 5 minutos el 60% de la caída del error, a las sesiones y su cruce con el
corte el 33%, al dispositivo el 6% y al sistema operativo menos del 1%. Las variables
que predicen **cuánto** gasta un usuario no son las que separan **cómo responde** al
registro facilitado: el sistema operativo casi no predice el gasto, pero cambia el
signo del efecto. Por eso la regla sale del experimento y no de la base histórica.

### Preguntas abiertas (H10) — reemplaza la sección completa

1. **Mecanismo en celulares no osx.** Los datos no explican por qué el mismo
   formulario baja el gasto en celulares Windows u otro y lo sube en celulares osx.
   - **Evidencia que lo resolvería:** una validación focalizada.
   - **Población:** usuarios que entran desde celular con Windows u otro sistema
     operativo.
   - **Brazos:** formulario facilitado frente al actual, con asignación aleatoria
     individual.
   - **Métrica principal:** `ln(Revenue)` por usuario; complemento: ingreso en
     dólares.
   - **Tamaño de referencia:** en el experimento actual ese grupo tuvo 3,489
     usuarios. Solo con la mitad de evaluación (1,762), el error estándar de su
     efecto en log fue 0.017.
   - **Qué cambiaría la regla:** si el efecto resulta ≥ 0 con un intervalo que
     descarte una caída, se extiende a todos (el ATE en dólares de darlo a todos es
     positivo). Si sale negativo, como estima el bosque (−22.5% en celular–Windows),
     se confirma la exclusión.
2. **Estabilidad en el tiempo.** El experimento es de un solo periodo. La regla se
   sostiene si la diferencia por dispositivo × sistema operativo se mantiene; la misma
   validación lo comprueba en otro periodo.

---

## Tabla de conclusiones (P5.1) — filas que cambian

### Parte A

| Conclusión | Taller 1 | Taller 2 | Se mantiene / matiza / cambia | Atribución |
| --- | --- | --- | --- | --- |
| Error de predicción fuera de muestra | RMSE 2.314 dólares (14.8% menos que la media, 2.716) | Lineal con corte y cruce 1.845; LASSO 1.765; árbol 1.627 y bosque 1.626 (40.1%); en log, árbol 0.349 frente a 0.361 de LASSO | Cambia | **Especificación y método.** De los 0.687 dólares que se ganan frente al lineal del Taller 1, el corte y el cruce dan 0.469 (68%), el diccionario de LASSO 0.080 (12%) y el árbol 0.138 (20%). El árbol llega a la misma especificación por sí solo, con las variables crudas y solo con entrenamiento, así que el reparto depende del camino. La transformación es neutra en los árboles (1.627 al retransformar) y empeora los lineales simples (2.382 y 1.952) |
| Qué variables predicen el gasto | Sin escalera | **Escalera en las dos escalas** (validación cruzada, 5 pliegues de `train`): en log, corte de 5 minutos −0.100 (60% de la caída total), sesiones −0.019, cruce −0.036, dispositivo −0.010, sistema operativo, recurrente y registro < 0.001. Mismo orden que en dólares y que la importancia del bosque | Matiza (se cuantifica) | Método (importancia) y especificación (escalera) |

### Parte B

| Conclusión | Taller 1 | Taller 2 | Se mantiene / matiza / cambia | Atribución |
| --- | --- | --- | --- | --- |
| Por qué las dos escalas difieren | Sin conciliar | Los efectos por grupo tienen signo opuesto y se cancelan en log (Σ peso × τ = 0.004; identidad exacta del ATE). En dólares quedan positivos por dos razones: los grupos con efecto positivo gastan algo más (4.16 frente a 3.64 dólares de base), y dentro de cada grupo el tratamiento sube la media más que el gasto típico. De 0.39 dólares (usuarios en celdas con n ≥ 100), los efectos proporcionales por dispositivo × SO explican 0.15; al partir también por sesiones, 0.22; quedan 0.17 dentro de las celdas finas | Cambia (queda conciliado) | **Ambos.** Método: la heterogeneidad de signo entre grupos. Transformación: el gasto base distinto entre grupos y, como mucho, los 0.17 dólares que quedan dentro de las celdas finas (cota superior: pueden incluir heterogeneidad por otras variables, como el tiempo en el sitio) |
| ¿El efecto es igual para todos? | Un solo efecto | Evidencia formal de HTE. Por dispositivo × SO: −22.5% en celular–Windows y −19.4% en celular–otro; de +5.8% a +44.5% en las demás celdas grandes | Cambia | Método |
| Recomendación | "Todavía no" escalar (criticada por la H10) | Escalar para todos salvo celulares Windows u otro; valor evaluado fuera de la muestra de selección | Cambia | Método (CATE). La regla es la misma en log y en dólares |

## Frases a eliminar de la síntesis y de las notas del 12

- "osx es de computadores y tabletas" (síntesis y `B_cate_por_grupo.md`): falsa. El SO
  es casi independiente del dispositivo.
- "Casi dos tercios de la ganancia vienen de la especificación; el resto, del método
  (1.765 → 1.627)": el tramo 1.765 → 1.627 es el 20%, no un tercio.
- "lo baja entre 9% y 15%", "una caída de alrededor de 25%" y similares: pasar a
  `exp(τ) − 1` (p. ej. −0.257 → −22.7%; −0.152 → −14.1%).
- "Orden de magnitud de la regla (aritmética … sin intervalo)": se reemplaza por el
  valor evaluado en la mitad de evaluación.
