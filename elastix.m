function [regim]=elastix(nii_fix,nii_mov,transform_pars,temp,mask,transf_par,varargin)
%%
% This script should run Elastix from within Matlab. Note that you will
% need to have Elastix installed on your computer. Depending on how elastix
% was installed, you might need to add the enviroment to you path using code similar to:
% setenv('PATH',[getenv('PATH') ':/software/elastix_macosx64_v4.8/bin'])
% setenv('PATH',[getenv('PATH') ':/software/elastix/bin'])
%%
% requierements: : Jimmy Shen (2020). Tools for NIfTI and ANALYZE image (https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image), MATLAB Central File Exchange.
%%
% this function uses elastix to register 2 images to eachother. A fixed image and a moving one. 
% nii_fix: fixed image + header, in format obtained by 'load_untouch_nii'
% from the 'NIFTI' toolbox
% nii_mov: moving image + header (same format)
% transform_pars: path to the text file containin the transformation
% parameters. Examples from my work are added and more examples can be
% found on the Elastix wikipedia. Note that if this is a list containing
% two files, instead, the program will do the transformations subsequently
% temp: temporary folder to safe the intermediate results. NOTE THAT THIS
% FOLDER IS REMOVED AFTER RUNNING
% Mask: if mask ='both' it will mask both images, using the masks provided as varargin (moving mask first). 
% If mask='mov' or 'fix' it will only use a moving or fixed mask, which should be provided as last argument.
% transf_par: Location where the transformation is saved.
%%
% Code is written by Oliver Gurney-Champion
% o.j.gurney-chapion@amsterdamumc.nl
%
%%

%% generate temporary wrking folder
while exist(temp,'dir')
    temp=[temp '1'];
end

mkdir(temp);
save_untouch_nii(nii_fix,fullfile(temp,'fixed_file.nii'))
save_untouch_nii(nii_mov,fullfile(temp,'moving_file.nii'))
mkdir(fullfile(temp,'out'));

%% determine the elastix mode to run
if strcmp(mask,'both')
    if nargin~=8
        error('not the right amount of input arguments')
    end
    movmask=varargin{1};
    fixmask=varargin{2};
    % saving the nifti
    save_untouch_nii(movmask,fullfile(temp,'moving_mask.nii'));
    save_untouch_nii(fixmask,fullfile(temp,'fixed_mask.nii'));
    % performing the transformation
    if size(transform_pars,2)>2
        % if a single transformation is given
        com=sprintf('elastix -f %s -m %s -out %s -p %s -mMask %s -fMask %s -threads 16 > /dev/null',fullfile(temp,'fixed_file.nii'),fullfile(temp,'moving_file.nii'),fullfile(temp,'out'),transform_pars,fullfile(temp,'moving_mask.nii'),fullfile(temp,'fixed_mask.nii'));       
    else
        % if two transformation files are given as subsequent
        % transformations
        com=sprintf('elastix -f %s -m %s -out %s -p %s -p %s -mMask %s -fMask %s -threads 16 > /dev/null',fullfile(temp,'fixed_file.nii'),fullfile(temp,'moving_file.nii'),fullfile(temp,'out'),transform_pars{1},transform_pars{2},fullfile(temp,'moving_mask.nii'),fullfile(temp,'fixed_mask.nii'));       
    end
elseif strcmp(mask,'fix')
    if nargin~=7
        error('not the right amount of input arguments')
    end
    fixmask=varargin{1};
    save_untouch_nii(fixmask,fullfile(temp,'fixed_mask.nii'));
        if size(transform_pars,2)>2
            com=sprintf('elastix -f %s -m %s -out %s -p %s -fMask %s -threads 16 > /dev/null',fullfile(temp,'fixed_file.nii'),fullfile(temp,'moving_file.nii'),fullfile(temp,'out'),transform_pars,fullfile(temp,'fixed_mask.nii'));       
        else
            com=sprintf('elastix -f %s -m %s -out %s -p %s -p %s -fMask %s -threads 16 > /dev/null',fullfile(temp,'fixed_file.nii'),fullfile(temp,'moving_file.nii'),fullfile(temp,'out'),transform_pars{1},transform_pars{2},fullfile(temp,'fixed_mask.nii'));       
    
        end
elseif strcmp(mask,'mov')
    if nargin~=7
        error('not the right amount of input arguments')
    end
    movmask=varargin{1};
    save_untouch_nii(movmask,fullfile(temp,'moving_mask.nii'));
            if size(transform_pars,2)>2
                com=sprintf('elastix -f %s -m %s -out %s -p %s -mMask %s -threads 16 > /dev/null',fullfile(temp,'fixed_file.nii'),fullfile(temp,'moving_file.nii'),fullfile(temp,'out'),transform_pars,fullfile(temp,'moving_mask.nii'));       
            else
                com=sprintf('elastix -f %s -m %s -out %s -p %s -p %s -mMask %s -threads 16 > /dev/null',fullfile(temp,'fixed_file.nii'),fullfile(temp,'moving_file.nii'),fullfile(temp,'out'),transform_pars{1},transform_pars{2},fullfile(temp,'moving_mask.nii'));       
            end
else
    if nargin~=6
        error('not the right amount of input arguments')
    end
    
                if size(transform_pars,2)>2
                        com=sprintf('elastix -f %s -m %s -out %s -p %s -threads 16 > /dev/null',fullfile(temp,'fixed_file.nii'),fullfile(temp,'moving_file.nii'),fullfile(temp,'out'),transform_pars);       
                else
                        com=sprintf('elastix -f %s -m %s -out %s -p %s -p %s -threads 16 > /dev/null',fullfile(temp,'fixed_file.nii'),fullfile(temp,'moving_file.nii'),fullfile(temp,'out'),transform_pars{1},transform_pars{2});       
                end
end
%% actually performing the transformation
    system(com);
    %% copy all results to right location
    if size(transform_pars,2)<3
        regim=load_untouch_nii(fullfile(temp,'out','result.1.nii'));
        
        do=sprintf('cp "%s" "%s"',fullfile(temp,'out','TransformParameters.0.txt'),[transf_par(1:end-5) '1.txt']);
        system(do);
        
        fid=fopen(fullfile(temp,'out','TransformParameters.1.txt'),'r');
        fid2=fopen([transf_par(1:end-5) '2.txt'],'w');
        while(~feof(fid))
            s=fgetl(fid);
            s=strrep(s,fullfile(temp,'out','TransformParameters.0.txt'),[transf_par(1:end-5) '1.txt']);
            fprintf(fid2,'%s\n',s);
        end
        fclose('all');
        delete(fullfile(temp,'out','*'));
        rmdir(fullfile(temp,'out'));
        delete(fullfile(temp,'*'));
        rmdir(fullfile(temp));
    elseif exist(fullfile(temp,'out','result.0.nii'),'file')>0
        regim=load_untouch_nii(fullfile(temp,'out','result.0.nii'));
        do=sprintf('cp "%s" "%s"',fullfile(temp,'out','TransformParameters.0.txt'),transf_par);
        system(do);
        delete(fullfile(temp,'out','*'));
        rmdir(fullfile(temp,'out'));
        delete(fullfile(temp,'*'));
        rmdir(fullfile(temp));
    else
        sprintf('temp folder: %s',temp)
        error('registration failed, please check the temp folder')
    end
    
end