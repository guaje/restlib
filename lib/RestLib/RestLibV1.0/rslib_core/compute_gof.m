function gof = compute_gof(comp1, comp2, mask, type_gof)
% Goodness of fit computation function
% FORMAT compute_gof(comp1, comp2, mask, type_gof)
% comp1    - first component image
% comp2    - second component image
% mask     - mask image
% type_gof - enumerated item in SupportedGOF class
%____________________________________________________________________________
%
% compute_gof is used to find the discrepancy between the observed values 
% and the expected values.
%
% The mask is used to get the roi of the image.
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

comp1 = comp1(logical(mask));
comp2 = comp2(logical(mask));

switch(type_gof)
    case SupportedGOF.GREICIUS.id
        gof = compute_greicius(comp1, comp2);
    case SupportedGOF.GREICIUS_ZMAP.id
        gof = compute_greicius_zmap(comp1, comp2);
    case SupportedGOF.PEARSON.id
        gof = compute_pearson(comp1, comp2);
    %case SupportedGOF.DISTANCE.id
    %case SupportedGOF.NMI.id
    otherwise
        error('Unknown action string');
end
return

function fit = compute_greicius(comp1, comp2)

data_out = comp1(comp2 == 0);
data_in = comp1(comp2 > 0);
fit = mean(data_in) - mean(data_out);
return

function fit = compute_greicius_zmap(comp1, comp2)

v2 = comp1;
v2 = detrend(v2, 0);
vstd = norm(v2, 2) ./ sqrt(length(v2) - 1);
comp1 = comp1 ./ (eps + vstd);
data_out = comp1(comp2 == 0);
data_in = comp1(comp2 > 0);
fit = mean(data_in) - mean(data_out);
return

function fit = compute_pearson(comp1, comp2)

fit = corrcoef(comp1(:), comp2(:));
fit = (fit(1, 2));
return