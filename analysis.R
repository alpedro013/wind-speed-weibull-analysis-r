# Project 02 | Wind Speed Statistical Analysis with R
# Reproducible baseline; requires R and package readxl.
# Run from this folder: Rscript analysis.R

if (!requireNamespace("readxl", quietly = TRUE)) {
  stop("Install the 'readxl' package: install.packages('readxl')")
}

input_file <- "datos_foro_evaluable.xlsx"
if (!file.exists(input_file)) stop("Dataset not found: ", input_file)
dir.create("outputs", showWarnings = FALSE)

raw <- readxl::read_excel(input_file, sheet = "Municipios")
required <- c("Municipio", "fecha", "vel_viento (m/s)")
if (!all(required %in% names(raw))) stop("Missing required columns")

cities <- c("Guapí", "San Andrés", "Barranquilla", "Cartagena")
if (!all(cities %in% unique(raw$Municipio))) stop("Missing selected municipality")

wind <- as.numeric(raw[["vel_viento (m/s)"]])
if (any(!is.finite(wind))) stop("Missing or non-finite wind speeds detected")
if (any(wind < 0)) stop("Negative wind speeds detected")
if (any(duplicated(raw[c("Municipio", "fecha")]))) stop("Duplicate municipality/date rows")

# Equation 8 in Adaramola et al. (2014): exponent -1.086.
# The original university exercise used -1.09; both are reported for traceability.
calculate_city <- function(city, exponent = -1.086) {
  v <- wind[raw$Municipio == city]
  n <- length(v)
  if (n < 2) stop("Insufficient observations for ", city)
  v_mean <- mean(v)
  v_sd <- sd(v) # sample SD, denominator n - 1
  if (v_mean <= 0 || v_sd <= 0) stop("Invalid mean/SD for ", city)
  k <- (v_sd / v_mean)^exponent
  c <- v_mean / gamma(1 + 1 / k)
  vmp <- if (k > 1) c * ((k - 1) / k)^(1 / k) else 0
  vmaxe <- c * ((k + 2) / k)^(1 / k)
  # Independent check: manual PDF against base R implementation.
  test_v <- c(1, 5, 10, 15, 20)
  manual_pdf <- (k / c) * (test_v / c)^(k - 1) * exp(-(test_v / c)^k)
  built_in_pdf <- dweibull(test_v, shape = k, scale = c)
  stopifnot(isTRUE(all.equal(manual_pdf, built_in_pdf, tolerance = 1e-10)))
  # Independent CDF expression vs base R.
  manual_cdf <- 1 - exp(-(test_v / c)^k)
  stopifnot(isTRUE(all.equal(manual_cdf, pweibull(test_v, shape = k, scale = c), tolerance = 1e-10)))
  data.frame(municipio = city, n = n, media_ms = v_mean,
             desviacion_ms = v_sd, cv_pct = 100 * v_sd / v_mean,
             k = k, c_ms = c, vmp_ms = vmp, vmaxe_ms = vmaxe,
             exponente = exponent)
}

result_paper <- do.call(rbind, lapply(cities, calculate_city, exponent = -1.086))
result_lab <- do.call(rbind, lapply(cities, calculate_city, exponent = -1.09))
write.csv(result_paper, "outputs/weibull_results_paper.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(result_lab, "outputs/weibull_results_lab.csv", row.names = FALSE, fileEncoding = "UTF-8")

# Histograms with fitted Weibull densities, one PDF for all selected cities.
pdf("outputs/weibull_histograms.pdf", width = 9, height = 7)
par(mfrow = c(2, 2))
for (i in seq_along(cities)) {
  city <- cities[i]
  v <- wind[raw$Municipio == city]
  r <- result_paper[i, ]
  hist(v, probability = TRUE, breaks = "FD", main = city,
       xlab = "Velocidad del viento (m/s)", col = "grey85", border = "white")
  curve(dweibull(x, shape = r$k, scale = r$c_ms), from = 0,
        to = max(v), add = TRUE, col = "black", lwd = 2)
}
dev.off()

print(result_paper, row.names = FALSE)
cat("Checks passed: input validity, manual PDF and CDF comparisons.\n")
