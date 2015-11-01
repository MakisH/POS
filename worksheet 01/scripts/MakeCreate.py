#!/usr/bin/python

import itertools
import os
import sys
import time
import fileinput

def find(l, s):
    for i in range(len(l)):
        if l[i].find(s)!=-1:
            return i
    return None # Or -1

numbers = ["1","2","3","4","5"]
intel = ["-march = native","-fomit-fram-pointer","-floop-block","-floop-interchange","-floop-strip-mine","-funroll-loops","-flto"]
f_handle = open('Makefile','r+')
#fileinput.filename()

flag_string = []

for i in range(1,len(intel)):
	combination = list(itertools.combinations(intel,i)) 
	flag_string.extend(map(' '.join,combination))
	
flag_searchline = '#flag_list'
target_searchline = '#target_list'

lines = f_handle.readlines()
flags_index = find(lines, flag_searchline)
targets_index = find(lines, target_searchline)

flag_lines = " "
target_lines = " "

print flags_index
print targets_index

for j in range(0,len(flag_string)):
	flag_lines += "CXXFLAGS_" + str(j) + " = -O3 -I. -w " + flag_string[j] + "\n"

for k in range(0,len(flag_string)):
	target_lines += "target_" + str(k) + ":" + "\n\t" + "lulesh.h" + "\n\t" + "$(CXX) -c $(CXXFLAGS_" + str(k) + ") -o $@  $< " + "\n" 

lines.insert(flags_index, flag_lines)
lines.insert(targets_index, target_lines)

f_handle.close()

new_f_handle = open("new_Makefile", "w")
new_lines = "".join(lines)
new_f_handle.write(new_lines)
new_f_handle.close()
