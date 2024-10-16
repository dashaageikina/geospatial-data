#assigning land cover variables to wildfires, separately for each year
#wildfire data is point-based
#I estimate land cover around each fire by approximating fire perimeters using data on acres burnt
if (!require(terra)) install.packages('terra')
if (!require(sf)) install.packages('sf')
if (!require(tidyverse)) install.packages('tidyverse')
if (!require(readxl)) install.packages('readxl')
library(terra)
library(sf)
library(tidyverse)
library(readxl)

rm(list=ls())

path <- "/Users/dariaageikina/Downloads/wildfires/data"
setwd(path)

#load data on incidents
incidents <- st_read("build_wildfire_reports/output/incidents_spatial.gpkg")
incidents <- filter(incidents,POO_state!="AK")
incidents <- subset(incidents,select=c(incident_id,start_year,final_acres))

#approximate fire perimeters
incidents$final_sq_m <- incidents$final_acres*4046.8564224
incidents$radius <- sqrt(incidents$final_sq_m/pi)
incidents <- st_buffer(incidents,incidents$radius)

#estimate tree cover, shrub cover, and herbaceous cover around fires
incidents$tree_cover_p <- 0
incidents$shrub_cover_p <- 0
incidents$herb_cover_p <- 0

path <- "build_land_cover"
input_path <- paste0(path,"/input/raw/cms_conus")
output_path <- paste0(path,"/output")

#downloading data from NASA's EARTH Data, using a list of commands they provide
wget_commands <- read_excel(paste0(input_path,"/wget_commands3.xlsx"))
wget_commands$command <- paste0('wget -r -np -nH --reject "index.html*" -e robots=off ',wget_commands$link)

for (i in 1:nrow(wget_commands)) {
  
  year <- wget_commands$year[i]
  type <- wget_commands$type[i]
  incidents_year <- filter(incidents, start_year==year)
  
  setwd(input_path)
  system(wget_commands$command[i])
  
  files <- list.files(input_path,recursive=T,pattern=".tif",full.names = T)
  land_rasts <- lapply(files, rast, lyrs=1) #get the first layer from each file - mean estimate numbers
  
  combined_raster <- do.call(merge, land_rasts)
  
  land_values <- terra::extract(combined_raster,incidents_year,mean,na.rm=TRUE)
  land_values[is.na(land_values)] <- 0
  
    if (type=="TC") {
      incidents_year$tree_cover_p <- rowMeans(land_values[2])
    } else if (type=="SC") {
      incidents_year$shrub_cover_p <- rowMeans(land_values[2])
    } else {
      incidents_year$herb_cover_p <- rowMeans(land_values[2])
    }

  incidents_year <- st_set_geometry(incidents_year,NULL)

  if (type=="TC") {
    incidents_year <- subset(incidents_year,select=c(incident_id,tree_cover_p))
    write.csv(incidents_year,paste0(path,"/input/built/conus/tree_cover/",year,".csv"))
  } else if (type=="SC") {
    incidents_year <- subset(incidents_year,select=c(incident_id,shrub_cover_p))
    write.csv(incidents_year,paste0(path,"/input/built/conus/shrub_cover/",year,".csv"))
  } else {
    incidents_year <- subset(incidents_year,select=c(incident_id,herb_cover_p))
    write.csv(incidents_year,paste0(path,"/input/built/conus/herb_cover/",year,".csv"))
  }
  
  unlink(files)
  
}
