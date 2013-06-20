drop table papertitles;
CREATE TABLE papertitles
AS
(
   select paperid, word
   from
   (
   select PaperID,
   regexp_split_to_table(lowered,' ') as word
   FROM
   (select id as PaperID, regexp_replace(lower(title), '[]|\[|:|\.|,|\(|\)|\?|’|”|“|‘|`|\"|\r]','','g') as lowered
      FROM paper
   ) AS FOO
   ) as allkey
   where char_length(word) > 1
   and word != 'and'
   and word != 'or'
   and word != 'a'
   and word != 'an'
   and word != 'the'
   and word != 'or'
   and word != 'in'
   and word != 'on'
   and word != 'by'
   and word != 'of'
   and word != 'from'
   and word != 'for'
   and word != 'to'
   and word != 'with'
   and word != 'at'
   group by paperid, word
)
;

