# Diego Villamil, Hiving
# CDMX, 15 de abril de 2020


source("../src/data/utilities.R")

registros_file <- "../data/interim/lapaz_keep"
if (registros_file %>% file.exists() %>% not()) {
  conn <- conectar_postgres("mediciones") 
  
  general   <- tbl(conn, "rwd_general" ) %>% collect() %>% 
    mutate_if(is.character, . %>% str_replace(" +", " "))
  canales   <- tbl(conn, "rwd_channels") %>% collect() %>% 
    mutate_if(is.character, . %>% str_replace(" +", " "))
  registros <- tbl(conn, "rwd_records" ) %>% collect() %>% 
    mutate_if(is.character, . %>% str_replace(" +", " "))

  write_feather(general,   "../data/interim/lapaz_keep/general.feather")
  write_feather(canales,   "../data/interim/lapaz_keep/canales.feather")
  write_feather(registros, "../data/interim/lapaz_keep/registros.feather")
  
  dbDisconnect()
  
} else {
  general   <- read_feather("../data/interim/lapaz_keep/general.feather") %>% 
    mutate_if(is.character, . %>% str_replace_all(" +", " "))
  canales   <- read_feather("../data/interim/lapaz_keep/canales.feather")%>% 
    mutate_if(is.character, . %>% str_replace_all(" +", " "))
  registros <- read_feather("../data/interim/lapaz_keep/registros.feather")%>% 
    mutate_if(is.character, . %>% str_replace_all(" +", " "))
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
         units, measure_desc) %>% unique() 

registros_0 <- registros %>% 
  semi_join(by = c("channel_serial" = "channel_by"), canales_0) %>% 
  select(channel_serial, measure_desc, 
      record_ts, record_avg, measure_serial)



# Graficas de registros ---------------------------------------------------

reg_mensual <- registros_0 %>% 
  mutate(fecha_mes = floor_date(record_ts, "month")) %>% 
  group_by(fecha_mes, channel_serial) %>% 
  summarize(n_cuenta = n(), 
            record_avg = mean(record_avg)) %>% 
  inner_join(by = c("channel_serial" = "channel_by"), 
      canales_0) %>% 
  mutate_at("channel_serial", . %>% str_replace_all(" / ", "\n"))

gg_mensual <- reg_mensual %>% 
    ggplot(aes(fecha_mes, record_avg, 
        color = channel_serial)) +
    facet_grid(units~measure_desc, scales = "free_y") +
    geom_line() + 
    labs(x = NULL, y = NULL) + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        legend.position = "bottom") + 
    guides(color = guide_legend(nrow=6,byrow=TRUE))

print(gg_mensual)

ggsave(plot = gg_mensual, height = 9, width = 16, dpi = 100, 
    "../reports/figures/lapaz/mediciones mensual.png")  
    







    





