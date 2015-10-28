function out = rslib_run_n2a(job)
% COMARestLib Run file for nifti to analyze
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

imgs_sets = job.imgs_set;
nis = numel(imgs_sets);
types = zeros(1, nis);
ibs = zeros(1, nis);
ti = 0;
for i = 1 : nis
    if isfield(imgs_sets(i).type, 'spmic')
        types(i) = 1;
    elseif isfield(imgs_sets(i).type, 'nii')
        types(i) = 2;
    end
    is = numel(imgs_sets(i).imgs);
    ibs(i) = is;
    ti = ti + is;
    out.imgs{i} = cell(size(imgs_sets(i).imgs));
end
spm_progress_bar('Init', sum(ibs), 'Nifti to Analyze', 'Volumes Complete');
for i = 1 : nis
    for j = 1 : ibs(i)
        [pth, nam, ext, num] = spm_fileparts(imgs_sets(i).imgs{j});
        img_fpth = fullfile(pth,[nam ext]);
        res_file = fullfile(imgs_sets(i).dir{1, 1}, nam);
        out_file = fullfile([res_file, '.img']);
        if types(i) == 1
            ic_struct = imgs_sets(i).type.spmic;
            spmimcalc_convert(img_fpth, out_file, ic_struct);
        elseif types(i) == 2
            nifti_convert(img_fpth, res_file);
        end
        out.imgs{i}{j} = out_file;
    end
end
spm_progress_bar('Clear');

return

function [Q, Vo] = spmimcalc_convert(in_img, out_img, ic_struct)
flags = {ic_struct.options.dmtx, ic_struct.options.mask, ic_struct.options.dtype, ic_struct.options.interp};
[Q, Vo] = spm_imcalc_ui(in_img, out_img, ic_struct.expression, flags);
return

function nifti_convert(in_img, out_img)
nii = load_untouch_nii(in_img);
ana = make_ana(nii.img);
save_untouch_nii(ana, out_img);

return