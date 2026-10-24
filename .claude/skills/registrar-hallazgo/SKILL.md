---
name: registrar-hallazgo
description: Crea o actualiza una nota de hallazgo en 05_Notas/ (un .md por hallazgo principal, con referencia a tablas/figuras, explicación intuitiva e importancia en el estudio) y contrasta la evidencia nueva con las notas existentes y con el Taller 1, alertando de inmediato si algo es contradictorio. Usar cuando se genere o cambie un resultado (tabla, figura, estimación), cuando el usuario pida "registrar un hallazgo", "escribir la nota", "actualizar las notas" o "contrastar con lo anterior", y antes de dar por cerrado un análisis.
---

# Registrar hallazgo y contrastar evidencia

Mantiene `05_Notas/` como memoria analítica del taller. Las reglas de fondo
están en la sección "Notas de hallazgos" de `CLAUDE.md`; esta skill es el
procedimiento. Se invoca cuando se genera o cambia un resultado, no solo al
cerrar la sesión.

Básate solo en resultados que existan en `03_Resultados/` y en lo ocurrido en la
conversación. Si algo no es inferible con certeza (la escala de una cifra, si un
resultado es de entrenamiento o de prueba, si dos números son comparables),
pregunta al usuario en vez de adivinar.

## Paso 1: identificar el hallazgo y su evidencia

1. Identifica el resultado nuevo o modificado: qué tablas/figuras de
   `03_Resultados/` lo contienen y qué script de `02_Scripts/` las genera.
   Confirma que los archivos existen (`ls`); una cifra sin archivo de respaldo
   no entra a una nota.
2. Lee `05_Notas/README.md` y busca si ya existe una nota sobre el mismo
   hallazgo. Si existe, se actualiza; si no, se crea.
3. Un hallazgo es un resultado que sostiene, matiza o contradice una conclusión
   del taller. Un resultado intermedio sin implicación para las preguntas de las
   Partes A o B no necesita nota (queda en la bitácora).

## Paso 2: contrastar antes de escribir

Antes de crear o modificar la nota, contrasta el resultado nuevo con:

- las notas relacionadas de `05_Notas/` (todas las de la misma parte, y las
  transversales `X_`);
- la sección "Punto de partida: resultados del Taller 1" de `CLAUDE.md`;
- las decisiones registradas en "Decisiones tomadas".

Compara dirección, orden de magnitud, **escala** (`ln(Revenue)` vs. `Revenue`;
no compares RMSE de variables dependientes distintas), base (observacional vs.
experimento), muestra (entrenamiento vs. prueba) y partición/semilla.

Clasifica el resultado:

| Clasificación | Qué significa | Qué se hace |
| --- | --- | --- |
| **Consistente** | Coincide con lo registrado. | Actualizar "Última verificación" e historial. |
| **Cambia (atribuible)** | Difiere del Taller 1 y la diferencia se explica por la transformación, el método o ambos. | Es lo que mide el taller: registrarlo como "cambia" en la nota, con la atribución. No es una alerta. |
| **Contradictorio** | Choca con una nota del Taller 2, o con el Taller 1 sin explicación atribuible. | Alertar (Paso 3). |

Si no puedes distinguir entre "cambia (atribuible)" y "contradictorio", trátalo
como contradictorio y alerta.

## Paso 3: alertar si hay contradicción

Detén el registro y avisa al usuario **en ese momento**, sin esperar al cierre
de la sesión y sin resolverlo en silencio. La alerta lleva:

1. **Qué se contradice:** ruta de la nota o fuente previa y del resultado nuevo.
2. **Las cifras de ambos lados**, cada una con escala, base, `n` y si es de
   entrenamiento o de prueba.
3. **Hipótesis de la causa**, distinguiendo: transformación, método,
   partición/semilla, error de código, datos distintos o diferencia en el
   estimando.
4. **Qué verificar** para resolverlo (un chequeo concreto, con el script o la
   tabla donde mirar).

Mientras el usuario no decida:

- **No sobrescribas** la nota anterior ni cambies su estado.
- Deja la evidencia nueva en el "Historial" de la nota o en una nota propia
  marcada como pendiente de conciliar, y dilo en el reporte.
- Con la decisión del usuario: marca la nota previa como `matizado` o
  `reemplazado` (con enlace a la nota que la sustituye) y, si cambió una
  conclusión, regístralo en "Decisiones tomadas" de `CLAUDE.md`.

## Paso 4: escribir o actualizar la nota

Nombre: `05_Notas/<script>/<parte>_<slug>.md`, en la subcarpeta del script del
que se deriva el hallazgo (p. ej. `05_Notas/03_punto_partida/`), con `<parte>` =
`A`, `B` o `X` (transversal), slug en minúsculas con guion bajo (p. ej.
`A_quiebre_time_spent.md`). Una nota por hallazgo, no por sesión. La nota solo
habla de lo que se sabe con los resultados de su script; si otro script lo
matiza, se registra en la subcarpeta de ese script. Declara el "Script de
origen" bajo "Parte / base".

Estructura:

```markdown
# <Hallazgo, enunciado como conclusión>

- **Estado:** vigente | matizado | reemplazado (con enlace a la nota que lo reemplaza)
- **Parte / base:** A o B; observacional o experimento; descriptivo, predictivo o causal
- **Última verificación:** YYYY-MM-DD, con el script que lo genera

## Evidencia
Rutas exactas de las tablas/figuras en `03_Resultados/` y el script de
`02_Scripts/` que las produce. Cifras clave con escala, `n` y si son de
entrenamiento o de prueba.

## Qué dice, en lenguaje intuitivo
Qué muestra la figura o tabla, cómo leerla y qué significa para el negocio, para
alguien sin formación técnica. Distingue estimando, estimador y estimación; separa
lo predictivo/descriptivo de lo causal.

## Por qué importa en el estudio
Qué pregunta del taller responde (A o B), con qué conclusión del Taller 1 se
conecta (se mantiene, se matiza o cambia), si la diferencia se asocia a la
transformación, al método o a ambos, y qué implica para la decisión de CheMarket.

## Límites e incertidumbre
Qué no permite afirmar, intervalos o variabilidad, y qué evidencia adicional
haría falta.

## Historial
- YYYY-MM-DD: qué cambió y por qué.
```

Reglas de redacción (de `CLAUDE.md`):

- Sin juicios de "bueno" o "malo" sobre resultados y sin entusiasmo por
  coeficientes, métricas o significancia. Reporta magnitud e incertidumbre.
- Sin código. Sin nombres de variables del código en la explicación intuitiva
  (di "ingreso", "registro facilitado", no `Revenue`, `easier_signup`), salvo
  donde la escala lo exija (`ln(Revenue)`).
- Predicción no es causalidad: en la base observacional, importancia de
  variables y particiones no son efectos. Los CATE son estimaciones con
  incertidumbre; que un método encuentre grupos no prueba que haya HTE.
- Antes de cerrar la nota, repasa las heurísticas pertinentes de
  `07_Recursos/heuristicas_retroalimentacion_taller1.md` (H1–H11).

## Paso 5: actualizar el índice

Actualiza `05_Notas/README.md`: una fila por nota con su archivo, estado,
parte/base y la pregunta del taller que responde. Si cambió el estado de una
nota, actualiza también su fila. No edites las filas de otras notas.

## Cierre

Termina con un reporte corto: notas creadas o actualizadas (rutas), la
clasificación de cada contraste (consistente, cambia, contradictorio) y, si hubo
alertas, qué quedó pendiente de decisión del usuario. Esta skill no hace commit:
los cambios se versionan con `cerrar-sesion` al cerrar la sesión (en la rama
del integrante, nunca en `main`).
