if (!require(terra)) install.packages('terra')
if (!require(sf)) install.packages('sf')
library(terra)
library(sf)

rm(list=ls())
path <- Sys.getenv("DATA_PATH")
setwd(path)
sf_use_s2(FALSE)

owners <- rast("/carb_offsets/data/build_forest_ownership/input/built/forest_ownership_nofederal.tif")
owners <- aggregate(owners, fact=10/3, fun="modal", na.rm=TRUE)
owners <- aggregate(owners, fact=10, fun="modal")
owners_sf <- st_as_sf(as.polygons(owners,aggregate=FALSE))

st_write(owners_sf,dsn="carb_offsets/build_forest_parcels/output/forest_parcels1km.gpkg",append=FALSE)