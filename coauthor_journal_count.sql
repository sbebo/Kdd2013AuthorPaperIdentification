/*WITH AuthorJournalCounts AS (
    SELECT AuthorId, JournalId, Count(*) AS Count
    FROM PaperAuthor pa
    LEFT OUTER JOIN Paper p on pa.PaperId=p.Id
    GROUP BY AuthorId, JournalId),*/
with CoAuthors AS (
        SELECT pa1.AuthorId Author1, 
               pa2.AuthorId Author2 
        FROM PaperAuthor pa1,
             PaperAuthor pa2
        WHERE pa1.PaperId=pa2.PaperId
          AND pa1.AuthorId != pa2.AuthorId
          AND pa1.AuthorId IN (
              SELECT DISTINCT AuthorId
              FROM TrainConfirmed)
        GROUP BY pa1.AuthorId, pa2.AuthorId)
SELECT t.AuthorId,
           t.PaperId, 
           SUM(ajc.Count) AS CoauthorJournalCounts
    FROM TrainConfirmed t
    LEFT OUTER JOIN Paper p ON t.PaperId=p.Id
    LEFT OUTER JOIN PaperAuthor pa ON t.PaperId=pa.PaperId
    LEFT OUTER JOIN CoAuthors ca ON ca.Author2=pa.AuthorId
    LEFT OUTER JOIN AuthorJournalCounts ajc
      ON ajc.AuthorId = ca.Author2
      AND ajc.JournalId = p.JournalId
    WHERE pa.AuthorId != t.AuthorId
      AND ca.Author1 = t.AuthorId
    GROUP BY t.AuthorId, t.PaperId

