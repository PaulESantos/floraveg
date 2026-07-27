test_that("abundancia, densidad y frecuencia funcionan adecuadamente", {
  df <- data.frame(
    sitio = c("P1", "P1", "P2", "P2"),
    especie = c("SpA", "SpB", "SpA", "SpC"),
    abundancia = c(10, 5, 5, 5)
  )

  ab <- abundancia(df)
  expect_equal(sum(ab$abundancia_relativa_pct), 100)
  expect_equal(ab$n_individuos[ab$especie == "SpA"], 15)

  d <- densidad_poblacional(n_individuos = 100, area_ha = 0.5)
  expect_equal(d, 200)

  freq <- frecuencia(df)
  expect_equal(freq$frecuencia_absoluta[freq$especie == "SpA"], 2)
  expect_equal(freq$frecuencia_pct[freq$especie == "SpA"], 100)
})

test_that("area_basal y cobertura devuelven calculos matematicos precisos", {
  # AB = 0.7854 * DAP^2 / 10000 m2
  ab <- area_basal(dap_cm = 20, unidad_salida = "m2")
  expect_equal(ab, (0.7854 * 400) / 10000, tolerance = 1e-4)

  cob <- cobertura(dc_m = 4, area_parcela_m2 = 100)
  # AC = 3.1416 * (2^2) = 12.5664 m2; % = 12.5664
  expect_equal(cob$cobertura_relativa_pct, 12.5664, tolerance = 1e-3)
})

test_that("distribucion_diametrica agrupa DAP en clases", {
  daps <- c(12, 15, 18, 22, 25, 33, 41, 45, 52, 68)
  dd <- distribucion_diametrica(daps, ancho_clase = 10)
  expect_true(is.data.frame(dd$tabla_clases))
  expect_equal(dd$ancho_clase, 10)
})
