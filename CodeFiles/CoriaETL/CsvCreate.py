def CsvCreate(Filename):
	import re
	#Filename = "cycle-aslinks.l7.t1.c000027.20070913.txt"
	CsvName= Filename.rsplit('.')[-2]
	CsvName= CsvName.split('.txt')[0]


	regex = re.compile("^D\t\d+\t\d+")
	with open("Data/Csv/"+CsvName + ".csv","a") as file:
		with open("Data/Original/" + Filename) as f:
		    for line in f:
		        if regex.search(line):
		        	match =regex.search(line)
		        	
		        	file.write(str(match.group(0)+"\n")[2:])

	return CsvName
#CsvCreate("cycle-aslinks.l7.t1.c000027.20070913.txt")
