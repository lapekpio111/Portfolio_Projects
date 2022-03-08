Select *
from portfolio_project..Covid_deaths
order by 3,4

Select *
from portfolio_project..Covid_vaccinations
order by 3,4

--Selecting data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..Covid_deaths
order by 1, 2

--Total_cases vs Total_deaths

Select location, date, total_cases, total_deaths, total_deaths/total_cases*100 death_percentage
from portfolio_project..Covid_deaths
where location = 'Poland'
order by 1, 2

--Total cases vs population

Select location, date, total_cases, population, total_cases/population*100 cases_percentage
from portfolio_project..Covid_deaths
where location = 'Poland'
order by 1, 2

--Looking at county with highest infection rate compared to population

Select location, max(total_cases) highest_number_of_cases, population, max(total_cases/population*100) cases_percentage
from portfolio_project..Covid_deaths
group by location, population
order by 4 desc

--Countries with highest number of deaths

Select location, max(cast(total_deaths as int))
from portfolio_project..Covid_deaths
where continent <> ''
group by location
order by 2 desc


--Countries with highest death count per population

Select location, max(cast(total_deaths as int)) highest_number_of_deaths, population, max(total_deaths/population*100) deaths_percentage
from portfolio_project..Covid_deaths
group by location, population
order by 4 desc

--CONTINENTS
--Continents with highest number of deaths
Select location, max(cast(total_deaths as int)) number_of_deaths
from portfolio_project..Covid_deaths
where continent = ''
group by location
order by 2 desc


Select continent, max(cast(total_deaths as int)) total_deaths
from portfolio_project..Covid_deaths
where continent <> ''
group by continent
order by 2 desc


-- GLOBAL


Select date, sum(new_cases) cases, sum(cast(new_deaths as int)) deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 death_percentage
from portfolio_project..Covid_deaths
where continent <> ''
group by date
order by 1, 2

Select sum(new_cases) cases, sum(cast(new_deaths as int)) deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 death_percentage
from portfolio_project..Covid_deaths
where continent <> ''
order by 1, 2

--Joining tables

Select *
from portfolio_project..Covid_deaths d
join portfolio_project..Covid_vaccinations v
on d.location = v.location and d.date = v.date

--Looking at total popuation vs vaccination

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date) as vaccinated_ppl
from portfolio_project..Covid_deaths d
join portfolio_project..Covid_vaccinations v
on d.location = v.location and d.date = v.date
where d.continent <> ''
order by 2, 3


Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date) as vaccinated_ppl,
(sum(convert(bigint, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date))/d.population*100
from portfolio_project..Covid_deaths d
join portfolio_project..Covid_vaccinations v
on d.location = v.location and d.date = v.date
where d.continent <> ''
order by 2, 3

--CTE


With pop_vs_vac (continent, location, date, population, new_vaccinations, vaccinated_ppl)
as(

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date) as vaccinated_ppl
from portfolio_project..Covid_deaths d
join portfolio_project..Covid_vaccinations v
on d.location = v.location and d.date = v.date
where d.continent <> ''
)
select *, vaccinated_ppl/population*100 as vaccinated_percentage
from pop_vs_vac
order by 2, 3


--TEMP TABLE

Drop table if exists #Vaccinated_percentage
Create table #Vaccinated_percentage
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
vaccinated_ppl numeric)

Insert into #Vaccinated_percentage
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (Partition by d.location order by d.location, d.date) as vaccinated_ppl
from portfolio_project..Covid_deaths d
join portfolio_project..Covid_vaccinations v
on d.location = v.location and d.date = v.date
where d.continent <> ''

select *, vaccinated_ppl/population*100
from #Vaccinated_percentage



--Creating view to store data for visualizations in Tableau
Drop view if exists Vaccinated_percentage

Create view Vaccinated_percentage as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (Partition by d.location order by d.location, d.date) as vaccinated_ppl
from portfolio_project..Covid_deaths d
join portfolio_project..Covid_vaccinations v
on d.location = v.location and d.date = v.date
where d.continent <> ''

select * 
from Vaccinated_percentage

Create view ContinentDeaths as
Select continent, max(cast(total_deaths as int)) total_deaths
from portfolio_project..Covid_deaths
where continent <> ''
group by continent

select *
from ContinentDeaths

Create view CountryDeaths as
Select date, sum(new_cases) cases, sum(cast(new_deaths as int)) deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 death_percentage
from portfolio_project..Covid_deaths
where continent <> ''
group by date

Select *
from CountryDeaths

Create view cases_deaths_Poland as
Select location, date, total_cases, total_deaths, total_deaths/total_cases*100 death_percentage
from portfolio_project..Covid_deaths
where location = 'Poland'

select *
from cases_deaths_Poland
