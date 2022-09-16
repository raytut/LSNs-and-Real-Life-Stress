
# Ask for Sub ID and Session
#printf "\n\n\t\e[1;4mSubject Number?\e[0m(eg: 001, 002 etc...) "
#read SUBJ_NR

# FOR LOOP
for SUBJ_NR in {001..156}; do

#Set Directory for Script
TEMPLOGDIR=/project/3013068.02/other/temp_logs
RUN_SCRIPT=/project/3013068.02/scripts/fMRI_task_analysis/template
SUBDIR=/project/3013068.02/data/sub_${SUBJ_NR}/stats

if [ -d $SUBDIR/s1_r1.feat ]; then
	#Replace Subject Number
	for k in $RUN_SCRIPT/second_level_temp.sh; do
		sed -e 's@SUBJECT_FEED@'$SUBJ_NR'@g' <$k> $TEMPLOGDIR/sub_${SUBJ_NR}_secondLevel.sh
	done

	printf "\tSubmitting job for subject ${SUBJ_NR}..."
	echo "bash $TEMPLOGDIR/sub_${SUBJ_NR}_secondLevel.sh" | qsub -N ${SUBJ_NR}_SL -o $TEMPLOGDIR/sub_${SUBJ_NR}_secondLevel_o -e $TEMPLOGDIR/sub_${SUBJ_NR}_secondLevel_e -l "walltime=03:00:00, mem=12gb"

	printf "\n\tDumping logs into $TEMPLOGDIR"
	printf "\n\n"
fi
# END LOOP
done

