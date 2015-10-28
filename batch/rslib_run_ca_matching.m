function out = rslib_run_ca_matching(job)
% COMARestLib Run file for Matching Components
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

out.comps = cell(min(size(job.sub_comps), size(job.stud_comps)));
out.gof = cell(min(size(job.sub_comps), size(job.stud_comps)));
out.stud = cell(min(size(job.sub_comps), size(job.stud_comps)));
num_sub_comps = numel(job.sub_comps);
num_stud_comps = numel(job.stud_comps);
[pth, nam, ext, num] = spm_fileparts(job.mask{1});
mask = load_nii(fullfile(pth, [nam, ext]));
spm_progress_bar('Init', num_sub_comps * num_stud_comps, 'Matching Components', 'Matched Components');

GOF = zeros(num_sub_comps, num_stud_comps);
for i = 1 : num_sub_comps
    [pth, nam, ext, num] = spm_fileparts(job.sub_comps{i});
    sub_comp = load_nii(fullfile(pth, [nam, ext]));
    for j = 1 : num_stud_comps
        [pth, nam, ext, num] = spm_fileparts(job.stud_comps{j});
        stud_comp = load_nii(fullfile(pth, [nam, ext]));
        [sub stu mas] = match_dimens(sub_comp.img, stud_comp.img, mask.img);
        sub = normalize_component(sub, mas);
        stu = normalize_component(stu, mas);
        GOF(i, j) = compute_gof(sub, stu, mas, job.gof);
    end
end

M = linear_matching(GOF, num_sub_comps, num_stud_comps);

if num_sub_comps < num_stud_comps
    for i = 1 : num_sub_comps
        assigned = find(M(i, :) == 1);
        [pth, nam, ext, num] = spm_fileparts(job.stud_comps{assigned});
        out.comps{i} = fullfile(pth, [nam, ext]);
        out.gof{i} = GOF(i, assigned);
        [pth, nam, ext, num] = spm_fileparts(job.sub_comps{i});
        out.stud{i} = fullfile(pth, [nam, ext]);
    end
else
    for i = 1 : num_stud_comps
        assigned = find(M(:, i) == 1);
        [pth, nam, ext, num] = spm_fileparts(job.sub_comps{assigned});
        out.comps{i} = fullfile(pth, [nam, ext]);
        out.gof{i} = GOF(assigned, i);
        [pth, nam, ext, num] = spm_fileparts(job.stud_comps{i});
        out.stud{i} = fullfile(pth, [nam, ext]);
    end
end

spm_progress_bar('Clear');

return