-- COVID-19 Data Exploration Portfolio Project
-- Skills used: Joins, CTEs, Window Functions, Aggregate Functions, Creating Views, Converting Data Types, Creating Temp Table

-- Create a temp table to store data to avoid redundancy
Create Table #CovidData (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	TotalCases numeric,
	NewCases numeric,
	TotalDeaths numeric,
	NewDeaths numeric,
	NewVaccinations numeric,
	RollingPeopleVaccinated numeric
);

-- Common Table Expression (CTE) for data preparation
WITH CovidData AS (
	SELECT 
		deaths.continent,
		deaths.location,
		deaths.date,
		deaths.population,
		deaths.total_cases,
		deaths.new_cases,
		deaths.total_deaths,
		deaths.new_deaths,
		vaccinations.new_vaccinations,
		SUM(CAST(vaccinations.new_vaccinations AS bigint))
			OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths deaths
	Join PortfolioProject..CovidVaccinations vaccinations
	ON deaths.location = vaccinations.location
		AND deaths.date = vaccinations.date
	WHERE
		deaths.continent IS NOT NULL
)

INSERT INTO #CovidData
SELECT *
FROM CovidData


-- Query 1: Total Cases vs Total Deaths by location
SELECT
	Location,
	Date,
	TotalCases,
	TotalDeaths,
	(CAST(TotalDeaths AS int)/ TotalCases) * 100 AS DeathPrecentage
FROM 
	#CovidData
ORDER BY
	Location, Date

-- Query 2: Total Cases vs Population by deaths

SELECT
    Location,
    Date,
    TotalCases,
    Population,
    (TotalCases / population) * 100 AS InfectedPercentage
FROM
    #CovidData
ORDER BY
    location, date;


-- Query 3: Highest Infection Rate In Every Country

SELECT
	Location,
	Population,
	MAX(TotalCases) AS TotalInfectedNumber,
	MAX((TotalCases/Population)) * 100 AS InfectedPrecentage
FROM
	#CovidData
GROUP BY
	Location, Population
ORDER BY
	InfectedPrecentage DESC


-- Query 4: Showing the Highest Death Count in every Country

SELECT
	Location,
	MAX(CAST(TotalDeaths AS int)) AS TotalDeathCount
FROM
	#CovidData
WHERE
	Continent IS NOT NULL
GROUP BY
	Location
ORDER BY
	TotalDeathCount DESC

-- Grouping By Continent

-- Query 5: Showing the Highest Death Count in every Continent

SELECT
	CASE
		WHEN Continent IS NULL THEN Location
		ELSE Continent
	END AS Continent,
	MAX(CAST(TotalDeaths AS int)) AS TotalDeathCount
FROM 
	#CovidData
GROUP BY
	CASE
        WHEN Continent IS NULL THEN Location
        ELSE Continent
    END
ORDER BY
	TotalDeathCount DESC


-- Query 6: Total Population vs Vaccinations
--			Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT
	Continent,
	Location,
	Date,
	Population,
	NewVaccinations,
	RollingPeopleVaccinated
FROM
	#CovidData
WHERE
	Continent IS NOT NULL
ORDER BY
	Continent,
	Location

-- Query 7: Creating View to store data for later visualizations

CREATE VIEW PrecentPopulationVaccinated	AS
SELECT Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated
FROM 
	#CovidData
WHERE 
	Continent IS NOT NULL

-- Summary: Key Insights and Findings
/*
I embarked on a comprehensive COVID-19 Data Exploration project, delving into various analyses to derive meaningful insights into the pandemic's multifaceted impact. Below are the key findings and observations:

1. Mortality Analysis:
   - Employing data on total cases and total deaths, I computed the death percentage for each country.
   - This analysis offers a nuanced view of the fatality rate across diverse geographical regions.
   - Formula: (Total Deaths / Total Cases) * 100.

2. Infection Rate and Population Impact:
   - By examining the ratio of total cases to population, I assessed the severity of infection in relation to demographics.
   - This assessment facilitates a deeper understanding of the pandemic's demographic disparities.
   - Formula: (Total Cases / Population) * 100.

3. Identifying Hotspots of Infection and Mortality:
   - Through rigorous analysis, I identified countries with the highest infection rates and death counts.
   - This analysis pinpoints geographical areas that have borne the brunt of the pandemic's impact.

4. Vaccination Progression Assessment:
   - I evaluated the percentage of the population that received at least one COVID-19 vaccine dose.
   - This assessment offers insights into the effectiveness and reach of vaccination campaigns.
   - Formula: (Total Vaccinated Population / Total Population) * 100.

5. Continent-Level Analysis:
   - I explored the continent-level analysis to uncover the highest death counts across various regions.
   - This analysis illuminates the pandemic's global ramifications, highlighting areas of significant concern.

These insights offer a holistic view of the COVID-19 pandemic's progression, impact, and response. This project underscores the pivotal role that data science plays in understanding complex global challenges and making informed decisions.

For further exploration and to validate these insights, refer to the data provided by the World Health Organization (WHO).

*/

-- Drop the temporary table
DROP TABLE IF EXISTS #CovidData
