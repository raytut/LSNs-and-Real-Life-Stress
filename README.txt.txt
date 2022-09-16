# Shifts in large-scale networks under stress are linked to affective reactivity to stress in daily life


This is the repository containing code used for the study **"Shifts in large-scale networks under stress are linked to affective reactivity to stress in daily life"**. A description of the processing pipeline is given below, along with the associated scripts used at each step. The analysis notebook with the data processing and statistics run in R can be found [here](). 


## Step 0: MRI and Behavioral Task

The MRI tasks were programmed in Presentation (NeuroBS) and can be founnd in this directory.

## Step 1: Image preparation

1. **Mulit-Echo Combination**: Using *ME_CombineGui_general*, multiecho images were recombined according to the PAID weighting method, resulting in directories with 3D Niftii images for each session. 
2. **fMRI_prepareME.sh:** 3D combined echo images were recombined into single 4D niftii files for each run. 

## Step 2: Peripheral Data:

1. *HR Data*: Heart rate data was recorded on a brainamp system. First, images were converted to Matlab readable files using [brainampconvert](), and heart rate data was then cleaned using [HERA](). Following HR cleaning, the scripts *fMRI_MakeRegressorsFromHERA* and *fMRI_HR_CollectIBIandRMSSD* are used to derive log files for usage as confound regressors and further analysis respectively. 
2. **Log Data**: Log data is cleaned using the *fMRI_LogMaker.py* script, where task logs are made for an event related GLM for each task. 

## Step 3: GLM 

In step 3, a template Feat file is found to be used with FSL, for both first-level (i.e., scanner run) and second-level (i.e., subject level) models. The *all_runs.sh* script runs the first level analysis across all participants, and *SecondLevel.sh* is used for the second level analysis. The individual scripts used to run the models can be found in the templates directory, and the feat design files can be found in the feat directory. 

## Step 4: ROI Analysis

Estimates were extracted from the stat images using the script *fMRI_ExtractSignal*, and statistical testing was carried out using code found in the *r/* directopry. The analysis can also be found in the analysis notebook linked above. 
