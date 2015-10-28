function out = rslib_run_icad_sd(job)
% COMARestLib Run file for ICA Batch
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

out.mask = cell(1, 1);
spm_progress_bar('Init', numel(job.imgs), 'Spatial Decomposition', 'Spatial Components Computed');

pf_dir = fullfile(job.icap{1, 1}, 'processed_files');
if ~exist(pf_dir, 'dir')
    mkdir(pf_dir);
end

ext = '';
for i = 1 : numel(job.imgs)
    [pth, nam, ext, num] = spm_fileparts(job.imgs{i});
    img = fullfile(pth,[nam ext]);
    copyfile(img, pf_dir);
    if strcmp(ext, '.img')
        hdr = fullfile(pth,[nam '.hdr']);
        copyfile(hdr, pf_dir);
    end
end

components_dir = fullfile(job.icap{1, 1}, 'components');
if ~exist(components_dir, 'dir')
    mkdir(components_dir);
end

icss_mode = '<icssMode/>';

icss_run = 5;
icss_min = 2;
icss_max = 15;
if isfield(job.ana, 'reg')
    ana_type = 1;
elseif isfield(job.ana, 'icss')
    ana_type = 2;
    icss_mode = job.ana.icss.icss_mode;
    icss_run = job.ana.icss.icss_run;
    icss_min = job.ana.icss.icss_min;
    icss_max = job.ana.icss.icss_max;
end

if isfield(job.mask, 'default_mask')
    maskFile = job.mask.default_mask;
elseif isfield(job.mask, 'mask_file')
    maskFile = ['''', job.mask.mask_file{1, 1}, ''''];
end

std_sd = '<stdSD/>';
std_stor = '<stdStor/>';
std_prec = '<stdPrec/>';
std_es = '<stdES/>';
em_sd = '<emSD/>';
em_prec = '<emPrec/>';

em_maxiter = 1000;
if isfield(job.pca_type, 'std')
    pca_type = 1;
    std_sd = job.pca_type.std.std_sd;
    std_stor = job.pca_type.std.std_stor;
    std_prec = job.pca_type.std.std_prec;
    std_es = job.pca_type.std.std_es;
elseif isfield(job.pca_type, 'em')
    pca_type = 2;
    em_sd = job.pca_type.em.em_sd;
    em_prec = job.pca_type.em.em_prec;
    em_maxiter = job.pca_type.em.em_maxiter;
end

gicat_file = fullfile(rslib('Dir'), 'parameters_templates', 'GroupICATemplate.m');
copyfile(gicat_file, job.icap{1, 1});
gicat_fid = fopen(gicat_file);
sgicat_fid = fopen(fullfile(job.icap{1, 1}, 'GroupICATemplate.m'), 'w');
prefix = job.prfx;
while 1
    tline = fgetl(gicat_fid);
    if ~ischar(tline)
        break
    end
    modifiedStr = strrep(tline, '<modality/>', job.modal);
    modifiedStr = strrep(modifiedStr, '<anaType/>', sprintf('%d', ana_type));
    modifiedStr = strrep(modifiedStr, '<icssMode/>', icss_mode);
    modifiedStr = strrep(modifiedStr, '<icssRun/>', sprintf('%d', icss_run));
    modifiedStr = strrep(modifiedStr, '<icssMin/>', sprintf('%d', icss_min));
    modifiedStr = strrep(modifiedStr, '<icssMax/>', sprintf('%d', icss_max));
    modifiedStr = strrep(modifiedStr, '<designMat/>', job.design_mat);
    modifiedStr = strrep(modifiedStr, '<dirProcessedFiles/>', pf_dir);
    modifiedStr = strrep(modifiedStr, '<ext/>', ext);
    modifiedStr = strrep(modifiedStr, '<dirOutputFile/>', components_dir);
    modifiedStr = strrep(modifiedStr, '<prefix/>', prefix);
    modifiedStr = strrep(modifiedStr, '<maskFile/>', maskFile);
    modifiedStr = strrep(modifiedStr, '<backRecon/>', sprintf('%d', job.back_recon));
    modifiedStr = strrep(modifiedStr, '<preprocOpt/>', sprintf('%d', job.preproc_opt));
    modifiedStr = strrep(modifiedStr, '<pcaType/>', sprintf('%d', pca_type));
    modifiedStr = strrep(modifiedStr, '<stdSD/>', std_sd);
    modifiedStr = strrep(modifiedStr, '<stdStor/>', std_stor);
    modifiedStr = strrep(modifiedStr, '<stdPrec/>', std_prec);
    modifiedStr = strrep(modifiedStr, '<stdES/>', std_es);
    modifiedStr = strrep(modifiedStr, '<emSD/>', em_sd);
    modifiedStr = strrep(modifiedStr, '<emPrec/>', em_prec);
    modifiedStr = strrep(modifiedStr, '<emMaxIter/>', sprintf('%d', em_maxiter));
    modifiedStr = strrep(modifiedStr, '<numberComponents/>', sprintf('%d', job.ncomp));
    fprintf(sgicat_fid, '%s\n', modifiedStr);
end
fclose(gicat_fid);
fclose(sgicat_fid);
icatb_batch_file_run(fullfile(job.icap{1, 1}, 'GroupICATemplate.m'));
cd(rslib('Dir'));

out.comps = cell(job.ncomp, 1);
comps_prefix = sprintf('%s%s', prefix, '_sub01_component_ica_s1_');
comps_file = fullfile(components_dir, sprintf('%s%s', comps_prefix, '.nii'));
if exist(comps_file, 'file')
    spm_file_split(comps_file);
    comps_regexp = strcat('^', comps_prefix, '_.*\.nii$');
    comps_files = spm_select('FPList', components_dir, comps_regexp);
    for i = 1 : size(comps_files, 1)
        out.comps{i} = comps_files(i, :);
    end
end

out.tcs = cell(1, 1);
tcs_filename = sprintf('%s%s', prefix, '_sub01_timecourses_ica_s1_.nii');
tcs_file = fullfile(components_dir, tcs_filename);
if exist(tcs_file, 'file')
    out.tcs{1} = tcs_file;
end

mask_prefix = fullfile(components_dir, sprintf('%s%s', prefix, 'Mask'));
mask_hdr = sprintf('%s%s', mask_prefix, '.hdr');
mask_img = sprintf('%s%s', mask_prefix, '.img');
if exist(mask_hdr, 'file') && exist(mask_img, 'file')
    out.mask{1} = mask_img;
end

spm_progress_bar('Clear');

return