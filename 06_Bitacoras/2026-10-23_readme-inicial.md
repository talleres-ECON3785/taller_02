# Bitácora — 2026-10-23: README inicial (P0.5)

## Resumen

Sesión de Santiago Muñoz (`SantiagoMunozM`). Se cerró **P0.5** del plan: crear el
`README.md` inicial de la raíz con objetivo, estructura de carpetas, instrucciones
de ejecución (solo `00_main.R`, con `pacman` instalando lo necesario) y un mapa
script → resultados por llenar. Con esto queda cerrado el hito H0.

El mapa lista como "existentes" solo los cuatro scripts que hay hoy en
`02_Scripts/`, con entradas y salidas verificadas contra el código (`saveRDS` y
`write_csv` de los scripts `01_` y `02_`). Los scripts `03_` a `09_` figuran como
"previstos", con los nombres de `PLAN.md`.

No se ejecutó `00_main.R` ni se generaron resultados.

De los "Siguientes objetivos" del handoff: se cumplió el (1) P0.5. El (2) P1.1–P1.3
y el (3) P2.1 no se trabajaron; se mantienen.

## Archivos

- Creados: `README.md`, `06_Bitacoras/2026-10-23_readme-inicial.md`.
- Modificados: `PLAN.md` (casilla P0.5 marcada), `HANDOFF.md`.
- Eliminados: ninguno.

## Detalle por archivo

### `README.md`

Secciones: objetivo (pregunta del taller, diseño 2×2 forma funcional × método,
Partes A y B, roles de las dos bases), cómo ejecutar, estructura de carpetas,
métodos, mapa script → resultados, documentación del trabajo y trabajo en equipo.

Decisiones:

- **Mapa en dos tablas** (existentes y previstos) en lugar de una sola, para que
  nadie busque en las salidas de un script que aún no existe. Cada script previsto
  pasa a la primera tabla en la misma sesión en que se crea, como pide `CLAUDE.md`.
- **Los scripts de formato** (`00_formato_*.R`) aparecen en el mapa pero con
  salidas vacías y la aclaración de que no van en `00_main.R`.
- **Comparabilidad con el Taller 1** (80/20, semilla 2026, RMSE) y la advertencia
  de no comparar RMSE entre escalas quedan en el README para que se vean sin leer
  `CLAUDE.md`.
- Se mencionan `CHROME_PATH` y la semilla porque son las dos cosas que pueden
  fallar o variar entre máquinas.
- La rama de Samuel (`SamuelEscandonC`) está tal como la infiere `CLAUDE.md` de su
  correo; sigue sin confirmar.

### `PLAN.md`

Se marcó `[x]` en P0.5.

## Pendientes

- P1.1–P1.3: descriptiva de la Parte A (`03_descriptivas_observacional.R`).
- P2.1: partición 80/20 que reproduce el RMSE 2.314 del Taller 1.
- P7.2: completar el mapa del README al final con todas las tablas y figuras.
- Sin confirmar: nombre de la rama de Samuel; convención de `log_revenue` frente al
  Taller 1; `guardar_tabla()` probado en una sola máquina.
