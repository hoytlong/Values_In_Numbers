#################################################################
# Code for figures and analysis in Chapter 2 (Archive and Sample)
#################################################################

#set working directory to local folder
setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter2")

#load libraries
library(ggplot2)
library(scales)
library(openxlsx)
library(plyr)
library(tidyverse)
library(reshape2)
library(directlabels)
library(readr)
library(ggrepel)
library(spatstat)
library(e1071)
library(ggrepel)
#library(dplyr)

###############################
# Analysis of Aozora Metadata
###############################

#read in complete corpus metadata
meta <- openxlsx::read.xlsx("Data/Corpus_Metadata_Clean.xlsx", sheet = 1)

#filter out by source to get just Aozora texts
meta <- meta %>% filter(SOURCE == "aozora")

#filter out duplicate texts
meta <- meta %>% filter(is.na(DUPE))

#######################################################
#analyze the NDC codes (figure not included in chapter)
#######################################################
unique(meta$GENRE)

#get counts of all genre types
tbl <- count(meta, GENRE)
tbl

#bar chart of genre breakdown
sort.tbl <- as.data.frame(tbl[order(tbl$n, decreasing = TRUE),])
genres <- sort.tbl$GENRE
p <- ggplot(sort.tbl, aes(GENRE, n, fill=GENRE, label=GENRE)) + geom_bar(width=.4, show.legend=FALSE, stat="identity")
p + scale_x_discrete(limits = genres) + labs(x = "NDC Classification", y = "Number of Texts") +
  geom_text(vjust=0, hjust=0, angle=45, size=5, position = position_jitter(width=0, height=0)) +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
  expand_limits(x = c(0, 20), y = c(0, 6000))

#examine genre breakdown for all works tagged as "juvenile"
juvenile <- meta %>% filter(SUBGENRE == "Juvenile")
count(juvenile, GENRE)

#determine unique number of authors
length(unique(meta$AUTHOR_ID))

#########################################
# Analyze text length (Figures 2.1, 2.2)
#########################################

#calculate summary statistics
mean(meta$TEXT_LENGTH, na.rm=TRUE)
median(meta$TEXT_LENGTH, na.rm=TRUE)
sd(meta$TEXT_LENGTH, na.rm=TRUE)
boxplot(meta$TEXT_LENGTH, na.rm=TRUE)

#sort by text length
lengths <- meta[with(meta, order(-TEXT_LENGTH)), ]
#add rank index
lengths$RANK <- 1:nrow(lengths)

#############
# Figure 2.1
#############

#plot the text length by rank number
p <- ggplot(lengths, aes(RANK, TEXT_LENGTH))
p + geom_point(size=.2) +
  xlab("Rank Order of Texts") + ylab("Text Length (in Characters)") +
  scale_y_continuous(labels = comma) +
  theme(plot.margin=unit(c(.2,.7,.2,.2),"cm")) +
  theme(legend.position = "", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

#############
# Figure 2.2
#############

#plot a histogram to show distribution of text lengths for FICTION
fict <- meta %>% filter(GENRE == "Fiction")
fict <- fict %>% filter(TEXT_LENGTH < 500000) #filter out the very longest texts
p <- ggplot(data = fict, aes(x = TEXT_LENGTH))
p + geom_histogram(bins=200) + 
  geom_vline(aes(xintercept=median(TEXT_LENGTH)), color="black", linetype="dashed", size=.5) +
  xlab("Text Length (in Characters)") + ylab("Number of Texts") +
  scale_x_continuous(labels = comma) +
  geom_text(aes(x=median(TEXT_LENGTH), label="\nMedian Length", y=500), colour="black", 
            angle=90, text=element_text(size=10)) +
  theme(plot.margin=unit(c(.2,.3,.2,.2),"cm")) +
  theme(legend.position = "", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

###########################
# Analyze Translation Data
###########################

#read in metadata for translations in Aozora corpus
trans_meta <- openxlsx::read.xlsx("Data/AozoraLiteraryTranslations.xlsx", sheet = 1)
trans_meta$FULL_NAME <- paste(trans_meta$AUTHOR_LAST, trans_meta$AUTHOR_FIRST, sep = "_")

#get counts of authors
auth_counts <- count(trans_meta, FULL_NAME)

#get total number of authors
length(unique(trans_meta$FULL_NAME))

###############################################################
# Analyze Bibliographic Data for Translations (Fig. 2.3 ~ 2.8)
###############################################################

#read in translation metadata
trans_meta <- openxlsx::read.xlsx("Data/MasterListFinal.xlsx", sheet = 1)

#filter out zenshu volumes
trans_meta <- trans_meta %>% filter(is.na(ENTRY_TYPE))

#filter out entries with no publication dates
trans_meta <- trans_meta %>% filter(!is.na(PUBL_START))

#create subset with just Taisho/Showa data
TS_meta <- trans_meta %>% filter(INDEX == "NDL_TS")

##############
# Figure 2.3
##############

#show temporal distribution as line (splitting the Meiji and Taisho/Showa data)
type_year <- trans_meta %>%
  group_by(PUBL_START, INDEX) %>%
  summarize(N = length(TITLE))

p <- ggplot(data = type_year, mapping = aes(x = PUBL_START, y = N, color = INDEX))
p + geom_line(mapping = aes(group = INDEX), size=1) +
  scale_x_continuous(breaks = c(1870,1880,1890,1900,1910,1920,1930,1940,1950,1960)) +
  labs(x="", y="Number of Translations", color = "", title="") +
  scale_color_manual(labels = c("MEIJI", "NDL_TS"), values = c("darkgrey", "black")) +
  theme(legend.position = "top", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

##############
# Figure 2.4
##############

#Import yearly publication data obtained from Shuppan Nenkan
shuppan <- openxlsx::read.xlsx("Data/Shuppan_Nenkan_Data.xlsx", sheet = 1)

#Add book amounts to newspaper/magazine amounts for Meiji period
shuppan$TOTALS <- shuppan$TOTAL_BOOKS + shuppan$NEWS_MAGS

#Get yearly counts for translation metadata, divided by period
year_counts <- trans_meta %>%
  group_by(PUBL_START, INDEX) %>%
  summarize(N = length(TITLE))

year_counts <- as.data.frame(year_counts)

#cutoff first 14 rows of shuppan, since we don't have data for that period
shuppan <- shuppan[14:88,]
#make yearly count data parallel to shuppan data
year_counts <- year_counts[12:86,]

#merge total publications with translation counts
year_counts$TOTALS <- shuppan$TOTALS
#calculate ratio
year_counts$ratio <- year_counts$N / year_counts$TOTALS

#replace missing years with NA
year_counts[year_counts==Inf]<-NA

#produce moving average of the ratio
ratio_movavg <- year_counts %>%
  mutate(lag1 = lag(ratio),
         lag2 = lag(ratio,2),
         movavg = ((lag1+lag2)/2) * 100)

#a transformation function
scaleFUN <- function(x) sprintf("%.1f", x)

#plot the results up to 1943
p <- ggplot(data = ratio_movavg[ratio_movavg$PUBL_START < 1943,], mapping = aes(x = PUBL_START, y = movavg, color=INDEX))
p + geom_line(mapping = aes(group = INDEX), size=1) +
  scale_x_continuous(breaks = c(1880,1890,1900,1910,1920,1930,1940)) +
  scale_y_continuous(labels=scaleFUN) +
  labs(x="", y="Percent of Total Publications", color = "", title="") +
  scale_color_manual(labels = c("MEIJI", "NDL_TS"), values = c("darkgrey", "black")) +
  theme(legend.position = "top", axis.text=element_text(size=12), title=element_text(size=12))

##################################################
# Figure 2.5 (working with just Taisho-Showa Data)
##################################################

#filter for titles where author birth is known and author has 3 or more titles
meta_birth <- TS_meta %>% filter(!is.na(AUTH_BIRTH))

#calculate the weighted median birth year for each year
w_median_birth <- meta_birth %>%
  group_by(PUBL_START, AUTH_BIRTH) %>%
  summarize(N = n())

w_median_birth <- w_median_birth %>%
  group_by(PUBL_START) %>%
  summarize(Z = weighted.median(x = AUTH_BIRTH, w = N))

#produce moving average
w_median_birth <- w_median_birth %>%
  mutate(lag1 = lag(Z),
         #lag2 = lag(Z,2),
         movavg = (Z+lag1)/2)

#calculate difference between year and median_birth for that year to get "pastness" measure
w_median_birth$dist <- w_median_birth$movavg - w_median_birth$PUBL_START 

p <- ggplot(data = w_median_birth, mapping = aes(x = PUBL_START, y = dist))
p + geom_line(size=1) +
  scale_x_continuous(breaks = c(1910,1920,1930,1940,1950)) +
  labs(x="", y="Years into the Past", color = "", title="") +
  theme(legend.position = "bottom", axis.text=element_text(size=12), title=element_text(size=12))

#####################
# Figure 2.6 ~ 2.7
#####################

#filter out everything between 1943 and 1945
new_meta <- TS_meta %>% filter(PUBL_START <= 1942 | PUBL_START >= 1946)

#input list of authors included in Shinchosha series and corresponding ID
auth_meta <- openxlsx::read.xlsx("Data/Foreign_Author_Metadata.xlsx", sheet = 1)

#select the part of Shinchosha to analyze
parts <- c("PART_ONE","PART_TWO","NOT_INCLUDED")
part <- parts[2]

#select threshold year to analyze (1929 for PART_ONE and NOT category; 1932 for PART_TWO)
breakpoints <- c(1929, 1932)
thresh <- breakpoints[2] 

#subset to get only authors in specific Part of Shinchosha anthology
auth_meta <- auth_meta %>% filter(SHINCHOSHA == part)

#perform a CHOW test for authors in this Part
auth_ratio <- new_meta %>%
  group_by(PUBL_START) %>%
  summarize(RATIO = length(TITLE[AUTHOR_NUM %in% auth_meta$AUTHOR_NUM]) / length(TITLE)) %>%
  mutate(lag1 = lag(RATIO),
         lag2 = lag(RATIO,2),
         movavg = (lag1+lag2)/2) #calculate 2 year moving avg

#run three regressions (all data and each half of data)
auth_ratio <- auth_ratio[3:41,]  #need to cut first 2 rows due to NA values
attach(auth_ratio)
r.reg = lm(movavg ~ PUBL_START)
ur.reg1 = lm(movavg ~ PUBL_START, data = auth_ratio[auth_ratio$PUBL_START <= thresh,])
ur.reg2 = lm(movavg ~ PUBL_START, data = auth_ratio[auth_ratio$PUBL_START > thresh,])
detach(auth_ratio)

## Calculate sum of squared residuals for each regression
SSR = NULL
SSR$r = r.reg$residuals^2
SSR$ur1 = ur.reg1$residuals^2
SSR$ur2 = ur.reg2$residuals^2

## K is the number of regressors in our model
K = r.reg$rank

## Computing the Chow test statistic (F-test)
numerator = ( sum(SSR$r) - (sum(SSR$ur1) + sum(SSR$ur2)) ) / K
denominator = (sum(SSR$ur1) + sum(SSR$ur2)) / (nrow(auth_ratio) - 2*K)
chow = numerator / denominator

## Calculate P-value
p_val <- 1 - pf(chow, K, (nrow(auth_ratio) - 2*K))

#Graph results 
#create a categorical variable based on before or after threshold year
auth_ratio$cut_point <- auth_ratio$PUBL_START <= thresh

#a transformation function
scaleFUN <- function(x) sprintf("%1.1f", 100*x)

q <- ggplot(data = auth_ratio, mapping = aes(x = PUBL_START, y = movavg, color = cut_point))
q + geom_point(size=2) +
  scale_x_continuous(breaks = c(1910,1920,1930,1940,1950,1960)) +
  labs(x="", y="Percent of Total Translations", title="") +
  scale_y_continuous(labels=scaleFUN) +
  scale_color_manual(values = c("black", "darkgrey")) +
  theme(legend.position = "", axis.text=element_text(size=12), title=element_text(size=12)) +
  geom_smooth(method = "lm", se=FALSE)


##############
# Figure 2.8
##############

#input list of authors included in Shinchosha series and corresponding ID
auth_meta <- openxlsx::read.xlsx("Data/Foreign_Author_Metadata.xlsx", sheet = 1)

#graph distribution of top 50 authors (needs to be sorted by NO_TITLES)
auth_meta <- auth_meta[with(auth_meta, order(-NO_TITLES)), ]
auth_meta$idu <- as.numeric(row.names(auth_meta))

ggplot(auth_meta[1:50,], aes(idu, y=NO_TITLES, label=AUTHOR_LAST)) + 
  geom_bar(stat="identity", width=.3, aes(fill=SHINCHOSHA)) +
  scale_fill_grey() +
  geom_text(vjust=0, hjust=0, angle=60, size=3, show.legend=FALSE, aes(color=SHINCHOSHA),
            position = position_jitter(width=0, height=0)) +
  scale_color_grey() +
  scale_y_continuous(limits=c(0, 2500)) + xlab("Author Rank by Number of Translations") + ylab("Number of Translations") +
  theme(legend.title = element_blank(), legend.position="top", legend.spacing.x = unit(.2, 'cm'))

###################################
# Analysis of GNBZ zenshu contents
###################################

#read in data
gnbz_meta <- openxlsx::read.xlsx("Data/ChikumaGNBZtoc.xlsx", sheet = "TOC")

#count titles by year out of copyright
oc_tbl <- count(gnbz_meta, OC_Year)

#############
# Figure 2.9
#############

#produce density plot and partially shade it up to 1968
dens <- density(oc_tbl$OC_Year, adjust=1/5)
dd <- with(dens,data.frame(x,y))
qplot(x,y,data=dd,geom="line") +
  geom_ribbon(data=subset(dd,x<1968),aes(ymax=y),ymin=0,fill="gray",colour=NA,alpha=0.7) +
  labs(x = "Year of Author's Death", y = "Proportion of Total") +
  geom_vline(xintercept=c(1968,1985), linetype="dotted")

#####################################################
# Analyze Nichigai Anthology Data (Fig. 2.10 ~ 2.14)
#####################################################

#read in zenshu metadata
zen_meta <- openxlsx::read.xlsx("Data/CompleteMetadata_Ver3.xlsx", sheet = 1)

##############
# Figure 2.10
##############

#temporal breakdown by zenshu volume (all data)
zenshu_vols <- plyr::ddply(zen_meta, .(year), summarize, y=length(unique(zenshu_full_title)))
ggplot(data = zenshu_vols, aes(x=factor(year), y=y, group=1)) + geom_line(size=1) +
  scale_x_discrete(breaks=c(1920,1930,1940,1950,1960,1970,1980,1990,2000)) +
  xlab("") + ylab("Number of Unique Volumes") +
  theme(legend.position = "", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

##############
# Figure 2.11
##############

#plot the general and author lines on the same graph
type_year <- zen_meta %>%
  group_by(year, zenshu_type) %>%
  summarize(N = length(unique(zenshu_full_title)))

p <- ggplot(data = type_year, mapping = aes(x = year, y = N, color = zenshu_type))
p + geom_line(mapping = aes(group = zenshu_type), size=1) +
  scale_x_continuous(breaks = c(1900,1910,1920,1930,1940,1950,1960,1970,1980,1990,2000)) +
  labs(x="", y="Number of Unique Volumes", color = "", title="") +
  scale_color_manual(labels = c("Author", "Omnibus"), values = c("darkgrey", "black")) +
  theme(legend.position = "top", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

###############################
# Analyze the Aozora "Fiction" 
###############################

#reload the complete corpus metadata
meta <- openxlsx::read.xlsx("Data/Corpus_Metadata_Clean.xlsx", sheet = 1)
#filter out by source to get just Aozora texts
meta <- meta %>% filter(SOURCE == "aozora")
#filter out duplicate texts
meta <- meta %>% filter(is.na(DUPE))
#get only works marked as fiction
fiction <- meta %>% filter(GENRE == "Fiction")
#filter out translations
fiction <- fiction %>% filter(is.na(TRANSLATION))
#filter out juvenile literature
fiction <- fiction %>% filter(is.na(SUBGENRE))

#calculate number of unique authors
length(unique(fiction$AUTHOR_ID))

#calculate gender statistics by title count
gender <- fiction %>%
  group_by(GENDER) %>%
  summarize(N = n()) %>%
  mutate(freq = N / sum(N),
         pct = round((freq*100), 0))
gender  

#calculte gender ratio as percentage of authors
uniq_gender <- fiction %>%
  group_by(GENDER, AUTHOR_ID) %>%
  summarize(N = n()) %>%
  group_by(GENDER) %>%
  summarize(N = n()) %>%
  mutate(freq = N / sum(N),
         pct = round((freq*100), 0))
uniq_gender  

###############
# Figure 2.12
###############

#show distribution of most represented authors by text count 
dfl <- ddply(fiction, .(AUTHOR_ID), summarize, y=length(AUTHOR_ID))

dfl <- dfl[with(dfl, order(-y)), ]
dfl$rank <- 1:nrow(dfl)

auth_rank <- merge(fiction[, c("AUTHOR_ID", "AUTHOR", "AUTHOR_LAST", "AUTHOR_FIRST")], dfl, by="AUTHOR_ID")
auth_rank$FULL_NAME <- paste(auth_rank$AUTHOR_LAST, auth_rank$AUTHOR_FIRST)
#set the following number to the rank above which you want to display author names
auth_rank$high[auth_rank$y >= 45] <- auth_rank$FULL_NAME[auth_rank$y >= 45]
auth_rank <- ddply(auth_rank, .(rank, high, FULL_NAME), summarize, y=length(rank))

#limit to top 50 authors
auth_rank <- auth_rank %>% filter(rank <= 50)

ggplot(auth_rank, aes(rank, y=y, label=high)) + geom_bar(stat="identity", width=.3, show.legend=FALSE) +
  geom_text(vjust=0, hjust=0, angle=60, size=3,
            position = position_jitter(width=0, height=0)) +
  scale_y_continuous(limits=c(0, 450)) + xlab("Author Rank by Number of Titles") + ylab("Number of Titles")

#this line goes before vjust if you want to try to move the label locations manually
#data = within(auth_rank, c(y <- y - .2, rank <- rank + .1)), 

###################################
# Figure 2.13 (back to Zenshu Data)
####################################

#select on all works tagged as fiction
zen_fiction <- zen_meta %>% filter(genre == "Fiction")

#break down by zenshu type
gen_fiction <- zen_fiction %>% filter(zenshu_type == "General")

#function for plotting with overlapping period
#with overlapping period window
half_window = 2
years = 1925:2003
data_set <- gen_fiction   #toggle between datasets here

#get subset indices within the moving window
get_period <- function(year, half_window) {
  index = (data_set$year >= year - half_window) & (data_set$year <= year + half_window)
  index[is.na(index)] = FALSE
  return(which(index))
}

get_ratio_by_period <- function(meta_subset) {
  y = with(meta_subset, 100*(length(which(sub_genre=="Popular"))/dim(meta_subset)[1]))
  return(y)
}

#calculate moving average
mov.avg = data.frame(year = years, 
                     y = sapply(years, function(year) get_ratio_by_period(gen_fiction[get_period(year, half_window), ])))

#now plot it
ggplot(data = mov.avg, aes(x = factor(year), y = y, group = 1)) + geom_point(alpha=.4) +
  scale_x_discrete(breaks=c(1930,1940,1950,1960,1970,1980,1990,2000)) +
  stat_smooth(method="loess", span = .75, colour="grey", se=FALSE) +
  #scale_y_continuous(limits = c(-10, 100)) +
  xlab("") + ylab("Percent of Popular Fiction in Omnibus Volumes") +
  theme(axis.text=element_text(size=12))

######################################
# Figure 2.14 
#####################################

get_percent_by_period <- function(meta_subset) {
  y = with(meta_subset, 100*(length(which(author_gender=="F"))/dim(meta_subset)[1]))
  return(y)
}

#calculate moving average
mov.avg = data.frame(year = years, 
                     y = sapply(years, function(year) get_percent_by_period(data_set[get_period(year, half_window), ])))

#now plot it
ggplot(data = mov.avg, aes(x = factor(year), y = y, group = 1)) + geom_point(alpha=.4) +
  scale_x_discrete(breaks=c(1930,1940,1950,1960,1970,1980,1990,2000)) +
  stat_smooth(method="loess", span = .75, colour="grey", se=FALSE) +
  geom_hline(size=1, color="black", yintercept = 10, linetype ="dotted") +
  #scale_y_continuous(limits = c(-10, 100)) +
  xlab("") + ylab("Percent of Titles by Female Authors") +
  theme(axis.text=element_text(size=12))

############################
# Rank Correlation Analysis
############################

#See the ranking.R file in this same folder

#########################################################
# Analyze the Aozora "Fiction" subset (longest ~2K works)
#########################################################

#read in complete corpus metadata
meta <- openxlsx::read.xlsx("Data/Corpus_Metadata_Clean.xlsx", sheet = 1)

#filter out by source to get just Aozora texts
meta <- meta %>% filter(SOURCE == "aozora")

#filter out duplicate texts
meta <- meta %>% filter(is.na(DUPE))

#all texts marked as part of fiction corpus, excluding non-Aozora material
fict_subset <- meta %>% filter(FICTION_CORPUS == "TRUE")

############
# Fig. 2.16
############

#calculate the works per year and graph
fict_counts <- fict_subset %>% filter(!is.na(PUBL_START))
fict_counts <- ddply(fict_counts, .(PUBL_START), summarise, y=length(WORK_TITLE))

ggplot(data = fict_counts, aes(x=factor(PUBL_START), y=y, group=1)) + geom_line() +
  scale_x_discrete(breaks=c(1890,1900,1910,1920,1930,1940,1950,1960)) +
  xlab("") + ylab("Number of Titles") + theme(axis.text=element_text(size=12)) +
  theme(plot.margin=unit(c(.5,.5,0,.5),"cm"))

#calculate the gender balance by author
uniq_gender <- fict_subset %>%
  group_by(GENDER, AUTHOR_ID) %>%
  summarize(N = n()) %>%
  group_by(GENDER) %>%
  summarize(N = n()) %>%
  mutate(freq = N / sum(N),
         pct = round((freq*100), 0))
uniq_gender  #11% Female Authors

#calculate gender statistics by title count
gender <- fict_subset %>%
  group_by(GENDER) %>%
  summarize(N = n()) %>%
  mutate(freq = N / sum(N),
         pct = round((freq*100), 0))
gender  #comes out to roughly 7% of titles by female authors (127 out of 1,827)

############
# Fig. 2.17
############

#produce a plot showing the distribution of authors
dfl <- ddply(fict_subset, .(AUTHOR_ID), summarise, y=length(AUTHOR_ID))

dfl <- dfl[with(dfl, order(-y)), ]
dfl$rank <- 1:nrow(dfl)

auth_rank <- merge(fict_subset[, c("AUTHOR_ID", "AUTHOR", "AUTHOR_LAST", "AUTHOR_FIRST")], dfl, by="AUTHOR_ID")
auth_rank$FULL_NAME <- paste(auth_rank$AUTHOR_LAST, auth_rank$AUTHOR_FIRST)
#set the following number to the rank above which you want to display author names
auth_rank$high[auth_rank$y >= 21] <- auth_rank$FULL_NAME[auth_rank$y >= 21]
auth_rank <- ddply(auth_rank, .(rank, high, FULL_NAME), summarise, y=length(rank))

#limit to top 50 authors
auth_rank <- auth_rank %>% filter(rank <= 50)

ggplot(auth_rank, aes(rank, y=y, label=high)) + geom_bar(stat="identity", width=.3, show.legend=FALSE) +
  geom_text(vjust=0, hjust=0, angle=60, size=3,
            position = position_jitter(width=0, height=0)) +
  scale_y_continuous(limits=c(0, 150)) + xlab("Author Rank by Number of Titles") + ylab("Number of Titles") 

# EXTRA: show distribution of text length
temp <- fict_subset %>% filter(TEXT_LENGTH < 500000) #filter out the very longest texts
p <- ggplot(data = temp, aes(x = TEXT_LENGTH))
p + geom_histogram(bins=200) + 
  geom_vline(aes(xintercept=median(TEXT_LENGTH)), color="black", linetype="dashed", size=1) +
  xlab("Text Length") + ylab("Number of Texts with this Length") +
  geom_text(aes(x=median(TEXT_LENGTH), label="\nMedian Length", y=200), colour="black", angle=90) +
  theme(legend.position = "", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

#################################
# Kanji Counts and MVR Analysis
#################################

#import data with counts of Chinese characters
kan_meta <- openxlsx::read.xlsx("Data/KanjiCounts.xlsx", sheet = 1)
kan_meta <- kan_meta %>% filter(!is.na(PUBL_START))
kan_meta <- kan_meta[which(kan_meta$PUBL_START > 1899),]

#calculate the ratio of kanji across all texts for that year
kanji_ratio <- kan_meta %>%
  group_by(PUBL_START) %>%
  summarise(N = sum(KANJI_COUNT) / (sum(KANJI_COUNT) + sum(NON_KANJI_COUNT))) %>%
  mutate(lag1 = lag(N),
         lag2 = lag(N,2),
         avg = (lag1+lag2)/2)

#calculate the mean ratio of kanji per year
kanji_ratio_mean <- kan_meta %>%
  group_by(PUBL_START) %>%
  summarise(N = mean(KANJI_COUNT / (KANJI_COUNT + NON_KANJI_COUNT))) %>%
  mutate(lag1 = lag(N),
         lag2 = lag(N,2),
         avg = (lag1+lag2)/2)

###############
# Figure 2.18
###############

scaleFUN <- function(x) sprintf("%1.1f", 100*x)

#plot the mean ratio 
ggplot(data=kanji_ratio_mean, aes(x=PUBL_START, y=avg, group=1)) + 
  geom_line() + 
  geom_smooth(color="black", se=FALSE) +
  scale_y_continuous(labels=scaleFUN) +
  xlab("") + ylab("Mean Percentage of Kanji") +
  theme(legend.position = "", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

###############
# Figure 2.19
###############

#import data with Part of Speech counts
pos_meta <- openxlsx::read.xlsx("Data/POSCounts.xlsx", sheet = 1)

#calculate upper and lower boundaries based on 2 standard deviations of the ratios
#only use these standard deviation for normally distributed values
#x_upp <- mean(pos_meta$N_RATIO) + (2 * sd(pos_meta$N_RATIO))
#x_low <- mean(pos_meta$N_RATIO) - (2 * sd(pos_meta$N_RATIO))
#y_upp <- mean(pos_meta$MVR) + (2 * sd(pos_meta$MVR))
#y_low <- mean(pos_meta$MVR) - (2 * sd(pos_meta$MVR))

#calculate upper and lower boundaries based on 2.5 and 97.5 percentiles
x_upp <- quantile(pos_meta$N_RATIO, c(.975))[[1]]
x_low <- quantile(pos_meta$N_RATIO, c(.025))[[1]]
y_upp <- quantile(pos_meta$MVR, c(.975))[[1]]
y_low <- quantile(pos_meta$MVR, c(.025))[[1]]

#single out points for labeling
pos_meta$group <- (pos_meta$AUTHOR_LAST == "Hori" & pos_meta$N_RATIO < x_low) | 
  (pos_meta$AUTHOR_LAST == "Miyazawa" & pos_meta$MVR > y_upp) | 
  (pos_meta$AUTHOR_FIRST == "Ogai" & pos_meta$MVR < y_low & pos_meta$N_RATIO > x_upp)

#produce plot
ggplot(data=pos_meta, aes(x=N_RATIO, y=MVR)) +
  geom_point(aes(color=group), size=1) +
  scale_color_manual(values = c("grey","black")) +
  geom_hline(yintercept=c(y_low,y_upp), linetype="dashed") +
  geom_vline(xintercept=c(x_low, x_upp), linetype="dashed") +
  geom_text_repel(data=filter(pos_meta, group=="TRUE"), aes(label=AUTHOR_LAST), size=3) +
  xlab("Noun Ratio") + ylab("MVR") +
  theme(legend.position = "", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))
  #geom_smooth(method = "lm") +

#measure the correlation of the two variables
cor(pos_meta$N_RATIO,pos_meta$MVR)