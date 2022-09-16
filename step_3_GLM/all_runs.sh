

# Ask for Sub ID and Session
#printf "\n\n\t\e[1;4mSubject Number?\e[0m(eg: 001, 002 etc...) "
#read SUBJ_NR
#printf "\n\t\e[1;4mSession Number?\e[0m(1/2) "
#read SESS_NR
#printf "\n"

# FOR LOOP
for SUBJ_NR in {001..156}; do
	for SESS_NR in {1..2}; do
		# Set directory
		SUBDIR=/project/3013068.02/data/sub_${SUBJ_NR}
		# If subject exists:
		if [ -d $SUBDIR ]; then
			
			TEMPLOGDIR=/project/3013068.02/other/temp_logs
			RUN_SCRIPT=/project/3013068.02/scripts/fMRI_task_analysis/template

			#Loop to replace template with run number, then run on cluster
			for i in {1..6}; do
				for k in $RUN_SCRIPT/run_temp.sh; do
					sed -e 's@SUBJECT_FEED@'$SUBJ_NR'@g' \
					-e 's@RUN_FEED@'$i'@g'\
					-e 's@SESS_FEED@'$SESS_NR'@g' <$k> $TEMPLOGDIR/sub_${SUBJ_NR}_S${SESS_NR}_${i}.sh
				done
				printf "\tSubmitting run ${i}..."
				echo "bash $TEMPLOGDIR/sub_${SUBJ_NR}_S${SESS_NR}_${i}.sh" | qsub -N ${SUBJ_NR}_RUN_${i} -o $TEMPLOGDIR/sub_${SUBJ_NR}_${SESS_NR}_${i}_o -e $TEMPLOGDIR/sub_${SUBJ_NR}_${SESS_NR}_${i}_e -l "walltime=04:00:00, mem=12gb"
			done
			printf "\n\tDumping logs into $TEMPLOGDIR"
			printf "\n\n"

		# END LOOP
		fi
	done
done
