CREATE TABLE paperkeywords
AS
(
   select paperid, keyword
   from
   (
   select PaperID,
   CASE
   WHEN Trimmed like '%;%'
      THEN regexp_split_to_table(Trimmed,'; ?')
   WHEN Trimmed like '%|%'
      THEN regexp_split_to_table(Trimmed,' ?\| ?')
   WHEN Trimmed like '%·%'
      THEN regexp_split_to_table(Trimmed,' ?· ?')
   WHEN Trimmed like '%•%'
      THEN regexp_split_to_table(Trimmed,' ?• ?')
   WHEN Trimmed like '%.%'
      THEN regexp_split_to_table(Trimmed,'\. ?')
   --WHEN Trimmed = ''
   --   THEN Array[]::text[] 
   ELSE  regexp_split_to_table(Trimmed,', ?')
   END AS keyword
   FROM
-- "additional and phrases" -- authorid=35
   (select id as PaperID, regexp_replace(lower(rtrim(keyword,'.')),'(key.?words?( and phrases)?|index ?(terms?)?) ?[\.|:|\-|(\-\-)|—]? ?','') as trimmed
      FROM paper
   ) AS FOO
   ) as allkey
   where keyword != ''
   group by paperid, keyword
)
;

