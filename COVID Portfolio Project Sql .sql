select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,2) as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got covid
select location,date,total_cases,population,round((total_cases/population)*100,2) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'United states'
order by 1,2

--Looking at countries with highest Infection Rate compared to population

select location,max(total_cases) as HighestInfectionCount,population,max((total_cases/population))*100 as PercentPopulationInfected  
from PortfolioProject..CovidDeaths
--where location = 'United states'
group by location,population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per population

select location,max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
group by location
order by TotalDeathsCount desc

--Showing deaths by continent 

select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc


--GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum (cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date 
order by 1,2


--Looking at Total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac



--Temp Table

DROP TABLE  if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualization

create view PersentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PersentPopulationVaccinated

create view continentdata as
select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
--order by TotalDeathsCount desc



create view GlobalData as
select sum(new_cases) as total_cases,sum (cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date 
--order by 1,2
