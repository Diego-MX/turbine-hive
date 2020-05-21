# Diego Villamil, Turbine
# CDMX, 26 de marzo de 2020


source("../src/data/utilities.R")

conn <- conectar_postgres("mediciones")


# Datos de La Paz -------------------------

lapaz_dir <- "../data/raw/wind_data/lapaz" 
archivo <- list.files(lapaz_dir, full=TRUE)[1]

for (archivo in lapaz_dir %>% list.files(full=TRUE) ) {
  
  message ("Procesando archivo: %s\n" %>% sprintf(archivo))
  tm_obj_0 <- tm_leer_archivo(archivo, "lapaz") 
  tm_obj <- tm_ajustar_objeto(tm_obj_0, "lapaz")
  tm_subir_sql(tm_obj, conn, "lapaz")

}

dbDisconnect(conn)

