
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_Percentage
From CovidDeaths
Where location like 'India'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as Percent_Population_Infected
From CovidDeaths
--Where location like 'India'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
From CovidDeaths
--Where location like 'India'
Group by Location, Population
order by Percent_Population_Infected desc


-- Countries with Highest death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as Total_death_Count
From CovidDeaths
--Where location like 'India'
Where continent is not null 
Group by Location
order by Total_death_Count desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as Total_death_Count
From CovidDeaths
--Where location like 'India'
Where continent is not null 
Group by continent
order by Total_death_Count desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_Percentage
From CovidDeaths
--Where location like 'India'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs vacinations
-- Shows Percentage of Population that has recieved at least one Covid vaccine

Select de.continent, de.location, de.date, de.population, va.new_vacinations
, SUM(CONVERT(int,va.new_vacinations)) OVER (Partition by de.Location Order by de.location, de.Date) as Rolling_People_vaccinated
--, (Rolling_People_vaccinated/population)*100
From CovidDeaths de
Join Covidvaccinations va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With Pop_vs_va (Continent, Location, Date, Population, New_vacinations, Rolling_People_vaccinated)
as
(
Select de.continent, de.location, de.date, de.population, va.new_vacinations
, SUM(CONVERT(int,va.new_vacinations)) OVER (Partition by de.Location Order by de.location, de.Date) as Rolling_People_vaccinated
--, (Rolling_People_vaccinated/population)*100
From CovidDeaths de
Join Covidvaccinations va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 
--order by 2,3
)
Select *, (Rolling_People_vaccinated/Population)*100
From Pop_vs_va



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists Percent_Population_vaccinated
Create Table Percent_Population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacinations numeric,
Rolling_People_vaccinated numeric
)

Insert into Percent_Population_vaccinated
Select de.continent, de.location, de.date, de.population, va.new_vacinations
, SUM(CONVERT(int,va.new_vacinations)) OVER (Partition by de.Location Order by de.location, de.Date) as Rolling_People_vaccinated
--, (Rolling_People_vaccinated/population)*100
From CovidDeaths de
Join Covidvaccinations va
	On de.location = va.location
	and de.date = va.date
--where de.continent is not null 
--order by 2,3

Select *, (Rolling_People_vaccinated/Population)*100
From Percent_Population_vaccinated




-- Creating View to store data for later visualizations

Create View Percent_Population_vaccinated as
Select de.continent, de.location, de.date, de.population, va.new_vacinations
, SUM(CONVERT(int,va.new_vacinations)) OVER (Partition by de.Location Order by de.location, de.Date) as Rolling_People_vaccinated
--, (Rolling_People_vaccinated/population)*100
From CovidDeaths de
Join Covidvaccinations va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 

Select *
From Percent_Population_vaccinated

