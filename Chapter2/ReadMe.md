\* This file describes code and data associated with Chapter 2
(“Archive and Sample”) of *The Values in Numbers: Reading Japanese
Literature in a Global Information Age*.

### ------- **<u>Data Files</u>** ------- ###

1\) **<u>“AozoraLiteraryTranslations.xlsx”</u>** – Subset of Aozora Bunko metadata
that includes all titles marked as translations into Japanese.

2\) **<u>“AuthRankCorr.xlsx”</u>** – Author ranking data used to produce
correlation matrix.

3\) **<u>“ChikumaGNBZtoc.xlsx”</u>** – Contains a list of all authors and titles
included in the Chikuma Shobo published *Gendai Nihon Bungaku Zenshu*.
Also includes metadata pertaining to author gender and copyright status,
as well as analysis for determining percentage overlap with Aozora Bunko
archive.

4\) **<u>“CompleteMetadata\_Ver3.xlsx”</u>** – Contains metadata derived from
Nichigai digital index of Japanese literature anthologies, with
associated metadata for authors and titles.

5\) **<u>“Corpus\_Metadata\_Clean.xlsx”</u>** – Contains metadata for complete
Aozora Bunko collection as well as titles digitized to supplement this
collection.

6\) **<u>“Foreign\_Author\_Metadata.xlsx”</u>** – Contains metadata for foreign
authors contained in the 2 translation indexes described in this
chapter.

7\) **<u>“KanjiCounts.xlsx”</u>** – Extracted counts of *kanji* characters for all
texts in the reduced Aozora “fiction” corpus as described in this
chapter.

8\) **<u>“MasterListFinal.xlsx”</u>** – Contains all metadata for titles listed in
the 2 translation indexes that were digitized for this chapter. The
Meiji and Taisho/Showa data have been combined into single spreadsheet.
Metadata for Meiji titles includes only the country of origin and year
of publication. Metadata for Taisho and Showa data is richer and has
been substantially cleaned. Publisher data, however, is not entirely
reliable due to poor OCR quality.

9\) **<u>“PenClubRoster1979.xlsx”</u>** – Digitized list of all members of the
Japanese P.E.N. club that was published in 1979, along with metadata
tags for gender.

10\) **<u>“POSCounts.xlsx”</u>** – Extracted counts of part-of-speech tags for all
texts in reduced Aozora “fiction” corpus as described in this chapter.

11\) **<u>“ShuppanNenkanData.xlsx”</u>** – Counts for the number of books and
magazines published per year from 1868 to 1955, based on tables given in
*Shuppan nenkan* volumes cited in the chapter.

12\) **<u>“Textbook\_Metadata.xlsx”</u>** – Metadata extracted from the Nichigai
index to literature printed in Japanese high school textbooks, *Kyōkasho
keisai sakuhin 13000: yonde okitai meichō annai* (2008).

13\) **<u>“Top3KTitleMetricsZenshuData.xlsx”</u>** – Contains a ranked list of the
top 3,000 titles (by raw count) in the Nichigai anthology data. Counts
are tabulated based only on omnibus anthologies, not individual author
anthologies.

14\) **<u>“Top250AuthorMetricsZenshuData.xlsx”</u>** – Contains a ranked list of
the top 250 authors (by total numbers of titles anthologized) in the
Nichigai anthology data. Counts are tabulated based only on omnibus
anthologies, not individual author anthologies.

### ------- **<u>Code Files</u>** ------- ###

*(R Scripts)*

1\) **<u>Ch2\_Code.R</u>** – Contains all code for producing visualizations and for
running simple metadata analysis on the bibliographic datasets discussed
in this chapter.

2\) **<u>ranking.R</u>** – Code for comparing author rank correlations and for
producing correlation matrix.

3\) **<u>TextbookAnalysis.R</u>** – Code for analyzing and visualizing Japanese
high school textbook data discussed in this chapter. None of these
visualizations are included in the chapter, but this code was used to
produce numerical figures related to this dataset.

*(Python Scripts)*

1\) **<u>AccessRankingExtractor.ipynb</u>** – Code used for extracting user
access data on Aozora Bunko. Scrapes number of hits per title and
extracts to an excel spreadsheet.

2\) **<u>FictionCorpusAnalysis.ipynb</u>** – Code used for counting Kanji
characters and POS tags in the Aozora limited “Fiction” corpus.

3\) **<u>ZenshuDataAnaysis.ipynb</u>** – This script contains code for analyzing
the Nichigai anthology metadata and for producing alternate metrics on
titles and authors (e.g., normalized frequencies, H-index, M-index).
