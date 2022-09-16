#!/bin/bash

#Preset
PRJFLD=/project/3013068.02
# Loop over baseline and task
analysis=(event )
invesfiles=(zstat)
stat="zstat"
# Loop over desings
for method in "${analysis[@]}"; do
	printf "$method - "
	
	#Make OP file with headers
	S_FILE=${PRJFLD}/stats/fMRI/Signal/fMRI_signal_${method}_stress_${stat}.txt
	M_FILE=${PRJFLD}/stats/fMRI/Signal/fMRI_signal_${method}_mean_${stat}.txt
	# Add header to files
	printf " sub_nr\tcope\tRun\tMask\tSignal\n" > ${S_FILE}
	printf " sub_nr\tcope\tRun\tMask\tSignal\n" > ${M_FILE}
	
	# Loop the types of contrasts
	for i in {001..156}; do
		printf "Subject ${i}\n"
		for cope in {1..13}; do # Loop over the task contrasts

			#Set Dirs.
			SUBFLD=$PRJFLD/data/sub_${i}
			STATS=$SUBFLD/stats/SecondLevel_${method}.gfeat
			file="cope${cope}"
			
			if [ -e "$STATS/cope1.feat/stats/${stat}6.nii.gz" ]; then
	
				#Loop over networks
				NETWORKS=(SN DMN ECN)
				for NET in "${NETWORKS[@]}"; do
		
					# Set template directory
					TEMPLATE=$PRJFLD/templates/${NET}_bin.nii.gz
					
					# Get the estimates from the second levels we made
					# Mean Contrast
					MEAN="$(fslstats $STATS/${file}.feat/stats/${stat}1.nii.gz -k ${TEMPLATE}  -M)"
					printf " ${i}\t${file}\tMean\t${NET}\t$MEAN\n" >> ${S_FILE}
					# Control Early
					CEarly="$(fslstats $STATS/${file}.feat/stats/${stat}2.nii.gz -k ${TEMPLATE}  -M)"
					printf " ${i}\t${file}\tControl-Early\t${NET}\t$CEarly\n" >> ${S_FILE}
					# Control Late
					CLate="$(fslstats $STATS/${file}.feat/stats/${stat}3.nii.gz -k ${TEMPLATE}  -M)"
					printf " ${i}\t${file}\tControl-Late\t${NET}\t$CLate\n" >> ${S_FILE}
					# Stress Early
					SEarly="$(fslstats $STATS/${file}.feat/stats/${stat}4.nii.gz -k ${TEMPLATE}  -M)"
					printf " ${i}\t${file}\tStress-Early\t${NET}\t$SEarly\n" >> ${S_FILE}
					# Stress Late
					SLate="$(fslstats $STATS/${file}.feat/stats/${stat}5.nii.gz -k ${TEMPLATE}  -M)"
					printf " ${i}\t${file}\tStress-Late\t${NET}\t$SLate\n" >> ${S_FILE}	
				done
			fi
		done

	done		
done		
			
			

