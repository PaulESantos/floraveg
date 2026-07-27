test_that("diversidad_alfa calcula la riqueza e indices completos speciesdiv", {
  df <- data.frame(
    sitio = c("P1", "P1", "P2", "P2", "P2"),
    especie = c("SpA", "SpB", "SpA", "SpC", "SpD"),
    abundancia = c(10, 5, 2, 8, 1)
  )

  alfa <- diversidad_alfa(df)
  expect_equal(nrow(alfa), 2)
  expect_true(all(c("n_individuos", "riqueza_s", "shannon_h", "pielou_j", "gini_simpson", "simpson_inv", "margalef", "menhinick", "mcintosh") %in% names(alfa)))

  expect_equal(alfa$riqueza_s[alfa$sitio == "P1"], 2)
  expect_equal(alfa$riqueza_s[alfa$sitio == "P2"], 3)
  expect_true(alfa$margalef[alfa$sitio == "P1"] > 0)
  expect_true(alfa$menhinick[alfa$sitio == "P1"] > 0)
  expect_true(alfa$mcintosh[alfa$sitio == "P1"] > 0)
})

test_that("diversidad_beta calcula similitud Jaccard y Morisita-Horn", {
  df <- data.frame(
    sitio = c("P1", "P1", "P2", "P2"),
    especie = c("SpA", "SpB", "SpA", "SpC"),
    abundancia = c(10, 5, 2, 8)
  )

  sim_jaccard <- diversidad_beta(df, metodo = "jaccard")
  expect_true(inherits(sim_jaccard, "dist"))
  expect_equal(as.numeric(sim_jaccard), 1/3, tolerance = 1e-3)

  tidy_beta <- diversidad_beta(df, metodo = "jaccard", formato = "tidy")
  expect_true(is.data.frame(tidy_beta))
  expect_equal(names(tidy_beta), c("sitio_1", "sitio_2", "similitud", "disimilitud"))
  expect_equal(nrow(tidy_beta), 1)
  expect_equal(tidy_beta$similitud[1], 0.3333, tolerance = 1e-3)
})

test_that("diversidad_shannon utiliza logaritmo base 2 según MINAM", {
  df <- data.frame(
    sitio = c("P1", "P1"),
    especie = c("SpA", "SpB"),
    abundancia = c(5, 5)
  )

  sh <- diversidad_shannon(df, base = 2)
  expect_equal(sh$shannon_h[1], 1.0, tolerance = 1e-4)
})

test_that("diversidad_pielou, simpson y sorensen funcionan correctamente", {
  df <- data.frame(
    sitio = c("P1", "P1", "P2", "P2"),
    especie = c("SpA", "SpB", "SpA", "SpC"),
    abundancia = c(5, 5, 2, 8)
  )

  p <- diversidad_pielou(df)
  expect_equal(p$pielou_j[p$sitio == "P1"], 1.0, tolerance = 1e-4)

  simp <- diversidad_simpson(df)
  expect_true(all(c("dominancia_simpson_d", "diversidad_simpson_1_d") %in% names(simp)))

  sor <- diversidad_sorensen(df)
  expect_true(inherits(sor, "dist"))
})

test_that("curva_whittaker y plot_whittaker funcionan correctamente", {
  df <- data.frame(
    sitio = c("P1", "P1", "P2", "P2"),
    especie = c("SpA", "SpB", "SpA", "SpC"),
    abundancia = c(10, 5, 2, 8)
  )

  cw_sitio <- curva_whittaker(df, por_sitio = TRUE)
  expect_true(is.data.frame(cw_sitio))
  expect_true(all(c("sitio", "especie", "rank", "abundance", "proportion", "accumfreq", "logabun") %in% names(cw_sitio)))

  cw_gen <- curva_whittaker(df, por_sitio = FALSE)
  expect_equal(unique(cw_gen$sitio), "General (Pooled)")

  p_w <- plot_whittaker(df, scale = "logabun", top_n_labels = 2)
  expect_true(inherits(p_w, "ggplot"))
})
