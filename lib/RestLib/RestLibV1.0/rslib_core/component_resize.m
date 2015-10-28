function out = component_resize(A, x, y, z)
% 3D Volume Resize function
% FORMAT component_resize(A, x, y, z)
% A    - first component image
% x    - x value
% y    - y value
% z    - z value
%____________________________________________________________________________
%
% component_resize is used to resize a 3D volume image
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

% create simple grid
xIn = linspace(0, 1, size(A, 1));
yIn = linspace(0, 1, size(A, 2));
zIn = linspace(0, 1, size(A, 3));

% define output grid
xOut = linspace(0, 1, x);
yOut = linspace(0, 1, y);
zOut = linspace(0, 1, z);

% define interpolant
gi = griddedInterpolant;
gi.GridVectors = {xIn, yIn, zIn};
gi.Values = A;
gi.Method = 'linear';

% regrid the data
out = gi({xOut yOut zOut});

% test first matrix against resizem
% testPrecip = resizem(A(:, :, 1), 2.5, 'bilinear');

% display(sprintf('Max deviation from resizem: %s', max(max(1-(testPrecip./interp(:,:,1))))));

return