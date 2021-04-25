#####################################################
# Data visualizations and Measurements for Chapter 4
#####################################################

setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter4")
library(ggplot2)
library(plotrix)
library(openxlsx)
library(plyr)
library(tidyverse)

##############
# Figure 4.2
##############

#read in book level predictions for given genre
book_preds <- read.csv("./Results/average_scores_inovel.csv")
rownames(book_preds) <- book_preds[,1]

#tiff('Fig4.2.tiff', 
#     height = 4, width = 8, units = 'in', compression = 'none', res = 400)

plot(book_preds$PUBL_DATE,book_preds$average_score, pch=16, xlab="Publication Date", 
     ylab="SOC Proximity Score (SOC = 0)", ylim=c(.3, 1))
abline(a=.5, b=0, lty=2,col="dark grey")  #draw a line at the probability threshold

#label only those points near the threshold; can adjust threshold based on results
with(subset(book_preds,average_score<=.8), 
     thigmophobe.labels(PUBL_DATE, average_score, 
                        row.names(subset(book_preds,average_score<=.8)), offset=.5, cex= 0.7))

#dev.off()

#########################################
# Analysis of Predictions on All Fiction
#########################################

pred_books <- openxlsx::read.xlsx("Results/average_scores_all_fic.xlsx", sheet= "Sheet 1")
pred_chunks <- openxlsx::read.xlsx("Results/pred_results_all_fic.xlsx", sheet = "Sheet 1")
pred_chunks$SOC = as.factor(pred_chunks$SOC)  #encodes labels as factors (categories)

#having labeled SOC or not based on 0.5 threshold, determine ratio of SOC and non-SOC chunks per year
prop_by_year <- pred_chunks %>%
  group_by(PUBL_DATE) %>%
  count(SOC) %>%
  mutate(prop = prop.table(n))

#"SOC" chunks are 14% of the dataset in 1929 and 1926; considerably lower in most other years

#now group chunk results by year, averaging across all chunks per year
avg_by_year_chunks <- pred_chunks %>%
  group_by(PUBL_DATE) %>%
  summarize(N = mean(score))

#now group results by year, averaging across all books in a given year
avg_by_year_books <- pred_books %>%
  group_by(PUBL_DATE) %>%
  summarize(N = mean(average_score))

#compute sd on each book
pred_books_2 = sapply(unique(pred_chunks$TITLE), function(name) sd(pred_chunks$score[pred_chunks$TITLE==name]))
names(pred_books_2) = unique(pred_chunks$TITLE)
sort(pred_books_2)   #sorts in ascending order

#now get an average on sd
avg_sd_book = data.frame(pred_books_2)
names(avg_sd_book)[1] = "stand_div"
#attach the publication dates
avg_sd_book$PUBL_DATE = pred_chunks[match(rownames(avg_sd_book), pred_chunks$TITLE),"PUBL_DATE"]

avg_sd_book <- avg_sd_book %>%
  group_by(PUBL_DATE) %>%
  summarize(N = mean(stand_div))

#invert the average for graphing purposes
avg_by_year_books$avg <- 1 - avg_by_year_books$N
avg_by_year_chunks$avg <- 1 - avg_by_year_chunks$N

##############
# Figure 4.3
##############

#plot the average per book
ggplot(data = avg_by_year_books, mapping = aes(x = factor(PUBL_DATE), y = avg, group = 1)) +
  scale_x_discrete(breaks=c(1925,1930,1935,1940)) +
  geom_point(shape=16, size=2) +
  stat_smooth(colour="grey", se=FALSE) +
  xlab("") + ylab("Mean SOC Proximity Score") +
  theme(axis.text=element_text(size=12))
#ggtitle(plot_title) +
#theme(plot.title = element_text(color="black", size=14, face="bold.italic", hjust=0.5, family = 'Arial Unicode MS'))

##############
# Figure 4.4
##############

#violin plots for each year to show distribution

#factor the dates and invert scores
pred_books$PUBL_DATE = as.factor(pred_books$PUBL_DATE)  #encodes labels as factors (categories)
pred_books$inv_average_score <- 1 - pred_books$average_score
pred_books$group <- pred_books$PUBL_DATE  == 1929  #create boolean variable for coloring purposes

ggplot(data = pred_books, mapping = aes(PUBL_DATE, inv_average_score, fill = group)) +
  geom_violin(draw_quantiles = c(0.75)) + 
  stat_summary(fun.y=mean, geom="point", shape=20, size=3, color="black", fill="black") +
  scale_fill_manual(values=c("white", "lightgrey")) +
  xlab("") + ylab("SOC Proximity Score") +
  theme(legend.position = "", axis.text=element_text(size=10)) #+
  #geom_jitter(color="black", size=0.4, alpha=0.9)  #use this to show underlying data points
