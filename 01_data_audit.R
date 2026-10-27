library(readxl)

datos <- read_excel("datos_foro_evaluable.xlsx",
                    sheet = "Municipios")

# Input structure validation
required_columns <- c(
  "Municipio",
  "fecha",
  "vel_viento (m/s)"
)

missing_columns <- setdiff(
  required_columns,
  names(datos)
)

if (length(missing_columns) > 0) {
  stop(
    "Missing required columns: ",
    paste(missing_columns, collapse = ",")
  )
}

message("PASS: Required columns are present.")

# Input data type validation
type_checks <- c(
  municipio = is.character(datos$Municipio),
  fecha = inherits(datos$fecha, "Date") ||
    inherits(datos$fecha, "POSIXct"),
  wind_speed = is.numeric(datos[["vel_viento (m/s)"]])
)

if (!all(type_checks)) {
  stop(
    "Invalid data types detected: ",
    paste(names(type_checks)[!type_checks], collapse = ", ")
  )
}

message("PASS: Required data types are valid.")

# Dimensiones y estructura
dim(datos)
names(datos)
str(datos)

# Valores faltantes
colSums(is.na(datos))

# Municipios y cantidad de observaciones
table(datos$Municipio)

# Cobertura temporal
range(datos$fecha)

# Cobertura por municipio
aggregate(fecha ~ Municipio, datos, min)
aggregate(fecha ~ Municipio, datos, max)

# Duplicados municipio-fecha
sum(duplicated(datos[c("Municipio", "fecha")]))

# Estadisticas generales de velocidad
summary(datos[["vel_viento (m/s)"]])


cobertura <- do.call(rbind, lapply(
  split(datos$fecha, datos$Municipio),
  function(fechas) {
    inicio <- min(fechas)
    fin <- max(fechas)
    dias_esperados <- as.integer(fin - inicio) + 1
    dias_observados <- length(unique(fechas))
  
    data.frame(
      inicio = inicio,
      fin = fin,
      dias_esperados = dias_esperados,
      dias_observados = dias_observados,
      cobertura_pct = round(
        100 * dias_observados / dias_esperados, 2
      )
    )
    }
))
print(cobertura)

# Periodos faltantes Bucaramanga
fechas_buc <- datos$fecha[
  datos$Municipio == "Bucaramanga"
]

fechas_faltantes <- setdiff(
  seq(min(fechas_buc), max(fechas_buc), by = "day"),
  fechas_buc
)

faltante_por_anio <- table(
  format(fechas_faltantes, "%Y")
)

print(faltante_por_anio)

