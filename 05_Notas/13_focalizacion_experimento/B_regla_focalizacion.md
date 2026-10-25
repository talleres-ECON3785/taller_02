# Dar el registro facilitado a todos salvo los celulares con Windows u otro sistema operativo sube el gasto del usuario típico ≈ 10%, frente a ≈ 1% de dárselo a todos

- **Estado:** vigente
- **Parte / base:** B; experimento; causal (efecto por grupo dispositivo × sistema
  operativo y valor de reglas evaluadas fuera de la muestra de selección)
- **Script de origen:** `02_Scripts/13_focalizacion_experimento.R`
- **Última verificación:** 2026-10-25, con `13_focalizacion_experimento.R`

## Evidencia

Experimento, n = 10,000. Bosque causal de 2,000 árboles, con la probabilidad de
asignación fija en la proporción tratada. El efecto de cada grupo se estima con el
promedio doblemente robusto de los efectos individuales del grupo. Porcentajes:
`exp(τ) − 1`, el cambio del gasto del usuario típico.

**Efecto por grupo, muestra completa**
(`03_Resultados/Tablas/13_focalizacion_experimento/experimento_efecto_celdas_dispositivo_so.png`
y `.csv`; figura del mismo nombre en `03_Resultados/Figuras/13_focalizacion_experimento/`):

| Grupo | n (entren. / eval.) | % base hist. | Gasto típico | Dólares | ¿Recibe el registro facilitado? |
| --- | --- | --- | --- | --- | --- |
| Computador–osx | 1,213 (614 / 599) | 12.0 | +44.5% [+38.7%; +50.5%] | +2.59 [2.23; 2.96] | Sí |
| Tableta–osx | 312 (165 / 147) | 3.0 | +35.0% [+25.1%; +45.6%] | +1.93 [1.30; 2.56] | Sí |
| Computador–Windows | 2,418 (1,223 / 1,195) | 24.0 | +8.0% [+5.0%; +11.1%] | +0.61 [0.44; 0.77] | Sí |
| Celular–osx | 1,486 (746 / 740) | 15.2 | +7.6% [+3.8%; +11.6%] | +0.54 [0.31; 0.77] | Sí |
| Computador–otro SO | 398 (189 / 209) | 4.0 | +7.4% [−0.3%; +15.6%] | +0.36 [−0.01; 0.73] | Sí |
| Tableta–Windows | 600 (291 / 309) | 5.9 | +5.8% [−0.2%; +12.0%] | +0.39 [0.13; 0.65] | Sí |
| Tableta–otro SO * | 84 (45 / 39) | 1.0 | +12.3% [−3.4%; +30.6%] | +0.44 [−0.24; 1.13] | Sí |
| Celular–otro SO | 516 (264 / 252) | 5.0 | −19.4% [−24.2%; −14.3%] | −0.61 [−0.85; −0.36] | No |
| Celular–Windows | 2,973 (1,463 / 1,510) | 29.9 | −22.5% [−24.5%; −20.4%] | −0.67 [−0.77; −0.56] | No |

\* Menos de 100 usuarios en alguna mitad: no sostiene conclusiones de focalización.

La regresión saturada por grupo (MCO con errores HC1, columna de la misma tabla)
da el mismo signo en los 8 grupos grandes.

**Reglas elegidas en una mitad y evaluadas en la otra**
(`03_Resultados/Tablas/13_focalizacion_experimento/experimento_valor_reglas.png` y `.csv`).
Mitad de evaluación, n = 5,000. Valor por usuario de la base histórica frente a no
dar el registro facilitado a nadie:

| Regla | % base | Gasto típico | Dólares |
| --- | --- | --- | --- |
| Todos los usuarios | 100.0 | +0.8% [−1.3%; +2.9%] | 0.416 [0.296; 0.535] |
| **Todos salvo celulares con Windows u otro SO** | 65.1 | **+10.2% [+8.4%; +12.0%]** | **0.657 [0.547; 0.766]** |
| Solo computador y tableta | 49.9 | +8.7% [+7.1%; +10.3%] | 0.578 [0.479; 0.678] |
| Elegida en entrenamiento: dispositivo × SO | 64.1 | +10.1% [+8.3%; +11.9%] | 0.653 [0.544; 0.761] |
| Elegida en entrenamiento: dispositivo × sesiones | 48.0 / 57.1 | +8.2% (elegida con log) | 0.535 (elegida con dólares) |
| Solo 3 o más sesiones | 57.7 | +3.8% [+2.2%; +5.4%] | 0.470 [0.360; 0.580] |

Diferencias, medidas solo en los grupos en que difieren dos reglas (mitad de
evaluación):

- recomendada − solo computador y tableta (celular–osx, 15.2%): +1.4% [+0.6%;
  +2.2%] y +0.076 dólares [0.031; 0.121];
- todos − recomendada (celulares con Windows u otro, 34.9%): −8.4% [−9.5%; −7.4%] y
  −0.235 dólares [−0.279; −0.192].

La mitad de entrenamiento elige exactamente los grupos de la regla recomendada
(salvo tableta–otro, que se excluye de la elección por tamaño).

## Qué dice, en lenguaje intuitivo

El estimando es el efecto del registro facilitado sobre el gasto del usuario
típico de cada grupo de dispositivo y sistema operativo. El dato en dólares es un
complemento que dice cuánto pesa cada grupo en el ingreso. En siete de los nueve
grupos el registro facilitado sube el gasto o no lo cambia. En los celulares con
Windows (30% de la base) y con otro sistema (5%) lo baja cerca de 20%, en las dos
escalas.

Para no engañarse eligiendo los grupos con los mismos datos con que se miden, el
experimento se partió en dos mitades. Con una se eligió a quién darle el registro
facilitado; con la otra, que no participó en la elección, se midió cuánto vale
esa decisión. Dárselo a todos menos a esos celulares sube el gasto del usuario
típico de la base cerca de 10% y deja 0.66 dólares por usuario. Dárselo a todos
deja 0.42 dólares y casi no mueve el gasto típico (+0.8%). Excluir también a los
celulares con osx, como proponía la versión anterior de la regla ("solo
computador y tableta"), deja 0.58 dólares: esos celulares sí responden al registro
facilitado.

## Por qué importa en el estudio

Responde a la Parte B: "¿qué características identifican grupos distintos?",
"¿hay grupos con efecto mayor, menor o cercano a cero?" y "¿qué implicaciones
tiene para CheMarket?". **Cambia** respecto al Taller 1, que solo tenía un efecto
promedio, y la diferencia se atribuye al **método**. La regla es la misma en las
dos escalas: los únicos grupos con daño distinguible lo tienen en logaritmo y en
dólares. Esta nota reemplaza, para la recomendación, la regla por dispositivo de
`B_cate_por_grupo.md`: el sistema operativo separa tanto como el dispositivo y no
se traslapa con él.

## Límites e incertidumbre

- Un solo experimento y un solo periodo. La regla se sostiene si la diferencia por
  dispositivo × sistema operativo se mantiene fuera del periodo del experimento.
- No se sabe por qué el formulario baja el gasto en celulares con Windows u otro
  sistema. Va a "Preguntas abiertas" de la síntesis, con la validación focalizada
  que lo resolvería.
- Computador–otro y tableta–Windows no tienen efecto distinguible de cero en
  logaritmo. Se tratan porque no hay evidencia de daño; su aporte es incierto.
- Tableta–otro (84 usuarios) no sostiene ninguna conclusión.
- El valor de una regla usa los pesos de la base histórica. El experimento es
  representativo de esa base (F = 0.66, p = 0.708).

## Historial

- 2026-10-25: primera versión, a partir de la auditoría
  (`10_Auditoria/informe_auditoria.md`) y del script 13, aprobado por el usuario.
