
-- this is correct 
USE aff_flood_monitoring; 

SELECT *
FROM stations
WHERE LOWER(TRIM(station_name)) LIKE '%KARIMGANJ%'
   OR SOUNDEX(TRIM(station_name)) = SOUNDEX('KARIMGANJ');
   

SELECT *
FROM stations
WHERE LOWER(TRIM(river)) LIKE LOWER(TRIM('%KUSHIYARA%'))
  AND LOWER(TRIM(district)) LIKE LOWER(TRIM('%KARIMGANJ%'))
  AND LOWER(TRIM(state)) LIKE LOWER(TRIM('%Assam%'))
LIMIT 1;

--  above 2 commands are correct





USE aff_flood_monitoring;

SELECT *
FROM stations;

SELECT * FROM staging_flood_data;

SELECT * FROM forecasts;

SHOW COLUMNS FROM staging_flood_data;


SELECT * FROM catchment_boundaries;



SELECT `CWCstations - Site name`, 
       `Station Details - River`, 
       `Station Details - District`, 
       `Station Details - State`, 
       `Day-2Forecast - Flood condition`
FROM staging_flood_data;


SELECT * FROM staging_flood_data;
SELECT * FROM forecasts;


SHOW COLUMNS FROM staging_flood_data;


