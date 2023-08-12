
Select *
From PotfolioProjectSql..CovidDeaths11
Where continent is not null
Order by 3,4


--Select *
--From PotfolioProjectSql..Covidvacc
--Order by 3,4

--Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PotfolioProjectSql..CovidDeaths11
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases,  total_deaths, cast(cast(total_deaths as float) / cast(total_cases as float)as float) *100 as death_percentage
From PotfolioProjectSql..CovidDeaths11
where location like '%states%'
Order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, population, total_cases, cast(cast(total_cases as float) / cast(population as float)as float) *100 as death_percentage
From PotfolioProjectSql..CovidDeaths11
where location like '%states%'
and continent is not null
Order by 1,2


--Looking at Countries with highest infection rate compare to Population

Select Location, population, MAX(total_cases) As Highest_Infection_Count, Max(cast(total_cases as float)) / cast(population as float) *100 as PercentofPopulationInfected
From PotfolioProjectSql..CovidDeaths11
--where location like '%states%'
Group by population, location
Order by PercentofPopulationInfected Desc

--Showing the Country With the Highest Death Count Per Population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PotfolioProjectSql..CovidDeaths11
Where continent is  null
Group by location
Order by Total_Death_Count desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From PotfolioProjectSql..CovidDeaths11
Where continent is not null
Group by continent
Order by Total_Death_Count desc

--Showing the Continent with the Highest Death Count Per Population

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From PotfolioProjectSql..CovidDeaths11
Where continent is not null
Group by continent
Order by Total_Death_Count desc


--GLOBAL NUMBERS

Select sum(new_cases) as sumnewcases, sum(new_deaths)as sumnewdeaths, sum(cast(new_deaths as float ))/sum(cast(new_cases as float))* 100  as death_percentage
From PotfolioProjectSql..CovidDeaths22
--where location like '%states%'
where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location Order by dea.location
) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from PotfolioProjectSql..CovidDeaths11 dea
Join PotfolioProjectSql..Covidvacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


--USING CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location Order by dea.location
) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from PotfolioProjectSql..CovidDeaths11 dea
Join PotfolioProjectSql..Covidvacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population) *100
From PopvsVac


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location Order by dea.location
) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from PotfolioProjectSql..CovidDeaths11 dea
Join PotfolioProjectSql..Covidvacc vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
Order by 2,3

Select *, (Rolling_People_Vaccinated/Population) *100
From #PercentPopulationVaccinated


--Creating View To Store Data For Later Visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location Order by dea.location
) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from PotfolioProjectSql..CovidDeaths11 dea
Join PotfolioProjectSql..Covidvacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated
