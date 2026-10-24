library(readxl)

datos <- read_excel(
  "datos_foro_evaluable.xlsx",
  sheet = "Municipios"
)

datos$fecha <- as.Date(datos$fecha)
datos$anio <- as.integer(format(datos$fecha, "%Y"))
datos$mes <- as.integer(format(datos$fecha, "%m"))

# Agrupacion por municipio, anio y mes
datos$grupo <- paste(
  datos$Municipio,
  datos$anio,
  sprintf("%02d", datos$mes),
  sep = "_"
)

mensual <- do.call(rbind, lapply(
  split(datos, datos$grupo),
  function(d) {
    
    v <- d[["vel_viento (m/s)"]]
    
    inicio_mes <- as.Date(
      format(d$fecha[1], "%Y-%m-01")
    )
    
    siguiente_mes <- seq(
      inicio_mes,
      by = "month",
      length.out = 2
    )[2]
    
    dias_mes <- as.integer(siguiente_mes - inicio_mes)
    dias_observados <- length(unique(d$fecha))
    
    data.frame(
      municipio = d$Municipio[1],
      anio = d$anio[1],
      mes = d$mes[1],
      dias_observados = dias_observados,
      dias_mes = dias_mes,
      cobertura_pct = round(
        100 * dias_observados / dias_mes, 2
      ),
      velocidad_media = mean(v),
      desviacion = sd(v),
      velocidad_maxima = max(v)
    )
  }
))

mensual <- mensual[
  order(mensual$municipio, mensual$anio, mensual$mes),
]

# Validaciones
stopifnot(
  all(mensual$cobertura_pct >= 0),
  all(mensual$cobertura_pct <= 100),
  all(mensual$dias_observados <= mensual$dias_mes)
)

# Identificar meses incompletos
meses_incompletos <- mensual[
  mensual$cobertura_pct < 90,
  c("municipio", "anio", "mes",
    "dias_observados", "dias_mes", "cobertura_pct")
]

# Exportar resultados
dir.create("outputs", showWarnings = FALSE)

write.csv(
  mensual,
  "outputs/monthly_statistics.csv",
  row.names = FALSE
)

# Mostrar verificaciones
print(head(mensual, 5), row.names = FALSE)

print(meses_incompletos, row.names = FALSE)

cat(
  "Meses con cobertura inferior al 90%:",
  nrow(meses_incompletos), "\n"
)

summary(mensual$cobertura_pct)

summary(mensual$cobertura_pct)

nrow(meses_incompletos)

file.exists("outputs/monthly_statistics.csv")


# Seleccionar meses con cobertura suficiente
mensual_valido <- subset(
  mensual,
  cobertura_pct >= 90
)

# Crear PDF con un grafico por municipio
pdf("outputs/monthly_wind_trends.pdf",
    width = 11, height = 7)

municipios <- unique(mensual_valido$municipio)

par(mfrow = c(3, 4), mar = c(3, 3, 3, 1))

for (ciudad in municipios) {
  d <- subset(mensual_valido, municipio == ciudad)
  
  fecha_mes <- as.Date(
    sprintf("%04d-%02d-01", d$anio, d$mes),
    format = "%Y-%m-%d"
  )
  plot(
    fecha_mes,
    d$velocidad_media,
    type = "l",
    main = ciudad,
    xlab = "Fecha",
    ylab = "Velocidad (m/s)",
    col = "blue"
  )
}

dev.off()

shell.exec(normalizePath("outputs/monthly_wind_trends.pdf"))

getwd()

file.exists("outputs/monthly_wind_trends.pdf")
