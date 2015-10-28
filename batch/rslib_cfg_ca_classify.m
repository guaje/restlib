function classify = rslib_cfg_ca_classify
% COMARestLib Configuration file for Classify Components
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

sub_comps         = cfg_files;
sub_comps.name    = 'Subject Components';
sub_comps.tag     = 'sub_comps';
sub_comps.filter  = 'image';
sub_comps.ufilter = '.*';
sub_comps.num     = [1 Inf];
sub_comps.help    = {'Select the components of the subject.'};

mask         = cfg_files;
mask.name    = 'Image Mask';
mask.tag     = 'mask';
mask.filter  = 'image';
mask.ufilter = '.*';
mask.num     = [1 1];
mask.help    = {'Select the image mask.'};

time_cour         = cfg_files;
time_cour.name    = 'Time Courses';
time_cour.tag     = 'time_cour';
time_cour.filter  = 'image';
time_cour.ufilter = '.*';
time_cour.num     = [1 1];
time_cour.help    = {'Select the time courses of the components.'};

rep_time         = cfg_entry;
rep_time.name    = 'Repetition Time';
rep_time.tag     = 'rep_time';
rep_time.strtype = 'r';
rep_time.val     = {2.00};
rep_time.num     = [1 1];
rep_time.help    = {'Input the repetition time in seconds.'};

%% Executable Branch

classify      = cfg_exbranch;
classify.name = 'Classify Components';
classify.tag  = 'rslib_cfg_ca_classify';
classify.val  = {sub_comps mask time_cour rep_time};
classify.prog = @rslib_run_ca_classify;
classify.vout = @vout_data;
%classify.check = @check_data;
classify.help = {['Performs the classification algorithm, which consists '...
                  'in a machine learning model, that discriminates '...
                  'between artifactural and non artifactural components.']};

%% Local Functions

function vout = vout_data(job)

vout(1)            = cfg_dep;
vout(1).sname      = 'Non Artifactural Components';
vout(1).src_output = substruct('.', 'nonartifact');
vout(1).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});

vout(2)            = cfg_dep;
vout(2).sname      = 'Artifactural Components';
vout(2).src_output = substruct('.', 'artifact');
vout(2).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});