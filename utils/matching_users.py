import mysql.connector
import random
import os
from shapely.geometry import Point
from shapely.wkt import loads
from datetime import datetime

# Set up MySQL connection using environment variables
conn = mysql.connector.connect(
    host=os.getenv('DB_HOST'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    database=os.getenv('DB_NAME')
)
cursor = conn.cursor()

# Step 1: Fetch catchment boundaries from flooded_sites and convert boundary_geom (BLOB) to WKT
cursor.execute("""
    SELECT station_id, ST_AsText(boundary_geom) AS boundary_geom_wkt
    FROM flooded_sites
""")
boundaries = cursor.fetchall()

# Step 2: Choose 5 random catchment boundaries
selected_boundaries = random.sample(boundaries, 5)

# Step 3: Generate new user locations that fall within the selected boundaries
for boundary in selected_boundaries:
    station_id, boundary_geom_wkt = boundary
    
    if not boundary_geom_wkt:
        print(f"Invalid or empty boundary_geom for station {station_id}")
        continue
    
    try:
        # Try parsing the WKT geometry using Shapely
        boundary_shape = loads(boundary_geom_wkt)
    except Exception as e:
        print(f"Error parsing WKT for station {station_id}: {e}. Boundary data: {boundary_geom_wkt}")
        continue
    
    # Generate random coordinates within the boundary
    minx, miny, maxx, maxy = boundary_shape.bounds
    while True:
        random_point = Point(random.uniform(minx, maxx), random.uniform(miny, maxy))
        if boundary_shape.contains(random_point):
            break
    
    new_latitude = random_point.y
    new_longitude = random_point.x
    created_at = datetime.now().strftime('%Y-%m-%d %H:%M:%S')  # Current timestamp

    # Step 4: Insert 5 new users into the user_location table
    for _ in range(5):
        cursor.execute("""
            INSERT INTO user_location (user_id, latitude, longitude, created_at, checkpoint, wpt_id, is_completed, journey_id)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (random.randint(1, 1000), new_latitude, new_longitude, created_at, random.randint(0, 1), 'WAYPT-1000001', random.randint(0, 1), random.randint(1, 10)))

    conn.commit()

# Close connection
cursor.close()
conn.close()
