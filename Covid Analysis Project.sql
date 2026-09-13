Select *
From "CovidProject".coviddeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From "CovidProject".Coviddeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From "CovidProject".Coviddeaths
Where location ilike '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From "CovidProject".Coviddeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From "CovidProject".Coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From "CovidProject".Coviddeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;


-- Covid deaths by continent

Select continent, MAX(total_deaths) as TotalDeathCount
From "CovidProject".coviddeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;


-- Global Numbers by date

Select date, SUM(new_cases) as sum_of_cases, SUM(new_deaths) as sum_of_deaths, (SUM(new_deaths)/SUM(new_cases)*100) as GlobalDeathPercentage
From "CovidProject".Coviddeaths
WHERE continent is not null 
Group by date
order by 1,2;


-- Total global deaths

Select SUM(new_cases) as sum_of_cases, SUM(new_deaths) as sum_of_deaths, (SUM(new_deaths)/SUM(new_cases)*100) as GlobalDeathPercentage
From "CovidProject".Coviddeaths
WHERE continent is not null 
order by 1,2;


-- Total population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountofPeopleVaccinated,
(RollingCountofPeopleVaccinated/population)*100 as 
FROM "CovidProject".Coviddeaths dea
JOIN "CovidProject".Covidvaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3;


-- Using CTE showing rolling count and percentage of population vaccinated

WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingCountofPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountofPeopleVaccinated
FROM "CovidProject".coviddeaths dea
JOIN "CovidProject".covidvaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,
(RollingCountofPeopleVaccinated / population) * 100 AS RollingPercentageofPeopleVaccinated
FROM PopVSVac;


-- Creating view to store data for later vizualization

CREATE VIEW "CovidProject".CovidDeathsbyContinent as
Select continent, MAX(total_deaths) as TotalDeathCount
From "CovidProject".coviddeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;




































