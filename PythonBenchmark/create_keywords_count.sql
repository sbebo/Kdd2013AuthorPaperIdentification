CREATE TABLE KeywordCounts AS
( SELECT PaperID, 
   CASE WHEN array_length(Arrays.Array,1)>0
      THEN array_length(Arrays.Array,1)
   ELSE
      0
   END AS KeywordCount
FROM (
   select PaperID, 
   CASE
   WHEN Trimmed like '%;%'
      THEN regexp_split_to_array(Trimmed,'; ?')
   WHEN Trimmed like '%|%'
      THEN regexp_split_to_array(Trimmed,'\| ?')
   WHEN Trimmed like '%·%'
      THEN regexp_split_to_array(Trimmed,'· ?')
   WHEN Trimmed like '%.%'
      THEN regexp_split_to_array(Trimmed,'\. ?')
   WHEN Trimmed = ''
      THEN Array[]::text[] 
   ELSE  regexp_split_to_array(Trimmed,', ?')
   END AS Array
   FROM
   (select id as PaperID, regexp_replace(lower(rtrim(keyword,'.')),'(key.?words?|index ?(terms?)?) ?[\.|:|\-|(\-\-)|—]? ?','') as Trimmed
      FROM paper
   ) AS FOO
   )
AS Arrays
);

