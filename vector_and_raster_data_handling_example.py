#merge data on forest parcels with data on CARB projects (U.S. Forest projects from 
#Compliance Offset Program), wildfire hazard potential, conservation easements, and tree canopy cover
import geopandas as gpd
import rasterio
from rasterstats import zonal_stats
import os

path = "/Users/dariaageikina/Downloads"

#load parcels
parcels = gpd.read_file(os.path.join(path, "forest_parcels1km.gpkg"))
parcels = parcels.to_crs('EPSG:5070') #metric coordinate system is the most precise for computations
parcels['parcel_id'] = parcels.index + 1
parcels['parcel_area'] = parcels.geometry.area

#load CARB projects (multi)polygons
projects = gpd.read_file(os.path.join(path, "all_projects.gpkg"))
projects = projects[projects.geometry.type.isin(['Polygon', 'MultiPolygon'])]
projects = projects.to_crs(parcels.crs)

#find the shares of projects in each parcel
intersected = gpd.overlay(parcels, projects, how='intersection')
intersected['intersect_area'] = intersected.geometry.area

intersected_summed = intersected.groupby(['parcel_id','project'])['intersect_area'].sum().reset_index()
intersected_summed = intersected_summed.groupby('parcel_id').agg({
    'project': lambda x: ', '.join(x.astype(str)),
    'intersect_area': 'sum'
}).reset_index()

alldata = parcels.merge(intersected_summed, on='parcel_id', how='left')
alldata['intersect_area'] = alldata['intersect_area'].fillna(0)
alldata['project_share'] = alldata['intersect_area'] / alldata['parcel_area']
alldata.drop(columns=['intersect_area'], inplace=True)

#find average wildfire hazard potential in each parcel
#first check metadata
whp_path = path+'/2014/RDS-2015-0047/Data/whp_2014_continuous/whp2014_cnt'
with rasterio.open(whp_path) as src:
    print(src.meta)
    
stats = zonal_stats(alldata, whp_path, stats='mean', nodata=-2147483647)
alldata['whp_2014'] = [stat['mean'] for stat in stats]
alldata = alldata.dropna(subset=['whp_2014'])
alldata.reset_index(drop=True, inplace=True)

#load conservation easement data
CEs = gpd.read_file(os.path.join(path, "NCED_08282020_shp"))
CEs = CEs.to_crs(parcels.crs)
CEs = CEs[CEs['owntype']!='FED']
CEs = CEs[['unique_id','geometry']]
CEs.rename(columns={'unique_id': 'ce_id'}, inplace=True)
#find if parcels intersect with conservation easements
intersected2 = gpd.sjoin(parcels, CEs, how='left', predicate = 'intersects')
intersected2 = intersected2.groupby('parcel_id').agg({
    'ce_id': lambda x: ', '.join(x.astype(str))
}).reset_index()

intersected2['ce'] = 0
intersected2.loc[intersected2['ce_id']!="nan", 'ce'] = 1
intersected2[intersected2['ce']==1]
intersected2 = intersected2[['parcel_id','ce']]

alldata = alldata.merge(intersected2, on='parcel_id', how='left')

alldata.to_file(path+'/merged_carb.gpkg', layer='alldata', driver='GPKG')

