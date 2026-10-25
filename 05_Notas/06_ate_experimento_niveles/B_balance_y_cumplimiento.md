# Los grupos del experimento son comparables y el cumplimiento es perfecto

- **Estado:** vigente
- **Parte / base:** B; experimento; validación del diseño (causal)
- **Script de origen:** `02_Scripts/06_ate_experimento_niveles.R`
- **Última verificación:** 2026-10-24, con `02_Scripts/06_ate_experimento_niveles.R` (secciones 1 a 3 de `00_main.R` más el script, no `00_main.R` completo)

## Evidencia
- `03_Resultados/Tablas/06_ate_experimento_niveles/experimento_balance.png` (y su
  `.csv`). Experimento, n = 10,000, muestra completa. Diferencia de medias entre
  grupos, con errores estándar HC1, de tiempo en el sitio, más de 5 minutos,
  sesiones anteriores, usuario recurrente, dispositivo y sistema operativo.
- Ninguna diferencia individual tiene valor p menor que 0.10 (el menor es 0.104,
  en el porcentaje de usuarios de escritorio: 39.5 % en control y 41.1 % en
  registro facilitado). Prueba conjunta (Wald con errores HC1, que incluye
  `os_type`): F = 0.96, valor p = 0.456.
- `03_Resultados/Tablas/06_ate_experimento_niveles/experimento_cumplimiento.png`
  (y su `.csv`): 5,043 usuarios de control, ninguno registrado, y 4,957 asignados
  al registro facilitado, todos registrados. El script se detiene con `stopifnot`
  si `sign_up` y `easier_signup` dejan de coincidir.

## Qué dice, en lenguaje intuitivo
Si la aleatorización funcionó, los dos grupos deberían parecerse en todo lo que
existía antes del tratamiento. La tabla de balance lo muestra: tiempo, sesiones,
dispositivo y sistema operativo son casi iguales entre grupos, y las diferencias
son del tamaño que produciría el azar. Como las covariables no predicen la
asignación en conjunto, no hay señal de que la asignación se haya hecho con algún
criterio distinto del azar. La tabla de cumplimiento muestra que nadie asignado al
registro facilitado dejó de registrarse y nadie en control se registró: cada
asignación se cumplió.

## Por qué importa en el estudio
Sostiene la lectura causal del ITT de `B_ols_efecto_registro.md` (Parte B) y es la
condición para que los controles solo ganen precisión. **Se mantiene** frente al
Taller 1 (cumplimiento perfecto, LATE = ITT; el balance del Taller 1 no incluía
`os_type`; este agrega esa variable y el indicador de más de 5 minutos). Este
resultado es previo a cualquier análisis de heterogeneidad; no depende de la
transformación ni del método.

## Límites e incertidumbre
- Balance en las covariables observadas; no descarta desbalance en variables no
  medidas, aunque la aleatorización lo hace improbable.
- Con 10 comparaciones, un valor p pequeño sería esperable por azar; por eso se
  usa también la prueba conjunta.
- No analiza atrición ni cruces: la tabla de cumplimiento muestra que no los hay.
- Perfecto no significa que el registro sea la única vía: `sign_up` y
  `easier_signup` coinciden, así que no se puede separar la asignación del acto
  de registrarse.

## Historial
- 2026-10-24: primera versión; balance, prueba conjunta y cumplimiento en el
  script 06.
