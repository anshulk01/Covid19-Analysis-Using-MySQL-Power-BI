-- importing data
-- first  creating tables
use project1;
create table covid_cases (iso_code varchar(30), continent varchar(30) default 'null', location varchar (30), 
population int, date_ date, total_cases int , new_cases int);
create table covid_deaths (iso_code varchar(30), date_ date, total_deaths int, new_deaths int);
create table covid_tests (iso_code varchar(30), date_ date, total_vaccinations int, new_vaccinations int, people_vaccinated int,
people_fully_vaccinated int ,total_boosters int);

-- then
-- used cmd for importing data faster

-- 1 showing countries with highest cases ;

select location,
		max(total_cases) from covid_cases
	where continent is not null
	group by  location
	order by 2 desc;



-- 2  showing countries with highest deaths;

select covid_cases.iso_code,
		covid_cases.location , 
        max(covid_deaths.total_deaths) from covid_cases
	left join covid_deaths
	on covid_cases.iso_code= covid_deaths.iso_code and covid_cases.date_=covid_deaths.date_
	where continent is not null
	group by covid_cases.location
	order by 3 desc;



-- 3 .highest death on a single day in each country

select 	a.location,
		b.date_,
		c.max_deaths 
from covid_cases as a
join 
	(select iso_code, date_,  new_deaths 
	from covid_deaths) as b
	on a.iso_code=b.iso_code and a.date_= b.date_
inner join 
	(select iso_code,max(new_deaths) as max_deaths from covid_deaths 
	group by iso_code) as c
	on b.iso_code = c.iso_code
	and b.new_deaths= c.max_deaths
	where a.continent is not null
	order by max_deaths desc;



-- 4. top 10 countries with highest percentage of population vaccinated;


select a.iso_code,
		a.location,
		max(people_fully_vaccinated) as total_vaccinated,
		(max(people_fully_vaccinated))/(a.population)*100 as per_of_popu_vaccinated from covid_tests as b 
	inner join covid_cases as a
	on a.iso_code = b.iso_code and a.date_ = b.date_
	where continent is not null
group by iso_code
order by 3 desc
limit 10;


-- 5. death rate of big 4 countries date wise;


select a.location,
		a.date_,
		a.total_cases,
        b.total_deaths,
        (b.total_deaths/a.total_cases)*100 as death_percentage
from covid_cases as a 
	left join covid_deaths as b
	on a.iso_code=b.iso_code and a.date_=b.date_
	where a.iso_code in('ind','usa','chn','bra');


-- 6.peak rate ie new_cases/population of countries;

select location,population, 
		max(new_cases), 
		max(new_cases/population)*100 as peak_rate from covid_cases
	group by location
	order by 4 desc;


-- 7. % contribution of each country in total cases 

select location,
	(max(total_cases)/c)*100 as rate from covid_cases
	cross join (select max(total_cases) as c from covid_cases ) as b
	where continent is not null
	group by location 
	order by  2 desc
;
-- 8. percentage contribution of each country deaths worldwide

select distinct covid_deaths.iso_code,g.location,
		max(total_deaths) over (partition by iso_code) as total_deaths, 
		wrlddeaths,
		(max(total_deaths) over (partition by iso_code)/wrlddeaths)*100 as percent_contribution
  from covid_deaths
	join (select max(total_deaths) as wrlddeaths from covid_deaths) as percent_contribution 
	inner join covid_cases as g
	on covid_deaths.iso_code = g.iso_code
	and covid_deaths.date_= g.date_;  
 

