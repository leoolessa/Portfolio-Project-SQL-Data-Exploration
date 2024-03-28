/*

Queries used for Tableau Project

*/



-- 1. 
-- OLD

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths 
where continent is not null 
order by 1,2



-- New
Select SUM(population) as total_population, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as float)) as total_deaths,  
		SUM(Cast(new_deaths as float))/SUM(new_cases)*100 as deaths_percentage,
		SUM(new_cases)/SUM(population)*100 as infected_percentage
from PortfolioProject..covid_deaths
where continent is not null
order by 1,2



-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2



-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths 
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc



-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths 
Group by Location, Population
order by PercentPopulationInfected desc



-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths 
Group by Location, Population, date
order by PercentPopulationInfected desc







