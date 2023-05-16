show databases;
use portfolio_project;
show tables;
select * from dob1;
select * from dob2;

-- number of rows in our dataset

select * from dob1 where state in ('Jharkhand', 'Bihar');

-- Total population of India

select sum(Population) as India_Population from dob2;

-- average growth in India
select state, avg(Growth)*100 Average_Growth from dob1 
group by state;

-- average sex ratio
select state, round(avg(Sex_Ratio), 2) as average_sex_ratio from dob1 group by state
order by average_sex_ratio desc;

-- average literacy rate
select state, round(avg(Literacy), 2) as average_literacy_rate from dob1 group by state
order by average_literacy_rate desc;

-- states with average literacy rate greater than 90
select state, round(avg(Literacy), 2) as average_literacy_rate from dob1 group by state 
having round(avg(Literacy), 2)>90
order by average_literacy_rate desc;

-- top 3 states showing highest growth percentage

select state, avg(growth)*100 as average_growth_percent from dob1 group by state
order by average_growth_percent desc limit 3;

-- India's sex ratio, bottom 3
select state, avg(Sex_Ratio) as lowest_sex_ratio from dob1 group by state
order by lowest_sex_ratio asc limit 3;

-- top and bottom 3 states in literacy rate

drop table if exists topstates;
create table topstates
(state varchar(250), 
topstate float);

insert into topstates
select state, round(avg(Literacy), 2) as average_literacy_rate from dob1 group by state
order by average_literacy_rate desc;

select * from topstates order by topstate desc limit 3;


drop table if exists bottomstates;
create table bottomstates
(state varchar(250), 
bottomstate float);

insert into bottomstates
select state, round(avg(Literacy), 2) as average_literacy_rate from dob1 group by state
order by average_literacy_rate asc;

select * from bottomstates order by bottomstate asc limit 3;

-- union operator

select * from
(select * from topstates order by topstate desc limit 3) a
union
select * from
(select * from bottomstates order by bottomstate asc limit 3)b;

-- states starting with letter a or b
-- Note: % is used to show that whatever is there in the output we are concerned with just the one with % like one shown below

select distinct(state) from dob2 where lower(state) like 'a%' or lower(state) like 'b%';

-- Joining tables

select dob1.district, dob1.state, dob2.population, sex_ratio from dob1 
inner join dob2 on dob1.district = dob2.district;

-- male and female segregation using population and sex ratio (distict wise)

select a.district, a.state, round(population/(a.sex_ratio+1),0) males,
round((a.population*a.sex_ratio)/(a.sex_ratio +1),0) females from
(select dob1.district, dob1.state, dob2.population, dob1.sex_ratio/1000 sex_ratio from dob1 
inner join dob2 on dob1.district = dob2.district) a; 

-- state wise (total males and females)

select b.state, sum(b.males) total_males, sum(b.females) total_females from
(select a.district, a.state, round(population/(a.sex_ratio+1),0) males,
round((a.population*a.sex_ratio)/(a.sex_ratio +1),0) females from
(select dob1.district, dob1.state, dob2.population, dob1.sex_ratio/1000 sex_ratio from dob1 
inner join dob2 on dob1.district = dob2.district) a) b group by b.state; 

-- total literacy rate

select e.state, sum(literate_people) total_literate, sum(illetrate_people) total_illetrate from
(select d.district, d.state, round(d.literacy_ratio*d.population,0) literate_people, 
round((1-d.literacy_ratio)*d.population,0) illetrate_people from
(select dob1.district, dob1.state, dob2.population, dob1.literacy/100 literacy_ratio from dob1 
inner join dob2 on dob1.district = dob2.district)d)e group by e.state;

-- Population in previous census

select sum(m.previous_census_population) previous_population, 
sum(m.current_census_population) current_population from
(select e.state, sum(e.population_previous_year) previous_census_population, 
sum(e.current_year_population) current_census_population from
(select d.district, d.state, round(d.population/(d.growth+1),0) population_previous_year, 
d.population current_year_population from
(select dob1.district, dob1.state, dob2.population, dob1.growth growth from dob1 
inner join dob2 on dob1.district = dob2.district)d) e
group by e.state) m;

-- top 3 districts in each state with highest literacy rate

select a.* from
(select rank() over(partition by state order by literacy desc) rnk, district, state, literacy 
from dob1) a
where a.rnk in (1,2,3);






