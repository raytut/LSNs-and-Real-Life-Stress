
function TE=ME_TE_Dicom2Nifti(directory, numberOfTE)
% function responsible to create nifti images from a dicom directory as
% well as extracting the echo times present of the epi images present in a
% given directory
% it is both compatible with multiecho wip data organization and the CMRR
% released sequence

%% find the first echo with series number header information%%
% cd (directory)
% allFiles = dir('*.IMA'); not everybody gets this extension, it depends on
% your PACS and dicom exporter
allFiles = dir(directory);
allFiles = allFiles(3:end); % first two elements are discarded, '.' and '..'
firstFileDicom = dicominfo(allFiles(1).name);
firstEchoNumber = firstFileDicom.SeriesNumber;
stringBeforeEchoNumber = allFiles(1).name(1:strfind(allFiles(1).name,sprintf('%.4d', firstEchoNumber))-1);
%%
try
allFilesReshaped = reshape(allFiles,[size(allFiles,1)/numberOfTE numberOfTE]);
catch
  display('Your number of volumes is not a multiple of the number of echos') 
end

filePerCycle = 50; % # of volumes to be converted in one for cycle, .._headers & .._convert functions seem to slow down with
                   % increasing number of inputs. 

%% Dicom2Nifti %%


    files = char(zeros(length(allFiles),length(allFiles(1).name)+2));
    for i=1:size(files,1)
        files(i,1:length(allFiles(i).name)) = allFiles(i).name;
    end
    
    for i = 1:ceil(size(files,1)/filePerCycle)
        if i == ceil(size(files,1)/filePerCycle) % Last chunk
            hdr = spm_dicom_headers(files((i-1)*filePerCycle+1:end,:));
            for j=1:length(hdr);
                TE(hdr{j}.EchoNumbers) = hdr{j}.EchoTime;
            end;
            spm_dicom_convert(hdr,'mosaic','flat','nii');
        else
            hdr = spm_dicom_headers(files((i-1)*filePerCycle+1:i*filePerCycle,:));
            for j = 1:length(hdr);
                TE(hdr{j}.EchoNumbers) = hdr{j}.EchoTime;
            end;
            spm_dicom_convert(hdr,'mosaic','flat','nii');
        end
    end



