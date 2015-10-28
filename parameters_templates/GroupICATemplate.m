% Enter the values for the variables required for the ICA analysis.
% Variables are on the left and the values are on the right.
% Characters must be enterd in single quotes.

%% Modality.
% Options are fMRI and EEG.
modalityType = '<modality/>';

%% Type of analysis.
% Options are 1 and 2.
% 1 - Regular Group ICA.
% 2 - Group ICA using icasso.
which_analysis = <anaType/>;

%% ICASSO options.
% This variable will be used only when which_analysis variable is set to 2.
% Options are 'randinit', 'bootstrap' and 'both'.
icasso_opts.sel_mode = '<icssMode/>';

% Number of times ICA will be run.
icasso_opts.num_ica_runs = <icssRun/>;

% Most stable run estimate is based on these settings.
% Minimum cluster size.
icasso_opts.min_cluster_size = <icssMin/>;

% Max cluster size. Max is the number of components.
icasso_opts.max_cluster_size = <icssMax/>;

%% Design matrix selection.
% Design matrix (SPM.mat) is used for sorting the components
% temporally (time courses) during display. Design matrix will not be used during the
% analysis stage except for SEMI-BLIND ICA.
% options are ('no', 'same_sub_same_sess', 'same_sub_diff_sess', 'diff_sub_diff_sess')
% 1. 'no' - means no design matrix.
% 2. 'same_sub_same_sess' - same design over subjects and sessions
% 3. 'same_sub_diff_sess' - same design matrix for subjects but different over sessions
% 4. 'diff_sub_diff_sess' - means one design matrix per subject.
keyword_designMatrix = '<designMat/>';

%% There are three ways to enter the subject data
% options are 1, 2, 3 or 4
dataSelectionMethod = 2;

%% Method 1
% If you have all subjects in one directory and their sessions in a separate folder or in the subject folder then specify 
% root directory, filePattern, flag and file numbers to include.
% Options for flag are: data_in_subject_folder, data_in_subject_subfolder
% 1. data_in_subject_subfolder - Data is selected from the subject sub
% folders. Number of sessions is equal to the number of sub-folders
% containing the specified file pattern.
% 2. data_in_subject_folder - Data is selected from the subject
% folders. Number of sessions is 1 and number of subjects is equal to the number of subject folders
% containing the specified file pattern.
% You can provide the file numbers ([1:220]) to include as a vector. If you want to
% select all the files then leave empty.
% Note: Make sure the sessions are the same over subjects.

%% Method 2
% If you have different filePatterns and location for subjects not in one
% root folder then enter the data here.
% Number of subjects is determined getting the length of the selected subjects. specify the data set or data sets needed for 
% the analysis here.
selectedSubjects = {'s1'};  % naming for subjects s1 refers to subject 1, s2 means subject 2. Use cell array convention even in case of one subject one session

% Number of Sessions
numOfSess = 1;

% functional data folder, file pattern and file numbers to include
% You can provide the file numbers ([1:220]) to include as a vector. If you want to
% select all the files then leave empty.
s1_s1 = {'<dirProcessedFiles/>', '*<ext/>'}; % subject session 1

%% Enter directory to put results of analysis
outputDir = '<dirOutputFile/>';

%% Enter Name (Prefix) Of Output Files
prefix = '<prefix/>';

%% Enter location (full file path) of the image file to use as mask
% or use Default mask which is []
maskFile = <maskFile/>;

%% Back reconstruction type. Options are 1 and 2
% 1 - Regular
% 2 - Spatial-temporal Regression 
% 3 - GICA3
backReconType = <backRecon/>;

%% Data Pre-processing options
% 1 - Remove mean per time point
% 2 - Remove mean per voxel
% 3 - Intensity normalization
% 4 - Variance normalization
preproc_type = <preprocOpt/>;


%% PCA Type. Also see options associated with the selected pca option. EM
% PCA options are commented.
% Options are 1 and 2
% 1 - Standard 
% 2 - Expectation Maximization
pcaType = <pcaType/>;

%% PCA options (Standard)

% a. Options are yes or no
% 1a. yes - Datasets are stacked. This option uses lot of memory depending
% on datasets, voxels and components.
% 2a. no - A pair of datasets are loaded at a time. This option uses least
% amount of memory and can run very slower if you have very large datasets.
pca_opts.stack_data = '<stdSD/>';

% b. Options are full or packed.
% 1b. full - Full storage of covariance matrix is stored in memory.
% 2b. packed - Lower triangular portion of covariance matrix is only stored in memory.
pca_opts.storage = '<stdStor/>';

% c. Options are double or single.
% 1c. double - Double precision is used
% 2c. single - Floating point precision is used.
pca_opts.precision = '<stdPrec/>';

% d. Type of eigen solver. Options are selective or all
% 1d. selective - Selective eigen solver is used. If there are convergence
% issues, use option all.
% 2d. all - All eigen values are computed. This might run very slow if you
% are using packed storage. Use this only when selective option doesn't
% converge.
pca_opts.eig_solver = '<stdES/>';


% %% PCA Options (Expectation Maximization)
% % a. Options are yes or no
% % 1a. yes - Datasets are stacked. This option uses lot of memory depending
% % on datasets, voxels and components.
% % 2a. no - A pair of datasets are loaded at a time. This option uses least
% % amount of memory and can run very slower if you have very large datasets.
pca_opts.stack_data = '<emSD/>';
 
% % b. Options are double or single.
% % 1b. double - Double precision is used
% % 2b. single - Floating point precision is used.
pca_opts.precision = '<emPrec/>';
 
% % c. Stopping tolerance 
pca_opts.tolerance = 1e-4;
 
% % d. Maximum no. of iterations
pca_opts.max_iter = <emMaxIter/>;


%% Maximum reduction steps you can select is 3
% Note: This number will be changed depending upon the number of subjects
% and sessions
numReductionSteps = 2;

%% Batch Estimation. If 1 is specified then estimation of 
% the components takes place and the corresponding PC numbers are associated
% Options are 1 or 0
doEstimation = 0; 


%% MDL Estimation options. This variable will be used only if doEstimation is set to 1.
% Options are 'mean', 'median' and 'max' for each reduction step. The length of cell is equal to
% the no. of data reductions used.
estimation_opts.PC1 = 'mean';

%% Number of pc to reduce each subject down to at each reduction step
% The number of independent components the will be extracted is the same as 
% the number of principal components after the final data reduction step.  
numOfPC1 = <numberComponents/>;

%% Scale the Results. Options are 0, 1, 2
% 0 - Don't scale
% 1 - Scale to Percent signal change
% 2 - Scale to Z scores
scaleType = 1;


%% 'Which ICA Algorithm Do You Want To Use';
% see icatb_icaAlgorithm for details or type icatb_icaAlgorithm at the
% command prompt.
% Note: Use only one subject and one session for Semi-blind ICA. Also specify atmost two reference function names

% 1 means infomax, 2 means fastICA, etc.
algoType = 1;
