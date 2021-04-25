"""
Find pair-wise significantly different semantic clusters ("atoms") across races.
Clusters created by kmeans-free clustering and distance matrix built with 20 bootstrap word2vec results.
Usage:
    python3 Cluster_Detection_Fic.py --thres 0.69 --num_test 5000 --window_size 20 --alpha 0.1 --overlap_percent 0.5
Input files and directories can be changed in the second part of the main() function. 
"""

# load libraries and functions
from utils import * 

def build_distance_matrix(word_vec_file, word_vec_bootstrap_folder, size_atom = 5000):
    """
    calculate distance matrix between atom words and vocabulary, averaged over multiple bootstrap replicates of word2vec fits
    - input:
        word_vec_file               txt file containing word2vec result fitted on the original corpus
        word_vec_bootstrap_folder   folder with txt files containing word2vec results fitted on the bootstrapped corpus
        size_atom                   number of atoms to fit
    - output:
        atoms
        vocab
        dist_matrix
    - input example:
        size_atom = 5000
        word_vec_file = './results/word2vec.txt'
        word_vec_bootstrap_folder = './results/word2vec_bootstrap/'
    """
    # load vocabulary based on the orignial word2vec result
    with open(word_vec_file, 'r', encoding = 'utf-8') as f:
        vocab = [line.split(' ')[0] for line in f.readlines()][1:]
    # vocabulary as a set, for fast intersection operation
    vocab_set = set(vocab)
    # iterate through the bootstrap results and get a common vocabulary shared across the word2vec results
    for word_vec_bootstrap_file in os.listdir(word_vec_bootstrap_folder):
        if not word_vec_bootstrap_file.endswith(".txt"):
            continue
        with open(os.path.join(word_vec_bootstrap_folder, word_vec_bootstrap_file), 'r', encoding = 'utf-8') as f:
            vocab_temp = [line.split(' ')[0] for line in f.readlines()][1:]
        vocab_set = vocab_set.intersection(set(vocab_temp))
    # update the vocabulary list
    vocab = [word for word in vocab if word in vocab_set]
    # set the first size_atom many of word in the vocabulary as the atom words
    atoms = vocab[:size_atom]
    # initialize the distance matrix 
    dist_matrix = np.zeros((len(atoms), len(vocab)))
    # iterate through the bootstrap word2vec fits
    for word_vec_bootstrap_file in os.listdir(word_vec_bootstrap_folder):
        if not word_vec_bootstrap_file.endswith(".txt"):
            continue
        with open(os.path.join(word_vec_bootstrap_folder, word_vec_bootstrap_file), 'r', encoding = 'utf-8') as f:
            vocab_temp = [line.split(' ')[0] for line in f.readlines()][1:]
        # load the word vectors
        word_vec = np.genfromtxt(os.path.join(word_vec_bootstrap_folder, word_vec_bootstrap_file), skip_header = 1)[:,1:]
        # normalize them to have unit l2-norm
        word_vec = normalize(word_vec, axis = 1, norm = 'l2')
        # subset to the atoms
        atom_vec = pd.DataFrame(word_vec.transpose(), columns = vocab_temp)[atoms]
        # subset to the common vocabulary
        word_vec = pd.DataFrame(word_vec.transpose(), columns = vocab_temp)[vocab]
        # update the distance matrix
        dist_matrix += np.matmul(atom_vec.transpose(), word_vec)
    # take average
    dist_matrix /= dist_matrix[0, 0]
    return atoms, vocab, dist_matrix

def get_significant_atoms_kmeans_free(race1, race2, atoms, vocab, dist_matrix, context_table, thres, overlap_percent, alpha, num_test):
    total1 = context_table.sum(1)[race1]
    total2 = context_table.sum(1)[race2]
    # build context table for atoms
    context_table_atoms = pd.DataFrame(np.matmul(context_table, ((dist_matrix >= thres) * 1).transpose()), columns = atoms)
    context_table_atoms.index = context_table.index
    # get p values
    pval = rank_context(context_table_atoms, race1, race2)
    pval_argsort = np.argsort(pval)
    # context_atoms stores significant atoms
    context_atoms = []
    context_atoms_word_pct1 = []
    context_atoms_word_pct2 = []
    for i in range(0, num_test):
        # if p value greater than alpha/num_test, then stop (Bonferroni correction)
        if pval[pval_argsort[i]] > alpha/num_test:
            break
        # words in the current atom
        temp = [vocab[j] for j in np.where(dist_matrix[:, pval_argsort[i]] >= thres)[0]]
        temp_wp1 = context_table.loc[race1, temp] / total1
        temp_wp2 = context_table.loc[race2, temp] / total2
        # detect if atom already in the list
        flag_new_atoms = True
        for j in range(len(context_atoms)):
            # if overlapping more than overlap_percent, don't include it as a new atom
            if len(set(temp).intersection(set(context_atoms[j]))) / min(len(temp), len(context_atoms[j])) > overlap_percent:
            #if set(temp).intersection(set(context_atoms[j])):
                flag_new_atoms = False
                if len(temp) < len(context_atoms[j]):
                    context_atoms[j] = temp
                    context_atoms_word_pct1[j] = temp_wp1
                    context_atoms_word_pct2[j] = temp_wp2
                break
        if flag_new_atoms:
            context_atoms.append(temp)
            context_atoms_word_pct1.append(temp_wp1)
            context_atoms_word_pct2.append(temp_wp2)
    return context_atoms, context_atoms_word_pct1, context_atoms_word_pct2

def main():
    # read and set up parameters 
    parser = argparse.ArgumentParser(description = "Set up parameters")
    parser.add_argument('--thres', type = float, dest = 'thres', default = 0.7, help = 'threshold for similarity')
    parser.add_argument('--num_test', type = int, default = 5000, help = 'number of tests')
    parser.add_argument('--window_size', type = int, default = 30, help = 'window size')
    parser.add_argument('--alpha', type = float, default = 0.1, help = 'significance level')
    parser.add_argument('--overlap_percent', type = float, default = 0.5, help = 'threshold over which two atoms will be declared as identical')
    args = parser.parse_args()
    thres = args.thres
    num_test = args.num_test
    alpha = args.alpha
    window_size = args.window_size
    overlap_percent = args.overlap_percent

	#find directory path of current folder
    folder_path = os.path.abspath("Cluster_Detection_Fic.py" + "/../../")

    # set up file names and directory
    word_vec_bootstrap_folder = folder_path + '\\results_fic_bootstrap\word2vec_bootstrap\\' # folder containing bootstrap results
    word_vec_file = folder_path + '\\results_fic_bootstrap\word2vec.txt' # word2vec fit on the original corpus
    corpus_dir = folder_path + '\\Corpora\FictionW2VPreProcessed\\' # corpus folder
    markers = ['朝鮮人', '中国人', '西洋人', '日本人', '黒人', '部落民', '土人', '東洋人', '外国人']
    result_file = folder_path + '\\results_fic_bootstrap\kfree_thres%.2f_numtest%s_window%s_alpha%.2f_overlap_percent%.2f.txt' # output file name format

    # build distance matrix from bootstrap results
    print('Creating distance matrix...')
    atoms, vocab, dist_matrix = build_distance_matrix(word_vec_file, word_vec_bootstrap_folder, num_test)

    # build context table
    print('Creating context table...')
    corpus= read_corpus(corpus_dir)
    texts = [text for text in corpus.text]
    context_table = build_context_table_all(texts = texts, markers = markers, vocab = vocab, window_size = window_size, separate = None, one_per_text = False)
    context_table = context_table.append(get_word_count(texts = texts, vocab = vocab))

    # find pairwise significant atoms
    print('Writing significant atoms...')
    f = open(result_file % (thres, num_test, window_size, alpha, overlap_percent), 'w', encoding = 'utf-8')
    for race1 in markers + ['total']:
        for race2 in markers + ['total']:
            if race1 == race2:
                continue
            f.write("Atoms that appear significantly more frequently around %s than %s:\n" %(race1, race2))
            sig_atoms, wp1, wp2 = get_significant_atoms_kmeans_free(race1, race2, atoms, vocab, dist_matrix, context_table, thres = thres, overlap_percent = overlap_percent, alpha = alpha, num_test = num_test)
            for i in range(len(sig_atoms)):
                f.write('- ')
                for j in range(len(sig_atoms[i])):
                    f.write('%s(%.5f, %.5f) ' %(sig_atoms[i][j], wp1[i][j], wp2[i][j]))
                f.write('\n')
            f.write('\n')
        f.write('\n')
    f.close()

if __name__ == "__main__":
    main()
