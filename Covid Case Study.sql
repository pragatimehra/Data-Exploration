/*
	Covid Case Study (January 2020 - April 2021)

	Countries tackled: UK, US, EU, RU, CA, CN, IN, AU
	Briefly worked on a larger dataset to explore Continents data

	Skills: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


CREATE DATABASE Porfolio_Project_1;
USE Porfolio_Project_1;

-- Fetching the columns to work with...
SELECT 
	Location, 
    DATE_FORMAT(date, '%y-%m-%d') AS "Date", 
    CAST(total_cases AS UNSIGNED) AS "Total Cases", 
    CAST(new_cases AS UNSIGNED) AS "New Cases", 
    CAST(total_deaths AS UNSIGNED) As "Total Deaths", 
    CAST(population AS UNSIGNED) AS "Population"
FROM CovidDeathsFinal;

-- Looking at Cases vs Population : Detailed Analysis
SELECT 
	Location,
    DATE_FORMAT(date, '%y-%m-%d') AS "Date", 
    CAST(population AS UNSIGNED) AS "Population",
    CAST(total_cases AS UNSIGNED) AS "Total Cases",
    CAST(total_cases AS UNSIGNED)/CAST(population AS UNSIGNED) * 100 AS "Infection Rate"
FROM CovidDeathsFinal;

-- Looking at Cases vs Population : Concrete Analysis
-- Countries with Highest Infection Rate
SELECT 
	Location,
    MAX(CAST(population AS UNSIGNED)) AS "Population",
    MAX(CAST(total_cases AS UNSIGNED)) AS "Total Cases",
    MAX(CAST(total_cases AS UNSIGNED))/MAX(CAST(population AS UNSIGNED)) * 100 AS "Infection Rate"
FROM CovidDeathsFinal
GROUP BY Location
ORDER BY MAX(CAST(total_cases AS UNSIGNED))/MAX(CAST(population AS UNSIGNED)) * 100 DESC;

-- Looking at Deaths vs Cases : Detailed Analysis
SELECT 
	Location,
    DATE_FORMAT(date, '%y-%m-%d') AS "Date",
    CAST(total_cases AS UNSIGNED) AS "Total Cases",
    CAST(total_deaths AS UNSIGNED) As "Total Deaths",
    CAST(total_deaths AS UNSIGNED)/CAST(total_cases AS UNSIGNED) * 100 AS "Death to Cases Rate"
FROM CovidDeathsFinal;

-- Looking at Deaths vs Cases : Concrete Analysis
-- Countries with Highest Death to Cases Rate
SELECT 
	Location,
    MAX(CAST(total_cases AS UNSIGNED)) AS "Total Cases",
    MAX(CAST(total_deaths AS UNSIGNED)) As "Total Deaths",
    MAX(CAST(total_deaths AS UNSIGNED))/MAX(CAST(total_cases AS UNSIGNED)) * 100 AS "Death to Cases Rate"
FROM CovidDeathsFinal
GROUP BY Location
ORDER BY MAX(CAST(total_deaths AS UNSIGNED))/MAX(CAST(total_cases AS UNSIGNED)) * 100 DESC;

-- Looking at Deaths vs Population : Detailed Analysis
SELECT 
	Location,
    DATE_FORMAT(date, '%y-%m-%d') AS "Date", 
    CAST(population AS UNSIGNED) AS "Population",
    CAST(total_deaths AS UNSIGNED) AS "Total Deaths",
    CAST(total_deaths AS UNSIGNED)/CAST(population AS UNSIGNED) * 100 AS "Death Count"
FROM CovidDeathsFinal;

-- Looking at Deaths vs Population : Concrete Analysis
-- Countries with Highest Death Counts
SELECT 
	Location,
    MAX(CAST(population AS UNSIGNED)) AS "Population",
    MAX(CAST(total_deaths AS UNSIGNED)) AS "Total Deaths",
    MAX(CAST(total_deaths AS UNSIGNED))/MAX(CAST(population AS UNSIGNED)) * 100 AS "Death Count"
FROM CovidDeathsFinal
GROUP BY Location
ORDER BY MAX(CAST(total_deaths AS UNSIGNED))/MAX(CAST(population AS UNSIGNED)) * 100 DESC;

-- Extracting Continents data from CovidDeaths Table
SELECT * FROM CovidDeaths;

SELECT
	Continent,
	DATE_FORMAT(date, '%y-%m-%d') AS "Date",
	CAST(total_cases AS UNSIGNED) AS "Total Cases", 
	CAST(new_cases AS UNSIGNED) AS "New Cases", 
	CAST(total_deaths AS UNSIGNED) As "Total Deaths", 
	CAST(population AS UNSIGNED) AS "Population"
FROM CovidDeaths
WHERE Continent != '';

-- Global Numbers
SELECT
	Continent,
    MAX(CAST(population AS UNSIGNED)) AS "Population",
	MAX(CAST(total_cases AS UNSIGNED)) AS "Total Cases", 
	MAX(CAST(total_deaths AS UNSIGNED)) As "Total Deaths",
    MAX(CAST(total_cases AS UNSIGNED))/MAX(CAST(population AS UNSIGNED)) * 100 AS "People Affected",
    MAX(CAST(total_deaths AS UNSIGNED))/MAX(CAST(population AS UNSIGNED)) * 100 AS "Death Count"
FROM CovidDeaths
WHERE Continent != ''
GROUP BY Continent;

-- Creating a 'World' View
CREATE VIEW World AS
SELECT
	Continent,
    MAX(CAST(population AS UNSIGNED)) AS Population,
	MAX(CAST(total_cases AS UNSIGNED)) AS Total_Cases, 
	MAX(CAST(total_deaths AS UNSIGNED)) As Total_Deaths,
    MAX(CAST(total_cases AS UNSIGNED))/MAX(CAST(population AS UNSIGNED)) * 100 AS People_Affected,
    MAX(CAST(total_deaths AS UNSIGNED))/MAX(CAST(population AS UNSIGNED)) * 100 AS Death_Count
FROM CovidDeaths
WHERE Continent != ''
GROUP BY Continent;

SELECT * FROM World;

SELECT
	SUM(Population) AS "Population",
	SUM(Total_Cases) AS "Cases",
    SUM(Total_Deaths) AS "Deaths",
    SUM(Total_Cases)/SUM(Population) * 100 AS "People Affected",
    SUM(Total_Deaths)/SUM(Population) * 100 AS "Death Count"
FROM World;

-- Overview of entire dataset...
SELECT *
FROM CovidDeathsFinal AS CDF
JOIN CovidVaccinationsFinal AS CVF
ON CDF.location = CVF.location
AND CDF.date = CVF.date;

-- Fetching Vaccinations Data
-- Creating a Rolling Vaccination Count
SELECT 
	CDF.continent AS "Continent",
	CDF.location AS "Location", 
    DATE_FORMAT(CDF.date, '%y-%m-%d') AS "Date",
    CONVERT(CDF.population, UNSIGNED) AS "Population",
    CONVERT(CVF.new_vaccinations, UNSIGNED) AS "New Vaccinations",
    SUM(CONVERT(CVF.new_vaccinations, UNSIGNED)) 
		OVER (PARTITION BY CDF.location ORDER BY STR_TO_DATE(CDF.date, '%y-%m-%d')
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS "Rolling Vaccination Count"
FROM CovidDeathsFinal AS CDF
JOIN CovidVaccinationsFinal AS CVF
ON CDF.location = CVF.location
AND DATE_FORMAT(CDF.date, '%y-%m-%d') = DATE_FORMAT(CVF.date, '%y-%m-%d');

-- Checking People Vaccinated from Total Population
-- Creating a CTE
WITH CTE_Vaccinations (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinatedCount) AS (
    SELECT 
        CDF.continent AS "Continent",
        CDF.location AS "Location", 
        DATE_FORMAT(CDF.date, '%y-%m-%d') AS "Date",
        CONVERT(CDF.population, UNSIGNED) AS "Population",
        CONVERT(CVF.new_vaccinations, UNSIGNED) AS "New Vaccinations",
        SUM(CONVERT(CVF.new_vaccinations, UNSIGNED)) 
            OVER (PARTITION BY CDF.location ORDER BY STR_TO_DATE(CDF.date, '%y-%m-%d')
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            AS "Rolling Vaccination Count"
    FROM CovidDeathsFinal AS CDF
    JOIN CovidVaccinationsFinal AS CVF
    ON CDF.location = CVF.location
    AND DATE_FORMAT(CDF.date, '%y-%m-%d') = DATE_FORMAT(CVF.date, '%y-%m-%d')
)

SELECT
    Location,
    Population,
    MAX(RollingVaccinatedCount) AS "Vaccinated People",
    (MAX(RollingVaccinatedCount) / Population) * 100 AS "% Vaccinated"
FROM CTE_Vaccinations
GROUP BY Location, Population
ORDER BY (MAX(RollingVaccinatedCount) / Population) DESC;

-- Created a View for Rolling Vaccination Count
CREATE VIEW RollingVaccinationsView AS
SELECT 
	CDF.continent AS "Continent",
	CDF.location AS "Location", 
	DATE_FORMAT(CDF.date, '%y-%m-%d') AS "Date",
	CONVERT(CDF.population, UNSIGNED) AS "Population",
	CONVERT(CVF.new_vaccinations, UNSIGNED) AS "New Vaccinations",
	SUM(CONVERT(CVF.new_vaccinations, UNSIGNED)) 
		OVER (PARTITION BY CDF.location ORDER BY STR_TO_DATE(CDF.date, '%y-%m-%d')
			  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS "Rolling Vaccination Count"
FROM CovidDeathsFinal AS CDF
JOIN CovidVaccinationsFinal AS CVF
ON CDF.location = CVF.location
AND DATE_FORMAT(CDF.date, '%y-%m-%d') = DATE_FORMAT(CVF.date, '%y-%m-%d');

SELECT * FROM RollingVaccinationsView;

SELECT
	Location,
    Population,
	MAX(`Rolling Vaccination Count`) AS Vaccinated,
    MAX(`Rolling Vaccination Count`)/Population * 100 AS "% Vaccinated"
FROM RollingVaccinationsView
GROUP BY Location, Population
ORDER BY MAX(`Rolling Vaccination Count`)/Population * 100 DESC;
