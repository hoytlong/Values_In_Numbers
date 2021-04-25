chunk <- function(x, nchunks=NULL, chunksize=NULL, remove=NULL) {
  n = length(x)
  if (!is.null(nchunks)) chunksize = floor(n/nchunks)
  else if (!is.null(chunksize)) nchunks = floor(n/chunksize)
  else nchunks = 20; chunksize = floor(n/nchunks)
  if (nchunks==0) {
    chunks = list(x)
    chunks[[1]] = chunks[[1]][!(chunks[[1]] %in% remove)]
  }
  else {
    chunks = list()
    for (i in 1:nchunks) {
      chunks[[i]] = x[((i-1)*chunksize+1):(i*chunksize)]
      chunks[[i]] = chunks[[i]][!(chunks[[i]] %in% remove)]
    }
  }
  return(chunks)
}

dtm <- function(x) {
  vocab = sort(unique(unlist(x)))
  w = matrix(0,nrow=length(x),ncol=length(vocab),dimnames=list(NULL,vocab))
  for (i in 1:length(x)) {
    freq = table(x[[i]])/length(x[[i]])
    w[i,names(freq)] = freq
  }
  return(w)
}

tfidf <- function(x) {
  return(t(t(x)*log(nrow(x)/colSums(x>0))))
}

cumsum_test <- function(x, replicate=100) {
  x = x-mean(x)
  y = sapply(1:replicate,function(i){max(abs(cumsum(sample(x))))})
  return(mean(max(abs(cumsum(x)))<=y))
}

get_chunk <- function(file_name, chunk_no, nchunks=NULL, chunksize=NULL) {
  text = scan(file_name, what="character", sep=" ", quote="", quiet=TRUE)
  text = text[text!=""]
  return(cat(chunk(text,nchunks,chunksize)[[chunk_no]],sep=" "))
}