function gpath = rslib_clean_gpath(gpath, rejd)
% COMA Resting-State Library, COMARestLib.
%
% Function that "cleans up" a list of paths to subdirectories,
% i.e. it removes any path containing a set of strings.
% By default, it removes all the '.svn' paths. Other strings can be passed
% as a cell array
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

if nargin<2
    rejd = {'.svn'};
end
if nargin<1
    return
end

if numel(rejd) > 1
    % do it 1 by 1
    for i = 1 : numel(rejd)
        gpath = rslib_clean_gpath(gpath, rejd{i});
    end
else
    % deal with 1 string
    l_col = strfind(gpath, ':');
    for i = numel(l_col) : -1 : 1
        if i > 1
            pth_bit = [(l_col(i - 1) + 1) l_col(i)];
        else
            pth_bit = [1 l_col(i)];
        end
        if ~isempty(strfind(gpath(pth_bit(1) : pth_bit(2)), rejd{1}))
            % remove the bit
            gpath(pth_bit(1) : pth_bit(2)) = [];
        end
    end
end

return