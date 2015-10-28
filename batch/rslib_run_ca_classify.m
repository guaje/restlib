function out = rslib_run_ca_classify(job)
% COMARestLib Run file for Classify Components
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

num_sub_comps = numel(job.sub_comps);
[pth, nam, ext, num] = spm_fileparts(job.mask{1});
mask = load_nii(fullfile(pth, [nam, ext]));
[pth, nam, ext, num] = spm_fileparts(job.time_cour{1});
time_courses = load_nii(fullfile(pth, [nam, ext]));

selectedFeatures = 1 : 11;

SVMType = '0';
kernelType = '2';
degree = '3';
gamma = '0.5';
coef0 = '100.0';
nu = '0.5';
cacheSize = '40.0';
cost = '100.0';
eps = '0.0010';
loss = '0.2';
weights = '0.1';

wekaOpts = {LibSVMOptions.SVM_TYPE.label, SVMType, ...
            LibSVMOptions.KERNEL_TYPE.label, kernelType, ...
            LibSVMOptions.DEGREE.label, degree, ...
            LibSVMOptions.GAMMA.label, gamma, ...
            LibSVMOptions.COEF0.label, coef0, ...
            LibSVMOptions.NU.label, nu, ...
            LibSVMOptions.CACHE_SIZE.label, cacheSize, ...
            LibSVMOptions.COST.label, cost, ...
            LibSVMOptions.EPS.label, eps, ...
            LibSVMOptions.LOSS.label, loss, ...
            LibSVMOptions.NORMALIZE.label};

spm_progress_bar('Init', num_sub_comps, 'Classify Components', 'Classified Components');

arff = loadARFF(fullfile(rslib('Dir'), 'training_data', 'TrainCompleteRBF.arff'));
classTrain = trainWekaClassifier(arff, SupportedClassifiers.LIBSVM.classifier, wekaOpts);

assignedMarks = [];
assignedProbs = [];

for i = 1 : num_sub_comps
    [pth, nam, ext, num] = spm_fileparts(job.sub_comps{i});
    sub_comp = load_nii(fullfile(pth, [nam, ext]));
    prefix = sub_comp.fileprefix;
    prefix_size = size(prefix, 2);
    comp_tc = str2num(prefix(prefix_size - 2 : prefix_size));
    dimVoxel = sub_comp.hdr.dime.pixdim(2 : 4);
    feature = computeFingerprintSpaceTime(sub_comp.img, time_courses.img(:, comp_tc), mask.img, job.rep_time, dimVoxel);
    feature = feature(:,selectedFeatures);
    writeWeka(feature,[],'vecTemp');
    test = loadARFF('vecTemp.arff');
    [testClass classProb]= wekaClassify(test, classTrain);
    testClass = ~testClass;
    assignedMarks(i) = testClass;
    assignedProbs(i) = classProb(1, 1);
end

nonartifact_index = find(assignedMarks' == 1);
artifact_index = find(assignedMarks' == 0);

out.nonartifact = cell(size(nonartifact_index));
out.artifact = cell(size(artifact_index));

for i = 1 : numel(nonartifact_index)
    [pth, nam, ext, num] = spm_fileparts(job.sub_comps{nonartifact_index(i)});
    out.nonartifact{i} = fullfile(pth, [nam, ext]);
end

for i = 1 : numel(artifact_index)
    [pth, nam, ext, num] = spm_fileparts(job.sub_comps{artifact_index(i)});
    out.artifact{i} = fullfile(pth, [nam, ext]);
end

spm_progress_bar('Clear');

return