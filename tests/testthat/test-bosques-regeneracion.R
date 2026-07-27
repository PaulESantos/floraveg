test_that("regeneracion_natural y proporcion_fenologia funcionan correctamente", {
  estadios <- regeneracion_natural(dap_cm = c(0.5, 1.2, 5.5, 12.0, 45.0))
  expect_equal(as.character(estadios), c("Brinzal", "Brinzal", "Latizal", "Fustal", "Fustal"))

  fenologia <- c("Floracion", "Floracion", "Fructificacion", "Vegetativo", "Vegetativo", "Vegetativo")
  prop <- proporcion_fenologia(fenologia)
  expect_equal(nrow(prop), 3)
  expect_equal(sum(prop$porcentaje), 100)
})
