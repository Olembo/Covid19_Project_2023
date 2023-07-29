/*
Covid 19 Data Exploration 
*/

select *
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 1, 2


---- Looking at Total cases Vs Total Deaths
-- Shows likelihood of duying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location = 'Canada' 
and continent is not null
order by 1, 2


--- Looking Total Cases Vs Population
--- Shows what percentage  of population got covid
Select Location, date,  Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location = 'United States'
and continent is not null
order by 1, 2

---Looking at Countries with highest Infection Rate compare to Population
Select Location,  Population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location = 'Canada'
--Where continent is not null
Group by Location, Population
order by PercentPopulationInfected Desc


---- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) As TotalDeathCount
from PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount Desc


--- Highest Death count by continent
Select continent,   MAX(cast(total_deaths as int)) As TotalDeathCount
from PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount Desc


----- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
---group by date
order by 1, 2


--- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--- USE CTE

With PopvsVac (continent, location, date, Population, New_Vaccnations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--- TEMP TABLE 

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


---- Creating view to store ata for visualisations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$  dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated



Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
