function ar_global = rslib_cfg_ar_global
% COMARestLib Configuration file for ArtRepair Global Correction
%_______________________________________________________________________
% Copyright (C) 2013 High Performance Computing Laboratory

% This file is part of COMARestLib.
% 
% COMARestLib is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% COMARestLib is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with COMARestLib.  If not, see <http://www.gnu.org/licenses/>.

% Written by Javier Guaje

%% Input Items

imgs         = cfg_files;
imgs.name    = 'Images';
imgs.tag     = 'imgs';
imgs.filter  = 'image';
imgs.ufilter = '.*';
imgs.num     = [1 Inf];
imgs.help    = {'Select the images to be repaired.'};

ra_file         = cfg_files;
ra_file.name    = 'Realignment File';
ra_file.tag     = 'ra_file';
ra_file.filter  = 'any';
ra_file.ufilter = '.*';
ra_file.num     = [1 1];
ra_file.help    = {'Select the realignment file.'};

mask_type        = cfg_menu;
mask_type.name   = 'Head Mask Type';
mask_type.tag    = 'mask_type';
mask_type.values = {1 4};
mask_type.labels = {'SPM mask' 'Automask'};
mask_type.val    = {4};
mask_type.help   = {'Choose a head mask type.'};

repair_type          = cfg_menu;
repair_type.name     = 'Repair Type';
repair_type.tag      = 'repair_type';
repair_type.values   = {0 1 2};
repair_type.labels   = {'No repairs', ...
                        'Artifact Repair', ...
                        'Movement Adjustment'};
repair_type.val      = {1};
repair_type.help     = {'Choose a repair type.'};

%% Executable Branch

ar_global        = cfg_exbranch;
ar_global.name   = 'ArtRepair: Global';
ar_global.tag    = 'rslib_cfg_ar_global';
ar_global.val    = {imgs ra_file mask_type repair_type};
ar_global.prog   = @rslib_run_ar_global;
ar_global.vout   = @vout_data;
%ar_global.check = @check_data;
ar_global.help   = {['Allows visual inspection of average intensity and '...
                     'scan to scan motion of fMRI data, and offers '...
                     'methods to repair outliers in the data. Outliers '...
                     'are scans whose global intensity is very different '...
                     'from the mean, or whose scan-to-scan motion is '...
                     'large. Thresholds that define the outliers are '...
                     'shown, and they can be adjusted by the user. '...
                     'Margins are defined around the outliers to assure '...
                     'that the repaired data will satisfy the '...
                     '"slowly-varying" background assumption of GLM '...
                     'models. Repairs can be done by '...
                     'interpolation between the nearest non-repaired '...
                     'scans (RECOMMENDED), or despike interpolation '...
                     'using the immediate before and after scans, or '...
                     'inserting the mean image in place of the image to '...
                     'be repaired. Repairs will change the scans marked '...
                     'by red vertical lines. Scans marked by green '...
                     'vertical lines are unchanged, but will be added to '...
                     'the deweighting text file.']};

%% Local Functions

function vout = vout_data(job)

vout(1)            = cfg_dep;
vout(1).sname      = 'Corrected Images';
vout(1).src_output = substruct('.', 'ci');
vout(1).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});

vout(2)            = cfg_dep;
vout(2).sname      = 'Repaired Images File';
vout(2).src_output = substruct('.', 'rif');
vout(2).tgt_spec   = cfg_findspec({{'filter', 'any', 'strtype', 'e'}});

vout(3)            = cfg_dep;
vout(3).sname      = 'Deweighted Images File';
vout(3).src_output = substruct('.', 'dif');
vout(3).tgt_spec   = cfg_findspec({{'filter', 'any', 'strtype', 'e'}});