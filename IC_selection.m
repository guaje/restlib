function [assignedMarks assignedProbs] = IC_selection(dirData, ncompo, maskName, Tr, typeClass)
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

    if nargin == 4
        typeClass = 'ext';
    end
    
    %typeClass = 'gre';

    if(strcmp(typeClass,'aut'))
        [assignedMarks assignedProbs] = IC_selectionAut(dirData,ncompo,maskName,Tr);
    elseif(strcmp(typeClass,'gre'))
        [assignedMarks assignedProbs] = IC_selectionGrecious(dirData,ncompo,maskName,Tr);    
    elseif(strcmp(typeClass,'ext'))
        [assignedMarks assignedProbs] = IC_selectionExtendedRed(dirData,ncompo,maskName,Tr);                    
    end
 
function [assignedMarks assignedProbs] = IC_selectionAut(dirData,ncompo,maskName,Tr)
    typeProcessing = 'GIFT';
    selectedFeatures = 1:11;    
    maskData = load_nii(maskName);        
    
    % training
    ff = loadARFF('trainingData/trainCompleteRBF.arff');
    % train using the optimal parameters
    classTrain = trainWekaClassifier(ff,'functions.LibSVM',{'-S','0','-K','2','-D','3','-G','0.5','-R','100.0','-N','0.5','-M','40.0','-C','100','-E','0.0010','-P','0.2','-Z'});       	
    % classify each component  
    timeData = getTemporalData(dirData,ncompo,typeProcessing);
    for i=1:ncompo
        dataCompSpatial = getSpatialData(dirData,i,typeProcessing);
        
        % compute the fingerprint for each available template        
        dimVoxel = dataCompSpatial.hdr.dime.pixdim(2:4);        
        feature = computeFingerprintSpaceTime(dataCompSpatial.img,timeData.img(:,i),maskData.img,Tr,dimVoxel);
        feature = feature(:,selectedFeatures);        
        
        % classification
        writeWeka(feature,[],'vecTemp');
        

        test = loadARFF('vecTemp.arff');
        [testClass classProb]= wekaClassify(test,classTrain);
        testClass = ~testClass;
        assignedMarks(i) = testClass;
        assignedProbs(i) = classProb(1,1);           
    end   

function [assignedMarks assignedProbs] = IC_selectionGrecious(dirData,ncompo,maskName,Tr)
    typeProcessing = 'GIFT';
    selectedFeatures = 1:11;    
    maskData = load_nii(maskName);        
    
    % training
    ff = loadARFF('trainingData/trainComplete.arff');
    % train using the optimal parameters
    classTrain = trainWekaClassifier(ff,'functions.MultilayerPerceptron',{'-H','6','-L','0.7'});
    % classify each component  
    timeData = getTemporalData(dirData,ncompo,typeProcessing);
    for i=1:ncompo
        dataCompSpatial = getSpatialData(dirData,i,typeProcessing);
        
        % compute the fingerprint for each available template        
        dimVoxel = dataCompSpatial.hdr.dime.pixdim(2:4);        
        feature = computeFingerprintSpaceTime(dataCompSpatial.img,timeData.img(:,i),maskData.img,Tr,dimVoxel);
        feature = feature(:,selectedFeatures);
        ratioTF = feature(1,10)/(sum(feature(1,5:10)));
        
        if ratioTF>0.5
            assignedMarks(i) = 0;
            assignedProbs(i) = 0;
        else
            assignedMarks(i) = 1;
            assignedProbs(i) = 1;
        end
    end       
    
    
function [assignedMarks assignedProbs] = IC_selectionExtendedRed(dirData,ncompo,maskName,Tr)
    typeProcessing = 'GIFT';
    maskData = load_nii(maskName);        
    
    % training
    ff = loadARFF('trainingData/trainExtendedRed.arff');
    % train using the optimal parameters
    % TODO: this parameters must be checked again with the classification
    classTrain = trainWekaClassifier(ff,'functions.MultilayerPerceptron',{'-H','a','-L','0.1'});
    
    % classify each component  
    timeData = getTemporalData(dirData,ncompo,typeProcessing);
    for i=1:ncompo
        dataCompSpatial = getSpatialData(dirData,i,typeProcessing);
        
        % compute the fingerprint for each available template        
        dimVoxel = dataCompSpatial.hdr.dime.pixdim(2:4);        
        feature = computeFingerprintSpaceTime(dataCompSpatial.img,timeData.img(:,i),maskData.img,Tr,dimVoxel,1);
        
        % classification
        writeWeka(feature,[],'vecTemp');        
        test = loadARFF('vecTemp.arff');
        [testClass classProb]= wekaClassify(test,classTrain);
        testClass = ~testClass;
        assignedMarks(i) = testClass;
        assignedProbs(i) = classProb(1,1);           
    end