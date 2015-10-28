function rslib_defaults
% Sets the defaults which are used by COMARestLib modules
%_______________________________________________________________________
%
% This file is intended to be customised for the site.
% Individual users can make copies which can be stored in their own
% matlab subdirectories. If ~/matlab is ahead of the COMARestLib directory
% in the MATLABPATH, then the users own personal defaults are used.
%
% This function should not be called directly in any script or function
% (apart from COMARestLib internals).
% To get/set the defaults, use rslib_get_defaults.
%
% Care must be taken when modifying this file.
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

% Prevent users from making direct calls to this function
%-----------------------------------------------------------------------
persistent RUN_ONCE
try
    if ~isdeployed && isempty(RUN_ONCE)
        d = dbstack;
        if isempty(intersect({'rslib', 'rslib_get_defaults'}, {d.name}))
            fprintf(['Direct calls to rslib_defauts are not recomended.\n' ...
                     'Please use rslib_get_defaults instead.\n']);
            RUN_ONCE = 1;
        end
    end
end

global RSLIB_DEFAULTS

RSLIB_DEFAULTS.matching.stud_comps = cellstr(char(...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rDMN_corr.img'), ...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rECN_L_corr.img'), ...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rECN_R_corr.img'), ...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rSalience_corr.img'), ...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rSensorimotor_corr.img'), ...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rAuditory_corr.img'), ...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rVisual_medial_corr.img'), ...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rVisual_lateral_corr.img'), ...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rVisual_occipital_corr.img'), ...
    fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj', 'rCerebellum_corr.img')));