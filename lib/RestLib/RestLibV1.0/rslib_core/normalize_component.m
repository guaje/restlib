function img = normalize_component(img, mask)
% 3D Component Normalization function
% FORMAT normalize_component(img, mask)
% img    - component image
% mask   - mask image
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

% Z-normalize the component
% masked = img(logical(mask));
% avg = mean(masked);
% stdv = std(masked);
% z_norm = (masked - avg) / stdv;
% img(logical(mask)) = z_norm;
% img(~logical(mask)) = 0;

% Normalize the component
z_norm = img(logical(mask));
z_norm_min = min(z_norm(:));
norm = z_norm - z_norm_min;
norm_max = max(norm(:));
norm = norm * (1 / norm_max);
img(logical(mask)) = norm;
img(~logical(mask)) = 0;

return