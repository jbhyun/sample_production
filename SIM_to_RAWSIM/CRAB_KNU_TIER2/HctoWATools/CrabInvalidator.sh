#!/bin/bash
# Author : Jihwan Bhyun, Jan 20. 2017

if [[ -z $CMSSW_BASE ]]; then echo "cmsenv needed, exiting"; exit 1; fi
if [[ $( pwd ) != "${CMSSW_BASE}/src/sample_production/SIM_to_RAWSIM/CRAB_KNU_TIER2" ]]; then echo "Run at CMSSW_BASE of proper dir, exiting"; exit 1; fi
if [[ ! -e CrabSubmitList.txt ]]; then echo "input list file doesn't exist, exiting"; exit 1; fi
if [[ ! -d Forge ]]; then mkdir Forge; echo "Made Forge"; fi;
if [[ -z $DBS3_CLIENT_ROOT ]]; then export DBS3_CLIENT_ROOT="/cvmfs/cms.cern.ch/crab3/slc6_amd64_gcc493/cms/dbs3-client/3.3.154/"; fi

ForgePath=$( readlink -f Forge ) 

NFile=$( wc -l CrabSubmitList.txt | cut -d ' ' -f1 )
#Time=$( date +"%y%m%d_%H%M%S" )
#FileName="InvalidationReport_${Time}.txt"
#if [[ ! -e ${FileName} ]]; then touch $FileName; fi

for (( i=1; i<${NFile}+1; i++ ))
do

 Process=$( sed "${i}q;d" CrabSubmitList.txt | cut -d ' ' -f1 ) 
 InputPath=$( sed "${i}q;d" CrabSubmitList.txt | cut -d ' ' -f2 )
 ProcessDir="${ForgePath}/${Process}"
 echo 
 echo "Command: python $DBS3_CLIENT_ROOT/examples/DBS3SetDatasetStatus.py --dataset=${InputPath} --url=https://cmsweb.cern.ch/dbs/prod/phys03/DBSWriter --status=INVALID --recursive=False"
 python $DBS3_CLIENT_ROOT/examples/DBS3SetDatasetStatus.py --dataset=${InputPath} --url=https://cmsweb.cern.ch/dbs/prod/phys03/DBSWriter --status=INVALID --recursive=False
# echo >> ${FileName}

done

