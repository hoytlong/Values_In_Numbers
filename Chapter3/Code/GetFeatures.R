##########################################
# Extract Additional Features from Corpora
##########################################

library(openxlsx)

#Set working directory and load functions from files
setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter3/")
source("Code/utils.R")
source("Code/feature.R")

#Load derived feature data from the Python code
meta_jp <- openxlsx::read.xlsx("./Results/python_extracted_features.xlsx", sheet = "Sheet1")

#Specify new features that will be added
feature_name = c("ttr_mean","ttr_sd","ttr_norm","ttr_cumsum",
                 "ent_mean","ent_sd","ent_norm","ent_cumsum",
                 "nonpara_ent", "period","punct","stopword")

#Add these features to our dataframe
meta_jp = cbind(meta_jp,matrix(0,nrow=nrow(meta_jp),ncol=length(feature_name),dimnames=list(NULL,feature_name)))

#Import Stopword and Punctuation Lists
stopword = list()
stopword$jp = scan("./Stoplists/stopword_jp.txt", what="character", sep=" ", encoding="UTF-8")
punct = list()
punct$jp = scan("./Stoplists/punct_jp.txt", what="character", sep=" ", encoding="UTF-8")

#Set chunksize for feature analysis
chunksize = 1000

##########################################
#Generate Features for the Japanese Corpus
##########################################

cat("Generating features for the Japanese corpus...\n")
pb = txtProgressBar(style=3)
for (i in 1:nrow(meta_jp)) {
  text = scan(paste0("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter3/Texts/",meta_jp$WORK_ID[i],".txt"), what="character", sep=" ", quote="", 
              quiet=TRUE, encoding="UTF-8")
  text = text[text!=""]
  meta_jp[i,c("ttr_mean","ttr_sd","ttr_norm","ttr_cumsum")] = feature_ttr(text, chunksize=chunksize, remove=punct$jp, normalize=TRUE, cumsum=TRUE, replicate=500)
  meta_jp[i,c("ent_mean","ent_sd","ent_norm","ent_cumsum")] = feature_entropy(text, chunksize=chunksize, remove=punct$jp, normalize=TRUE, cumsum=TRUE, replicate=500)
  meta_jp[i,"period"] = mean(text=="。")
  meta_jp[i,"punct"] = mean(text %in% punct$jp)
  meta_jp[i,"stopword"] = mean(text %in% stopword$jp)
  
  #for nonparametric entropy, feed in text as vector of individual Chinese characters, not words
  no_spaces <- paste(text, collapse="")
  char_tokens <- unlist(strsplit(no_spaces, split=""))
  #char_tokens <- char_tokens[! char_tokens %in% punct$jp]  #calculate after removing punctuation
  meta_jp[i,"nonpara_ent"] = feature_nonpara_entropy(char_tokens, 1000, 100)
  
  setTxtProgressBar(pb,i/nrow(meta_jp))
}
close(pb)

cat("Recording chunkwise measurements...\n")
pb = txtProgressBar(style=3)
record_jp = data.frame(file_id=NULL,chunk_no=NULL,ttr=NULL,ent=NULL)
for (i in 1:nrow(meta_jp)) {
  text = scan(paste0("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter3/Texts/",meta_jp$WORK_ID[i],".txt"), what="character", sep=" ", quote="", 
              quiet=TRUE, encoding="UTF-8")
  text = text[text!=""]
  ttr = feature_ttr(text, chunksize=chunksize, remove=punct$jp, return.value=TRUE)
  ent = feature_entropy(text, chunksize=chunksize, remove=punct$jp, return.value=TRUE)
  record_jp = rbind(record_jp,data.frame(file_id=rep(meta_jp$WORK_ID[i],length(ttr)),chunk_no=1:length(ttr),ttr=ttr,ent=ent))
  setTxtProgressBar(pb,i/nrow(meta_jp))
}
close(pb)

###############################
#Output results to .csv files
###############################

openxlsx::write.xlsx(meta_jp, file = "./Results/all_extracted_features.xlsx",row.names=FALSE)
openxlsx::write.xlsx(record_jp,file="./Results/record_jp.xlsx",row.names=FALSE)
