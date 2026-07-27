test_that("validate_inventario y standardize_inventory funcionan correctamente", {
  df_valido <- data.frame(sitio = "P1", especie = "Sp1", abundancia = 1)
  expect_equal(validate_inventario(df_valido), df_valido)

  df_bci <- data.frame(plot = "P1", species = "Sp1", abundance = 5)
  df_std <- standardize_inventory(df_bci)
  expect_equal(names(df_std), c("sitio", "especie", "abundancia"))
  expect_equal(df_std$abundancia[1], 5)

  expect_error(validate_inventario("no_df"), "El argumento 'datos' debe ser un data.frame")
  expect_error(validate_inventario(data.frame(x = 1)), "Faltan las siguientes columnas requeridas")
})

test_that("long_to_comm convierte data frame a matriz de sitio x especie", {
  df <- data.frame(
    sitio = c("P1", "P1", "P2", "P2"),
    especie = c("SpA", "SpB", "SpA", "SpC"),
    abundancia = c(10, 5, 2, 8)
  )
  mat <- long_to_comm(df)
  expect_true(is.matrix(mat))
  expect_equal(dim(mat), c(2, 3))
  expect_equal(mat["P1", "SpA"], 10)
  expect_equal(mat["P1", "SpC"], 0)
  expect_equal(mat["P2", "SpC"], 8)
})
