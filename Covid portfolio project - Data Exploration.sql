-- checking that csv file has been imported succesfully
SELECT * FROM dbo.CovidDeaths
SELECT * FROM dbo.CovidVaccines

-- selecting data
SELECT location,date,total_cases_per_million,total_deaths_per_million, population
FROM dbo.CovidDeaths
order by 1,2

-- shows likelihood od dying if you contract covid in the country
SELECT location,date,total_cases_per_million,total_deaths_per_million, 
(total_deaths_per_million/total_cases_per_million) * 100 as deathpercentage
FROM dbo.CovidDeaths
where location like 'India'
order by 1,2 

-- shows what percentage of population got covid
SELECT location, cast(total_cases_per_million as int) as total_cases,population, 
    (total_cases_per_million/population)  * 100  as covidpopulation 
FROM dbo.CovidDeaths
where location like '%states%'
order by 1,2 

-- countries with highest infection rate
SELECT location,population,max(cast(total_cases_per_million as int)) as highestinfection,
 max(total_cases_per_million/population) * 100 as percentofpopulationinfected
FROM dbo.CovidDeaths
group by location,population
order by percentofpopulationinfected desc

--countries with highest death count per population
SELECT location,population, MAX(cast(total_deaths_per_million as int))as totaldeathcount
FROM dbo.CovidDeaths
where continent is not null
group by location,population
order by totaldeathcount desc 

-- showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths_per_million as int))as totaldeathcount
FROM dbo.CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc 

-- global numbers
SELECT date, sum(new_cases) as total_cases,
sum(CAST(new_deaths as int)) as totaldeaths
FROM dbo.CovidDeaths
WHERE continent is not null
group by date
order by 1,2 

-- using CTE
WITH popvsdia (continent,location,date,diabetes_prevalenceate,population,diabetics)
as(
SELECT dea.continent,dea.[location],dea.[date], dea.population, vac.diabetes_prevalence
,sum(CONVERT(int,vac.diabetes_prevalence)) 
over (PARTITION by dea.location ORDER by dea.[location],dea.[date]) as diabetics
FROM dbo.CovidDeaths  dea
join dbo.CovidVaccines vac
on dea.location = vac.location
and dea.[date] = vac.[date]
 where dea.continent is not NULL
-- order by 2,3
) 
select *, (diabetics/population)* 100
FROM popvsdia

-- TEMP TABLE
DROP TABLE IF EXISTS #percentpopulationdiabetic
CREATE TABLE #percentpopulationdiabetic
(
    continent NVARCHAR(255),
    location  NVARCHAR(255),
    date datetime,
    population NUMERIC,
    diabetic_prev numeric,
    diabetic numeric
)

Insert into #percentpopulationdiabetic
SELECT dea.continent,dea.[location],dea.[date], dea.population, vac.diabetes_prevalence
,sum(CONVERT(int,vac.diabetes_prevalence)) 
over (PARTITION by dea.location ORDER by dea.[location],dea.[date]) as diabetics
FROM dbo.CovidDeaths  dea
join dbo.CovidVaccines vac
on dea.location = vac.location
and dea.[date] = vac.[date]
 where dea.continent is not NULL

 select * from #percentpopulationdiabetic

--  Creating view to store data for later visualizations

CREATE VIEW percentpopulationdiabetic1 AS
SELECT dea.continent,dea.[location],dea.[date], dea.population, vac.diabetes_prevalence
,sum(CONVERT(int,vac.diabetes_prevalence)) 
over (PARTITION by dea.location ORDER by dea.[location],dea.[date]) as diabetics
FROM dbo.CovidDeaths  dea
join dbo.CovidVaccines vac
on dea.location = vac.location
and dea.[date] = vac.[date]
where dea.continent is not NULL

select * FROM percentpopulationdiabetic1
