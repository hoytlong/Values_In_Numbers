#######################################################
# Code for Boxplots and T-Tests for Feature Comparison
#######################################################

setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter3")
library(e1071)
library(ggplot2)
library(openxlsx)

#Load Derived Features
data_jp <- openxlsx::read.xlsx("./Results/all_extracted_features.xlsx", sheet = "Sheet 1")

###################################################
# Basic scripts to produce graphs for Chapter 3
###################################################

#use this if you want to print boxplots side by side
par(mfrow = c(1,2))

p <- ggplot(data_jp, aes(factor(narrator), third_per))
p + labs(title = "Percent Dialogue") + 
  theme(legend.position = "none", axis.title.x = element_blank(), axis.title.y = element_blank(),
        plot.title = element_text(size=20)) +
  geom_boxplot(aes(fill = factor(narrator)), notch = TRUE, outlier.colour = "red", outlier.size = 2)

#violin plots
p <- ggplot(data_jp, aes(factor(GENRE), ent_mean))
p + geom_violin(aes(fill = factor(GENRE)), scale = "count") #+ geom_jitter(height = 0)

####################################################################
# Use Boxplots and T-tests to compare distribution of features

### 1
boxplot(ttr_mean~GENRE, data_jp, main="Type Token Ratio")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$ttr_mean,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.0048

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$ttr_mean,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.57

#### 2
boxplot(ent_mean~GENRE, data_jp, main="Mean Entropy")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$ent_mean,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.0031

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$ent_mean,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.69

#### 3
boxplot(nonpara_ent~GENRE, data_jp, main="Nonpara Ent")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$nonpara_ent,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.53

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$nonpara_ent,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.64

#### 4
boxplot(GuiraudC~GENRE, data_jp, main="Guiraud C")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$GuiraudC,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.012

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$GuiraudC,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.46

#### 5
boxplot(YulesK~GENRE, data_jp, main="Yules K")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$YulesK,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.000

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$YulesK,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.85

#### 6
boxplot(ent_cumsum~GENRE, data_jp, main="Ent Cumsum")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$ent_cumsum,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.14

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$ent_cumsum,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.79

#### 7a
boxplot(ent_sd~GENRE, data_jp, main="Ent SD")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$ent_sd,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.001

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$ent_sd,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.95

#### 7b
boxplot(ttr_sd~GENRE, data_jp, main="TTR SD")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$ttr_sd,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.000

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$ttr_sd,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.69

#### 8
boxplot(dialogue~GENRE, data_jp, main="Dialogue")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$dialogue,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.000

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$dialogue,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.056

#### 9
boxplot(pronouns~GENRE, data_jp, main="Pronouns")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$pronouns,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.000

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$pronouns,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.0085

#### 10
boxplot(thought~GENRE, data_jp, main="Thought/Feeling")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$thought,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.000

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$thought,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.47

#### 11
boxplot(stopword~GENRE, data_jp, main="Stopwords")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$stopword,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.00057

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$stopword,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.54

#### 12
boxplot(ttr_cumsum~GENRE, data_jp, main="TTR Cumsum")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$ttr_cumsum,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.02

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$ttr_cumsum,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.12

#### 13
boxplot(punct~GENRE, data_jp, main="Punctuation")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$punct,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.000

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$punct,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.49

#### 14
boxplot(conjuncts~GENRE, data_jp, main="Conjunctions")
pairwise.t.test(subset(data_jp, GENRE!="JUNBUNGAKU")$conjuncts,
                subset(data_jp, GENRE!="JUNBUNGAKU")$GENRE,p.adjust="bonferroni")  #.81

pairwise.t.test(subset(data_jp, GENRE!="POPULAR")$conjuncts,
                subset(data_jp, GENRE!="POPULAR")$GENRE,p.adjust="bonferroni")     #.49

