#!/bin/bash
#@ wall_clock_limit = 00:20:00
#@ job_name = pos-lulesh-seq
#@ job_type = parallel
#@ class = test
#@ output = pos_lulesh_seq_$(jobid).out
#@ error = pos_lulesh_seq_$(jobid).out
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
./lulesh2.0
