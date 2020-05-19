from CRABClient.UserUtilities import config

config = config()

##requestName## e.g., config.General.requestName = 'TTToHcToWA_AToMuMu_MHc100_MA15_CMSSW_7_1_18_GEN-SIM'
config.General.workArea = 'crab_projects'
config.General.transferLogs = True
config.General.transferOutputs = True

config.JobType.pluginName = 'PrivateMC'
config.JobType.maxMemoryMB = 4000
config.JobType.maxJobRuntimeMin = 1400
#config.JobType.numCores = 4
##psetName## e.g., config.JobType.psetName = 'GENSIM_crab.py'

##outputPrimaryDataset## e.g., config.Data.outputPrimaryDataset = 'TTToHcToWA_AToMuMu_MHc100_MA15'
#config.Data.outLFNDirBase = '/store/user/%s/' % (getUsernameFromSiteDB())
config.Data.outputDatasetTag = 'CMSSW_7_1_18_GEN-SIM'
config.Data.splitting = 'EventBased'
config.Data.unitsPerJob = 1000
NJOBS = 200

config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
config.Data.publication = True

config.Site.storageSite = 'T2_KR_KNU'
#config.Site.blacklist = ['T3_US_UMiss']
