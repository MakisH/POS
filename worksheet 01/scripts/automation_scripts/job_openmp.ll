#!/bin/bash
#@ wall_clock_limit = 00:05:00
#@ job_name = pos-lulesh-openmp
#@ job_type = MPICH
#@ class = test
#@ output = pos_lulesh_openmp_$(jobid).out
#@ error = pos_lulesh_openmp_$(jobid).out
#@ node = 1
#@ total_tasks = ${OMP_NUM_THREADS} 
#@ node_usage = not_shared
#@ energy_policy_tag = lulesh
#@ minimize_time_to_solution = yes
#@ island_count = 1
#@ queue

. /etc/profile
. /etc/profile.d/modules.sh
export OMP_NUM_THREADS=${OMP_NUM_THREADS}
./lulesh2.0
