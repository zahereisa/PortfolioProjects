select *
	from PortfolioProject..CovidDeaths$
	order by 3,4

--	Select *
--	from PortfolioProject..CovidVaccinations$

select location, date, total_cases,new_cases,total_deaths, population
	from PortfolioProject..CovidDeaths$
	order by 1,2

	--Looking at Total Cases vs Total Deaths
	--shows likelihood of dying if you contract covid in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	from PortfolioProject..CovidDeaths$
	where location like '%states%'
	order by 1,2

	--Looking at Total Cases vs Population
	--shows what percentage of population got covid
select location, date, total_cases,population, (total_cases/population)*100 as InfectionRate
	from PortfolioProject..CovidDeaths$
	where location like '%states%'
	order by 1,2


--Looking at countries with highest infection rate compared to population
select location,  MAX(total_cases),population as HighestInfectionCount, MAX((total_cases/population))*100 as 
	InfectionRate
	from PortfolioProject..CovidDeaths$
	--where location like '%states%'
	group by Location, Population
	order by InfectionRate desc

--Showing countries with Highest Death Count per Population
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeaths$
	where continent is not null
	group by Location
	order by TotalDeathCount desc 

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeaths$
	where continent is null
	group by Location
	order by TotalDeathCount desc

--Global Numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast
	(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
	from PortfolioProject..CovidDeaths$
	where continent is not null 
	order by 1,2

	--Looking at Rate of Testing
select location, date, total_tests,population, (total_tests/population)*100 as testrate
	from PortfolioProject..CovidDeaths$
where location like '%States%' and total_tests is not null
--group by date
order by testrate

	--Looking at Hospitalization Rate
select  location,date,  weekly_hosp_admissions_per_million, (weekly_hosp_admissions_per_million/population)*100 as hosprate
	from PortfolioProject..CovidDeaths$
where weekly_hosp_admissions_per_million is not null and location like '%States%'
--group by location
order by date, hosprate 

--Exploring CovidVaccinations table and joinning it with coviddeaths table

Select * 
	From PortfolioProject..CovidDeaths$ cdeaths
	Join PortfolioProject..CovidVaccinations$ cvacs
	On cdeaths.location=cvacs.location
	and cdeaths.date=cvacs.date

	--looking at Total Population vs Vaccinations
Select cdeaths.continent, cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations
	--adding rolling count
	,SUM(CONVERT(int,cvacs.new_vaccinations ))over(partition by cdeaths.location order by cdeaths.location,
	cdeaths.date) as RollingDailyVaccinations
	From PortfolioProject..CovidDeaths$ cdeaths
	Join PortfolioProject..CovidVaccinations$ cvacs
	On cdeaths.location=cvacs.location
	and cdeaths.date=cvacs.date
where cdeaths.continent is not null and cvacs.new_vaccinations is not null
order by 2,3
	
--USE CTE

with PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingDailyVaccinations)
as 
(
Select cdeaths.continent, cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations
	--adding rolling count
	,SUM(CONVERT(int,cvacs.new_vaccinations ))over(partition by cdeaths.location order by cdeaths.location,
	cdeaths.date) as RollingDailyVaccinations
	From PortfolioProject..CovidDeaths$ cdeaths
	Join PortfolioProject..CovidVaccinations$ cvacs
	On cdeaths.location=cvacs.location
	and cdeaths.date=cvacs.date
where cdeaths.continent is not null and cvacs.new_vaccinations is not null
--order by 2,3
)		--CTE used to perform calculations on new rollingcount columns to look at daily vaccinations percentage
	Select * ,(RollingDailyVaccinations/Population)*100
		from PopvsVac

--Using TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingDailyVaccinations numeric, 
)


Insert into #PercentPopulationVaccinated
Select cdeaths.continent, cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations
	--adding rolling count
	,SUM(CONVERT(int,cvacs.new_vaccinations ))over(partition by cdeaths.location order by cdeaths.location,
	cdeaths.date) as RollingDailyVaccinations
	From PortfolioProject..CovidDeaths$ cdeaths
	Join PortfolioProject..CovidVaccinations$ cvacs
	On cdeaths.location=cvacs.location
	and cdeaths.date=cvacs.date
where cdeaths.continent is not null and cvacs.new_vaccinations is not null
--order by 2,3
Select * ,(RollingDailyVaccinations/Population)*100
		from #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select cdeaths.continent, cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations
	--adding rolling count
	,SUM(CONVERT(int,cvacs.new_vaccinations ))over(partition by cdeaths.location order by cdeaths.location,
	cdeaths.date) as RollingDailyVaccinations
	From PortfolioProject..CovidDeaths$ cdeaths
	Join PortfolioProject..CovidVaccinations$ cvacs
	On cdeaths.location=cvacs.location
	and cdeaths.date=cvacs.date
where cdeaths.continent is not null and cvacs.new_vaccinations is not null
--order by 2,3

Select *

From PercentPopulationVaccinated