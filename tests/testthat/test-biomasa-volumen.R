test_that("volumen_maderable y biomasa_aerea calculan formulas correctamente", {
  vol <- volumen_maderable(area_basal_m2 = 0.5, altura_m = 20, factor_forma = 0.70)
  expect_equal(vol, 7.0)

  bio_tree <- biomasa_aerea(densidad_madera = 0.6, volumen_m3 = 10)
  expect_equal(bio_tree, 6.0)

  bio_grass <- biomasa_aerea(peso_seco_g_m2 = 200, area_ha = 2)
  expect_equal(bio_grass, 4.0)
})

test_that("obtener_densidad_madera asigna densidades por especie, genero y fallback estandar", {
  sps <- c("Cedrela odorata", "Inga edulis", "Inga capitata", "EspecieDesconocida sp.")
  dens <- obtener_densidad_madera(sps, default = 0.60)

  expect_equal(length(dens), 4)
  expect_equal(dens[1], 0.45) # Cedrela odorata exact match
  expect_equal(dens[2], 0.55) # Inga edulis exact match
  expect_equal(dens[3], 0.54) # Inga genus fallback
  expect_equal(dens[4], 0.60) # Default fallback
})
