from CRABClient.UserUtilities import config

config = config()

##requestName## e.g., config.General.requestName = 'TTToHcToWA_AToMuMu_MHc100_MA15_CMSSW_7_1_18_GEN-SIM'
config.General.workArea = 'crab_projects'
config.General.transferLogs = True
config.General.transferOutputs = True

config.JobType.pluginName = 'Analysis'
config.JobType.maxMemoryMB = 2500
#config.JobType.maxJobRuntimeMin = 1400
#config.JobType.numCores = 4
##psetName## e.g., config.JobType.psetName = 'GENSIM_crab.py'

##inputDataset## E.g., config.Data.inputDataset = '/TTToHcToWA_AToMuMu_MHc130_MA35_v2/jbhyun-CMSSW_7_1_18_GEN-SIM-c2345211336d5844e3ea1a8a7fbfc845/USER'
config.Data.outputDatasetTag = 'CMSSW_9_4_7_MiniAOD'
config.Data.splitting = 'FileBased'
config.Data.unitsPerJob = 1
config.Data.publication = True

config.Site.storageSite = 'T2_KR_KNU'
#config.Site.whitelist = ['T2_CH_CERN', 'T2_DE_DESY', 'T2_US_Nebraska']
#config.Site.blacklist = ['T3_US_UMiss']
