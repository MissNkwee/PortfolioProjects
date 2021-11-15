Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4 

--Select Data that we are going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Lookig at Total cases vs Total Deaths
--This shows the likelihood of dying if you contract covid in your country or part of the continent 
Select Location, date, total_deaths, total_cases,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Africa%'
order by 1,2

--Loooking  at Total cases vs Population
--Shows what percentage of poulation got Covid 
Select Location, date, population, total_cases,(cast(total_cases as float)/cast(population as float))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
where location like '%Africa%'
order by 1,2


--Looking at countries with highest Infection Rate Compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCountries,Max((cast(total_cases as float)/cast(population as float)))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
Order by InfectionPercentage desc

--Showing Countries with Highest Death 
Select Location, MAX(cast(total_deaths as float))as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing  continenets with the  highest death count per population 
Select continent, MAX(cast(total_deaths as float))as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS 

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
--USE CTE
With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.date)as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac 
     On  dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/cast(population as float))*100 as RollingPeopleVaccinatedPerPopulation
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.date)as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac 
     On  dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later vizualizations in tableau
DROP VIEW if exists PercentPopulationVaccinated
use [PortfolioProject]
Create View PercentPopulationVaccinated 
AS Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.date)as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac 
     On  dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated