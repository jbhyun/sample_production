#!/bin/bash
# Author : Jihwan Bhyun, May 14. 2020
# Comment: LHE file is assumed to be 1 file. It is better do so to allow better flexibility in merging files in later steps.
#          Producing multiple LHE files can have duplicate run/event numbers which can be problematic when merging root files.

ProdStep="RecoEIAOD"
CrabCfgFile="skeletons/crab_skeleton.py"
ProdCfgFile="skeletons/RecoEIAOD_cfg.py"
InputList="ListToSubmit.txt"
ReSubList=${InputList}
KillList="ListToKill.txt"
TrigDebug="T"
RunningMode="Pilot" #Init/Resub/Kill/Pilot

if [[ -z $CMSSW_BASE ]]; then echo "cmsenv needed, exiting"; exit 1; fi
if [[ $( pwd ) != "${CMSSW_BASE}/src/sample_production/${ProdStep}/CRAB_KNU" ]]; then echo "Run at CMSSW_BASE of proper dir, exiting"; exit 1; fi
if [[ ( ! -e ${CrabCfgFile} ) || ( ! -e ${ProdCfgFile} ) ]]; then echo "One of target script doesn't exist, exiting"; exit 1; fi 
if [[ ! -e ${InputList} ]]; then echo "input list file doesn't exist, exiting"; exit 1; fi
mkdir -pv Forge; mkdir -pv Logs;

CommandLog="${CMSSW_BASE}/src/sample_production/${ProdStep}/CRAB_KNU/Logs/CommandLog.txt"
touch ${CommandLog}
date >> ${CommandLog}


SampleProdBase=${CMSSW_BASE}/src/sample_production/${ProdStep}/CRAB_KNU
ForgePath=$( readlink -f Forge ) 
NFile=$( wc -l ${InputList} | cut -d ' ' -f1 )

if [[ ${RunningMode} == "Init" || ${RunningMode} == "Pilot" ]]; then
  for (( i=1; i<${NFile}+1; i++ ))
  do
    cd ${SampleProdBase}
   
    Process=$( sed "${i}q;d" ${InputList} | cut -d ' ' -f1 ) 
    InputPath=$( sed "${i}q;d" ${InputList} | cut -d ' ' -f2 )
    ProcessDir="${ForgePath}/${Process}"
    mkdir -pv ${ProcessDir}
   
    CrabCfgFull="${ProcessDir}/crab_${Process}.py"
    ProdCfgFull="${ProcessDir}/${ProdStep}_crab_${Process}.py"
    cp ${CrabCfgFile} ${CrabCfgFull}
    cp ${ProdCfgFile} ${ProdCfgFull}
   
    sed -i "s|##.*config\.|config\.|g" ${CrabCfgFull}
    sed -i "s|requestName\ =\ '[^']*'|requestName\ =\ '${Process}_${CMSSW_VERSION}_${ProdStep}'|g" ${CrabCfgFull}
    sed -i "s|psetName\ =\ '[^']*'|psetName\ =\ '${ProdStep}_crab_${Process}.py'|g" ${CrabCfgFull}
    sed -i "s|inputDataset\ =\ '[^']*'|inputDataset\ =\ '${InputPath}'|g" ${CrabCfgFull}
    sed -i "s|outputDatasetTag\ =\ '[^']*'|outputDatasetTag\ =\ '${CMSSW_VERSION}_${ProdStep}'|g" ${CrabCfgFull}
   
    cd ${ProcessDir}
    PilotOption="";
    if [[ ${RunningMode} == "Pilot" ]]; then PilotOption="--dryrun --skip-estimates"; fi
    if [[ ${TrigDebug} != "T" ]]; then crab submit -c crab_${Process}.py ${PilotOption}; fi
    echo "crab submit -c crab_${Process}.py ${PilotOption}" >> ${CommandLog};
  done
elif [[ ${RunningMode} == "Resub" ]]; then
  if [[ ! -e ${ReSubList} ]]; then echo "list to resubmit doesn't exist, exiting"; exit 1; fi
  BlackListOpt="--siteblacklist=T2_UK_London_IC"
  MaxMemory=2500
  MaxJobRunTime=1400

  while read line
  do
    cd ${SampleProdBase}
    Process=$( echo $line | cut -d ' ' -f1 )
    TargetDir=${ForgePath}/${Process}/crab_projects/crab_${Process}_${CMSSW_VERSION}_${ProdStep}/
    if [[ ! -d ${TargetDir} ]]; then echo "Target Dir doesn't exist for ${Process}, skipping"; continue; fi
    crab resubmit ${BlackListOpt} --maxmemory ${MaxMemory} --maxjobruntime ${MaxJobRunTime} -d ${TargetDir}
    echo "crab resubmit ${BlackListOpt} --maxmemory ${MaxMemory} --maxjobruntime ${MaxJobRunTime} -d ${TargetDir}" >> ${CommandLog}
  done<${ReSubList}

elif [[ ${RunningMode} == "Kill" ]]; then
  if [[ ! -e ${KillList} ]]; then echo "list to kill doesn't exist, exiting"; exit 1; fi

  while read line
  do
    cd ${SampleProdBase}
    Process=$( echo $line | cut -d ' ' -f1 )
    TargetDir=${ForgePath}/${Process}/crab_projects/crab_${Process}_${CMSSW_VERSION}_${ProdStep}/
    if [[ ! -d ${TargetDir} ]]; then echo "Target Dir doesn't exist for ${Process}, skipping"; continue; fi
    crab kill -d ${TargetDir}
    echo "crab kill -d ${TargetDir}" >> ${CommandLog}
  done<${KillList}

elif [[ ${RunningMode} == "Status" ]]; then
  Time=$( date +"%y%m%d_%H%M%S" )
  StatusLog="Logs/StatusReport_${Time}.txt"
  if [[ ! -e ${StatusLog} ]]; then touch $StatusLog; fi

  while read line
  do
    Process=$( echo $line | cut -d ' ' -f1 ) 
    TargetDir=${ForgePath}/${Process}/crab_projects/crab_${Process}_${CMSSW_VERSION}_${ProdStep}/
    crab status -d ${TargetDir} | grep -E "Task|idle|fail|running|finished|transfer|unsubmitted|Output dataset" >> ${StatusLog}
    echo >> ${StatusLog}
  done<${InputList}

else echo "Wrong RunningMode setting."; exit 1; 
fi

echo >> ${CommandLog}
