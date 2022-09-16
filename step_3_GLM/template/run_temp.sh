#####################################################################
#																						 	 
#						Feat-AROMA Bash Script						   
#																						   
#				This script runs processing for a single   
#				run for the BALLS study. It first does the 
#				preprocessing steps, then AROMA followed 
#				by the stats on the AROMA Data    
#																						   	
#				  
#				Author: Rayyan Toutounji								   
#																						   
#####################################################################

#!/bin/bash

#Print out start time and date:
DATE="$(date)"; printf "\n\n\tStart time: $DATE"

#Subject and run Settings
SUBJ=SUBJECT_FEED
SESS=SESS_FEED
run=RUN_FEED
if [ ${run} -ge 1 -a ${run} -le 3 ]; then 
	FLDNR=1
else
	FLDNR=2
fi

#Folder Paths and Settings
SUBFOLD=/project/3013068.02/data/sub_${SUBJ}
SCRIPT=/project/3013068.02/scripts/fMRI_task_analysis/
LOGFILE=$SCRIPT/logs

# Step 1 Registration and MC files
OUTPUT1=$SUBFOLD/stats/s${SESS}_r${run}
FUNCFILE=$SUBFOLD/func/sess_${SESS}/run_${run}/run_${run}.nii.gz
NVOLS="$(fslnvols $FUNCFILE)"
ANATFILE=$SUBFOLD/struc/t1_brain
FIELDMAPFILE=$SUBFOLD/func/sess_${SESS}/fieldmap/fieldmap_${FLDNR}
MAGNITUDEFILE=$SUBFOLD/func/sess_${SESS}/fieldmap/mag_${FLDNR}_brain
STATS1=$SUBFOLD/stats/s${SESS}_r${run}.feat 

# Step 2 AROMA Files
AROMA_DIR=$STATS1/AROMA
AROMA_Denoised_Func=$AROMA_DIR/denoised_func_data_nonaggr.nii.gz
AROMA_HPF=$AROMA_DIR/denoised_func_data_nonaggr_hpf.nii.gz
AROMA_MEAN=$AROMA_DIR/denoised_func_data_nonaggr_mean.nii.gz
AROMA_BPF=$AROMA_DIR/denoised_func_data_nonaggr_bpfiltered.nii.gz

# Step 3 register to standard
FUNC_STD=$AROMA_DIR/filtered_func_data_clean_hpf.nii.gz
STATS2=$STATS1/stats_event

# Step 4: CSF and WM regressors
WMNOISE=$STATS1/WM_noise.txt
CSFNOISE=$STATS1/CSF_noise.txt
RETROICOR=$SUBFOLD/logs/phys/RETROICOR_s${SESS}_run_${run}.txt

# Step 5: STATS
Time_NBack_0Back=$SUBFOLD/logs/mri/nback_0backs_${SESS}_r${run}.txt
Time_NBack_2Back=$SUBFOLD/logs/mri/nback_2backs_${SESS}_r${run}.txt

Time_Odd_Odds=$SUBFOLD/logs/mri/oddball_oddballs_${SESS}_r${run}.txt
Time_Odd_Nodds=$SUBFOLD/logs/mri/oddball_noddballs_${SESS}_r${run}.txt

Time_Mem_For=$SUBFOLD/logs/mri/memory_incorrect_${SESS}_r${run}.txt
Time_Mem_Rem=$SUBFOLD/logs/mri/memory_correct_${SESS}_r${run}.txt


if [ -e $FUNCFILE ]; then
	
	####################################
	#Feat Part 1: Preprocessing 1
	####################################
	printf "\n\n\tSTEP 1: Running first steps in FSL...\n\n"


	#First check if prerocessing done. If not, then run it
	if [ -e "$STATS1" ]; then
		printf "\tPreprocessing for run $run already done. Moving to next step...\n"
	elif [ -e $FUNCFILE ]; then
		#Make the .fsf file for run
		for i in $SCRIPT/feat/feat_1_preAROMA.fsf; do
			sed -e 's@OUTPUT@'$OUTPUT1'@g' \
			-e 's@NVOL@'$NVOLS'@g' \
			-e 's@ANAT@'$ANATFILE'@g' \
			-e 's@FIELDMAP@'$FIELDMAPFILE'@g' \
			-e 's@MAGNITUDE@'$MAGNITUDEFILE'@g' \
			-e 's@DATA@'$FUNCFILE'@g' <$i> $SUBFOLD/stats/FEAT_S${SESS}_1_${run}.fsf
		done
		#Runs the analysis
		printf "\tRunning preprocessing for run ${run}..."
		feat $SUBFOLD/stats/FEAT_S${SESS}_1_${run}.fsf
	fi

	DATE="$(date +%T)"
	printf "\n\tFinshed:$DATE\n"
	####################################
	#Feat Part 2: ICA-AROMA
	####################################
	
	printf "\n\n\tSTEP 2: Running ICA-AROMA...\n\n"
	DATE="$(date +%T)"
	printf "\n\tStarted:$DATE\n\n"

	#Check if AROMA already done. If yes move on.
	if [ -e "$AROMA_DIR/filtered_func_data_clean_hpf.nii.gz" ]; then
		printf "\tICA-AROMA already done for run ${run}, proceeding to next step...\n"
	else
		#Remove AROMA folder in case ran unsuccesfully
		rm -r $STATS1/AROMA
		#Prints the run being analyzed
		printf "\tRunning AROMA for run ${run}... "
		#Run ICA-AROMA (Req Python 2.7)
		source activate ANALYSIS
		/project/3013068.02/scripts/ICA-AROMA/ICA_AROMA.py -f $STATS1 -den both -o $AROMA_DIR
	fi

	DATE="$(date +%T)"
	printf "\n\tFinished:$DATE\n"
	####################################
	#Feat Part 3: High Pass Filter
	####################################
	
	printf "\n\n\tSTEP 3: Highpass filter + CSF and WM Regressor Creation\n\n"
	DATE="$(date +%T)"
	printf "\n\tStarted:$DATE\n\n"

	if [ -f "$AROMA_DIR/filtered_func_data_clean_hpf.nii.gz" ]; then
		printf "\tHigh pass filtering already done for run ${run}, proceeding to next step...\n"
	else 
		#Apply High Pass Filter: set as volumes, 20 volumes = 100 sec
		printf "\n\tProcessing run ${run}..."
		# Get mean and bandpass filter
		fslmaths $AROMA_Denoised_Func -Tmean $AROMA_MEAN
		fslmaths $AROMA_Denoised_Func -bptf 20 -1  $AROMA_BPF
		# Add mean back to filtered data and copy to stat dir
		fslmaths $AROMA_BPF -add $AROMA_MEAN $AROMA_HPF
		cp $AROMA_HPF $STATS1/filtered_func_data_clean_hpf.nii.gz
		cp $AROMA_HPF $AROMA_DIR/filtered_func_data_clean_hpf.nii.gz
	fi
	
	####################################
	#Feat Part 4: WM + CSF regressors
	####################################
	
	#Get WM and CSF Regressors
	if [ -f "$STATS1/CSF_noise.txt" ]; then
		printf "\tWM and CSF timecourse already extracted for run ${run}, proceeding to next step...\n"
	else 	
		#Segment T1 
		fast --channels=1 --type=1 --class=3 $ANATFILE.nii.gz
		
		#Apply inverse transformation parameters from example2highres to mask with filtered_func_data.nii.gz as target using ApplyXFM
		#For CSF
		flirt -in ${ANATFILE}_pve_0.nii.gz -ref $STATS1/filtered_func_data.nii.gz -applyxfm -init $STATS1/reg/example_func2highres_inv.mat -out $STATS1/t1_brain_CSF_reg.nii.gz
		#For WM
		flirt -in ${ANATFILE}_pve_2.nii.gz -ref $STATS1/filtered_func_data.nii.gz -applyxfm -init $STATS1/reg/example_func2highres_inv.mat -out $STATS1/t1_brain_WM_reg.nii.gz
		#threshold the probabilty a given voxel is CSF or WM...
		#For CSF 0.98
		fslmaths $STATS1/t1_brain_CSF_reg.nii.gz -thr 0.98 $STATS1/t1_brain_CSF_reg_thr.nii.gz
		#For WM 1
		fslmaths $STATS1/t1_brain_WM_reg.nii.gz -thr 1 $STATS1/t1_brain_WM_reg_thr.nii.gz
		#Extract values
		fslmeants -i $STATS1/filtered_func_data -m $STATS1/t1_brain_CSF_reg_thr.nii.gz -o $STATS1/CSF_noise.txt 
		fslmeants -i $STATS1/filtered_func_data  -m $STATS1/t1_brain_WM_reg_thr.nii.gz -o $STATS1/WM_noise.txt
		# Merge into a single regressor file
		paste $STATS1/CSF_noise.txt $STATS1/WM_noise.txt > $STATS1/confound_regressors.txt
		Confound_file=$STATS1/confound_regressors.txt
	fi
	
	####################################
	#Feat Part 5: Stats
	####################################
	
	if [ ! -f "$FUNC_STD" ]; then
		printf "\tSomething in the preprocessing for run ${run} went wrong. Check and try again...\n"
	elif [[ -e "$STATS2.feat" ]]; then
		printf "\tStats already done for ${run}\n"
	else 	  
		printf "\n\n\tSTEP 4: STATS...\n\n"
		NVOLS2="$(fslnvols $FUNC_STD)"
		##Modify Template 	
		for i in $SCRIPT/feat/feat_2_postAROMA.fsf; do
			sed -e 's@OUTPUT@'$STATS2'@g' \
			-e 's@NVOL@'$NVOLS2'@g' \
			-e 's@DATA@'$FUNC_STD'@g' \
			-e 's@ConfoundFile@'$Confound_file'@g' \
			-e 's@NPATH2@'$Time_NBack_2Back'@g' \
			-e 's@NPATH0@'$Time_NBack_0Back'@g' \
			-e 's@ODDPATHO@'$Time_Odd_Odds'@g'\
			-e 's@ODDPATHN@'$Time_Odd_Nodds'@g'\
			-e 's@MEMPATHR@'$Time_Mem_Rem'@g'\
			-e 's@MEMPATHF@'$Time_Mem_For'@g' <$i> $SUBFOLD/stats/FEAT_S${SESS}_2_${run}.fsf
		done
		
		##Run Feat 2
		feat $SUBFOLD/stats/FEAT_S${SESS}_2_${run}.fsf
		cp -r $STATS1/reg $STATS2.feat/reg
		# Clean up redundant files
		#rm  $AROMA_DIR/denoised*
		rm $STATS1/*.nii.gz
		#cp  $AROMA_DIR/filtered_func_data_clean_hpf.nii.gz $FUNC_STD #move aroma file back
		printf "\n"
	fi
	
	####################################
	#Feat Part 6: Clean-up and sync
	####################################
	printf "\n\n\tSTEP 5: Cleanup...\n\n"
	#Remove unecessary files to save on storage
	rm $SUBFOLD/stats/FEAT_S${SESS}_1_${run}.fsf
	rm $SUBFOLD/stats/FEAT_S${SESS}_2_${run}.fsf

fi
#fi



