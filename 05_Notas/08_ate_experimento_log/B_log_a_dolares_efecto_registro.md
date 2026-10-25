# En logaritmo el registro facilitado casi no mueve el ingreso (1.3%), pero en dólares lo sube 12%: la diferencia es dispersión

- **Estado:** vigente
- **Parte / base:** B; experimento; causal (ITT en `ln(Revenue)`, con retransformación a dólares) y descriptivo (cuantiles)
- **Script de origen:** `02_Scripts/08_ate_experimento_log.R`
- **Última verificación:** 2026-10-24, con `00_main.R` completo

## Evidencia
Experimento, n = 10,000 (control 5,043; registro facilitado 4,957), muestra completa, errores HC1. Carpeta `03_Resultados/Tablas/08_ate_experimento_log/` (cada una con `.csv`):
- `experimento_ols_registro_log.png`: coeficiente en `ln(Revenue)` de 0.0134 (IC 95%: −0.010 a 0.037; p = 0.26) sin controles y 0.0065 (−0.009 a 0.022) con los controles del script 06.
- `experimento_log_a_dolares.png`: exp(coef) − 1 = +1.35%. Retransformando con un factor común a los dos grupos, el efecto en dólares sería 0.057; con un factor por grupo, 0.491, igual a la diferencia de medias. Efecto directo en dólares: 0.491 (IC 0.347 a 0.634), 12.3% sobre el control (3.978); con controles 0.454 (11.4%).
- `experimento_descomposicion_media.png`: cociente de medias 1.123 = 1.0135 (media geométrica) × 1.108 (dispersión). Desviación estándar de `ln(Revenue)`: 0.532 en control y 0.660 en tratamiento; diferencia de varianzas 0.153 (error estándar 0.012).
- `experimento_cuantiles_por_grupo.png`: el tratamiento reduce los percentiles bajos (percentil 10: 1.85 a 1.63 dólares) y sube los altos (percentil 90: 7.23 a 8.56; percentil 99: 14.40 a 24.88); la mediana no cambia (3.15 frente a 3.14). Sin intervalos.
- `experimento_efecto_cola.png`: el efecto en dólares baja de 0.491 a 0.363 al limitar el ingreso al percentil 99 (IC 0.236 a 0.489) y a 0.144 al percentil 95 (IC 0.046 a 0.241).
- Figura: `03_Resultados/Figuras/08_ate_experimento_log/experimento_distribucion_lnrevenue_por_grupo.png`.

## Qué dice, en lenguaje intuitivo
El usuario típico gasta casi lo mismo con o sin registro facilitado: en logaritmo el efecto es de alrededor de 1% y el intervalo incluye el cero. Pero el gasto promedio en dólares sube unos 12%. Las dos cosas son compatibles porque el tratamiento no desplaza toda la distribución: la ensancha. Algunos usuarios gastan menos y otros mucho más, de modo que la mediana y la media geométrica casi no se mueven y la media aritmética sube por la cola alta.

Llevar el resultado a dólares requiere cuidado. Si se hace la conversión habitual (exp del coeficiente por un solo factor de corrección para todos), el efecto en dólares sale en 0.06, ocho veces menor que el real, porque ese factor supone que el tratamiento no cambia la dispersión. Con un factor por grupo se recupera el efecto real.

## Por qué importa en el estudio
Responde "¿cambia el ATE y su interpretación en `ln(Revenue)`?" y concilia las dos estimaciones del Taller 1 (H2): ITT sin controles de 0.0134 en logaritmo y de 0.49 en dólares. **Se mantiene** el número del Taller 1 en las dos escalas (0.0134; 0.491). No son contradictorias: miden estimandos distintos (cambio del usuario típico frente a cambio de la media). La diferencia se atribuye a la transformación, que cambia qué parte de la distribución pesa. Para la decisión de CheMarket el estimando que importa en ingresos totales es la media en dólares (0.49 por usuario, 12%); el logaritmo dice que el beneficio no es uniforme. Una pregunta para la Parte B: qué usuarios producen la cola (ver límites).

## Límites e incertidumbre
- La división entre media geométrica y dispersión no tiene intervalo propio; sí lo tienen el coeficiente en logaritmo, el efecto en dólares y la diferencia de varianzas.
- Con controles, el modelo en logaritmo impone el mismo efecto proporcional a todos; la retransformación por grupo da 0.077 frente a 0.454 directo, así que ese supuesto no se sostiene. Esa brecha sugiere que el efecto proporcional difiere entre usuarios. Una exploración descriptiva (no registrada en tablas, subgrupos elegidos después de ver los datos, sin intervalos ni corrección por comparaciones múltiples) mostró efectos en logaritmo de signo opuesto por dispositivo (computador y tableta positivos, celular negativo) y sistema operativo (osx positivo; Windows y otros negativos). **No es evidencia de HTE:** eso lo evalúan el bosque causal y sus pruebas formales (P4).
- Los cuantiles son descriptivos y no traen intervalos (el remuestreo no está en el catálogo; se puede ampliar con autorización). Limitar el ingreso al percentil 99 o 95 usa el resultado para recortar: describe cuánto depende el promedio de la cola, no es un efecto de la intervención.
- No se usa `feols` en este script, sino `lm` con HC1 como en el 06 (mismos errores estándar).
- Con controles, el coeficiente en logaritmo (0.0065) difiere del 0.0042 del Taller 1, que usaba otro conjunto de controles; ambos están lejos de ser distinguibles de cero.

## Historial
- 2026-10-24: primera versión (P3.2 en logaritmo, P3.3 parcial: cuantiles y cola).
