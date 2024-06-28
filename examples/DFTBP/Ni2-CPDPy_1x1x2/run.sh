#!/bin/bash

mkdir cfg

export OMP_NUM_THREADS=16

$HOME/lammps-29Oct20/src/lmp_serial -sf omp -pk omp 16 -in in.lmp


