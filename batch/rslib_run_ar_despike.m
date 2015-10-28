function out = rslib_run_ar_despike(job)
% COMARestLib Run file for ArtRepair Despike Correction
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

out.di = cell(size(job.imgs));
out.mii = cell(1, 1);
[pth, nam, ext, num] = spm_fileparts(job.imgs{1, 1});
vmsr_regexp = strcat('^vmsr.*\', ext, '$');
imgs = spm_select('FPList', pth, vmsr_regexp);
if isfield(job.despike, 'no_clip')
    despike = job.despike.no_clip;
elseif isfield(job.despike, 'in_clip')
    despike = job.despike.in_clip;
end
%spm_progress_bar('Init', numel(job.rs_imgs), 'Motion Correction', 'Volumes Complete');
art_despike(imgs, job.filt_type, despike);
di_regexp = strcat('^dvmsr.*\', ext, '$');
files = spm_select('FPList', pth, di_regexp);
for i = 1 : size(files, 1)
    out.di{i} = files(i, :);
end
mii_regexp = strcat('^meen.*\', ext, '$');
mii_files = spm_select('FPList', pth, mii_regexp);
for i = 1 : size(mii_files, 1)
    out.mii{i} = mii_files(i, :);
end
%spm_progress_bar('Clear');

return