function lsdir = rslib_list_subdir(pth_dir, rejd)
% COMA Resting-State Library, COMARestLib.
%
% Function that returns the list of subdirectories of a directory,
% rejecting those beginning with some characters ('.', '@' and '_' by
% default)
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

if nargin < 2
    rejd = '.@_';
end
if nargin < 1
    pth_dir = pwd;
end

tmp = dir(pth_dir);
ld = find([tmp.isdir]);
ld([1 2]) = [];
lsdir = {tmp(ld).name};
if ~isempty(rejd)
    for ii = 1 : numel(rejd)
        lrej = find(strncmp(rejd(ii), lsdir, 1));
        if ~isempty(lrej)
            lsdir(lrej) = [];
        end
    end
end

return