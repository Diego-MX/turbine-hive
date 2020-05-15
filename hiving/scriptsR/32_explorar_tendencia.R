# Diego Villamil, Turbine Hive
# CDMX, 13 de mayo de 2020

# Seguimos el blog: 
# https://www.r-bloggers.com/tidy-time-series-analysis-part-1/


library(tidmetk)

wind_speed <- read_feather("../data/explore/lapaz_wind.feather") %>% 
  arrange(record_ts) %>% 
  complete(record_ts = record_ts %>% {seq(min(.), max(.), by=600)}) %>% 
  fill(starts_with("wind"), .direction = "down") 




  
wind_lags <- wind_speed %>% 
  filter(is.na(wind_speed) | is.na(lag(wind_speed)) | is.na(lead(wind_speed)))

wind_summary <- wind_speed %>% 
  tk_index() %>% tk_get_timeseries_summary() %>% glimpse()

wind_speed %>% complete(seq(min()))


wind_aug <- wind_speed %>% select(-wind_channel) %>% 
  tk_augment_timeseries_signature(.date_var = "record_ts") %>% 
  select(-index.num,)
