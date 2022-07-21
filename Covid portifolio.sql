/*
Covid 19 Data Exploration 

greater detail

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

--Looking Percentage of  Total Deaths vs Total cases 

Select Date, location,continent, total_cases , total_deaths, (total_deaths/total_cases)* 100 as Deathpercentage
From PortifolioProjects..CovidDeath
Order by 1 ,2 ;


--Looking at total cases against total population in 

Select Date, location, total_cases , population, (total_cases/population)* 100 as Casepercentage
From PortifolioProjects..CovidDeath
Where Location like '%africa%' and continent is not null
Order by 1 ,2 ;

--Country with highest infection rate compared to population

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

--Continents with Highest Death count per popupation

Select continent,  MAX (cast(total_deaths as int)/ population)*100 as MaxDeath
From PortifolioProjects.dbo.CovidDeath
Where continent is not null
Group by continent
Order by MaxDeath desc;

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

WITH CTE AS
(
SELECT *,ROW_NUMBER() OVER (PARTITION BY col1,col2,col3 ORDER BY col1,col2,col3) AS RN
FROM MyTable
)
DELETE FROM CTE WHERE RN<>1

