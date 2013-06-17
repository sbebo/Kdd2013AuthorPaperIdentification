SELECT AuthorId,
       PaperId,
       NumSameJournal, 
       NumSameConference,
       NumPapersWithAuthor,
       NumAuthorsWithPaper,
       NumPaperAuthorPairs,
       SumPapersWithCoAuthors,
       AvgPapersWithCoAuthors,
       NumSameJournalByCoauthors,
       AvgNumSameJournalByCoauthors,
       NumSameConferenceByCoauthors,
       AvgNumSameConferenceByCoauthors,
       Keywordcount,
       --Totalkeywordcount,
       Avgkeywordcount,
       --Commonkeywords,
       CommonTitleWords
       --NegId
FROM ##DataTable##
