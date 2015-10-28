classdef LibSVMOptions
% LibSVM Options Class used to enumerate the LibSVM Options
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
        name = '';
        label = '';
    end
    
    methods(Access = private)
        function opts = LibSVMOptions(name, label)
            opts.name = name;
            opts.label = label;
        end
    end
    
    enumeration
        SVM_TYPE('SVM Type', '-S');
        KERNEL_TYPE('Kernel Type', '-K');
        DEGREE('Degree', '-D');
        GAMMA('Gamma', '-G');
        COEF0('Coef0', '-R');
        NU('nu', '-N');
        CACHE_SIZE('Cache Size', '-M');
        COST('Cost', '-C');
        EPS('eps', '-E');
        LOSS('Loss', '-P');
        SHRINKING('Shrinking', '-H');
        NORMALIZE('Normalize', '-Z');
        DO_NOT_REPLACE_MISSING_VALUES('Do not replace missing values', '-V');
        WEIGHTS('Weights', '-W');
        PROBABILITY_ESTIMATES('Probability Estimates', '-B');
    end
end