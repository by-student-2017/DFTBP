#!/bin/bash

NCPU=1
lammps_adress=$HOME/lammps-29Oct20

mkdir cfg

export OMP_NUM_THREADS=${NCPU}
export MAGMA_NUM_GPUS=1

${lammps_adress}/src/lmp_serial -sf omp -pk omp ${NCPU} -in in.lmp

