#Creating Time Series Results of AS Developments

library(utils)
library(R.utils)
library(dplyr)
library(stringr)


PATH <- "datensätze/alle/"

fileList <- list.files(PATH) #gives all the folder names



#only run once! 
#--
ListComplete <- paste0(PATH,fileList)
sapply(ListComplete, R.utils::gunzip)
#--

ListExtracted <- list.files(PATH) #worked: only txt files now


# load in the right format...
# only extract the information that is wanted 

 
#prepare needed variables and data frames
dataAgg <- as.data.frame(ListExtracted)
dataAgg$LuniqueASFrom <- NA
dataAgg$LuniqueASTo <- NA
dataAgg$LuniqueConnection <- NA
dataAgg$avgConASFrom <- NA
dataAgg$avgConASTo <- NA
LuniqueASFrom <- NA
LuniqueASTo <- NA
LuniqueConnection <- NA
avgConASFrom <- NA
avgConASTo <- NA

#final data frame needed for later 
completeResults <- data.frame( LuniqueASFrom, LuniqueASTo, LuniqueConnection, avgConASFrom, avgConASTo)
completeResults

#ATTENTION: running the following part is highly time consuming! 
for(j in 1:length(ListExtracted)){ 
  data <- read.delim((paste0(PATH,ListExtracted[j])), sep = " ")
  
  #data transformation
  data <- data %>% 
    filter(grepl("D",data$X.INFO.)) %>% 
    select(X.INFO.) %>% 
    rename(aslinkinformation = X.INFO.) 
  
  write.csv(data, "aslinksData.csv", row.names = FALSE)
  dataD <- read.csv("aslinksData.csv", sep = "", header = T)
  
  dataAsLinks <- as.data.frame(str_split_fixed(dataD$aslinkinformation, "",2)) %>% 
    rename(Direct = V1)
  dataAsLinks$transformation <- strsplit(as.character(dataAsLinks$V2), "\t")
  
  for (i in 1:length(dataAsLinks$Direct)){
    
    #calculate metrics for each log file
    dataAsLinks$as_From[i] <- dataAsLinks$transformation[[i]][2]
    dataAsLinks$as_To[i] <- dataAsLinks$transformation[[i]][3]
    dataAsLinks$Details[i] <- dataAsLinks$transformation[[i]]
  }
  
  dataAsLinks$uniqueconnection <- paste0(dataAsLinks$as_From,dataAsLinks$as_To)
  dataAsLinks$V2 <- NULL
  dataAsLinks$as_From <- as.numeric(dataAsLinks$as_From) 
  dataAsLinks$as_To <- as.numeric(dataAsLinks$as_To)
  dataAsLinks$uniqueconnection <- as.numeric(dataAsLinks$uniqueconnection)
  
  #1) extrct numbers of AS_froms 
  uniqueASFrom <- unique(dataAsLinks$as_From) #length = 5542
  values <- as.data.frame(uniqueASFrom)
  
  for(i in 1:length(uniqueASFrom)){ 
    values$lengthASFrom[i] <- length(dataAsLinks$as_From[which(dataAsLinks$as_From == uniqueASFrom[i])])
  }
  
  

  #for time series analysis:
  #KPIs to compare over time:
  #number of unique as_froms 
  LuniqueASFrom <- length(uniqueASFrom)  #length = 5542
  #numver of unique as_tos
  LuniqueASTo <- length(unique(dataAsLinks$as_To)) #length = 24603
  #unique connections
  LuniqueConnection <- length(unique(dataAsLinks$uniqueconnection)) #length = 49544
  #number of multiorigins 
  
  #number of average AS_from connections
  avgConASFrom <- length(dataAsLinks$as_From)/LuniqueASFrom
  
  #number of average AS_To connections
  avgConASTo <- length(dataAsLinks$as_To)/LuniqueASTo 
  
  #put all the results
  completeResults[j, ] = c(LuniqueASFrom, LuniqueASTo, LuniqueConnection, avgConASFrom, avgConASTo)
}


#write csv 
write.csv(completeResults, "asLinksLoopResults.csv")


#add ID column
idseq <- seq(from = 1, to = j)
completeResults <- cbind(idseq, completeResults)

#make a backup
# backupCompleteResults <- completeResults


#plot time series graphs
 
png(file="ASFromAll.png", width=600,height=400)
 
ggUniqueASFromAll <- ggplot(completeResultsBis17) +
  geom_line(aes(x = IdTime, y= LuniqueASFrom)) +
  xlab("Time (daily)") +
  ylab("Number of sending AS Nodes")+ 
  annotate("text", x= 0 , y= 6500, label= "07", size = 2) +
  annotate("text", x= 150 , y= 6500, label= "08", size = 2) +
  annotate("text", x= 300 , y= 6500, label= "09", size = 2) +
  annotate("text", x= 430 , y= 6500, label= "10", size = 2) +
  annotate("text", x= 600 , y= 6500, label= "11", size = 2) +
  annotate("text", x= 800 , y= 6500, label= "12", size = 2) +
  annotate("text", x= 950 , y= 6500, label= "13", size = 2) +
  annotate("text", x= 1200 , y= 6500, label= "14", size = 2) +
  annotate("text", x= 1400, y= 6500, label= "15", size = 2) +
  annotate("text", x= 1650 , y= 6500, label= "16", size = 2) +
  annotate("text", x= 1900, y= 6500, label= "17", size = 2) +

  geom_vline(aes(xintercept = 38), color = "darkred") +
  geom_vline(aes(xintercept = 204), color = "darkred") +
  geom_vline(aes(xintercept = 361), color = "darkred") +
  geom_vline(aes(xintercept = 520), color = "darkred") +
  geom_vline(aes(xintercept = 701), color = "darkred") +
  geom_vline(aes(xintercept = 869), color = "darkred") +
  geom_vline(aes(xintercept = 1076), color = "darkred") +
  geom_vline(aes(xintercept = 1281), color = "darkred") +
  geom_vline(aes(xintercept = 1505), color = "darkred") +
  geom_vline(aes(xintercept = 1777), color = "darkred")   
ggUniqueASFromAll

dev.off()


png(file="ASToAll.png", width=600,height=400)

ggUniqueASToAll <- ggplot(completeResultsBis17) +
  geom_line(aes(x = IdTime, y= LuniqueASTo)) +
  xlab("Time (daily)") +
  ylab("Number of receiving AS Nodes") +
  annotate("text", x= 0 , y= 29000, label= "07", size = 2) +
  annotate("text", x= 150 , y= 29000, label= "08", size = 2) +
  annotate("text", x= 300 , y= 29000, label= "09", size = 2) +
  annotate("text", x= 430 , y= 29000, label= "10", size = 2) +
  annotate("text", x= 600 , y= 29000, label= "11", size = 2) +
  annotate("text", x= 800 , y= 29000, label= "12", size = 2) +
  annotate("text", x= 950 , y= 29000, label= "13", size = 2) +
  annotate("text", x= 1200 , y= 29000, label= "14", size = 2) +
  annotate("text", x= 1400, y= 29000, label= "15", size = 2) +
  annotate("text", x= 1650 , y= 29000, label= "16", size = 2) +
  annotate("text", x= 1900, y= 29000, label= "17", size = 2) +
  
  geom_vline(aes(xintercept = 38), color = "darkred", size = 0.01) +
  geom_vline(aes(xintercept = 204), color = "darkred") +
  geom_vline(aes(xintercept = 361), color = "darkred") +
  geom_vline(aes(xintercept = 520), color = "darkred") +
  geom_vline(aes(xintercept = 701), color = "darkred") +
  geom_vline(aes(xintercept = 869), color = "darkred") +
  geom_vline(aes(xintercept = 1076), color = "darkred") +
  geom_vline(aes(xintercept = 1281), color = "darkred") +
  geom_vline(aes(xintercept = 1505), color = "darkred") +
  geom_vline(aes(xintercept = 1777), color = "darkred")   

ggUniqueASToAll

dev.off()



png(file="uniqueConnectionsAll.png", width=600,height=400)

ggLuniqueConnectionAll <- ggplot(completeResultsBis17) +
  geom_line(aes(x = IdTime, y= LuniqueConnection)) +
  xlab("Time (daily)") +
  ylab("Number of unique AS connections")
ggLuniqueConnectionAll

dev.off()


png(file="ggavgConASFromAll.png", width=600,height=400)

ggavgConASFromAll <- ggplot(completeResultsBis17) +
  geom_line(aes(x = IdTime, y= avgConASFrom)) +

  xlab("Time (daily)") +
  ylab("Average number of outgoing connections")
ggavgConASFromAll

dev.off()


png(file="ggavgConASToAll.png", width=600,height=400)

ggavgConASToAll <- ggplot(completeResultsBis17) +
  geom_line(aes(x = IdTime, y= avgConASTo)) +
  xlab("Time (daily)") +
  ylab("Average number of incoming connections")
ggavgConASToAll


dev.off()

#save image
save.image("CompleteResults.RData")
