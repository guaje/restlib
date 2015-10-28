function rslib_batch
% COMA Resting-State Library, COMARestLib.
%
% This function prepares and launches the batch system.
% This builds the whole tree for the various tools and their GUI at the
% first call to this script.
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

persistent batch_initialize

if isempty(batch_initialize) || ~batch_initialize
    % COMARestLib config tree
    rslib_gui = rslib_cfg_batch;
    % Adding COMARestLib config tree to the SPM tools
    cfg_util('addapp', rslib_gui);
    % No need to do it again for this session
    batch_initialize = 1;
end

% Launching the batch system
cfg_ui;

return