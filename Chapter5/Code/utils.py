import re
import os
import gensim
import random
import pickle
import numpy as np
import pandas as pd
import operator
import argparse
from collections import Counter
from sklearn.cluster import KMeans
from sklearn.preprocessing import normalize
from scipy.stats import fisher_exact

def find_nearest_words(x, num = 20, cosine = True):
    if cosine:
        index = (-np.matmul(word_vec, x)).argsort()[0:num]
    else:
        index = ((word_vec - x)**2).sum(1).argsort()[0:num]
    return [vocab[i] for i in index]

def clean(text):
    """ Remove punctuations and extra white spaces
    """
    # replace punctuations with white space
    puncs = ['、', '。', '「', '」', '…', '！', '――', '？', 'ゝ', '『', '』', 
         '（', '）', '／', '＼', '々', 'ーーー', '］', '・', 'ゞ', '［', 
         '<', '＃', '△', '※', '＊', r'\(', r'\)', ',', r'\.', r'\*']
    for punc in puncs:
        text = re.sub(punc, ' ', text)
    for punc in ['＿', '−', '─']:
        text = re.sub(punc, '', text)
    # remove extra white spaces
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def read_corpus(dir):
    corpus = {
        'filename' : [],
        'text'     : []
    }
    for file in os.listdir(dir):
        if file.endswith(".txt"):
            with open(os.path.join(dir, file), 'r', encoding = 'utf-8') as f:
                corpus['filename'].append(file)
                text = clean(f.read())
                corpus['text'].append(text.split(' '))
    return pd.DataFrame(corpus)

# def build_context_table(texts, markers, window_size, atoms, labels, one_per_text = True, separate = None, exclude = []):
#     """
#     Build context table based on texts for the markers.
#     """
#     if not separate:
#         separate = 2 * window_size
#     m = len(markers)
#     context = [dict(zip(markers, [0] * m)).copy() for i in range(0, atoms.shape[0])]
#     context = dict(zip(range(0, atoms.shape[0]), context))
#     context_words = {term: [] for term in markers}
#     for text in texts:
#         markers_temp = markers.copy()
#         index = dict(zip(markers, [-separate] * m))
#         for i in range(window_size, len(text)-window_size-1):
#             if (text[i] in markers_temp) and (i >= index[text[i]] + separate):
#                 for j in range(0, window_size):
#                     if text[i-j-1] not in exclude:
#                         try:
#                             context[labels[vv[text[i-j-1]]]][text[i]] += 1
#                             context_words[text[i]].append(text[i-j-1])
#                         except:
#                             pass
#                     if text[i+j+1] not in exclude:
#                         try:
#                             context[labels[vv[text[i+j+1]]]][text[i]] += 1
#                             context_words[text[i]].append(text[i+j+1])
#                         except:
#                             pass
#                 index[text[i]] = i
#                 if one_per_text:
#                     markers_temp.remove(text[i])
#                     if len(markers_temp) < 1:
#                         break
#     context_words = {term: dict(Counter(context_words[term])) for term in markers }
#     return pd.DataFrame(context), context_words

def build_context_table(texts, markers, window_size, atoms, labels, vv, one_per_text = True, separate = None, exclude = []):
    if not separate:
        separate = 2 * window_size
    m = len(markers)
    #context = [dict(zip(markers, [0] * m)).copy() for i in range(0, atoms.shape[0])]
    #context = dict(zip(range(0, atoms.shape[0]), context))
    context = {i: {marker: 0 for marker in markers} for i in range(0, atoms.shape[0])}
    context_words = {term: [] for term in markers}
    for text in texts:
        markers_temp = markers.copy()
        index = {marker: -separate for marker in markers}
        for i in range(window_size, len(text) - window_size - 1):
            if (text[i] in markers_temp) and (i >= index[text[i]] + separate):
                for j in range(0, window_size):
                    if text[i-j-1] not in exclude:
                        try:
                            context[labels[vv[text[i-j-1]]]][text[i]] += 1
                            context_words[text[i]].append(text[i-j-1])
                        except:
                            pass
                    if text[i+j+1] not in exclude:
                        try:
                            context[labels[vv[text[i+j+1]]]][text[i]] += 1
                            context_words[text[i]].append(text[i+j+1])
                        except:
                            pass
                index[text[i]] = i
                if one_per_text:
                    markers_temp.remove(text[i])
                    if len(markers_temp) < 1:
                        break
    context_words = {term: dict(Counter(context_words[term])) for term in markers }
    return pd.DataFrame(context), context_words

def build_context_table_all(texts, markers, vocab, window_size, one_per_text = False, separate = None):
    if not separate:
        separate = 2 * window_size
    context = {word: {marker: 0 for marker in markers} for word in vocab}
    for text in texts:
        markers_temp = markers.copy()
        index = {marker: -separate for marker in markers}
        for i in range(window_size, len(text) - window_size - 1):
            if (text[i] in markers_temp) and (i >= index[text[i]] + separate):
                for j in range(0, window_size):
                    try:
                        context[text[i - j - 1]][text[i]] += 1
                    except:
                        pass
                    try:
                        context[text[i + j + 1]][text[i]] += 1
                    except:
                        pass
                index[text[i]] = i
                if one_per_text:
                    markers_temp.remove(text[i])
                    if len(markers_temp) < 1:
                        break
    return pd.DataFrame(context)[vocab]

def get_word_count(texts, vocab):
    word_count = {word: {'total': 0} for word in vocab}
    for text in texts:
        for word in text:
            if word in word_count:
                word_count[word]['total'] += 1
    return pd.DataFrame(word_count)[vocab]

def rank_context(context, race1, race2):
    temp = np.array(context.loc[[race1, race2]])
    total = temp.sum(1)
    return np.array([fisher_exact(np.column_stack((temp[:, i], total - temp[:, i])), alternative = "greater")[1] 
                     for i in range(temp.shape[1])])

def bh(p):
    n = len(p)
    i = np.arange(n, 0, -1)
    o = (-p).argsort()
    ro = o.argsort()
    return np.minimum.accumulate(n/i * p[o])[ro]

def get_stop_words():
    stop_words = []
    with open("./stopwords.txt", 'r', encoding = "utf-8") as f:
        for word in f.readlines():
            stop_words.append(word.replace("\n", ""))
    return stop_words


def kmeanspp_init(x, k):
    """
    Customized k-means++ implementation, using cosine distance
    """
    n, p = x.shape
    x = normalize(x, axis = 1, norm = 'l2')
    prob = [1/n] * n
    ind = np.where(np.random.multinomial(1, prob) == 1)[0][0]
    centers = x[ind].reshape([1, p])
    for i in range(1, k):
        d = 1 - np.matmul(x, centers.T)
        prob = d.min(1)
        prob = prob / prob.sum()
        ind = np.where(np.random.multinomial(1, prob) == 1)[0][0]
        centers = np.vstack([centers, x[ind]])
    return centers

def kmeans(x, k, random_state = None):
    """
    Customized k-means with k-means++ initialization and cosine distance
    """
    random.seed(random_state)
    n, p = x.shape
    max_iter = 1e5
    num_iter = 0
    x = normalize(x, axis = 1, norm = 'l2')
    centers = kmeanspp_init(x, k)
    labels = np.matmul(x, centers.T).argmax(1)
    while True:
        labels_old = labels.copy()
        centers = np.array([x[labels == i, :].mean(0) for i in range(0, k)])
        centers = normalize(centers, axis = 1, norm = 'l2')
        labels = np.matmul(x, centers.T).argmax(1)
        num_iter += 1
        if all(labels - labels_old == 0):
            break
        if num_iter > max_iter:
            print("Maximum number of iteration reached...")
            break
    score  = np.matmul(x, centers.T).max(1).mean()
    return centers, labels, score

def display_significant_context(race1, race2, threshold, context, context_words, atoms_words):
    total = context.sum(1)
    pval = rank_context(context, race1, race2)
    pval_adjusted = bh(pval)
    for i in pval.argsort():
        if pval_adjusted[i] < threshold:
            print("Original p value: %.3f; Adjusted p value: %.3f" % (pval[i], pval_adjusted[i]))
            print("Atom words: \n", atoms_words[list(context)[i]])
            print("Context words for %s:\n" % race1, [[word, "%.5f" % (context_words[race1][word]/total[race1])] for word in atoms_words[list(context)[i]] if word in context_words[race1].keys()])
            print("Context words for %s:\n" % race2, [[word, "%.5f" % (context_words[race2][word]/total[race2])] for word in atoms_words[list(context)[i]] if word in context_words[race2].keys()])
            print('\n')

            