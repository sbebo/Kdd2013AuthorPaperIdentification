drop table authortitles;
CREATE TABLE AuthorTitles AS
( SELECT AuthorID,pt.word, 
         COUNT(*) AS WordCount
   FROM PaperAuthor pa, papertitles pt 
   WHERE pa.PaperID = pt.PaperID
   GROUP BY AuthorId, pt.word
);

