function [featureAll] = computeFeatures(dirData, ncompo, maskName, Tr)
% Compute Features function
% FORMAT computeFeatures(dirData, ncompo, maskName, Tr)
% dirData     - directory name with data comming from groupICA
% ncompo      - number of components to be analyzed
% maskName    - mask name
% Tr          - repetition Time
%
% example of use:
% computeFeatures('data\subj_1',30,'data\subj_1\icaAnaMask',2.0)
%____________________________________________________________________________
%
% computeFeatures is used to classify non-artifactural components comming
% from ICA using a Neural Networks
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

% Written by Francisco Gómez and Andrea Soddu

    % To choose automatic classification based on machine learning
    typeClass = 'mar';
    % To choose the Grecious criterium
    %typeClass = 'gre';
    
    if(strcmp(typeClass,'mar'))
        [featureAll] = computeFeatureMart(dirData,ncompo,maskName,Tr);
    elseif(strcmp(typeClass,'gre'))
        % TODO
    end

    
function [featureAll] = computeFeatureMart(dirData,ncompo,maskName,Tr)
    typeProcessing = 'GIFT';
    selectedFeatures = 1:11;    
    maskData = load_nii(maskName);        

    featureAll = [];
    % classify each component  
    timeData = getTemporalData(dirData,ncompo,typeProcessing);
    for i=1:ncompo
        dataCompSpatial = getSpatialData(dirData,i,typeProcessing);
        
        % compute the fingerprint for each available template        
        dimVoxel = dataCompSpatial.hdr.dime.pixdim(2:4);
        feature = computeFingerprintSpaceTime(dataCompSpatial.img,timeData.img(:,i),maskData.img,Tr,dimVoxel);
        feature = feature(:,selectedFeatures);        
        featureAll = [featureAll;feature];                        
    end