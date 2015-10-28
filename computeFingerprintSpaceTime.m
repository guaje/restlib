function [feature dataZ temporalData] = computeFingerprintSpaceTime(ICComponent, temporalComponent, mask, Tr, dimVoxel, isReduced)
% Compute Spatio-Temporal Fingerprint function
% FORMAT computeFingerprintSpaceTime(ICComponent, temporalComponent, mask, Tr, dimVoxel, isReduced)
% ICComponent          - spatial data of the component
% temporalComponent    - temporal data of the component
% mask                 - ask data
% Tr                   - repetition Time
%____________________________________________________________________________
%
% computeFingerprintSpaceTime is used to compute a fingerprint for the
% ICA component
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

% Written by Francisco Gómez and Katherine Baquero

    if nargin == 5
        isReduced = 0;
    end

    %Normalization of the temporal data
    mean_TC=mean(temporalComponent);
    std_TC=std(temporalComponent);
    temporalData = (temporalComponent-mean_TC)./std_TC;

    pearsonCoeffR = xcorr(temporalData,1,'coeff');
    pearsonCoeff = abs(pearsonCoeffR(1,1));
    
    % entropy
    p = hist(temporalData);
    p(p==0) = [];
    % normalize p so that sum(p) is one.    
    p = p ./ numel(temporalData);    
    %normalized entropy
    entropyTemporal = exp(abs(-sum(p.*log2(p))));
    
    % sampling frequency
    Fs = 1/Tr;
    [Pxx,w] = pwelch(temporalData,33,32,[],Fs,'onesided');    
    pxDbHxz = (Pxx);    
    spectrumBand1 = sum(pxDbHxz(find(w>=0 & w<=0.008)));
    spectrumBand2 = sum(pxDbHxz(find(w>=0.008 & w<=0.02)));
    spectrumBand3 = sum(pxDbHxz(find(w>=0.02 & w<=0.05)));
    spectrumBand4 = sum(pxDbHxz(find(w>=0.05 & w<=0.1)));
    spectrumBand5 = sum(pxDbHxz(find(w>=0.1 & w<=0.25)));
    
    %Normalized SpectrumBand:
    spectrumBand=[spectrumBand1 spectrumBand2 spectrumBand3 spectrumBand4 spectrumBand5];

    %% Spatial Features    
    dataZ = ICComponent(mask ~= 0);

    % characterization with only the RoI filtered
    meanData = mean(dataZ);
    % kurtosis
    kurt = kurtosis(dataZ);
    kurt =abs(log(kurt));
    % skewness
    skew = skewness(dataZ);    
    skew =abs(log(skew)); 
    % entropy
    p = hist(dataZ);
    p(p==0) = [];
    % normalize p so that sum(p) is one.    
    p = p ./ numel(dataZ);    
    entro = -sum(p.*log2(p));
    %normlizada
    entro = abs(log(entro));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     global labelD;
%     figure
% %     subplot(2,1,1);    
%     bar(p)    
%     title(sprintf('isneuronal = %d',labelD))
%     [kurt labelD]
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    options = optimset('display', 'off', 'TolX', 1e-6, 'MaxIter', 10);
    dataZ(:) = (dataZ(:)-mean(mean(dataZ(:))));
%    [ahat, bhat] = ggmle(dataZ(:), options);

    % computes degree of clustering    
    dataZN = ICComponent(mask~=0);
    dataZN = (dataZN - mean(dataZN))/std(dataZN);
    indexOrig = find(mask~=0);
    imBin = zeros(size(ICComponent));
    imBin(indexOrig(abs(dataZN)>2.5)) = 1;
    [L,NUM] = bwlabeln(imBin);
    acumVoxels = 0;
    for i=1:NUM    
        if size(find(L==i),1)*prod(dimVoxel)<270
            acumVoxels = acumVoxels+size(find(L==i),1);
        end
    end
    degreeClustering = acumVoxels/size(find(imBin==1),1);

    ratioVal = (spectrumBand2 + spectrumBand3)/(spectrumBand1 + spectrumBand4  + spectrumBand5);
    feature = [kurt skew entro pearsonCoeff entropyTemporal spectrumBand degreeClustering];
    
    if isReduced==1
        dynamicRange = max(pxDbHxz)-min(pxDbHxz);
        ratioVal1 = (spectrumBand1+spectrumBand2)/(spectrumBand3+spectrumBand4+spectrumBand5);        
        feature = [kurt skew entro pearsonCoeff entropyTemporal spectrumBand degreeClustering ratioVal1 ratioVal dynamicRange];
        feature = feature([1,2,5,6,8,11,13,14]);
    end
    

    
