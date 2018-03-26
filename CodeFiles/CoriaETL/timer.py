#!/usr/bin/env python
import time, subprocess

while True:
	Frequency = 60*60*24
	time.sleep(Frequency)
	subprocess.call(["python", "main.py"])
		
	except:
		print("Something went wrong. Restarting in"+ str(Frequency/(60*60))+" hours.")
		continue