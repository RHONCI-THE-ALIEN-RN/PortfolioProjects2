

--   Covid 19 Data Exploration project 07-15-23
--  Skills used: Database and table creation, Joins, CTE's, Temp Tables, Windows Functions, 
--Aggregate Functions, Creating Views, Converting Data Types


--- examining the data for the project

Select *
From ProjectPortfolio..CovidDeaths
order by 1,2

Select *
From ProjectPortfolio..CovidVaccinations
order by 1,2

-- just some joins

Select *
From ProjectPortfolio.dbo.CovidDeaths as CD
Inner Join ProjectPortfolio.dbo.CovidVaccinations as CV
	ON CD.continent = CV.continent

Select CD.continent, CV.total_vaccinations, cv.aged_65_older
From ProjectPortfolio.dbo.CovidDeaths as CD
Left Join ProjectPortfolio.dbo.CovidVaccinations as CV
	ON CD.continent = CV.continent
Where cv.total_vaccinations is not null
Order By CD.continent desc

--- some data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio.dbo.CovidDeaths
Where continent is not null 
order by 1,2

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%aru%'
and continent is not null
order by 1,2


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where location like '%states%'
Group by continent
order by TotalDeathCount desc

-- Contintents with the highest Covid death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



Select date, SUM(new_cases) as GlobalTotal_cases, SUM(cast(new_deaths as int)) as GlobalTotal_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobalDeathPercentage
From ProjectPortfolio..CovidDeaths
where continent is not null 
Group By date


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%states%'
order by 1,2


---  Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, SomePeopleVaccinated)
as
(
Select CovidD.continent, CovidD.location, CovidD.date, CovidD.population, CovidVAC.new_vaccinations
, SUM(CONVERT(int,CovidVAC.new_vaccinations)) OVER (Partition by CovidD.Location Order by CovidD.location, CovidD.Date) as SomePeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio.dbo.CovidDeaths CovidD
Join ProjectPortfolio.dbo.CovidVaccinations CovidVAC
	On CovidD.location = CovidVAC.location
	and CovidD.date = CovidVAC.date
where CovidD.continent is not null 
)
Select *, (SomePeopleVaccinated/Population)*100
From PopvsVac



--- The below Temp Table is used to perform a Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select CovidD.continent, CovidD.location, CovidD.date, CovidD.population, CovidVAC.new_vaccinations
, SUM(CONVERT(int,CovidVAC.new_vaccinations)) OVER (Partition by CovidD.Location Order by CovidD.location, CovidD.Date) as RollingPeopleVaccinated
From ProjectPortfolio.dbo.CovidDeaths CovidD
Join ProjectPortfolio.dbo.CovidVaccinations CovidVAC
	On CovidD.location = CovidVAC.location
	and CovidD.date = CovidVAC.date
where CovidD.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--  To be used as a View to store data for later visualizations 


Create View PercentPopulationVaccinated as
Select CovidD.continent, CovidD.location, CovidD.date, CovidD.population, CovidVAC.new_vaccinations
, SUM(CONVERT(int,CovidVAC.new_vaccinations)) OVER (Partition by CovidD.Location Order by CovidD.location, CovidD.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio.dbo.CovidDeaths CovidD
Join ProjectPortfolio.dbo.CovidVaccinations CovidVAC
	On CovidD.location = CovidVAC.location
	and CovidD.date = CovidVAC.date
where CovidD.continent is not null


--NEW View
Select * 
FROM PercentPopulationVaccinated