## Resubmission

This is a resubmission of floraveg v0.1.0 addressing feedback from CRAN reviewer Leonore Hochhauser:

* **Title Case**: Updated `Title` in `DESCRIPTION` to Title Case: `"Indicadores Ecológicos y De Vegetación"`.
* **Description Field**: Expanded and enriched the `Description` field to provide thorough details of functions, analytical metrics, biomass & carbon estimation, and web dashboard integration, omitting any redundant `"in R"` phrasing at the start.
* **Random Seeds**: Removed all `set.seed()` calls inside internal package functions and Shiny modules (`R/mod_biomasa_volumen.R`, `R/mod_carga_datos.R`, `R/mod_codigo_r.R`, `R/mod_diversidad.R`, `R/mod_estructura.R`, `R/mod_ivi.R`, `R/mod_reporte.R`), replacing random sampling with a static deterministic example data generator (`obtener_datos_ejemplo()`) in `R/utils_ejemplo.R` that does not modify global RNG state.

## Test environments

* Local Windows 11 x64, R 4.6.1

## R CMD check results

0 errors | 0 warnings | 0 notes

## Method References

* The package implements methods aligned with the official guidelines of the Ministry of Environment of Peru (Ministerio del Ambiente del Perú - MINAM, 2015) for floristic inventories.
* Above-ground biomass estimation uses tropical tree allometric models by Chave et al. (2014) <doi:10.1111/gcb.12629>.
