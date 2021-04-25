####################################################
# Code for Supervised Classification for Chapter 4 
####################################################

#set the local directory
setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter4")

#load libraries
library(ROCR)
library(e1071)
library(lattice)
library(ggplot2)
library(plyr)
library(tidyverse)
library(plotrix)

###################################
# Prepare Data for Classification
###################################

#read in extracted features data for SOC and Genre-Labeled Texts
alldata <- openxlsx::read.xlsx("Results/AllChunkFeatures.xlsx", sheet = "Sheet1")
#encode genre labels as factors (categories)
alldata$class_labels = as.factor(alldata$class_labels)  

#change ellipses feature to a categorical variable
alldata$ellip_cat[alldata$ellipses == 0] <- 0
alldata$ellip_cat[alldata$ellipses > 0] <- 1
alldata$ellip_cat <- factor(alldata$ellip_cat)
alldata$ellipses <- alldata$ellip_cat
alldata <- subset(alldata, select = -c(ellip_cat) )

##################################################################################
# Classify SOC against other Genres (Repeat with 5 Random Samples of other genre)
#################################################################################

#Subsample the SHISHOSETSU or JUNBUNGAKU chunks to align sample size with SOC
#repeat this procedure 5 times, analyzing the fitted model summary (looking for consistency in model across samples) 
soc_sample <- alldata %>% filter(GENRE == "SOC")
genre_sample <- alldata %>% filter(GENRE == "SHISHOSETSU")  #select GENRE to sample (e.g., SHISHOSETSU, POPULAR, JUNBUNGAKU)

#set random seed
set.seed(998)
#create 5 samples
sample1 <- genre_sample %>% group_by(TITLE) %>% sample_n(size = 4, replace=FALSE) #sample 4 chunks from each Title
soc_genre1 <- bind_rows(soc_sample, sample1)    #merge the SOC and genre sample together
sample2 <- genre_sample %>% group_by(TITLE) %>% sample_n(size = 4, replace=FALSE) #sample 4 chunks from each Title
soc_genre2 <- bind_rows(soc_sample, sample2)    #merge the SOC and genre sample together
sample3 <- genre_sample %>% group_by(TITLE) %>% sample_n(size = 4, replace=FALSE) #sample 4 chunks from each Title
soc_genre3 <- bind_rows(soc_sample, sample3)    #merge the SOC and genre sample together
sample4 <- genre_sample %>% group_by(TITLE) %>% sample_n(size = 4, replace=FALSE) #sample 4 chunks from each Title
soc_genre4 <- bind_rows(soc_sample, sample4)    #merge the SOC and genre sample together
sample5 <- genre_sample %>% group_by(TITLE) %>% sample_n(size = 4, replace=FALSE) #sample 4 chunks from each Title
soc_genre5 <- bind_rows(soc_sample, sample5)    #merge the SOC and genre sample together

#run classification on all features across 5 runs
subsets = list()
subsets[[1]] = -(1:8)				# includes all features

#run the full model on each of the 5 samples and examine summary
fit = glm(class_labels~.,family=binomial(logit),data=soc_genre4[,subsets[[1]]])
# to look at the coefs and p values
summary(fit)

##################################################################################
# Create multiple models to test based on significant features that emerge above
##################################################################################

# set up subsets of features for logistic models, filtering from least to most significant
# choice of subset is based on the p-values of the full model

## For Junbungaku comparison
subsets = list()
subsets[[1]] = -(1:8)				# includes all features
subsets[[2]] = -c(1:8,10,13)			# excluding sent_length, per_pronoun_use
subsets[[3]] = -c(1:8,10,13,14)		# excluding above and per_pronoun_head
subsets[[4]] = -c(1:8,10,13,14,12,17)		# excluding TTR_no_pn and verbless sents
subsets[[5]] = -c(1:8,10,13,14,12,16,20)      #excluding above and ellipses and TTR_no_stopwords
#subsets[[6]] = -c(1:8,10,12,13,14,17)   #excluding all above and verbless_sents

## For Shishosetsu comparison
subsets = list()
subsets[[1]] = -(1:8)				# includes all features
subsets[[2]] = -c(1:8,10,14,12,17)			# excluding sent_length, per_pronoun_head, TTR_no_pn, verbless_sents
subsets[[3]] = -c(1:8,10,14,12,17,16,21)		# excluding above and TTR_no_stop and fid_ratio
subsets[[4]] = -c(1:8,10,14,12,17,16,21,13)		# excluding above and per_pronoun_use
#subsets[[5]] = -c(1:8,10,13,14,12,16,20)      #excluding above and ellipses and TTR_no_stopwords
#subsets[[6]] = -c(1:8,10,12,13,14,17)   #excluding all above and verbless_sents

## For Popular comparison
subsets = list()
subsets[[1]] = -(1:8)				# includes all features
subsets[[2]] = -c(1:8,10,12,21,13)			# excluding sent_length, verbless_sents, fid_ratio, per_pronoun_use
subsets[[3]] = -c(1:8,10,12,21,13,18)		# excluding above and onom
subsets[[4]] = -c(1:8,10,12,21,13,18,17,14)		# excluding above and per_pronoun_head,TTR_no_pn
#subsets[[5]] = -c(1:8,10,13,14,12,16,20)      #excluding above and ellipses and TTR_no_stopwords
#subsets[[6]] = -c(1:8,10,12,13,14,17)   #excluding all above and verbless_sents

## Subsets for degrading model accuracy
subsets = list()
subsets[[1]] = -(1:8)				# includes all features
subsets[[2]] = -c(1:8,11)			
subsets[[3]] = -c(1:8,11,15)	

#OPTIONAL: check for outliers
#finding leverage points
library(gghalfnorm)
gghalfnorm(residuals(fit))

#OPTIONAL: filter outliers based on above test
data <- soc_genre1  #will use this sample from here on out
data <- data[-c(65, 140), ]  #eliminate outliers

##############################################################
# Perform Classification on multiple random samples of Genre
##############################################################

# do some setup for the actual classification 
# number of cross-validations
ntrial = 100

# will record auc (accuracy) for each of the candidate models
auc = list()
auc.book = list()
#construct matrices to house auc values
for (i in 1:length(subsets)) {
	auc[[i]] = numeric(ntrial)
	auc.book[[i]] = numeric(ntrial)
}

set.seed(998)
#for 100 trials, create train and test sets, and then compute chunk-level and book-level predictions
for (count in 1:ntrial) {
	#resample the non-SOC genre each time
  sample <- genre_sample %>% group_by(TITLE) %>% sample_n(size = 4, replace=FALSE) #sample 4 chunks from each Title
  data <- bind_rows(soc_sample, sample)    #merge the SOC and genre sample together
  
  # training, test splitting
	# 12 books for each category in test set
	book.soc = as.character(unique(data$TITLE[data$class_labels==0]))
	book.real = as.character(unique(data$TITLE[data$class_labels==1]))
	book.test = c(sample(book.soc,12),sample(book.real,12))  #train/test split is 90/10
	data.train = data[!data$TITLE %in% book.test,]
	data.test = data[data$TITLE %in% book.test,]
	
	# logistic regression
	for (i in 1:length(subsets)) {
		# fit logistic regression (i=1,2,3,4,5,6,etc for all models)
		fit.logit = glm(class_labels~.,family=binomial(logit),data=data.train[,subsets[[i]]])
		# chunkwise:
		# compute the fitted logit values for the test data (for each chunk)
		pred.logit = predict(fit.logit,data.test[,subsets[[i]]])
		# compute the fitted probabilities (for each chunk)
		pred.logit = exp(pred.logit)/(1+exp(pred.logit))
		# convert NaN values to 1 (these are Inf values that should be 1)
		pred.logit = ifelse(is.nan(pred.logit), 1, pred.logit)
		# compute the auc
		prediction.logit = prediction(pred.logit,data.test$class_labels)
		auc[[i]][count] = performance(prediction.logit,"auc")@y.values[[1]]
		
		# bookwise:
		# compute the average fitted probabilities of 5 chunks in each book
		pred.book = sapply(book.test, function(name) mean(pred.logit[data.test$TITLE==name]))
		# compute the true class
		truth = sapply(book.test, function(name) data.test$class_label[data.test$TITLE==name][1])
		# compute auc
		prediction.logit = prediction(pred.book,truth)
		auc.book[[i]][count] = performance(prediction.logit,"auc")@y.values[[1]]
	}
}

# compute mean auc for the 5 chunkwise models
sapply(1:length(subsets),function(i) mean(auc[[i]]))
# compute mean auc for the 5 bookwise models
sapply(1:length(subsets),function(i) mean(auc.book[[i]]))

#######################################
# Select model to do predictions with
#######################################

# select most accurate model from the above auc summaries (e.g., subset 1, 2, 3, etc)
# re-run classification with the most accurate model on a previous random sample (here I choose first sample)
# NOTE: there will be minor differences in results based on the choice of random sample
fit = glm(class_labels~.,family=binomial(logit),data=soc_genre1[,subsets[[1]]])
# to look at the coefs and p values
summary(fit)

#set "data" variable to random sample of choice
data = soc_genre1

# observe the densities of prediction scores for both classes; useful for choosing decision "threshold" (i.e., SOC or not SOC)
plot(density(fit$fitted[data$class_labels==0]), col="red")
lines(density(fit$fitted[data$class_labels==1]))

# set a threshold; remember there's a tradeoff here between precision and recall
# what you set this to depends on what you want to value in the prediction process
thres = 0.5
# false negatives
sum(data$class_labels==1&fit$fitted<thres)/sum(data$class_labels==1)
# false positives
sum(data$class_labels==0&fit$fitted>thres)/sum(data$class_labels==0)

#the following code is used to grab texts below threshold
#helps to inspect which of the SOC texts are closest to 0
below_thres = cbind(data[,c(2,3)],fit$fitted.values)
names(below_thres)[3] = "score"     #this number needs to match your fitted column
# sort it
below_thres[sort(below_thres$score,index.return=TRUE)$ix,]
below_thres.sorted = below_thres[sort(below_thres$score,index.return=TRUE)$ix,]
# apply the threshold
# chunks that get classified as 1
below_thres.sorted[below_thres.sorted$score>thres,]
# chunks that get classified as 0
below_thres.sorted[below_thres.sorted$score<=thres,]

#create an average score for each text/book, averaging across all chunks 
soc.book = sapply(unique(below_thres$TITLE), function(name) mean(below_thres$score[below_thres$TITLE==name]))
names(soc.book) = unique(below_thres$TITLE)
data.frame(sort(soc.book))   #sorts in ascending order

#############################################################
# Using the fitted model, predict on all passages in a genre
#############################################################

#use all passages from the Genre sampled at the outset (e.g., SHISHOSETSU, POPULAR, JUNBUNGAKU)
newdata <- genre_sample

# predicted score by chunks
pred = predict(fit,newdata)
# transform to probabilities
pred = exp(pred)/(1+exp(pred))
pred = ifelse(is.nan(pred), 1, pred)
# sort it in an increased order
newdata$TITLE[sort(pred, index.return=T)$ix]
# put score alongside the chunkids and titles and publ_dates
result = cbind(newdata[,c(3,6,8)],pred)
names(result)[4] = "score"     #this number needs to match your pred column; renaming as score
# sort it
result[sort(result$score,index.return=TRUE)$ix,]
result.sorted = result[sort(result$score,index.return=TRUE)$ix,]
# apply the threshold
# chunks that get classified as 1
result.sorted[result.sorted$score>thres,]
# as 0
result.sorted[result.sorted$score<=thres,]

mean(result.sorted$score)  #get the average score for all chunks
#0.8795594 for JUNBUNGAKU
#0.9122635 for SHISHOSETSU
#0.8389446 for POPULAR

#create an average score for each text, averaging across all chunks 
pred.book = sapply(unique(result$TITLE), function(name) mean(result$score[result$TITLE==name]))
names(pred.book) = unique(result$TITLE)
sort(pred.book)   #sorts in ascending order

book_preds = data.frame(pred.book)
names(book_preds)[1] = "average_score"
#attach the publication dates
book_preds$PUBL_DATE = result[match(rownames(book_preds), result$TITLE),"PUBL_DATE"]

#save the data for closer analysis and for visualizations; change file names based on genre
#these are predictions on all passages
write.csv(result, file = "Results/pred_results_inovel.csv")
#these are the averaged scores for titles
write.csv(book_preds, file = "Results/average_scores_inovel.csv")

######################################################
# Using Fitted Model, predict on Larger Fiction Corpus
######################################################

#need to use a sample from the "Popular" genre for fitting the model
genre_sample <- alldata %>% filter(GENRE == "POPULAR")
#set random seed
set.seed(998)
sample1 <- genre_sample %>% group_by(TITLE) %>% sample_n(size = 4, replace=FALSE) #sample 4 chunks from each Title
soc_genre1 <- bind_rows(soc_sample, sample1)    #merge the SOC and genre sample together

#fit the full model on first sample of POPULAR fiction, using model 1
fit = glm(class_labels~.,family=binomial(logit),data=soc_genre1[,subsets[[1]]])
# to look at the coefs and p values
summary(fit)

#read in processed fiction chunks
newdata <- openxlsx::read.xlsx("Results/FicChunkFeatures.xlsx", sheet = "Sheet1")
#encode labels as factors (categories)
newdata$class_labels = as.factor(newdata$class_labels)  

#change ellipses feature to a categorical variable
newdata$ellip_cat[newdata$ellipses == 0] <- 0
newdata$ellip_cat[newdata$ellipses > 0] <- 1
newdata$ellip_cat <- factor(newdata$ellip_cat)
newdata$ellipses <- newdata$ellip_cat
newdata <- subset(newdata, select = -c(ellip_cat) )

#use fitted model and predict on all chunks in Fiction corpus
# predicted score by chunks
pred = predict(fit,newdata)
# transform to probabilities
pred = exp(pred)/(1+exp(pred))
pred = ifelse(is.nan(pred), 1, pred)
# sort it in an increased order
newdata$TITLE[sort(pred, index.return=TRUE)$ix]
# put score alongside the chunkids and titles and publ_dates
result = cbind(newdata[,c(3,6,8)],pred)
names(result)[4] = "score"     #this number needs to match your pred column; renaming as score

# sort it
result[sort(result$score,index.return=TRUE)$ix,]
result.sorted = result[sort(result$score,index.return=TRUE)$ix,]
# apply the threshold
# chunks that get classified as 1
result.sorted[result.sorted$score>thres,]
# as 0
result.sorted[result.sorted$score<=thres,]

mean(result.sorted$score)  #get the average score for all chunks
#0.8959

#create an average score for each text, averaging across all chunks 
pred.book = sapply(unique(result$TITLE), function(name) mean(result$score[result$TITLE==name]))
names(pred.book) = unique(result$TITLE)
sort(pred.book)   #sorts in ascending order

test = data.frame(pred.book)
names(test)[1] = "average_score"
#attach the publication dates
test$PUBL_DATE = result[match(rownames(test), result$TITLE),"PUBL_DATE"]

# Save prediction results to an excel file
openxlsx::write.xlsx(result, file = "pred_results_all_fic.xlsx", fileEncoding="UTF-8")
#these are the averaged scores on book titles (use this for the plot above)
openxlsx::write.xlsx(test, file = "average_scores_all_fic.xlsx", fileEncoding="UTF-8", rowNames = TRUE)

###########################################################
# Further Analysis of Prediction Results on Fiction Corpus
###########################################################

# group results by year, averaging across all books in a given year
test2 <- test %>%
  group_by(PUBL_DATE) %>%
  summarize(N = mean(average_score))

# group chunk results by year, averaging across all chunks per year
test3 <- result %>%
  group_by(PUBL_DATE) %>%
  summarize(N = mean(score))

#compute sd on each book
pred.book2 = sapply(unique(result$TITLE), function(name) sd(result$score[result$TITLE==name]))
names(pred.book2) = unique(result$TITLE)
sort(pred.book2)   #sorts in ascending order

#now get an average on sd
test4 = data.frame(pred.book2)
names(test4)[1] = "stand_div"
#attach the publication dates
test4$PUBL_DATE = result[match(rownames(test4), result$TITLE),"PUBL_DATE"]

test5 <- test4 %>%
  group_by(PUBL_DATE) %>%
  summarize(N = mean(stand_div))

plot(test4$PUBL_DATE,test4$stand_div, pch=16, xlab="Publication Date", 
     ylab="SD of Probability Score", ylim=c(min(test4$stand_div), max(test4$stand_div)))

test4 %>% filter(stand_div > (3 * sd(stand_div)))

#there doesn't appear to be a temporal trend