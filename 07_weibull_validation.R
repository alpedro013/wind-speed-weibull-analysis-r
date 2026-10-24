# Project 02 - Weibull CDF Validation
# Maximum empirical vs theoretical CDF discrepancy
# Accounts for both sides of empirical CDF jumps

source("04_weibull_12_municipalities.R")

D_resultados_corregidos <- data.frame(
  municipio = character(),
  D_CDF = numeric()
)

for (i in seq_len(nrow(weibull_12))) {
  
  ciudad <- weibull_12$municipio[i]
  
  v <- sort(datos[["vel_viento (m/s)"]][
    datos$Municipio == ciudad
  ])
  
  n <- length(v)
  valores <- sort(unique(v))
  
  F_derecha <- ecdf(v)(valores)
  
  F_izquierda <- findInterval(
    valores, v, left.open = TRUE
  ) / n
  
  F_modelo <- pweibull(
    valores,
    shape = weibull_12$k[i],
    scale = weibull_12$c_ms[i]
  )
  
  D <- max(
    abs(F_derecha - F_modelo),
    abs(F_izquierda - F_modelo)
  )
  
  D_resultados_corregidos <- rbind(
    D_resultados_corregidos,
    data.frame(
      municipio = ciudad,
      D_CDF = D
    )
  )
}

D_resultados_corregidos <- D_resultados_corregidos[
  order(-D_resultados_corregidos$D_CDF),
]

print(D_resultados_corregidos, row.names = FALSE)

dir.create("outputs", showWarnings = FALSE)

write.csv(
  D_resultados_corregidos,
  "outputs/weibull_cdf_validation.csv",
  row.names = FALSE
)
