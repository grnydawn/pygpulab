#!/bin/bash
#BSUB -W 6:00
#BSUB -nnodes 1
#BSUB -P cli115
#BSUB -o gpuperf.o%J
#BSUB -J gpuperf
jsrun -n1 -c1 -g1 -a1 $*
