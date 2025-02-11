# Portfolio of Geospatial Projects by Dasha* Ageikina

This portfolio presents a sample of projects showcasing my skills in geospatial data science that I accumulated during my research work

## Geospatial Data Manipulation

### Vector Data

**Generating county-level metrics of wildfire smoke from satellite-derived wildfire smoke polygon data**
<div align="center">
  <div style="display: flex; justify-content: center; gap: 10px;">
    <img src="https://github.com/user-attachments/assets/10e7d8e0-9442-4a49-8d9a-d5a42df61f49" width="400">
    <img src="https://github.com/user-attachments/assets/d24c7180-46ea-42fd-a9f2-feeee6388127" width="400">
  </div>
</div>

I generate county-level metrics of monthly smoke exposure from satellite-derived wildfire smoke data from NOAA’s Hazard Mapping System (HMS). I use a [cleaned version](https://github.com/echolab-stanford/wildfire-map-public/tree/main/data/smoke) of the HMS dataset from Stanford’s ECHO Lab. It contains polygon data, with each polygon representing a smoke plume that lasted a specified amount of time (typically several hours). I construct two key measures of smoke for each county-month pair:

 - Smoke Days: The number of days in a month when any part of a county is exposed to smoke, providing an intuitive measure of smoke presence.
 - Mean Daily Smoke Hours: A weighted measure incorporating the duration and spatial coverage of smoke plumes within a county.
   
These metrics help analyze spatial and temporal trends in wildfire smoke exposure across the U.S.

The metrics are constructed in two steps:

```
.
├── Code/                           
│   └── smoke/
│       ├── build_county_day_smoke.R     : generates smoke metrics for each county-day
│       ├── build_county_month_smoke.R   : aggregates county-day smoke metrics at the county-month level 
```

### Raster Data

**Generating land cover metrics for wildfires from raster tiles**
<div align="center">
<img src="https://github.com/user-attachments/assets/ad28920b-b7a0-4727-9f84-ab25b6134870" width="500">
</div>

I use raster [CMS Vegetative Lifeform Cover data](https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1809).

## Geospatial Data Generation

**Generating polygon data from PDF maps**

## Geospatial Data Analysis & Visualization

**Map of carbon projects**
<div align="center">
<img src="https://github.com/user-attachments/assets/3ddaf18e-0e92-4755-b0ff-7d4f99b66817" width="600">
</div>

<div align="center">
<img src="https://github.com/user-attachments/assets/389c26b3-84b6-4aaa-a343-9888b24910c7" width="600">
</div>

**Note: My legal first name is Daria, which I use for official matters and publications.*
