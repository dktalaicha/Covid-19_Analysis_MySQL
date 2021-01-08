/* DATE WISE ANALYSIS FOR WHOLE WORLD */ 
SELECT Date, SUM(confirmed_cases) AS total_confirmed_cases, SUM(fatalities) AS total_fatalities 
from covid_19_data
GROUP BY Date
order by Date DESC;

/* DATE WISE ANALYSIS FOR EACH COUNTRY */
SELECT Date, country, SUM(confirmed_cases) AS total_confirmed_cases, SUM(fatalities) AS total_fatalities 
from covid_19_data
GROUP BY Date, country
HAVING total_confirmed_cases > 0
order by Date DESC, total_confirmed_cases DESC;

SELECT Date, country, SUM(confirmed_cases) AS total_confirmed_cases, SUM(fatalities) AS total_fatalities 
from covid_19_data
WHERE date < "2020-01-23"
GROUP BY Date, country
HAVING total_confirmed_cases > 0
order by Date DESC, total_confirmed_cases DESC;

SELECT * FROM covid_19_data WHERE country = "China" ORDER BY Date;

SELECT Date, country, SUM(confirmed_cases) AS total_confirmed_cases, SUM(fatalities) AS total_fatalities 
from covid_19_data
WHERE country = "China"
GROUP BY Date, country
HAVING total_confirmed_cases > 0
order by Date;

SELECT * FROM covid_19_data order by Date LIMIT 200;


/* COUNTRY WISE ANALYSIS */
SELECT country, SUM(confirmed_cases) AS total_confirmed_cases, SUM(fatalities) AS total_fatalities
FROM (
  SELECT country, province_state, MAX(confirmed_cases) AS confirmed_cases, MAX(fatalities) AS fatalities 
  from covid_19_data
  GROUP BY province_state, country) AS temp
GROUP BY country
HAVING total_confirmed_cases > 0
order by total_confirmed_cases DESC;


/* RATE OF CHANGE IN CONFIRM CASES AND FATALITIES */
/********************************/
/* SELECT 
  t1.Date, 
  t1.country, 
  SUM(t1.confirmed_cases) AS total_confirmed_cases, 
  SUM(t1.fatalities) AS total_fatalities,
  IFNULL(((SUM(t1.confirmed_cases) -IFNULL((SELECT SUM(t2.confirmed_cases) FROM covid_19_data t2 
                                      WHERE t2.date = t1.date-1 AND t2.country = t1.country), 0)) * 100) 
          / IFNULL((SELECT SUM(t2.confirmed_cases) FROM covid_19_data t2 
                    WHERE t2.date = t1.date-1 AND t2.country = t1.country), 0),0) as rate_of_change
from covid_19_data t1
GROUP BY t1.date, t1.country
HAVING total_confirmed_cases > 5000
order by t1.country, 3 DESC;
*/
/********************************/

SELECT 
     A.*, 
     CASE WHEN (A.total_confirmed_cases IS NULL OR B.total_confirmed_cases IS NULL OR B.total_confirmed_cases=0) THEN 0 ELSE
       (A.total_confirmed_cases - B.total_confirmed_cases)*100/B.total_confirmed_cases END AS confirmed_cases_rate,
     CASE WHEN (A.total_fatalities IS NULL OR B.total_fatalities IS NULL OR B.total_fatalities=0) THEN 0 ELSE
        (A.total_fatalities - B.total_fatalities)*100/B.total_fatalities END AS fatalities_rate
FROM (SELECT Date, country, 
      SUM(confirmed_cases) AS total_confirmed_cases, 
      SUM(fatalities) AS total_fatalities 
    from covid_19_data
    GROUP BY Date, country
    HAVING total_confirmed_cases > 5000
    order by total_confirmed_cases DESC) A LEFT JOIN (SELECT Date, country, 
  SUM(confirmed_cases) AS total_confirmed_cases, 
  SUM(fatalities) AS total_fatalities 
from covid_19_data
GROUP BY Date, country
HAVING total_confirmed_cases > 5000
order by total_confirmed_cases DESC) B
ON A.date = (B.date+1) AND A.country = B.country; 


/* TOTAL CASES COMPARING TO COUNTRY POPULATION */

SELECT t.country, SUM(t.confirmed_cases) AS total_confirmed_cases, 
SUM(t.fatalities) AS total_fatalities, 
((SUM(t.confirmed_cases)/p.population) * 1000000) as Total_Cases_Per_1M_Pop,
((SUM(t.fatalities)/p.population) * 1000000) as Total_Fatalities_Per_1M_Pop,
p.density_pop_per_km2 as density_pop_per_km2,
p.population
FROM (
  SELECT country, province_state, MAX(confirmed_cases) AS confirmed_cases, MAX(fatalities) AS fatalities 
  from covid_19_data
  GROUP BY province_state, country) AS t
INNER JOIN population_density AS p
on t.country = p.country
GROUP BY t.country
HAVING total_confirmed_cases > 1000
order by total_confirmed_cases DESC;

/* IMPACT OF AGE ON CONFIMRED CASES  */


SELECT t.country, SUM(t.confirmed_cases) AS Confirmed, 
SUM(t.fatalities) AS Deaths, 
((SUM(t.confirmed_cases)/p.population) * 1000000) as 'Cases per 1M people',
/*((SUM(t.fatalities)/p.population) * 1000000) as 'Deaths per 1M people',*/
p.density_pop_per_km2 as DensityPopPerkm2,
p.population,
a.age_0_14_yrs,
a.age_15_64_yrs,
a.age_above_65_yrs
FROM (
      SELECT country, province_state, MAX(confirmed_cases) AS confirmed_cases, MAX(fatalities) AS fatalities 
      from covid_19_data
      GROUP BY province_state, country) AS t
INNER JOIN population_density AS p
  ON t.country = p.country
INNER JOIN age_structure a
  ON t.country = a.country
GROUP BY t.country
HAVING Confirmed > 1000
order by 4 DESC;


/* IMPACT OF AGE AND HEALTH CARE INDEX ON CONFIMRED CASES  */


SELECT t.country, SUM(t.confirmed_cases) AS Confirmed, 
SUM(t.fatalities) AS Deaths, 
((SUM(t.confirmed_cases)/p.population) * 1000000) as 'Cases per 1M people',
((SUM(t.fatalities)/p.population) * 1000000) as 'Deaths per 1M people',
p.density_pop_per_km2 as DensityPopPerkm2,
p.population,
a.age_15_64_yrs,
a.age_above_65_yrs,
h.health_care_index
FROM (
      SELECT country, province_state, MAX(confirmed_cases) AS confirmed_cases, MAX(fatalities) AS fatalities 
      from covid_19_data
      GROUP BY province_state, country) AS t
INNER JOIN population_density AS p
  ON t.country = p.country
INNER JOIN age_structure a
  ON t.country = a.country
INNER JOIN health_care_index h
  ON t.country = h.country
GROUP BY t.country
HAVING Confirmed > 0
order by a.age_above_65_yrs DESC;
  