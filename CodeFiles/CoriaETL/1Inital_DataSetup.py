#This function should be executed in the beginning of data setup.
# all data files from 2007 will be downloaded, transofromed to csv and uploaded to MySQL DB.
# At the end the total time of initialisation will be printed (variable TotalTime)
import urllib2,urllib, io, gzip, os, time, lxml.html, datetime
from CsvCreate import CsvCreate # file: CsvCreate.py
from  Csv2CoriaDB import Csv2CoriaDB
import time,lxml.html

Beginn = datetime.datetime.now()
print "Starting time: " + str(Beginn)

#currentyear needed because of folder structure in Caida
CurrentYear = time.strftime("%Y")
print CurrentYear

#YearBefore = int(CurrentYear)-1
#Initial upload of all Caida data sets:
#YearBefore= 2007
YearBefore = 2007

print "\n Bearbeitung Jahr" + str(YearBefore) + "\n"

while YearBefore <= int(CurrentYear):
	Caida = "http://data.caida.org/datasets/topology/ark/ipv4/as-links/team-1/" + str(YearBefore) +"/"

	# extract File name list
	connection = urllib2.urlopen(Caida)
	Liste = []
	dom =  lxml.html.fromstring(connection.read())
	for link in dom.xpath('//a/@href'): # select the url in href for all a tags(links)
	    Liste.append(Caida + str(link))
	print Liste
	connection.close()

	print "###################################################################################"

	for j in Liste:
		j2= j.rsplit('/')[-1]
		j3= j2.split('.gz')[0]

		if "cycle-as" in j:
			if os.path.isfile("Data/Original/"+j3):
				print "!!Wurde bereits verarbeitet: " + j3
			else:
				print "## Download und Verarbeitung: " + j3
				response = urllib.urlopen(j)
				compressed_file = io.BytesIO(response.read())
				decompressed_file = gzip.GzipFile(fileobj=compressed_file)
				Filename= "Data/Original/" + j3
				with open(Filename, 'wb') as outfile:
					outfile.write(decompressed_file.read())
					outfile.close()
				#Create a Csv file from download 
				CsvCreate(j3)
				#Upload to Coria databse 
				Csv2CoriaDB(j3)

	YearBefore+=1


else:
	
	print "XXX Done XXX \n"

Ende = datetime.datetime.now()

print " \nTotal Time: " +  str(Ende-Beginn)