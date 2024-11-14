CREATE DATABASE aff_flood_monitoring;

CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY 'hv&i3816WHzSMWZPvv';

GRANT ALL PRIVILEGES ON aff_flood_monitoring.* TO 'root'@'127.0.0.1';
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'root'@'127.0.0.1';

USE aff_flood_monitoring; 
SELECT * FROM staging_flood_data;

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'aff_flood_monitoring' 
  AND TABLE_NAME = 'staging_flood_data';

-- DROP TABLE aff_flood_data;
-- DROP TABLE staging_flood_data;

SHOW TABLES;

CREATE TABLE india_sites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_name VARCHAR(255) NOT NULL,
    lat FLOAT NOT NULL,
    lng FLOAT NOT NULL
);

CREATE TABLE current_flood_data AS
SELECT 
    "CWC stations - Site Name", 
    "Station Details - District", 
    "Station Details - River", 
    "Station Details - State", 
    "Day-2 Forecast - Flood Condition"
FROM 
    staging_flood_data;
    
CREATE TABLE staging_history AS
SELECT * FROM current_flood_data;

CREATE TABLE subbasin_polygons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subbasin_id INT,
    lat FLOAT,
    lng FLOAT
);

CREATE TABLE users_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    lat FLOAT,
    lng FLOAT
);

USE aff_flood_monitoring; 

DROP TABLE alerts;
DROP TABLE forecasts;
DROP TABLE catchment_boundaries;
DROP TABLE stations;
DROP TABLE users;

ALTER TABLE stations MODIFY station_id VARCHAR(50);

-- Create table for stations
CREATE TABLE stations (
    station_id VARCHAR(50) PRIMARY KEY,
    station_name VARCHAR(255) NOT NULL,
    river VARCHAR(255),
    district VARCHAR(255),
    state VARCHAR(255),
    longitude DECIMAL(10, 7),
    latitude DECIMAL(10, 7)
);

-- Create table for catchment boundaries with spatial geometry
CREATE TABLE catchment_boundaries (
    station_id VARCHAR(50) PRIMARY KEY,
    boundary_geom GEOMETRY NOT NULL,
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

-- Create table for users (renamed from people to match structure)
CREATE TABLE users (
  tenant_id VARCHAR(60) NOT NULL DEFAULT 'nagpur_001' COMMENT 'stores tenant id',
  id INT NOT NULL AUTO_INCREMENT COMMENT 'Unique record id',
  user_id VARCHAR(100) NOT NULL COMMENT 'Unique record id',
  user_name VARCHAR(60) DEFAULT NULL,
  middle_name VARCHAR(60) DEFAULT NULL,
  last_name VARCHAR(60) DEFAULT NULL,
  email VARCHAR(60) DEFAULT NULL,
  mobile_prefix VARCHAR(5) DEFAULT NULL,
  mobile VARCHAR(13) NOT NULL,
  password VARCHAR(255) DEFAULT NULL,
  user_image VARCHAR(255) DEFAULT NULL,
  country VARCHAR(60) DEFAULT NULL,
  state VARCHAR(60) DEFAULT NULL,
  district VARCHAR(60) DEFAULT NULL,
  city VARCHAR(60) DEFAULT NULL,
  bloodgroup VARCHAR(5) DEFAULT NULL,
  dateofbirth DATE DEFAULT NULL,
  address VARCHAR(255) DEFAULT NULL,
  pin_code VARCHAR(10) DEFAULT NULL,
  emg_mobile_prefix VARCHAR(5) DEFAULT NULL,
  emg_mobile_prefix_alt VARCHAR(5) DEFAULT NULL,
  emergency_contact_name VARCHAR(255) DEFAULT NULL,
  emergency_contact_mobile VARCHAR(20) DEFAULT NULL,
  emergency_contact_mobile_alt VARCHAR(20) DEFAULT NULL,
  relationship ENUM('Father','Mother','Brother','Sister','Cousin','Uncle','Friend') DEFAULT NULL,
  emg_mobile_prefix_two VARCHAR(5) DEFAULT NULL,
  emergency_contact_name_two VARCHAR(255) DEFAULT NULL,
  emergency_contact_mobile_two VARCHAR(20) DEFAULT NULL,
  relationship_two ENUM('Father','Mother','Brother','Sister','Cousin','Uncle','Friend') DEFAULT NULL,
  emg_mobile_prefix_two_alt VARCHAR(5) DEFAULT NULL,
  emergency_contact_mobile_two_alt VARCHAR(20) DEFAULT NULL,
  emg_mobile_prefix_three VARCHAR(5) DEFAULT NULL,
  emergency_contact_name_three VARCHAR(255) DEFAULT NULL,
  emergency_contact_mobile_three VARCHAR(20) DEFAULT NULL,
  relationship_three ENUM('Father','Mother','Brother','Sister','Cousin','Uncle','Friend') DEFAULT NULL,
  emg_mobile_prefix_three_alt VARCHAR(5) DEFAULT NULL,
  emergency_contact_mobile_three_alt VARCHAR(20) DEFAULT NULL,
  user_role ENUM('Yatri','Host','Volunteer') DEFAULT 'Yatri',
  user_signed_up_as_host INT DEFAULT '0',
  user_signed_up_as_volunteer INT DEFAULT '0',
  status VARCHAR(20) DEFAULT '1',
  create_on DATETIME DEFAULT NULL,
  last_modified_on DATETIME DEFAULT NULL,
  deactivated_on DATETIME DEFAULT NULL,
  sign_privacy_policy TINYINT(1) DEFAULT '0',
  policy_version DECIMAL(10,2) DEFAULT NULL,
  doc_type VARCHAR(255) DEFAULT NULL,
  doc_front VARCHAR(255) DEFAULT NULL,
  doc_back VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY user_id_UNIQUE (user_id),
  UNIQUE KEY mobile_UNIQUE (mobile),
  UNIQUE KEY email_UNIQUE (email)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Create table for forecasts
CREATE TABLE forecasts (
    forecast_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    forecast_date DATE NOT NULL,
    forecast_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    flood_condition ENUM("Normal", "Above Normal", "Severe", "Extreme") NOT NULL,
    forecast_source VARCHAR(255) DEFAULT 'staging_flood_data',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

CREATE TABLE current_flood_data AS
SELECT 
    "CWC stations - Site Name", 
    "Station Details - District", 
    "Station Details - River", 
    "Station Details - State", 
    "Day-2 Forecast - Flood Condition"
FROM 
    staging_flood_data;
    
INSERT INTO forecasts (station_id, forecast_date, flood_condition)
SELECT 
    s.station_id,
    CURDATE() + INTERVAL 2 DAY AS forecast_date,
    cfd.`Day-2 Forecast - Flood Condition`
FROM current_flood_data cfd
JOIN stations s ON cfd.`CWC stations - Site Name` = s.station_name
WHERE cfd.`Station Details - State` IN ('MAHARASHTRA', 'GUJARAT', 'MADHYA PRADESH');

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

-- Create table for alerts
CREATE TABLE alerts (
    alert_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(100),
    station_id VARCHAR(50),
    alert_message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

DROP TABLE forecasts;


SELECT * FROM stations;

