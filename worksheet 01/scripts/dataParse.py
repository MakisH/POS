#!/usr/bin/python

import fileinput
import os
import csv

Data = [("filename", "Elapsed time", "Grind time", "FOM")]
tup = [0]*4
for i in os.listdir(os.getcwd()):
    if i.endswith(".txt"):
	print("opening file... \n" + i)
	file = open(i , 'r')
	row = file.readlines()
	tup[0] = str(i)
	for line in row:
	    if line.find("Elapsed time") > -1:
		info = line.split()
	        title = ' '.join([i, info[0] , info[1]])
		time = info[3]
		tup[1] = time
	    if line.find("Grind time") > -1:
		info = line.split()
		Gtime = info[4]
		tup[2] = Gtime
	    if line.find("FOM") > -1:
		info = line.split()
		FOM = info [2]
		tup[3] = FOM
#	print(" ".join([title,  "=", time, Gtime, FOM]))
	Data.append(tuple(tup))
	file.close()
#TODO output data to .csv
outFile = "output.ods"
print("writing output to: " + outFile + "\n")
with open(outFile, "w") as out:
    csv_out=csv.writer(out)
#    csv_out.writerow(['name','num'])
    for row in Data:
        csv_out.writerow(row)

#print(Data)
