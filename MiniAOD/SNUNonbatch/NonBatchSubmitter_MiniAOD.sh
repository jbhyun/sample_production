#!/bin/bash

InputDir=""
OutDir="/data9/Users/jbhyun/PrivGEN/NoFilter/MiniAOD"
InFileList="FileList.txt"
OutFileNameBase="MiniAOD"
Script="MiniAOD_cfg.py"
TrigDebug="F"
TrigMVOut="T" #T or F
Nmax_phy=72
Nmax_man=50

if [[ -z $CMSSW_BASE ]]; then echo "set up cmssw environment."; exit 1; fi
if [[ ! -e $InFileList ]]; then echo "No input file list."; exit 1; fi
if [[ ! -e submission.log ]]; then touch submission.log; fi
if [[ -e AllJobDone ]]; then
  date >> submission.log;
  echo "All job already done.">> submission.log;
  echo >> submission.log;
  exit 1;
fi
if [[ ! -e ListToSubmit.txt ]]; then cp ${InFileList} ListToSubmit.txt; fi
if [[ ! -e ListRunning.txt ]]; then touch ListRunning.txt; fi

date >> submission.log


#Cleaning finished jobs
cp ListRunning.txt Tmp.txt
if [[ ${TrigMVOut} == "T" ]]; then
  if [[ ! -d ${OutDir} ]]; then echo "No such final out path."; exit 1; fi
  while read line
  do
    ProcStr=$( echo $line | rev | cut -d '/' -f2 | rev )
    FileNum=$( echo $line | rev | cut -d '/' -f1 | cut -d '_' -f1 | cut -d '.' -f2 | rev )
    CfgFile=${ProcStr}/${ProcStr}_${FileNum}_cfg.py
    OutFile=${ProcStr}/${OutFileNameBase}_${FileNum}.root
    LogFile=${ProcStr}/${ProcStr}_${FileNum}.log

    if [[ $( tail -1 ${LogFile} ) != "dropped waiting message"* ]]; then continue; fi
    mkdir -p ${OutDir}/${ProcStr}
    cp ${CfgFile} ${OutDir}/${ProcStr}/ && rm ${CfgFile}
    cp ${OutFile} ${OutDir}/${ProcStr}/ && rm ${OutFile}
    cp ${LogFile} ${OutDir}/${ProcStr}/ && rm ${LogFile}
    sed -i "\|${line}|d" Tmp.txt

  done<ListRunning.txt
fi
mv Tmp.txt ListRunning.txt


#Number of jobs to submit
NRunTot=$( top -n1b | egrep "^Tasks:" | cut -d ',' -f2 | rev | cut -d ' ' -f2 | rev )
Njob=$(( ${Nmax_phy} - ${NRunTot} ))
if [[ ${Njob} -lt 0 ]]; then Njob=0; fi
if [[ ${Njob} -gt ${Nmax_man} ]]; then Njob=${Nmax_man}; fi
echo "Currently running jobs: ${NRunTot}, permitted jobs to submit: ${Njob}" >> submission.log


#Submission
Counter=0
cp ListToSubmit.txt Tmp2.txt
while read line
do
  (( ++Counter )) 
  if [[ ${Counter} -gt ${Njob} ]]; then break; fi;

  ProcStr=$( echo $line | rev | cut -d '/' -f2 | rev )
  FileNum=$( echo $line | rev | cut -d '/' -f1 | cut -d '_' -f1 | cut -d '.' -f2 | rev )
  CfgName=${ProcStr}_${FileNum}_cfg.py

  mkdir -p ${ProcStr}
  cp $Script ${ProcStr}/${CfgName}
  sed -i "s|file:'|file:${line}'|g" ${ProcStr}/${CfgName}
  sed -i "s|${OutFileNameBase}.root|${ProcStr}/${OutFileNameBase}_${FileNum}.root|g" ${ProcStr}/${CfgName}

  if [[ ${TrigDebug} == "F" ]]; then
    cmsRun ${ProcStr}/${CfgName} &> ${ProcStr}/${ProcStr}_${FileNum}.log &
  else
    echo "cmsRun ${ProcStr}/${CfgName}" > ${ProcStr}/${ProcStr}_${FileNum}.log 
    echo "dropped waiting message count 1030" >> ${ProcStr}/${ProcStr}_${FileNum}.log 
    touch ${ProcStr}/${OutFileNameBase}_${FileNum}.root
  fi

  sed -i "\|${line}|d" Tmp2.txt
  echo ${line} >> ListRunning.txt
  echo "Submitted ${ProcStr}/${CfgName}" >> submission.log

done<ListToSubmit.txt
mv Tmp2.txt ListToSubmit.txt


#Status Summary 
Nremain=$( wc -l ListToSubmit.txt | cut -d ' ' -f1 )
NRunCurrent=$( wc -l ListRunning.txt | cut -d ' ' -f1 )
if [[ ${Nremain} -eq 0 && NRunCurrent -eq 0 ]]; then touch AllJobDone; echo "All job done" >> submission.log;
elif [[ ${Nremain} -eq 0 ]]; then touch AllJobSubmitted; echo "All job submitted, running: ${NRunCurrent}" >> submission.log;
elif [[ ${Nremain} -gt 0 ]]; then echo "Remaining: ${Nremain}, running: ${NRunCurrent}" >> submission.log;
else echo "Something wrong!!"; fi
echo >> submission.log
