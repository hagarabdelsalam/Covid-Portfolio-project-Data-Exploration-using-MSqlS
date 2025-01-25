-----------------------------------------------------------------------Our First DataBase [CovidDeaths]------------------------------------------------------------------------  ----------
select location ,date,total_cases,new_cases,total_deaths,population
from SqlDataExploration..CovidDeaths
order by 1,2

--(1)Looking at Total_Cases VS Total_Deaths
--shows likelihood of dying if you contract covid in your Country
select location ,date,(total_deaths/total_cases)*100 as Death_Percentage
from SqlDataExploration..CovidDeaths
where location = 'Egypt' and continent is not null
order by 1,2

--(2)Looking at Total_Cases VS Population
--show percentage of population got covid 
select location ,date,population,total_cases,(total_cases/population)*100 as Percentage_population_Infectd
from SqlDataExploration..CovidDeaths
where continent is not null
order by 1,2


--(3)Looking at countries with highest Infection Rate compared to Population 
select location ,max(total_cases) as Heighest_Infection_Count,max((total_cases)/population)*100 as Percentage_population_Infectd
from SqlDataExploration..CovidDeaths
where continent is not null
group by location
order by 1,2

--(4)Showing continent with Hieghest Death Count per Population 
select location ,max(cast(total_deaths as int)) as TotalDeathsCount
from SqlDataExploration..CovidDeaths
where continent is null
group by location
order by TotalDeathsCount Desc

--Global Numbers 

select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
from SqlDataExploration..CovidDeaths
where continent is not null

-------------------------------------------------------------Our Seconed DataBase [CovidVaccinations]---------------------------------------------------------------------------------

--Looking at TOTAL population vs Vaccination
select death.continent,death.location,death.date,death.population,vacci.new_vaccinations
,sum(convert(int,vacci.new_Vaccinations )) over(partition by death.location order by death.location,death.date )
from SqlDataExploration.dbo.CovidVaccinations as vacci
join SqlDataExploration.dbo.CovidDeaths as death
on vacci.location=death.location and vacci.date=death.date
where death.continent is not null
order by 2,3

--use CTE
with popVsvaccination( continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(select death.continent,death.location,death.date,death.population,vacci.new_vaccinations
,sum(convert(int,vacci.new_Vaccinations )) over(partition by death.location order by death.location,death.date ) 
as RollingPeopleVaccinated
from SqlDataExploration.dbo.CovidVaccinations as vacci
join SqlDataExploration.dbo.CovidDeaths as death
on vacci.location=death.location and vacci.date=death.date
where death.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from popVsvaccination

--Temp Table 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime ,
population numeric ,
new_vaccination numeric ,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select death.continent,death.location,death.date,death.population,vacci.new_vaccinations
,sum(convert(int,vacci.new_Vaccinations )) over(partition by death.location order by death.location,death.date ) 
as RollingPeopleVaccinated
from SqlDataExploration.dbo.CovidVaccinations as vacci
join SqlDataExploration.dbo.CovidDeaths as death
on vacci.location=death.location and vacci.date=death.date
--where death.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Create View to store data for later visualization
create View
PercentPopulationVaccinated as
select death.continent,death.location,death.date,death.population,vacci.new_vaccinations
,sum(convert(int,vacci.new_Vaccinations )) over(partition by death.location order by death.location,death.date ) 
as RollingPeopleVaccinated
from SqlDataExploration.dbo.CovidVaccinations as vacci
join SqlDataExploration.dbo.CovidDeaths as death
on vacci.location=death.location and vacci.date=death.date
where death.continent is not null
--order by 2,3 -->The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.

select * from PercentPopulationVaccinated
