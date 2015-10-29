# 1. take original parts from the basic Makefile
# 2. between original parts, insert two things:

# A. list of flags
# format: CXXFLAGS_i = -O3 -I. -w, (string i)

# B. list of targets:

# format:
# name_i: lulesh.h
# @echo "Building $<"
# $(CXX) -c $(CXXFLAGS_i) -o $@  $<


