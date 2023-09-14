SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

---- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


---- Total Cases vs Total Deaths
-- Likelyhood of dying if you contract covid in specific countries
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2


---- Looking at Total Cases vs Population
-- Shows what percentage of population contracted Covid
SELECT location, date, population,  total_cases, (total_cases/population)*100 AS Infected_Population_Ratio
FROM CovidDeaths
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population
SELECT location, population,  MAX(total_cases) AS Highest_Infection_Count, 
MAX((total_cases/population))*100 AS Infected_Population_Ratio
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC


-- Countries with highest death count
SELECT location, MAX(cast(Total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY 2 DESC


---- Breaking down by continent

-- Showing continents with the highest death count
SELECT continent, MAX(cast(Total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY 2 DESC


-- Global numbers
SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Death_Percentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Looking at total population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date



-- Using CTE for analysis

With PopVsVac (Continent, Location, Date, population, NewVaccinations,
RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY location, date
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac




-- TEMP table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(55),
Location varchar(55),
Date datetime,
Population int,
New_Vaccinations int,
RollingPeopleVaccinated int
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY location, date

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationsPercentage
FROM #PercentPopulationVaccinated


-- Creating views to store data for visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY location, date

CREATE VIEW Total_Deaths_Per_Continent AS
SELECT continent, MAX(cast(Total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
--ORDER BY 2 DESC

CREATE VIEW Total_Deaths_Per_Country AS
SELECT location, MAX(cast(Total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY Location
--ORDER BY 2 DESC

CREATE VIEW Infection_Percentage_Per_Country AS
SELECT location, population,  MAX(total_cases) AS Highest_Infection_Count, 
MAX((total_cases/population))*100 AS Infected_Population_Ratio
FROM CovidDeaths
--WHERE location = 'United States'
GROUP BY location, population
--ORDER BY 4 DESC

