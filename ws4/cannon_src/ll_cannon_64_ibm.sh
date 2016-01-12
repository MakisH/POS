#!/bin/bash
#@ wall_clock_limit = 00:20:00
#@ job_name = pos-cannon-mpi-ibm
#@ job_type = Parallel
#@ output = cannon_collectives_$(jobid).out
#@ error = cannon_collectives_$(jobid).out
#@ class = test
#@ node = 4
#@ total_tasks = 64
#@ node_usage = not_shared
#@ energy_policy_tag = cannon_collectives_sb
#@ minimize_time_to_solution = yes
#@ notification = never
#@ island_count = 1
#@ queue

. /etc/profile
. /etc/profile.d/modules.sh

# As we have three different versions of the code (provided, collectives, MPI I/O),
# we can select a version here, for convenience. Valid options: "provided", "collectives", "io".
# Please update the header of the jobscript respectively.
#VERSION="provided"
VERSION="collectives"
#VERSION="io"

# As we need to run this in both SuperMUC Phase I and SuperMUC Phase II,
# we define the respective binary here for convenience.
# Please update the header of the jobscript respectively.
ARCH="sb"
#ARCH="hw"

BINARY="./cannon_${VERSION}_${ARCH}"

# We run everything many times, in order to check for reproducibility.
# We could run either sets of the same config the one after the other,
# or run the whole set of tests many times. The latter one is probably more
# effective in testing different machine states. Even more effective would
# be maybe to submit many jobs in different times, but this would pose a large
# pre- and post-processing overhead that we didn't think was reasonable, since
# our results were not so different between runs but were quite different between
# the different implementations we needed to test.

# Note: We need to add the test flag to some runs for testing.
#	We ommit it when running everything many times, in order to reduce the total job runtime.
#	To make things simpler, we implemented an option to choose between testing or actual measuring.
DO_TESTING=true

# Repetitions for the normal (non-testing) mode.
REPETITIONS=30

# Output some information to remember/verify the setup.
echo Normal job for testing or measuring
echo Version: ${VERSION}
echo Architecture: ${ARCH}
echo Binary: ${BINARY}
ls -la ${BINARY}
echo Testing: ${DO_TESTING}
echo Repetitions: ${REPETITIONS}
echo
echo lscpu:
lscpu
echo

if [ "$DO_TESTING" = true ]; then
  date
  mpiexec -n 64 ${BINARY} ../cannon_matrices/64x64-1.in     ../cannon_matrices/64x64-2.in test
  date
  mpiexec -n 64 ${BINARY} ../cannon_matrices/128x128-1.in   ../cannon_matrices/128x128-2.in test
  date
  mpiexec -n 64 ${BINARY} ../cannon_matrices/256x256-1.in   ../cannon_matrices/256x256-2.in test
  date
else
  date
  for i in `seq 1 ${REPETITIONS}`;
  do
    mpiexec -n 64 ${BINARY} ../cannon_matrices/64x64-1.in     ../cannon_matrices/64x64-2.in
    date
    mpiexec -n 64 ${BINARY} ../cannon_matrices/128x128-1.in   ../cannon_matrices/128x128-2.in
    date
    mpiexec -n 64 ${BINARY} ../cannon_matrices/256x256-1.in   ../cannon_matrices/256x256-2.in
    date
    mpiexec -n 64 ${BINARY} ../cannon_matrices/512x512-1.in   ../cannon_matrices/512x512-2.in
    date
    mpiexec -n 64 ${BINARY} ../cannon_matrices/1024x1024-1.in ../cannon_matrices/1024x1024-2.in
    date
    mpiexec -n 64 ${BINARY} ../cannon_matrices/2048x2048-1.in ../cannon_matrices/2048x2048-2.in
    date
    mpiexec -n 64 ${BINARY} ../cannon_matrices/4096x4096-1.in ../cannon_matrices/4096x4096-2.in
    date
  done
fi
echo
echo All the tests completed!
