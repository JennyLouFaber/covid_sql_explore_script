Select *
From CovidPortfolioProject..coviddeaths
Where continent is not null
order by 3,4

--Select *
--From CovidPortfolioProject..covidvaccinations
--order by 3,4


--Selecting Data that will be used

Select location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..coviddeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..coviddeaths
Where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population

Select location, date, total_cases, population, (total_cases/population)*100 as CasesPopuationPercentage
From CovidPortfolioProject..coviddeaths
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..coviddeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--Showing countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..coviddeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..coviddeaths
Where continent is null
Group by Location
order by TotalDeathCount desc

--Breaking down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..coviddeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global numbers

Select date, SUM(new_cases), SUM(cast(new_deaths as int))--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..coviddeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolioProject..coviddeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(CONVERT(int,new_deaths)) as total_deaths, SUM(CONVERT(int,new_deaths))/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolioProject..coviddeaths
Where continent is not null
order by 1,2

--Creating view to store data for later visualizations

Create View GlobalNumbers as
Select SUM(new_cases) as total_cases, SUM(CONVERT(int,new_deaths)) as total_deaths, SUM(CONVERT(int,new_deaths))/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolioProject..coviddeaths
Where continent is not null
--order by 1,2
Select *
From GlobalNumbers



-- Joining CovidDeaths table and CovidVaccinations table

Select *
From CovidPortfolioProject..coviddeaths dea
Join CovidPortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location)
From CovidPortfolioProject..coviddeaths dea
Join CovidPortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3
--When converting vac.new_vaccinations from varchar to int, an error occurred (Msg 8115, Level 16). I had to change int to bigint for the math to work.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..coviddeaths dea
Join CovidPortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..coviddeaths dea
Join CovidPortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..coviddeaths dea
Join CovidPortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PerceptPopulationVaccinated
Create Table #PerceptPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PerceptPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..coviddeaths dea
Join CovidPortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PerceptPopulationVaccinated


--Creating view to store data for later visualizations

Create View PerceptPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..coviddeaths dea
Join CovidPortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PerceptPopulationVaccinated