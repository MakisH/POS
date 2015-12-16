#!/bin/bash
export OMP_NUM_THREADS=3 
mpirun -np 4 tau_exec -T ompt,mpi,pdt,papi -ompt ./bt-mz_W.4
