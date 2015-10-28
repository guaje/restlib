function rslib_add_paths
% COMA Resting-State Library, COMARestLib.
%
% Function add some subpaths to the MATLABPATH
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

if ~exist('rslib_cfg_batch', 'file')
    addpath(fullfile(rslib('Dir'), 'batch'));
end

gpath_restlib = genpath(fullfile(rslib('Dir'), 'lib', 'RestLib'));
gpath_restlib = rslib_clean_gpath(gpath_restlib);
addpath(gpath_restlib);

gpath_weka = genpath(fullfile(rslib('Dir'), 'lib', 'Weka'));
gpath_weka = rslib_clean_gpath(gpath_weka);
addpath(gpath_weka);

javaaddpath(fullfile(rslib('Dir'), 'lib', 'weka.jar'));
%javaaddpath('/opt/homebrew-cask/Caskroom/weka/3.6.12/weka-3-6-12/weka.jar');
javaaddpath(fullfile(rslib('Dir'), 'lib', 'libsvm.jar'));
%javaaddpath('/Users/jariguaje/Neuro/Software/libsvm-3.20/java/libsvm.jar');

return