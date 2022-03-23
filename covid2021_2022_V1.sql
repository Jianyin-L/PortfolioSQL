-- Data Exploration for Covid dataset

-- Covid Deaths
SELECT *
FROM portfolio_covid..CovidDeaths
ORDER BY location, date;


-- Daily comfirmed Cases, Death and Death Percentage in the world
SELECT format(date, 'dd-MMM-yyyy') as CurrentDate, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, ROUND(sum(cast(new_deaths as int))/sum(new_cases)*100, 4) as DeathsPercentage
FROM portfolio_covid..CovidDeaths
WHERE (new_cases is NOT null) and (continent is NOT null) and (new_deaths is NOT null)
GROUP BY date
ORDER BY date;


-- Total Cases, Death and Death Percentage of each continent
SELECT continent, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as TotalDeath, ROUND(sum(cast(new_deaths as int))/sum(new_cases)*100, 4) as DeathsPercentage
FROM portfolio_covid..CovidDeaths
WHERE (new_deaths is Not null) and continent is NOT null and (new_deaths is NOT null)
GROUP BY continent
ORDER BY DeathsPercentage desc;


-- Total Cases, Death and Death Percentage of each country
SELECT continent, location, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as TotalDeath, ROUND(sum(cast(new_deaths as int))/sum(new_cases)*100, 4) as DeathsPercentage
FROM portfolio_covid..CovidDeaths
WHERE (new_deaths is Not null) and continent is NOT null and (new_deaths is NOT null)
GROUP BY continent, location
ORDER BY DeathsPercentage desc;


-- Confirmed cases over population per country as of February 7, 2022
SELECT continent, location, format(date, 'dd-MMM-yyyy') as date, population, total_cases, ROUND((total_cases/population)*100, 4) as CovidsPercentage
FROM portfolio_covid..CovidDeaths
WHERE ((date) = (SELECT max(date) FROM portfolio_covid..CovidDeaths)) 
and (total_cases is NOT null) and (population is Not null) 
and continent is NOT null
ORDER BY CovidsPercentage desc;


-- Death cases over population per country as of February 7, 2022
SELECT continent, location, format(date, 'dd-MMM-yyyy') as date, population, cast(total_deaths as int) as total_deaths, ROUND((cast(total_deaths as int)/population)*100, 4) as DeathsPercentage
FROM portfolio_covid..CovidDeaths
WHERE ((date) = (SELECT max(date) FROM portfolio_covid..CovidDeaths)) 
and (total_deaths is NOT null) and (population is Not null)
and continent is NOT null
ORDER BY DeathsPercentage desc;


-- Total Cases V.S. Total Population in Australia over the past 2 years
SELECT location, format(date, 'dd-MMM-yyyy'), population, total_cases, ROUND((total_cases/population)*100, 4) as CovidsPercentage
FROM portfolio_covid..CovidDeaths
WHERE location = 'Australia'
ORDER BY date;


-- Covid Vaccinations
SELECT *
FROM portfolio_covid..CovidVaccinations
ORDER BY location, date;


-- Rolling value, Partition by, Order by
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingVaccinated
FROM portfolio_covid..CovidDeaths dea Join portfolio_covid..CovidVaccinations vac
ON (dea.location = vac.location) and (dea.date = vac.date)
WHERE dea.continent is NOT null
ORDER by dea.location, dea.date


-- Use common_table_expression
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingVaccinated
FROM portfolio_covid..CovidDeaths dea Join portfolio_covid..CovidVaccinations vac
ON (dea.location = vac.location) and (dea.date = vac.date)
WHERE dea.continent is NOT null
)
SELECT continent, location, date, population, new_vaccinations, RollingVaccinated, (RollingVaccinated/population)*100 as VaccinatedOverPop 
From PopvsVac
ORDER by location, date


-- Use Temp table
DROP TABLE if exists #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPopVaccinated numeric
)
Insert into #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingVaccinated
FROM portfolio_covid..CovidDeaths dea Join portfolio_covid..CovidVaccinations vac
ON (dea.location = vac.location) and (dea.date = vac.date)
WHERE dea.continent is NOT null
ORDER by dea.location, dea.date

SELECT continent, location, date, population, new_vaccinations, RollingPopVaccinated, (RollingPopVaccinated/population)*100 as VaccinatedOverPop 
From #PercentPopVaccinated
ORDER by location, date


-- Fully Vaccinated over time in Australia
select dea.date, dea.population, vac.people_fully_vaccinated, (vac.people_fully_vaccinated/dea.population)*100
FROM portfolio_covid..CovidDeaths dea Join portfolio_covid..CovidVaccinations vac
ON (dea.location = vac.location) and (dea.date = vac.date)
WHERE (dea.continent is NOT null) and (dea.location = 'Australia')
order by dea.location, dea.date;



-- Create View
Create View abc as
SELECT *
FROM portfolio_covid..CovidVaccinations

SELECT * 
FROM abc
