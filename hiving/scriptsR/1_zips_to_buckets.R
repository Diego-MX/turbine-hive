# Diego Villamil, Turbine
# CDMX, 26 de marzo de 2020

# WindData, WindYucatan son zipfile que encontramos aparte. 
# La extracción se hace manual porque está desordenada. 

source("../src/data/utilities.R")

lapaz_psql <- conectar_postgres("mediciones")

# Se le cambió el nombre. 
lapaz_dir <- "../data/raw/wind_data/Mesa La Paz" 
  

for (archivo in lapaz_dir %>% list.files(full=TRUE) ) {
  tm_obj <- tm_leer_archivo(archivo, "lapaz") 
  tm_obj <- tm_ajustar_general(tm_obj, c_fila[["direccion"]])
  tm_subir_sql(tm_obj, lapaz_sql, "lapaz")
}

