select * from covidDatabase..covidDeaths;

-- Selecting data to use

select location, date, total_cases, new_cases, total_deaths, population
from covidDatabase..covidDeaths order by 1,2;


-- Comparing the total deaths vs total cases in canada
-- death percentage shows the percentage of people died after catching the virus
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from covidDatabase..covidDeaths
where location like '%canada%'
order by 1,2;

-- Shows when the death percentage was heighest
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from covidDatabase..covidDeaths
where location like '%canada%'
order by 5 desc;


-- Shows % of people of peple that got covid in canada
select location, date, population,total_cases,(total_cases/population)*100 as InfectedPercent
from covidDatabase..covidDeaths
where location like '%canada%'
order by 1,2;

-- Checking the countries with Highest infection rate
select location, population, max(total_cases)as MaximumCases, max(total_cases/population)*100 as InfectedPercent
from covidDatabase..covidDeaths
group by location, population
order by 4 desc;

-- Showing the countries with highest number of deaths
select location, population, max(cast(total_deaths as int))as DeathCount
from covidDatabase..covidDeaths
where continent is not null
group by location, population
order by DeathCount desc;

-- Showing highest deaths by continents
select continent,max(cast(total_deaths as int))as DeathCount
from covidDatabase..covidDeaths
where continent is not null
group by continent
order by DeathCount desc;

-- Breaking down data Globally
-- Showing total cases each day
select date, sum(cast(new_cases as int))as TotalCases
from covidDatabase..covidDeaths
where continent is not null
group by date
order by TotalCases desc;

-- Showing total deaths and death percentage each day
select date, sum(cast(new_deaths as int))as DeathCount, 
sum(cast(new_deaths as int))/sum((new_cases))*100 as DeathPercentage 
from covidDatabase..covidDeaths
where continent is not null
group by date
order by DeathCount desc;

-- Table for vaccinations
select * from covidDatabase..covidVaccines;

-- joining both tables
select * from covidDatabase..covidDeaths deaths
join covidDatabase..covidVaccines vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null
order by 2,3;

-- Comparing population vs total vaccinations
select deaths.continent,deaths.location,deaths.date, deaths.population, vax.new_vaccinations from covidDatabase..covidDeaths deaths
join covidDatabase..covidVaccines vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null
order by 1,2,3;

-- in canada
select deaths.continent,deaths.location,deaths.date, deaths.population, vax.new_vaccinations from covidDatabase..covidDeaths deaths
join covidDatabase..covidVaccines vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null
	and deaths.location like '%Canada%'
order by 1,2,3;

-- Calculation the number of total vaccines on a daily basis in canada

select deaths.continent,deaths.location,deaths.date, deaths.population, vax.new_vaccinations, 
sum(cast(vax.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.location,deaths.date) as RollinTotalVaccinated
from covidDatabase..covidDeaths deaths
join covidDatabase..covidVaccines vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null
	and deaths.location like '%Canada%'
order by 1,2,3;

-- calculating the same in a diifernt way
select deaths.location,deaths.date, deaths.population, vax.new_vaccinations, 
max(convert(bigint,vax.total_vaccinations))as RollinTotalVaccinated
from covidDatabase..covidDeaths deaths
join covidDatabase..covidVaccines vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null
	and deaths.location like '%Canada%'
group by deaths.location,deaths.date, deaths.population, vax.new_vaccinations
order by 1,2,3;



-- Creating CTE
with popVsVax (Continent, Location,  Date, Population, newVaccination, RollingTotalVaccinated)
as(

select deaths.continent,deaths.location,deaths.date, deaths.population, vax.new_vaccinations, 
sum(cast(vax.new_vaccinations as bigint)) over 
(partition by deaths.location order by deaths.location,deaths.date) as RollingTotalVaccinated
from covidDatabase..covidDeaths deaths
join covidDatabase..covidVaccines vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null
--and deaths.location like '%Canada%'
)
select * from popVsVax;

-- calulate % the total number of people vaccinated in evry continent 
drop table  if exists #PercentVaccinated;

Create table #PercentVaccinated(
Continent varchar(255),
Location varchar(255),
date datetime,
Population numeric,
new_vacciantions numeric,
TotalVaccinations numeric
)

insert into #PercentVaccinated

select deaths.continent,deaths.location,deaths.date, deaths.population, vax.new_vaccinations, 
sum(cast(vax.new_vaccinations as bigint)) over 
(partition by deaths.location order by deaths.location,deaths.date) as RollingTotalVaccinated
from covidDatabase..covidDeaths deaths
join covidDatabase..covidVaccines vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null

Select * , (TotalVaccinations/population) * 100 as percentageVaccinated
from #PercentVaccinated
order by 1,2,3
;

--Creating a view
create View percentPopulationVaccinated as 
select deaths.continent,deaths.location,deaths.date, deaths.population, vax.new_vaccinations, 
sum(cast(vax.new_vaccinations as bigint)) over 
(partition by deaths.location order by deaths.location,deaths.date) as RollingTotalVaccinated
from covidDatabase..covidDeaths deaths
join covidDatabase..covidVaccines vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null


