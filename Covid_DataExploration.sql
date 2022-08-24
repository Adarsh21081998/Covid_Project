use Covid_project;

select * from CovidD
where continent is not null
order by 3,4;
--select * from CovidVacci
--order by 3,4;
select location,date,total_cases,new_cases,total_deaths,population 
from CovidD
where continent is not null
order by 1,2;


-- Estimating Death Rates from complete data
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Rate
from CovidD
where continent is not null
order by 1,2;

-- Estimating Infection Rate
select location,date,total_cases,population,(total_cases/population)*100 as Infection_Rate
from CovidD
where continent is not null
order by 1,2;

-- Estimating Country's with Highest Infection Rate
select location,population,MAX(total_cases) as Most_Infected,MAX((total_cases/population))*100 as Infection_Rate
from CovidD
where continent is not null
group by location,population
order by population desc

--Estimating Countries with Highest Death Rate per population
select location,MAX(cast(total_deaths as int)) as total_death_count
from CovidD
where continent is not null
group by location
order by total_death_count desc

--Exploring by continent

select location,MAX(cast(total_deaths as int)) as total_death_count
from CovidD
where continent is null
group by location
order by total_death_count desc

-- Estimating continents with Highest death rates
select continent,MAX(cast(total_deaths as int)) as total_death_count
from CovidD
where continent is not null
group by continent
order by total_death_count desc

--Global Numbers
select date,SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as Death_Rates--,population,(total_cases/population)*100 as Infection_Rate
from CovidD
where continent is not null
group by date
order by 1,2;


-- Across the whole World
select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as Death_Rates--,population,(total_cases/population)*100 as Infection_Rate
from CovidD
where continent is not null
order by 1,2;


-- Total Vaccination 
with popvsvac (continent,loaction,date ,population,new_vaccinations,rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated from CovidD dea
join CovidVacci vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

)
select * ,(rolling_people_vaccinated/population)*100 from popvsvac


----temp Table
Drop table if exists #Percent_population_Vaccinated
create table #Percent_population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #Percent_population_Vaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated from CovidD dea
join CovidVacci vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

select * ,(RollingPeopleVaccinated/Population)*100 from #Percent_population_Vaccinated

---createing view for visualization
create View Percent_population_Vaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated from CovidD dea
join CovidVacci vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

