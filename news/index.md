# Changelog

## floraveg 0.0.0.9000

- Version inicial de desarrollo del paquete `floraveg`.
- Implementación de estandarización y validación de esquemas de datos de
  inventario con
  [`standardize_inventory()`](https://paulesantos.github.io/floraveg/reference/standardize_inventory.md),
  [`validate_inventario()`](https://paulesantos.github.io/floraveg/reference/validate_inventario.md)
  y `df_to_community_matrix()`.
- Funciones de análisis de diversidad alfa y beta
  ([`diversidad_alfa()`](https://paulesantos.github.io/floraveg/reference/diversidad_alfa.md),
  [`diversidad_beta()`](https://paulesantos.github.io/floraveg/reference/diversidad_beta.md),
  [`diversidad_shannon()`](https://paulesantos.github.io/floraveg/reference/diversidad_shannon.md),
  [`diversidad_pielou()`](https://paulesantos.github.io/floraveg/reference/diversidad_pielou.md),
  [`diversidad_simpson()`](https://paulesantos.github.io/floraveg/reference/diversidad_simpson.md),
  [`diversidad_sorensen()`](https://paulesantos.github.io/floraveg/reference/diversidad_sorensen.md),
  [`curva_acumulacion()`](https://paulesantos.github.io/floraveg/reference/curva_acumulacion.md),
  `ajustar_modelos_acumulacion()`, `predict_acumulacion_especies()`,
  [`curva_whittaker()`](https://paulesantos.github.io/floraveg/reference/curva_whittaker.md),
  [`plot_whittaker()`](https://paulesantos.github.io/floraveg/reference/plot_whittaker.md)).
- Funciones de estructura forestal e Índice de Valor de Importancia
  (`abundancia_absoluta_relativa()`, `frecuencia_absoluta_relativa()`,
  [`area_basal()`](https://paulesantos.github.io/floraveg/reference/area_basal.md),
  `cobertura_copa()`,
  [`densidad_poblacional()`](https://paulesantos.github.io/floraveg/reference/densidad_poblacional.md),
  [`distribucion_diametrica()`](https://paulesantos.github.io/floraveg/reference/distribucion_diametrica.md),
  `calcular_ivi()`, `clasificar_posicion_sociologica()`,
  `analizar_regeneracion_natural()`).
- Estimación de biomasa leñosa aérea (AGB) según modelos alométricos de
  Chave et al. (2014) y volumen maderable con base de datos de densidad
  de madera neotropical (`calcular_biomasa_agb()`,
  `calcular_volumen_maderable()`,
  [`obtener_densidad_madera()`](https://paulesantos.github.io/floraveg/reference/obtener_densidad_madera.md)).
- Aplicación web interactiva completa en Shiny accesible mediante
  [`run_floraveg()`](https://paulesantos.github.io/floraveg/reference/run_floraveg.md)
  y lanzadores de módulos independientes
  ([`run_mod_modelo_datos()`](https://paulesantos.github.io/floraveg/reference/run_modules.md),
  [`run_mod_diversidad()`](https://paulesantos.github.io/floraveg/reference/run_modules.md),
  [`run_mod_estructura()`](https://paulesantos.github.io/floraveg/reference/run_modules.md),
  [`run_mod_biomasa()`](https://paulesantos.github.io/floraveg/reference/run_modules.md),
  [`run_mod_ivi()`](https://paulesantos.github.io/floraveg/reference/run_modules.md),
  [`run_mod_codigo_r()`](https://paulesantos.github.io/floraveg/reference/run_modules.md)).
