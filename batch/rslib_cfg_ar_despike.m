function ar_despike = rslib_cfg_ar_despike
% COMARestLib Configuration file for ArtRepair Despike Correction
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

filt_type        = cfg_menu;
filt_type.name   = 'Filter Type';
filt_type.tag    = 'filt_type';
filt_type.values = {1 2 3 4};
filt_type.labels = {'17-tap filter', ...
                    '37-tap filter', ...
                    'No high pass filter', ...
                    'Matched filter for single events using temporal smoothing'};
filt_type.val    = {1};
filt_type.help   = {'Choose a filter type.'};

no_clip         = cfg_const;
no_clip.name    = 'None';
no_clip.tag     = 'no_clip';
no_clip.val     = {0};
no_clip.help    = {'No clipping is done.'};

in_clip         = cfg_entry;
in_clip.name    = 'Threshold';
in_clip.tag     = 'in_clip';
in_clip.strtype = 'e';
in_clip.val     = {4};
in_clip.num     = [1 1];
in_clip.help    = {['Clip Threshold is used to despike the data, in '...
                    'units of percentage signal change computed '...
                    'relative to the mean image.']};

despike          = cfg_choice;
despike.name     = 'Despike';
despike.tag      = 'despike';
despike.values   = {no_clip in_clip};
despike.val      = {in_clip};
despike.help     = {'Choose a despike option.'};

%% Executable Branch

ar_despike        = cfg_exbranch;
ar_despike.name   = 'ArtRepair: Despike';
ar_despike.tag    = 'rslib_cfg_ar_despike';
ar_despike.val    = {imgs filt_type despike};
ar_despike.prog   = @rslib_run_ar_despike;
ar_despike.vout   = @vout_data;
%ar_despike.check = @check_data;
ar_despike.help   = {['Removes spikes and slow variations using '...
                      'clipping and a high pass filter. Generally, '...
                      'these functions remove large noise at the '...
                      'expense of slightly reducing the contrast '...
                      'between conditions. '...
                      'WARNING! FOR UNNORMALIZED IMAGES ONLY. The '...
                      'large size of normalized images may cause this '...
                      'program to crash or go very slow.']};

%% Local Functions

function vout = vout_data(job)

vout(1)            = cfg_dep;
vout(1).sname      = 'Despiked Images';
vout(1).src_output = substruct('.', 'di');
vout(1).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});

vout(2)            = cfg_dep;
vout(2).sname      = 'Mean Input Image';
vout(2).src_output = substruct('.', 'mii');
vout(2).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});