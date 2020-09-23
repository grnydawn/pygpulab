#!/usr/bin/bash

WORK=e3sm_quickstart
PROJECT_ID=cli115
SCRATCH=/gpfs/alpine/${PROJECT_ID}/scratch/${USER}
WORKDIR=${SCRATCH}/${WORK}

rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}
cd ${WORKDIR}

git clone https://github.com/E3SM-Project/E3SM.git
#cd E3SM; git checkout e5d0e555c22e678a23a6dd4f576d49c381201c21; cd ..
cd E3SM
git submodule update --init --recursive


cd cime/scripts
./create_newcase --case ${WORKDIR}/quickstart --project ${PROJECT_ID} --compset A_WCYCL1850S_CMIP6 --res ne30_oECv3_ICG --mach cori-knl --user-mods-dir ../config/e3sm/testmods_dirs/allactive/v1cmip6/
cd cmip6-picontrol
./case.setup
./case.build
./case.submit
