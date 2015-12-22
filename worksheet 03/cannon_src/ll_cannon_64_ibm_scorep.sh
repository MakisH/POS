#!/bin/bash 
#@ wall_clock_limit = 00:05:00
#@ job_name = pos-cannon-mpi-ibm-scorep
#@ job_type = Parallel
#@ output = cannon_nonblocking_scorep_$(jobid).out
#@ error = cannon_nonblocking_scorep_$(jobid).out
#@ class = test
#@ node = 4
#@ total_tasks = 64
#@ node_usage = not_shared
#@ energy_policy_tag = cannon_nonblocking_hw_scorep
#@ minimize_time_to_solution = yes
#@ notification = never
#@ island_count = 1
#@ queue

. /etc/profile
. /etc/profile.d/modules.sh

perf_off

# As we have three different versions of the code (provided, non-blocking communication, one-sided communication), 
# we can select a version here, for convenience. Valid options: "provided", "nonblocking", "onesided".
# Please update the header of the jobscript respectively.
#VERSION="provided"
VERSION="nonblocking"
#VERSION="onesided"

# As we need to run this in both SuperMUC Phase I and SuperMUC Phase II,
# we define the respective binary here for convenience.
# Please update the header of the jobscript respectively.
#ARCH="sb"
ARCH="hw"

BINARY="./cannon_${VERSION}_${ARCH}_scorep"

# Size of matrices to test for
N=4096

export SCOREP_ENABLE_PROFILING=false
export SCOREP_ENABLE_TRACING=true
export SCOREP_EXPERIMENT_DIRECTORY=scorep_cannon_${VERSION}_${ARCH}_${N}
export SCOREP_TOTAL_MEMORY=100M

echo Score-P job
echo Version: ${VERSION}
echo Architecture: ${ARCH}
echo Binary: ${BINARY}
ls -la ${BINARY}
echo Matrix size: ${N}
echo Profiling: ${SCOREP_ENABLE_PROFILING}
echo Tracing: ${SCOREP_ENABLE_TRACING}
echo Score-P directory: ${SCOREP_EXPERIMENT_DIRECTORY}
echo Score-P total memory: ${SCOREP_TOTAL_MEMORY}

mpiexec -n 64 ${BINARY} ../cannon_matrices/${N}x${N}-1.in ../cannon_matrices/${N}x${N}-2.in
