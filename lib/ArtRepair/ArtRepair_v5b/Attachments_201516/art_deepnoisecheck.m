function zout = art_deepnoisecheck(Images,FiltType,Despike)
% FUNCTION art_deepnoisecheck(Images,FiltType,Despike)
%  >> art_deepnoisecheck   to run by GUI
% 
%  BETA-PROGRAM: Estimates noise level in a set of images.
%  Detrends the data using high pass filter, then estimates the
%  RMS fluctuations on every voxel in the detrended data. Writes an image
%  of the RMS fluctuations with prefix RMSnoise, and a mean of the
%  detrended image with prefix RMSnoisemean. Summarizes the fluctuations
%  averaged over the image in percent signal change.
%  
%  For fast quality checks, suggest using >> art_noiseplots instead.
%
% WARNING! FOR UNNORMALIZED IMAGES ONLY. The large size of normalized
% images may cause this program to crash or go very slow.
% ALL IMAGES MUST HAVE THE SAME ORIENTATION AND IMAGE SIZE.
% The program uses a subset of the art_despike program, where 
% FiltType is always 1, and Despike is always 0. 
%
% INPUTS
%    Images is a list of images, in a single session.
%       Images must all have the same orientation and size.
%    NO USER CHOICE: FiltType has 4 options:
%       1. 17-tap filter, aggressive high pass filter.  DEFAULT
%       2. 37-tap filter, long filter for block designs. SPM high pass 
%          filter may be better since it preserves gain. NOT USED
%       3. No high pass filtering is done. Despiking is done based
%          on a 17-point moving average of unfiltered data. NOT USED
%       4. Matched filter for single events using temporal smoothing.
%          Perhaps useful for movies of ER fMRI   NOT USED
%    NO USER CHOICE: Clip Threshold is used to despike the data, in units of percentage
%       signal change computed relative to the mean image.
%       If Despike = 0, no clipping is done. Despike=0 DEFAULT.
% OUTPUTS
%    Mean input image, named RMSnoisemeanINPUT.img, 
%       where INPUT is input image 
%    RMS of detrended images, named RMSnoiseINPUT.img
%    All input images are preserved.
%
% Takes a few minutes for 200 images. 
% Runs through all the images sequentially like a pipeline.
%
%  Compatible with SPM5, SPM8 and SPM2.
%  Compatible with AnalyzeFormat and Nifti images.
%  v.1  July 2008  Paul Mazaika
%  v.2  May 2009 pkm  despike output works off centered mean.
%  Beta-program   Mar2010 pkm


% Identify spm version
spmv = spm('Ver'); spm_ver = 'spm2';
if (strcmp(spmv,'SPM5') | strcmp(spmv,'SPM8b') | strcmp(spmv,'SPM8') )
    spm_ver = 'spm5'; end;
spm_defaults;
  

if nargin == 0
    CLIP = 1;   % 1 to despike,  0 to not despike which is a bit faster.
    % DE-SPIKE CLIP PERCENTAGE. Default is 4%.
    Despikedef = 4;
    %Despike = spm_input('Enter clip threshold (pct sig chg)',1,'e',Despikedef);
    Despike = 0;   % NEW
    if Despike == 0; CLIP = 0; end
    %FiltType = spm_input('Select high pass filter',...
	%	1,'m','17-tap, Robust filter for noisy images |37-tap, Better for block designs in clean images |No high pass filter.|Matched filter for isolated ER designs',[ 1 2 3 4], 1);
    FiltType = 1;   % NEW
    if (Despike == 0 & FiltType == 3) disp('Error: Conflict in inputs.'); return; end;
    if strcmp(spm_ver,'spm5')
        Pimages = spm_select(Inf,'image','Select images to filter');
    else   % spm2
        Pimages  = spm_get(Inf,'.img','select images to filter');
    end
else
    Pimages = Images;
    Despike = 0; FiltType = 1;   % NEW
    %afilt = HPFilter;
    if Despike == 0 & FiltType ~= 3
        CLIP = 0
    elseif Despike > 0
        CLIP = 1;
    elseif Despike == 0 & FiltType == 3
        disp('Error: Conflict in art_despike inputs.');
        return;
    end
end

% Set up filter coefficients
%   HPFilter is a filter vector (1,N) where N must be ODD in length
%       and the sum of the coefficients is zero.
if FiltType == 1
    %  17-tap high pass filter with the coefficients sum of zero
    afilt = [ -1 -1 -1 -1 -1.5 -1.5 -2 -2 22 -2 -2 -1.5 -1.5 -1 -1 -1 -1];
    gain = 1.1/22;  % gain is set for small bias for HRF shape
elseif FiltType == 2
    %  37-tap high pass filter, Takes about 2 sec per image.
    afilt = [ -ones(1,18)  36  -ones(1,18) ];
    gain = 1/36;  % gain is set for small avg. bias to block length 11.
elseif FiltType == 3
    % Skip filtering step. nfilt =17 for clipping baseline.
    afilt = [ -ones(1,7) 0 14 0  -ones(1,7)  ];  % dummy values used only to set nfilt.
    gain = 1/14;
elseif FiltType == 4
    % Movie filter, to possibly see single HRFs in art_movie
    % Filter is matched to HRF shape, assuming TR=2 sec.
    afilt = [ -1 -1 -1.2 -1.2 -1.2 -1.2 -1 -1 2.5 6.3 6.3 2.5 0 -1 -1 -1.2 -1.2 -1.2 -1.2 -1 -1];
    gain = 1/14;
end

% Filter characterization
nfilt = length(afilt); 
if mod(nfilt,2) == 0   % check that filter length is odd.
    disp('Warning from art_despike: Filter length must be odd')
    return
end
if abs(mean(afilt)) > 0.000001
    disp('Warning from art_despike: Filter coefficients must sum to zero.')
    return
end
lag = (nfilt-1)/2;  % filtered value at 9 corresponds to a peak at 5.
% Convert despike threshold in percent to fractional mulitplier limits
spikeup = 1 + 0.01*Despike;
spikedn = 1 - 0.01*Despike;

fprintf('\n Starting RMS check noise estimation');
% fprintf('\n NEW IMAGE FILES WILL BE CREATED');
% fprintf('\n The filtered scan data will be saved in the same directory');
% fprintf('\n with "d" (for despike or detrend) pre-pended to their filenames.\n');
% prechar = 'd';
% if CLIP == 1
%     disp('Spikes are clipped before high pass filtering')
%     disp('Spikes beyond this percentage value are clipped.')
%     disp(Despike)
% else
%     disp('No despiking will be done.');
% end
% if FiltType ~= 3
%     disp('The high pass filter is:');
%     disp(afilt);
%     wordsgain = [ 'With gain =' num2str(gain) ];
%     disp(wordsgain);
% else
%     disp('No filtering will be done.');
% end



% FILTER AND DESPIKE IMAGES
% Process all the scans sequentially
% Start and End are padded by reflection, e.g. sets data(-1) = data(3).
% Initialize lagged values for filtering with reflected values
% Near the end, create forward values for filtering with reflected values.

% Find mean image
    P = spm_vol(Pimages);
    startdir = pwd;
    cd(fileparts(Pimages(1,:)));
    [ xaa, xab, xac ] = fileparts(Pimages(1,:));
    xaab = strtok(xab,'_');   % trim off the volume number
    %meanimagename = [ 'mean' xaab xac ];
    meanimagename = [ 'RMSnoisemean' xaab '.img' ];
    local_mean_ui(P,meanimagename);
    Pmean = spm_vol(meanimagename);
    Vmean = spm_read_vols(Pmean);
    nscans = size(Pimages,1);

% Initialize arrays with reflected values.
Y4 = zeros(nfilt,size(Vmean,1),size(Vmean,2),size(Vmean,3));
Y4s = zeros(1,size(Vmean,1),size(Vmean,2),size(Vmean,3));
disp('Initializing filter inputs for starting data')
for i = 1:(nfilt+1)/2
    i2 = i + (nfilt-1)/2;
    Y4(i2,:,:,:) = spm_read_vols(P(i));
    i3 = (nfilt+1) -  i2;
    if i > 1   % i=1 then i3 = i2.
        Y4(i3,:,:,:) = Y4(i2,:,:,:);
    end
end
%  Start up clipping is done here
if CLIP ==1 
   movmean = squeeze(mean(Y4,1));
   for i = 1:nfilt
       Y4s = squeeze(Y4(i,:,:,:));
       Y4s = min(Y4s,spikeup*movmean);
       Y4s = max(Y4s,spikedn*movmean);
       Y4(i,:,:,:) = Y4s;
   end
end

% Initialize sum of squares array.
NX = size(Vmean,1); NY = size(Vmean,2); NZ = size(Vmean,3);
Ysum2 = zeros(NX,NY,NZ);
Ysum = zeros(NX,NY,NZ);
fprintf('\n Starting RMS image calculation of filtered data...')


% Main Loop
% Speed Note: Use Y4(1,:,:,:) = spm_read_vols(P(1));  % rows vary fastest
%disp('\n Starting Main Loop')
for i = (nfilt+1)/2:nscans+(nfilt-1)/2
    if i <= nscans
        Y4(nfilt,:,:,:) = spm_read_vols(P(i));
    else   % Must pad the end data with reflected values.
        i2 = i - nscans;  
        Y4(nfilt,:,:,:) = spm_read_vols(P(nscans-i2)); % Y4(i2,:,:,:);
    end
    %  Incremental clipping is done here
    if CLIP == 1 & FiltType == 3   % only despiking
        movmean2 = mean(Y4,1);
        movmean = squeeze(movmean2);  % just a speed thing.
        % This lag is from FiltType = 3
        Y4s = squeeze(Y4(nfilt-lag,:,:,:));  % centered for despike only
        Y4s = min(Y4s,spikeup*movmean);
        Y4s = max(Y4s,spikedn*movmean);
        Yn2 = squeeze(Y4s);
    elseif CLIP == 1 & FiltType ~= 3   % combined despike and filter
        movmean2 = mean(Y4,1);
        movmean = squeeze(movmean2);  % just a speed thing.
        Y4s = squeeze(Y4(nfilt,:,:,:));  % predictive despike to use in filter
        Y4s = min(Y4s,spikeup*movmean);
        Y4s = max(Y4s,spikedn*movmean);
        Y4(nfilt,:,:,:) = Y4s;
    end
    if FiltType ~= 3     % apply filter to original or despiked data
        Yn = filter(afilt,1,Y4,[],1);
        Yn2 = squeeze(Yn(nfilt,:,:,:));
        Yn2 = gain*Yn2 + Vmean;
    end
    % Collect RMS statistics on the high-pass detrended array
    Ysum2 = Ysum2 + Yn2.*Yn2;
    Ysum = Ysum + Yn2;

    % Slide the read volumes window up.
    %     showprog = [' Processed volume   ', sname, sext ];
    %     disp(showprog); 
    for js = 1:nfilt-1
        Y4(js,:,:,:) = Y4(js+1,:,:,:);
    end 
end
% Summarize the RMS statistics on the detrended data
Ysum = Ysum/nscans;
Ysum2 = Ysum2/nscans - Ysum.*Ysum;
Ysum2 = sqrt(Ysum2);

% Prepare the header for the RMSnoise volume
V = spm_vol(Pimages(1,:));
v = V;
[dirname, sname, sext ] = fileparts(V.fname);
prechar = 'RMSnoise';
sfname = [ prechar, sname ];
filtname = fullfile(dirname,[sfname sext]);
v.fname = filtname;
spm_write_vol(v,Ysum2); 

% Find image mean within head mask
Pnames = Pimages(1,:);
maskY = art_automask(Pnames,-1,1);
maskcount = sum(sum(sum(maskY)));  %  Number of voxels in mask.
msum = sum(sum(sum(Ysum.*maskY)));  %  Sum of mean image over mask
imgmean = msum/maskcount;
% Find mean of the RMS image within head mask
mstd = sum(sum(sum(Ysum2.*maskY)));  %  Sum of RMS image over mask.
stdmean = mstd/maskcount;

pctstd = 100*stdmean/imgmean;
words = [ '\n\n RMS variation of detrended image, avg over mask in percent:  ', num2str(pctstd)];
fprintf(words)
words = [ '\n\n RMS in percent    actual RMS    image mean over mask'];
fprintf(words)
varstats = [ pctstd   stdmean  imgmean ]

zout = 1;
%fprintf('\nDone with despike and high pass filter!\n');
fprintf('\nDone with preliminary noise check!\n');
cd(startdir)



%------------------------------------------------
function local_mean_ui(P,meanimagename)
% Batch adaptation of spm_mean_ui, with image name added.
% meanimagename is a character string, e.g. 'meansr.img'
% FORMAT spm_mean_ui
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience
% John Ashburner, Andrew Holmes
% $Id: spm_mean_ui.m 1096 2008-01-16 12:12:57Z john $
Vi = spm_vol(P);
n  = prod(size(Vi));
spm_check_orientations(Vi);

%-Compute mean and write headers etc.
%-----------------------------------------------------------------------
fprintf(' ...computing')
Vo = struct(	'fname',	meanimagename,...
		'dim',		Vi(1).dim(1:3),...
		'dt',           [4, spm_platform('bigend')],...
		'mat',		Vi(1).mat,...
		'pinfo',	[1.0,0,0]',...
		'descrip',	'spm - mean image');

%-Adjust scalefactors by 1/n to effect mean by summing
for i=1:prod(size(Vi))
	Vi(i).pinfo(1:2,:) = Vi(i).pinfo(1:2,:)/n; end;

Vo            = spm_create_vol(Vo);
Vo.pinfo(1,1) = spm_add(Vi,Vo);
Vo            = spm_create_vol(Vo);


%-End - report back
%-----------------------------------------------------------------------
fprintf(' ...done\n')
fprintf('\tMean image written to file ''%s'' in current directory\n\n',Vo.fname)

