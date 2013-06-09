/*select a.name, b.name, a.id, b.id
from author a, author b
where a.id > b.id
and a.name = b.name
and a.name != '';
*/

/*select lower(name), array_agg(id), array_agg(name)
from author
group by lower(name)
having lower(name) != '';
*/
/*
select avg(array_length(dupl.duplos,1))
from
(
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
) as dupl
;
*/

WITH Synonims AS
(
   select a.id, lower(pa.name) as name
      from 
      paperauthor pa,
      author a
      where
      pa.authorid = a.id
      and
      pa.name != a.name
      group by a.id,lower(pa.name)
   )
select b.id, lower(b.name), array_agg(distinct c.id) as duplos
from
author b left outer join Synonims s
on b.id = s.id,
author c
where
   lower(c.name) = s.name
group by b.id,lower(b.name)
;

/*
select a.id, array_agg(distinct lower(pa.name))
   from 
      paperauthor pa,
      author a
   where
      pa.authorid = a.id
   and
      pa.name != a.name
   group by a.id;
*/
