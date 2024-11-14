import os
from dotenv import load_dotenv
import mysql.connector
from datetime import datetime
from random import uniform, randint

load_dotenv()

db_config = {
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME')
}

connection = mysql.connector.connect(**db_config)
cursor = connection.cursor()

for i in range(10):
    user_id = i + 1
    latitude = round(uniform(-90.0, 90.0), 10)
    longitude = round(uniform(-180.0, 180.0), 10)
    created_at = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    checkpoint = randint(0, 1)
    wpt_id = f"WAYPT-{1000000 + i + 1}"
    is_completed = randint(0, 1)
    journey_id = randint(1, 10)

    insert_query = """
        INSERT INTO user_location (user_id, latitude, longitude, created_at, checkpoint, wpt_id, is_completed, journey_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """
    cursor.execute(insert_query, (user_id, latitude, longitude, created_at, checkpoint, wpt_id, is_completed, journey_id))

connection.commit()
cursor.close()
connection.close()
