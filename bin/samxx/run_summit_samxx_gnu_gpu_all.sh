#!/usr/bin/env bash

WORK=sam++
PROJECT_ID=cli115
SCRATCH=/gpfs/alpine/${PROJECT_ID}/scratch/${USER} 
WORKDIR=${SCRATCH}/${WORK}

rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}
cd ${WORKDIR}
git clone https://github.com/mrnorman/YAKL.git
cd YAKL; git checkout a35cc1cd6f6c63498752a8d2f00e64ccb9f57621; cd ..
git clone https://github.com/NVlabs/cub.git
cd cub; git checkout c3cceac115c072fb63df1836ff46d8c60d9eb304; cd ..
git clone https://github.com/E3SM-Project/E3SM.git
cd E3SM; git checkout e5d0e555c22e678a23a6dd4f576d49c381201c21; cd ..
cd E3SM; git checkout mrnorman/samxx/youngsung; cd ..
cd E3SM
git submodule update --init --recursive
cd components/cam/src/physics/crm/samxx/test/build
rm -rf CMakeCache.txt CMakeFiles

source $MODULESHOME/init/bash
module purge
module load DefApps gcc cuda netcdf/4.6.2 netcdf-fortran/4.4.4 cmake/3.17.3 python/3.7.0-anaconda3-5.3.0 spectrum-mpi
module load nsight-systems nsight-compute
module unload darshan-runtime

unset ARCH
unset NCRMS

export NCHOME=${OLCF_NETCDF_ROOT}
export NFHOME=${OLCF_NETCDF_FORTRAN_ROOT}
#export NCRMS=1
#export NCRMS=409
export CC=mpicc
export CXX=mpic++
export FC=mpif90
export FFLAGS="-O3 -ffree-line-length-none -g" 
export CXXFLAGS="-O3 -g"
export ARCH="CUDA"
export CUDA_ARCH="-arch sm_70 -O3 --use_fast_math -D__USE_CUDA__ --expt-extended-lambda --expt-relaxed-constexpr -g -G -lineinfo"
export YAKL_HOME="`pwd`/../../../../../../../../externals/YAKL"
export YAKL_CUB_HOME="${WORKDIR}/cub"

./download_data.sh
./cmakeclean.sh
./cmakescript.sh crmdata_nx32_ny1_nz28_nxrad2_nyrad1.nc crmdata_nx8_ny8_nz28_nxrad2_nyrad2.nc

make -j8

# TODO
# - replace runtest.sh with nsighttest.sh

# old nvprof profiling to get a quick view
jsrun -n1 -c1 -g1 -a1 nvprof --profile-child-processes  ./runtest.sh &> sam++.nvprof

# new nsight systems profiling
jsrun -n1 -c1 -g1 -a1 nsys profile -o sam++.systems -f true ./runtest.sh

# new nsight compute profiling
jsrun -n1 -c1 -g1 -a1 --smpiargs="-disable_gpu_hooks" ncu --target-processes=all -c 1500 --set=full --force-overwrite -o sam++.compute ./runtest.sh
