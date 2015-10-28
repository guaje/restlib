function varargout = rslib_get_defaults(defstr, varargin)
% Get/set the defaults values associated with an identifier
% FORMAT defaults = rslib_get_defaults
% Return the global "RSLIB_DEFAULTS" variable defined in rslib_defaults.m.
%
% FORMAT defval = rslib_get_defaults(defstr)
% Return the defaults value associated with identifier "defstr". 
% Currently, this is a '.' subscript reference into the global  
% "RSLIB_DEFAULTS" variable defined in rslib_defaults.m.
%
% FORMAT rslib_get_defaults(defstr, defval)
% Sets the defaults value associated with identifier "defstr". The new
% defaults value applies immediately to:
% * new modules in batch jobs
% * modules in batch jobs that have not been saved yet
% This value will not be saved for future sessions of COMARestLib. To make
% persistent changes, edit rslib_defaults.m.
%__________________________________________________________________________
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

global RSLIB_DEFAULTS;
if isempty(RSLIB_DEFAULTS)
    rslib_defaults;
end

if nargin == 0
    varargout{1} = RSLIB_DEFAULTS;
    return
end

% construct subscript reference struct from dot delimited tag string
tags = textscan(defstr,'%s', 'delimiter','.');
subs = struct('type','.','subs',tags{1}');

if nargin == 1
    varargout{1} = subsref(RSLIB_DEFAULTS, subs);
else
    RSLIB_DEFAULTS = subsasgn(RSLIB_DEFAULTS, subs, varargin{1});
end