##############################################
# Code to perform Rank Correlation Analysis
##############################################

#set working directory to local folder
setwd("C:/Users/Hoyt/Dropbox/CodeDataForBook/Chapter2")

#load libraries
library(Hmisc)
library(ircor)

#read in author rank data
meta <- openxlsx::read.xlsx("Data/AuthRankCorr.xlsx", sheet = 1)

# Calculate kendall's tau with treatment for ties
rankings <- c("Z_RAW","Z_H_INDEX","Z_M_INDEX","AOZORA","TB_RAW")
tau_matrix <- data.frame(matrix(nrow = 5, ncol = 5))
rownames(tau_matrix) <- rankings
colnames(tau_matrix) <- rankings
for (i in 1:length(rankings)){
  for (j in 1:length(rankings)){
    tau_matrix[i, j] = tau_b(meta[, rankings[i]], meta[, rankings[j]])
  }
}

# Calculate tau_AP with treatment for ties
rankings <- c("Z_RAW","Z_H_INDEX","Z_M_INDEX","AOZORA","TB_RAW")
tauAP_matrix <- data.frame(matrix(nrow = 5, ncol = 5))
rownames(tauAP_matrix) <- rankings
colnames(tauAP_matrix) <- rankings
for (i in 1:length(rankings)){
  for (j in 1:length(rankings)){
    tauAP_matrix[i, j] = tauAP_b(meta[, rankings[i]], meta[, rankings[j]], decreasing = FALSE)
  }
}

#############################
# Plot the correlation matrix
# Figure 2.15
# http://www.sthda.com/english/wiki/ggplot2-quick-correlation-matrix-heatmap-r-software-and-data-visualization
#############################

library(reshape2)
library(ggplot2)

#rename columns and rows
rownames(tau_matrix) <- c("Zenshu_Raw","Zenshu_H","Zenshu_M","Aozora","Textbooks")
colnames(tau_matrix) <- c("Zenshu_Raw","Zenshu_H","Zenshu_M","Aozora","Textbooks")

#round the values to 2 decimal points
tau_matrix <- round(tau_matrix, 2)

# Get lower triangle of the correlation matrix
get_lower_tri<-function(tau_matrix){
  tau_matrix[upper.tri(tau_matrix)] <- NA
  return(tau_matrix)
}

# Get upper triangle of the correlation matrix
get_upper_tri <- function(tau_matrix){
  tau_matrix[lower.tri(tau_matrix)]<- NA
  return(tau_matrix)
}

#re-order the correlation matrix
reorder_tau <- function(tau_matrix){
  # Use correlation between variables as distance
  dd <- as.dist((1-tau_matrix)/2)
  hc <- hclust(dd)
  tau_matrix <- tau_matrix[hc$order, hc$order]
}

tau_matrix <- reorder_tau(tau_matrix)
upper_tri <- get_upper_tri(tau_matrix)

# Melt the correlation matrix
melted_tau <- melt(as.matrix(upper_tri), na.rm = TRUE)
melted_tau$type <- ifelse(melted_tau$value < 1, "black", "white")
# Heatmap
ggheatmap <- ggplot(data = melted_tau, aes(Var2, Var1, fill = value)) + geom_tile(color = "white") +
  scale_fill_gradient2(low = "white", high = "black", mid = "grey", 
                       midpoint = 0.5, limit = c(0,1), space = "Lab", 
                       name="Correlation Value") +
  theme_minimal()+ theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1),
                         axis.text.y = element_text(size=12)) +
  coord_fixed()

ggheatmap + 
  geom_text(aes(Var2, Var1, label = value, colour=type), size = 4) +
  scale_colour_manual(values=c("black", "white"), guide=FALSE) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "none")

    #legend.justification = c(1, 0),
    #legend.position = c(0.5, 0.7),
    #legend.direction = "horizontal") +
  #guides(fill = guide_colorbar(barwidth = 7, barheight = 1,
  #                             title.position = "top", title.hjust = 0.5))

