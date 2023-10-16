# DFTBP 
- LAMMPS codes for DFTB+
- Tests: 
  + DFTB+ v.23.1 
    + [(v.21.2 or v.22.2 for "graphene" in examples)](https://dftbplus.org/download/deprecated)
  + [lammps-29Oct2020](https://download.lammps.org/tars/lammps-29Oct2020.tar.gz) [(a relative link)](https://download.lammps.org/tars/index.html)
  + Ubuntu 22.04.1 LTS (WLS2, Windows11)
- Note 1: "mpirun -np 1" and OpenMP version


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
option(WITH_SDFTD3 "Whether the s-dftd3 library should be included" TRUE)
option(WITH_API "Whether public API should be included and the DFTB+ library installed" TRUE)
option(BUILD_SHARED_LIBS "Whether the libraries built should be shared" TRUE)
```

```

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
- Note: If a different version is set, you need to rewrite the above environment (only the version number needs to be modified) in "vim ~/.bashrc" before starting installation and compilation.


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


## Example (graphene, stress-strain, test version) ######################################
  1. go to examples directory
```
cd /mnt/d/lammps-29Oct20/examples/DFTBP/graphene_stress-strain
```
  2. run
```
export OMP_NUM_THREADS=4
mpirun -quiet -np 1 /mnt/d/lammps-29Oct20/src/lmp_mpi -in md.in
```
  3. ./plot_stress_vs_strain_v2.gpl

  4. open *.cfg (in cfg directory) on Ovito code


## Example (N in graphene, GFN2-xTB) ######################################
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


## Example (PbTiO3, MSD, GFN2-xTB, test version) ######################################
  1. go to examples directory
```
cd /mnt/d/lammps-29Oct20/examples/DFTBP/PbTiO3_MSD
```
  2. run
```
ulimit -s unlimited
export OMP_NUM_THREADS=8
mpirun -quiet -np 1 /mnt/d/lammps-29Oct20/src/lmp_mpi -in md.in
```
  3. ./plot_msd_O.gpl

  4. open equil.xyz (in cfg directory) on Ovito code


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
- This package based on fix_latte.cpp and fix_latte.h
- For non-WSL Linux, "/mnt/d" replaces "$HOME" etc (i.d., "/mnt/d" => "$HOME")
- I have only been able to get it working, so please contact the respective developer for any problems or development issues.- Implementing MPI parallelism is not easy, as shown in the [video](https://www.youtube.com/watch?v=RXg6oNIOn1U&t=662s) about "MPI-parallelization needs some care (but possible)" and DFTB+'s API.
- Considering that the official homepage of "xTB" lists TiO2 and MgO as calculation examples, oxides such as SiO2 and ceramics may be suitable for "xTB" rather than metals. Of course, it is also possible that appropriate calculation conditions (Mixing Parameters, etc.) have not been found for the metal system.
- Based on the phonon results in Si using [Alamode](https://github.com/by-student-2017/alamode-example) , it is assumed that calculations up to about 500 K are highly reliable in "xTB".
- "DFTB+ v.21.2 and v.22.2" version: It is necessary to rewrite "Makefile" and "Makefile.mpi" to the version number of DFTB+ to be used. You will also need to rewrite the DFTB+ path settings in "~/.bashrc". Please use the "dftbplus.h" included in the DFTB+ include that you want to use. Note that "_Bool" may need to be changed to "bool" in "dftbplus.h".
- Since "DFTB+ v.23.1" and later can read the lammps structure file, there is no need to worry about whether it is consistent with the conventional DFTB+ input file (*.gen). You probably won't need to make any changes to the "in.lammps" file.
- Be careful about the first line of the Lammps data file. When outputting with Lammps' write_data, it is necessary to modify it in DFTB+ v.23.1. For example, if you delete the part after ",", it will work fine. I really hope this issue is fixed in a future DFTB+.
- Lattice constant optimization problem: https://github.com/grimme-lab/xtb/discussions/529 
- Error in NPT Simulations Using xTB: https://github.com/dftbplus/dftbplus/issues/1079
- A code to calculate volume has been added to "fix_dftb.cpp". If there is no problem with this modification, virial (pressure) may also be able to be calculated.
- Since it may operate at low temperatures, regardless of the temperature of the experiment, it is important to consider obtaining information at low temperatures, as it is important information for comparison. It is also important to create a large amount of comparable data at low operating temperatures (same temperature).
- There's nothing more I can do. I would like the developers of "xTB" and "DFTB+" to actively work to ensure that calculations for various systems operate correctly under periodic boundary conditions.
- I'm thinking about MOPAC + Lammps, but I can't do it because MOPAC's API is not official and well-developed. I also want you to actively work on this.
- I compared the results.tag of dftb+ and the results of lammps and corrected it to "forces[i3+j]=-gradients[i *3+j]*funitconv;". We are looking for active opinions from our readers.
- In my current modified version, "virial" was not working properly, so it turned out that the second term of the pressure in "lammps" was not calculated correctly.
- The second term of Lampps pressure is changed in "virial" of "fix_dftp.cpp". The original DFTBP is used as a reference, but the comments in dftbplus.h indicate that both the DFTB+ formula is Pascal, which I am not satisfied with. I would like to get information from many people regarding this as well.


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
- [OSTI.GOV / Journal Article: Dynamic aspects of graphene deformation and fracture from approximate density functional theory](https://www.osti.gov/biblio/1841487)


## My Wish ######################################
- The only people who have published the code that links "DFTB+" and "Lammps" are the developers (ORNL and LANL) and myself ("By Student"), who has made it work with the latest version. I strongly look forward to the success of the Max Planck Computing and Data Facility (MPCDF) and other motivated individuals.


## Acknowledgment ######################################
- This project (modified version) is/was partially supported by the following :
  + meguREnergy Co., Ltd.
  + ATSUMITEC Co., Ltd.
  + RIKEN


## Units (DFTB+ and Lammps) ######################################
- double const sunitconv=1.0/0.367493245336341E-01; (in fix_dftb.h)
  + 0.367493245336341E-01 = 1/27.211
  + 1 Ha (DFTB+ and fix_dftb.cpp) = 27.211 eV (Lammps, metal units)
  + Stress
- double const funitconv=1.0/0.194469064593167E-01; (in fix_dftb.h)
  + 0.194469064593167E-01 = 1/51.422
  + 1 Ha/Bohr (DFTB+ and fix_dftb.cpp) => 51.422 eV/Angstrom (Lammps, metal units)
  + Force
- double const eunitconv=1.0/0.367493245336341E-01; (in fix_dftb.h)
  + 0.367493245336341E-01 = 1/27.211
  + 1 Ha (DFTB+ and fix_dftb.cpp) => 27.211 eV (Lammps, metal units)
  + Energy
- double const lunitconv=0.188972598857892E+01; (in fix_dftb.h)
  + 0.188972598857892E+01 = 1/0.52918
  + 1 Bohr (DFTB+ and fix_dftb.cpp) = 0.52918 Angstrom (Lammps, metal units)
  + Lattice vector


## Units (DFTB+ and Lammps) ######################################
- force : DFTB+ (results.tag: Ha/Bohr), Lammps (eV/Angstrom)
- stress: DFTB+ (results.tag: Ha/Bohr^3, Pa or au ?), Lammps (bar = 100 kPa = 0.1 MPa)
  + "elastic[ii][jj] /= (PRESURE_AU * 1.0E9) # Convert to GPa": Inue 134 in calcelastic (python3 code): au -(0.339893208050290E-13 * 1.0E9) -> GPa
- volume: DFTB+ (results.tag: Ha/Bohr), Lammps (eV/Angstrom)


## Future plans ######################################
- USPEX: https://uspex-team.org/en/uspex/overview (QE, MOPAC, Lammps, etc)
- CALYPSO: http://www.calypso.cn/ (QE, Siesta, CP2k, DFTB+, Lammps, etc)
- CrySPY: https://tomoki-yamashita.github.io/CrySPY_doc/index.html (QE, OpenMX, Lammps, etc)
- GASP-python: https://github.com/henniggroup/GASP-python (Lammps, etc)
- EVO: http://cpc.cs.qub.ac.uk/summaries/AEOZ_v1_0.html
- MOLPAK: https://sourceforge.net/projects/molpak/


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
  


