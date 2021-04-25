\* This file describes code and data associated with Chapter 3 (“Genre
and Repetition”) of *The Values in Numbers: Reading Japanese Literature
in a Global Information Age*.

**Data Files**

1\) **“Data\\Ch3CorpusMetadata.xlsx”** – Metadata file for all texts in
the corpus, including unique IDs associated with each text.

2\) **“Texts\\”** – Folder containing all out-of-copyright texts in the
corpus (186 texts). Texts have already been tokenized. Please contact
author for access to the full corpus.

3\) **“Stoplists\\jp\_punct.txt”** – List of Japanese punctuation that
are excluded in some operations. These are also the punctuation counted
as part of the “punctuation” feature.

4\) **“Stoplists \\jp\_stopword.txt”** – Corpus specific stopword list.
Stopwords were decided based on an overall frequency distribution of the
corpus, from which words were hand-picked.

5\) **“Data\\FreqDist.xlsx”** – A spreadsheet containing tabulated
frequencies for all words in corpus. This list was used to create the
stopword list for feature extraction.

6\) **“Results\\all\_extracted\_features.xlsx”** – Data frame of
extracted features for Japanese corpus.

7\) **“Results\\derived\_data\_ch.csv”** – Data frame of extracted
features for the Chinese corpus. This file was produced as part of an
earlier iteration of this research, as described in the chapter.

**Code Files**

*(Python Scripts)*

1\) **“jp\_feature\_extraction.ipynb”** – An IPython notebook used to
extract specific features from the Japanese text corpus and to perform
distinctive word analysis.

*(R Scripts)*

1\) **“GetFeatures.R”** – An R script used to extract additional
features from text corpora (e.g., type-token ratio, entropy,
non-parametric entropy).

2\) **“features.R”** – An R file containing functions for feature
extraction.

3\) **“utils.R”** – An R file containing various utility functions used
in the feature extraction code.

4\) **“GetResults.R”** – Code for comparing distributions of features
across genre corpora. Includes code for producing boxplots and for doing
simple t-tests.

5\) **“GetChunks.R”** – An R script that extracts chunk-level features
along with the corresponding chunks. Can be used to identify, for
example, the most or least entropic chunks. The Results folder contains
the output of this script for high and low entropy chunks.

6\) **“Classifier.R”** – R script used to run a best-subset selection
logistic classifier on the extracted features and to generate text-level
genre predictions based on different genre models.

7\) **“Visualize.R”** – Code to generate all visualizations related to
this chapter.

**<u>Corpus Processing and Analysis Steps</u>**

\* All texts were stripped of paratextual content such as titles,
headers, page numbers, etc. Kanji characters were normalized to “new”
style. Word tokenization was performed with the MeCab python library
using the *Unidic* dictionary from NINJAL.

\* After this initial processing, the “jp\_feature\_extraction.ipynb”
code file is used to calculate the most distinctive words between genres
and to extract specific features used in analysis. From this is obtained
a “python\_extracted\_features.xlsx” file, stored in the “Results”
folder.

\* Additional features related to entropy and vocabulary richness are
then calculated using the “GetFeatures.R” code file. This produces two
results files. 1) “all\_extracted\_features.xlsx” is the final data
frame containing all extracted features for all texts. 2)
“record\_jp.xlsx” records passage level measurements and is used to
identify high or low entropy passages for further analysis with the
“GetChunks.R” code file.

\* Once features have been extracted, the “Classifier.R” code file is
used to perform supervised text classification and to output text-level
predictions based on the 2 genre models described in the chapter.
