\* This file describes code and data associated with Chapter 4
(“Influence and Judgement”) of *The Values in Numbers: Reading Japanese
Literature in a Global Information Age*.

### **------- Data Files -------** ###

1\) **“Data\\SOC\_TEXTS\_METADATA.xlsx”** – Metadata file for all
hand-picked SOC passages, including unique IDs associated with each
text.

2\) **“Data\\ALL\_TEXTS\_METADATA.xlsx”** – Metadata file for 90 texts
selected from the corpus of I-Novel, Popular, and Pure literature texts
used in Chapter 3. Includes unique IDs associated with each text.

3\) **“Data\\ALL\_FIC\_METADATA.xlsx”** – Metadata file for 718 texts
selected from the Aozora Bunko collection with dates ranging from 1925
to 1940. Also includes digitized texts that are still under copyright.
Metadata includes unique IDs associated with each text.

4\) **“Texts\\”** – Folder containing all SOC passages used in analysis.
Texts are not tokenized. Due to copyright restrictions, full text for
the larger sample of 718 works is not provided.

5\) **“VocabLists\\jp\_stopword.txt”** – Corpus specific stopword list.
Stopwords were decided based on an overall frequency distribution of the
corpus, from which words were hand-picked.

6\) **“VocabLists\\onom.txt”** – List of onomatopoetic words extracted
from Jim Breen’s extensive online dictionary of Japanese. Original data
file not included in this repository.

7\) **“Results\\AllChunkFeatures.xlsx”** – Data frame of extracted
passage-level features for all SOC labeled texts and all 90 texts marked
as “I-Novel,” “Popular,” or “Junbungaku” (pure literature).

8\) **“Results\\FicChunkFeatures.xlsx”** – Data frame of extracted
passage-level features for all 718 works sampled from the Aozora Fiction
corpus.

9\) **“Results\\average\_scores\_\*.\*”** – These files represent the
computed predictions by work/book for texts in a specific genre or in
the larger fiction corpus. Predictions are specific to the fitted model
selected in Classifier.R code file, as well as the random sample on
which the model is fit.

10\) **“Results\\pred\_results\_\*.\*”** – These files represent the
computed predictions by passage/chunk for texts in a specific genre or
in the larger fiction corpus. Predictions are specific to the fitted
model selected in Classifier.R code file, as well as the random sample
on which the model is fit.

11\) **“Results\\SOC\_CHUNKS\_1929.xlsx”** – A spreadsheet containing
predicted SOC scores and metadata for all passages from works in fiction
corpus published in 1929.

12\) **“Results\\1929\_SOC\_Passages.txt”** – This file contains all
passages from works in the fiction corpus published in 1929 along with
predicted score, chunk id, and author information.

13\) **“Results\\US\_NOVELS\_SOC\_Predictions.csv”** – A spreadsheet
with predicted SOC scores for English novels analyzed in earlier
research on this topic (scores averaged across entire novel). I provide
a reference in the chapter to code used in producing this earlier
analysis.

14\) **“Results\\Figures\\\*\_PRED.jpg”** – These figures show results
for work/book level predictions on the I-novel, Popular, and Pure
(“JUNBUNGAKU”) literature genres. Only the figure for I-novel predicted
scores is included in the body of the chapter.

### **------- Code Files -------** ###

1\) **“jp\_feature\_extraction.ipynb”** – An IPython notebook used to
extract passage level features from all corpora.

2\) **“Classifier.R”** – R script used to perform supervised
classification using logistic regression on a variety of different
models. Generates passage and book-level predictions based on results of
the classification procedure.

3\) **“Visualize.R”** – R script for reproducing visualizations used in
this chapter. Uses the passage and book level predictions produced with
Classifier.R code file.

### **------- Corpus Processing and Analysis Steps -------** ###

\* All texts were stripped of paratextual content such as titles,
headers, page numbers, etc. Kanji characters were normalized to “new”
style. Word tokenization was performed with the MeCab python library
using the *Unidic* dictionary from NINJAL.

\* After this initial processing, the “jp\_feature\_extraction.ipynb”
code file is used to extract all features at the passage (or “chunk”)
level. It does this for the SOC labeled passages, but it also chunks and
measures all passages in two larger corpora: 1) a set of 90 texts
selected from the corpus used in Chapter 3, and 2) a set of 718 texts
published between 1925 and 1940 taken from the larger Aozora Bunko
collection and from a handful of digitized (and in-copyright) texts. The
extracted features are output to “AllChunkFeatures.xlsx” and
“AllFicFeatures.xlsx,” described above.

\* Once features have been extracted, the “Classifier.R” code file is
used to perform supervised text classification and identify the most
accurate models based on different combinations of the extracted
features. Once the model is fit, predictions can be made for all
passages from a given corpus. These predictions are used for
visualization and further analysis.
