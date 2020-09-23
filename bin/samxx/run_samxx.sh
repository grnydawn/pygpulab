#!/usr/bin/env bash

WORK=sam-cpp
PROJECT_ID=cli115
SCRATCH=/gpfs/alpine/${PROJECT_ID}/scratch/${USER} 
WORKDIR=${SCRATCH}/${WORK}

rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}
cd ${WORKDIR}
#git clone https://github.com/mrnorman/YAKL.git
#cd YAKL; git checkout a35cc1cd6f6c63498752a8d2f00e64ccb9f57621; cd ..
git clone https://github.com/NVlabs/cub.git
cd cub; git checkout c3cceac115c072fb63df1836ff46d8c60d9eb304; cd ..
git clone https://github.com/E3SM-Project/E3SM.git
cd E3SM; git checkout e5d0e555c22e678a23a6dd4f576d49c381201c21; cd ..
cd E3SM
git submodule update --init --recursive
cd components/cam/src/physics/crm/samxx/test/build
rm -rf CMakeCache.txt CMakeFiles

source $MODULESHOME/init/bash
module purge
module load DefApps gcc cuda netcdf/4.6.2 netcdf-fortran/4.4.4 cmake/3.17.3 python/3.7.0-anaconda3-5.3.0 spectrum-mpi
module load nsight-systems nsight-compute

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

./download_data.sh
./cmakeclean.sh
./cmakescript.sh crmdata_nx32_ny1_nz28_nxrad2_nyrad1.nc crmdata_nx8_ny8_nz28_nxrad2_nyrad2.nc

make -j8

cat > ./nsighttest.sh <<- EOM
#!/bin/bash

printf "Running C++ code\n\n"
cd cpp2d
rm -f cpp_output_000001.nc
mpirun -n 1 ./cpp2d || exit -1

cd ..

printf "Running C++ code\n\n"
cd cpp3d
rm -f cpp_output_000001.nc
mpirun -n 1 ./cpp3d || exit -1
EOM
chmod +x ./nsighttest.sh

# commands
#jsrun -n1 -c1 -g1 -a1 --smpiargs=-"disable_gpu_hooks" nsys profile -o sam++.nsys -f true ./nsighttest.sh
#jsrun -n1 -c1 -g1 -a1 nsys profile -o sam++.nsys -f true ./nsighttest.sh
#jsrun -n1 -c1 -g1 -a1 --smpiargs="-gpu" nsys profile -o sam++.nsys -f true ./nsighttest.sh
#jsrun -n1 -c1 -g1 -a1 --smpiargs="-disable_gpu_hooks" ncu --target-processes=all --set=full --force-overwrite -o sam++.ncu.full ./nsighttest.sh
#jsrun -n1 -c1 -g1 -a1 --smpiargs="-disable_gpu_hooks" ncu --target-processes=all --force-overwrite -o sam++.ncu -c 1 ./nsighttest.sh
#jsrun -n1 -c1 -g1 -a1 --smpiargs="-disable_gpu_hooks" ncu --target-processes=all --set=default --section=SpeedOfLight_RooflineChart --force-overwrite -o sam++.ncu.default ./nsighttest.sh

jsrun -n1 -c1 -g1 -a1 --smpiargs="-disable_gpu_hooks" ncu --target-processes=all --force-overwrite -o sam++.ncu ./nsighttest.sh
