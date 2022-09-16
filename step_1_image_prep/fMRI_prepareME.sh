#!/bin/bash

# Load modules needed for fieldmaps
module load dcm2niix

#Read input variables
printf "\n\t\t\e[1;4mSubject number (001,002...)?\e[0m\n\n\t\t"
read -e SUBID
printf "\n\t\t\e[1;4mSession (1/2)\e[0m\n\n\t\t"
read -e SESS
if [ $SESS -eq 1 ]; then
	TYPE=control
elif [ $SESS -eq 2 ]; then
	TYPE=stress
fi


#Default Folders
PROJ=/project/3013068.02
SUBFLD=$PROJ/data/sub_$SUBID
FOLDER=$SUBFLD/func/sess_$SESS/
DATA=$SUBFLD/func/sess_${SESS}/fieldmap
RAW=$PROJ/raw/sub-${SUBID}/ses-${TYPE}
STRUC_RAW=$PROJ/raw/sub-${SUBID}/*/*t1_mprage_sag_p2_iso_1.0
STRUC=$SUBFLD/struc

#Default Outputs
MAG1=${RAW}/015-field_map_2iso
PHASE1=${RAW}/016-field_map_2iso
MAG2=${RAW}/031-field_map_2iso
PHASE2=${RAW}/032-field_map_2iso


#Check if t1 processed, skip if already done
printf "\n\t\t\e[1;4mDCM2NII T1 Conversion...\e[0m\n\n"
if [ -f $STRUC/t1_brain.nii.gz ]; then
	printf "\t\tAlready done, double check if not\n"
else
	dcm2niix -o $STRUC -4 Y -b n -z Y $STRUC_RAW
	mv $STRUC/*t1_mprage_sag_p2_iso_1.0* $STRUC/t1.nii.gz
	bet $STRUC/t1.nii.gz $STRUC/t1_brain.nii.gz -R 
	printf "\n\n\t\tCheck if manual skull stripping needed\n"
fi

#First convert 3D ME into 4D (Skip fieldmap folder to avoid errors)
cd $FOLDER
printf "\n\t\t\e[1;4mRunning 3D to 4D conversion...\e[0m\n\n"
for i in `ls -d *`; do
	if [ "$i" == "fieldmap" ]; then
		printf "\t\tSkipping Fieldmap\n"
        continue;
	fi
	if [ -d $i/PAID_CombinedVolumes/ ]; then
		printf "\t\t$i...\n"
		fslmerge -tr $i/$i $i/PAID_CombinedVolumes/M_* 1.5
		rm -r $i/PAID_CombinedVolumes/
		rm -r $i/converted_Volumes
	else
		printf "\t\tAlready combined $i...\n"
		sleep 1
	fi
done
printf "\n"

# Production of fieldmaps from raw DICOMs
printf "\n\t\t\e[1;4mProcessing fieldmaps...\e[0m\n\n"

#If the files are aquired normally...
if [[ -d $MAG1  &&  -d $MAG2/ ]]; then
	#Convert to dicoms
	dcm2niix -m y -b n -z y -o $DATA -f mag_1 $MAG1/
	dcm2niix -m y -b n -z y -o $DATA -f phase_1 $PHASE1/
	dcm2niix -m y -b n -z y -o $DATA -f mag_2 $MAG2/
	dcm2niix -m y -b n -z y -o $DATA -f phase_2 $PHASE2/
	
	#Rename for consistency
	mv $DATA/mag_1* $DATA/mag_1.nii.gz
	mv $DATA/mag_2* $DATA/mag_2.nii.gz
	mv $DATA/phase_1* $DATA/phase_1.nii.gz
	mv $DATA/phase_2* $DATA/phase_2.nii.gz
	
	if [[ -f $DATA/mag_1.nii.gz && -f $DATA/mag_1.nii.gz ]]; then
		#Complete Robust brain extraction for fieldmap calculation
		bet $DATA/mag_1 $DATA/mag_1_brain -R
		bet $DATA/mag_2 $DATA/mag_2_brain -R
		
		#Calculate fieldmaps with standard SIEMENS parameters
		fsl_prepare_fieldmap SIEMENS $DATA/phase_1 $DATA/mag_1_brain $DATA/fieldmap_1 2.46
		fsl_prepare_fieldmap SIEMENS $DATA/phase_2 $DATA/mag_2_brain $DATA/fieldmap_2 2.46
		# Print successful exist
		printf "\t\tFieldmaps processed successfully. Exiting...\n\n"
	else
		printf "\t\t\e[1mError!\e[0mCheck fieldmap aquisitions!\n\n"
	fi
	
#If not, print error message for manual processing
else
	printf "\t\t\e[1mError!\e[0mCheck fieldmap aquisitions!\n\n"
fi

printf "\n\t\t\e[1;4mDone. Exiting...\e[0m\n\n"
sleep 1
