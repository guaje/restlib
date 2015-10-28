function spatial_decomposition = rslib_cfg_icad_sd
% COMARestLib Configuration file for ICA Batch
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

%% Input Items

modal        = cfg_menu;
modal.name   = 'Modality';
modal.tag    = 'modal';
modal.values = {'fMRI' 'EEG'};
modal.labels = {'fMRI' 'EEG'};
modal.val    = {'fMRI'};
modal.help   = {'Choose a modality.'};

icss_mode        = cfg_menu;
icss_mode.name   = 'Mode';
icss_mode.tag    = 'icss_mode';
icss_mode.values = {'randinit' 'bootstrap' 'both'};
icss_mode.labels = {'Randomly Initialized' 'Bootstrapped' 'Both'};
icss_mode.val    = {'randinit'};
icss_mode.help   = {'Choose an option.'};

icss_run         = cfg_entry;
icss_run.name    = 'Number of ICA runs';
icss_run.tag     = 'icss_run';
icss_run.strtype = 'e';
icss_run.val     = {5};
icss_run.num     = [1 1];
icss_run.help    = {'Enter the number of times ICA algorithm will be performed.'};

icss_min         = cfg_entry;
icss_min.name    = 'Number of ICA runs';
icss_min.tag     = 'icss_min';
icss_min.strtype = 'e';
icss_min.val     = {5};
icss_min.num     = [1 1];
icss_min.help    = {'Enter the number of times ICA algorithm will be performed.'};

icss_max         = cfg_entry;
icss_max.name    = 'Number of ICA runs';
icss_max.tag     = 'icss_max';
icss_max.strtype = 'e';
icss_max.val     = {5};
icss_max.num     = [1 1];
icss_max.help    = {'Enter the number of times ICA algorithm will be performed.'};

icss         = cfg_branch;
icss.name    = 'Group ICA using icasso';
icss.tag     = 'icss';
icss.val     = {icss_mode icss_run icss_min icss_max};
icss.help    = {'Parameters for a standard PCA.'};

reg      = cfg_const;
reg.name = 'Regular Group ICA';
reg.tag  = 'reg';
reg.val  = {'1'};
reg.help = {'Regular Group ICA.'};

ana        = cfg_choice;
ana.name   = 'Analisys Type';
ana.tag    = 'ana';
ana.values = {reg icss};
ana.val    = {reg};
ana.help   = {'Choose an analysis type.'};

design_mat        = cfg_menu;
design_mat.name   = 'Design Matrix Selection';
design_mat.tag    = 'design_mat';
design_mat.values = {'no', ...
                     'same_sub_same_sess', ...
                     'same_sub_diff_sess', ...
                     'diff_sub_diff_sess'};
design_mat.labels = {'No design matrix', ...
                     'Same design over subjects and sessions', ...
                     'Same design matrix for subjects but different over sessions', ...
                     'One design matrix per subject'};
design_mat.val    = {'no'};
design_mat.help   = {['Design matrix (SPM.mat) is used for sorting '...
                      'the components temporally (time courses) '...
                      'during display. Design matrix will not be '...
                      'used during the analysis stage except for '...
                      'SEMI-BLIND ICA.']};
                  
imgs         = cfg_files;
imgs.name    = 'Processed Files';
imgs.tag     = 'imgs';
imgs.filter  = 'image';
imgs.ufilter = '.*';
imgs.num     = [1 Inf];
imgs.help    = {['Select the images to decompose into Independent' ...
                 'Components using the ICA algorithm.']};

icap         = cfg_files;
icap.name    = 'ICA Directory';
icap.tag     = 'icap';
icap.filter  = 'dir';
icap.ufilter = '.*';
icap.num     = [1 1];
icap.help    = {'Select the directory for the ICA decomposition process.'};
             
prfx         = cfg_entry;
prfx.name    = 'Prefix';
prfx.tag     = 'prfx';
prfx.strtype = 's';
prfx.val     = {'icaAna'};
prfx.num     = [1 Inf];
prfx.help    = {'Enter the name(Prefix) of the output files.'};

default_mask      = cfg_const;
default_mask.name = 'Default';
default_mask.tag  = 'default_mask';
default_mask.val  = {'[]'};
default_mask.help = {'Default mask.'};

mask_file         = cfg_files;
mask_file.name    = 'Mask File';
mask_file.tag     = 'mask_file';
mask_file.filter  = 'any';
mask_file.ufilter = '.*';
mask_file.num     = [1 1];
mask_file.help    = {'Select the mask file.'};

mask        = cfg_choice;
mask.name   = 'Mask File';
mask.tag    = 'mask';
mask.values = {default_mask mask_file};
mask.val    = {default_mask};
mask.help   = {'Choose a mask option.'};

back_recon        = cfg_menu;
back_recon.name   = 'Back Reconstruction Type';
back_recon.tag    = 'back_recon';
back_recon.values = {1 2};
back_recon.labels = {'Regular', ...
                     'Spatial-temporal Regression'};
back_recon.val    = {1};
back_recon.help   = {'Choose a back reconstruction type.'};

preproc_opt        = cfg_menu;
preproc_opt.name   = 'Preprocessing Options';
preproc_opt.tag    = 'preproc_opt';
preproc_opt.values = {1 2 3 4};
preproc_opt.labels = {'Remove mean per time point', ...
                      'Remove mean per voxel', ...
                      'Intensity normalization', ...
                      'Variance normalization'};
preproc_opt.val    = {1};
preproc_opt.help   = {'Choose a preprocessing option.'};

std_sd        = cfg_menu;
std_sd.name   = 'Stack Data';
std_sd.tag    = 'std_sd';
std_sd.values = {'yes' 'no'};
std_sd.labels = {'Yes' 'No'};
std_sd.val    = {'yes'};
std_sd.help   = {'Choose an option.'};

std_stor        = cfg_menu;
std_stor.name   = 'Storage';
std_stor.tag    = 'std_stor';
std_stor.values = {'full' 'packed'};
std_stor.labels = {'Full' 'Packed'};
std_stor.val    = {'full'};
std_stor.help   = {'Choose an option.'};

std_prec        = cfg_menu;
std_prec.name   = 'Precision';
std_prec.tag    = 'std_prec';
std_prec.values = {'double' 'single'};
std_prec.labels = {'Double' 'Single'};
std_prec.val    = {'double'};
std_prec.help   = {'Choose an option.'};

std_es        = cfg_menu;
std_es.name   = 'Eigen Solver';
std_es.tag    = 'std_es';
std_es.values = {'selective' 'all'};
std_es.labels = {'Selective' 'All'};
std_es.val    = {'selective'};
std_es.help   = {'Choose an option.'};

std         = cfg_branch;
std.name    = 'Standard';
std.tag     = 'std';
std.val     = {std_sd std_stor std_prec std_es};
std.help    = {'Parameters for a standard PCA.'};

em_sd        = cfg_menu;
em_sd.name   = 'Stack Data';
em_sd.tag    = 'em_sd';
em_sd.values = {'yes' 'no'};
em_sd.labels = {'Yes' 'No'};
em_sd.val    = {'yes'};
em_sd.help   = {'Choose an option.'};

em_prec        = cfg_menu;
em_prec.name   = 'Precision';
em_prec.tag    = 'em_prec';
em_prec.values = {'double' 'single'};
em_prec.labels = {'Double' 'Single'};
em_prec.val    = {'single'};
em_prec.help   = {'Choose an option.'};

em_maxiter         = cfg_entry;
em_maxiter.name    = 'Maximum Number of Iterations';
em_maxiter.tag     = 'em_maxiter';
em_maxiter.strtype = 'e';
em_maxiter.val     = {1000};
em_maxiter.num     = [1 1];
em_maxiter.help    = {'Enter the maximum number of iterations.'};

em         = cfg_branch;
em.name    = 'Expectation Maximization';
em.tag     = 'em';
em.val     = {em_sd em_prec em_maxiter};
em.help    = {'Parameters for an Expectation Maximization PCA.'};

pca_type        = cfg_choice;
pca_type.name   = 'PCA Type';
pca_type.tag    = 'pca_type';
pca_type.values = {std em};
pca_type.val    = {std};
pca_type.help   = {'Choose a back reconstruction type.'};

ncomp         = cfg_entry;
ncomp.name    = 'Number of Components';
ncomp.tag     = 'ncomp';
ncomp.strtype = 'i';
ncomp.val     = {30};
ncomp.num     = [1 1];
ncomp.help    = {'Number of components to be computed.'};

%% Executable Branch

spatial_decomposition      = cfg_exbranch;
spatial_decomposition.name = 'Spatial Decomposition';
spatial_decomposition.tag  = 'rslib_cfg_icad_sd';
spatial_decomposition.val  = {modal ana design_mat imgs icap prfx mask ...
                              back_recon preproc_opt pca_type ncomp};
spatial_decomposition.prog = @rslib_run_icad_sd;
spatial_decomposition.vout = @vout_data;
%spatial_decomposition.check = @check_data;
spatial_decomposition.help = {};

%% Local Functions

function vout = vout_data(job)

vout(1)            = cfg_dep;
vout(1).sname      = 'Independent Components';
vout(1).src_output = substruct('.', 'comps');
vout(1).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});

vout(2)            = cfg_dep;
vout(2).sname      = 'Time Courses';
vout(2).src_output = substruct('.', 'tcs');
vout(2).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});

vout(3)            = cfg_dep;
vout(3).sname      = 'Mask';
vout(3).src_output = substruct('.', 'mask');
vout(3).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});