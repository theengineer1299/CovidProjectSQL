Select *
From [Covid Portfolio Project]..CovidDeaths
Order by 3,4

Select *
From [Covid Portfolio Project]..CovidVaccinations

-- Selecting the Data we're going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Covid Portfolio Project]..CovidDeaths
Order by 1,2


-- Looking at the Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..CovidDeaths
Where location like '%lanka%'
and continent is not null
Order by 1,2 


-- Looking at the Total Cases vs Population
-- Shows what percentage of the population caught Covid-19

Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From [Covid Portfolio Project]..CovidDeaths
Where location like '%lanka%'
Order by 1,2 


-- Countries with highest infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentagePopulationInfected desc

-- COuntries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Breaking things down by Continent
-- Showing Continents with Highest Death Count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
Order by 1,2 


-- Joining Deaths and Vaccines Tables

Select * 
From [Covid Portfolio Project]..CovidDeaths as dea
Join [Covid Portfolio Project]..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Covid Portfolio Project]..CovidDeaths as dea
Join [Covid Portfolio Project]..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Looking at Latest Vaccination Numbers per Date According to Location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumPeopleVaccinated
From [Covid Portfolio Project]..CovidDeaths as dea
Join [Covid Portfolio Project]..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Portfolio Project]..CovidDeaths dea
Join [Covid Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Creating View to store data later for Visualizations

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Portfolio Project]..CovidDeaths dea
Join [Covid Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


