/* Create Database */
CREATE DATABASE IF NOT EXISTS covid_19;
SHOW DATABASES;
USE covid_19;
show tables;

CREATE TABLE `covid_19_data` (
  `Id` int,
  `Province_State` text DEFAULT NULL,
  `Country_Region` text DEFAULT NULL,
  `Date` text DEFAULT NULL,
  `ConfirmedCases` int DEFAULT 0,
  `Fatalities` int DEFAULT 0
);


CREATE TABLE `health_care_index` (
  `Country` text,
  `Health Care Index` text DEFAULT NULL,
  `Health Care Exp. Index` text DEFAULT NULL
);

CREATE TABLE `population_density` (
  `Rank` varchar(10),
  `Country (or dependent territory)` varchar(200),
  `Area km2` varchar(50),
  `Area mi2` varchar(50), 
  `Population` varchar(50),
  `Density pop./km2` varchar(50),
  `Density pop./mi2` varchar(50),
  `Date` varchar(50),
  `Population source` varchar(50)
);


CREATE TABLE `age_structure` (
  `Country` text,
  `Age 0 to 14 Years` text DEFAULT NULL,
  `Age 15 to 64 Years` text DEFAULT NULL,
  `Age above 65 Years` text DEFAULT NULL
);

show tables;

DESCRIBE covid_19_data;
DESCRIBE health_care_index;
DESCRIBE population_density;
DESCRIBE age_structure;

truncate table covid_19_data;
truncate table health_care_index;
truncate table population_density;
truncate table age_structure;


/* Importing the CSV data to MySQL by Command Line for Fast Importing */

/*

$ mysql -u root -p

mysql> SET GLOBAL local_infile=1;
Query OK, 0 rows affected (0.00 sec)

mysql> quit
Bye

$ mysql --local-infile=1 -u root -p


LOAD DATA LOCAL INFILE '/home/dinesh/Data-Science/MySQL/research_project/covid-19/age_structure.csv'
INTO TABLE age_structure
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/home/dinesh/Data-Science/MySQL/research_project/covid-19/health_care_index.csv'
INTO TABLE health_care_index
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/home/dinesh/Data-Science/MySQL/research_project/covid-19/population_density.csv'
INTO TABLE population_density
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/home/dinesh/Data-Science/MySQL/research_project/covid-19/covid_19_data.csv'
INTO TABLE covid_19_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

*/


DESCRIBE covid_19_data;
DESCRIBE health_care_index;
DESCRIBE population_density;
DESCRIBE age_structure;


SELECT * FROM covid_19_data LIMIT 20;
SELECT * FROM health_care_index LIMIT 20;
SELECT * FROM population_density LIMIT 20;
SELECT * FROM age_structure LIMIT 20;

/* structure covid_19_data table */

ALTER TABLE covid_19_data 
CHANGE COLUMN Id id  INT,
CHANGE COLUMN Province_State province_state varchar(200),
CHANGE COLUMN Country_Region country VARCHAR(200),
CHANGE COLUMN Date date date,
CHANGE COLUMN ConfirmedCases confirmed_cases INT,
CHANGE COLUMN Fatalities fatalities INT
ADD PRIMARY KEY (id);

UPDATE covid_19_data SET province_state = country where province_state =  "";



/* structure health_care_index table */

ALTER TABLE health_care_index 
CHANGE COLUMN Country country varchar(200),
CHANGE COLUMN `Health Care Index` health_care_index DOUBLE,
CHANGE COLUMN `Health Care Exp. Index` health_care_exp_index DOUBLE
ADD PRIMARY KEY (country);

UPDATE health_care_index SET country = TRIM(country);

UPDATE health_care_index SET country = "US" WHERE country = "United States";


/* structure population_density table */

update population_density set density_rank = NULL where density_rank = '–';
UPDATE population_density SET `Area km2` = REPLACE(`Area km2`,',','');
UPDATE population_density SET `Area mi2` = REPLACE(`Area mi2`,',','');
UPDATE population_density SET `Population` = REPLACE(`Population`,',','');
UPDATE population_density SET `Density pop./km2` = REPLACE(`Density pop./km2`,',','');
UPDATE population_density SET `Density pop./mi2` = REPLACE(`Density pop./mi2`,',','');
UPDATE population_density SET `Country (or dependent territory)` = TRIM(`Country (or dependent territory)`);
UPDATE population_density SET `Country (or dependent territory)` = REPLACE(`Country (or dependent territory)`, '\t', '');
UPDATE population_density SET `Country (or dependent territory)` = REPLACE(`Country (or dependent territory)`, '\n', '');

ALTER TABLE population_density ADD temp_date DATE AFTER Date;
SET SQL_SAFE_UPDATES = 0;
UPDATE population_density Set temp_date = Str_to_date(Date,'%M %d, %Y');


ALTER TABLE population_density 
CHANGE COLUMN density_rank density_rank INT,
CHANGE COLUMN `Country (or dependent territory)` country varchar(200),
CHANGE COLUMN `Area km2` area_km2 DOUBLE,
CHANGE COLUMN `Area mi2` area_mi2 DOUBLE,
CHANGE COLUMN `Population` population INT,
CHANGE COLUMN `Density pop./km2` density_pop_per_km2 DOUBLE,
CHANGE COLUMN `Density pop./mi2` density_pop_per_mi2 DOUBLE,
CHANGE COLUMN `Population source` population_source TEXT, 
DROP COLUMN Date,
ADD PRIMARY KEY (country);

ALTER TABLE population_density
CHANGE COLUMN temp_date date DATE NULL DEFAULT NULL;

UPDATE population_density SET country = "US" WHERE country = "United States";

/* structure age_structure table */
ALTER TABLE age_structure CHANGE COLUMN Country country VARCHAR(200) DEFAULT NULL;
UPDATE age_structure SET country = TRIM(country);
UPDATE age_structure SET country = REPLACE(country, '\t', '');
UPDATE age_structure SET country = REPLACE(country, '\n', '');

UPDATE age_structure SET `Age 0 to 14 Years` = TRIM(`Age 0 to 14 Years`);
UPDATE age_structure SET `Age 15 to 64 Years` = TRIM(`Age 15 to 64 Years`);
UPDATE age_structure SET `Age above 65 Years` = TRIM(`Age above 65 Years`);

update age_structure set `Age 0 to 14 Years` = REPLACE(`Age 0 to 14 Years`,"%","");
update age_structure set `Age 15 to 64 Years` = REPLACE(`Age 15 to 64 Years`,"%","");
update age_structure set `Age above 65 Years` = REPLACE(`Age above 65 Years`,"%","");

ALTER TABLE age_structure 
CHANGE COLUMN `Age 0 to 14 Years` age_0_14_yrs DOUBLE,
CHANGE COLUMN `Age 15 to 64 Years` age_15_64_yrs DOUBLE,
CHANGE COLUMN `Age above 65 Years` age_above_65_yrs INT;

ALTER TABLE age_structure 
CHANGE COLUMN age_above_65_yrs age_above_65_yrs DOUBLE,
ADD PRIMARY KEY (country);

UPDATE age_structure SET country = "US" WHERE country = "United States";
