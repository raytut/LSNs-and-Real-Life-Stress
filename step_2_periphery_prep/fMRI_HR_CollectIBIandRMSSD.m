%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%   This script collects the HR data from HERA compatible files collected and
%   processed using Brainampconverter. 
%
%	It will go through all subject folders, access the physiology recordings, 
%	and collect the RMSSD and IBI of each subject/run. 
%   
%	The output is a csv tab delimited file in a specified directory, and also includes
%	the name of each run. 
%   
%	Settings are in the first few lines and can be changed according
%   to your projects needs.  Also change the naming convention for each subject folder
%	in line 39.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Directories (Edit according to project needs)
datafolder=fullfile('/project','3013068.02','data');
outputfolder=fullfile('/project','3013068.02','stats','fMRI','Behavioral','fmri_HR.txt');
subject_tot= 200;

%First check if the output file exists
if isfile(outputfolder)
     % File exists.
else
    %Make the file if it doesnt
   header_info={'SUB_NR', 'File_Name', 'IBI','RMSSD', 'RTMSSD'};
   dlmcell(outputfolder, header_info, '\t');
end 
    %Loop over subjects
for sub_nr=1:subject_tot
    %Pad subject number to match naming convetion
     subject_padded = sprintf( '%03d', sub_nr); 

    %Access Phys folder for subject
    subjectfolder = fullfile(datafolder,['3013068.02_BaLS_sub_', subject_padded], 'logs', 'phys');
    if isfolder(subjectfolder)
        cd (subjectfolder);

        %Get all hera files
        herafiles=dir('*_hera.mat');
        N = length(herafiles);
        filenames = cell(N,1);

        %Open hera file in loop
        for i = 1:N
            try
               %Load file
               filename = herafiles(i).name ;
               load (filename);
               %Add everything to a cell with IBI and RMSSD
               C={sub_nr, filename,matfile.outmeasures.preBPM, matfile.outmeasures.rMSSD, matfile.outmeasures.rtMSSD};
               %Append to csv
               dlmcell(outputfolder, C,'\t','-a');
            catch
                %Nothing
            end
        end
    end
end
