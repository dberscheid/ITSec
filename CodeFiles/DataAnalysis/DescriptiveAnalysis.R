#Descriptive Graphs of AS Distributions
#Results will be: Distribution of sinding AS nodes and Distribution of receiving AS nodes

library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)


data <- read.delim("cycle-aslinks.l7.t1.c006187.20171204.txt", sep = " ")

data <- data %>% 
  filter(grepl("D",data$X.INFO.)) %>% 
  select(X.INFO.) %>% 
  rename(aslinkinformation = X.INFO.) 

data$from_AS <- NA
data$to_AS <- NA
data$monitor_key1 <- NA



dataD <- read.csv("aslinksData.csv", sep = "", header = T)

  

dataAsLinks <- as.data.frame(str_split_fixed(dataD$aslinkinformation, "",2)) %>% 
  rename(Direct = V1)

    # dataAsLinks <- dataAsLinks %>%
    #   as.character(dataAsLinks$V2)
    # 
    # dataAsLinks <- dataAsLinks %>%
    #   separate(dataAsLinks, V2, as_to, "")
    # 
    # 
    # dataAsLinks$as._to <- as.data.frame(str_split_fixed(dataAsLinks$V2, "",))

dataAsLinks$as_From <- NA
#split each value in new column
for (i in 1:length(dataAsLinks$Direct)){
  
  dataAsLinks$as_From[i] <- dataAsLinks$transformation[[i]][2]
  dataAsLinks$as_To[i] <- dataAsLinks$transformation[[i]][3]
  dataAsLinks$Details[i] <- dataAsLinks$transformation[[i]]
}

dataAsLinks$uniqueconnection <- paste0(dataAsLinks$as_From,dataAsLinks$as_To)
dataAsLinks$V2 <- NULL
dataAsLinks$as_From <- as.numeric(dataAsLinks$as_From) 
dataAsLinks$as_To <- as.numeric(dataAsLinks$as_To)
dataAsLinks$uniqueconnection <- as.numeric(dataAsLinks$uniqueconnection)


#frequency of each node in the data set
#choose between absolute and relative values
ggplotFrom <- ggplot(dataAsLinks,aes(x=as_From)) +
  geom_histogram(fill="lightblue",aes(y=..count../sum(..count..)))
  # geom_histogram(fill="lightblue",aes(y=..count..))
ggplotFrom

ggplotTo <- ggplot(dataAsLinks,aes(x=as_To)) +
  geom_histogram(fill="lightblue",aes(y=..count../sum(..count..)))
  # geom_histogram(fill="lightblue",aes(y=..count..))
ggplotTo




#data set: most recent one from December 2017
save( dataAsLinks, file = "ASTable.RData") 

length(unique(dataAsLinks$as_From))
# [1] 5573 #number of differen ASes that sent traffic

length(unique(dataAsLinks$as_To))
# [1] 24739 #number of differen ASes that received traffic


# final plot outputs

#distirbution of sending AS:
sumAs <- dataAsLinks %>% 
  group_by(as_From) %>% 
  summarize(count = n())

sumAs <- sumAs[!is.na(sumAs$as_From),]
sumAs <- arrange(sumAs, desc(count))
sumAs$rank <- seq(1:length(sumAs$count))



png("AsFromDistribution.png", width = 450, height = 500, units = "px")
  
gg <- ggplot(sumAs, aes(x = rank, y = count), stat= "identity") +
    geom_point() +
    ylab("Number an As is sending to")+
    xlab("Rank")
  gg
  
dev.off()


  

#distirbution of receiving AS:
sumAsTo <- dataAsLinks %>% 
  group_by(as_To) %>% 
  summarize(count = n())

sumAsTo <- arrange(sumAsTo, desc(count))
sumAsTo <- sumAsTo[!is.na(sumAsTo$as_To),]
sumAsTo$rank <- seq(1:length(sumAsTo$count))



png("AsToDistribution.png", width = 450, height = 500, units = "px")

  ggTo <- ggplot(sumAsTo, aes(x = rank, y = count), stat= "identity") +
    geom_point() +
    ylab("Number of AS an As is receiving from") +
    xlab("Rank")
  ggTo

dev.off()


