SELECT *
FROM Project..CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT *
FROM Project..CovidVaccinations
where continent is not null
ORDER BY 3,4

--Data going to be used
Select Location,date,total_cases,new_cases,total_deaths,population
From Project..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
--shows likelihood of dying if you contract covid in our country
Select Location,date,total_cases,total_deaths,( total_deaths/total_cases)*100 as DeathPercentage
From Project..CovidDeaths
Where location like '%india%' and continent is not null
order by 1,2

--Looking at Total Cases Vs Population
--shows what % of population got covid
Select Location,date,population,total_cases,( total_cases/population)*100 as PercentPopulationInfected
From Project..CovidDeaths
--Where location like '%india%'
where continent is not null
order by 1,2


--Looking at Countries having highest infection rate compared to  whole population
Select Location,population,MAX(total_cases)as HighestInfectionCount,MAX(( total_cases/population))*100 as PercentPopulationInfected
From Project..CovidDeaths
--Where location like '%india%'
where continent is not null
group by Location, population
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per population
Select Location,MAX(cast(total_deaths as int))as TotalDeathCount
From Project..CovidDeaths
--Where location like '%india%'
where continent is not null
group by Location 
order by TotalDeathCount desc

--Breaking down by continent
--showing continents with the highest death count
Select continent,MAX(cast(total_deaths as int))as TotalDeathCount
From Project..CovidDeaths
--Where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project..CovidDeaths
--Where location like '%india%' 
where continent is not null
--group by date
order by 1,2


--Looking at Total Population Vs Vaccinations
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingCountOfPeopleVaccinated
FROM Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--Use CTE of the previous query for getting percentage of  RollingCountOfPeopleVaccinated column
with PopVsVac (Continent, Location, Date, Population,New_Vaccination, RollingCountOfPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingCountOfPeopleVaccinated
FROM Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingCountOfPeopleVaccinated/Population)*100
From PopVsVac

--TEMP TABLE
DROP TABLE if exists #percentPopulationVaccinated
create Table #percentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountOfPeopleVaccinated  numeric)

Insert into #percentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingCountOfPeopleVaccinated
FROM Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date= vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingCountOfPeopleVaccinated/Population)*100
From #percentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create view PopulationVaccinatedpercent as
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingCountOfPeopleVaccinated
FROM Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3


select *
from PopulationVaccinatedpercent