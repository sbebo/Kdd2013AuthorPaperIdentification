select foo.id, foo.name, array_agg(distinct foo.duplos) 
from
(
   select aa.id as id, lower(aa.name) as name, bb.id as duplos
from 
author aa
left outer join
author bb on lower(aa.name) = lower(bb.name)
where 
bb.name != ''
union
(
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
      and
      pa.name != ''
      group by a.id,lower(pa.name)
   )
select b.id as id, lower(b.name) as name, c.id as duplos
from
author b left outer join Synonims s
on b.id = s.id,
author c
where
   lower(c.name) = s.name
)
) as foo
group by foo.id, foo.name

union

select a.id, a.name, array_agg(a.id)
from author a
where a.name = ''
group by a.id,a.name
;
