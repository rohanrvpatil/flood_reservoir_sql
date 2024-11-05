import pandas as pd
import mysql.connector

load_dotenv(path="../.env")

db_config = {
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME')
}

def load_station_data(file_path):
    stations_df = pd.read_excel(file_path)
    stations_df = stations_df[['ghi_stn_id', 'site_name', 'river', 'district', 'state', 'ghi_lat', 'ghi_lon']]
    stations_df = stations_df.replace({pd.NA: None, pd.NaT: None, float('nan'): None})

    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    for index, row in stations_df.iterrows():
        cursor.execute("""
            INSERT INTO stations (station_id, station_name, river, district, state, latitude, longitude)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (row['ghi_stn_id'], row['site_name'], row['river'], row['district'], row['state'], row['ghi_lat'], row['ghi_lon']))
    
    conn.commit()
    cursor.close()
    conn.close()

load_station_data("D:/Downloads/ghi_v2409/stations_ghi_excel.xlsx")
