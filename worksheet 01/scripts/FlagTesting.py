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

original_bash_script_handle = open('seq.ll','r+')

output_searchline = 'pos_lulesh_seq_$(jobid).out'
error_searchline = 'pos_lulesh_seq_$(jobid).out'

script_name = "flagtest.ll"

flag_string = []

for i in range(0, len(intel)-1): 
	combination = list(itertools.combinations(intel,i)) 
	flag_string.extend(map(' '.join,combination))

for j in range(0, len(flag_string)-1):

	os.environ['FLAG_COMBINATION'] = "-O3 -I. -w" + flag_string[j]
	current_flag_string = flag_string[j]
	jobid = current_flag_string.replace(" ", "")
	jobid = jobid.replace(".", "")
	jobid = jobid.replace("-", "_")
	os.environ['OUTPUT_FILE_NAME'] = "pos_lulesh_seq_$" + jobid + ".out"
	os.environ['ERROR_FILE_NAME'] = "pos_lulesh_seq_$" + jobid + "error.out"
	# output_file_name_line = "pos_lulesh_seq_$" + jobid + ".out"
	# error_file_name_line = "pos_lulesh_seq_$" + jobid + "error.out"

	subprocess.call(["llsubmit " + script_name], shell=True)
