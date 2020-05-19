#!/bin/bash
# Author : Jihwan Bhyun, May 18., 2020


ProdStep="RecoEIAOD"
InputList="ListToSubmit.txt"
TrigDebug="T"


if [[ -z $CMSSW_BASE ]]; then echo "cmsenv needed, exiting"; exit 1; fi
if [[ $( pwd ) != "${CMSSW_BASE}/src/sample_production/${ProdStep}/CRAB_KNU" ]]; then echo "Run at CMSSW_BASE of proper dir, exiting"; exit 1; fi
if [[ ! -e ${InputList} ]]; then echo "input list file doesn't exist, exiting"; exit 1; fi
if [[ -z $DBS3_CLIENT_ROOT ]]; then export DBS3_CLIENT_ROOT="/cvmfs/cms.cern.ch/crab3/slc6_amd64_gcc493/cms/dbs3-client/3.3.154/"; fi
if [[ ! -d Forge ]]; then echo "Crab directory doesn't exists, exit"; exit 1; fi
mkdir -pv Logs;
ForgePath=$( readlink -f Forge ) 
CommandLog="${CMSSW_BASE}/src/sample_production/${ProdStep}/CRAB_KNU/Logs/CommandLog.txt"
touch ${CommandLog}
date >> ${CommandLog}


while read line
do
  Process=$( echo ${line} | cut -d ' ' -f1 ) 
  InputPath=$( echo ${line} | cut -d ' ' -f2 )
  ProcessDir="${ForgePath}/${Process}"
  echo "Invalidating ${Process}..." 
  if [[ ${TrigDebug} != "T" ]]; then python $DBS3_CLIENT_ROOT/examples/DBS3SetDatasetStatus.py --dataset=${InputPath} --url=https://cmsweb.cern.ch/dbs/prod/phys03/DBSWriter --status=INVALID --recursive=False; fi
  echo "python $DBS3_CLIENT_ROOT/examples/DBS3SetDatasetStatus.py --dataset=${InputPath} --url=https://cmsweb.cern.ch/dbs/prod/phys03/DBSWriter --status=INVALID --recursive=False" >> ${CommandLog}
done<${InputList}

echo >>${CommandLog}
