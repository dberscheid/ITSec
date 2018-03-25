#graph for as classification

library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(RColorBrewer)


PATH <- "datensätze/as-classification/"

fileList <- list.files(PATH) #gives all the folder names

#unzip the files
ListComplete <- paste0(PATH,fileList)
sapply(ListComplete, R.utils::gunzip)


classi <- read.delim("datensätze/as-classification/20150801.as2types.txt", sep = "|")
#remove the first few rows, which are just some pre information
classi <- classi[-(1:5),]
classi$AS <- classi$X..format..as
classi$X..format..as <- NULL
  
#get some descriptive statistics of the data set
summary(classi)

# source                  type             AS       
# :    0                 :    0   1      :    1  
# CAIDA_class :46329   Content       : 2340   10     :    1  
# Enterpise   :    0   Enterpise     :27446   100    :    1  
# manual_class:  783   Transit/Access:21721   1000   :    1  
# peerDB_class: 4395                          10000  :    1  
#                                             10001  :    1  
#                                             (Other):51501 
value <- c()
# value[1] <- summary(classi$type)[[2]] #type content
# value[2] <- summary(classi$type)[[3]] #type enterprise
# value[3] <- summary(classi$type)[[4]] #type transit/access

group <- c()
group[1] <- "content"
group[2] <- "enterprise"
group[3] <- "transit/access"



length(classi$type)# total: 51507

#percentage of content ASes:
value[1] <- percContent <- summary(classi$type)[[2]]/ length(classi$type)
# [1] 0.04543072

#percentage of enterprise ASes:
value[2] <- percEnt <- summary(classi$type)[[3]]/ length(classi$type)
# [1] 0.5328596

#percentage of transit/access ASes:
value[3] <- percTrans <- summary(classi$type)[[4]]/ length(classi$type)
# [1] 0.4217097

#make a data frame
df <- data.frame(
  group,
  value
)

#make a pie chart:

# Barplot
bp<- ggplot(df, aes(x="", y=value, fill=group))+
  geom_bar(width = 1, stat = "identity")
bp


blank_theme <- theme_minimal()+
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.border = element_blank(),
    panel.grid=element_blank(),
    axis.ticks = element_blank(),
    plot.title=element_text(size=14, face="bold")
  )

png("asClassificationPie.png", width = 1200, height = 800, units = 'px', res = 200)

pie <- bp + coord_polar("y", start=0)  +
  scale_fill_brewer("Type of AS") + blank_theme +
  theme(axis.text.x=element_blank(),
        legend.title = element_text("Type"))+
  geom_text(aes(x = 1.3, y = value, label = percent(value)))
  
dev.off()       
