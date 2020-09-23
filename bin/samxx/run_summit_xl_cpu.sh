#!/usr/bin/env bash

WORK=rrtmgp-cpp
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
git clone https://github.com/E3SM-Project/rte-rrtmgp.git
cd rte-rrtmgp; git checkout 206cb85f0c49ad8113aa58be8c426f030e5b9bad; cd ..
cd rte-rrtmgp/cpp/test/build
rm -rf CMakeCache.txt CMakeFiles

source $MODULESHOME/init/bash
module purge
#module load DefApps gcc cmake cuda netcdf-cxx4 netcdf
module load DefApps xl cmake cuda netcdf-cxx4 netcdf
module list
unset ARCH
unset CUDA_ARCH
unset CUBHOME

unset ARCH
unset NCRMS

#-std=extended1y

export NCFLAGS="`ncxx4-config --libs`"
export CC=xlc
export CXX=xlc++
#export CXXFLAGS="-O3"
export CXXFLAGS="-O3 -std=extended1y"
export YAKLHOME="${WORKDIR}/YAKL"

./get_data.sh
./cmakeclean.sh
cp ~/cmakescript.sh .
./cmakescript.sh
make -j8
#./run_test.sh
#make test
