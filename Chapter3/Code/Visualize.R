#####################################################
# Data visualizations and Measurements for Chapter 3
#####################################################

setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter3")
library(e1071)
library(ggplot2)
library(openxlsx)

#Load Derived Features
data_jp <- openxlsx::read.xlsx("./Results/all_extracted_features.xlsx", sheet = "Sheet 1")

############
#Figure 3.1
############

require(gridExtra)

p <- ggplot(subset(data_jp, GENRE!="JUNBUNGAKU"), aes(factor(GENRE), ent_mean)) +
  geom_violin(fill = "grey80", scale = "count", width = .75) +
  stat_summary(fun.y=mean, geom="point", shape=20, size=3, color="black", fill="black") +
  #geom_hline(yintercept=c(mean(subset(data_jp, GENRE=="SHISHOSETSU")$ent_mean)), linetype="dashed") +
  labs(x="", y="Mean Entropy") + guides(fill = FALSE) +
  scale_x_discrete(breaks=c("POPULAR","SHISHOSETSU"),labels=c("POPULAR","I-NOVEL"))
p

q <- ggplot(subset(data_jp, GENRE!="JUNBUNGAKU"), aes(factor(GENRE), ttr_mean)) +
  geom_violin(fill = "grey80", scale = "count", width = .75) +
  stat_summary(fun.y=mean, geom="point", shape=20, size=3, color="black", fill="black") +
  #geom_hline(yintercept=c(mean(subset(data_jp, GENRE=="SHISHOSETSU")$ttr_mean)), linetype="dashed") +
  labs(x="", y="Mean Type Token Ratio") + guides(fill = FALSE) +
  scale_x_discrete(breaks=c("POPULAR","SHISHOSETSU"),labels=c("POPULAR","I-NOVEL"))

grid.arrange(p, q, ncol=2)

############
# Figure 3.2
############

p <- ggplot(subset(data_jp, GENRE!="JUNBUNGAKU"), aes(x=thought, y=ttr_mean, color=GENRE))
p + stat_smooth(method = "lm") + geom_point(shape=16, size=1) + 
  scale_color_manual(labels=c("Popular", "I-Novel"), values=c("black", "grey")) +
  ylab("Mean TTR") +
  xlab("Thought/Feeling Verbs")

#for black/white version
p <- ggplot(subset(data_jp, GENRE!="JUNBUNGAKU"), aes(x=thought, y=ttr_mean, shape=GENRE))
p + stat_smooth(method = "lm", color="grey", se=FALSE) + geom_point(aes(shape=GENRE), size=1) + 
  #scale_color_manual(labels=c("Popular", "I-Novel"), values=c("blue", "red")) +
  scale_shape_manual(values=c(4, 1), labels=c("Popular", "I-novel")) +
  ylab("Mean TTR") +
  xlab("Thought/Feeling Verbs")


#############
# Figure 3.3
#############

# See "Classifier.R" file

#############
# Figure 3.4
#############

data_ch = data.frame(read.csv("Results/derived_data_ch.csv", encoding="UTF-8"))
highlight3 <- c("R_scn_032", "R_scn_033", "R_scn_018", "R_dig_020", "R_scn_053", "R_scn_026", "R_scn_031", "R_scn_034")

p <- ggplot(data_ch, aes(x=thought, y=ent_mean, shape=GENRE, label=AUTHOR_LAST))
p + stat_smooth(method = "lm", color="grey", se=FALSE) + geom_point(aes(shape=GENRE), size=1) +
  xlab("Thought/Feeling Words") + ylab("Mean Entropy") + 
  geom_text(data=subset(data_ch, FILE_ID %in% highlight3), angle=45, size=4, nudge_y=.03) +
  scale_shape_manual(labels=c("Popular", "Romantic"), values=c(4,1))
