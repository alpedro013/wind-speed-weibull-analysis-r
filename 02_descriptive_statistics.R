library(readxl)

datos <- read_excel(
  "datos_foro_evaluable.xlsx",
  sheet = "Municipios"
)

resumen <- do.call(rbind, lapply(
  split(datos, datos$Municipio),
  function(d) {
    v <- d[["vel_viento (m/s)"]]
  
    data.frame(
      municipio = d$Municipio[1],
      n = length(v),
      media = mean(v),
      mediana = median(v),
      desviacion = sd(v),
      cv_pct = 100 * sd(v) / mean(v),
      minimo = min(v),
      maximo = max(v)
    )
    }
))

# Ordenar municipios por velocidad media descendente
resumen <- resumen[order(-resumen$media), ]

# Mostrar resultados
print(resumen, row.names = FALSE)

# Crear carpeta de resultados si no existe
dir.create("outputs", showWarnings = FALSE)

# Exportar estadísticas descriptivas
write.csv(
  resumen,
  "outputs/descriptive_statistics.csv",
  row.names = FALSE
)