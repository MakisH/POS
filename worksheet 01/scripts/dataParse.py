#!/usr/bin/python

import fileinput
import os
import csv

# Set-up of structures
Data = [("filename", "Elapsed time", "Grind time", "FOM")]
info_buffer = [0]*4

# Iterate through all the files in the current directory and
# grab the relevant information from all the *.out files.
for filename in os.listdir(os.getcwd()):
    if filename.endswith(".out"):
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
	Data.append(tuple(info_buffer))
    # Close the file
	file.close()

# output the data to .csv
outFile = "output.csv"
print("writing output to: " + outFile + "\n")
with open(outFile, "w") as out:
    csv_out=csv.writer(out)
    for row in Data:
        csv_out.writerow(row)
