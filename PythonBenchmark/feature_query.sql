WITH 
AuthorPaperCounts AS (
    SELECT AuthorId, Count(*) AS Count
    FROM PaperAuthor
    GROUP BY AuthorId),
PaperAuthorCounts AS (
    SELECT PaperId, Count(*) AS Count
    FROM PaperAuthor
    GROUP BY PaperId),
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
              FROM ##DataTable##)
        GROUP BY pa1.AuthorId, pa2.AuthorId)
    SELECT t.AuthorId,
           t.PaperId, 
           SUM(NumPapersTogether) AS Sum,
           AVG(NumPapersTogether) as Avg 
    FROM ##DataTable## t
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
              FROM ##DataTable##)
        GROUP BY pa1.AuthorId, pa2.AuthorId)
   SELECT t.AuthorId,
            t.PaperId,
            SUM(ajc.Count) AS Count,
            AVG(ajc.Count) AS AvgCount
   FROM ##DataTable## t
   LEFT OUTER JOIN Paper p ON t.PaperId = p.Id
   LEFT OUTER JOIN PaperAuthor pa ON t.PaperID=pa.PaperID
   LEFT OUTER JOIN CoAuthors ca ON ca.Author2=pa.AuthorId
   LEFT OUTER JOIN AuthorJournalCounts ajc
      ON ajc.AuthorId = ca.Author2
      AND ajc.JournalId = p.JournalID
   WHERE pa.AuthorId != t.AuthorId
      AND ca.Author1 = t.AuthorId
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
              FROM ##DataTable##)
        GROUP BY pa1.AuthorId, pa2.AuthorId)
   SELECT t.AuthorId,
            t.PaperId,
            SUM(acc.Count) AS Count,
            AVG(acc.Count) AS AvgCount
   FROM ##DataTable## t
   LEFT OUTER JOIN Paper p ON t.PaperId = p.Id
   LEFT OUTER JOIN PaperAuthor pa ON t.PaperID=pa.PaperID
   LEFT OUTER JOIN CoAuthors ca ON ca.Author2=pa.AuthorId
   LEFT OUTER JOIN AuthorConferenceCounts acc
      ON acc.AuthorId = ca.Author2
      AND acc.ConferenceId = p.ConferenceID
   WHERE pa.AuthorId != t.AuthorId
      AND ca.Author1 = t.AuthorId
   GROUP BY t.AuthorId, t.PaperId
)
SELECT t.AuthorId,
       t.PaperId,
       ajc.Count As NumSameJournal, 
       acc.Count AS NumSameConference,
       apc.Count AS NumPapersWithAuthor,
       pac.Count AS NumAuthorsWithPaper,
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
       --tkc.TotalKeywordCount as Totalkeywordcount,
       tkc.AvgKeywordCount as Avgkeywordcount
FROM ##DataTable## t
LEFT OUTER JOIN Paper p ON t.PaperId=p.Id
LEFT OUTER JOIN AuthorJournalCounts ajc
    ON ajc.AuthorId=t.AuthorId
  AND ajc.JournalId = p.JournalId
LEFT OUTER JOIN AuthorConferenceCounts acc
    ON acc.AuthorId=t.AuthorId
   AND acc.ConferenceId = p.ConferenceId
LEFT OUTER JOIN AuthorPaperCounts apc
    ON apc.AuthorId=t.AuthorId
LEFT OUTER JOIN PaperAuthorCounts pac
    ON pac.PaperId=t.PaperId
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
