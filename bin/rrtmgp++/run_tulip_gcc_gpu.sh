#!/usr/bin/env bash

WORK=rrtmgp-cpp
SCRATCH=/home/groups/coegroup/${USER}
WORKDIR=${SCRATCH}/${WORK}

rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}
cd ${WORKDIR}
git clone https://github.com/mrnorman/YAKL.git
cd YAKL; git checkout a35cc1cd6f6c63498752a8d2f00e64ccb9f57621; cd ..
git clone https://github.com/NVlabs/cub.git
cd cub; git checkout c3cceac115c072fb63df1836ff46d8c60d9eb304; cd ..
git clone https://github.com/E3SM-Project/rte-rrtmgp.git
cd rte-rrtmgp; git checkout 206cb85f0c49ad8113aa58be8c426f030e5b9bad; cd ..
cd rte-rrtmgp/cpp/test/build
rm -rf CMakeCache.txt CMakeFiles
#source $MODULESHOME/init/bash
#module purge
#module load DefApps gcc/6.4.0 cmake/3.17.3 cuda/10.1.243 netcdf-cxx4/4.3.0 netcdf/4.6.2
module load gcc netcdf/gcc/64/4.6.1 cmake

NETCDF_CXX=/home/users/coe0165/opt/netcdf-cxx/4.3.1

export PATH=${NETCDF_CXX}/bin:${PATH}
#export LD_LIBRARY_PATH=${NETCDF_CXX}/lib:${LD_LIBRARY_PATH}

#source summit_gpu.sh
export NCFLAGS="`ncxx4-config --libs`"
export CC=gcc
export CXX=g++
export CXXFLAGS="-O3"
export ARCH="CUDA"
export CUDA_ARCH="-arch sm_70 --std=c++14 --use_fast_math -O3"
export CUBHOME="${WORKDIR}/cub"
export YAKLHOME="${WORKDIR}/YAKL"
export YAKL_CXX_FLAGS="-I${NETCDF_CXX}/include"

./get_data.sh
./cmakescript.sh
make -j8
make test
