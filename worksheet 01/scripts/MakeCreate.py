#!/usr/bin/pyton

import itertools
import os
import sys
import time
import fileinput

f_handle = open('testfile','w')
numbers = ["1","2","3","4","5"]
intel = ["-march = native","-fomit-fram-pointer","-floop-block","floop-interchange","floop-strip-mine","funroll-loops","-flto"]
f_handle = open('testfile','w')
#fileinput.filename()

for i in range(1,len(intel)):

	combination = list(itertools.combinations(intel,i)) 
	flag_string= map(' '.join,combination)
	
	flag_searchline = '#flag_list'
	target_searchline = '#target_list'

	lines = f_handle.readlines()
	flags_index = lines.index(flag_searchline)
	targets_index =  lines.index(target_searchline)

	for j in range(0,len(flag_string)):
		flag_lines += "CXXFLAGS_i = -O3 -I. -w " + flag_string[j] + "\n"

	for k in range(0,len(flag_string)):
		target_lines += "name_" + k + ": lulesh.h $(CXX) -c $(CXXFLAGS_" + k + " -o $@  $< " + "\n" 

	for line in f_handle
		lines.insert(flags_index, flag_lines)
		lines.insert(targets_index, target_lines)

file.close()
