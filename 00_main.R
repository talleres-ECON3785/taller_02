# =============================================================================
# Script maestro: ejecuta todo el pipeline del Taller 2 en una sola corrida
# Taller 2 - ECON-3785
#
# Corre los scripts de 02_Scripts/ en el orden de su numeracion. Antes de
# ejecutarlos, (1) verifica que el directorio de trabajo es la raiz del
# proyecto, (2) instala y carga con pacman todos los paquetes del proyecto y
# (3) crea las carpetas de salida que falten. Los scripts individuales NO
# cargan paquetes ni crean carpetas: asumen que este script ya lo hizo.
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Verificar que el directorio de trabajo es la raiz del proyecto
# -----------------------------------------------------------------------------

if (!file.exists("taller_02.Rproj")) {
  stop(
    "Este script debe ejecutarse con el directorio de trabajo en la raiz ",
    "del proyecto (donde esta taller_02.Rproj). Directorio actual: ", getwd()
  )
}

# -----------------------------------------------------------------------------
# 2. Paquetes: pacman los instala si no estan y luego los carga
# -----------------------------------------------------------------------------

# lista unica de paquetes del proyecto: si un script nuevo necesita otro
# paquete, se agrega aqui (no dentro del script)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse,    # limpieza, manipulacion y graficas (incluye ggplot2)
  gt,           # formato de las tablas de la presentacion
  modelsummary, # tablas de regresion con errores robustos (output = "gt")
  sandwich,     # errores estandar robustos (vcovHC) para la regresion lineal
  fixest,       # feols() y etable(): ITT con errores robustos hc1 (Parte B)
  caret,        # validacion cruzada y particion train/test (benchmarks lineales)
  glmnet,       # LASSO con cv.glmnet(): benchmark lineal flexible (Parte A)
  rpart,        # arboles de regresion CART con poda por validacion cruzada
  rpart.plot,   # figura del arbol podado
  ranger,       # bagging y bosques aleatorios; importancia por permutacion
  grf           # bosque causal: ATE, CATE, calibracion y TOC (Parte B)
)

# -----------------------------------------------------------------------------
# 3. Verificar las carpetas de salida (una sola vez, antes de todo)
# -----------------------------------------------------------------------------

# si un script nuevo escribe en otra carpeta, se agrega a esta lista.
# 01_Datos/01_Crudos/ no va aqui: no es una salida y nunca se escribe en ella
carpetas_salida <- c(
  "01_Datos/02_Procesados", "01_Datos/03_Listos",
  "03_Resultados/Tablas", "03_Resultados/Figuras",
  # una subcarpeta por script que genera tablas o figuras (nombre del script)
  "03_Resultados/Tablas/01_limpieza_observacional",
  "03_Resultados/Figuras/03_punto_de_partida_observacional",
  "03_Resultados/Figuras/04_forma_funcional_observacional"
)
for (carpeta in carpetas_salida) {
  if (!dir.exists(carpeta)) dir.create(carpeta, recursive = TRUE)
}

# -----------------------------------------------------------------------------
# 4. Orden de ejecucion de los scripts (segun su numeracion)
# -----------------------------------------------------------------------------

scripts <- c(
  "02_Scripts/01_limpieza_observacional.R",
  "02_Scripts/02_limpieza_experimento.R",
  "02_Scripts/03_punto_de_partida_observacional.R",
  "02_Scripts/04_forma_funcional_observacional.R"
)

# nota: '00_formato_graficas.R' no aparece en esta lista porque no produce
# resultados por si mismo; solo define el formato de las figuras y lo cargan
# con source() los scripts que las generan

# -----------------------------------------------------------------------------
# 5. Ejecutar cada script en su propio entorno, en orden
# -----------------------------------------------------------------------------

for (script in scripts) {
  mensaje <- paste0("Ejecutando: ", script)
  message(strrep("=", nchar(mensaje)))
  message(mensaje)
  message(strrep("=", nchar(mensaje)))

  source(script, local = new.env(), encoding = "UTF-8")
}

message("Pipeline completo: los ", length(scripts),
        " scripts se ejecutaron sin errores.")
