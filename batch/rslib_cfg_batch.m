function rslib = rslib_cfg_batch
% COMARestLib Configuration file for COMARestLib Batch System
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

%% ArtRepair Modules

ar        = cfg_choice;
ar.name   = 'ArtRepair';
ar.tag    = 'ar';
ar.values = {rslib_cfg_ar_mr, ...
             rslib_cfg_ar_global, ...
             rslib_cfg_ar_despike};
ar.help   = {'ArtRepair submodules'};

%% Preprocessing Modules

preproc        = cfg_choice;
preproc.name   = 'Preprocessing';
preproc.tag    = 'preproc';
preproc.values = {rslib_cfg_n2a, ...
                  ar, ...
                  rslib_cfg_art};
preproc.help   = {'Preprocessing modules'};

%% ICA decomposition Modules

icad        = cfg_choice;
icad.name   = 'Components Decomposition';
icad.tag    = 'icad';
icad.values = {rslib_cfg_icad_sd};
icad.help   = {'ICA Decomposition modules'};

%% Components Analisys Modules

compsa        = cfg_choice;
compsa.name   = 'Components Analysis';
compsa.tag    = 'compsa';
compsa.values = {rslib_cfg_ca_matching, ...
                 rslib_cfg_ca_classify};
compsa.help   = {'Components Analysis modules'};

%% RestLib Modules

rslib        = cfg_choice;
rslib.name   = 'RestLib';
rslib.tag    = 'rslib';
rslib.values = {preproc, icad, compsa};
rslib.help   = {'Batch UI for RestLib'};

return