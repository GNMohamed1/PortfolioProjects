
Select *
From PortfolioProject..CovidDeaths
order by 3,4



-- Selecting the data which will be explored

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Shows the death rate from Covid in Egypt

Select location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as DeathPrecentage
From PortfolioProject..CovidDeaths
Where location like '%egypt%' and continent is not null
order by 1,2


-- Shows the precentage of population got Covid in Egypt

Select location, date, total_cases, population,(total_cases/population)*100 as InfectedPrecentage
From PortfolioProject..CovidDeaths
Where location like '%egypt%' and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to the Population

Select Location, Population, MAX(total_cases), MAX((total_cases/population))*100 as InfectedPrecentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
order by InfectedPrecentage desc


-- Looking at Countries with Highest Death Count

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Looking at Continent with Highest Death Count

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc


-- Global Numbers


Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPrecentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2



-- Looking at Total Population vs Vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
order by 3,2 


-- Use CTE

With PopvsVac (Contient, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Creating Temp Table

Drop Table if exists #PrecentPopulationVaccinated

Create Table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PrecentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PrecentPopulationVaccinated


-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null

Select *
From PercentPopulationVaccinated