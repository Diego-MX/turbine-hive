
# Diego Villamil, Turbine
# CDMX, 27 de marzo de 2020


# Preparación -----------------------------------------

library(readxl)

char2regex <- function (x) 
    str_c(x, collapse="|") %>% sprintf("(%s)", .) 


# Funciones -------------------------------------------

conectar_postgres <- function (...) {
  conn <- dbConnect(ODBC())
  return (conn)
}


tm_leer_archivo <- function (direccion, fuente="la_paz") {
  
switch (fuente, 
la_paz = {          
  
  ## 0. Obtener meta informacion del archivo. 
  tm_obj <- list(general = NA, canales = NA, registros = NA)
  
  claves <- c("SDR", "Logger Info", "Site Info", 
              "Sensor Info", "Channel", "Date & Time") 
  claves_regex <- char2regex(claves)  
  
  crudisimo <- read_excel(direccion, col_names=FALSE, n_max=1000)
  
  filas <- crudisimo$...1 %>% { tibble(
      indice = str_which(., claves_regex), 
      nombre = str_subset(., claves_regex), 
      clave  = str_extract(., claves_regex)[indice]
  )}
  
  indices <- claves %>% 
    set_names(., .) %>% 
    map(~(filas %$% indice[clave == .x]))
  

  # 1. Información General. 
  indices_no_unicos <- map_dbl(indices, length) %>% 
      discard(~(. == 1)) %>% names()
  if (indices_no_unicos != "Channel") {
    warning ("El único índice no único es Channel.")
    return (tm_obj)
  }
  
  indices_no_ordenados <- is.unsorted(indices %>% 
      unlist(use.names=FALSE))
  if (indices_no_ordenados) {
    warning ("\tLos índices no están ordenados de acuerdo a:\n", 
             "\tSDR, Logger, Site, Sensor, Channel, registros.")
    return (tm_obj) 
  }
  
  indices_general <- indices %>% 
    extract(1: (which(names(.) == "Sensor Info"))) %>% 
    unlist()
  info_general_ <- read_excel(direccion, col_names=FALSE, 
        n_max=ind_sensor <- indices$`Sensor Info` - 1) %>% 
    filter(!is.na(...1))
  
  cols_general <- info_general_$...1 %>% 
    subset(!str_detect(., "-----"))
  info_general <- info_general_ %>% 
    spread(...1, ...2) %>% 
    select_at(cols_general) %>% 
    mutate_at("Site Elevation", 
        ~str_replace(., "m", "") %>% as.numeric())
  tm_obj[["general"]] <- info_general
  
  
  # 2. Información de los canales
  k_infos <- diff(indices$Channel) 
  if (n_distinct(k_infos) == 1) {
    k_info <- unique(k_infos) 
    n_canales <- length(indices$Channel)
  } else {
    warning ("Distancias entre canales debe ser igual")
    return (tm_obj)
  }
  
  if (max(indices$Channel) + k_info != indices$`Date & Time`) {
    warning ("Revisar distance de Date & Time y el último Channel.")
    return (tm_obj)
  }
  canales <- read_excel(direccion, col_names=FALSE, 
        skip=min(indices$Channel) - 1, n_max=n_canales * k_info) %>% 
    mutate(k_canal = ceiling(row_number()/k_info)) %>% 
    filter(!is.na(...1)) %>% 
    spread(...1, ...2, convert=TRUE) %>% 
    select(-k_canal) %>% 
    mutate_at("Height", ~str_replace(., "m", "") %>% as.numeric())
  tm_obj[["canales"]] <- canales
  
  
  # 3. Registros de los canales. 
  registros_cols <- paste0("Ch", 1:n_canales) %>% 
    outer(c("Avg", "SD", "Max", "Min"), str_c) %>% t() %>% 
    c("Date & Time Stamp", .)
    
  if (length(indices$`Date & Time`) != 1) {
    warning ("No se encontró fila que empiece con 'Date & Time'")
    return (tm_obj)
  }
  
  registros <- read_excel(direccion, 
        skip=indices$`Date & Time` - 1) %>% 
    set_names(names(.) %>% str_replace("(\\d{1,2})", "\\1_")) %>% 
    gather(aux, valor, -`Date & Time Stamp`) %>% 
    filter(!is.na(valor)) %>% 
    separate(aux, c("canal", "aux_stat")) %>% 
    mutate_at("canal", 
        ~str_replace(., "CH", "") %>% as.numeric()) %>% 
    spread(aux_stat, valor, fill = NA) %>% 
    select(`Date & Time Stamp`, canal, Avg, SD, Min, Max)
  
  tm_obj[["registros"]] <- registros
  
  return (tm_obj)
}
)}
  


tm_ajustar_general <- function (obj_tm, direccion, fuente="lapaz") {
switch (fuente, 
lapaz = {
  lapaz_regex <- "(TM.{1,2}) ([0-9]{8})-([0-9]{8}).xlsx"
  info_nombres <- c("name", "tm", "start_date", "end_date")
  
  tm_info <- basename(direccion) %>% 
    str_match(lapaz_regex) %>% as.vector() %>% 
    set_names(info_nombres)
    
  # Usar MUTATE_AT
  general_mod <- obj_tm[["general"]] %>% 
    mutate(tm  =  tm_info["tm"], 
        name   =  tm_info["name"], 
        end_date = tm_info["end_date"], 
        start_date = tm_info["start_date"]) %>% 
    mutate_at(ends_with("date"), ymd)
  
  tm_obj$general <- general_mod
  return (tm_obj)
})}


tm_subir_sql <- function (obj_tm, conn = NULL) {
  # OBJ_TM cuenta con 3 campos: GENERAL, CANALES, REGISTROS.
  if (is.null(conn)) {
    conn <- dbConnect(...)
  }
  
  tm_cols <- read_csv("../references/sql_tables/lapaz_cols.csv")
  
  
  
  
  # REVISAR valores NULOS.
  
  # https://www.rdocumentation.org/packages/RODBC/versions/1.3-16/topics/sqlSave
  general <- obj_tm$general %>% 
    
  
  
  sqlSave(conn, )
  
  
  
}
  















