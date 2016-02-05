#!/bin/bash

# Filename of the binary file to convert.
FILENAME=$1
# Number of elements per x and per y written in the file.
ELEMX=$2
ELEMY=$3
SIZEROW=${ELEMY}
let SIZEROW*=8

# Filename of the ASCII file to convert to.
OUTPUT=${FILENAME}.txt

printf "Filename  : ${FILENAME}\n" > ${OUTPUT}

# Read and write the first 8 bytes of the binary file (two integers).
hexdump -e '1 4 "Rows      : %d \n" 1 4 "Columns   : %d\n\n"' -n 8 ${FILENAME} >> ${OUTPUT}
# We have already read 8 bytes.
OFFSET=8

# Write the matrix rows
printf "Matrix =\n" >> ${OUTPUT}

for i in `seq 1 ${ELEMX}`;
do
    hexdump -e ''"${ELEMY}"' 8 "%5.1f " "\n"' -n ${SIZEROW} -s ${OFFSET} ${FILENAME} >> ${OUTPUT}
    let OFFSET+=${SIZEROW}
done
