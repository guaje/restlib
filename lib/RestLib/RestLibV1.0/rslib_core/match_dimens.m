function [S1 S2 M] = match_dimens(S1, S2, M)
% 3D Match Dimensions function
% FORMAT match_dimens(S1, S2)
% S1    - first component image
% S2    - second component image
%____________________________________________________________________________
%
% match_dimens is used to match the dimens of 2 3D volume images
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
[x1, y1, z1] = size(S1);
[x2, y2, z2] = size(S2);
x_min = x1;
y_min = y1;
z_min = z1;
if x2 < x_min
    x_min = x2;
end
if y2 < y_min
    y_min = y2;
end
if z2 < z_min
    z_min = z2;
end
S1 = component_resize(S1, x_min, y_min, z_min);
S2 = component_resize(S2, x_min, y_min, z_min);
M = component_resize(M, x_min, y_min, z_min);

return