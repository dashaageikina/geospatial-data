# Portfolio of Geospatial Projects by Dasha* Ageikina

This portfolio presents a sample of projects showcasing my skills in geospatial data science that I accumulated during my research work.

**Note: My legal first name is Daria, which I use for official matters and publications.*

*If you have questions or if you see any mistakes, e-mail me at [dariaageikina@gmail.com](mailto:dariaageikina@gmail.com).*

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

The [ICS-209-PLUS dataset](https://figshare.com/articles/dataset/ICS209-PLUS_Cleaned_databases/8048252/10) constructed by the EarthLab at the University of Colorado-Boulder contains detailed geospatial records (point-based) of U.S. wildfires between 1999 and 2014 ([paper](https://www.nature.com/articles/s41597-020-0403-0#Sec29)). My goal was to determine the extent of tree, shrub, and grass coverage in the area surrounding each wildfire's point of origin.

The data on land cover classes comes from [CMS Vegetative Lifeform Cover data](https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1809) (available for free upon registration). This dataset consists of tiled raster files, organized by year and land cover class, where each pixel represents the percentage of land covered by a specific vegetation type. 

The analysis involves three main steps:

1. Generating Fire Perimeters – I estimate wildfire perimeters based on the point location and reported acres burned.
2. Merging Land Cover Tiles – I compile the raster tiles for each land cover class and year to create a seamless dataset.
3. Extracting Land Cover Metrics – For each wildfire, I calculate the average percentage of tree, shrub, and grass coverage within its perimeter, using data from the year prior to the fire.

The graph illustrates the trends of the fire-level averages for each land cover metric by GACC (Geographic Area Coordination Center).

```
.
├── Code/                           
│   └── land_cover/
│       ├── build_annual_land_cover.R
```

## Geospatial Data Generation

**Generating polygon data from PDF maps**
<div align="center">
<img src="https://github.com/user-attachments/assets/3ddaf18e-0e92-4755-b0ff-7d4f99b66817" width="600">
</div>

[CARB's Compliance Offset Program](https://ww2.arb.ca.gov/our-work/programs/compliance-offset-program) provides open access to documentation for U.S. forest carbon sequestration projects, which include reforestation, avoided conversion of forests to other uses, and improved forest management. The documentation files are stored separately for each project. 

My goal was to build a geospatial database of all projects with their locations. I automated the downloading process and compiled the geospatial data using web scraping and data cleaning. However, a significant number of projects lack geospatial files and only have documentation in PDF format. For these projects, I manually generated vector polygon data by overlaying images in Google Earth Pro.

Finally, I compiled all data into a file, carb_forest_projects.kml, which includes project names, project types, and locations for most projects as of December 1, 2025. The map above shows project centroids categorized by project type, with marker sizes varying based on project areas. 

**Disclaimer**: This project is provided for informational purposes only. While I have made efforts to ensure data accuracy, I do not guarantee its completeness or correctness. Use this data at your own risk.

```
.
├── Output/                           
│   └── forest_projects/
│       ├── carb_forest_projects.kml
```


## Geospatial Data Analysis & Visualization


<div align="center">
<img src="https://github.com/user-attachments/assets/389c26b3-84b6-4aaa-a343-9888b24910c7" width="600">
</div>
