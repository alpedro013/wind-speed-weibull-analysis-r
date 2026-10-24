# Project 02 - Wind Energy Density
# Periodo normalizado de 30 dias

source("05_wind_power_density.R")

horas <- 30 * 24

energia_30d <- wpd_resultados

energia_30d$energia_kWh_m2 <- (
  energia_30d$WPD_W_m2 * horas
) / 1000

print(
  energia_30d[, c(
    "municipio",
    "WPD_W_m2",
    "energia_kWh_m2"
  )],
  row.names = FALSE
)

dir.create("outputs", showWarnings = FALSE)

write.csv(
  energia_30d,
  "outputs/wind_energy_density_30d.csv",
  row.names = FALSE
)
