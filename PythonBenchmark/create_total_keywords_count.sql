CREATE TABLE TotalKeywordCounts AS
( SELECT AuthorID, 
         SUM(KeywordCount) AS TotalKeywordCount,
         AVG(KeywordCount) AS AvgKeywordCount
   FROM PaperAuthor pa, KeywordCounts kc
   WHERE pa.PaperID = kc.PaperID
   GROUP BY AuthorId
);

