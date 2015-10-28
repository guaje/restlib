function match = rslib_cfg_ca_matching
% COMARestLib Configuration file for Matching Components
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

%% 
[m, n] = enumeration('SupportedGOF');

%% Input Items

sub_comps         = cfg_files;
sub_comps.name    = 'Subject Components';
sub_comps.tag     = 'sub_comps';
sub_comps.filter  = 'image';
sub_comps.ufilter = '.*';
sub_comps.num     = [1 Inf];
sub_comps.help    = {'Select the components of the subject.'};

stud_comps         = cfg_files;
stud_comps.name    = 'Study Components';
stud_comps.tag     = 'stud_comps';
stud_comps.filter  = 'image';
stud_comps.ufilter = '.*';
stud_comps.num     = [1 Inf];
stud_comps.dir     = fullfile(rslib('Dir'), 'templates', 'spatial_hypn_subj');
stud_comps.def     = @(val)rslib_get_defaults('matching.stud_comps', val{:});
stud_comps.help    = {'Select the components of the study.'};

mask         = cfg_files;
mask.name    = 'Comparison Mask';
mask.tag     = 'mask';
mask.filter  = 'image';
mask.ufilter = '.*';
mask.num     = [1 1];
mask.help    = {'Select the comparison mask.'};

gof        = cfg_menu;
gof.name   = 'Goodness of Fit';
gof.tag    = 'gof';
gof.values = {m(:).id};
gof.labels = {m(:).name};
gof.val    = {SupportedGOF.GREICIUS.id};
gof.help   = {'Choose the similarity measure for the study.'};

%% Executable Branch

match      = cfg_exbranch;
match.name = 'Matching Components';
match.tag  = 'rslib_cfg_ca_matching';
match.val  = {sub_comps stud_comps mask gof};
match.prog = @rslib_run_ca_matching;
match.vout = @vout_data;
%match.check = @check_data;
match.help = {['Performs the matching algorithm, which finds the similarity between '...
    'the subject''s components and the study''s components.']};

%% Local Functions

function vout = vout_data(job)

vout(1)            = cfg_dep;
vout(1).sname      = 'Matched Components';
vout(1).src_output = substruct('.', 'comps');
vout(1).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});

vout(2)            = cfg_dep;
vout(2).sname      = 'Goodness of Fit';
vout(2).src_output = substruct('.', 'gof');
vout(2).tgt_spec   = cfg_findspec({{'filter', 'any', 'strtype', 'e'}});

vout(3)            = cfg_dep;
vout(3).sname      = 'Study Components';
vout(3).src_output = substruct('.', 'stud');
vout(3).tgt_spec   = cfg_findspec({{'filter', 'image', 'strtype', 'e'}});