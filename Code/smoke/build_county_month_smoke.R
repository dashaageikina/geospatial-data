# Load packages
if (!require(sf)) installed.packages('sf')
if (!require(foreign)) installed.packages('foreign')
if (!require(tidyverse)) installed.packages('tidyverse')
if (!require(data.table)) installed.packages('data.table')
library(foreign)
library(sf)
library(tidyverse)
library(data.table)

rm(list = ls())
data_path <- Sys.getenv("DATA_PATH")
sf_use_s2(FALSE)

# Read smoke data
county_smoke_days <- readRDS(file.path(data_path, "build_smoke/input/built/additional/counties_smoke_days.rds"))

# Combine all non-empty data tables
county_smoke_day <- rbindlist(lapply(county_smoke_days, function(df) {
  if (nrow(df) == 0) return(NULL)  # Skip empty elements
  df <- st_set_geometry(df, NULL)  # Drop spatial attributes
  df$p_covered_by_smoke <- as.numeric(df$p_covered_by_smoke)  # Ensure numeric type
  return(setDT(df))  # Convert to data.table format
}), use.names = TRUE, fill = TRUE)

# Add variables
county_smoke_day <- county_smoke_day %>%
  mutate(
    fips = as.numeric(paste0(STATE, COUNTY)),
    year = as.numeric(substr(date, 1, 4)),
    month = as.numeric(substr(date, 5, 6)),
    day = as.numeric(substr(date, 7, 8)),
    any_smoke = as.integer(p_covered_by_smoke_w > 0)  # Vectorized condition
  ) %>%
  select(fips, year, month, day, covered_by_smoke, p_covered_by_smoke, p_covered_by_smoke_w, any_smoke)

# Aggregate data at the monthly level
monthly <- county_smoke_day %>%
  group_by(fips, year, month) %>%
  summarise(
    n_smoke_days_fixed = sum(covered_by_smoke, na.rm = TRUE),
    smoke_cover_fixed = sum(p_covered_by_smoke, na.rm = TRUE),
    smoke_cover_w_fixed = sum(p_covered_by_smoke_w, na.rm = TRUE),
    any_smoke_days_fixed = sum(any_smoke, na.rm = TRUE),
    .groups = "drop"
  )

# Save output for Stata analysis
write.dta(monthly, file.path(data_path, "build_smoke/output/monthly_smoke.dta"))