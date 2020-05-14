#!/bin/bash
export SCRAM_ARCH=slc6_amd64_gcc630
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_9_3_15_patch2/src ] ; then 
 echo release CMSSW_9_3_15_patch2 already exists
else
scram p CMSSW CMSSW_9_3_15_patch2
fi
cd CMSSW_9_3_15_patch2/src
eval `scram runtime -sh`

curl -s --insecure https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/B2G-RunIIFall17wmLHEGS-01851 --retry 2 --create-dirs -o Configuration/GenProduction/python/B2G-RunIIFall17wmLHEGS-01851-fragment.py 
[ -s Configuration/GenProduction/python/B2G-RunIIFall17wmLHEGS-01851-fragment.py ] || exit $?;

scram b
cd ../../
seed=$(($(date +%s) % 100 + 1))
cmsDriver.py Configuration/GenProduction/python/B2G-RunIIFall17wmLHEGS-01851-fragment.py --fileout file:B2G-RunIIFall17wmLHEGS-01851.root --mc --eventcontent RAWSIM,LHE --datatier GEN-SIM,LHE --conditions 93X_mc2017_realistic_v3 --beamspot Realistic25ns13TeVEarly2017Collision --step LHE,GEN,SIM --nThreads 8 --geometry DB:Extended --era Run2_2017 --python_filename B2G-RunIIFall17wmLHEGS-01851_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${seed})" -n 244 || exit $? ; 


