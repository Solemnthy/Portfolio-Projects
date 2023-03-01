Select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2

-- total cases vs total deaths 
-- shows likelihood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as 'Death Percentage'
from covid_deaths
where location like '%philippines%'
order by 1,2


-- total cases vs population
-- percentage of population got covid 
select location, date, population, total_cases ,
(total_cases/population)*100 as 'Percent Population Infected'
from covid_deaths
where location like '%philippines%'
order by 1,2

-- countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PercentPopulationInfected
from covid_deaths
group by 1,2
order by PercentPopulationInfected desc



-- Countries with hightes death count  
select location, max(cast(total_deaths as signed)) as TotalDeathCount
from covid_deaths
where continent is not null
group by location
order by TotalDeathCount 


-- Continent with highest death count per population
Select location, max(cast(total_deaths as signed)) as totaldeathcount
from covid_deaths
where continent is null
group by location
order by totaldeathcount desc



-- Global numbers
select date, sum(new_cases) as total_cases, 
sum(cast(new_deaths as signed)) as total_deaths,
(sum(cast(new_deaths as signed))/sum(new_cases))*100 as 'Death Percentage'
from covid_deaths
where continent is not null
group by date
order by 1,2


-- Total Population vs Vaccinations

Select dae.continent, dae.location, dae.date, dae.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as signed)) 
over (partition by  dae.location order by dae.location, dae.date) as rollingpeoplevaccinated,
from covid_deaths as dae
join covid_vaccinations as vac on dae.location = vac.location
and dae.date = vac.date
where dae.continent is not null
order by 2,3


-- cte

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
Select dae.continent, dae.location, dae.date, dae.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as signed)) 
over (partition by  dae.location order by dae.location, dae.date) as rollingpeoplevaccinated
from covid_deaths as dae
join covid_vaccinations as vac on dae.location = vac.location
and dae.date = vac.date
where dae.continent is not null
-- order by 2,3
)
select * ,(rollingpeoplevaccinated/population) * 100
from popvsvac



-- Temp Table
drop table if exists percentpopulationvaccinated
create temporary table percentpopulationvaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population int,
new_vaccinations int,
rollingpeoplevaccinated int
)

insert into percentpopulationvaccinated
Select dae.continent, dae.location, dae.date, dae.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as signed)) 
over (partition by  dae.location order by dae.location, dae.date) as rollingpeoplevaccinated
from covid_deaths as dae
join covid_vaccinations as vac on dae.location = vac.location
and dae.date = vac.date
where dae.continent is not null
-- order by 2,3)

select * ,(rollingpeoplevaccinated/population) * 100
from percentpopulationvaccinated


 -- create view
 
percentpopulationvaccinatedcreate view percentpopulationvaccinated as
Select dae.continent, dae.location, dae.date, dae.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as signed)) 
over (partition by  dae.location order by dae.location, dae.date) as rollingpeoplevaccinated
from covid_deaths as dae
join covid_vaccinations as vac on dae.location = vac.location
and dae.date = vac.date
where dae.continent is not null
-- order by 2,3)


