library(readxl)

datos <- read_excel(
  "datos_foro_evaluable.xlsx",
  sheet = "Municipios"
)

weibull_12 <- do.call(rbind, lapply(
  split(datos, datos$Municipio),
  function(d) {
    
    v <- d[["vel_viento (m/s)"]]
    
    media <- mean(v)
    desviacion <- sd(v)
    
    k <- (desviacion / media)^(-1.086)
    c <- media / gamma(1 + 1/k)
    
    vmp <- c * ((k - 1)/k)^(1/k)
    vmaxE <- c * ((k + 2)/k)^(1/k)
    
    data.frame(
      municipio = d$Municipio[1],
      n = length(v),
      media_ms = media,
      desviacion_ms = desviacion,
      k = k,
      c_ms = c,
      vmp_ms = vmp,
      vmaxE_ms = vmaxE
    )
  }
))

weibull_12 <- weibull_12[
  order(-weibull_12$media_ms),
]

nrow(weibull_12)

dir.create("outputs", showWarnings = FALSE)

write.csv(
  weibull_12,
  "outputs/weibull_12_municipalities.csv",
  row.names = FALSE
)

print(weibull_12, row.names = FALSE)

file.exists("outputs/weibull_12_municipalities.csv")
