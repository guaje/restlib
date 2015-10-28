function art = rslib_cfg_art
% COMARestLib Configuration file for Artifact Detection Tools (ART)
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

spm_files         = cfg_files;   % This is the generic data entry item
spm_files.name    = 'SPM Files'; % The displayed name
spm_files.tag     = 'spm_files'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
spm_files.filter  = 'mat';       % 
spm_files.ufilter = '.*';        %
spm_files.num     = [1 1];       % Number of inputs required (2D-array with exactly one row and one column)
spm_files.help    = {'Select the .mat file required for artifact detection with ART.'};

%% Executable Branch

art        = cfg_exbranch;                     % This is the branch that has information about how to run this module
art.name   = 'Artifact Detection Tools (ART)'; % The display name
art.tag    = 'rslib_cfg_art';                  % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
art.val    = {spm_files};                      % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
art.prog   = @rslib_run_art;                   % A function handle that will be called with the harvested job to run the computation
art.vout   = @vout_data;                       % A function handle that will be called with the harvested job to determine virtual outputs
%art.check = @check_data;                      % A function handle that will be called to check the inputs
art.help   = {['Automatic and manual detection of global mean and motion '...
               'outliers in fMRI data.']};

%% Local Functions

function vout = vout_data(job)

vout(1)            = cfg_dep;
vout(1).sname      = 'Config File';
vout(1).src_output = substruct('.', 'cf');
vout(1).tgt_spec   = cfg_findspec({{'filter', 'any', 'strtype', 'e'}});

vout(2)            = cfg_dep;
vout(2).sname      = 'Outlier Statistics File';
vout(2).src_output = substruct('.', 'osf');
vout(2).tgt_spec   = cfg_findspec({{'filter', 'any', 'strtype', 'e'}});

vout(3)            = cfg_dep;
vout(3).sname      = 'Analysis Mask';
vout(3).src_output = substruct('.', 'am');
vout(3).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});