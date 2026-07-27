test_that("calc_ivi suma abundancia, dominancia y frecuencia para dar IVI (max 300%)", {
  df <- data.frame(
    sitio = c("P1", "P1", "P1", "P2", "P2"),
    especie = c("SpA", "SpB", "SpC", "SpA", "SpB"),
    abundancia = c(5, 3, 2, 8, 4),
    dap_cm = c(20, 15, 10, 25, 18)
  )

  res_ivi <- calc_ivi(df)
  expect_equal(nrow(res_ivi), 3)
  expect_true(all(c("especie", "abundancia_rel_pct", "dominancia_rel_pct", "frecuencia_rel_pct", "ivi") %in% names(res_ivi)))
  expect_equal(sum(res_ivi$ivi), 300, tolerance = 1e-3)
})
