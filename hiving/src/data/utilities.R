# Diego Villamil, Turbine
# CDMX, 27 de marzo de 2020

# Preparación -----------------------------------------

library(readxl)
library(RPostgres)


char2regex <- function (x) str_c(x, collapse="|") %>% sprintf("(%s)", .) 


# Funciones -------------------------------------------

conectar_postgres <- function (dbname) {
  conn <- dbConnect(Postgres(), 
    dbname = dbname, 
    host   = Sys.getenv("PSQL_HOST"), 
    user   = Sys.getenv("PSQL_USER"),
    password = Sys.getenv("PSQL_PASS"))
  return (conn)
}


tm_leer_archivo <- function (direccion, fuente="la_paz") {
switch (fuente, 
lapaz = {          
  
  ## 0. Obtener meta informacion del archivo. 
  tm_obj <- list(archivo = archivo, general = NA, 
                 canales = NA, registros = NA)
  
  claves <- c("SDR", "Logger Info", "Site Info", 
              "Sensor Info", "Channel", "Date & Time") 
  claves_regex <- char2regex(claves)  
  
  two_cols <- c("...1", "...2")
  crudisimo <- read_excel(direccion, 
      col_names=two_cols, col_types="text", range="A1:B500")
  
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
  info_general_ <- read_excel(direccion, 
        col_names=two_cols, col_types="text",
        n_max=indices$`Sensor Info` - 1) %>% 
    filter(!is.na(...1))
  
  cols_general <- info_general_$...1 %>% 
    subset(!str_detect(., "-----"))
  info_general <- info_general_ %>% 
    spread(...1, ...2) %>% 
    select_at(cols_general) %>% 
    mutate_at("Site Elevation", ~str_replace(., "m", "") %>% as.numeric())
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
  canales <- read_excel(direccion, 
        col_names=two_cols, col_types="text", 
        skip=min(indices$Channel) - 1,
        n_max=n_canales * k_info) %>% 
    mutate(k_canal = ceiling(row_number()/k_info)) %>% 
    filter(!is.na(...1)) %>% 
    spread(...1, ...2, convert=TRUE) %>% 
    select(-k_canal) %>% 
    mutate_at("Height", ~str_replace(., "m", "") %>% as.numeric())
  tm_obj[["canales"]] <- canales
  
  
  # 3. Registros de los canales. 
  if (length(indices$`Date & Time`) != 1) {
    warning ("No se encontró fila que empiece con 'Date & Time'")
    return (tm_obj)
  }
  
  reg_types <- c("date", rep("numeric", 4*n_canales))
  registros <- read_excel(direccion,
        col_types=reg_types, skip=indices$`Date & Time` - 1) %>% 
    mutate(record_len = `Date & Time Stamp` %>% 
        subtract(lead(.), .) %>% as.numeric()) %>% 
    set_names(names(.) %>% str_replace("(\\d{1,2})", "\\1_")) %>% 
    gather(aux, value, -`Date & Time Stamp`, -record_len) %>% 
    filter(!is.na(value)) %>% 
    separate(aux, c("channel", "aux_stat")) %>% 
    mutate_at("channel", 
        ~str_replace(., "CH", "") %>% as.numeric()) %>% 
    spread(aux_stat, value, fill=NA) %>% 
    select(`Date & Time Stamp`, record_len, channel, 
        record_avg = Avg, record_sd = SD, record_min = Min, record_max = Max)
  
  tm_obj[["registros"]] <- registros
  
  return (tm_obj)
}
)}
  

tm_ajustar_objeto <- function (obj_tm, fuente="lapaz" ) { 
switch (fuente, 
lapaz = {
  lapaz_cols <- read_csv("../references/sql_tables/lapaz_cols.csv",
                         col_types=cols())
  
  rename_quos <- c("general", "channels", "records") %>% set_names(., .) %>% 
      map(.f = ~filter(lapaz_cols, tabla == .x, 
              !is.na(nombre_in), !is.na(nombre_out)) %$% 
              set_names(nombre_in, nombre_out))
    
  lapaz_regex <- "(TM.{1,2}) ([0-9]{8})-([0-9]{8}).xlsx"
  info_nombres <- c("filename", "tm", "start_date", "end_date")
  
  tm_info <- basename(obj_tm[["archivo"]]) %>% 
    str_match(lapaz_regex) %>% as.vector() %>% 
    set_names(info_nombres)
  
  # Usar MUTATE_AT
  general_mod <- obj_tm[["general"]] %>% 
    mutate(filename = tm_info["filename"], 
        tm_file     = tm_info["tm"], 
        start_date  = tm_info["start_date"], 
        end_date    = tm_info["end_date"]) %>% 
    mutate_at(c("start_date", "end_date"), ymd) %>% 
    mutate(Desc = glue("{`Project Desc`} / {`Site Desc`}")) %>% 
    rename(!!!rename_quos$general)
  
  drop_canales <- lapaz_cols %>% 
    filter(tabla == "channels") %$%
    nombre_in[is.na(nombre_out)]
    
  canales_0 <- obj_tm[["registros"]][["channel"]] %>% unique()
  canales_mod_ <- obj_tm[["canales"]] %>% 
    filter(`Channel #` %in% canales_0) %>% 
    mutate(measure_serial = general_mod$serial_num,
          measure_desc = general_mod$description[1]) %>% 
    mutate_at("Serial Number", ~if_else(is.na(.), 
          glue("{measure_desc} / {Description}"), .)) %>% 
    rename(!!!rename_quos$channels) 
  
  registros_mod <- canales_mod_ %>% 
    select(channel_serial = serial_num, chn_join = `Channel #`) %>% 
    right_join(by=c("chn_join" = "channel"), 
        obj_tm[["registros"]]) %>% select(-chn_join) %>% 
    mutate(measure_serial = general_mod$serial_num, 
          measure_desc = general_mod$description) %>% 
    rename( !!!rename_quos$records) 
  
  canales_mod <- canales_mod_ %>% 
    select(-one_of(drop_canales)) %>% 
    mutate(warnings = case_when(
          is.na(as.numeric(serial_num)) ~ "Serial Number",
          TRUE ~ as.character(NA)), 
       serial_num = str_extract(serial_num, "\\d*") %>% 
          as.numeric())
  
  new_tm <- list(archivo = obj_tm[["archivo"]], 
                 general = general_mod, 
                 channels = canales_mod, 
                 records  = registros_mod)
  return (new_tm)
})}


tm_subir_sql <- function (obj_tm, conn, fuente="lapaz") {
switch (fuente, 
lapaz = {
  # OBJ_TM cuenta con 3 campos: GENERAL, CANALES, REGISTROS.
  message("\tCargando renglón general.") 
  dbWriteTable(conn, "rwd_general",  obj_tm$general, append=TRUE)
  
  message("\tCargando renglón channels.\n")
  dbWriteTable(conn, "rwd_channels", obj_tm$channels, append=TRUE)
  
  message("\tCargando renglón records.\n")
  dbWriteTable(conn, "rwd_records",  obj_tm$records, append=TRUE)
})
}
  















