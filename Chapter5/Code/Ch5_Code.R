##############################################
# Code for Figures and Analysis for Chapter 5 
##############################################

#set working directory to local folder
setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter5")

#import libraries
library(ggplot2)
library(scales)
library(openxlsx)
library(plyr)
library(dplyr)
library(tidyverse)
library(reshape2)
library(remotes)
#remotes::install_github("coolbutuseless/ggpattern")
library(ggpattern)

###############################################
# Figures/Analysis for Kindai Magazine Corpus
###############################################

#read in kindai magazine metadata
meta <- openxlsx::read.xlsx("Data/Kindai_Meta.xlsx", sheet = 1)

#filter out texts with "y" in the FILTER column
meta <- meta[which(is.na(meta$FILTER)),]

#function for plotting with overlapping period
#with overlapping period window
half_window = 10
years = 1887:1957
#get subset indices within the moving window
get_period <- function(year, half_window) {
  index = (meta$YEAR >= year - half_window) & (meta$YEAR <= year + half_window)
  index[is.na(index)] = FALSE
  return(which(index))
}

######################
# Simple Trend Plots
######################

#################
# Docs by Period
#################

#group the metadata by period and sum the total number of texts
count_by_period <- plyr::ddply(meta, .(YEAR), summarize, y=length(YEAR))
ggplot(data=count_by_period, aes(x=YEAR, y=y, group=1)) +
  geom_line() + scale_y_continuous(limits = c(0, 3500)) 

#alternative way of smoothing
get_count_by_period <- function(meta_subset) {
  y = with(meta_subset, length(YEAR))
  return(y)
}
count_data = data.frame(year = years, y = sapply(years, function(year) get_count_by_period(meta[get_period(year, half_window), ])))
ggplot(data = count_data, aes(x = year, y = y)) +
  geom_line() + scale_y_continuous(limits = c(0, 7000)) +
  ylab("Number of Works") +
  xlab("Year")

#########################################
# Text Length by Period (Figures 5.1~5.2)
#########################################

#Figure 5.1
#total length of texts by period
words_by_period <- plyr::ddply(meta, .(YEAR), summarize, y=sum(TOKENS))
ggplot(data=words_by_period, aes(x=YEAR, y=y, group=1)) +
  geom_line() + scale_y_continuous(limits = c(0, 3500000), labels=comma) +
  scale_x_continuous(breaks=c(1890,1900,1910,1920,1930,1940,1950,1960), limits=c(1885,1960)) +
  ylab("Lexical Items") + xlab("") +
  theme(legend.position = "bottom", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

#Figure 5.2
#number of race_words normalized by total length of texts per period

#transformation function
scaleFUN <- function(x) sprintf("%.4f", x)

race_by_period <- plyr::ddply(meta, .(YEAR), summarize, y = sum(RACEWORDS) / sum(TOKENS))
top <- max(race_by_period['y'][,1])
ggplot(data=race_by_period, aes(x=YEAR, y=y, group=1)) +
  geom_line() + scale_y_continuous(limits = c(0, top), labels=scaleFUN) +
  scale_x_continuous(breaks=c(1890,1900,1910,1920,1930,1940,1950,1960), limits=c(1885,1960)) +
  ylab("References to Racial/Ethnic Others") + xlab("") +
  theme(legend.position = "bottom", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

#Figure 5.3
#number of references to "Japanese" normalized by total length of texts per period
japan_by_period <- plyr::ddply(meta, .(YEAR), summarize, y = sum(JAPANESE) / sum(TOKENS))
top <- max(japan_by_period['y'][,1])
ggplot(data=japan_by_period, aes(x=YEAR, y=y, group=1)) +
  geom_line() + scale_y_continuous(limits = c(0, top), labels=scaleFUN) +
  scale_x_continuous(breaks=c(1890,1900,1910,1920,1930,1940,1950,1960), limits=c(1885,1960)) +
  ylab("References to Japanese") + xlab("") +
  theme(legend.position = "bottom", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

##############################
# Race Words by Magazine Title
##############################

#get proportion of race words per magazine
count_race <- meta %>%
  group_by(MAGAZINE) %>%
  summarize(rw = sum(RACEWORDS),
            N = sum(TOKENS)) %>%
  mutate(freq = rw / N,
         pct = freq*100)

#check results
count_race

#get proportion of words referring to "Japanese" per magazine
count_jpn <- meta %>%
  group_by(MAGAZINE) %>%
  summarize(jw = sum(JAPANESE),
            N = sum(TOKENS)) %>%
  mutate(freq = jw / N,
         pct = freq*100)

#check results
count_jpn

##########################################
# Grids for Analysis of Semantic Clusters
##########################################

########################################
# Other races versus Japanese (Fig. 5.4)
########################################

race_cxt <- openxlsx::read.xlsx("results_kindai_bootstrap/Kindai_Clusters_Summary.xlsx", sheet = "HeatMap1")

#race_cxt <- race_cxt[,1:5]
race_cxt.m <- melt(race_cxt)
race_cxt.m$Category <- factor(race_cxt.m$Category, levels = rev(as.character(race_cxt[[1]])))

#replace NAs with zero
race_cxt.m[is.na(race_cxt.m)] <- 0

p <- ggplot(race_cxt.m, aes(variable, Category)) #+ geom_tile(aes(fill = value), colour = "grey") +
  #scale_fill_gradient(low = "white", high = "black")

base_size <- 9
p + theme_grey(base_size = base_size * 1.5) + labs(x = "", y = "") + 
  geom_tile_pattern(aes(fill=value, pattern_density=value), colour="grey", pattern='circle', 
                    pattern_fill="black", pattern_colour="black", size=.5) +
  scale_fill_gradient(low = "white", high = "black") +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) + 
  theme(axis.text.x = element_text(size = base_size * 1.5, angle = 45, hjust = 1, colour = "black"),
        axis.text.y = element_text(size= base_size)) +
  guides(fill=guide_legend(title="Strength", reverse=TRUE, keywidth=1), pattern_density=FALSE)

#####################################
# Japanese vs other races (Fig. 5.5)
#####################################

jp_cxt <- openxlsx::read.xlsx("results_kindai_bootstrap/Kindai_Clusters_Summary.xlsx", sheet = "HeatMap2")

#jp_cxt <- jp_cxt[,1:9]
jp_cxt.m <- melt(jp_cxt)
jp_cxt.m$Category <- factor(jp_cxt.m$Category, levels = rev(as.character(jp_cxt[[1]])))

#replace NAs with zero
jp_cxt.m[is.na(jp_cxt.m)] <- 0

p <- ggplot(jp_cxt.m, aes(variable, Category)) #+ geom_tile(aes(fill = value), colour = "grey") +
  #scale_fill_gradient(low = "white", high = "black")

base_size <- 9
p + theme_grey(base_size = base_size * 1.5) + labs(x = "", y = "") + 
  geom_tile_pattern(aes(fill=value, pattern_density=value), colour="grey", pattern='circle', 
                    pattern_fill="black", pattern_colour="black", size=.5) +
  scale_fill_gradient(low = "white", high = "black") +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) + 
  theme(axis.text.x = element_text(size = base_size * 1.5, angle = 45, hjust = 1, colour = "black")) +
  guides(fill=guide_legend(title="Strength", reverse=TRUE, keywidth=1), pattern_density=FALSE)

######################################
# Figures/Analysis for Fiction Corpus
######################################

#read in fiction metadata
meta <- openxlsx::read.xlsx("Data/Fiction_Meta.xlsx", sheet = 1)

#function for plotting with overlapping period
#with overlapping period window
half_window = 2
years = 1892:1960
#get subset indices within the moving window
get_period <- function(year, half_window) {
  index = (meta$PUBL_START >= year - half_window) & (meta$PUBL_START <= year + half_window)
  index[is.na(index)] = FALSE
  return(which(index))
}

#################
# Docs by Period
#################

#group the metadata by period and sum the total number of texts
count_by_period <- plyr::ddply(meta, .(PUBL_START), summarize, y=length(PUBL_START))
ggplot(data=count_by_period, aes(x=PUBL_START, y=y, group=1)) +
  geom_line() + scale_y_continuous(limits = c(0, 110)) 

#an alternative way of smoothing
get_count_by_period <- function(meta_subset) {
  y = with(meta_subset, length(PUBL_START))
  return(y)
}

#plot with alternative smoothing
count_data = data.frame(year = years, y = sapply(years, function(year) get_count_by_period(meta[get_period(year, half_window), ])))
ggplot(data = count_data, aes(x = year, y = y)) +
  geom_line() + scale_y_continuous(limits = c(0, 400)) +
  ylab("Number of Works") +
  xlab("Year")

#############################################
# Text Length by Period (Figures 5.6 ~ 5.8)
############################################

#Figure 5.6
#total length of texts by period
words_by_period <- plyr::ddply(meta, .(PUBL_START), summarize, y=sum(TOKENS))
ggplot(data=words_by_period, aes(x=PUBL_START, y=y, group=1)) +
  geom_line() + scale_y_continuous(limits = c(0, 4000000), labels=comma) +
  scale_x_continuous(breaks=c(1890,1900,1910,1920,1930,1940,1950,1960), limits=c(1890,1960)) +
  ylab("Lexical Items") + xlab("") +
  theme(legend.position = "bottom", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

#filter out pre-1905 texts as data is too sparse; this also exlcudes texts for which you lack publication dates
meta <- meta %>% filter(PUBL_START >= 1905)

#Figure 5.7
#number of race_words normalized by total length of texts per period

#transformation function
scaleFUN <- function(x) sprintf("%.5f", x)

race_by_period <- plyr::ddply(meta, .(PUBL_START), summarize, y = sum(RACEWORDS) / sum(TOKENS))
top <- max(race_by_period['y'][,1])
ggplot(data=race_by_period, aes(x=PUBL_START, y=y, group=1)) +
  geom_line() + scale_y_continuous(limits = c(0, top), labels=scaleFUN) +
  scale_x_continuous(breaks=c(1910,1920,1930,1940,1950,1960), limits=c(1910,1960)) +
  ylab("References to Racial/Ethnic Others") + xlab("") +
  theme(legend.position = "bottom", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

#Figure 5.8
#number of references to "Japanese" normalized by total length of texts per period
japan_by_period <- plyr::ddply(meta, .(PUBL_START), summarize, y = sum(JAPANESE) / sum(TOKENS))
top <- max(japan_by_period['y'][,1])
ggplot(data=japan_by_period, aes(x=PUBL_START, y=y, group=1)) +
  geom_line() + scale_y_continuous(limits = c(0, top), labels=scaleFUN) +
  scale_x_continuous(breaks=c(1910,1920,1930,1940,1950,1960), limits=(c(1910,1960))) +
  ylab("References to Japanese") + xlab("") +
  theme(legend.position = "bottom", axis.text=element_text(size=12), title=element_text(size=12)) #,face="bold"))

###########################################
# Semantic Grids for Analysis of Clusters 
###########################################

#####################################
# Japanese vs other races (Fig. 5.9)
#####################################

jp_cxt <- openxlsx::read.xlsx("results_fic_bootstrap/Fiction_Clusters_Summary.xlsx", sheet = "HeatMap2")

#jp_cxt <- jp_cxt[,1:9]
jp_cxt.m <- melt(jp_cxt)
jp_cxt.m$Category <- factor(jp_cxt.m$Category, levels = rev(as.character(jp_cxt[[1]])))

#replace NAs with zero
jp_cxt.m[is.na(jp_cxt.m)] <- 0

p <- ggplot(jp_cxt.m, aes(variable, Category)) #+ geom_tile(aes(fill = value)) +
  #scale_fill_gradient(low = "white", high = "black")

base_size <- 9
p + theme_grey(base_size = base_size * 1.5) + labs(x = "", y = "") +
  geom_tile_pattern(aes(fill=value, pattern_density=value), colour="grey", pattern='circle', 
                    pattern_fill="black", pattern_colour="black", size=.5) +
  scale_fill_gradient(low = "white", high = "black") +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) + 
  theme(axis.text.x = element_text(size = base_size * 1.5, angle = 45, hjust = 1, colour = "black")) +
  guides(fill=guide_legend(title="Strength", reverse=TRUE, keywidth=1), pattern_density=FALSE)

########################################
# Other races versus Japanese (Fig. 5.10)
########################################

race_cxt <- openxlsx::read.xlsx("results_fic_bootstrap/Fiction_Clusters_Summary.xlsx", sheet = "HeatMap1")

#commented lines are used to filter out rows or columns
#race_cxt <- race_cxt[,c(1,5)]
#race_cxt <- race_cxt[c(3,11,12,13,16,17,18,20,22,24,25,26),]
race_cxt.m <- melt(race_cxt)
race_cxt.m$Category <- factor(race_cxt.m$Category, levels = rev(as.character(race_cxt[[1]])))

#replace NAs with zero
race_cxt.m[is.na(race_cxt.m)] <- 0

p <- ggplot(race_cxt.m, aes(variable, Category)) #+ geom_tile(aes(fill = value), colour = "grey") +
  #scale_fill_gradient(low = "white", high = "black")

base_size <- 9
p + theme_grey(base_size = base_size * 1.5) + labs(x = "", y = "") + 
  geom_tile_pattern(aes(fill=value, pattern_density=value), colour="grey", pattern='circle', 
                    pattern_fill="black", pattern_colour="black", size=.5) +
  scale_fill_gradient(low = "white", high = "black") +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) + 
  theme(axis.text.x = element_text(size = base_size * 1.5, angle = 45, hjust = 1, colour = "black"),
        axis.text.y = element_text(size= base_size - 2)) +
  guides(fill=guide_legend(title="Strength", reverse=TRUE, keywidth=1), pattern_density=FALSE)