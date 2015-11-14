#!/usr/bin/python

import itertools
import os
import sys
import time
import fileinput
import subprocess

test_all = 1
intel = ["-march=native", "-xHost", "-unroll", "-ipo"]
gcc = ["-march=native","-fomit-frame-pointer","-floop-block","-floop-interchange","-floop-strip-mine","-funroll-loops","-flto"]
script_name = "flagtest.ll"

#create new temp file with environment variables replaced with flags
LLinput = open(script_name,'r+')
output_searchline = 'pos_lulesh_seq_$(jobid).out'
error_searchline = 'pos_lulesh_seq_$(jobid).out'


flag_string = []

for i in range(0, len(intel) + 1):
	combination = list(itertools.combinations(intel,i))
	flag_string.extend(map(' '.join, combination))


for j in range(len(flag_string) -2, len(flag_string) -1):
#for j in range(0, 1):
	LLoutput = open('tmp.ll',"w")
	os.environ['FLAG_COMBINATION'] = str("-O3 -I. -w " + flag_string[j])
	print("make fresh!!!!!!!\n")
	subprocess.call("make fresh", shell = True)
	current_flag_string = flag_string[j]
	jobid = current_flag_string.replace(" ", "")
	jobid = jobid.replace(".", "")
	jobid = jobid.replace("-", "_")
	os.environ['OUTPUT_FILE_NAME'] = "pos_lulesh_seq_$(jobid)" + jobid + ".out"
	os.environ['ERROR_FILE_NAME'] = "pos_lulesh_seq_$(jobid)" + jobid + "_error.out"
	row_in = LLinput.readlines()
	print("writing tmp.ll..... \n")
	#TODO evaluate enviroment variables in input file and write to output with os.path.expandvar()
        for line in row_in:
                LLoutput.write(os.path.expandvars(line))
	#TODO delete temporary file
	# output_file_name_line = "pos_lulesh_seq_$" + jobid + ".out"
	# error_file_name_line = "pos_lulesh_seq_$" + jobid + "error.out"
	
	LLoutput.close()	
	#submit job to load leveler with temporary .ll file
	subprocess.call(["llsubmit tmp.ll"], shell=True)
#	subprocess.call(["rm tmp.ll"], shell = True)
