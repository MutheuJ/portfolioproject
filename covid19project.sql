
select *
from coviddeaths


--select *
--from covidvaccination

--selecting data to use

select location, date, total_cases, new_cases, population
from coviddeaths
order by 2

--total cases vs total deaths
 -- lielihood
 select location, date, total_cases, total_deaths, (cast(total_deaths as int))/ (cast(total_cases as float))*100 as deathpercentage
 from coviddeaths 
 where location like '%states%'
 and continent is not null 
order by 1,2 

---total cases vs population
select location, date, total_cases, population, (cast(total_cases as float))/ (cast( population as float))*100 as deathpercentage
 from coviddeaths 
 --where location like '%states%'
order by 1,2 

--highest infection rate country
select location, population, max(cast(total_cases as float)) as HighestInfectionCount,
max(cast(total_cases as float))/(cast( population as float))*100 as PopulationInfectedpercentage
 from coviddeaths 
 --where location like '%states%'
 group by location, population
order by HighestInfectionCount desc

--highest death count per population

select location, max(cast(total_deaths as float)) as TotalDeathCount
 from coviddeaths 
 --where location like '%states%'
 where continent is not null
 group by location
order by TotalDeathCount desc


--by continent
select continent, max(cast(total_deaths as float)) as TotalDeathCount
 from coviddeaths 
 --where location like '%states%'
 where continent is not null
 group by continent
order by TotalDeathCount desc

--continent with highest count
select continent, max(cast(total_deaths as float)) as TotalDeathCount
 from coviddeaths 
 --where location like '%states%'
 where continent is not null
 group by continent
order by TotalDeathCount desc

--global numbers
--use set arithabort and ansi_warning off if denominator is zero
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
from coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, (cast(dea.Date as date ))) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--use cte
with popvsvac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, (cast(dea.Date as date ))) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from popvsvac

--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, (cast(dea.Date as date ))) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated

select *
from covidvaccinations

--creating view 
create view percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, (cast(dea.Date as date ))) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
select *
from percentpopulationvaccinated