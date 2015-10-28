function art_noiseplots(Qimages);
% function art_noiseplots(Images,voxel)
% >> art_noiseplots  for GUI input
%  
%  Obtains the timecourse of 8 voxels from a set of images, where the voxels
%  are chosen at the 3/8 and 5/8 proportion of the full image size.
%  In a whole brain scan, usually at least four voxels are deep in
%  white matter in each hemisphere. The timeseries on these voxels are
%  not affected much by head motion and physiology. 
%      Also shown is a 5% range of intensities. Ignoring drift, if the
%  variation on most voxels is less than 5%, the data is not noisy. 
%  If the variation on most voxels is
%  larger than 5%, or all the timeseries are noisy at the same times,
%  then the data is likely corrupted by unusually large noise. 
%
%  To estimate a normal level of noise in the data, check other functional
%  images on the same day, or other subjects performing the same task.
%
%  The eight voxels are chosen at the 3/8 and 5/8 proportion of the full
%  array size, e.g. for an image size of 64x64x30, x-voxel is 24 or 40,
%  y-voxel is 24 or 40, and z-voxel is 11 or 19, thus (24,40,19) is one
%  of the eight voxels.
%
%  GUI input
%     Program asks for images
%  Argument input: art_noiseplots(Images)
%     Images: Set of images, with full path names
%  Outputs
%     Plots graph of timeseries.
%
%  A generalization of art_plottimeseries.
%  Paul Mazaika - Mar 2010.
%  Supports SPM12 Jan2015  pkm.

% Configure while preserving old SPM versions
spmv = spm('Ver'); spm_ver = 'spm5';  % chooses spm_select to read vols
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end
if (strcmp(spmv,'SPM2') || strcmp(spmv,'SPM5')) spm_defaults;
    else spm('Defaults','fmri'); end

if nargin > 0
    xyz = voxel;  % not used
else  %  GUI input
    % GUI for imagesif strcmp(spm_ver,'spm5')
    if strcmp(spm_ver,'spm5')
        Qimages = spm_select(Inf,'image','Select images for timeseries');
    else   % spm2
        Qimages  = spm_get(Inf,'.img','select images for timeseries');
    end
    % GUI for voxel location (in voxel)
    %xyz = spm_input('Enter I J K voxel coords (in voxels)',1,'e',[],3);
end
Q = spm_vol(Qimages);
nimages = size(Q,1);
Q1 = spm_read_vols(Q(1));
[ NX, NY, NZ ] = size(Q1);
dim(1) = NX; dim(2) =NY; dim(3) = NZ;

% Choose 8 points distributed around the mid point
xlow = round(3*NX/8); xhigh = round(5*NX/8);
ylow = round(3*NY/8); yhigh = round(5*NY/8);
zlow = round(3*NZ/8); zhigh = round(5*NZ/8);

%coord=round(xyz)';

% %dim=SPM.xY.VY(1).dim
% x=coord(1);
% y=coord(2);
% z=coord(3);

intensity=zeros(nimages,8); %length(SPM.xY.P));
for filenumber=1:nimages  %length(SPM.xY.P)
    Q1 = spm_read_vols(Q(filenumber));
    intensity(filenumber,1) = Q1(xlow,ylow,zhigh);
    intensity(filenumber,2) = Q1(xlow,yhigh,zhigh);
    intensity(filenumber,3) = Q1(xhigh,ylow,zhigh);
    intensity(filenumber,4) = Q1(xhigh,yhigh,zhigh);
    intensity(filenumber,5) = Q1(xlow,ylow,zlow);
    intensity(filenumber,6) = Q1(xlow,yhigh,zlow);
    intensity(filenumber,7) = Q1(xhigh,ylow,zlow);
    intensity(filenumber,8) = Q1(xhigh,yhigh,zlow); 
end
outmean1 = mean(intensity(:,1));
intensity(1:nimages,9) = 1.025*outmean1;
intensity(1:nimages,10) = 0.975*outmean1;

if nargin == 0 | nargin > 0
    %timename=['timecourse' num2str(x) num2str(y) num2str(z) '.txt'];
    figure(20)
    plot(intensity)
%     labl = ['Voxel coordinates  ' num2str(coord)];
     xlabel('Horizontal lines show a 5% intensity range.');
     title('Noise level: Time histories of 8 voxels around midhemisphere.');
%     strint = 'intensity';
%     save(timename,strint,'-ASCII') %-ASCII
end