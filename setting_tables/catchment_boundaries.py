import geopandas as gpd
import mysql.connector

import os
from dotenv import load_dotenv

load_dotenv()

db_config = {
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME')
}

def load_catchment_boundaries(directory):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    for filename in os.listdir(directory):
        if filename.endswith('.shp'):
            shapefile_path = os.path.join(directory, filename)
            gdf = gpd.read_file(shapefile_path)

            station_id = filename[-17:-4]

            cursor.execute("SELECT COUNT(*) FROM stations WHERE station_id = %s", (station_id,))
            exists = cursor.fetchone()[0]

            if exists == 0:
                print(f"Station ID {station_id} does not exist in the stations table. Skipping...")
                continue

            for _, row in gdf.iterrows():
                boundary_geom = row['geometry'].wkt
                
                cursor.execute("""
                    INSERT INTO catchment_boundaries (station_id, boundary_geom)
                    VALUES (%s, ST_GeomFromText(%s))
                """, (station_id, boundary_geom))
    
    conn.commit()
    cursor.close()
    conn.close()

load_catchment_boundaries(r"D:\Downloads\ghi_v2409\by_station")