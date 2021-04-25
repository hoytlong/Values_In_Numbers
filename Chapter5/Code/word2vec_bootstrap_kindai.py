"""
word2vec_bootstrap_kindai.py: build multiple word2vec models with bootstrap samples
usage: python3 word2vec_bootstrap_kindai.py --embed_dim 100 --num_bootstrap 20
"""

import os
import re
import random
import gensim
import argparse
import pandas as pd
from pandas import Series, DataFrame
from utils import *

#find directory path of current folder
folder_path = os.path.abspath("word2vec_bootstrap_kindai.py" + "/../../")

### some pre-processing functions

def punc_cleaner(raw):
    raw = re.sub(r'[一二三四五六七八九十]+[百千万]*', '', raw)   #replace all numbers
    raw = re.sub(r'[×‥・○◎]+', '', raw)   #replace punctuation marks
    raw = re.sub(r'[Ａ-Ｚ]+', '', raw)     #replace full-width letters
    raw = re.sub(r'\s+', ' ', raw)     #get rid of double spaces
    return raw

def name_cleaner(text, proper_names):
    tokens = re.split(r'\s', text)
    targets = set(re.findall(r'[ァ-ヺ]+', text)) #extract all katakana words
    
    #if it's in our proper name list then delete all instances
    for target in targets:
        if target in proper_names:
            tokens = list(filter(lambda a: a != target, tokens))
    
    text = ' '.join(tokens)           #get rid of double spaces    
    return text

def periods(text):
    #count periods
    periods = re.findall(r'。', text)
    
    #tokenize text
    text = re.split(r'\s', text)
    
    return len(periods)/len(text)

def get_proper_names():
    proper_names = []
	prop_names_file = folder_path + "\\WordLists\ProperNames.txt"
    with open(prop_names_file, 'r', encoding = "utf-8") as f:
        for word in f.readlines():
            proper_names.append(word.replace("\n", ""))
    return proper_names

### Bootstrap function to build w2v model on random sample if desired

def buildWordsBySentenceBootstrap(corpus_path, bootstrap = True):
    """
    Prepare sentence list for word2vec
    """
    files = [file for file in os.listdir(corpus_path) if file.endswith('.txt')]
    words_by_sentence = []
    for i in range(len(files)):
        if bootstrap:
            file = random.choice(files)
        else:
            file = files[i]
        with open(os.path.join(corpus_path, file), 'r', encoding = 'utf-8') as f:
            raw = f.read()
            
            #get ratio of periods in text
            period_count = periods(raw)            
            
            #exclude texts that don't use standard period for punctuation (ratio of .005 or less)
            if period_count > .005:
                temp_sents = re.findall(r'([^！？。(――)(——)\(\)]+(」を.*)*(」と[^。]*)*(」、と[^。]*)*(？」と[^。]*)*[！？。」(……)]*)', raw)            
                #now tokenize each sentence and add to global list
                for sent in temp_sents:
                    sent_to_tokenize = sent[0]  #grab only first item, since findall produces tuples
                    if sent_to_tokenize != ' ':
                        sent_words = re.split(r'\s', sent_to_tokenize)
                        if sent_words[0] == '':
                            words_by_sentence.append(sent_words[1:])  #get rid of leading space
                        else:
                            words_by_sentence.append(sent_words)
    
    #return the full list of sentences, which is the necessary input for w2v 
    return words_by_sentence

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--embed_dim", type = int, help = "embedding dimension", default = 100)
    parser.add_argument("--num_bootstrap", type = int, help = "number of bootstrap samples", default = 20)
    args = parser.parse_args()
    embed_dim = args.embed_dim
    num_bootstrap = args.num_bootstrap
    
    #pre-process texts and stick them in new folder
    
    corpus_path = folder_path + '\\KindaiW2VPreProcessed\\'  #store pre-processed texts here
    input_path = folder_path + '\\KindaiLemmaMerged\\'        #previously lemmatized texts are here; racial identifiers should be merged
    
    #filter out duplicates and pre-1886 and post-1960 texts
    meta_file = folder_path + '\\Data\Kindai_Meta.xlsx'
	df = pd.read_excel(meta_file, sheetname='Sheet1')
    df = df[df['FILTER'] != 'YES']
    input_files = df.FILE_ID.tolist()
    #input_files = [file for file in os.listdir(input_path) if file.endswith('.txt')]
    
    proper_names = get_proper_names()
    for i in range(len(input_files)):
        file = input_files[i]
        with open(os.path.join(input_path, file), 'r', encoding = 'utf-8') as f:
            raw = f.read()
            raw = punc_cleaner(raw)
            raw = name_cleaner(raw, proper_names)  #strip proper names
            with open(os.path.join(corpus_path, file), 'w', encoding="utf-8") as g:
                g.write(raw)
            g.close()    
    
    file_name = folder_path + '\\results_kindai_bootstrap\word2vec_bootstrap\model_'
    for i in range(num_bootstrap):
        random.seed(i)
        words_by_sentence = buildWordsBySentenceBootstrap(corpus_path)
        model = gensim.models.word2vec.Word2Vec(words_by_sentence, size=embed_dim, window=10, min_count=5, sg=1, alpha=0.025, iter=5, batch_words=10000)
        model.wv.save_word2vec_format(file_name + str(i) + '.txt')
        print(i)
    words_by_sentence = buildWordsBySentenceBootstrap(corpus_path, bootstrap = False)
    model = gensim.models.word2vec.Word2Vec(words_by_sentence, size=embed_dim, window=10, min_count=5, sg=1, alpha=0.025, iter=5, batch_words=10000)
    model.wv.save_word2vec_format(folder_path + '\results_kindai_bootstrap\word2vec.txt')
	
	#point to folder where bootstrap files are stored
	model_dir = folder_path + '\\results_kindai_bootstrap\word2vec_bootstrap\\'
	boot_files = [file for file in os.listdir(model_dir) if file.endswith('.txt')]

	for i in range(len(boot_files)):
		file = boot_files[i]
		with open(os.path.join(model_dir, file), 'r', encoding = 'utf-8') as f:
			raw = f.read()
			if re.findall(r'\n -', raw):
				raw = re.sub(r'\n -', r'\nSPACE -', raw)
				with open(os.path.join(model_dir, file), 'w', encoding='utf-8') as g:
					g.write(raw)
				g.close()
			elif re.findall(r'\n 0', raw):
				raw = re.sub(r'\n 0', r'\nSPACE 0', raw)
				with open(os.path.join(model_dir, file), 'w', encoding='utf-8') as g:
					g.write(raw)
				g.close()

if __name__ == '__main__':
    main()