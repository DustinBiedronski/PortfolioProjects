use [ATA Project]

Select *
From CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From portfolio1..vaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
order by 1,2

--Lookimg at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at Total cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
From CovidDeaths
Where continent is not null
Where location like '%states%'
order by 1,2


Select location, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as percentpopulationinfected
From CovidDeaths
Where continent is not null
Group by location, population
order by percentpopulationinfected desc



Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From CovidDeaths
Where continent is not null
Group by date
order by 1,2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(floor(vac.new_vaccinations) as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--, (RollingPeopleVaxxed/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaxxed)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(floor(vac.new_vaccinations) as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--, (RollingPeopleVaxxed/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaxxed/Population)*100
From PopvsVac


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
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaxxed/Population)*100
From #PercentPopulationVaxxed



CREATE VIEW PercentPopulationVaxxed as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(floor(vac.new_vaccinations) as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
--, (RollingPeopleVaxxed/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3