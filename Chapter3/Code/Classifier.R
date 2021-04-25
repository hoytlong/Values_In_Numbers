##############################################
# Code for Logistic Regression Classification
##############################################

#Set working directory and load libraries
setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter3")
library(scales)
library(bestglm)
library(plyr)
library(tidyverse)

####################################
# Classification for Japanese Texts
####################################

#Load data
meta_jp <- openxlsx::read.xlsx("./Results/all_extracted_features.xlsx", sheet = "Sheet 1")

#Reduce to 2 genres for comparison; factorize and alphabetically sort the GENRE labels
meta_jp <- meta_jp %>% filter(GENRE != "JUNBUNGAKU")  #filtering out works of this genre type
meta_jp$GENRE = as.factor(as.character(meta_jp$GENRE))

###########
# Model #1
###########

# Prepare binary classifier with desired features and fit the model
X = meta_jp[, c("ttr_mean", "ttr_cumsum", "ttr_sd", "ent_mean", "ent_cumsum", "ent_sd", "YulesK", "GuiraudC", "nonpara_ent")]
y = ifelse(meta_jp$GENRE=="SHISHOSETSU",TRUE,FALSE)
Xy = cbind(X,y)
fit.best = bestglm(Xy,family=binomial,IC="CV")

# inspect the best model (this gives you the subset of features with best classification results)
summary(fit.best$BestModel)

# Perform ten-fold cross validation to get accuracy estimate on the "best" features
model = fit.best$BestModel$model
n = nrow(model)
m = 10	# number of folds
set.seed(1)
ind = sample(rep(1:m, c(rep(ceiling(n/m), m-n%%m), rep(floor(n/m), n%%m))))	# indices for folds
p0 = 0.4
confusion = matrix(0, 2, 2)
for (i in 1:m) {
	fit = glm(y~., family=binomial, data=model, subset=which(ind!=i))
	phat = predict(fit, newdata=model[ind==i, ], type="response")
	confusion = confusion + table(model$y[ind==i], as.numeric(phat>p0))
}
# estimate of accuracy by cross validation
accuracy = sum(diag(confusion))/(sum(confusion))
print(accuracy*100)
# estimate of confusion matrix
rownames(confusion) = c("Popular", "Shishosetsu")
colnames(confusion) = c("Popular", "Shishosetsu")
print(confusion/m)

# Produce correlation matrix of features in the model
pdf("Results/Model1_pairs_jp.pdf", height=10, width=10)
pairs(model, pch=16, col=model$y+1)
dev.off()

### model 1: 64% accuracy

#Coefficients:
#             Estimate Std. Error z value Pr(>|z|)   
# (Intercept)  -5.75353    4.61202  -1.248  0.21221   
# ttr_mean    -23.65201   10.22507  -2.313  0.02072 * 
# YulesK        0.04885    0.01528   3.196  0.00139 **
# nonpara_ent   1.63441    0.52103   3.137  0.00171 **


###########
# Model #2
###########

# Prepare binary classifier with desired features and fit the model
X = meta_jp[, c("ttr_mean", "ttr_cumsum", "ttr_sd", "ent_mean", "ent_cumsum", "ent_sd", "YulesK", "GuiraudC", "nonpara_ent",
                "period", "punct", "stopword", "pronouns", "thought", "conjuncts")]  
y = ifelse(meta_jp$GENRE=="SHISHOSETSU",TRUE,FALSE)
Xy = cbind(X,y)
fit.best = bestglm(Xy,family=binomial,IC="CV")

# inspect the best model (this gives you the subset of features with best classification results)
summary(fit.best$BestModel)

# Perform ten-fold cross validation to get accuracy estimate on the "best" features
model = fit.best$BestModel$model
n = nrow(model)
m = 10	# number of folds
set.seed(1)
ind = sample(rep(1:m, c(rep(ceiling(n/m), m-n%%m), rep(floor(n/m), n%%m))))	# indices for folds
p0 = 0.4
confusion = matrix(0, 2, 2)
for (i in 1:m) {
  fit = glm(y~., family=binomial, data=model, subset=which(ind!=i))
  phat = predict(fit, newdata=model[ind==i, ], type="response")
  confusion = confusion + table(model$y[ind==i], as.numeric(phat>p0))
}
# estimate of accuracy by cross validation
accuracy = sum(diag(confusion))/(sum(confusion))
print(accuracy*100)
# estimate of confusion matrix
rownames(confusion) = c("Popular", "Shishosetsu")
colnames(confusion) = c("Popular", "Shishosetsu")
print(confusion/m)

# Produce correlation matrix of features in the model
pdf("Results/Model2pairs_jp.pdf", height=10, width=10)
pairs(model, pch=16, col=model$y+1)
dev.off()

### model 2: 82% accuracy

#Coefficients:
#             Estimate Std. Error z value Pr(>|z|)    
#(Intercept)   -0.292      1.158  -0.252 0.800892    
# ttr_sd      -119.377     41.360  -2.886 0.003898 ** 
# pronouns       5.896      1.691   3.487 0.000488 ***
# thought      811.620    189.688   4.279 1.88e-05 ***
# conjuncts    -16.349      4.358  -3.752 0.000176 ***

######################################################################
# Produce graphical representation of logistic regression predictions
######################################################################

v = 0.003
sep = " "
phat = fitted(fit.best$BestModel)  #be sure to verify which model you are using

#produce list of ordered, jittered titles for I-novels
phat1 = phat[meta_jp$GENRE=="SHISHOSETSU"]
phat1 = phat1[order(phat1, decreasing=TRUE)]
title1 = as.character(meta_jp[as.numeric(names(phat1)), "ROMANIZED_TITLE"])
title1 = unlist(lapply(lapply(lapply(title1, FUN = strsplit, split=" "), FUN = unlist), paste, collapse = "_"))

for (i in 2:length(phat1)) {
	if (any(abs(phat1[i]-phat1[1:(i-1)])<v)) {
		title1[i] = paste0(c(title1[i], rep(sep, 2+max(nchar(title1[1:(i-1)][abs(phat1[i]-phat1[1:(i-1)])<v])))), collapse="")
		print(title1[i])
	}
}

#produce list of ordered, jittered titles for Popular
phat0 = phat[meta_jp$GENRE!="SHISHOSETSU"]
phat0 = phat0[order(phat0, decreasing=TRUE)]
title0 = as.character(meta_jp[as.numeric(names(phat0)), "ROMANIZED_TITLE"])
title0 = unlist(lapply(lapply(lapply(title0, FUN = strsplit, split=" "), FUN = unlist), paste, collapse = "_"))
  
for (i in 2:length(phat0)) {
	if (any(abs(phat0[i]-phat0[1:(i-1)])<v)) {
		title0[i] = paste0(c(rep(sep, 2+max(nchar(title0[1:(i-1)][abs(phat0[i]-phat0[1:(i-1)])<v]))), title0[i]), collapse="")
		print(title0[i])
	}
}

#output to PDF; be sure to change filename to reflect which model you are using
pdf("Results/fitted_predictions_model2.pdf", height=15, width=5)
#tiff("Results/fitted_predictions_model2_temp.tiff", units='in',height=15, width=5, res=600)
par(mar=c(4,4,1,2),family="mono")
plot(as.numeric(meta_jp$GENRE), phat, col=alpha("black",0.5), pch=16, ylab="Fitted Probability", xlab="Genre", axes=FALSE, ylim=c(0,1))
axis(side=1, at=c(1,2), labels=levels(meta_jp$GENRE), cex.axis=0.6, las=1)
axis(side=2, cex.axis=0.6)
text(2, phat1, labels=title1, pos=2, cex=0.5)
text(1, phat0, labels=title0, pos=4, cex=0.5)
dev.off()


####################################
# Classification for Chinese Texts
####################################

meta_ch = read.csv("Results/derived_data_ch.csv")

#Factorize and alphabetically sort the GENRE labels
meta_ch$GENRE = as.factor(as.character(meta_ch$GENRE))

# best subset selection
X = meta_ch[, c("thought", "pronouns", "ttr_mean", "ttr_cumsum", "ent_mean", "ent_cumsum", "period", 
                "punct", "stopword", "YulesK", "GuiraudC", "nonpara_ent")]
y = ifelse(meta_ch$GENRE=="ROMANTIC",TRUE,FALSE)
Xy = cbind(X,y)
fit.best = bestglm(Xy, family=binomial, IC="CV")
# the best model
summary(fit.best$BestModel)

model = fit.best$BestModel$model
n = nrow(model)
m = 10	# number of folds
set.seed(1)
ind = sample(rep(1:m, c(rep(ceiling(n/m), m-n%%m), rep(floor(n/m), n%%m))))	# indices for folds
p0 = 0.5
confusion = matrix(0, 2, 2)
for (i in 1:m) {
	fit = glm(y~., family=binomial, data=model, subset=which(ind!=i))
	phat = predict(fit, newdata=model[ind==i, ], type="response")
	confusion = confusion + table(model$y[ind==i], phat>p0)
}
# estimate of accuracy by cross validation
1-sum(diag(confusion))/(sum(confusion))

rownames(confusion) = c("Romantic", "Popular")
colnames(confusion) = c("Romantic", "Popular")
print(confusion/m)

# Produce correlation matrix of features in the model
pdf("pairs_ch.pdf", height=8, width=8)
pairs(model, pch=16, col=model$y+1)
dev.off()

