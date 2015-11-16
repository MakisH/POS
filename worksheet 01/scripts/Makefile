# Makefile for the LULESH benchmark, in the context of TUM Programming of Supercomputers course, WS2015-16, Worksheet 1, group 9.

SHELL = /bin/sh
.SUFFIXES: .cc .o

LULESH_EXEC = lulesh2.0

# Note: Remember to load the Intel MPI module.
MPI_INC = /lrz/sys/intel/impi/5.0.3.048/include64
MPI_LIB = /lrz/sys/intel/impi/5.0.3.048/lib64

# Compiler to use for the serial and the MPI case.
# For GCC serial, use g++ (load the module gcc/4.9).
# For Intel serial, use icc (load the module intel/15.0).
# For intel MPI, use mpiCC (unload the module mpi.ibm, load the module mpi.intel).
#SERCXX = g++ -DUSE_MPI=0
SERCXX = icc -DUSE_MPI=0
MPICXX = mpiCC -DUSE_MPI=1

# Serial or MPI run? Uncomment respectively
## Serial run
CXX = $(SERCXX)
## MPI run
#CXX = $(MPICXX)

SOURCES2.0 = \
	lulesh.cc \
	lulesh-comm.cc \
	lulesh-viz.cc \
	lulesh-util.cc \
	lulesh-init.cc
OBJECTS2.0 = $(SOURCES2.0:.cc=.o)

# Compiler flags
#  To enable profiling, add "-pg".
#  To see the vectorization reports for g++, add "-ftree-vectorizer-verbose=2 -fopt-info-vec-missed=missed.all".
#  To see the vectorization reports for icc, add "-vec-report2".
#  To enable OpenMP use "-fopenmp" for g++, or "-openmp" for icc.
#  Selected flags for g++ in Task 4.2: "-O3 -march="native" -funroll-loops -floop-block".
#  Selected flags for icc in Task 4.2: "-O3 -xHost -unroll".
OPTIM_FLAGS = -O3 -xHost -unroll
CXXFLAGS = $(OPTIM_FLAGS) -I. -w

# Linker flags
LDFLAGS = -O3

.cc.o: lulesh.h
	@echo "Building $<"
	$(CXX) -c $(CXXFLAGS) -o $@  $<

all: $(LULESH_EXEC)

lulesh2.0: $(OBJECTS2.0)
	@echo "Linking"
	$(CXX) $(OBJECTS2.0) $(LDFLAGS) -lm -o $@

clean:
	/bin/rm -f *.o *~ $(OBJECTS) $(LULESH_EXEC)
	/bin/rm -rf *.dSYM

tar: clean
	cd .. ; tar cvf lulesh-2.0.tar LULESH-2.0 ; mv lulesh-2.0.tar LULESH-2.0

# Shortcut to "make clean && make".
fresh: clean all
