from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import Select,WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time,os

chrome_options = Options()  
chrome_options.add_argument("--headless --disable-gpu --headless --no-sandbox")  

def Csv2CoriaDB(Filename):
	Filename= Filename.rsplit('.')[-2]
	Filename= Filename.split('.txt')[0]
	#download chromedriver and give Path to chromedriver.exe
	driver = webdriver.Chrome("C:\Python27\Scripts\chromedriver.exe", chrome_options=chrome_options)


	#def CsvUpload:
	driver.get("http://localhost:8080/coria/#!/datasets/upload")
	driver.implicitly_wait(5)

	#select "tab-separated-importer"
	select = driver.find_element_by_xpath('//*[@id="import.providers"]/option[6]').click()

	#send name
	
	element = driver.find_element_by_xpath('//*[@id="import.name"]')
	element.send_keys(Filename)

	#choose dataset
	path= os.getcwd()
	file = str(path + "/Data\Csv\\" + Filename + ".csv")

	#file = 'C:\caida\Data_Csv\20180101.csv'
	#driver.find_element_by_xpath('//*[@id="file"]'').send_keys(os.getcwd("C:\Users\Carlimero\Downloads\datastructrue.txt")')
	file_input = driver.find_element_by_xpath('//*[@id="file"]')
	file_input.send_keys(file)
	#time.sleep(5)

	#submit data
	driver.find_element_by_xpath('//*[@id="import"]/button').click()

	time.sleep(3)
	driver.quit()

	print(Filename + "uploaded to Coria database")






# elem = driver.find_element_by_name("q")
# elem.clear()
# elem.send_keys("pycon")
# elem.send_keys(Keys.RETURN)
# assert "No results found." not in driver.page_source
# driver.close()

# //*[@id="import.providers"]/option[6]



