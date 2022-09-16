

# Ask for Sub ID
printf "\n\n\t\e[1;4mSubject Number?\e[0m(eg: 001, 002 etc...) "
read SUBJ_NR
printf "\n\t\e[1;4mSession Number?\e[0m(1/2) "
read SESS_NR
printf "\n\t\e[1;4mRun Number?\e[0m(1-6) "
read i
printf "\t"

RUN_SCRIPT=/project/3013068.02/scripts/feat_AROMA/template
TEMP_LOG=/project/3013068.02/other/temp_logs

for k in $RUN_SCRIPT/run_temp.sh; do
	sed -e 's@SUBJECT_FEED@'$SUBJ_NR'@g' \
	-e 's@RUN_FEED@'$i'@g'\
	-e 's@SESS_FEED@'$SESS_NR'@g' <$k> $TEMP_LOG/sub_${SUBJ_NR}_${i}.sh
done
echo "$TEMP_LOG/sub_${SUBJ_NR}_${i}.sh" | qsub -N ${SUBJ_NR}_RUN_${i} -o $TEMP_LOG/sub_${SUBJ_NR}_${SESS_NR}_${i}_o -e $TEMP_LOH/sub_${SUBJ_NR}_${SESS_NR}_${i}_e -l "walltime=08:00:00, mem=12gb"

