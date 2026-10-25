# Propuesta B: `02_Scripts/13_focalizacion_experimento.R`

Estado: **propuesta, sin ejecutar**. Nada del pipeline cambia hasta que el usuario
la apruebe.

## Para qué

Llevar al pipeline lo que va a las diapositivas de la recomendación, para que el
video use salidas de `00_main.R` (regla de `CLAUDE.md`). Hoy esas cifras solo
existen en `10_Auditoria/salidas/aud_02_*.csv` y `aud_03_*.csv`.

## Diseño (solo herramientas del catálogo)

- **Datos:** `experimento_listos.RDS` (n = 10,000) y `observacional_limpio.Rds`, solo
  para los pesos de cada celda en la base histórica.
- **Bosques:** `causal_forest` con las mismas 5 covariables y la misma matriz X que el
  script 12, 2,000 árboles, `seed = 2026`, `num.threads = 4` y `W.hat = mean(W)`.
  - El script 12 deja que `grf` estime `W.hat`. La auditoría mostró que las cifras no
    cambian (ATE 0.0039 frente a 0.0037 en log; 0.414 en dólares en los dos casos).
  - Decisión para el usuario: dejar 12 como está y declarar la diferencia en una
    nota, o pasar 12 también a `W.hat = mean(W)` (sus cifras cambian en el cuarto
    decimal).
- **Celdas:** dispositivo × sistema operativo (9) y dispositivo × tramo de sesiones
  (9; tramos 0–2, 3–4 y 5 o más, los de P4.3).
- **Muestra completa:** efecto de cada celda con
  `average_treatment_effect(cf, subset = celda)`, en log y en dólares, con:
  - IC del 95%;
  - lectura `exp(τ) − 1`;
  - n total y n por mitad;
  - peso en la base histórica;
  - gasto medio del control.

  Como contraste transparente se agrega `feols(y ~ 0 + celda + celda:easier_signup,
  vcov = "hc1")`.
- **Regla, como en el Lab 10:** con `set.seed(2026)` se parte el experimento en dos
  mitades por usuario.
  - `cf_ent`, estimado en la mitad de entrenamiento, elige las celdas a tratar
    (efecto > 0, solo celdas con al menos 100 observaciones en cada mitad).
  - `cf_eva`, estimado solo en la mitad de evaluación, mide el valor de cada regla
    como `peso(S) × average_treatment_effect(cf_eva, subset = S)`.
  - La diferencia entre dos reglas anidadas se mide sobre las celdas en que
    difieren, por ejemplo celular–osx.
- **Conciliación:**
  - identidad ATE = Σ peso × τ_celda, en las dos escalas;
  - lo implicado por `gasto_control × (exp(τ_log) − 1)` con un gasto común, con el
    gasto de cada celda y con la partición fina dispositivo × SO × sesiones (celdas
    con n ≥ 100);
  - el residuo dentro de las celdas.
- **Celdas pequeñas:** las que tienen menos de 100 observaciones en alguna mitad
  (tableta–otro, tableta–5 o más) se marcan en tablas y figuras y no entran a las
  reglas elegidas.

## Salidas

Carpeta `03_Resultados/{Tablas,Figuras}/13_focalizacion_experimento/`. Tablas con
`guardar_tabla()` (`.png` y `.csv`) y figuras con `guardar_figura()`.

| Archivo | Contenido | Diapositiva |
| --- | --- | --- |
| Tabla `experimento_efecto_celdas_dispositivo_so` | 9 celdas: n (total, entrenamiento, evaluación), % de la base histórica, efecto en log como % (`exp(τ) − 1`) con IC, efecto en dólares con IC y MCO por celda; marca de celda pequeña | "El registro facilitado baja el gasto solo en celulares Windows u otro" |
| Figura `experimento_efecto_celdas_dispositivo_so` | Puntos con IC por celda, dos paneles (log como %, dólares), color según la regla (tratada / no tratada), celdas pequeñas en gris | ídem |
| Tabla `experimento_valor_reglas` | Mitad de evaluación: valor por usuario frente a "nadie" de cada regla (log como % y dólares, con IC), y las diferencias entre reglas sobre las celdas en que difieren | "Excluir solo esos celulares deja X por usuario, frente a Y de darlo a todos" |
| Tabla `experimento_conciliacion_celdas` | Identidad del ATE; aporte de los signos opuestos, del gasto base y del residuo dentro de celdas, en dólares | "Por qué el efecto es ≈ 0 en log y +0.41 dólares" |
| Tabla `experimento_efecto_celdas_dispositivo_sesiones` | 9 celdas dispositivo × sesiones, mismo formato | Apéndice: las sesiones no cambian la regla |

## Cambios en `00_main.R`

En `carpetas_salida`:

```r
  "03_Resultados/Tablas/13_focalizacion_experimento",
  "03_Resultados/Figuras/13_focalizacion_experimento"
```

En `scripts`, al final:

```r
  "02_Scripts/13_focalizacion_experimento.R"
```

No hacen falta paquetes nuevos: `grf`, `fixest`, `gt` y `ggplot2` ya están en el
`p_load()`.

## Otros archivos que se tocan en la misma sesión (reglas de `CLAUDE.md`)

- `README.md`: fila del script 13 en el mapa script → resultados.
- `05_Notas/13_focalizacion_experimento/`:
  - `B_regla_focalizacion.md`: regla y valor fuera de la muestra de selección;
  - `X_conciliacion_por_celdas.md`: atribución nivel vs. log.
- `05_Notas/README.md`: índice de las notas nuevas.
- `05_Notas/12_heterogeneidad_experimento/B_cate_por_grupo.md`: marcarla como
  `matizado`, con enlace a la nota nueva y con la confirmación del usuario. Su frase
  "osx es de computadores y tabletas" es falsa.
- `CLAUDE.md`, "Decisiones tomadas": `W.hat = mean(W)` en 13; la regla cambia de
  "computador y tableta" a "todos menos celular Windows u otro".
- `PLAN.md` y `HANDOFF.md`, solo si el usuario lo pide.
- `catalogo_metodos.md`: no hace falta ninguna ampliación.

## Tiempo estimado

- Escribir el script y las dos notas: 45 a 60 min.
- Corrida del script solo: unos 3 min. `00_main.R` completo: 46 min en esta máquina.
