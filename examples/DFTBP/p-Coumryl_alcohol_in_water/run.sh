#!/bin/bash

NCPU=1
#lammps_adress=$HOME/lammps-29Oct20
lammps_adress=/mnt/d/lammps-29Oct20

mkdir cfg

export OMP_NUM_THREADS=${NCPU}

${lammps_adress}/src/lmp_serial -sf omp -pk omp ${NCPU} -in in.lmp

