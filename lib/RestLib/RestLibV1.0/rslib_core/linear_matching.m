function M = linear_matching(GOFMatrix, num_sub_comps, num_stud_comps)
% Linear Programming Solver
% FORMAT linear_matching(GOFMatrix, num_sub_comps, num_stud_comps)
% GOFMatrix      - Goodness of Fit Matrix
% num_sub_comps  - number of subject's components
% num_stud_comps - number of study's components
%____________________________________________________________________________
%
% linear_matching is used to find the optimum match between the study 
% components and the subject components.
%
% The sum of row and column elements usually must be one. It depends of the
% number of subject's components and study's components.
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

f = GOFMatrix(:)';
f_size = size(f);

ARows = zeros(num_sub_comps, f_size(2));
ACols = zeros(num_stud_comps, f_size(2));

% Compute the row's constraints
for i = 1 : num_sub_comps
    nin = i : num_sub_comps : f_size(2);
    ARows(i, nin) = 1;
end

% Compute the column's constraints
prev = 0;
step = 1 : num_sub_comps;
for i = 1 : num_stud_comps
    nin = prev + step;
    ACols(i, nin) = 1;
    prev = prev + num_sub_comps;
end

% Analize and adjust constraints in order to subject's components and
% study's components
if num_sub_comps < num_stud_comps
    M = bintprog(-f, ACols, ones(num_stud_comps, 1), ARows, ones(num_sub_comps, 1));
elseif num_sub_comps == num_stud_comps
    A = [ARows; ACols];
    M = bintprog(-f, zeros(1, f_size(2)), zeros(1, 1), A, ones(num_sub_comps + num_stud_comps, 1));
elseif num_sub_comps > num_stud_comps
    M = bintprog(-f, ARows, ones(num_sub_comps, 1), ACols, ones(num_stud_comps, 1));
end

% Solve the linear problem
M = reshape(M, num_sub_comps, num_stud_comps);

return