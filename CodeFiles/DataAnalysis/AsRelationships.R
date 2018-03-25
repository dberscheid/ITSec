#Analyzing the Relationship beween ASes

library(dplyr)
library(tidyr)
library(ggplot2)

PATH <- "datensätze/as-relationships"


#take one recent dataset from 2018 as sample
# I already deleted the unwanted information from the head of the file. (out of the raw document)
relData <- read.delim("datensätze/as-relationships/20180101.as-rel.txt", sep = "|")

#preparation:
relData <- relData[-(1:123), -c(4,5)]
relData <- relData %>% 
  rename(providerAS = X..source.topology) %>% 
  rename(customerAS = BGP) %>% 
  rename(relType = X20180101)

relData$relType <- as.factor(relData$relType)

#if -1 then it is provider and customer 
# if 0 then it is peer to peer 

#distribution of relationship type
value <- NA

frame <- as.data.frame(value)

frame$value <- summary(relData$relType)[1] #117703 #number of provider - customer - relationships
frame[2,1] <- summary(relData$relType)[2] #143637 #number of peer to peer relationships

frame$relation <- c("P2C", "P2P")

#   value     relation
# 1 117703      C2P
# 2 143637      P2P



png(file="relationspeerandprovider.png",width=400,height=400)

  ggplot(data = frame,
         aes(relation, value)) +
    geom_bar(stat = "identity") +
    ylim(0, 160000)
  
dev.off() 



