function varargout = rslib(varargin)
% COMA Resting-State Library, COMARestLib.
%
% This function initializes things for COMARestLib and provides some low
% level functionalities
%
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

% Format arguments
%-----------------------------------------------------------------------
global RSLIB_INIT
if nargin == 0,
    action = 'StartUp';
else
    action = varargin{1};
end

switch lower(action)
        % =================================================================
    case 'startup'                                    % Startup the library
        % =================================================================
        
        % Welcome message
        rslib('ASCIIWelcome');
        
        % add paths
        rslib_add_paths;
         
        % check installation of spm, artrepair, art, groupica, nifti, 
        % restlib and check spm version
        ok = rslib_check_installation;
        if ~ok
            beep
            fprintf('INSTALLATION PROBLEM!');
            return
        end
        
        % Add SPM's directories: matlabbatch
        if ~exist('cfg_util','file')
            addpath(fullfile(spm('Dir'), 'matlabbatch'));
        end
        
        % intialize the matlabbatch system
        cfg_get_defaults('cfg_util.genscript_run', @genscript_run);
        cfg_util('initcfg');
        clear rslib_batch;
        
        % load startup global defaults
        rslib_defaults;
        
        % set path to COMARestLib and SPM dir into 'file select'
        spm_select('prevdirs', [spm('Dir') filesep]);
        spm_select('prevdirs', [rslib('Dir') filesep]);
        
        % launch the main GUI, if needed
        rslib_batch;
        
        % print present working directory
        fprintf('COMARestLib present working directory:\n\t%s\n', pwd);
        
        % Init flag true
        RSLIB_INIT = true;
        
        %==================================================================
    case 'asciiwelcome'                  % ASCII COMARestLib banner welcome
        %==================================================================
        disp( ' +----------+');
        disp( ' |          |');
        disp( ' |   COMA   |');
        disp( ' |          |');
        disp( ' +----------+');
        disp( ' | Rest Lib |');
        disp( ' +---------+');
        disp( ' COMARestLib v1.0 - ');
        fprintf('\n');
        
        % =================================================================
    case 'dir'                  % Identify specific (COMARestLib) directory
        % =================================================================
        % rslib('Dir', Mfile)
        %------------------------------------------------------------------
        if nargin<2,
            Mfile = 'rslib';
        else
            Mfile = varargin{2};
        end
        RSLIBdir = which(Mfile);
        
        if isempty(RSLIBdir)              %-Not found or full pathname given
            if exist(Mfile, 'file') == 2  %-Full pathname
                RSLIBdir = Mfile;
            else
                error(['Can''t find ', Mfile, ' on MATLABPATH']);
            end
        end
        RSLIBdir    = fileparts(RSLIBdir);
        varargout = {RSLIBdir};
        
        % =================================================================
    case 'ver'                                        % COMARestLib version
        % =================================================================
        % [ver, rel] = rslib('Ver', Mfile, ReDo)
        %------------------------------------------------------------------
        % NOTE:
        % This bit of code is largely inspired/copied from SPM8!
        % See http://www.fil.ion.ucl.ac.uk/spm for details.
        
        if nargin ~= 3,
            ReDo = false;
        else
            ReDo = logical(varargin{3});
        end
        if nargin == 1 || (nargin > 1 && isempty(varargin{2}))
            Mfile = '';
        else
            Mfile = which(varargin{2});
            if isempty(Mfile)
                error('COMARestLib:UnknownFile', 'Can''t find %s on MATLABPATH.', varargin{2});
            end
        end
        
        v = get_version(ReDo);
        
        if isempty(Mfile)
            varargout = {v.Release v.Version};
        else
            unknown = struct('file', Mfile,'id', '???', 'date', '', 'author', '');
            fp  = fopen(Mfile, 'rt');
            if fp == -1
                error('Can''t read %s.', Mfile);
            end
            str = fread(fp, Inf, '*uchar');
            fclose(fp);
            str = char(str(:)');
            r = regexp(str, ['\$Id: (?<file>\S+) (?<id>[0-9]+) (?<date>\S+) ' ...
                '(\S+Z) (?<author>\S+) \$'], 'names', 'once');
            if isempty(r)
                r = unknown;
            end
            varargout = {r(1).id v.Release};
        end
        
        % =================================================================
    otherwise                                       % Unknown action string
        % =================================================================
        error('Unknown action string');
end

return

% =========================================================================
% SUBFUNCTIONS
% =========================================================================
function v = get_version(ReDo)
% Function that retrieves COMARestLib version

persistent RSLIB_VER;
v = RSLIB_VER;
if isempty(RSLIB_VER) || (nargin > 0 && ReDo)
    v = struct('Name', '', 'Version', '', 'Release', '', 'Date', '');
    try
        vfile = fullfile(rslib('Dir'), 'Contents.m');
        fid = fopen(vfile, 'rt');
        if fid == -1
            error(str);
        end
        l1 = fgetl(fid);
        l2 = fgetl(fid);
        fclose(fid);
        l1 = strtrim(l1(2 : end));
        l2 = strtrim(l2(2 : end));
        t  = textscan(l2,'%s', 'delimiter', ' ');
        t = t{1};
        v.Name = l1;
        v.Date = t{4};
        v.Version = t{2};
        v.Release = t{3}(2 : end - 1);
    catch %#ok<CTCH>
        error('COMARestLib:getversion', ...
            'Can''t obtain COMARestLib Revision information.');
    end
    RSLIB_VER = v;
end

return