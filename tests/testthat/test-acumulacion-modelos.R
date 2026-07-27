test_that("modelo_clench y estimadores_riqueza funcionan correctamente", {
  df <- data.frame(
    sitio = c("P1", "P1", "P2", "P2", "P3", "P3", "P4", "P4"),
    especie = c("Sp1", "Sp2", "Sp1", "Sp3", "Sp1", "Sp4", "Sp2", "Sp5"),
    abundancia = c(1, 2, 3, 1, 2, 4, 1, 1)
  )

  clench <- modelo_clench(df)
  expect_equal(clench$riqueza_observada, 5)

  est <- estimadores_riqueza(df)
  expect_true(all(c("chao2", "jackknife1", "jackknife2", "bootstrap") %in% names(est)))
  expect_equal(est$riqueza_observada, 5)
})
