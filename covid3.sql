select *
from CovidVaccinations
go

--Creating View to Store Data for later visualization
create view aa as
select dea.continent, dea.location, dea.date, dea.population, 
       vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over 
	   (partition by dea.location order by dea.date, dea.location) 
	   as RollingVaccinationPerPopulation
from CovidVaccinations as vac
join CovidDeaths as dea
    on dea.date=vac.date
	and dea.location= vac.location
where dea.continent is not null
order by 2,3;
go


-- use cte
with PercentPopulationVaccinated (continent, location, 
     date, population, new_vaccinations, RollingVaccinationPerPopulation)
as
(
select dea.continent, dea.location, dea.date, dea.population, 
       vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over 
	   (partition by dea.location order by dea.date, dea.location) 
	   as RollingVaccinationPerPopulation
from CovidVaccinations as vac
join CovidDeaths as dea
    on dea.date=vac.date
	and dea.location= vac.location
where dea.continent is not null
--order by 2,3;
)
select *, (RollingVaccinationPerPopulation/population)*100 as PercentPopVac
from PercentPopulationVaccinated
;
go

--use Subquery
select *, (sub1.RollingVaccinationPerPopulation/sub1.population)*100 as PercentPopVac
from 
	(select dea.continent, dea.location, dea.date, dea.population, 
		   vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over 
		   (partition by dea.location order by dea.date, dea.location) 
		   as RollingVaccinationPerPopulation
	from CovidVaccinations as vac
	join CovidDeaths as dea
		on dea.date=vac.date
		and dea.location= vac.location
	where dea.continent is not null
	--order by 2,3;
	) sub1
