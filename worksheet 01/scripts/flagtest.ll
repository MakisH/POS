#!/bin/bash
#@ wall_clock_limit = 00:20:00
#@ job_name = pos-lulesh-seq
#@ job_type = MPICH
#@ class = test
#@ output = $(OUTPUT_FILE_NAME)
#@ error = $(ERROR_FILE_NAME)
#@ node = 1
#@ total_tasks = 1
#@ node_usage = not_shared
#@ energy_policy_tag = lulesh
#@ minimize_time_to_solution = yes
#@ island_count = 1
#@ queue
. /etc/profile
. /etc/profile.d/modules.sh
. $HOME/.bashrc
# load the correct MPI library
# module unload mpi.ibm
# module load mpi.intel

./lulesh2.0


