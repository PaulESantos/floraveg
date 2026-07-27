#' Diversidad Alfa e Índices de Riqueza y Equidad (MINAM 2015 / speciesdiv)
#'
#' Calcula la riqueza y los índices clásicos y avanzados de diversidad alfa por sitio o unidad muestral:
#' Riqueza observada (S), N° Individuos (N), Shannon-Wiener (H'), Equitabilidad de Pielou (J'),
#' Gini-Simpson, Simpson Inverso, Margalef, Menhinick y McIntosh.
#'
#' @param datos Data frame con datos de inventario en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio/parcela. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna con la abundancia. Por defecto \code{"abundancia"}.
#' @param metodos Vector o carácter de métodos a calcular: \code{"full"}, \code{"richness"}, \code{"shannon"}, \code{"pielou"}, \code{"gini_simpson"}, \code{"simpson_inv"}, \code{"margalef"}, \code{"menhinick"}, \code{"mcintosh"}. Por defecto \code{"full"}.
#' @param base Base del logaritmo para Shannon y Pielou. Por defecto \code{2} según especificación MINAM.
#'
#' @return Un data frame con el sitio y las columnas correspondientes a los índices calculados.
#' @export
#' @examples
#' df <- data.frame(
#'   sitio = c("P1", "P1", "P2", "P2", "P2"),
#'   especie = c("SpA", "SpB", "SpA", "SpB", "SpC"),
#'   abundancia = c(10, 5, 2, 8, 1)
#' )
#' diversidad_alfa(df)
diversidad_alfa <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia",
                            metodos = "full", base = 2) {
  if (is.matrix(datos)) {
    mat <- datos
  } else {
    mat <- long_to_comm(datos, sitio = sitio, especie = especie, abundancia = abundancia)
  }
  storage.mode(mat) <- "numeric"

  n_sites <- nrow(mat)
  site_names <- rownames(mat)

  if ("full" %in% metodos) {
    metodos <- c("richness", "shannon", "pielou", "gini_simpson", "simpson_inv", "margalef", "menhinick", "mcintosh")
  }

  res <- data.frame(sitio = site_names, stringsAsFactors = FALSE)

  # N° Individuos (N) y Riqueza (S)
  n_ind <- rowSums(mat)
  s_obs <- apply(mat, 1, function(x) sum(x > 0))

  res$n_individuos <- as.numeric(n_ind)
  res$riqueza_s <- as.numeric(s_obs)

  if ("shannon" %in% metodos || "pielou" %in% metodos) {
    sh_nat <- vegan::diversity(mat, index = "shannon")
    sh_base <- sh_nat / log(base)
    if ("shannon" %in% metodos) res$shannon_h <- as.numeric(sh_base)
  }

  if ("pielou" %in% metodos) {
    max_h <- log(s_obs) / log(base)
    j_prime <- ifelse(s_obs > 1, sh_base / max_h, 0)
    res$pielou_j <- as.numeric(j_prime)
  }

  if ("gini_simpson" %in% metodos) {
    gini_simp <- apply(mat, 1, function(x) {
      N <- sum(x)
      if (N <= 0) return(0)
      p <- x[x > 0] / N
      1 - sum(p^2)
    })
    res$gini_simpson <- as.numeric(gini_simp)
  }

  if ("simpson_inv" %in% metodos) {
    simp_inv <- apply(mat, 1, function(x) {
      N <- sum(x)
      if (N <= 0) return(0)
      p <- x[x > 0] / N
      sum_p2 <- sum(p^2)
      if (sum_p2 <= 0) 0 else 1 / sum_p2
    })
    res$simpson_inv <- as.numeric(simp_inv)
  }

  if ("margalef" %in% metodos) {
    marg <- apply(mat, 1, function(x) {
      S <- sum(x > 0)
      N <- sum(x)
      if (N <= 1) return(0)
      (S - 1) / log(N)
    })
    res$margalef <- as.numeric(marg)
  }

  if ("menhinick" %in% metodos) {
    menh <- apply(mat, 1, function(x) {
      S <- sum(x > 0)
      N <- sum(x)
      if (N <= 0) return(0)
      S / sqrt(N)
    })
    res$menhinick <- as.numeric(menh)
  }

  if ("mcintosh" %in% metodos) {
    mcint <- apply(mat, 1, function(x) {
      x_pos <- x[x > 0]
      N <- sum(x_pos)
      if (N <= 1 || (N - sqrt(N)) == 0) return(0)
      (N - sqrt(sum(x_pos^2))) / (N - sqrt(N))
    })
    res$mcintosh <- as.numeric(mcint)
  }

  res
}

#' Diversidad Beta: Coeficientes de Similitud (MINAM 2015)
#' Indice de Diversidad Beta (Jaccard, Sorensen o Morisita-Horn)
#'
#' @param datos Data frame en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna con abundancia. Por defecto \code{"abundancia"}.
#' @param metodo Caracter; \code{"jaccard"} (cualitativo), \code{"sorensen"} (cualitativo) o \code{"morisita-horn"} (cuantitativo).
#' @param formato Caracter; \code{"matrix"} (matriz/dist original) o \code{"tidy"} (data.frame ordenado con sitio_1, sitio_2, similitud, disimilitud). Por defecto \code{"matrix"}.
#'
#' @return Si \code{formato = "matrix"}, objeto de clase \code{dist} o matriz de similitud (0 a 1).
#'   Si \code{formato = "tidy"}, un \code{data.frame} con las columnas \code{sitio_1}, \code{sitio_2}, \code{similitud} y \code{disimilitud}.
#' @export
diversidad_beta <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia",
                            metodo = c("jaccard", "sorensen", "morisita-horn"),
                            formato = c("matrix", "tidy")) {
  metodo <- match.arg(metodo)
  formato <- match.arg(formato)

  if (is.matrix(datos)) {
    mat <- datos
  } else {
    mat <- long_to_comm(datos, sitio = sitio, especie = especie, abundancia = abundancia)
  }
  storage.mode(mat) <- "numeric"

  if (metodo == "jaccard") {
    disim <- vegan::vegdist(mat, method = "jaccard", binary = TRUE)
  } else if (metodo == "sorensen") {
    disim <- vegan::vegdist(mat, method = "bray", binary = TRUE)
  } else {
    disim <- vegan::vegdist(mat, method = "horn")
  }

  similitud <- 1 - disim

  if (formato == "tidy") {
    m_mat <- as.matrix(similitud)
    r_names <- rownames(m_mat)
    n <- length(r_names)

    if (n < 2) {
      return(data.frame(
        sitio_1 = character(0),
        sitio_2 = character(0),
        similitud = numeric(0),
        disimilitud = numeric(0),
        stringsAsFactors = FALSE
      ))
    }

    pairs_list <- vector("list", n * (n - 1) / 2)
    idx <- 1
    for (i in seq_len(n - 1)) {
      for (j in (i + 1):n) {
        sim_val <- m_mat[i, j]
        pairs_list[[idx]] <- data.frame(
          sitio_1 = r_names[i],
          sitio_2 = r_names[j],
          similitud = round(sim_val, 4),
          disimilitud = round(1 - sim_val, 4),
          stringsAsFactors = FALSE
        )
        idx <- idx + 1
      }
    }
    tidy_df <- do.call(rbind, pairs_list)
    return(tidy_df)
  }

  similitud
}

#' Índice de Diversidad de Shannon-Wiener (H') (MINAM 2015)
#'
#' @param datos Data frame en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia. Por defecto \code{"abundancia"}.
#' @param base Base del logaritmo. Por defecto \code{2}.
#'
#' @return Data frame con el sitio y su respectivo valor de Shannon-Wiener (H').
#' @export
diversidad_shannon <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia",
                               base = 2) {
  if (is.matrix(datos)) {
    mat <- datos
  } else {
    mat <- long_to_comm(datos, sitio = sitio, especie = especie, abundancia = abundancia)
  }
  storage.mode(mat) <- "numeric"

  shannon_nat <- vegan::diversity(mat, index = "shannon")
  shannon_adjusted <- shannon_nat / log(base)

  data.frame(
    sitio = rownames(mat),
    shannon_h = as.numeric(shannon_adjusted),
    base_log = base,
    stringsAsFactors = FALSE
  )
}

#' Curva de Acumulación de Especies (MINAM 2015)
#'
#' @param datos Data frame en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia. Por defecto \code{"abundancia"}.
#' @param metodo Método de acumulación para \code{vegan::specaccum}. Por defecto \code{"random"}.
#' @param sustituciones Número de permutaciones cuando \code{metodo = "random"}. Por defecto \code{100}.
#'
#' @return Objeto de clase \code{specaccum}.
#' @export
curva_acumulacion <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia",
                              metodo = "random", sustituciones = 100) {
  if (is.matrix(datos)) {
    mat <- datos
  } else {
    mat <- long_to_comm(datos, sitio = sitio, especie = especie, abundancia = abundancia)
  }
  storage.mode(mat) <- "numeric"

  n_sites <- nrow(mat)
  if (n_sites <= 1) {
    stop("Se requieren al menos 2 sitios para calcular la curva de acumulacion.", call. = FALSE)
  }

  max_perms <- if (n_sites <= 10) factorial(n_sites) else sustituciones
  perms <- min(sustituciones, max_perms)

  suppressMessages(
    suppressWarnings(
      vegan::specaccum(mat, method = metodo, permutations = perms)
    )
  )
}

#' Índice de Equitabilidad de Pielou (J') (SINIA / MINAM Tabla 2.0-4)
#'
#' @param datos Data frame en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia. Por defecto \code{"abundancia"}.
#' @param base Base logarítmica utilizada en Shannon (2 por defecto).
#'
#' @return Data frame con el sitio, riqueza (S), Shannon (H') y Equitabilidad de Pielou (J').
#' @export
diversidad_pielou <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia",
                               base = 2) {
  if (is.matrix(datos)) {
    mat <- datos
  } else {
    mat <- long_to_comm(datos, sitio = sitio, especie = especie, abundancia = abundancia)
  }
  storage.mode(mat) <- "numeric"

  sh <- diversidad_shannon(mat, base = base)
  s <- vegan::specnumber(mat)

  max_h <- log(s) / log(base)
  j_prime <- ifelse(s > 1, sh$shannon_h / max_h, 0)

  data.frame(
    sitio = rownames(mat),
    riqueza = as.numeric(s),
    shannon_h = sh$shannon_h,
    pielou_j = as.numeric(j_prime),
    stringsAsFactors = FALSE
  )
}

#' Índice de Dominancia y Diversidad de Simpson (D y 1-D)
#'
#' @param datos Data frame en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia. Por defecto \code{"abundancia"}.
#'
#' @return Data frame con el sitio, dominancia de Simpson (D) e índice de Simpson (1 - D).
#' @export
diversidad_simpson <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia") {
  if (is.matrix(datos)) {
    mat <- datos
  } else {
    mat <- long_to_comm(datos, sitio = sitio, especie = especie, abundancia = abundancia)
  }
  storage.mode(mat) <- "numeric"

  simpson_inv <- vegan::diversity(mat, index = "simpson")
  simpson_d <- 1 - simpson_inv

  data.frame(
    sitio = rownames(mat),
    dominancia_simpson_d = as.numeric(simpson_d),
    diversidad_simpson_1_d = as.numeric(simpson_inv),
    stringsAsFactors = FALSE
  )
}

#' Coeficiente de Similitud de Sorensen-Dice
#'
#' @param datos Data frame en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia. Por defecto \code{"abundancia"}.
#'
#' @return Objeto de clase \code{dist} con los valores de similitud de Sorensen-Dice.
#' @export
diversidad_sorensen <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia") {
  if (is.matrix(datos)) {
    mat <- datos
  } else {
    mat <- long_to_comm(datos, sitio = sitio, especie = especie, abundancia = abundancia)
  }
  storage.mode(mat) <- "numeric"

  disim <- vegan::vegdist(mat, method = "bray", binary = TRUE)
  similitud <- 1 - disim
  similitud
}

#' Curvas de Dominancia-Abundancia de Whittaker (Rank-Abundance)
#'
#' Calcula los rangos de abundancia, proporciones relativas, frecuencias acumuladas y valores logaritmicos
#' para especies agrupadas por sitio o nivel general (pooled).
#'
#' @param datos Data frame con datos de inventario en formato long o matriz de comunidad.
#' @param sitio Nombre de la columna del sitio/parcela. Por defecto \code{"sitio"}.
#' @param especie Nombre de la columna de la especie. Por defecto \code{"especie"}.
#' @param abundancia Nombre de la columna de abundancia. Por defecto \code{"abundancia"}.
#' @param por_sitio Si es \code{TRUE}, genera curvas independientes por sitio; si es \code{FALSE}, agrupa la comunidad completa (pooled). Por defecto \code{TRUE}.
#'
#' @return Un data frame con columnas: \code{sitio}, \code{especie}, \code{rank}, \code{abundance}, \code{proportion}, \code{accumfreq}, \code{logabun}, \code{rankfreq}.
#' @export
curva_whittaker <- function(datos, sitio = "sitio", especie = "especie", abundancia = "abundancia", por_sitio = TRUE) {
  datos <- standardize_inventory(datos)

  if (!sitio %in% names(datos)) sitio <- "sitio"
  if (!especie %in% names(datos)) especie <- "especie"
  if (!abundancia %in% names(datos)) abundancia <- "abundancia"

  if (isTRUE(por_sitio)) {
    sitios_lista <- unique(datos[[sitio]])
    res_list <- list()

    for (s in sitios_lista) {
      sub_df <- datos[datos[[sitio]] == s, , drop = FALSE]
      sp_sum <- stats::aggregate(
        sub_df[[abundancia]],
        by = list(especie = sub_df[[especie]]),
        FUN = sum,
        na.rm = TRUE
      )
      names(sp_sum)[2] <- "abundance"
      sp_sum <- sp_sum[sp_sum$abundance > 0, , drop = FALSE]
      if (nrow(sp_sum) == 0) next

      sp_sum <- sp_sum[order(-sp_sum$abundance, sp_sum$especie), ]
      n_sp <- nrow(sp_sum)
      tot <- sum(sp_sum$abundance)

      sp_sum$rank <- 1:n_sp
      sp_sum$proportion <- (sp_sum$abundance / tot) * 100
      sp_sum$accumfreq <- cumsum(sp_sum$proportion)
      sp_sum$logabun <- log10(sp_sum$abundance)
      sp_sum$rankfreq <- (sp_sum$rank / n_sp) * 100
      sp_sum$sitio <- as.character(s)

      res_list[[length(res_list) + 1]] <- sp_sum[, c("sitio", "especie", "rank", "abundance", "proportion", "accumfreq", "logabun", "rankfreq")]
    }

    if (length(res_list) == 0) return(data.frame())
    do.call(rbind, res_list)
  } else {
    sp_sum <- stats::aggregate(
      datos[[abundancia]],
      by = list(especie = datos[[especie]]),
      FUN = sum,
      na.rm = TRUE
    )
    names(sp_sum)[2] <- "abundance"
    sp_sum <- sp_sum[sp_sum$abundance > 0, , drop = FALSE]
    if (nrow(sp_sum) == 0) return(data.frame())

    sp_sum <- sp_sum[order(-sp_sum$abundance, sp_sum$especie), ]
    n_sp <- nrow(sp_sum)
    tot <- sum(sp_sum$abundance)

    sp_sum$rank <- 1:n_sp
    sp_sum$proportion <- (sp_sum$abundance / tot) * 100
    sp_sum$accumfreq <- cumsum(sp_sum$proportion)
    sp_sum$logabun <- log10(sp_sum$abundance)
    sp_sum$rankfreq <- (sp_sum$rank / n_sp) * 100
    sp_sum$sitio <- "General (Pooled)"

    sp_sum[, c("sitio", "especie", "rank", "abundance", "proportion", "accumfreq", "logabun", "rankfreq")]
  }
}

#' Grafico ggplot2 de Curvas de Dominancia-Abundancia de Whittaker
#'
#' Genera un grafico de ggplot2 para visualizar distribuciones de abundancia de especies (SAD).
#'
#' @param datos Data frame con datos de inventario.
#' @param scale Escala de abundancia en el eje Y: \code{"logabun"} (Log10 Abundancia), \code{"abundance"} (Absoluta), \code{"proportion"} (porcentaje Abundancia Relativa), \code{"accumfreq"} (porcentaje Frecuencia Acumulada). Por defecto \code{"logabun"}.
#' @param por_sitio Si es \code{TRUE}, grafica curvas por sitio; si es \code{FALSE}, agrupa la comunidad general. Por defecto \code{TRUE}.
#' @param top_n_labels Numero de especies top a etiquetar en el grafico. Por defecto \code{3}.
#'
#' @return Un objeto de clase \code{ggplot}.
#' @importFrom rlang .data
#' @export
plot_whittaker <- function(datos, scale = "logabun", por_sitio = TRUE, top_n_labels = 3) {
  df_rank <- curva_whittaker(datos, por_sitio = por_sitio)
  if (nrow(df_rank) == 0) return(ggplot2::ggplot() + ggplot2::labs(title = "Sin datos de abundancia"))

  y_var <- switch(
    scale,
    "logabun" = "logabun",
    "abundance" = "abundance",
    "proportion" = "proportion",
    "accumfreq" = "accumfreq",
    "logabun"
  )

  y_lab <- switch(
    scale,
    "logabun" = "Abundancia Log10",
    "abundance" = "Abundancia Absoluta (N\u00b0 Ind)",
    "proportion" = "Abundancia Relativa (%)",
    "accumfreq" = "Frecuencia Acumulada (%)",
    "Abundancia Log10"
  )

  p <- ggplot2::ggplot(df_rank, ggplot2::aes(x = .data$rank, y = .data[[y_var]], color = .data$sitio, group = .data$sitio)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_point(size = 2.5) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Curvas de Dominancia-Abundancia (Whittaker Rank-Abundance)",
      subtitle = paste0("Escala: ", y_lab),
      x = "Rango de Especies (Rank 1..S)",
      y = y_lab,
      color = "Sitio / Parcela"
    )

  if (top_n_labels > 0) {
    df_top <- df_rank[df_rank$rank <= top_n_labels, , drop = FALSE]
    if (nrow(df_top) > 0) {
      p <- p + ggplot2::geom_text(
        data = df_top,
        ggplot2::aes(x = .data$rank, y = .data[[y_var]], label = .data$especie),
        vjust = -0.7,
        size = 3.2,
        show.legend = FALSE
      )
    }
  }

  p
}
