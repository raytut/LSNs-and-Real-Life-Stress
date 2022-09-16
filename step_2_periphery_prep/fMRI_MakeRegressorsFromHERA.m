%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This script will access the physiological logs corrected
%   using HERA to generate both a .mat and .txt file that cane 
%   be used as regressors in the analysis pipeline made for the 
%   strain study. 
%
%   Authors: Rayyan Tutunji
%   Date Modified: 18-MAR-2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RETRO_2_TXT = RETRO_AND_TXT(sub_nr, sess)

%Get File and Data Variable
subject_padded = [sprintf( '%03d', sub_nr)]; 
datafolder = fullfile('/project','3013068.02','data',['3013068.02_BaLS_sub_', subject_padded], 'logs', 'phys');
cd (datafolder);

%Get session files
if sess==1;
    matfiles = dir(['*_s1','*run*hera.mat']);   % selects only the runs; no full recordings!
    N = length(matfiles);
    filenames = cell(N,1);
elseif sess==2;
    matfiles = dir(['*_s2','*run*hera.mat']);   % selects only the runs; no full recordings!
    N = length(matfiles);
    filenames = cell(N,1);
end;

%Set file names and run RETROICOR
for i = 1:N
   filenames = matfiles(i).name ;
   matFilename = filenames;
   RETROICORplus(matFilename,5,0,cd);
   RETROICORFILE = extractBefore(matFilename,'.mat');
   load([RETROICORFILE, '_RETROICORplus_regr.mat']);
   
   %Name files 
   if isempty(strfind(RETROICORFILE,'s1_r1_fMRI_run_1'))==0;
        dlmwrite ('RETROICOR_s1_run_1.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's1_r1_fMRI_run_2'))==0;
        dlmwrite ('RETROICOR_s1_run_rs1.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's1_r1_fMRI_run_3'))==0;
        dlmwrite ('RETROICOR_s1_run_2.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's1_r1_fMRI_run_4'))==0;
        dlmwrite ('RETROICOR_s1_run_rs2.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's1_r1_fMRI_run_5'))==0;
        dlmwrite ('RETROICOR_s1_run_3.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's1_r2_fMRI_run_1'))==0;
        dlmwrite ('RETROICOR_s1_run_4.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's1_r2_fMRI_run_2'))==0;
        dlmwrite ('RETROICOR_s1_run_rs3.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's1_r2_fMRI_run_3'))==0;
        dlmwrite ('RETROICOR_s1_run_5.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's1_r2_fMRI_run_4'))==0;
        dlmwrite ('RETROICOR_s1_run_rs4.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's1_r2_fMRI_run_5'))==0;
        dlmwrite ('RETROICOR_s1_run_6.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE,'s2_r1_fMRI_run_1'))==0;
        dlmwrite ('RETROICOR_s2_run_1.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's2_r1_fMRI_run_2'))==0;
        dlmwrite ('RETROICOR_s2_run_rs1.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's2_r1_fMRI_run_3'))==0;
        dlmwrite ('RETROICOR_s2_run_2.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's2_r1_fMRI_run_4'))==0;
        dlmwrite ('RETROICOR_s2_run_rs2.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's2_r1_fMRI_run_5'))==0;
        dlmwrite ('RETROICOR_s2_run_3.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's2_r2_fMRI_run_1'))==0;
        dlmwrite ('RETROICOR_s2_run_4.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's2_r2_fMRI_run_2'))==0;
         dlmwrite ('RETROICOR_s2_run_rs3.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's2_r2_fMRI_run_3'))==0;
        dlmwrite ('RETROICOR_s2_run_5.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's2_r2_fMRI_run_4'))==0;
        dlmwrite ('RETROICOR_s2_run_rs4.txt',R,'delimiter','\t');
   elseif isempty(strfind(RETROICORFILE, 's2_r2_fMRI_run_5'))==0;
        dlmwrite ('RETROICOR_s2_run_6.txt',R,'delimiter','\t'); 
   end
end


