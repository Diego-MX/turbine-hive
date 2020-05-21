# Diego Villamil, Turbine Hive
# CDMX, 13 de mayo de 2020

# Seguimos el blog: 
# https://cran.rstudio.com/web/packages/sweep/vignettes/SW01_Forecasting_Time_Series_Groups.html



library(timetk)
analysis <- FALSE 

wind_speed <- read_feather("../data/explore/lapaz_wind.feather") %>% 
  arrange(record_ts) %>% 
    group_by(record_ts) %>% 
    summarize(wind_ts  = mean(wind_speed), 
         wind_channel  = wind_channel[1]) %>% 
  complete(record_ts = record_ts %>% {seq(min(.), max(.), by=600)}) %>% 
  fill(starts_with("wind"), .direction="down") 
  

if (analysis) {
  wind_lags <- wind_speed %>% 
    filter(is.na(wind_speed) | is.na(lag(wind_speed)) | is.na(lead(wind_speed)))

  
    
  wind_summary <- wind_speed %>% 
    tk_index() %>% tk_get_timeseries_summary() %>% glimpse()
  
}


wind_speed %>% complete(seq(min()))

wind_aug <- wind_speed %>% select(-wind_channel) %>% 
  tk_augment_timeseries_signature(.date_var="record_ts") %>% 
  select(-index.num, )









