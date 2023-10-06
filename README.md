# DFTBP 
- LAMMPS codes for DFTB+
- Tests: 
  + DFTB+ v.23.1 
    + [(v.21.2 or v.22.2 for "graphene" in examples)](https://dftbplus.org/download/deprecated)
  + [lammps-29Oct2020](https://download.lammps.org/tars/lammps-29Oct2020.tar.gz) [(a relative link)](https://download.lammps.org/tars/index.html)
  + Ubuntu 22.04.1 LTS (WLS2, Windows11)
- Note 1: "mpirun -np 1" and OpenMP version
- Note 2: By using "xTB", calculations using many elements are possible. I am looking forward to hearing reports from many people in their papers. 


## Step 1. Preparing DFTB+ ######################################
  1. Install libraries, e.g.
```
sudo apt update
sudo apt -y install gfortran g++ build-essential
sudo apt -y install libopenmpi-dev libscalapack-openmpi-dev
sudo apt -y install libopenblas-dev
sudo apt -y install make cmake
sudo apt -y install python3-numpy python-is-python3
```
  2. Install DFTB+ v.23.1 and related libraries
```
cd /mnt/d
wget https://github.com/dftbplus/dftbplus/releases/download/23.1/dftbplus-23.1.tar.xz
tar xvf dftbplus-23.1.tar.xz
cd dftbplus-23.1
./utils/get_opt_externals ALL
```
  3. vim config.cmake
```
option(WITH_OMP "Whether OpenMP thread parallisation should be enabled" TRUE)
option(WITH_MPI "Whether DFTB+ should support MPI-parallelism" FALSE)
option(WITH_TBLITE "Whether xTB support should be included via tblite." TRUE)
option(WITH_API "Whether public API should be included and the DFTB+ library installed" TRUE)
option(BUILD_SHARED_LIBS "Whether the libraries built should be shared" TRUE)
```
  4. Compiling DFTB+ v23.1
```
mkdir _build
FC=gfortran CC=gcc cmake -DLAPACK_LIBRARY="-L/usr/lib/x86_64-linux-gnu -lopenblas -lpthread" -DCMAKE_INSTALL_PREFIX=/mnt/d/dftbplus-23.1/dftb+ -B _build ./
cmake --build _build -- -j
cmake -B _build -DTEST_OMP_THREADS=4 ./
pushd _build; ctest; popd
cmake --install _build
```
  5. Environment settings
```
echo 'export PATH=$PATH:/mnt/d/dftbplus-23.1/dftb+/bin' >> ~/.bashrc
echo 'export PATH=$PATH:/mnt/d/dftbplus-23.1/dftb+/lib' >> ~/.bashrc
echo 'export PATH=$PATH:/mnt/d/dftbplus-23.1/dftb+/include' >> ~/.bashrc
echo 'export PATH=$PATH:/mnt/d/dftbplus-23.1/tools/misc' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/mnt/d/dftbplus-23.1/dftb+/lib' >> ~/.bashrc
bash
```


## Step 2. Preparing DFTBP and Lammps ######################################
  6. Install DFTBP and Lammps code
```
cd /mnt/d
wget https://download.lammps.org/tars/lammps-29Oct2020.tar.gz
tar zxvf lammps-29Oct2020.tar.gz
git clone https://github.com/by-student-2017/DFTBP.git
cp -r ./DFTBP/* ./lammps-29Oct20/
```
  6. Compiling Lammps with DFTBP code
```
cd lammps-29Oct20/src
make yes-dftbp yes-MOLECULE
make package-status
make mpi
```


## Example (GFN2-xTB, N in graphene, NVT) ######################################
  1. go to examples directory
```
cd /mnt/d/lammps-29Oct20/examples/DFTBP/N_in_graphene
```
  2. run
```
export OMP_NUM_THREADS=4
mpirun -quiet -np 1 /mnt/d/lammps-29Oct20/src/lmp_mpi -in md.in
```
  3. open equil.xyz on Ovito code


## Note (for fix_dftb.h, etc) ######################################
- ERROR messages:
  + Must use units metal with fix dftbp command
  + Fix dftbp currently runs only in serial
  + Illegal ... command
  + Self-explanatory. Check the input script syntax and compare to the documentation for the command.  You can use -echo screen as a command-line option when running LAMMPS to see the offending line.
  + Fix latte does not yet support a LAMMPS calculation of a Coulomb potential
  + Could not find fix latte compute ID
  + Fix dftbp compute ID does not compute pe/atom
  + Fix dftbp requires 3d problem
  + Fix dftbp cannot compute Coulomb potential
  + Fix dftbp requires 3d simulation
  + Internal DFTB+ problem
- WARNING messages:
  + Fix dftbp should come after all other integration fixes
- "virial" for "fix_dftb.cpp": "compute energy_all" has been killed because if you rewrite the code related to the DFTB+ app, it will show "failed" in the error or test check. Therefore, energy_all[1] for repulsion energy and energy_all[2] for electron energy do not show correct values. The virial energy_all[3] to [8] correspond to the original code if you multiply the Pa unit by the volume of the cell (i.d., [eV/Bohr^3] * CellVol [Bohr^3] => [eV]. This could be done in the lammps script file instead.)
- This package based on fix_latte.cpp and fix_latte.h
- "DFTB+ v.21.2 and v.22.2" version: It is necessary to rewrite "Makefile" and "Makefile.mpi" to the version number of DFTB+ to be used. You will also need to rewrite the DFTB+ path settings in "~/.bashrc". Please use the "dftbplus.h" included in the DFTB+ include that you want to use. Note that "_Bool" may need to be changed to "bool" in "dftbplus.h".
- For non-WSL Linux, "/mnt/d" replaces "$HOME" etc (i.d., "/mnt/d" => "$HOME")
- I have only been able to get it working, so please contact the respective developer for any problems or development issues.
- Since "DFTB+ v.23.1" and later can read the lammps structure file, there is no need to worry about whether it is consistent with the conventional DFTB+ input file (*.gen). You probably won't need to make any changes to the "in.lammps" file.


## PC specs used for test ######################################
+ OS: Microsoft Windows 11 Home 64 bit
+ BIOS: 1.14.0
+ CPU： 12th Gen Intel(R) Core(TM) i7-12700
+ Base Board：0R6PCT (A01)
+ Memory：32 GB
+ GPU: NVIDIA GeForce RTX3070
+ WSL2: VERSION="22.04.1 LTS (Jammy Jellyfish)"


## References ######################################
- [G. S. Jung, S. Irle and B. G. Sumpter, Carbon 190 (2022) 183-193.](https://doi.org/10.1016/j.carbon.2022.01.002)


## My Wish ######################################
- The only people who have published the code that links "DFTB+" and "Lammps" are the developers (ORNL and LANL) and myself, who has made it work with the latest version. I strongly look forward to the success of the Max Planck Institute and other motivated individuals.


## Original Information ######################################
# DFTBP
LAMMPS codes for DFTB+

Reference: Gang Seob Jung, Stephan Irle, and Bobby Sumpter. "Dynamic aspects of graphene deformation and fracture from approximate density functional theory." Carbon (2022)

Please check DFTB+ code https://github.com/dftbplus/dftbplus

This package provides a fix dftbp command which is a wrapper on the DFTB+ DFTB code, so that molecular dynamics can be run with LAMMPS
using density-functional tight-binding calculations by DFTB+.

GS JUNG@ORNL made this package based on fix_latte.cpp and fix_latte.h (developed by LANL)

Please report any bug/commetns to jungg@ornl.gov or gs4phone@gmail.com

The necessary functions for DFTB+ API have been implemented (update is allowed by dftb+).

Until that, you can check the details of changes in https://github.com/gsjung0419/dftbplus

0. The code is only tested with following environments.

 -. Intel compiler (19 and 20)
 
 -. MPICH 3.2.1 version compiled by intel compiler
 
 -. CMAKE 3.12 or 3.19
 
 -. Matching the versions of programs are recommended (The author did not check other possible combinations). 


1. DFTB+ options (tested) (See your confg.cmake in dftb+)

 -. WITH_OMP: TRUE or FALSE
 
 -. WITH_DFTD3: TRUE or FALSE
 
 -. WITH_API: TRUE (Mandatory for static library, e.g., library.a)
 
 -. BUILD_SHARED_LIBS: TURE (Mandatory for shared library, e.g., library.so, mandatory for python-based lammps users)
 
 -. You may have compile issues if you try with other environments.


2.1. Installation of DFTB+ (recommended for the most fundamental version)

 -. Compile the dftb+ (WITH_OMP, WITH_API: TRUE)
 
 -. Check libdftbplus.a is generated.
 
 -. Locate libdftbplus.a in preffered folder (ex., ~/applic/lib/dftbplus)


2.2. Installation of LAMMPS (recommended for the most fundamental version)

 -. Use LAMMPS version 29OCT20, the newest version did not work for "fix" based modification.
 
 -. Copy lib/dftbp to LAMMPS_sourcecode/lib
 
 -. Edit Makefile.lammps.mpi in lib/dftbp, "location of library" you set in DFTB+ installation (ex., ~/applic/lib/dftbplus).
 
 -. Move src as lammps/src/DFTBP 
 
 !! Make sure your dftbplus.h is the same as provided from dftbplus (there might be updates for API functions).
 
 -. Edit Makefile in lammps/src folder;include "dftbp" in PACKAGE.
 
 -. Check "make package-status" whether you have DFTBP package
 
 -. Make available with "make yes-dftbp"
 
 -. Compile lammps with "make mpi" in src folder (compile with intel compiler + mpich3.2.1)

3 Usage and Example

 !! Before you are running the simulation. Check OMP_NUM_THREADS= 1 or specify a number
 
 !! Without specified the OMP number, DFTB+ tries to use all available cores, making it slow.
 

 3.1 Graphene md (example C-C.skf is MIO)
 
  -. data file for lammps and dftb+ should be prepared separately.
  
  -. The order of input atoms should be matched.
  
  -. Check dftb_in.hsd for options for dftb+. Most options are turned off except force calculations
  


