/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Use PortifolioProjects
Go
Select* 
From PortifolioProjects..CovidDeath
Order by 3 ,4 ;

Select* 
From PortifolioProjects..CovidVaccinations
Order by 3 ,4 ;

---Select Data to use

Select Date, location, total_cases ,new_cases, total_deaths, population
From PortifolioProjects..CovidDeath
Order by 1 ,2 ;

-- Percentage of Total Deaths vs Total cases 
-- Shows likelihood of dying if you contract covid in your country

Select Date, location,continent, total_cases , total_deaths, (total_deaths/total_cases)* 100 as Deathpercentage
From PortifolioProjects..CovidDeath
Order by 1 ,2 ;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Date, location, total_cases , population, (total_cases/population)* 100 as Casepercentage
From PortifolioProjects..CovidDeath
Where Location like '%africa%' and continent is not null
Order by 1 ,2 ;

-- Countries with Highest Infection Rate compared to Population

Select location,population, MAX (total_cases) as HighestInfectionCount , MAX  ((total_cases/population))* 100 as Casepercentage
From PortifolioProjects..CovidDeath
--Where Location like '%africa%'
Group by location,population
Order by Casepercentage desc ;

--Countries with Highest Death 

Select location as Country,  MAX (cast(total_deaths as bigint)) as MaxDeath
From PortifolioProjects.dbo.CovidDeath
Where continent is not null
Group by location 
Order by MaxDeath desc;

--CONTINENTS
--Continents with Highest Death count per popupation

Select continent,  MAX (cast(total_deaths as int)/ population)*100 as MaxDeath
From PortifolioProjects.dbo.CovidDeath
Where continent is not null
Group by continent
Order by MaxDeath desc;

--GLOBAL TRENDS

--Percentage of Total daily total death cases 

Select [date],
			SUM (new_cases) as Ncases,
			SUM (cast(new_deaths as int)) as Ndeaths,
			SUM (cast(new_deaths as int))/ SUM (new_cases ) * 100 as DeathPerc 
From  PortifolioProjects.dbo.CovidDeath
where continent is not null 
		And new_cases is not null 
		AND new_deaths is not null
Group by [Date]
Order by DeathPerc desc

--Total global death cases

Select
			SUM (new_cases) as Totalcases,
			SUM (cast(new_deaths as int)) as Totaldeaths,
			SUM (cast(new_deaths as int))/ SUM (new_cases ) * 100 as TotalDeathPerc 
From  PortifolioProjects.dbo.CovidDeath
where continent is not null 
		And new_cases is not null 
		AND new_deaths is not null
		

--Total population vs Vaccinnnations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date
From PortifolioProjects..CovidDeath dea
Join PortifolioProjects..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date

--to further remove duplicate rows from above query???


Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations 
From PortifolioProjects..CovidDeath dea
Join PortifolioProjects..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations > 1
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
SUM (cast(vac.new_vaccinations as bigint)) 
				 OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVac
				 From PortifolioProjects..CovidDeath dea
Join PortifolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	 AND dea.date = vac.date
Where dea.continent is not null --and vac.new_vaccinations > 1
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
--SUM (cast(vac.new_vaccinations as bigint)) 
				 --OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVac
From dbo.CovidDeath dea
Outer Join dbo.CovidVaccinations vac
	On dea.location = vac.location
	 AND dea.date = vac.date
Where dea.continent is not null --and vac.new_vaccinations > 1
Order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

WITH CTE AS
(
SELECT *,ROW_NUMBER() OVER (PARTITION BY col1,col2,col3 ORDER BY col1,col2,col3) AS RN
FROM MyTable
)
DELETE FROM CTE WHERE RN<>1

