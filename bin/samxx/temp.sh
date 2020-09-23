#!/usr/bin/env bash

WORK=sam-cpp
PROJECT_ID=cli115
SCRATCH=/gpfs/alpine/${PROJECT_ID}/scratch/${USER} 
WORKDIR=${SCRATCH}/${WORK}

cd ${WORKDIR}
cd E3SM
cd components/cam/src/physics/crm/samxx/test/build

source $MODULESHOME/init/bash
module purge
#module load DefApps gcc/8.1.1 cuda/10.1.243 netcdf/4.6.2 netcdf-fortran/4.4.4 cmake/3.17.3 python/3.7.0-anaconda3-5.3.0
module load DefApps gcc cuda netcdf/4.6.2 netcdf-fortran/4.4.4 cmake/3.17.3 python/3.7.0-anaconda3-5.3.0 spectrum-mpi
module load nsight-systems nsight-compute

source deactivate

unset ARCH
unset NCRMS

export NCHOME=${OLCF_NETCDF_ROOT}
export NFHOME=${OLCF_NETCDF_FORTRAN_ROOT}
export NCRMS=1
export CC=mpicc
export CXX=mpic++
export FC=mpif90
export FFLAGS="-O3 -ffree-line-length-none"
export CXXFLAGS=-O3
export ARCH="CUDA"
export CUDA_ARCH="-arch sm_70 -O3 --use_fast_math -D__USE_CUDA__ --expt-extended-lambda --expt-relaxed-constexpr"
export YAKL_HOME="`pwd`/../../../../../../../../externals/YAKL"
export YAKL_CUB_HOME="${WORKDIR}/cub"
#export YAKL_CUB_HOME="/ccs/home/$USER/cub"

#./cmakeclean.sh
#./cmakescript.sh crmdata_nx32_ny1_nz28_nxrad2_nyrad1.nc crmdata_nx8_ny8_nz28_nxrad2_nyrad2.nc
#make -j 8

cp -f ~/runtest.sh .

#jsrun -n1 -c20 -g1 -a1 nsys profile -o sam++.nsys -f true ./runtest.sh
jsrun -n1 -c1 -g1 -a1 ncu --target-processes=all --set=full --force-overwrite -o sam++.ncu.full ./runtest.sh


#jsrun -n1 -c1 -g1 -a1 ncu --target-processes=all --set=default --section=SpeedOfLight_RooflineChart --force-overwrite -o sam++.ncu.default ./runtest.sh
#./runtest.sh
