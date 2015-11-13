#!/usr/bin/python

import fileinput
import os
import csv

def printCSV(Data, outFile):
    print("writing output to: " + outFile + "\n")
    with open(outFile, "w") as out:
        csv_out=csv.writer(out)
        for row in Data:
            csv_out.writerow(row)

def getMetrics(fileName):
    info_buffer = [0]*4
    print("opening file... \n" + filename)
    file = open(filename , 'r')
    row = file.readlines()
    info_buffer[0] = str(filename)
    for line in row:
    # Grab the Elapsed time
        if line.find("Elapsed time") > -1:
            info = line.split()
            time = info[3]
            info_buffer[1] = time
        # Grab the Grind time
	if line.find("Grind time") > -1:
	    info = line.split()
	    Gtime = info[4]
	    info_buffer[2] = Gtime
        # Grab the FOM
	if line.find("FOM") > -1:
	    info = line.split()
	    FOM = info [2]
	    info_buffer[3] = FOM
    # Make the info_buffer a tuple
    # Close the file
	file.close()
	return(tuple(info_buffer))

# Set-up of structures
Data = [("filename", "Elapsed time", "Grind time", "FOM")]

# Iterate through all the files in the current directory and
# grab the relevant information from all the *.out files.
for filename in os.listdir(os.getcwd()):
    if filename.endswith(".out"):
        Data.append(getMetrics(filename))

# output the data to .csv
outFile = "output.csv"
printCSV(Data, outFile)
