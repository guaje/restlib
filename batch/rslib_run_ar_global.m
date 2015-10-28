function out = rslib_run_ar_global(job)
% COMARestLib Run file for ArtRepair Global Correction
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

out.ci = cell(size(job.imgs));
out.rif = cell(1, 1);
out.dif = cell(1, 1);
[pth, nam, ext, num] = spm_fileparts(job.imgs{1, 1});
msr_regexp = strcat('^msr.*\', ext, '$');
imgs = spm_select('FPList', pth, msr_regexp);
%spm_progress_bar('Init', numel(job.rs_imgs), 'Motion Correction', 'Volumes Complete');
art_global(imgs, job.ra_file{1, 1}, job.mask_type, job.repair_type);
v_regexp = strcat('^vmsr.*\', ext, '$');
files = spm_select('FPList', pth, v_regexp);
for i = 1 : size(files, 1)
    out.ci{i} = files(i, :);
end
out.rif{1} = fullfile(pth, 'art_repaired.txt');
out.dif{1} = fullfile(pth, 'art_deweighted.txt');
%spm_progress_bar('Clear');

return