cran_repo <- getOption("repos")
cran_repo["CRAN"] <- "https://cran.itam.mx/"
options(repos=cran_repo)
rm(cran_repo)

if (interactive()) try(fortunes::fortune(), silent=TRUE)

file_at <- function (file, ...) file.path(..., file)

classes <- function (df) { tibble(
    name  = names(df), 
    class = sapply(df, . %>% {class(.)[1]} )
)}

extract_from <- function (y, x) x[y]

expand_positions <- function (x, x_end = NA) {
  if (is.unsorted(x)) 
    stop ("Vector X must be ordered.")
  
  if (is.na(x_end)) 
    x_end <- x[length(x)] - 1
  
  x <- unname(x)
  y <- x[1]:x_end %>% 
    cut(breaks = x, right = FALSE, labels = FALSE) %>% 
    extract_from(x)
  
  return (y)    
}





# Para incorporar Conda, 
# https://community.rstudio.com/t/why-not-r-via-conda/9438/4

# .libPaths(new=c('<conda home>/envs/env_name/lib/R/library', 
#                   '<path to external>')

if (FALSE) {
  # Revisar código
  startCondaEnv = function (env_name, lib='/home/balter/R') {
    cat("pointing to conda env: %s and lib location\n" %>% 
        sprintf(env_name, lib))
  
    r_lib_path = lib
    if (env_name == "" || env_name == "base") {
      #print("using default base env")
      conda_lib_path = file.path('/home/balter/conda/lib/R/library')
    } else {
      conda_lib_path = file.path('/home/balter/conda/envs', 
        env_name, 'lib/R/library')
    }
    #cat('conda_lib_path: ', conda_lib_path, '\n')
    .libPaths(new=c(conda_lib_path, r_lib_path))
    
    #cat(".libPaths():\n")
    print(.libPaths())
  }
  
  
  current_conda_env = Sys.getenv('CONDA_DEFAULT_ENV')
  cat('current_conda_env:', current_conda_env, '\n')
  
  current_conda_prefix = Sys.getenv('CONDA_PREFIX')
  cat('current_conda_prefix:', current_conda_prefix, '\n')
  
  if (current_conda_env != "") {
    r_version = R.Version()
    r_version = paste0(r_version$major, '.', r_version$minor)
  
    if (r_version == '3.5.1') {
        r_lib_path = '/home/balter/R35'
    } else { 
      if (r_version == '3.4.11') {
        r_lib_path = '/home/balter/R34'
      } else {
        message("no compatible lib")
        r_lib_path = ''
      }
    }
    #cat("env: ", current_conda_env, ", prefix: ", current_conda_prefix, "\n")
    conda_env_lib = file.path(current_conda_prefix,'lib/R/library')
    startCondaEnv(current_conda_env, lib=r_lib_path)
  } else {
    print("no conda env")
  }

}
