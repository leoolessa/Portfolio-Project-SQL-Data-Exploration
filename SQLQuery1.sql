/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * 
from PortfolioProject..covid_deaths
where continent is not null
order by 3,4



-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
where continent is not null
order by 1,2



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths / total_cases)* 100 as death_percentage
from PortfolioProject..covid_deaths
where location like '%Brazil%'
and continent is not null
order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got infected by covid

Select Location, date, population, total_cases, (total_cases / population)* 100 as percentage_population_infected
from PortfolioProject..covid_deaths
order by 1,2



-- Looking at countries with hightest infaction rate compared to population

Select Location, Population, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_population_infected
from PortfolioProject..covid_deaths
Group by Location, Population
order by percent_population_infected desc



-- Looking at countries with higthest Death count per population

Select location, MAX(cast(total_deaths as int)) as total_deathCount
from PortfolioProject..covid_deaths
where continent is not null
group by location
order by total_deathCount desc



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing  cotinents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as total_deathCount
from PortfolioProject..covid_deaths
where continent is not null
group by continent
order by total_deathCount desc




-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as death_percentage
from PortfolioProject..covid_deaths
where continent is not null
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated,
(rolling_people_vaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location =  vac.location 
	And dea.date = vac.date
Where dea.continent is not null
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated,
(rolling_people_vaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location =  vac.location 
	And dea.date = vac.date
Where dea.continent is not null
)
Select *, (rolling_people_vaccinated/population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #percent_population_vaccinated
Select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated,
(rolling_people_vaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location =  vac.location 
	And dea.date = vac.date

Select *, (rolling_people_vaccinated/population)*100
From #percent_population_vaccinated



-- Creating View to store data for later visualizations

Create View percent_population_vaccinated as 
Select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated,
(rolling_people_vaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location =  vac.location 
	And dea.date = vac.date
where dea.continent is not null