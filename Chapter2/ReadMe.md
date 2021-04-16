**Read Me File**

\* This Read Me File describes code and data associated with Chapter 2
(“Archive and Sample”) of *The Values in Numbers: Reading Japanese
Literature in a Global Information Age*.

**<u>Data Files</u>**

1\) “AozoraLiteraryTranslations.xlsx” – Subset of Aozora Bunko metadata
that includes all titles marked as translations into Japanese.

2\) “AuthRankCorr.xlsx” – Author ranking data used to produce
correlation matrix.

3\) “ChikumaGNBZtoc.xlsx” – Contains a list of all authors and titles
included in the Chikuma Shobo published *Gendai Nihon Bungaku Zenshu*.
Also includes metadata pertaining to author gender and copyright status,
as well as analysis for determining percentage overlap with Aozora Bunko
archive.

4\) “CompleteMetadata\_Ver3.xlsx” – Contains metadata derived from
Nichigai digital index of Japanese literature anthologies, with
associated metadata for authors and titles.

5\) “Corpus\_Metadata\_Clean.xlsx” – Contains metadata for complete
Aozora Bunko collection as well as titles digitized to supplement this
collection.

6\) “Foreign\_Author\_Metadata.xlsx” – Contains metadata for foreign
authors contained in the 2 translation indexes described in this
chapter.

7\) “KanjiCounts.xlsx” – Extracted counts of *kanji* characters for all
texts in the reduced Aozora “fiction” corpus as described in this
chapter.

8\) “MasterListFinal.xlsx” – Contains all metadata for titles listed in
the 2 translation indexes that were digitized for this chapter. The
Meiji and Taisho/Showa data have been combined into single spreadsheet.
Metadata for Meiji titles includes only the country of origin and year
of publication. Metadata for Taisho and Showa data is richer and has
been substantially cleaned. Publisher data, however, is not entirely
reliable due to poor OCR quality.

9\) “PenClubRoster1979.xlsx” – Digitized list of all members of the
Japanese P.E.N. club that was published in 1979, along with metadata
tags for gender.

10\) “POSCounts.xlsx” – Extracted counts of part-of-speech tags for all
texts in reduced Aozora “fiction” corpus as described in this chapter.

11\) “ShuppanNenkanData.xlsx” – Counts for the number of books and
magazines published per year from 1868 to 1955, based on tables given in
*Shuppan nenkan* volumes cited in the chapter.

12\) “Textbook\_Metadata.xlsx” – Metadata extracted from the Nichigai
index to literature printed in Japanese high school textbooks, *Kyōkasho
keisai sakuhin 13000: yonde okitai meichō annai* (2008).

13\) “Top3KTitleMetricsZenshuData.xlsx” – Contains a ranked list of the
top 3,000 titles (by raw count) in the Nichigai anthology data. Counts
are tabulated based only on omnibus anthologies, not individual author
anthologies.

14\) “Top250AuthorMetricsZenshuData.xlsx” – Contains a ranked list of
the top 250 authors (by total numbers of titles anthologized) in the
Nichigai anthology data. Counts are tabulated based only on omnibus
anthologies, not individual author anthologies.

**<u>Code Files</u>**

*(R Scripts)*

1\) Ch2\_Code.R – Contains all code for producing visualizations and for
running simple metadata analysis on the bibliographic datasets discussed
in this chapter.

2\) ranking.R – Code for comparing author rank correlations and for
producing correlation matrix.

3\) TextbookAnalysis.R – Code for analyzing and visualizing Japanese
high school textbook data discussed in this chapter. None of these
visualizations are included in the chapter, but this code was used to
produce numerical figures related to this dataset.

*(Python Scripts)*

1\) “AccessRankingExtractor.ipynb” – Code used for extracting user
access data on Aozora Bunko. Scrapes number of hits per title and
extracts to an excel spreadsheet.

2\) “FictionCorpusAnalysis.ipynb” – Code used for counting Kanji
characters and POS tags in the Aozora limited “Fiction” corpus.

3\) “ZenshuDataAnaysis.ipynb” – This script contains code for analyzing
the Nichigai anthology metadata and for producing alternate metrics on
titles and authors (e.g., normalized frequencies, H-index, M-index).