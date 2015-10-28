classdef SupportedGOF
% Supported Goodness of Fit Class used to enumerate the GOF similarity
% measures available in the library
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
    
    properties
        id = 0;
        name = '';
    end
    
    methods(Access = private)
        function gof = SupportedGOF(id, name)
            gof.id = id;
            gof.name = name;
        end
    end
    
    enumeration
        GREICIUS(0, 'Greicius');
        GREICIUS_ZMAP(1, 'Greicius z-map');
        PEARSON(2, 'Pearson Correlation');
        %DISTANCE(3, 'Distance Correlation');
        %NMI(4, 'NMI');
    end
end