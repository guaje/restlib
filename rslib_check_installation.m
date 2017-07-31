function ok = rslib_check_installation
% COMA Resting-State Library, COMARestLib.
%
% Function to check installation of SPM
%
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

ok = true;

% Check SPM installation
if exist('spm.m', 'file')
    SPMver = spm('Ver');
    if ~strcmpi(SPMver, 'SPM8') && ~strcmpi(SPMver, 'SPM12')
        beep
        fprintf('\nERROR:\n')
        fprintf('\tThe *latest* version of SPM8 or SPM12 should be installed on your computer,\n')
        fprintf('\tand be available on MATLABPATH!\n\n')
        ok = false;
    end
else
    beep
    fprintf('\nERROR:\n')
    fprintf('\tThe *latest* version of SPM8 or SPM12 should be installed on your computer,\n')
    fprintf('\tand be available on MATLABPATH!\n\n')
    ok = false;
end

% Check the search path
matlab_path = textscan(path,'%s','delimiter',pathsep);
matlab_path = matlab_path{1};
if ~ismember(lower(rslib('Dir')),lower(matlab_path))
    error(sprintf([...
                   'You do not appear to have the MATLAB search path \n'...
                   'set up to include your COMARestLib distribution. \n'...
                   'This means that you can start COMARestLib in this \n'...
                   'directory, but if your change to another \n'...
                   'directory then MATLAB will be unable to find the \n'...
                   'COMARestLib functions. You can use the editpath \n'...
                   'command in MATLAB to set it up. \n\n addpath %s\n\n'...
                   'For more information, try typing the following:\n\n'...
                   'help path\n help editpath'], rslib('Dir')));
end

% Check ArtRepair installation
if ~exist('ArtRepair.m', 'file')
    gpath_artrepair = genpath(fullfile(rslib('Dir'), 'lib', 'ArtRepair'));
    gpath_artrepair = rslib_clean_gpath(gpath_artrepair);
    addpath(gpath_artrepair);
end

% Check Artifact Detection Tools(ART) installation
if ~exist('art.m', 'file')
    gpath_art = genpath(fullfile(rslib('Dir'), 'lib', 'ART'));
    gpath_art = rslib_clean_gpath(gpath_art);
    addpath(gpath_art);
end

% Check GoupICA installation
% if ~exist('groupica.m', 'file')
%     gpath_groupica = genpath(fullfile(rslib('Dir'), 'lib', 'GroupICA'));
%     gpath_groupica = rslib_clean_gpath(gpath_groupica);
%     addpath(gpath_groupica);
% end

% Check NIFTI installation
if ~exist('load_nii.m', 'file')
    gpath_nifti = genpath(fullfile(rslib('Dir'), 'lib', 'NIFTI'));
    gpath_nifti = rslib_clean_gpath(gpath_nifti);
    addpath(gpath_nifti);
end

% Install RestLib
gpath_rslib = genpath(fullfile(rslib('Dir'), 'lib', 'RestLib'));
gpath_rslib = rslib_clean_gpath(gpath_rslib);
addpath(gpath_rslib);

return