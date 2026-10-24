# Wind Speed Statistical Analysis and Weibull Modeling with R

**Project 02 — Professional Portfolio | Reproducible Statistical Analysis**

## Overview

This project analyzes wind speed observations from 12 Colombian municipalities using R. It extends an original university exercise into a reproducible workflow covering data quality assessment, descriptive statistics, temporal analysis, Weibull modeling, theoretical wind power and energy density estimation, and model validation.

The objective is to demonstrate reproducible quantitative analysis, statistical model implementation, independent verification, and transparent interpretation of results.

This is a methodological analysis, not a wind farm feasibility study.

## Data

**Source file:** `datos_foro_evaluable.xlsx`  
**Worksheet:** `Municipios`

The dataset contains 17,341 observations across 12 Colombian municipalities, with records spanning portions of 2020–2024.

The principal variables include date, municipality, wind speed, temperature, and atmospheric pressure.

Temporal coverage varies by municipality. The original data collection methodology, measurement height, and representativeness have not been independently verified.

### Data availability

The source dataset was provided by the university as teaching material.
It is not included in the public repository because redistribution permission has not been established.

The scripts require the original Excel file, `datos_foro_evaluable.xlsx`,
in the project root directory to reproduce the calculations.
Without access to that dataset, independent execution of the complete workflow is not possible.

Publication of derived outputs is also subject to review of the dataset's usage conditions.

## Analysis Workflow

| Script | Purpose |
|---|---|
| `01_data_audit.R` | Dataset structure, completeness, duplicates, and temporal coverage |
| `02_descriptive_statistics.R` | Wind speed descriptive statistics |
| `03_temporal_analysis.R` | Monthly wind speed trends and observation coverage |
| `04_weibull_12_municipalities.R` | Weibull parameter estimation for 12 municipalities |
| `05_wind_power_density.R` | Theoretical wind power density estimation |
| `06_wind_energy_density.R` | Theoretical energy density for a normalized 30-day period |
| `07_weibull_validation.R` | Empirical versus theoretical CDF discrepancy analysis |
| `analysis.R` | Original four-municipality methodological baseline |

## Methodology

### Weibull distribution

The Weibull shape and scale parameters are estimated using:

\[
k=\left(\frac{\sigma}{\bar v}\right)^{-1.086}
\]

\[
c=\frac{\bar v}{\Gamma(1+1/k)}
\]

These equations follow the methodology referenced in Adaramola et al. (2014).

The original university exercise used an exponent of −1.09. The baseline analysis preserves that distinction for comparison.

### Wind power density

Theoretical wind power density is estimated as:

\[
WPD=\frac{1}{2}\rho c^3\Gamma(1+3/k)
\]

A constant reference air density of 1.225 kg/m³ is used.

### Wind energy density

Energy density is calculated for a normalized hypothetical period of 720 hours:

\[
E_D=\frac{WPD\times720}{1000}
\]

The result is expressed in kWh/m² and does not represent actual turbine electricity generation.

### Model validation

Weibull calculations are checked against R's built-in distribution functions.

Theoretical WPD estimates are compared against empirical estimates calculated directly from observed wind speeds.

Empirical and Weibull cumulative distributions are compared using their maximum absolute separation, accounting for both sides of empirical CDF jumps.

This is a descriptive model-fit assessment, not a calibrated statistical hypothesis test.

## Selected Findings

- Riohacha has the highest estimated wind power density among the analyzed municipalities.
- San Andrés and Riohacha show the smallest maximum empirical-versus-Weibull CDF discrepancies.
- Mocoa has the largest CDF discrepancy (approximately 0.1196) and a Weibull WPD estimate approximately 7.62% below its empirical counterpart.
- Agreement in estimated wind power density does not necessarily imply a close fit across the entire wind speed distribution.

## Requirements and Execution

**Requirements:** R and the `readxl` package.

Install the required package if necessary:

```r
install.packages("readxl")
```

From the project root, execute the numbered scripts sequentially:

```r
source("01_data_audit.R")
source("02_descriptive_statistics.R")
source("03_temporal_analysis.R")
source("04_weibull_12_municipalities.R")
source("05_wind_power_density.R")
source("06_wind_energy_density.R")
source("07_weibull_validation.R")
```

Generated CSV and PDF files are stored in `outputs/`.

All eight R scripts executed successfully. The ten expected output files were regenerated, and all eight CSV outputs were verified as equivalent to their backups. PDF files were generated successfully, but visual equivalence was not independently verified.

## Limitations

- The source dataset is associated with a university exercise; its original collection procedures have not been independently established.
- Wind speed measurement heights and observation protocols are unknown.
- Temporal coverage varies among municipalities.
- The Weibull model is an approximation and exhibits varying fit quality across municipalities.
- The analysis uses constant air density; variable density modeling was deferred because the atmospheric pressure field requires additional provenance verification.
- Energy density values represent normalized theoretical estimates, not measured energy production.
- Turbine power curves, operating constraints, and actual electrical output are outside the scope.
- This work adapts methodology from a Nigerian wind energy study; it does not reproduce that study's underlying dataset or turbine-performance findings.

## Scientific Reference

Adaramola et al. (2014). *Performance evaluation of wind turbines for energy generation in Niger Delta, Nigeria*. Sustainable Energy Technologies and Assessments, 6, 75–85.

## Project Status

**Statistical analysis and descriptive validation:** Completed.

**Script execution:** PASS (8/8 scripts).

**Output regeneration:** PASS (10/10 expected files present).

**CSV reproducibility:** PASS (8/8 regenerated CSV datasets equivalent to backups).

**PDF outputs:** Generated successfully; visual equivalence not independently verified.

**Script cleanup:** Completed.

**Source dataset:** University-provided teaching material; excluded from public version pending redistribution permission.

**Portfolio publication:** Pending final repository review.
