drop table DeletedValidFeaturesTer;
CREATE TABLE DeletedValidFeaturesTer AS
(
WITH 
AuthorPaperCounts AS (
    SELECT AuthorId, Count(*) AS Count
    FROM PaperAuthor
    GROUP BY AuthorId),
PaperAuthorCounts AS (
    SELECT PaperId, Count(*) AS Count
    FROM PaperAuthor
    GROUP BY PaperId),
PairCount AS (
   SELECT paperid, authorid, count(*) as count
   from paperauthor
   group by paperid, authorid
),
NegativeId AS (
   SELECT id as paperid,1 as indicator
   from paper
   where journalid<0
   group by id
   union
   SELECT id as paperid,1 as indicator
   from paper
   where conferenceid<0
   group by id
),
SumPapersWithCoAuthors AS (
    WITH CoAuthors AS (
        SELECT pa1.AuthorId Author1, 
               pa2.AuthorId Author2, 
               COUNT(*) AS NumPapersTogether
        FROM PaperAuthor pa1,
             PaperAuthor pa2
        WHERE pa1.PaperId=pa2.PaperId
          AND pa1.AuthorId != pa2.AuthorId
          AND pa1.AuthorId IN (
              SELECT DISTINCT AuthorId
              FROM ValidDeleted)
        GROUP BY pa1.AuthorId, pa2.AuthorId)
    SELECT t.AuthorId,
           t.PaperId, 
           SUM(NumPapersTogether) AS Sum,
           AVG(NumPapersTogether) as Avg 
    FROM ValidDeleted t
    LEFT OUTER JOIN PaperAuthor pa ON t.PaperId=pa.PaperId
    LEFT OUTER JOIN CoAuthors ca ON ca.Author2=pa.AuthorId
    WHERE pa.AuthorId != t.AuthorId
      AND ca.Author1 = t.AuthorId
    GROUP BY t.AuthorId, t.PaperId
),
CoauthorJournalCounts AS (
   WITH CoAuthors AS (
        SELECT pa1.AuthorId Author1, 
               pa2.AuthorId Author2, 
               COUNT(*) AS NumPapersTogether
        FROM PaperAuthor pa1,
             PaperAuthor pa2
        WHERE pa1.PaperId=pa2.PaperId
          AND pa1.AuthorId != pa2.AuthorId
          AND pa1.AuthorId IN (
              SELECT DISTINCT AuthorId
              FROM ValidDeleted)
        GROUP BY pa1.AuthorId, pa2.AuthorId)
   SELECT t.AuthorId,
            t.PaperId,
            SUM(ajc.Count) AS Count,
            AVG(ajc.Count) AS AvgCount
   FROM ValidDeleted t
   LEFT OUTER JOIN Paper p ON t.PaperId = p.Id
   LEFT OUTER JOIN PaperAuthor pa ON t.PaperID=pa.PaperID
   LEFT OUTER JOIN CoAuthors ca ON ca.Author2=pa.AuthorId
   LEFT OUTER JOIN AuthorJournalCounts ajc
      ON ajc.AuthorId = ca.Author2
      AND ajc.JournalId = p.JournalID
   WHERE pa.AuthorId != t.AuthorId
      AND ca.Author1 = t.AuthorId
      AND ajc.JournalId !=0  
   GROUP BY t.AuthorId, t.PaperId
),
CoauthorConferenceCounts AS (
   WITH CoAuthors AS (
        SELECT pa1.AuthorId Author1, 
               pa2.AuthorId Author2, 
               COUNT(*) AS NumPapersTogether
        FROM PaperAuthor pa1,
             PaperAuthor pa2
        WHERE pa1.PaperId=pa2.PaperId
          AND pa1.AuthorId != pa2.AuthorId
          AND pa1.AuthorId IN (
              SELECT DISTINCT AuthorId
              FROM ValidDeleted)
        GROUP BY pa1.AuthorId, pa2.AuthorId)
   SELECT t.AuthorId,
            t.PaperId,
            SUM(acc.Count) AS Count,
            AVG(acc.Count) AS AvgCount
   FROM ValidDeleted t
   LEFT OUTER JOIN Paper p ON t.PaperId = p.Id
   LEFT OUTER JOIN PaperAuthor pa ON t.PaperID=pa.PaperID
   LEFT OUTER JOIN CoAuthors ca ON ca.Author2=pa.AuthorId
   LEFT OUTER JOIN AuthorConferenceCounts acc
      ON acc.AuthorId = ca.Author2
      AND acc.ConferenceId = p.ConferenceID
   WHERE pa.AuthorId != t.AuthorId
      AND ca.Author1 = t.AuthorId
      AND acc.ConferenceId != 0 
   GROUP BY t.AuthorId, t.PaperId
),
CommonKeywords AS (
-- Keywords in common with the other papers by same author
select   pk.paperid, 
         ak.authorid, 
         sum(ak.count-1) as common_keywords -- do not count themselves
from  authorkeywords ak,
      paperkeywords pk,
      ValidDeleted t
where
   t.paperid = pk.paperid
   and
   t.authorid = ak.authorid
   and
   ak.keyword = pk.keyword
   and exists (
      select null
      from paperauthor pp
      where pp.paperid = pk.paperid
      and pp.authorid = ak.authorid   
   )
group by
   pk.paperid, ak.authorid
),
CommonTitleWords AS (
select   pk.paperid, 
         ak.authorid, 
         sum(ak.wordcount-1) as common_titlewords -- do not count themselves
from  authortitles ak,
      papertitles pk,
      ValidDeleted t
where
   t.paperid = pk.paperid
   and
   t.authorid = ak.authorid
   and
   ak.word = pk.word
   and exists (
      select null
      from paperauthor pp
      where pp.paperid = pk.paperid
      and pp.authorid = ak.authorid   
   )
group by
   pk.paperid, ak.authorid
)
SELECT t.AuthorId,
       t.PaperId,
       case when ajc.Count > 0 then ajc.Count
       else 0
      end
       As NumSameJournal, 
       case when acc.Count > 0 then acc.Count
      else 0
      end
       AS NumSameConference,
       apc.Count AS NumPapersWithAuthor,
       pac.Count AS NumAuthorsWithPaper,
       pc.Count AS NumPaperAuthorPairs,
       CASE WHEN coauth.Sum > 0 THEN coauth.Sum
            ELSE 0 
       END AS SumPapersWithCoAuthors,
       CASE WHEN coauth.Avg > 0 THEN coauth.Avg
            ELSE 0 
       END AS AvgPapersWithCoAuthors,
       CASE WHEN cjc.Count > 0 THEN cjc.Count
            ELSE 0
       END AS NumSameJournalByCoauthors,
       CASE WHEN cjc.AvgCount > 0 THEN cjc.AvgCount
            ELSE 0
       END AS AvgNumSameJournalByCoauthors,
       CASE WHEN ccc.Count > 0 THEN ccc.Count
            ELSE 0
       END AS NumSameConferenceByCoauthors,
       CASE WHEN ccc.AvgCount > 0 THEN ccc.AvgCount
            ELSE 0
       END AS AvgNumSameConferenceByCoauthors,
       kc.KeywordCount as Keywordcount,
       tkc.TotalKeywordCount as Totalkeywordcount,
       tkc.AvgKeywordCount as Avgkeywordcount,
       CASE WHEN ck.common_keywords > 0
       THEN ck.common_keywords 
       ELSE 0
       END as Commonkeywords,
       CASE WHEN ct.common_titlewords > 0
       THEN ct.common_titlewords 
       ELSE 0
       END as CommonTitleWords,
       CASE WHEN neg.indicator > 0
       THEN neg.indicator 
       ELSE 0
       END as NegId 
FROM ValidDeleted t
LEFT OUTER JOIN Paper p ON t.PaperId=p.Id
LEFT OUTER JOIN AuthorJournalCounts ajc
    ON ajc.AuthorId=t.AuthorId
  AND ajc.JournalId = p.JournalId
  AND ajc.JournalId != 0 
LEFT OUTER JOIN AuthorConferenceCounts acc
    ON acc.AuthorId=t.AuthorId
   AND acc.ConferenceId = p.ConferenceId
   AND acc.ConferenceId != 0 
LEFT OUTER JOIN AuthorPaperCounts apc
    ON apc.AuthorId=t.AuthorId
LEFT OUTER JOIN PaperAuthorCounts pac
    ON pac.PaperId=t.PaperId
LEFT OUTER JOIN PairCount pc
    ON pc.PaperId=t.PaperId
    AND pc.AuthorId=t.AuthorId
LEFT OUTER JOIN SumPapersWithCoAuthors coauth
    ON coauth.AuthorId=t.AuthorId
   AND coauth.PaperId=t.PaperId
LEFT OUTER JOIN CoauthorJournalCounts cjc
   ON cjc.AuthorId = t.AuthorId
   AND cjc.PaperId = t.PaperId
LEFT OUTER JOIN CoauthorJournalCounts ccc
   ON ccc.AuthorId = t.AuthorId
   AND ccc.PaperId = t.PaperId
LEFT OUTER JOIN KeywordCounts kc
   ON kc.PaperID = t.PaperID
LEFT OUTER JOIN TotalKeywordCounts tkc
   ON tkc.AuthorId = t.AuthorID
LEFT OUTER JOIN CommonKeywords ck
   ON ck.authorid = t.authorid
   AND ck.paperid = t.paperid
LEFT OUTER JOIN CommonTitleWords ct
ON ct.authorid = t.authorid
   AND ct.paperid = t.paperid
LEFT OUTER JOIN NegativeId neg
ON neg.paperid = t.paperid
);
