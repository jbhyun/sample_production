#!/bin/bash
# Author : Jihwan Bhyun, Jan 20. 2017
# Context : Functionally, nearly bash version of Jaesung's make_cfg.py. But this scripts reads input from external text file.
#           In Forge dir, make working directories for each input, and write a copy of crab.py, SIMtoRawsim.py in the directory,
#           in SIMtoRawsim.py, add 15 randomly chosen Minbias file path, and in crab.py change configuration file name and paths.
# Usage : in CMSSW_BASE, put Request list in CrabSubmitList.txt, with first column of sample name and 2nd column of DBS path of sample, and those 2 column should be separated with delimeter ' '. And then run it.


if [[ -z $CMSSW_BASE ]]; then echo "cmsenv needed, exiting"; exit 1; fi
if [[ $( pwd ) != "${CMSSW_BASE}/src/sample_production/RAWSIM_to_AODSIM/CRAB_KNU_TIER2" ]]; then echo "Run at CMSSW_BASE of proper dir, exiting"; exit 1; fi
if [[ ! -e CrabReSubmitList.txt ]]; then echo "input list file doesn't exist, exiting"; exit 1; fi
if [[ ! -d Forge ]]; then mkdir Forge; echo "Made Forge"; fi;


SampleProdBase=${CMSSW_BASE}/src/sample_production/RAWSIM_to_AODSIM/CRAB_KNU_TIER2
ForgePath=$( readlink -f Forge ) 

NFile=$( wc -l CrabReSubmitList.txt | cut -d ' ' -f1 )

for (( i=1; i<${NFile}+1; i++ ))
do
 cd ${SampleProdBase}
 Process=$( sed "${i}q;d" CrabReSubmitList.txt | cut -d ' ' -f1 ) 
 TargetDir=${ForgePath}/${Process}/crab_projects/crab_${Process}_CMSSW_8_0_21_AODSIM/
 if [[ ! -d ${TargetDir} ]]; then echo "Target Dir doesn't exist for ${Process}, skipping"; continue; fi 
 crab resubmit -d ${ForgePath}/${Process}/crab_projects/crab_${Process}_CMSSW_8_0_21_AODSIM/
done


#sed 'Nq;d' ;quit at nth line, delete to be printed(but it stops before Nth line)
