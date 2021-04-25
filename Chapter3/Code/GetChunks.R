############################################
# Code for Extracting Individual Text Chunks
############################################

setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter3")
source('Code/utils.R')
library(openxlsx)
library(plyr)
library(tidyverse)

# For Japanese Corpus
# put the tokenized japanese text files in the directory <path>
path = 'C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter3/Texts/'
record_jp = openxlsx::read.xlsx('Results/record_jp.xlsx', sheet = "Sheet 1")
head(record_jp)

#select by genre
record_jp <- record_jp[which(record_jp$genre=='SHISHOSETSU'),]
dim(record_jp)

# Get chunks within the lowest quartile of mean entropy (approx 600)
# try this with lowest and highest quantile (about 650 chunks on either end)
# just need to filter on quantile values; no need to sort
lower_bound <- quantile(record_jp$ent)[[2]]
low_chunks <- record_jp %>% filter(ent <= lower_bound)

#ind = sort(record_jp$ent,decreasing=FALSE,index.return=TRUE)$ix[1:200]
low_ind = sort(low_chunks$ent,decreasing=FALSE,index.return=TRUE)$ix
sink('./Results/LowEntJP.txt')
for (i in low_ind) {
  temp = low_chunks[i,]
  get_chunk(paste0(path,temp$file_id,'.txt'),temp$chunk_no,chunksize=1000)
  cat('\n\n')
}
sink()

# Get chunks within top quartile of mean entropy (approx 600)
upper_bound <- quantile(record_jp$ent)[[4]]
upper_chunks <- record_jp %>% filter(ent >= upper_bound)

up_ind = sort(upper_chunks$ent,decreasing=TRUE,index.return=TRUE)$ix
sink('./Results/HighEntJP.txt')
for (i in ind) {
  temp = upper_chunks[i,]
  get_chunk(paste0(path,temp$file_id,'.txt'),temp$chunk_no,chunksize=1000)
  cat('\n\n')
}
sink()