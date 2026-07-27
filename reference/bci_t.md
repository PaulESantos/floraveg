# Datos de Inventario de Arboles en la Isla Barro Colorado (BCI Dataset en Formato Largo)

Registro de inventario de arboles en 50 parcelas de 1 hectarea en la
Isla Barro Colorado (BCI, Panama; Zanne et al., 2014; Condit et al.,
2002) con 225 especies arboreas, formateado en estructura larga
(sitio/plot, especie/species, abundancia/abundance).

## Usage

``` r
data(bci_t)
```

## Format

Un `data.frame` con 4539 filas y 3 columnas:

- plot:

  Identificador de la parcela / sitio de 1 ha (1 al 50).

- species:

  Nombre cientifico completo actualizado de la especie arborea (225
  especies).

- abundance:

  Numero de individuos registrados para la especie en la parcela.

## Source

Zanne, A.E. et al. (2014). Three keys to the terrestrial biodiversity of
Barro Colorado Island. *Dryad Digital Repository*.
