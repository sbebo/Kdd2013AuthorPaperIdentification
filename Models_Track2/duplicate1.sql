select a.id, lower(a.name), array_agg(distinct b.id) as duplos
from 
author a
left outer join
author b on lower(a.name) = lower(b.name)
where 
b.name != ''
group by a.id,lower(a.name)
union
select a.id, a.name, array_agg(a.id)
from author a
where a.name = ''
group by a.id,a.name
;
