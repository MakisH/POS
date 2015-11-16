#default build suggestion of MPI + OPENMP with gcc on Livermore machines you might have to change the compiler name

SHELL = /bin/sh
.SUFFIXES: .cc .o

LULESH_EXEC = lulesh2.0

# Note: Remember to load the Intel MPI module.
MPI_INC = /lrz/sys/intel/impi/5.0.3.048/include64
MPI_LIB = /lrz/sys/intel/impi/5.0.3.048/lib64

SERCXX = g++ -DUSE_MPI=0
MPICXX = mpiCC -DUSE_MPI=1
# Serial run
CXX = $(SERCXX)
# MPI run
# CXX = $(MPICXX)

SOURCES2.0 = \
	lulesh.cc \
	lulesh-comm.cc \
	lulesh-viz.cc \
	lulesh-util.cc \
	lulesh-init.cc
OBJECTS2.0 = $(SOURCES2.0:.cc=.o)

# Our config for serial run
CXXFLAGS = ${FLAG_COMBINATION}
#CXXFLAGS = -O3 -I. -w 

#flag_list
LDFLAGS = -O3

# Our config for OpenMP
# CXXFLAGS = -O3 -openmp -I.
# LDFLAGS = -O3 -openmp

# Our config for MPI
# CXXFLAGS = -O3 -I. -w
# LDFLAGS = -O3

# Our config for MPI + OpenMP
# CXXFLAGS = -O3 -openmp -I.
# LDFLAGS = -O3 -openmp

.cc.o: lulesh.h
	@echo "Building $<"
	$(CXX) -c $(CXXFLAGS) -o $@  $<

all: $(LULESH_EXEC)
	
#target_list

lulesh2.0: $(OBJECTS2.0)
	@echo "Linking"
	$(CXX) $(OBJECTS2.0) $(LDFLAGS) -lm -o $@

clean:
	/bin/rm -f *.o *~ $(OBJECTS) $(LULESH_EXEC)
	/bin/rm -rf *.dSYM

tar: clean
	cd .. ; tar cvf lulesh-2.0.tar LULESH-2.0 ; mv lulesh-2.0.tar LULESH-2.

fresh: clean all


