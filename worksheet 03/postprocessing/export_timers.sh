#!/bin/bash

# File to extract the data from
FILE=$1
# Version of the code used (e.g. "provided", "nonblocking", "onesided")
VERSION=$2
# Architecture used (e.g. "sb", "hw")
ARCH=$3

# Check for the output directory existence and, if needed, create it.
if [ ! -d "${VERSION}/" ]; then
    mkdir ${VERSION}
fi
if [ ! -d "${VERSION}/${ARCH}/" ]; then
    mkdir ${VERSION}/${ARCH}/
fi


# First size that is tested
N=64
# N_COUNT different sizes are tested (64, 128, 256...).
# Only powers of 2 are checked.
N_COUNT=7
for i in `seq 1 ${N_COUNT}`;
do
    echo "Reading the output of the job ${JOBID} for the (${N},${N}) matrices..."
    cat ${FILE} | grep "(${N},${N})" -A2 | grep "Computation time" | cut -f2- -d':' | sed -e 's/^\s*//' > ${VERSION}/${ARCH}/${VERSION}_${N}_comp.dat
    cat ${FILE} | grep "(${N},${N})" -A2 | grep "MPI time" | cut -f2- -d':' | sed -e 's/^\s*//' > ${VERSION}/${ARCH}/${VERSION}_${N}_mpi.dat
    let N=N*2
done
echo "All data were exported!"
