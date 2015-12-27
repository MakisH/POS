#!/usr/bin/python
#!/usr/bin/python -tt

# python -m tabnanny FlagTesting.py checks for indentation problems
#----------------------------------------------
# TO USE THIS FILE, TURN ON OMP IN MAKE FILE
# also pay attention to output file configuration

import itertools
import os
import sys
import time
import fileinput
import subprocess

#intel = ["-march=native", "-xHost", "-unroll", "-ipo"]
#gcc = ["-march=native","-fomit-frame-pointer","-floop-block","-floop-interchange","-floop-strip-mine","-funroll-loops","-flto"]
script_name = "job_openmp.ll"

#flag_string = []

#for i in range(0, len(intel) + 1):
	#combination = list(itertools.combinations(intel,i))
	#flag_string.extend(map(' '.join, combination))
numThreads = [1, 2, 4, 8, 16]

for j in range(0, len(numThreads)-1):
	LLoutput = open('tmp.ll',"w")
	LLinput = open(script_name,'r+')
	os.environ['OMP_NUM_THREADS'] = str(numThreads[j])
	print("make fresh!!!!!!!\n")
	subprocess.call("make fresh", shell = True)
	os.environ['OUTPUT_FILE_NAME'] = "out/openmp/pos_lulesh_OMP_" + str(numThreads[j]) + "_$(jobid).out"
	os.environ['ERROR_FILE_NAME'] = "out/openmp/pos_lulesh_OMP_" + str(numThreads[j])  + "_$(jobid).error.out"
	row_in = LLinput.readlines()
	print("writing tmp.ll..... \n")
	for line in row_in:
		LLoutput.write(os.path.expandvars(line))
	
	LLoutput.close()	
	LLinput.close()

	#submit job to load leveler with temporary .ll file
	subprocess.call(["llsubmit tmp.ll"], shell=True)
	time.sleep(2)
	#subprocess.call(["rm tmp.ll"], shell = True)





