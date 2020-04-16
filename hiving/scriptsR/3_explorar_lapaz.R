# Diego Villamil, Hiving
# CDMX, 15 de abril de 2020


source("../src/data/utilities.R")

conn <- conectar_postgres("mediciones")

general   <- tbl(conn, "rwd_general" ) %>% collect()
canales   <- tbl(conn, "rwd_channels") %>% collect()
registros <- tbl(conn, "rwd_records" ) %>% collect()

write_feather(general,   "../data/raw/lapaz_general.feather")
write_feather(canales,   "../data/raw/lapaz_canales.feather")
write_feather(registros, "../data/raw/lapaz_registros.feather")

canales_0 <- canales %>% 
  group_by(serial_num) %>% 
  mutate(n_vueltas = n()) %>% ungroup() %>% 
  arrange(desc(n_vueltas), serial_num) %>% 
  select(channel_desc, serial_num, n_vueltas, units, measure_desc)


