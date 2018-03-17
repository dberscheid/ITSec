#Gaph of AS locations and its flows of traffic around the world 

library(dplyr)
library(tidyr)
library(ggplot2)
library(ggmap)
library(tidyverse)
library(maps)
library(geosphere)
library(mapdata)


PATH <- "datensätze/as-relationships-geo/"
fileList <- list.files(PATH) #gives all the folder names

#unzip the files
ListComplete <- paste0(PATH,fileList)
sapply(ListComplete, R.utils::gunzip)


# I already deleted the unwanted information from the head of the file. (out of the raw document)
geodata <- read.delim("datensätze/as-relationships-geo/201603.as-rel-geo.txt", sep = "|")
geodata <- geodata %>% 
  rename(AS0 = X3) %>% 
  rename(AS1 = X3356) %>% 
  rename(location0 = Boston.MA.US.bc) %>% 
  rename(location1 = San.Jose.CA.US.bc)


locationData <- geodata %>% 
  separate(location0 , "location0", sep = "-") %>% 
  separate(location1 , "location1", sep = "-")  

#get unique names of locations
#add lat and lon

cities <- unique(as.character(locationData$location0))
cities1 <- unique(as.character(locationData$location1))


#get lon and lat of each unique city
lonlat <- geocode(cities)
lonlat1 <- geocode(cities1)

sum(!is.na(lonlat) == TRUE) #1616 / 674 (found vs. not found)
sum(!is.na(lonlat1) == TRUE) #1616 / 674 (found vs. not found)


df <- as.data.frame(unique(cities)) %>%
  rename(cities = `unique(cities)`) %>%
  cbind(lonlat)


df1 <- as.data.frame(unique(cities1)) %>%
  rename(cities1 = `unique(cities1)`) %>%
  cbind(lonlat1)

dfComplete <- df[!is.na(df$lon),]
dfComplete <- df[!is.na(df$lat),]

dfComplete1 <- df[!is.na(df1$lon),]
dfComplete1 <- df[!is.na(df1$lat),]


dfComplete <- dfComplete %>% 
  rename(location0 = cities)

dfComplete1 <- dfComplete1 %>% 
  rename(location1 = cities) %>% 
  rename(lon1 = lon) %>% 
  rename(lat1 = lat) 

### at this point we have locationData and dfComplete 
#now: match them 
locationData <- locationData %>% 
  right_join(dfComplete, by= "location0")

locationData <- locationData %>% 
  right_join(dfComplete1, by = "location1")

locationData <- locationData %>% 
  rename(lon = lon.x) %>% 
  rename(lat = lat.x)

#summarise
dfSummary <- locationData %>% 
  group_by(AS0)

           
#make a map with connections 
#only: where are the connections coming from and where to, not how many... 
#helper function:
plot_my_connection <- function( dep_lon, dep_lat, arr_lon, arr_lat, ...){
  inter <- gcIntermediate(c(dep_lon, dep_lat), c(arr_lon, arr_lat), n=50, addStartEnd=TRUE, breakAtDateLine=F)             
  inter=data.frame(inter)
  diff_of_lon=abs(dep_lon) + abs(arr_lon)
  if(diff_of_lon > 180){
    lines(subset(inter, lon>=0), ...)
    lines(subset(inter, lon<0), ...)
  }else{
    lines(inter, ...)
  }
}



# png(file="mygraphic.png",width=1200,height=800)
map('world',col="#f2f2f2", fill=TRUE, bg="white" , lwd=0.05, border=0, ylim=c(-80,80), mar=rep(0,4)) 
points(x=dfSummary$lon, y=dfSummary$lat, col="slateblue", cex=3, pch=20)


png(file="relationsWorld.png",width=1200,height=800)

  world <- map_data(map = "world") # we already did this, but we can do it again
  g1 <- ggplot() + geom_polygon(data = world, aes(x=long, y = lat, group = group)) + 
    coord_fixed(1.3) 
  g1 + 
    geom_point(data = dfSummary, aes(x = lon, y = lat), color = "orange", size = 2)

dev.off()



png(file="connectionsWorld.png",width=1200,height=800)

# world <- map_data(map = "world") # we already did this, but we can do it again
  g1 <- ggplot() + geom_polygon(data = world, aes(x=long, y = lat, group = group)) + 
    coord_fixed(1.3) 
  
  g1 + 
    geom_point(data = dfSummary, aes(x = lon, y = lat), color = "orange", size = 2)
  
  
  for(i in 1:length(dfSummary$AS0)) {
    plot_my_connection(dfSummary$lon[i], dfSummary$lat[i],  dfSummary$lon1[i], dfSummary$lat1[i], col="slateblue", lwd=1)
    inter <- gcIntermediate(c(dfSummary$lon[i], dfSummary$lat[i]),  c(dfSummary$lon1[i], dfSummary$lat1[i]), n=50, addStartEnd=TRUE, breakAtDateLine=F)
    lines(inter, col="slateblue", lwd=1)
  }
  
dev.off()


#------------------------------------------

worldlocations <- as.data.frame(dfSummary$lon)

worldlocations <- worldlocations %>% 
  cbind(dfSummary$lat, dfSummary$lon1, dfSummary$lat1)

worldlocations <- worldlocations[!is.na(worldlocations[,4]),]

#remove the locations where the starting point is also the end point 
remove <- which(worldlocations$`dfSummary$lon` == worldlocations$`dfSummary$lon1` & worldlocations$`dfSummary$lat` == worldlocations$`dfSummary$lat1`)


worldlocations <- worldlocations[-remove,]
png(file="connectedASes.png",width=1200,height=800)

g1 + 
  geom_point(data=worldlocations, aes(x = worldlocations[,1], y = worldlocations[,2]), col = "orange") +
  geom_curve(data=worldlocations, aes(x = worldlocations[,1], y = worldlocations[,2], xend = worldlocations[,3], yend = worldlocations[,4]), 
             col = "orange", size = 0.05, curvature = .2) +
  geom_point(data=worldlocations, aes(x = worldlocations[,3], y = worldlocations[,4]), col = "orange")

dev.off()


png(file="connectedASesOHnePunkte.png",width=1200,height=800)

g1 + 
  # geom_point(data=worldlocations, aes(x = worldlocations[,1], y = worldlocations[,2]), col = "orange") +
  geom_curve(data=worldlocations, aes(x = worldlocations[,1], y = worldlocations[,2], xend = worldlocations[,3], yend = worldlocations[,4]), 
             col = "orange", size = 0.05, curvature = .2) 
  # geom_point(data=worldlocations, aes(x = worldlocations[,3], y = worldlocations[,4]), col = "orange")

dev.off()




png(file="ASesNurPunkte.png",width=1200,height=800)

g1 + 
  geom_point(data=worldlocations, aes(x = worldlocations[,1], y = worldlocations[,2]), col = "orange") +
  # geom_curve(data=worldlocations, aes(x = worldlocations[,1], y = worldlocations[,2], xend = worldlocations[,3], yend = worldlocations[,4]), 
  # col = "orange", size = 0.05, curvature = .2) 
  geom_point(data=worldlocations, aes(x = worldlocations[,3], y = worldlocations[,4]), col = "orange")

dev.off()


