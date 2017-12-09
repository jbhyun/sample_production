#!/bin/bash
# Author : Jihwan Bhyun, Jan 20. 2017

if [[ -z $CMSSW_BASE ]]; then echo "cmsenv needed, exiting"; exit 1; fi
if [[ $( pwd ) != "${CMSSW_BASE}/src/sample_production/RAWSIM_to_AODSIM/CRAB_KNU_TIER2" ]]; then echo "Run at CMSSW_BASE of proper dir, exiting"; exit 1; fi
if [[ ! -e CrabSubmitList.txt ]]; then echo "input list file doesn't exist, exiting"; exit 1; fi
if [[ ! -d Forge ]]; then mkdir Forge; echo "Made Forge"; fi;

ForgePath=$( readlink -f Forge ) 

NFile=$( wc -l CrabSubmitList.txt | cut -d ' ' -f1 )
Time=$( date +"%y%m%d_%H%M%S" )
FileName="StatusReport_${Time}.txt"
if [[ ! -e ${FileName} ]]; then touch $FileName; fi

for (( i=1; i<${NFile}+1; i++ ))
do

 Process=$( sed "${i}q;d" CrabSubmitList.txt | cut -d ' ' -f1 ) 
 ProcessDir="${ForgePath}/${Process}"
 crab status -d ${ForgePath}/${Process}/crab_projects/crab_${Process}_CMSSW_8_0_21_AODSIM/ | grep -E "Task|idle|fail|running|finished|transfer|unsubmitted|Output dataset" >> ${FileName}

 echo >> ${FileName}

done

