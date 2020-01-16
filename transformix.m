function img_out=transformix(img_in,transfer_pars,temp,varargin)
%%
% This script should run Transformix from within Matlab. Note that you will
% need to have Elastix installed on your computer. Depending on how elastix
% was installed, you might need to add the enviroment to you path using code similar to:
% setenv('PATH',[getenv('PATH') ':/software/elastix_macosx64_v4.8/bin'])
% setenv('PATH',[getenv('PATH') ':/software/elastix/bin'])
%%
% requierements: : Jimmy Shen (2020). Tools for NIfTI and ANALYZE image (https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image), MATLAB Central File Exchange.
%%
% this function uses transformix to apply a registration obtained by
% elastix on a image
% img_in: image + header, in format obtained by 'load_untouch_nii'
% from the 'NIFTI' toolbox
% transform_pars: the transformation text file obtained with elastix
% temp: temporary folder to safe the intermediate results. NOTE THAT THIS
% FOLDER IS REMOVED AFTER RUNNING
% if a 4th image is given as input, the header of the final nifti will be
% replaced by that of the 4th input image. Was usefull to me in the past.
%%
% Code is written by Oliver Gurney-Champion
% o.j.gurney-chapion@amsterdamumc.nl
%
%%


if nargin~=3 && nargin~=4
    error('wrong number of arguments')
end


while exist(temp,'dir')
    temp=[temp '1'];
end

mkdir(temp);
scl=img_in.hdr.dime.scl_slope;
img_in.hdr.dime.scl_slope=1;
save_untouch_nii(img_in,fullfile(temp,'img_in.nii'))
mkdir(fullfile(temp,'out'))

com3=sprintf('transformix -in "%s" -out "%s" -tp "%s" -def -threads 1 > /dev/null',fullfile(temp,'img_in.nii'),fullfile(temp,'out'),transfer_pars);
for ll=1:5
system(com3);
end

if 0<exist(fullfile(temp,'out','result.nii'),'file')
    if nargin==3
        img_out=load_untouch_nii(fullfile(temp,'out','result.nii'));
    elseif nargin==4
        tempimg=load_untouch_nii(fullfile(temp,'out','result.nii'));
        img_out=varargin{1};
        sans=size(tempimg.img);
        img_out.hdr.dime.dim(1)=size(sans,2);
        if img_out.hdr.dime.dim(1)==4
            img_out.hdr.dime.dim(5)=sans(4);
        else
            img_out.hdr.dime.dim(5)=1;
        end
        img_out.hdr.dime.scl_slope=scl;
        img_out.hdr.dime.scl_intercept=0;
        img_out.img=tempimg.img;
    end
     delete(fullfile(temp,'out','*'));
     rmdir(fullfile(temp,'out'));
     delete(fullfile(temp,'*'));
     rmdir(fullfile(temp));
else
    sprintf('the temp folder is %s',temp)
    error('registration failed, please check the temp folder')
end

end