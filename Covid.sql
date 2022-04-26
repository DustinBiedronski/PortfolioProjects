/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From [ATA Project]..CovidDeaths
Where continent is not null
order by 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From [ATA Project]..CovidDeaths
Where continent is not null
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [ATA Project]..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
From [ATA Project]..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as percentpopulationinfected
From [ATA Project]..CovidDeaths
--Where location like '%states&'
Group by location, population
order by percentpopulationinfected desc


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [ATA Project]..CovidDeaths
--Where location like '%states&'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [ATA Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From [ATA Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(floor(vac.new_vaccinations) as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--, (RollingPeopleVaxxed/population)*100
From [ATA Project]..CovidDeaths dea
Join [ATA Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaxxed)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(floor(vac.new_vaccinations) as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--, (RollingPeopleVaxxed/population)*100
From [ATA Project]..CovidDeaths dea
Join [ATA Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaxxed/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaxxed
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaxxed numeric
)

INSERT INTO #PercentPopulationVaxxed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(floor(vac.new_vaccinations) as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--, (RollingPeopleVaxxed/population)*100
From [ATA Project]..CovidDeaths dea
Join [ATA Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaxxed/Population)*100
From #PercentPopulationVaxxed




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaxxed as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(floor(vac.new_vaccinations) as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--, (RollingPeopleVaxxed/population)*100
From [ATA Project]..CovidDeaths dea
Join [ATA Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

