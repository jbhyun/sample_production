#!/bin/bash
# Author : Jihwan Bhyun, Jan 20. 2017
# Context : Functionally, nearly bash version of Jaesung's make_cfg.py. But this scripts reads input from external text file.
#           In Forge dir, make working directories for each input, and write a copy of crab.py, SIMtoRawsim.py in the directory,
#           in SIMtoRawsim.py, add 15 randomly chosen Minbias file path, and in crab.py change configuration file name and paths.
# Usage : in CMSSW_BASE, put Request list in CrabSubmitList.txt, with first column of sample name and 2nd column of DBS path of sample, and those 2 column should be separated with delimeter ' '. And then run it.


if [[ -z $CMSSW_BASE ]]; then echo "cmsenv needed, exiting"; exit 1; fi
if [[ $( pwd ) != "${CMSSW_BASE}/src/sample_production/AODSIM_to_MiniAOD/CRAB_KNU_TIER2" ]]; then echo "Run at CMSSW_BASE of proper dir, exiting"; exit 1; fi
if [[ ( ! -e skeletons/crab_skeleton.py ) || ( ! -e skeletons/AODSIM_to_MiniAOD.py ) ]]; then echo "One of target script doesn't exist, exiting"; exit 1; fi 
if [[ ! -e CrabSubmitList.txt ]]; then echo "input list file doesn't exist, exiting"; exit 1; fi
if [[ ! -d Forge ]]; then mkdir Forge; echo "Made Forge"; fi;


SampleProdBase=${CMSSW_BASE}/src/sample_production/AODSIM_to_MiniAOD/CRAB_KNU_TIER2
ForgePath=$( readlink -f Forge ) 

NFile=$( wc -l CrabSubmitList.txt | cut -d ' ' -f1 )

for (( i=1; i<${NFile}+1; i++ ))
do
 cd ${SampleProdBase}

 Process=$( sed "${i}q;d" CrabSubmitList.txt | cut -d ' ' -f1 ) 
 InputPath=$( sed "${i}q;d" CrabSubmitList.txt | cut -d ' ' -f2 )
 ProcessDir="${ForgePath}/${Process}"
 if [[ ! -d ${ProcessDir} ]]; then mkdir ${ForgePath}/${Process}; echo "Made ProcDir for ${Process}"; fi

 cp skeletons/crab_skeleton.py ${ProcessDir}/crab_${Process}.py
 cp skeletons/AODSIM_to_MiniAOD.py ${ProcessDir}/AODSIM_to_MiniAOD_crab_${Process}.py


 sed -i "s/##.*config\./config\./g" ${ProcessDir}/crab_${Process}.py
 sed -i "s/requestName\ =\ '[^']*'/requestName\ =\ '${Process}_CMSSW_8_0_21_MiniAOD'/g" ${ProcessDir}/crab_${Process}.py
 sed -i "s/psetName\ =\ '[^']*'/psetName\ =\ 'AODSIM_to_MiniAOD_crab_${Process}.py'/g" ${ProcessDir}/crab_${Process}.py
 sed -i "s:inputDataset\ =\ '[^']*':inputDataset\ =\ '${InputPath}':g" ${ProcessDir}/crab_${Process}.py

 cd ${ProcessDir}
 #crab submit -c crab_${Process}.py
done
