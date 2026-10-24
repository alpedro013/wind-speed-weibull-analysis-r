# Project 02 - Wind Power Density
# Modelo Weibull con densidad constante

source("04_weibull_12_municipalities.R")

# Densidad del aire de referencia (kg/m3)
rho <- 1.225

# Densidad de potencia estimada por Weibull (W/m2)
weibull_12$WPD_W_m2 <- 0.5 * rho *
  weibull_12$c_ms^3 *
  gamma(1 + 3 / weibull_12$k)

# Ordenar de mayor a menor densidad de potencia
wpd_resultados <- weibull_12[
  order(-weibull_12$WPD_W_m2),
  c("municipio", "media_ms", "k",
    "c_ms", "WPD_W_m2")
]

print(wpd_resultados, row.names = FALSE)

# Verificaciones
stopifnot(
  nrow(wpd_resultados) == 12,
  all(is.finite(wpd_resultados$WPD_W_m2)),
  all(wpd_resultados$WPD_W_m2 > 0)
)

# Exportar
dir.create("outputs", showWarnings = FALSE)

write.csv(
  wpd_resultados,
  "outputs/wind_power_density_constant.csv",
  row.names = FALSE
)

# WPD calculada directamente de los datos
wpd_empirica <- aggregate(
  datos[["vel_viento (m/s)"]]^3,
  by = list(municipio = datos$Municipio),
  FUN = mean
)

names(wpd_empirica)[2] <- "media_v_cubo"

wpd_empirica$WPD_empirica <- 0.5 * rho *
  wpd_empirica$media_v_cubo

# Comprobar ambos metodos
comparacion<- merge(
  wpd_resultados,
  wpd_empirica[, c("municipio", "WPD_empirica")],
  by = "municipio"
)

comparacion$error_pct <- 100 *
  (comparacion$WPD_W_m2 -
     comparacion$WPD_empirica) /
  comparacion$WPD_empirica

print(
  comparacion[, c(
    "municipio", "WPD_W_m2",
    "WPD_empirica", "error_pct"
  )],
  row.names = FALSE
)

# Inspeccionar variables atmosfericas
summary(datos[["T (°C)"]])
summary(datos[["pres (hPa)"]])

# Comprobar tipos de datos
is.numeric(datos[["T (°C)"]])
is.numeric(datos[["pres (hPa)"]])

# Comprobar datos faltantes
sum(is.na(datos[["T (°C"]]))
sum(is.na(datos[["pres (hPa)"]]))

presion_municipios <- aggregate(
  datos[["pres (hPa)"]],
  by = list(municipio = datos$Municipio),
  FUN = mean
)

names(presion_municipios)[2] <- "presion_media_hPa"

print(presion_municipios, row.names = FALSE)
