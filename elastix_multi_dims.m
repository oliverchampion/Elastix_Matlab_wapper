function imgs_out=elastix_multi_dims(imgs_in,transform_pars,temp,transf_par,mask,mmask)
%%
% This script should run Elastix from within Matlab. Note that you will
% need to have Elastix installed on your computer. Depending on how elastix
% was installed, you might need to add the enviroment to you path using code similar to:
% setenv('PATH',[getenv('PATH') ':/software/elastix_macosx64_v4.8/bin'])
% setenv('PATH',[getenv('PATH') ':/software/elastix/bin'])
%%
% requierements: : Jimmy Shen (2020). Tools for NIfTI and ANALYZE image (https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image), MATLAB Central File Exchange.
%%
% this function uses elastix to register a 4D set of images to itself over the 4th dimension.
% nii_in: 4D image + header, in format obtained by 'load_untouch_nii'
% from the 'NIFTI' toolbox
% transform_pars: path to the text file containin the transformation
% parameters. Examples from my work are added and more examples can be
% found on the Elastix wikipedia. Note that if this is a list containing
% two files, instead, the program will do the transformations subsequently
% temp: temporary folder to safe the intermediate results. NOTE THAT THIS
% FOLDER IS REMOVED AFTER RUNNING
% transf_par: Location where the transformation is saved.
% mask is the fixed mask (binary) as loaded by the NIFTI toolbox
% mmask is the moving mask (binary) as loaded by the NIFTI toolbox
%%
% Code is written by Oliver Gurney-Champion
% o.j.gurney-chapion@amsterdamumc.nl
%
%%
% setenv('PATH',[getenv('PATH') ':/data_Oliver/software/elastix/bin'])
if imgs_in.hdr.dime.dim(5)~=size(imgs_in.img,4)
    error('header and image size disagree')
end

if imgs_in.hdr.dime.dim(5)==1
    error('input image is 3D instead of 4D')
end

while exist(temp,'dir')
    temp=[temp '1'];
end
dims=imgs_in.hdr.dime.dim(5);
mkdir(temp);
mkdir(temp,'out');
save_untouch_nii(imgs_in,fullfile(temp,'img.nii'))
if nargin==6
    save_untouch_nii(mask,fullfile(temp,'mask.nii'));
    save_untouch_nii(mmask,fullfile(temp,'mmask.nii'));
    % moving mask has been turned off!
    com=sprintf('elastix -f "%s" -m "%s" -out %s -p "%s" -fMask "%s" -threads 12 > /dev/null',fullfile(temp,'img.nii'),fullfile(temp,'img.nii'),fullfile(temp,'out'),transform_pars,fullfile(temp,'mask.nii'));
    system(com);
        filepath=fullfile(temp,'out');
        if exist(fullfile(filepath,'result.0.nii'),'file')
        else
            sprintf('temp is %s',temp);
            error('registration failed, please check the temp folder  %s',temp);
        end
        imgs_out=load_untouch_nii(fullfile(filepath,'result.0.nii'));
        do=sprintf('cp "%s" "%s"',fullfile(filepath,'TransformParameters.0.txt'),transf_par);
        system(do);
        delete(fullfile(filepath,'*'));
        rmdir(fullfile(filepath));
elseif nargin==4
       com=sprintf('elastix -f "%s" -m "%s" -out "%s" -p "%s" -threads 8 > /dev/null',fullfile(temp,'img.nii'),fullfile(temp,'img.nii'),fullfile(temp,'out'),transform_pars);
    system(com);
        filepath=fullfile(temp,'out');
        if exist(fullfile(filepath,'result.0.nii'),'file')
        else
            sprintf('temp is %s',temp);
            error('registration failed, please check the temp folder  %s',temp);
             
        end
        imgs_out=load_untouch_nii(fullfile(filepath,'result.0.nii'));
        do=sprintf('cp "%s" "%s"',fullfile(filepath,'TransformParameters.0.txt'),transf_par);
        system(do);
        %delete(fullfile(filepath,'*'));
        %rmdir(fullfile(filepath));
else
    sprintf('currently in folder %s',temp);
    error('wrong number of input arguments')
end
        %delete(fullfile(temp,'*'));
        %rmdir(fullfile(temp));
        imgs_out.hdr.dime.dim(1)=4;
        imgs_out.hdr.dime.dim(5)=dims;

end