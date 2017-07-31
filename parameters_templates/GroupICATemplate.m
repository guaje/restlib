% Enter the values for the variables required for the ICA analysis.
% Variables are on the left and the values are on the right.
% Characters must be enterd in single quotes.

%% Modality. Options are fMRI and EEG
modalityType = '<modality/>';

%% Type of analysis
% Options are 1, 2 and 3.
% 1 - Regular Group ICA
% 2 - Group ICA using icasso
% 3 - Group ICA using MST
which_analysis = <anaType/>;

%% ICASSO options.
% This variable will be used only when which_analysis variable is set to 2.
icasso_opts.sel_mode = '<icssMode/>'; % Options are 'randinit', 'bootstrap' and 'both'
icasso_opts.num_ica_runs = <icssRun/>;  % Number of times ICA will be run
% Most stable run estimate is based on these settings.
icasso_opts.min_cluster_size = <icssMin/>; % Minimum cluster size
icasso_opts.max_cluster_size = <icssMax/>; % Max cluster size. Max is the no. of components

%% Enter TR in seconds. If TRs vary across subjects, TR must be a row vector of length equal to the number of subjects.
TR = <tr/>;

%% Group ica type
% Options are spatial or temporal for fMRI modality. By default, spatial
% ica is run if not specified.
group_ica_type = '<gicaType/>';

%% Parallel info
% enter mode serial or parallel. If parallel, enter number of
% sessions/workers to do job in parallel
parallel_info.mode = '<parallelMode/>';
parallel_info.num_workers = <parallelWorkers/>;

%% Group PCA performance settings. Best setting for each option will be selected based on variable MAX_AVAILABLE_RAM in icatb_defaults.m. 
% If you have selected option 3 (user specified settings) you need to manually set the PCA options. 
% Options are:
% 1 - Maximize Performance
% 2 - Less Memory Usage
% 3 - User Specified Settings
perfType = <perfType/>;

%% Design matrix selection
% Design matrix (SPM.mat) is used for sorting the components
% temporally (time courses) during display. Design matrix will not be used during the
% analysis stage except for SEMI-BLIND ICA.
% options are ('no', 'same_sub_same_sess', 'same_sub_diff_sess', 'diff_sub_diff_sess')
% 1. 'no' - means no design matrix.
% 2. 'same_sub_same_sess' - same design over subjects and sessions
% 3. 'same_sub_diff_sess' - same design matrix for subjects but different
% over sessions
% 4. 'diff_sub_diff_sess' - means one design matrix per subject.
keyword_designMatrix = 'no';

%% There are three ways to enter the subject data
% options are 1, 2, 3 or 4
dataSelectionMethod = 2;

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
s1_s1 = {'<dirProcessedFiles/>', '*<ext/>'}; % subject 1 session 1
%%%%%%%%%%%%%%%%%%%%%%% end for Method 2 %%%%%%%%%%%%%%

%% Enter directory to put results of analysis
outputDir = '<dirOutputFile/>';

%% Enter Name (Prefix) Of Output Files
prefix = '<prefix/>';

%% Enter location (full file path) of the image file to use as mask
% or use Default mask which is []
maskFile = <maskFile/>;

%% Group PCA Type. Used for analysis on multiple subjects and sessions.
% Options are 'subject specific' and 'grand mean'. 
%   a. Subject specific - Individual PCA is done on each data-set before group
%   PCA is done.
%   b. Grand Mean - PCA is done on the mean over all data-sets. Each data-set is
%   projected on to the eigen space of the mean before doing group PCA.
%
% NOTE: Grand mean implemented is from FSL Melodic. Make sure that there are
% equal no. of timepoints between data-sets.
group_pca_type =  'subject specific';

%% Back reconstruction type. Options are str and gica
backReconType = '<backRecon/>';

%% Data Pre-processing options
% 1 - Remove mean per time point
% 2 - Remove mean per voxel
% 3 - Intensity normalization
% 4 - Variance normalization
preproc_type = <preprocOpt/>;

%% PCA Type. Also see options associated with the selected pca option. EM
% PCA options and SVD PCA are commented.
% Options are 1, 2, 3, 4 and 5.
% 1 - Standard 
% 2 - Expectation Maximization
% 3 - SVD
% 4 - MPOWIT
% 5 - STP
pcaType = 1;

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

%% Maximum reduction steps you can select is 2. Options are 1 and 2. For temporal ica, only one data reduction step is
% used.
numReductionSteps = <reductionSteps/>;

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

%% Scale the Results. Options are 0, 1, 2, 3 and 4
% 0 - Don't scale
% 1 - Scale to Percent signal change
% 2 - Scale to Z scores
% 3 - Normalize spatial maps using the maximum intensity value and multiply timecourses using the maximum intensity value
% 4 - Scale timecourses using the maximum intensity value and spatial maps using the standard deviation of timecourses
scaleType = <scaleType/>;

%% 'Which ICA Algorithm Do You Want To Use';
% see icatb_icaAlgorithm for details or type icatb_icaAlgorithm at the
% command prompt.
% Note: Use only one subject and one session for Semi-blind ICA. Also specify atmost two reference function names
% 1 means infomax, 2 means fastICA, etc.
algoType = 1;
