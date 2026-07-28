# floraveg 0.0.0.9000

* Version inicial de desarrollo del paquete `floraveg`.
* Implementación de estandarización y validación de esquemas de datos de inventario con `standardize_inventory()`, `validate_inventario()` y `df_to_community_matrix()`.
* Funciones de análisis de diversidad alfa y beta (`diversidad_alfa()`, `diversidad_beta()`, `diversidad_shannon()`, `diversidad_pielou()`, `diversidad_simpson()`, `diversidad_sorensen()`, `curva_acumulacion()`, `ajustar_modelos_acumulacion()`, `predict_acumulacion_especies()`, `curva_whittaker()`, `plot_whittaker()`).
* Funciones de estructura forestal e Índice de Valor de Importancia (`abundancia_absoluta_relativa()`, `frecuencia_absoluta_relativa()`, `area_basal()`, `cobertura_copa()`, `densidad_poblacional()`, `distribucion_diametrica()`, `calcular_ivi()`, `clasificar_posicion_sociologica()`, `analizar_regeneracion_natural()`).
* Estimación de biomasa leñosa aérea (AGB) según modelos alométricos de Chave et al. (2014) y volumen maderable con base de datos de densidad de madera neotropical (`calcular_biomasa_agb()`, `calcular_volumen_maderable()`, `obtener_densidad_madera()`).
* Aplicación web interactiva completa en Shiny accesible mediante `run_floraveg()` y lanzadores de módulos independientes (`run_mod_modelo_datos()`, `run_mod_diversidad()`, `run_mod_estructura()`, `run_mod_biomasa()`, `run_mod_ivi()`, `run_mod_codigo_r()`).
