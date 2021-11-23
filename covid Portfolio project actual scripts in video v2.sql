
select*
from PortfolioProject..covidDeaths
order by 3,4;
go


--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4;
--go


--select data that we are going to be using

select	*
from PortfolioProject..covidDeaths
where continent is not null
order by 1,2;
go


--looking at Total cases vs Total Deaths

 select	location, date, total_cases, total_deaths, (total_deaths/convert(float,total_cases))*100
 as DeathPercentage
from PortfolioProject..covidDeaths
--where location like '%state%'
where continent is not null
order by 1,2;
go


--looking at countries with highest Infection Rate compared to Population
--shows likelihood of dying if you contract covid in canada

select location, population, total_cases, total_deaths, (convert(float,total_deaths )/(convert(float,total_cases))*100) as DeathPercentage
from PortfolioProject..covidDeaths
--where location like '%canada%'
where continent is not null
order by 1,2;
go


--looking at total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, 
        (convert(float,total_cases))/population*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
order by 1,2;
go


--looking at countries with highest Infection rate to population

select location, population, max(total_cases) as HighestInfectionCount, 
       Max(cast(total_cases as float)/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc;
go


--showing countries with highest Death count perpopulation 

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%canada%'
where continent is not null
group by location
order by TotalDeathCount desc;
go


--let's break things down by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%canada%'
where continent is not null
group by continent
order by TotalDeathCount desc;
go


--showing the continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%canada%'
where continent is not null
group by continent
order by TotalDeathCount desc;
go


 --Global numbers

select  sum(convert(float,new_cases)) as total_cases, sum(convert(float,new_deaths)) as total_deaths, 
       sum(convert(float,new_deaths))/sum(convert(float,new_cases))*100 as DeathPercentage
from PortfolioProject..covidDeaths
--where location like '%state%'
where continent is not null
--group by date
order by 1,2;
go


--looking at Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) 
	   as Rollingpeoplevaccinated
	--   ,(Rollingpeoplevaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;
go


--use city

with popvsvac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) 
	   as Rollingpeoplevaccinated
	--   ,(Rollingpeoplevaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;
) 
select *,(Rollingpeoplevaccinated/population)*100
from popvsvac
go


--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
lacation nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) 
	   as Rollingpeoplevaccinated
	--   ,(Rollingpeoplevaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3;

select *, (Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated;
go


--creating view to store data for later visualisations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) 
	   as Rollingpeoplevaccinated
	--   ,(Rollingpeoplevaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;
go


select *
from PercentPopulationVaccinated;
go

