# Especificar el repositorio para descargar paquetes... Yay ITAM. 
cran_repo <- getOption("repos")
cran_repo["CRAN"] <- "https://cran.itam.mx/"
options(repos=cran_repo)
rm(cran_repo)

# Frases motivadoras
if (interactive()) try(fortunes::fortune(), silent=TRUE)

# Cambiar el orden de los argumentos resulta bien útil en ocasiones. 
file_at <- function (file, ...) file.path(..., file)

extract_from <- function (y, x) x[y]

# Para explorar tablas rápidamente. 
classes <- function (df) { tibble(
    name  = names(df), 
    class = sapply(df, . %>% {class(.)[1]})
)}





