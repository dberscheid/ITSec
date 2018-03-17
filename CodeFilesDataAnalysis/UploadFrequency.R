#Graph about Uploading Frequency
library(ggplot2)

uploads <- read.csv("datensätze/UploadFrequency.csv", sep = ";")
uploads$Datum <- as.Date(uploads$Datum, format = "%d.%m.%Y")


png(file="uploadFrequency.png",width=500,height=300)

ggplot(data = uploads,
       aes(Datum, AnzahlUploads )) +
  geom_bar(stat = "identity") +
  xlim("2016-01-29", "2018-03-15") +
scale_x_date(date_breaks = "8 weeks", date_labels = "%m.%Y")+
theme(axis.text.x=element_text(angle=40, hjust=1)) +
  labs(x = "Date", y = "Uploads")

dev.off()

