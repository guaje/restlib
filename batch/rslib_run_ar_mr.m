function out = rslib_run_ar_mr(job)
% COMARestLib Run file for ArtRepair Motion Regressor Correction
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

out.mci = cell(size(job.rs_imgs));
out.mi = cell(1, 1);
out.mr = cell(6, 1);
out.lf = cell(1, 1);
%spm_progress_bar('Init', numel(job.rs_imgs), 'Motion Correction', 'Volumes Complete');
[rs_pth, rs_nam, rs_ext, rs_num] = spm_fileparts(job.rs_imgs{1});
[ra_pth, ra_nam, ra_ext, ra_num] = spm_fileparts(job.ra_imgs{1});
prefix = rs_nam(1 : size(rs_nam, 2) - size(ra_nam, 2));
rs_regexp = strcat('^', prefix, '.*\', rs_ext, '$');
ra_regexp = strcat('^.*\', ra_ext, '$');
art_motionregress(rs_pth, rs_regexp, ra_pth, ra_regexp);
mci_regexp = strcat('^m', prefix, '.*\', rs_ext, '$');
mci_files = spm_select('FPList', rs_pth, mci_regexp);
for i = 1 : size(mci_files, 1)
    out.mci{i} = mci_files(i, :);
end
out.mi{1} = fullfile(rs_pth, sprintf('%s%s', 'maprior', rs_ext));
mr_regexp = strcat('^mgamma.*\', rs_ext, '$');
mr_files = spm_select('FPList', rs_pth, mr_regexp);
for i = 1 : size(mr_files, 1)
    out.mr{i} = mr_files(i, :);
end
out.lf{1} = fullfile(rs_pth, 'art_motion.txt');
%spm_progress_bar('Clear');

return