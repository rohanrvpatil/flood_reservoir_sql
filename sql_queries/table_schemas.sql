-- creating tables
DROP TABLE catchment_boundaries;
DROP TABLE stations;
DROP TABLE alerts;
DROP TABLE forecasts;
DROP TABLE user_location;
DROP TABLE staging_flood_data;
DROP TABLE current_flood_data;
DROP TABLE staging_history;

SELECT * FROM staging_flood_data;
SELECT * FROM catchment_boundaries;
SELECT * FROM user_location;

SELECT station_id, boundary_geom
FROM flooded_sites
LIMIT 5;

SHOW COLUMNS FROM staging_flood_data;

SELECT * FROM current_flood_data;

SHOW CREATE TABLE staging_flood_data;

 
-- CREATE TABLE `staging_flood_data` (
--   `CWCstations - S.No` text,
--   `CWCstations - Site name` text,
--   `Station Details - River` text,
--   `Station Details - District` text,
--   `Station Details - State` text,
--   `Station Details - WL;DL;HFL` text,
--   `Short-RangeForecast - Date Time` text,
--   `Short-RangeForecast - Flood condition` text,
--   `Short-RangeForecast - Forecast WL` text,
--   `Day-1Forecast - Date Time` text,
--   `Day-1Forecast - Flood condition` text,
--   `Day-1Forecast - Max WL` text,
--   `Day-2Forecast - Date Time` text,
--   `Day-2Forecast - Flood condition` text,
--   `Day-2Forecast - Max WL` text,
--   `Day-3Forecast - Date Time` text,
--   `Day-3Forecast - Flood condition` text,
--   `Day-3Forecast - Max WL` text,
--   `Day-4Forecast - Date Time` text,
--   `Day-4Forecast - Flood condition` text,
--   `Day-4Forecast - Max WL` text,
--   `Day-5Forecast - Date Time` text,
--   `Day-5Forecast - Flood condition` text,
--   `Day-5Forecast - Max WL` text,
--   `Day-6Forecast - Date Time` text,
--   `Day-6Forecast - Flood condition` text,
--   `Day-6Forecast - Max WL` text,
--   `Day-7Forecast - Date Time` text,
--   `Day-7Forecast - Flood condition` text,
--   `Day-7Forecast - Max WL` text
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci


CREATE TABLE stations (
    station_id VARCHAR(50) PRIMARY KEY,
    station_name VARCHAR(255) NOT NULL,
    river VARCHAR(255),
    district VARCHAR(255),
    state VARCHAR(255),
    longitude DECIMAL(10, 7),
    latitude DECIMAL(10, 7)
);

CREATE TABLE catchment_boundaries (
    station_id VARCHAR(50) PRIMARY KEY,
    station_name VARCHAR(255),
    boundary_geom GEOMETRY NOT NULL,
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

UPDATE catchment_boundaries cb
JOIN stations s ON cb.station_id = s.station_id
SET cb.station_name = s.station_name;

CREATE TABLE `user_location` (
  `user_location_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `latitude` decimal(20,10) NOT NULL,
  `longitude` decimal(20,10) NOT NULL,
  `created_at` datetime NOT NULL,
  `checkpoint` int NOT NULL DEFAULT '0',
  `wpt_id` varchar(255) DEFAULT 'WAYPT-1000001',
  `is_completed` int NOT NULL DEFAULT '0',
  `journey_id` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`user_location_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE current_flood_data;

CREATE TABLE current_flood_data AS
SELECT 
    `CWCstations - Site name`,
    `Station Details - District`,
    `Station Details - River`,
    `Station Details - State`,
    `Day-2Forecast - Flood condition`
FROM 
    staging_flood_data
WHERE 
    TRIM(LOWER(`Station Details - State`)) IN ('maharashtra', 'madhya pradesh', 'gujarat');
    

CREATE TABLE flooded_sites AS
SELECT 
    cb.station_id,
    cb.station_name,
    cb.boundary_geom,
    cfd.`CWCstations - Site name` AS site_name,
    cfd.`Station Details - District` AS district,
    cfd.`Station Details - River` AS river,
    cfd.`Station Details - State` AS state,
    cfd.`Day-2Forecast - Flood condition` AS flood_condition
FROM 
    catchment_boundaries cb
JOIN 
    current_flood_data cfd 
ON 
    TRIM(LOWER(cb.station_name)) = TRIM(LOWER(cfd.`CWCstations - Site name`));

SELECT * FROM flooded_sites;

DROP TABLE users_in_flooded_areas;




CREATE TABLE users_in_flooded_areas AS
SELECT 
    ul.user_location_id,
    ul.user_id,
    ul.latitude,
    ul.longitude,
    ul.created_at,
    ul.checkpoint,
    ul.wpt_id,
    ul.is_completed,
    ul.journey_id,
    fs.station_id,
    fs.station_name,
    fs.boundary_geom,
    fs.site_name,
    fs.district,
    fs.river,
    fs.state,
    fs.flood_condition
FROM 
    user_location ul
JOIN 
    flooded_sites fs
ON 
    ST_Contains(fs.boundary_geom, ST_GeomFromText(CONCAT('POINT(', ul.longitude, ' ', ul.latitude, ')')))
WHERE 
    ul.longitude IS NOT NULL AND ul.latitude IS NOT NULL;

SELECT * FROM users_in_flooded_areas;
SELECT * FROM flooded_sites;
    
CREATE TABLE staging_history AS
SELECT * FROM current_flood_data;


CREATE TABLE forecasts (
    forecast_id CHAR(36) PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    flood_condition TEXT,
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
);



