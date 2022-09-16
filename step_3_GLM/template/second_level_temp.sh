#####################################################################
#																						 	 
#						Feat-AROMA Bash Script						   
#																						   
#				This script runs processing for a single   
#				run for the BALLS study. It first does the 
#				preprocessing steps, then AROMA followed 
#				by the stats on the AROMA Data    
#																						   	
#				Last Edit: 19-11-2019; Rayyan Toutounji   
#				Author: Rayyan Toutounji								   
#																						   
#####################################################################

#!/bin/bash
#Print out start time and date:
DATE="$(date)"; printf "\n\n\tStart time: $DATE"

#Subject and run Settings
SUBJ=SUBJECT_FEED

#Folder Paths and Settings
SUBFOLD=/project/3013068.02/data/sub_${SUBJ}
SCRIPT=/project/3013068.02/scripts/fMRI_task_analysis/
LOGFILE=$SCRIPT/logs

# Control Stats
S1_1=${SUBFOLD}/stats/s1_r1.feat/stats_event.feat
S1_2=${SUBFOLD}/stats/s1_r2.feat/stats_event.feat
S1_3=${SUBFOLD}/stats/s1_r3.feat/stats_event.feat
S1_4=${SUBFOLD}/stats/s1_r4.feat/stats_event.feat
S1_5=${SUBFOLD}/stats/s1_r5.feat/stats_event.feat
S1_6=${SUBFOLD}/stats/s1_r6.feat/stats_event.feat
# Stress Stats
S2_1=${SUBFOLD}/stats/s2_r1.feat/stats_event.feat
S2_2=${SUBFOLD}/stats/s2_r2.feat/stats_event.feat
S2_3=${SUBFOLD}/stats/s2_r3.feat/stats_event.feat
S2_4=${SUBFOLD}/stats/s2_r4.feat/stats_event.feat
S2_5=${SUBFOLD}/stats/s2_r5.feat/stats_event.feat
S2_6=${SUBFOLD}/stats/s2_r6.feat/stats_event.feat



# Output Folder
OUTPUT_DIR=$SUBFOLD/stats/SecondLevel_event


if [ -d $S1_1 ] && [ -d $S1_1 ]; then
	
	# Print to console
	printf "\n\n\tSTEP 1: Running Second Level Analysis..\n\n"

	#Check if already run
	if [ -e "${OUTPUT_DIR}.feat" ]; then
		printf "\tPreprocessing for run $run already done. Moving to next step...\n"
	else
		#Make the .fsf file for run
		for i in $SCRIPT/feat/feat_3_SecondLevel.fsf; do
			sed -e 's@OUTPUT@'$OUTPUT_DIR'@g' \
			-e 's@S1_R1@'$S1_1'@g' \
			-e 's@S1_R2@'$S1_2'@g' \
			-e 's@S1_R3@'$S1_3'@g' \
			-e 's@S1_R4@'$S1_4'@g' \
			-e 's@S1_R5@'$S1_5'@g' \
			-e 's@S1_R6@'$S1_6'@g' \
			-e 's@S2_R1@'$S2_1'@g' \
			-e 's@S2_R2@'$S2_2'@g' \
			-e 's@S2_R3@'$S2_3'@g' \
			-e 's@S2_R4@'$S2_4'@g' \
			-e 's@S2_R5@'$S2_5'@g' \
			-e 's@S2_R6@'$S2_6'@g'  <$i> $SUBFOLD/stats/${SUBJ}_FEAT_SecondLevel_event.fsf
		done
	fi
	##Run Feat 2
	feat $SUBFOLD/stats/${SUBJ}_FEAT_SecondLevel_event.fsf
	rm $SUBFOLD/stats/${SUBJ}_FEAT_SecondLevel_event.fsf
fi
#fi



