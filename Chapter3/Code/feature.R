feature_ttr <- function(text, nchunks=NULL, chunksize=NULL, remove=NULL, normalize=FALSE, cumsum=FALSE, replicate=100, return.value=FALSE) {
  chunks = chunk(text, nchunks, chunksize, remove)
  TTR = sapply(1:length(chunks),function(i) length(unique(chunks[[i]]))/length(chunks[[i]]))
  if (return.value) return(TTR)
  features = data.frame(mean=mean(TTR),sd=sd(TTR))
  if (normalize) {
    TTR_norm = mean(sapply(1:replicate,function(i) length(unique(sample(text,length(chunks[[1]]))))/length(chunks[[1]])))
    features$norm = mean(TTR)-TTR_norm
  }
  if (cumsum) features$cumsum = cumsum_test(TTR,replicate=replicate)
  return(features)
}

feature_entropy <- function(text, nchunks=NULL, chunksize=NULL, remove=NULL, normalize=FALSE, cumsum=FALSE, replicate=100, return.value=FALSE) {
  chunks = chunk(text, nchunks, chunksize, remove)
  entropy = sapply(1:length(chunks),function(i) {temp = table(chunks[[i]])/length(chunks[[i]]);sum(-temp*log(temp))} )
  if (return.value) return(entropy)
  features = data.frame(mean=mean(entropy),sd=sd(entropy))
  if (normalize) {
    entropy_norm = mean(sapply(1:replicate, function(i) { temp = table(sample(text,length(chunks[[1]])))/length(chunks[[1]]); sum(-temp*log(temp)) }))
    features$norm = (mean(entropy)-entropy_norm)
  }
  if (cumsum) features$cumsum = cumsum_test(entropy,replicate=replicate)
  return(features)
}

feature_nonpara_entropy <- function(text, N=floor(length(text)*0.9), M=length(text)-N-100) {
  if (length(text)<N+M+100) {
    cat('Invalid window size.')
    return(0)
  }
  lambda = c()
  ii = floor(seq(N+1,length(text)-100,length.out=M))
  for (i in ii) {
    l = -1
    index = (i-N):(i-1)
    while (length(index)>0) {
      l = l+1
      index = index[sapply(index, function(j) text[j+l]==text[i+l])]
    }
    lambda = c(lambda,l)
  }
  return(1/mean(lambda/log(N)))
}