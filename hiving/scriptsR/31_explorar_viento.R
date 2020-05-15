# Diego Villamil, Hiving
# CDMX, 26 de abril de 2020


source("../src/data/utilities.R")

registros_file <- "../data/interim/lapaz"
analisis <- FALSE

if (registros_file %>% file.exists() %>% not()) {
  conn <- conectar_postgres("mediciones") 
  
  general   <- tbl(conn, "rwd_general" ) %>% collect() %>% 
    mutate_if(is.character, str_trim)
  canales   <- tbl(conn, "rwd_channels") %>% collect() %>% 
    mutate_if(is.character, str_trim)
  registros <- tbl(conn, "rwd_records" ) %>% collect() %>% 
    mutate_if(is.character, . %>% str_trim)

  write_feather(general,   "../data/interim/lapaz/general.feather")
  write_feather(canales,   "../data/interim/lapaz/canales.feather")
  write_feather(registros, "../data/interim/lapaz/registros.feather")
  
  dbDisconnect(conn)
    
} else {
  general   <- read_feather("../data/interim/lapaz/general.feather") 
  canales   <- read_feather("../data/interim/lapaz/canales.feather")
  registros <- read_feather("../data/interim/lapaz/registros.feather") 
}

canales_1 <- canales %>% 
  mutate(channel_by = serial_num %>% as.character() %>% 
      coalesce(glue("{measure_desc} / {channel_desc}") %>% 
      as.character() )) %>% 
  group_by(channel_by) %>% 
  mutate(k_reps = n()) %>% 
  ungroup() %>% 
  arrange(desc(k_reps), channel_by) %>% 
  select(channel_by, channel_desc, serial_num, units, k_reps, 
      measure_desc, height, scale_fct, channel_offset, units, 
      measure_serial)

canales_0 <- canales_1 %>% 
  select(channel_by, channel_desc, serial_num, 
         units, measure_desc) %>% unique() %>% 
  filter(units == "m/s ")


registros_0 <- registros %>% 
  semi_join(by = c("channel_serial" = "channel_by"), canales_0) %>% 
  select(channel_serial, measure_desc, 
      record_ts, record_avg, measure_serial)



# Graficas de registros ---------------------------------------------------

if (analisis) {
  reg_mensual <- registros_0 %>% 
    mutate(fecha_mes = floor_date(record_ts, "month")) %>% 
    group_by(fecha_mes, channel_serial) %>% 
    summarize(n_cuenta = n(), 
              record_avg = mean(record_avg)) %>% 
    inner_join(canales_0, by = c("channel_serial" = "channel_by")) %>% 
    mutate_at("channel_serial", . %>% str_replace_all(" / ", "\n"))
  
  gg_mensual <- reg_mensual %>% 
      ggplot(aes(fecha_mes, record_avg, color = channel_serial)) +
      facet_wrap(~measure_desc, scales = "free_y") +
      geom_line() + 
      labs(x = NULL, y = NULL) + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1), 
          legend.position = "bottom") + 
      guides(color = guide_legend(nrow=6,byrow=TRUE))
  
  print(gg_mensual)
  
  ggsave(plot = gg_mensual, height = 9, width = 16, dpi = 100, 
      "../reports/figures/lapaz/velocidad mensual.png")  
  
  gg_torre_sur <- reg_mensual %>% 
    filter(str_detect(measure_desc, "Sur"), 
           channel_serial != "0") %>% 
    ggplot(aes(fecha_mes, record_avg, color = channel_serial)) +
      facet_wrap(~channel_serial) +
      geom_line() + 
      labs(x = NULL, y = NULL) + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
      guides(color = guide_legend(nrow=6,byrow=TRUE))
      
  print(gg_torre_sur)
}


# Experimetno de dependientes diario ---------------------------

if (analisis) {
  registros_diarios <- registros_0 %>% 
    mutate(date_record = as.Date(record_ts), 
          record_hr = hour(record_ts), 
          is_12 = record_hr == 12, is_18 = record_hr == 18) %>% 
    group_by(date_record) %>% 
    summarize(n_records  = n(), 
          n_channels = n_distinct(channel_serial), 
          stdev_rcrd = sd(record_avg), 
          record_avg = mean(record_avg), 
          record_max = max(record_avg), 
          record_12  = sum(record_avg*is_12)/sum(is_12),
          record_18  = sum(record_avg*is_18)/sum(is_18)) %>% 
    ungroup()
  
  gg_stats <- registros_diarios %>% 
    select(date_record, n_records, n_channels, stdev_rcrd) %>% 
    gather("stat", "value", -date_record) %>% 
    ggplot(aes(date_record, value, color = stat)) + 
      facet_wrap(~ stat, scales = "free_y") +
      geom_line()
  
  print(gg_stats)
  
  ggsave(plot = gg_stats, height = 9, width = 16, dpi = 100, 
         "../reports/figures/lapaz/stats_diaria.png")
  
  
  gg_diarios <- registros_diarios %>% 
    select(date_record, starts_with("record")) %>% 
    gather("tipo", "velocidad", starts_with("record"), na.rm = TRUE) %>% 
    mutate_at("tipo", ~str_replace(., "record_", "")) %>% 
    ggplot(aes(date_record, velocidad, color = tipo)) + 
      geom_line() 
  
  print(gg_diarios)
  
  ggsave(plot = gg_diarios, height = 9, width = 16, dpi = 100, 
    "../reports/figures/lapaz/velocidad_diaria.png")
}


# Una torre y agregado por hora ------------------------------------------------


# Tomamos las torres 105060, 15406 (a 40 mts altura)


reg_main_channels <- registros_0 %>% 
  select(channel_serial, rec = record_avg, record_ts) %>% {
  full_join(by = "record_ts", suffix = c("_105060", "_15406"), 
      filter(., channel_serial == "105060") %>% select(-channel_serial), 
      filter(., channel_serial ==  "15406") %>% select(-channel_serial))
  } %>% 
  mutate(wind_speed = coalesce(rec_105060, rec_15406), 
         wind_channel = if_else(!is.na(rec_105060), "105060", "15406")) %>% 
  select(-starts_with("rec_1")) 

write_feather(reg_main_channels, "../data/explore/lapaz_wind.feather")

# Pasamos a otro script para analizar tendencias. 










  


  










