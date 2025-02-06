# Load packages
if (!require(sf)) install.packages('sf', dependencies=TRUE)
if (!require(future.apply)) install.packages('future.apply', dependencies=TRUE)
library(sf)
library(future.apply)

# Set up parallel processing
plan(multisession, workers = parallel::detectCores() - 1)
# Set data path
data_path <- Sys.getenv("DATA_PATH")
# Disable spherical geometry
sf_use_s2(FALSE)

# Load smoke data
smoke <- readRDS(paste0(data_path, "/build_smoke/input/raw/smoke_plumes.rds"))

# Load data on county boundaries
usa_counties_path <- paste0(data_path, "/build_surface_pm25/input/raw/county_boundaries/gz_2010_us_050_00_20m/gz_2010_us_050_00_20m.shp")
counties <- st_read(usa_counties_path)
counties$ID <- counties$GEO_ID
# Remove Alaska, Hawaii, and Puerto Rico
counties <- subset(counties, !(STATE %in% c(2, 15, 72)))

# Change CRS to UTM
utm_crs <- "+proj=utm +zone=12 +datum=WGS84"
counties <- st_transform(counties, crs = st_crs(utm_crs))

# Function to compute smoke coverage per county-day
intersect_smoke_day_with_counties <- function(smoke_day) {
  if (nrow(smoke_day) == 0) return(smoke_day)
  
  smoke_day <- st_transform(smoke_day, crs = st_crs(utm_crs))
  # Remove invalid geometries
  smoke_day <- smoke_day[st_is_valid(smoke_day), ]
  if (nrow(smoke_day) == 0) return(smoke_day)
  
  # Compute the shares of counties covered by smoke on a given day, weighted by duration
  # Precompute county areas (avoids redundant calculations)
  county_areas <- st_area(counties)
  
  # Compute intersections of counties and smoke days
  all_intersections <- st_intersection(counties, smoke_day)
  
  # Add columns to store smoke coverage on a given day, weighted and unweighted
  counties$p_covered_by_smoke <- 0   #county areas covered by smoke
  counties$p_covered_by_smoke_w <- 0  #county areas covered by smoke, weighted by smoke plume durations
  
  if (nrow(all_intersections) > 0) {
    # Extract start and end times as minutes
    start_minutes <- as.numeric(substr(all_intersections$Start, 9, 10)) * 60 + 
      as.numeric(substr(all_intersections$Start, 11, 12))
    end_minutes <- as.numeric(substr(all_intersections$End, 9, 10)) * 60 + 
      as.numeric(substr(all_intersections$End, 11, 12))
    
    # Compute duration (ignore zero durations)
    durations <- abs(end_minutes - start_minutes)
    valid_durations <- durations > 0
    
    if (any(valid_durations)) {
      # Compute area ratios once
      area_ratios <- as.numeric(st_area(all_intersections) / county_areas[all_intersections$ID])
      
      # Compute unweighted coverage (count number of times a county is affected)
      counties$p_covered_by_smoke <- tapply(rep(1, sum(valid_durations)), 
                                            all_intersections$ID, sum, default = 0)
      
      # Compute weighted coverage
      counties$p_covered_by_smoke_w <- tapply(durations[valid_durations] * area_ratios[valid_durations], 
                                              all_intersections$ID, sum, default = 0)
    }
  }
  
  return(counties)
}

# Apply function in parallel
counties_smoke_days <- future_lapply(smoke, intersect_smoke_day_with_counties)

# Save results
saveRDS(counties_smoke_days, paste0(data_path, "/build_smoke/input/built/additional/counties_smoke_days.rds"))

# Clean up parallel session
plan(sequential)
