#!/bin/bash
export SCRAM_ARCH=slc6_amd64_gcc630
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_9_4_7/src ] ; then 
 echo release CMSSW_9_4_7 already exists
else
scram p CMSSW CMSSW_9_4_7
fi
cd CMSSW_9_4_7/src
eval `scram runtime -sh`


scram b
cd ../../
cmsDriver.py step1 --fileout file:B2G-RunIIFall17DRPremix-02050_step1.root  --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer17PrePremix-MCv2_correctPU_94X_mc2017_realistic_v9-v1/GEN-SIM-DIGI-RAW" --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions 94X_mc2017_realistic_v11 --step DIGIPREMIX_S2,DATAMIX,L1,DIGI2RAW,HLT:2e34v40 --nThreads 8 --datamix PreMix --era Run2_2017 --python_filename B2G-RunIIFall17DRPremix-02050_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 1089 || exit $? ; 

cmsDriver.py step2 --filein file:B2G-RunIIFall17DRPremix-02050_step1.root --fileout file:B2G-RunIIFall17DRPremix-02050.root --mc --eventcontent AODSIM --runUnscheduled --datatier AODSIM --conditions 94X_mc2017_realistic_v11 --step RAW2DIGI,RECO,RECOSIM,EI --nThreads 8 --era Run2_2017 --python_filename B2G-RunIIFall17DRPremix-02050_2_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 1089 || exit $? ; 


