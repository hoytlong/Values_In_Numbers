#################################################################
# Code for Analysis of Japanese High School Textbook Metadata
#################################################################

#set working directory to local folder
setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter2")

library(ggplot2)
library(scales)
library(openxlsx)
library(plyr)
library(tidyverse)
library(reshape2)
library(directlabels)
library(readr)

#read in textbook metadata
tb_meta <- openxlsx::read.xlsx("Data/Textbook_Metadata.xlsx", sheet = 1)

#filter out by type
tb_meta <- tb_meta %>% filter(type == "NonClassical")

#create unique identifiers for textbook titles, work titles, and author_textbook combinations
tb_meta <- tb_meta %>%
  unite(unique_textbook, textbook_publisher, textbook_title, sep = "_", remove = FALSE)

tb_meta <- tb_meta %>%
  unite(unique_work, work_title, author, sep = "_", remove = FALSE)

tb_meta <- tb_meta %>%
  unite(author_textbook, author, unique_textbook, sep = "_", remove = FALSE)

#get the number of unique textbook titles
length(unique(tb_meta$unique_textbook))  #found 842 unique non-classical textbooks

#function for plotting with overlapping period
#with overlapping period window
half_window = 2
years = 1950:2007
#get subset indices within the moving window
get_period <- function(year, half_window) {
  index = (tb_meta$year >= year - half_window) & (tb_meta$year <= year + half_window)
  index[is.na(index)] = FALSE
  return(which(index))
}

#########################
# temporal distributions
#########################

#temporal distribution (by individual title)
ggplot(tb_meta, aes(factor(year))) + geom_bar(width=.3, show.legend=FALSE) + 
  scale_x_discrete(breaks=c(1950,1960,1970,1980,1990,2000)) + 
  xlab("Year of Publication") + ylab("Number of Titles")

#temporal distribution (by unique textbook title)
df_textbook <- plyr::ddply(tb_meta, .(year), summarize, y=length(unique(textbook_title)))
ggplot(data = df_textbook, aes(x=factor(year), y=y, group=1)) + geom_line() +
  scale_x_discrete(breaks=c(1950,1960,1970,1980,1990,2000)) +
  xlab("Year of Publication") + ylab("Number of Unique Textbooks")

#examine individual author and title trends by setting "auth" and "id" to desired authors/titles 
auth = "夏目漱石"  
auth = "芥川龍之介"
auth = "森鴎外"
auth = "釈迢空"
auth = "志賀直哉"
auth = "中島敦"

id = 9159 #Soseki's Kokoro
id = 8572 #Nakajima's Sangetsuki
id = 170 #Akutagawa's Rashomon
id = 10047 #Higuchi's Takekurabe
id = 5593 #Shiga's Kinosaki nite

#temporal distribution (by single author)
sub.meta1 <- tb_meta %>% filter(author == auth)
ggplot(sub.meta1, aes(factor(year))) + geom_bar(width=.3, show.legend=FALSE) + 
  scale_x_discrete(breaks=c(1950,1960,1970,1980,1990,2000)) +
  xlab("Year of Publication") + ylab("Number of Titles")

#temporal distribution (by single title)
sub.meta2 <- tb_meta %>% filter(work_id == id)
sub.meta2 <- plyr::ddply(sub.meta2, .(year), summarize, y=length(work_title))
ggplot(data = sub.meta2, aes(x = factor(year), y = y, group = 1)) + geom_point() + 
  xlab("Year") + ylab("Count")

####################################################################
# calculate percentage of textbook titles that contain specific work
#####################################################################

#calculate same ratio but with a moving average
get_count_by_period <- function(meta_subset, id) {
  y = with(meta_subset, 100*length(which(work_id==id))/length(unique(unique_textbook)))
  return(y)
}

#calculate moving average
sub.wap = data.frame(year = years, 
                     y = sapply(years, function(year) get_count_by_period(tb_meta[get_period(year, half_window), ], id)))

#graph the result
plot_title = tb_meta[which(tb_meta$work_id == id),][1,4]

ggplot(data = sub.wap, aes(x = factor(year), y = y, group = 1)) + geom_point(alpha=.4) +
  scale_x_discrete(breaks=c(1950,1960,1970,1980,1990,2000)) +
  stat_smooth(method="loess", span = .75) +
  #scale_y_continuous(limits = c(-10, 100)) +
  xlab("Year") + ylab("% of Textbooks in which Work Appears (Moving 4 year Average") +
  ggtitle(plot_title) +
  theme(plot.title = element_text(color="black", size=14, face="bold.italic", hjust=0.5, family = 'Arial Unicode MS'))

####################################################################
# calculate same percentage for multiple titles and graph results
#####################################################################

top_ids = c(8572, 170, 9159, 12250, 5593, 10047, 7162, 9162, 4172)
#top_ids = c(8572, 170, 9159, 12250, 9162)

#caluculate for each id and merge results as you go
df.list <- c()

for (i in top_ids){
  sub.wap = data.frame(year = years, 
                       y = sapply(years, function(year) get_count_by_period(tb_meta[get_period(year, half_window), ], i)))
  
  #get title
  plot_title = tb_meta[which(tb_meta$work_id == i),][1,4]
  colnames(sub.wap)[2] <- plot_title
  nam <- paste("sub", i, sep = "_")
  assign(nam, sub.wap)
  df.list <- c(df.list, nam)
}

k <- 1
for (j in 1:(length(df.list)-1)){
  if (j == 1){
    merged <- merge(get(df.list[k]), get(df.list[k+1]), by="year")
    k <- k + 1
  }
  else{
    merged <- merge(merged, get(df.list[k+1]), by="year")
    k <- k + 1
  }
}

#now melt the combined dataframe and plot
merge.long <- melt(merged, id = "year", measure = colnames(merged)[2:length(merged)])

cairo_pdf("Results/TopTitleArcs.pdf", height=10, width=14, 
          pointsize=10, family="MS Mincho")

ggplot(merge.long, aes(x=year, y=value, colour = variable)) + geom_point(alpha=0) +
  #scale_x_discrete(breaks=c(1950,1960,1970,1980,1990,2000)) +
  stat_smooth(method="loess", span = .75, alpha=0.1) +
  theme(legend.text = element_text(family = 'MS Mincho')) +
  #geom_dl(aes(label = variable), method = "angled.boxes", cex = 0.8) +
  #theme(legend.position = "none") +
  xlab("Year") + ylab("% of Textbooks in which Works Appear (Moving 4 year Average)")

dev.off()

###############################################################################
# calculate percentage of textbook titles that contain works by specific author
###############################################################################

#calculate same ratio but with a moving average
get_count_by_period_2 <- function(meta_subset, auth) {
  y = with(meta_subset, 100*length(unique(meta_subset[which(author==auth),"author_textbook"]))/length(unique(unique_textbook)))
  return(y)
}

#calculate moving average
sub.wap = data.frame(year = years, 
                     y = sapply(years, function(year) get_count_by_period_2(tb_meta[get_period(year, half_window), ], auth)))

ggplot(data = sub.wap, aes(x = factor(year), y = y, group = 1)) + geom_point(alpha=.4) +
  scale_x_discrete(breaks=c(1950,1960,1970,1980,1990,2000)) +
  stat_smooth(method="loess", span = .75) +
  #scale_y_continuous(limits = c(-10, 100)) +
  xlab("Year") + ylab("% of Textbooks in which Author's Works Appear (Moving 4 year Average") +
  ggtitle(auth) +
  theme(plot.title = element_text(color="black", size=14, face="bold.italic", hjust=0.5))

################################################################################
# calculate percentage of textbook titles that contain works by multiple authors
################################################################################

#select one of these lists
#top_auths <- c("夏目漱石","釈迢空","島崎藤村","芥川龍之介","森鴎外","志賀直哉","宮沢賢治","樋口一葉")
top_auths <- c("寺田寅彦","ゲーテ","シェイクスピア","谷崎潤一郎","佐藤春夫","有島武郎","中村光夫")

#caluculate for each id and merge results as you go
df.auth.list <- c()

for (i in 1:length(top_auths)){
  sub.auth.wap = data.frame(year = years, 
                       y = sapply(years, function(year) get_count_by_period_2(tb_meta[get_period(year, half_window), ], top_auths[i])))
  
  #get title
  colnames(sub.auth.wap)[2] <- top_auths[i]
  nam <- paste("sub", i, sep = "_")
  assign(nam, sub.auth.wap)
  df.auth.list <- c(df.auth.list, nam)
}

k <- 1
for (j in 1:(length(df.auth.list)-1)){
  if (j == 1){
    merged <- merge(get(df.auth.list[k]), get(df.auth.list[k+1]), by="year")
    k <- k + 1
  }
  else{
    merged <- merge(merged, get(df.auth.list[k+1]), by="year")
    k <- k + 1
  }
}

#now melt the combined dataframe and plot
merge.long <- melt(merged, id = "year", measure = colnames(merged)[2:length(merged)])

cairo_pdf("Results/FallingAuthArcs.pdf", height=10, width=14, 
          pointsize=10, family="MS Mincho")

ggplot(merge.long, aes(x=year, y=value, colour = variable)) + geom_point(alpha=0) +
  #scale_x_discrete(breaks=c(1950,1960,1970,1980,1990,2000)) +
  stat_smooth(method="loess", span = .75) +
  theme(legend.text = element_text(family = 'MS Mincho')) +
  xlab("Year") + ylab("% of Textbooks in which Author Appears (Moving 4 year Average)")

dev.off()