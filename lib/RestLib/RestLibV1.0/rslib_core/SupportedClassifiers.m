classdef SupportedClassifiers
% Supported Classifiers Class used to enumerate the classifiers available
% in the library
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
        classifier = '';
    end
    
    methods(Access = private)
        function class = SupportedClassifiers(name, classifier)
            class.name = name;
            class.classifier = classifier;
        end
    end
    
    enumeration
        LIBSVM('LibSVM', 'functions.LibSVM');
    end
end