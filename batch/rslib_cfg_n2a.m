function n2a = rslib_cfg_n2a
% COMARestLib Configuration file for nifti to analyze
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

name         = cfg_entry;
name.name    = 'Input Name';
name.tag     = 'name';
name.strtype = 's';
name.num     = [1 Inf];
name.help    = {['Enter a name for these file sets. This name will be' ...
                 ' displayed in the ''Dependency'' listing as output name.']};
             
dir         = cfg_files;
dir.name    = 'Directory';
dir.tag     = 'dir';
dir.filter  = 'dir';
dir.ufilter = '.*';
dir.num     = [1 1];
dir.help    = {['Select the directory where the converted images are '...
                'going to be saved.']};

imgs         = cfg_files;
imgs.name    = 'Images';
imgs.tag     = 'imgs';
imgs.filter  = 'image';
imgs.ufilter = '.*';
imgs.num     = [1 Inf];
imgs.help    = {'Select a set of nifti images to convert to analyze format.'};
              
expression         = cfg_entry;
expression.name    = 'Expression';
expression.tag     = 'expression';
expression.strtype = 's';
expression.num     = [2 Inf];
expression.help    = {'Example expressions (f):'
                      '    * Mean of six images (select six images)'
                      '       f = ''(i1+i2+i3+i4+i5+i6)/6'''
                      '    * Make a binary mask image at threshold of '
                      '      100'
                      '       f = ''i1>100'''
                      '    * Make a mask from one image and apply to '
                      '      another'
                      '       f = ''i2.*(i1>100)'''
                      '             - here the first image is used to '
                      '               make the mask, which is applied '
                      '               to the second image'
                      '    * Sum of n images'
                      '       f = ''i1 + i2 + i3 + i4 + i5 + ...'''
                      '    * Sum of n images (when reading data into '
                      '      a data-matrix - use dmtx arg)'
                      '       f = ''sum(X)'''}';

dmtx        = cfg_menu;
dmtx.name   = 'Data Matrix';
dmtx.tag    = 'dmtx';
dmtx.labels = {'No - don''t read images into data matrix'...
               'Yes -  read images into data matrix'}';
dmtx.values = {0 1};
dmtx.val    = {0};
dmtx.help   = {'If the dmtx flag is set, then images are read into a '
               'data matrix X (rather than into separate variables i1, '
               'i2, i3,...). The data matrix  should be referred to as '
               'X, and contains images in rows. Computation is plane '
               'by plane, so in data-matrix mode, X is a NxK matrix, '
               'where N is the number of input images [prod(size(Vi))], '
               'and K is the number of voxels per plane '
               '[prod(Vi(1).dim(1:2))].'}';

mask        = cfg_menu;
mask.name   = 'Masking';
mask.tag    = 'mask';
mask.labels = {'No implicit zero mask'
               'Implicit zero mask'
               'NaNs should be zeroed'};
mask.values = {0 1 -1};
mask.val    = {0};
mask.help   = {'For data types without a representation of NaN, '
               'implicit zero masking assumes that all zero voxels '
               'are to be treated as missing, and treats them as NaN. '
               'NaN''s are written as zero (by spm_write_plane), for '
               'data types without a representation of NaN.'}';

interp        = cfg_menu;
interp.name   = 'Interpolation';
interp.tag    = 'interp';
interp.labels = {'Nearest neighbour'
                 'Trilinear'
                 '2nd Degree Sinc'
                 '3rd Degree Sinc'
                 '4th Degree Sinc'
                 '5th Degree Sinc'
                 '6th Degree Sinc'
                 '7th Degree Sinc'}';
interp.values = {0 1 -2 -3 -4 -5 -6 -7};
interp.val    = {1};
interp.help   = {'With images of different sizes and orientations, '
                 'the size and orientation of the first is used for '
                 'the output image. A warning is given in this '
                 'situation. Images are sampled into this '
                 'orientation using the interpolation specified by '
                 'the hold parameter.'
                 ''
                 'The method by which the images are sampled when '
                 'being written in a different space.'
                 '    Nearest Neighbour'
                 '    - Fastest, but not normally recommended.'
                 '    Bilinear Interpolation'
                 '    - OK for PET, or realigned fMRI.'
                 '    Sinc Interpolation'
                 '    - Better quality (but slower) interpolation, '
                 '    especially with higher degrees.'}';

dtype        = cfg_menu;
dtype.name   = 'Data Type';
dtype.tag    = 'dtype';
dtype.labels = {'UINT8   - unsigned char'
                'INT16   - signed short'
                'INT32   - signed int'
                'FLOAT32 - single prec. float'
                'FLOAT64 - double prec. float'}';
dtype.values = {spm_type('uint8') spm_type('int16') spm_type('int32') ...
                spm_type('float32') spm_type('float64')};
dtype.val    = {spm_type('int16')};
dtype.help   = {'Data-type of output image'};

options      = cfg_branch;
options.name = 'Options';
options.tag  = 'options';
options.val  = {dmtx mask interp dtype };
options.help = {'Options for image calculator'};

spmic      = cfg_branch;
spmic.name = 'SPM''s Image Calculator';
spmic.tag  = 'spmic';
spmic.val  = {expression options};
spmic.help = {['Converts nifti images to analyze using SPM''s '...
               'Image Calculator.']};

nii      = cfg_const;
nii.name = 'Nifti make_ana';
nii.tag  = 'nii';
nii.val  = {'2'};
nii.help = {['Converts nifti images to analyze using nifti '...
             'software''s function make_ana.']};

type        = cfg_choice;
type.name   = 'Conversion Type';
type.tag    = 'type';
type.values = {spmic nii};
type.val    = {spmic};
type.help   = {['Choose the conversion type. Options include '...
                'SPM''s Image Calculator and Nifti make_ana.']};

imgs_set      = cfg_branch;
imgs_set.name = 'Images Set';
imgs_set.tag  = 'imgs_set';
imgs_set.val  = {dir imgs type};
imgs_set.help = {['For each set of images is required the directory '...
                  'where the converted images are going to be '...
                  'saved, as well, as a set of nifti files to be '...
                  'converted.']};

imgs_sets        = cfg_repeat;
imgs_sets.name   = 'Images Sets';
imgs_sets.tag    = 'imgs_sets';
imgs_sets.values = {imgs_set};
imgs_sets.num    = [1 Inf];
imgs_sets.help   = {['Select one or more sets of nifti files. Each set can' ...
                    ' be passed separately as a dependency to other modules.']};

%% Executable Branch

n2a      = cfg_exbranch;
n2a.name = 'Nifti to Analyze';
n2a.tag  = 'rslib_cfg_n2a';
n2a.val  = {name imgs_sets};
n2a.prog = @rslib_run_n2a;
n2a.vout = @vout_data;
%n2a.check = @check_data;
n2a.help = {['This module allows to select sets of nifti (.nii) images '...
             'to be converted to analyze format (.img and .hdr files). '...
             'The outputs of this module are the analyze images (.img) '...
             'and are indexed according to the input image sets.']};

%% Local Functions

function vout = vout_data(job)

if strcmp(job.name, '<UNDEFINED>') || isempty(job.name) || isa(job.name, 'cfg_dep')
    setname = 'Image sets';
else
    setname = job.name;
end

ni = numel(job.imgs_set);
for i = 1 : ni
    vout(i)            = cfg_dep;
    vout(i).sname      = sprintf('%s(%d) - Images', setname, i);
    vout(i).src_output = substruct('.', 'imgs', '{}', {i});
    vout(i).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});
end