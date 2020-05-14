#!/bin/bash

Nexec=$(( 4 * 12 ))  #Total number of execution
Time=15     #Time interval between each execution
Unit='m'   #Time Unit
Script='NonBatchSubmitter_RecoEIAOD.sh'

if [[ ! -e ${Script} ]]; then echo "No script ${Script} to execute. Check it again."; exit 1; fi;

for (( i=0; i<${Nexec}; i++ )); do
  if [[ -e AllJobDone ]]; then break; fi
  ./${Script}
  sleep ${Time}${Unit}
done
