#!/bin/bash

if [[ -e submission.log ]]; then rm submission.log; fi
if [[ -e ListRunning.txt ]]; then rm ListRunning.txt; fi
if [[ -e ListToSubmit.txt ]]; then rm ListToSubmit.txt; fi
if [[ -e AllJobDone ]]; then rm AllJobDone; fi
if [[ -e AllJobSubmitted ]]; then rm AllJobSubmitted; fi
