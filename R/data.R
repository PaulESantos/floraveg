#' Datos de Observaciones de Vegetacion de Dunas (Dune Dataset en Formato Largo)
#'
#' Conjunto de datos de observaciones de 30 especies de vegetacion en 20 sitios en dunas holandesas
#' (Jongman et al., 1987), formateado en estructura larga (sitio/plot, especie/species, abundancia/abundance).
#'
#' @format Un \code{data.frame} con 197 filas y 3 columnas:
#' \describe{
#'   \item{plot}{Identificador de la parcela / sitio (1 al 20).}
#'   \item{species}{Nombre abreviado o cientifico de la especie (30 especies).}
#'   \item{abundance}{Conteo / abundancia observada de la especie en el sitio.}
#' }
#' @source Jongman, R.H.G., ter Braak, C.J.F. & van Tongeren, O.F.R. (1987). \emph{Data Analysis in Community and Landscape Ecology}. Pudoc, Wageningen.
#' @docType data
#' @keywords datasets
#' @name dune_t
#' @usage data(dune_t)
"dune_t"

#' Datos de Inventario de Arboles en la Isla Barro Colorado (BCI Dataset en Formato Largo)
#'
#' Registro de inventario de arboles en 50 parcelas de 1 hectarea en la Isla Barro Colorado (BCI, Panama;
#' Zanne et al., 2014; Condit et al., 2002) con 225 especies arboreas, formateado en estructura larga
#' (sitio/plot, especie/species, abundancia/abundance).
#'
#' @format Un \code{data.frame} con 4539 filas y 3 columnas:
#' \describe{
#'   \item{plot}{Identificador de la parcela / sitio de 1 ha (1 al 50).}
#'   \item{species}{Nombre cientifico completo actualizado de la especie arborea (225 especies).}
#'   \item{abundance}{Numero de individuos registrados para la especie en la parcela.}
#' }
#' @source Zanne, A.E. et al. (2014). Three keys to the terrestrial biodiversity of Barro Colorado Island. \emph{Dryad Digital Repository}.
#' @docType data
#' @keywords datasets
#' @name bci_t
#' @usage data(bci_t)
"bci_t"
