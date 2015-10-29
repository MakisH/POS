
#!/usr/bin/pyton

import itertools
import os
import sys
import time
import fileinput


file = open('testfile','w')
numbers = ["1","2","3","4","5"]
intel = ["-march = native","-fomit-fram-pointer","-floop-block","floop-interchange","floop-strip-mine","funroll-loops","-flto"]
file = open('testfile','w')
#fileinput.filename()
for i in range(1,len(intel)):
	combination = list(itertools.combinations(intel,i)) 
#	print([x for x in itertools.combinations(numbers, i)])
	flag_string= map(' '.join,combination)
#	print(combination[0])
	for j in range(0,len(intel)):
#		print(flag_string[j])
#		for line in file
#			if line.contains('foo'):
				
		file.write(flag_string[j])
		file.write("\n")
	#TODO input flags into Makefile at deesired position with desired syntax
file.close()
