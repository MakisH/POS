#!/usr/bin/python
#!/usr/bin/python -tt

# python -m tabnanny FlagTesting.py checks for indentation problems

import itertools
import os
import sys
import time
import fileinput
import subprocess

intel = ["-march=native", "-xHost", "-unroll", "-ipo"]
gcc = ["-march=native","-fomit-frame-pointer","-floop-block","-floop-interchange","-floop-strip-mine","-funroll-loops","-flto"]
script_name = "flagtest.ll"

flag_string = []

for i in range(0, len(intel) + 1):
	combination = list(itertools.combinations(intel,i))
	flag_string.extend(map(' '.join, combination))

for j in range(0, len(flag_string) -1):
	LLoutput = open('tmp.ll',"w")
	LLinput = open(script_name,'r+')
	os.environ['OPTIM_FLAGS'] = str(flag_string[j])
	print("make fresh!!!!!!!\n")
	subprocess.call("make fresh", shell = True)
	current_flag_string = flag_string[j]
	flags = current_flag_string.replace(" ", "")
	flags = flags.replace(".", "")
	flags = flags.replace("-", "_")
	os.environ['OUTPUT_FILE_NAME'] = "pos_lulesh_seq_" + flags + "_$(jobid).out"
	os.environ['ERROR_FILE_NAME'] = "pos_lulesh_seq_" + flags + "_$(jobid).error.out"
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





