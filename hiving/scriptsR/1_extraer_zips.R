# Diego Villamil, Hiving
# CDMX, 4 de abril de 2020

# Download "Wind Data.zip"
# Download "wind data yucatan edg3.zip"

dir0 <- "../data/raw"

zip1 <- file.path("Wind Data.zip", dir0)
dir1 <- file.path("wind_data", dir0)
zip2 <- file.path("wind data yucatan edg3.zip", dir0)
dir2 <- file.path("wind_yucatan", dir0)

dir.create(dir1)
unzip(zip1, junkpaths=T, exdir=dir1)

# ....

# Como hay muchos zips anidados con nombres feos, 
# hago la extracción manual. 

zip11 <- file.path(dir1, "Mesa La Paz Excel Data.zip")
dir11 <- file.path(dir1, "lapaz")

zip12 <- file.path(dir1, "20200316 Lupe.zip")
dir12 <- file.path(dir1, "lupe")



