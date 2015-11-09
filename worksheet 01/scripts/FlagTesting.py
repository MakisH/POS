#!/usr/bin/python

import itertools
import os
import sys
import time
import fileinput
import subprocess


def find(l, s):
    for i in range(len(l)):
        if l[i].find(s)!=-1:
            return i
    return None # Or -1

intel = ["-march = native","-fomit-fram-pointer","-floop-block","-floop-interchange","-floop-strip-mine","-funroll-loops","-flto"]
f_handle = open('Makefile','r+')
#fileinput.filename()

flag_string = []

for i in range(0, len(intel)-1): 
	combination = list(itertools.combinations(intel,i)) 
	flag_string.extend(map(' '.join,combination))

for j in range(0, len(flag_string)-1):
	os.environ['FLAG_COMBINATION'] = flag_string[j]
	subprocess.call(["make"])
	subprocess.call(["./exec"])

flag_searchline = '#flag_list'
target_searchline = '#target_list'



