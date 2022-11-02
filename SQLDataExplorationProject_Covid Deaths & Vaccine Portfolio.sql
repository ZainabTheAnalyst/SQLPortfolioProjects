select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Looking at Total cases vs Total Deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from portfolioproject..coviddeaths
where location = 'canada' 
order by 1,2

--Looking at Total Case vs Population
select location,date,Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..coviddeaths
where location = 'canada' 
order by 1,2

--Looking at countries with HighestInfection Rate compared to Population
select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject..coviddeaths
group by location, population 
order by PercentPopulationInfected DESC

-- Showing countires with Highest Death Count per Population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per Population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers 
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from portfolioproject..coviddeaths
where continent is not null
order by 1,2

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
where continent is not null
--group by date
order by 1,2

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
where continent is not null
order by 1,2

-- COVID VACCINATIONS

SELECT*
FROM PortfolioProject..Covidvaccinations

Select*
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date

-- Looking at Total Population vs Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated,

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE 
With PopVsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
)
select *, (rollingpeoplevaccinated/Population)*100
from PopVsVac

--TempTable 

Drop Table if exists #percentpopulationvaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null 


select *, (rollingpeoplevaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating Views to store data for later visualizations 

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 



Select *
From PercentPopulationVaccinated

CREATE VIEW HighestDeathCount AS
select location,max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
where continent is not null
group by location
