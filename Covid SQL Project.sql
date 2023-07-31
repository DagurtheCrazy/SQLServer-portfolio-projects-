select * from CovidVaccinations order by 3,4;
select * from CovidDeaths order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2;

select location,date,total_cases,total_deaths, convert(numeric(5,2),(cast(total_deaths as float)/cast(total_cases as float))*100) as DeathPercentage
from dbo.CovidDeaths
where location like('%Italy%')
order by 1,2;

select location,date,total_cases,total_deaths, convert(numeric(18,2), (cast(total_deaths as float)/cast(total_cases as float))*100) as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1,2;

select location,date,total_cases,population, convert(numeric(5,2),(cast(total_cases as float)/population)*100) as InfectedPercentage
from dbo.CovidDeaths
where location like('%Italy%')
order by 1,2;

select location,date,population,total_cases, convert(numeric(5,2),(cast(total_cases as float)/population)*100) as InfectedPercentage
from dbo.CovidDeaths
where continent is not null
order by 1,2;

select location,cast(cast(population as float) as int) as population ,max(cast(cast(total_cases as float) as int)) as HighestInfectionCount, convert(numeric(18,2),max((cast(total_cases as float)/population))*100) as PercentPopulationInfected
from dbo.CovidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc;

select location,cast(cast(population as float) as int) as population,date,max(cast(cast(total_cases as float) as int)) as HighestInfectionCount, convert(numeric(18,2),max((cast(total_cases as float)/population))*100) as PercentPopulationInfected
from dbo.CovidDeaths
where continent is not null
group by location,population,date
order by PercentPopulationInfected desc;

create view PercentTotalPopulationInfected 
as(
select location,cast(cast(population as float) as int) as population ,max(cast(cast(total_cases as float) as int)) as HighestInfectionCount, convert(numeric(18,2),max((cast(total_cases as float)/population))*100) as PercentPopulationInfected
from dbo.CovidDeaths
where continent is not null
group by location,population
);
select * from PercentTotalPopulationInfected order by location;


select location, MAX(cast(cast(total_deaths as float) as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

create view NationsTotalDeathCount 
as (
select location, MAX(cast(cast(total_deaths as float) as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by location
);
select * from NationsTotalDeathCount order by TotalDeathCount desc;


select continent, Sum(cast(cast(new_deaths as float) as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

create view ContinentTotalDeathCount 
as (
select continent, MAX(cast(cast(total_deaths as float) as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
);
select * from ContinentTotalDeathCount order by TotalDeathCount desc;


select date,SUM(cast(new_cases as float)) as TotalNewCases, SUM(cast(new_deaths as float)) as TotalNewDeaths,
convert(numeric(5,2),SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100) as DeathPercentage
from dbo.CovidDeaths
where continent is not null
group by date
having SUM(cast(new_cases as float))<> 0
order by 1;

select SUM(cast(new_cases as float)) as Total_Cases, SUM(cast(new_deaths as float)) as Total_Deaths,
convert(numeric(5,2),SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100) as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1;

select cd.continent,cd.location,cd.date,cast(cd.population as float) as population,
cast(cv.new_vaccinations as float) as new_vaccinations,
SUM(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3;

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
select cd.continent,cd.location,cd.date,cast(cd.population as float) as population,
cast(cv.new_vaccinations as float) as new_vaccinations,
SUM(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 from PopvsVac;

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);
insert into #PercentPopulationVaccinated
select cd.continent,cd.location,cd.date,cast(cd.population as float) as population,
cast(cv.new_vaccinations as float) as new_vaccinations,
SUM(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null;

select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated from #PercentPopulationVaccinated;


create view PercentPopulationVaccinated 
as(
select cd.continent,cd.location,cd.date,cast(cd.population as float) as population,
cast(cv.new_vaccinations as float) as new_vaccinations,
SUM(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
);
select * from PercentPopulationVaccinated;




