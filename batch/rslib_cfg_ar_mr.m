function ar_mr = rslib_cfg_ar_mr
% COMARestLib Configuration file for ArtRepair Motion Regressor 
% Correction
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

rs_imgs         = cfg_files;
rs_imgs.name    = 'Resliced Images';
rs_imgs.tag     = 'rs_imgs';
rs_imgs.filter  = 'image';
rs_imgs.ufilter = '.*';
rs_imgs.num     = [1 Inf];
rs_imgs.help    = {'Select the resliced images.'};

ra_imgs         = cfg_files;
ra_imgs.name    = 'Realigned Images';
ra_imgs.tag     = 'ra_imgs';
ra_imgs.filter  = 'image';
ra_imgs.ufilter = '.*';
ra_imgs.num     = [1 Inf];
ra_imgs.help    = {'Select the realigned images.'};

%% Executable Branch

ar_mr      = cfg_exbranch;
ar_mr.name = 'ArtRepair: Motion Regressor';
ar_mr.tag  = 'rslib_cfg_ar_mr';
ar_mr.val  = {rs_imgs ra_imgs};
ar_mr.prog = @rslib_run_ar_mr;
ar_mr.vout = @vout_data;
%ar_mr.check = @check_data;
ar_mr.help = {['Remove residual interpolation errors after the realign '...
               'and reslice operations. '...
               'It is an alternative to adding motion regressors to '...
               'the design matrix. More fractional variation is '...
               'removed on edge voxels with high variation, while '...
               'little variation is removed on non-edge voxels. The '...
               'function should be applied after realign and reslice, '...
               'but before normalization. '...
               'WARNING! This function will crash or run very slow on '...
               'normalized images.']};

%% Local Functions

function vout = vout_data(job)

vout(1)            = cfg_dep;
vout(1).sname      = 'Motion Corrected Images';
vout(1).src_output = substruct('.', 'mci');
vout(1).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});

vout(2)            = cfg_dep;
vout(2).sname      = 'Maprior Image';
vout(2).src_output = substruct('.', 'mi');
vout(2).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});

vout(3)            = cfg_dep;
vout(3).sname      = 'Motion Regressors';
vout(3).src_output = substruct('.', 'mr');
vout(3).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});

vout(4)            = cfg_dep;
vout(4).sname      = 'Log File';
vout(4).src_output = substruct('.', 'lf');
vout(4).tgt_spec   = cfg_findspec({{'filter', 'any', 'strtype', 'e'}});