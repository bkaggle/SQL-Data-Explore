select *
from covidDeath
where continent is not null
order by 3,4

-----Let's select the data we are going to using
select location,date,new_cases,total_cases,total_cases,population
from covidDeath
where continent is not null
order by 1,2


--Looking at Total cases vs Total deaths
select location,date ,total_deaths,total_cases,(total_deaths/total_cases)*100 as DeathPercentage
from covidDeath
where continent is not null
order by 1,2


---Looking at population vs Total cases
select location,date,population ,total_cases,(total_cases/population)*100 as CasePerPopulation
from covidDeath
where continent is not null
order by 1,2



---Looking at countries with highest infection compared to population
select location,population,date,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 as PercentInfectedPopulation
from covidDeath
where continent is not null
group by location,population,date
order by PercentInfectedPopulation desc


---Showing highest Death count per population
select location,population ,MAX(cast(total_deaths as int)) AS HighestDeathCount
from covidDeath
where continent is not null
group by location,population
order by HighestDeathCount desc


---Let's break things down by continent
select continent ,MAX(cast(total_deaths as int)) AS HighestDeathCount
from covidDeath
where continent is not null
group by continent
order by HighestDeathCount desc


---GLOBAL NUMBERS
select SUM(total_cases) as TotalCases,SUM(cast(total_deaths as int)) as TotalDeaths,SUM(cast(total_deaths as int))/SUM(total_cases)*100 as DeathPercentage
from covidDeath
where continent is not null
order by 1,2


---Join two tables and looking at vaccination vs population
select *
from covidVaccination

select covidDeath.continent,covidDeath.location,covidDeath.date,covidDeath.population,covidVaccination.new_vaccinations,
sum(cast(covidVaccination.new_vaccinations as bigint)) over (partition by covidDeath.location order by covidDeath.date,covidDeath.location) 
as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population) / you can't use the column you just created
from covidDeath
join covidVaccination
on covidDeath.date=covidVaccination.date
and covidDeath.location=covidVaccination.location
where covidDeath.continent is not null
order by 2,3


--- USE CTE

with popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select covidDeath.continent,covidDeath.location,covidDeath.date,covidDeath.population,covidVaccination.new_vaccinations,
sum(cast(covidVaccination.new_vaccinations as bigint)) over (partition by covidDeath.location order by covidDeath.date,covidDeath.location) 
as RollingPeopleVaccinated
 
from covidDeath
join covidVaccination
on covidDeath.date=covidVaccination.date
and covidDeath.location=covidVaccination.location
where covidDeath.continent is not null
---order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from popvsvac



--- TEMP TABLES
DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date Datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select covidDeath.continent,covidDeath.location,covidDeath.date,covidDeath.population,covidVaccination.new_vaccinations,
sum(cast(covidVaccination.new_vaccinations as bigint)) over (partition by covidDeath.location order by covidDeath.date,covidDeath.location) 
as RollingPeopleVaccinated
 
from covidDeath
join covidVaccination
on covidDeath.date=covidVaccination.date
and covidDeath.location=covidVaccination.location
where covidDeath.continent is not null
---order by 2,3

select *,(RollingPeopleVaccinated/population)
from #PercentPopulationVaccinated


--- Let's create a view for later visualizations

create view PercentPopulationVaccinated as
select covidDeath.continent,covidDeath.location,covidDeath.date,covidDeath.population,covidVaccination.new_vaccinations,
sum(cast(covidVaccination.new_vaccinations as bigint)) over (partition by covidDeath.location order by covidDeath.date,covidDeath.location) 
as RollingPeopleVaccinated
 
from covidDeath
join covidVaccination
on covidDeath.date=covidVaccination.date
and covidDeath.location=covidVaccination.location
where covidDeath.continent is not null
---order by 2,3

select *
from PercentPopulationVaccinated