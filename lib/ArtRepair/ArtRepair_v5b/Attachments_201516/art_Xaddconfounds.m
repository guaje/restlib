function art_addconfounds
% FUNCTION art_addconfounds 
% WARNING: AMEMDED CONTRAST VECTORS ARE NOT CORRECT
%    
% This function reads an existing SPM matrix, and writes a new SPM
% matrix with additional confounds in the GLM defined as 
% one new regressor for each timepoint with rapid scan-to-scan
% motion (Lemieux, 2007 and others). It is assumed that each original
% scan session has an art_repaired.txt file produced by ArtRepair (the 
% art_global function). The original SPM matrix is preserved.
% 
% Note the program keeps the original data in the SPM design, and does
% not replace data with the repaired files (those with prefix "v"). The
% original data needs to have same size and orientation, e.g. normalized.
%
% INPUT by GUI
%    Specify the SPM.mat file.
%    Specify a new folder for the new SPM.mat file with confounds.
%    Assumes the data were repaired by art_global, so that the file
%       art_repaired.txt is available for each session.
% OUTPUT 
%    Writes a new SPM.mat in the designated new Results folder,
%       with the added confounds for artifacts.
%    Runs SPM estimation including contrasts for this repaired design,
%       and writes beta, con, etc. images in new Results folder.
%
% Note ArtRepair flags scans with rapid scan-to-scan motion, but 
% may include additional scans with strong intensity artifacts.
%
% Paul Mazaika, Nov 2012

clear SPM scans;
%spm_defaults for SPM5 and SPM2
if strcmp(spm('Ver'),'SPM8') == 1
    spm('Defaults', 'fmri');
else
    spm_defaults;
end
% Identify spm version
spmv = spm('Ver'); spm_ver = 'spm2';
if (strcmp(spmv,'SPM5') | strcmp(spmv,'SPM8b') | strcmp(spmv,'SPM8') )
    spm_ver = 'spm5'; end

% Get the existing SPM file
if strcmp(spm_ver,'spm5')
    origSPM   = spm_select(1,'mat','Select SPM design to re-estimate');
    RepairResults = spm_select(1,'dir','Select folder for Repaired Results');
else
    origSPM = spm_get(1, 'SPM.mat', 'Select SPM design to re-estimate');
    RepairResults = spm_get(-1,'*','Select folder for Repaired Results');
end
dirSPM = fileparts(origSPM);
cd(dirSPM);
copyfile('SPM.mat',RepairResults);
%status =unix('cp SPM.mat RepairResults');
cd(RepairResults);
load SPM;
% Load the new location
SPM.swd = RepairResults;

% Recall a few design sizes from the SPM structure
num_sess = size(SPM.nscan,2);  % number of sessions
%session_size = SPM.nscan(1);   % assumed all sessions are the same length.
%scandata = SPM.xY.VY.fname;    % filename of each image volume



%=====================================================================
%  LOGIC FOR ADDING CONFOUNDS 
%-------------------------------------------------------------------------
%    When the art_global program "repairs" the data, it writes the
% files art_deweighted.txt and art_repaired.txt to the Images folder in
% a single session study. For multiple sessions, we assume each session
% is repaired separately. 

% Clear out everything NOT usually initialized
%   Keep SPM.nscan, xY, xGx, xBF
save1 = SPM.xX.K.HParam;
save2 = SPM.xVi.form;
save3 = SPM.xX.X;
SPM.xX=[];  
SPM.xVi=[];
SPM.xX.K.HParam = save1;
SPM.xVi.form = save2;
% Keep SPM.Sess, SPMid, swd, xCon
SPM.xM=[]; SPM.xsDes=[]; SPM.xVol=[]; SPM.Vbeta=[]; SPM.VResMS=[]; SPM.VM=[]; 
saveCon = SPM.xCon;
saveSess = SPM.Sess;
consize = length(SPM.xCon);
SPM.xCon=[];

  
% For multiple sessions, art_repaired list is in EACH session folder.
try
    for isess = 1:num_sess
        index = 1;
        session_size = SPM.nscan(isess);  % no. scans in this session
        if isess > 1  % Find a scan in the folder for session isess
            for j = 1:isess-1
                index = index + SPM.nscan(j);
            end
        end
        imagedir = fileparts(SPM.xY.VY(index).fname);
        repairlist = fullfile(imagedir,'art_repaired.txt');
        outindex = load(repairlist);
        Nconfounds = length(outindex);
        Nconf(isess) = Nconfounds;
        Nconfoundstring = num2str(Nconfounds);
        outmsg = [Nconfoundstring ' confounds produced for session ' num2str(isess)];
        disp(outmsg)
        if Nconfounds > 0
            Nmatrix = zeros(session_size,Nconfounds);
            for k=1:Nconfounds
                Nmatrix(outindex(k),k) = 1;
            end
            Qz = size(SPM.Sess(isess).C.C,2);  % no. of existing confounds
            SPM.Sess(isess).C.C(1:session_size,Qz+1:Qz+Nconfounds) = Nmatrix;
            for k = 1:Nconfounds
                SPM.Sess(isess).C.name{Qz+k}= 'artif';
            end
            % Compute the correlations of the design (SPM.xX.X) to the
            % artifact locations
            artifs = zeros(session_size,1); artifs(outindex) = 1;
            RHO = corr(save3(index:index+session_size-1,:),artifs);
            disp('Correlations of design conditions with artifacts')
            RHO
        end
    end
    disp('Adding rapid-motion confounds to GLM Design.')
catch
    disp('WARNING: Could not locate an art_repaired.txt file for each session')
end


% Configure the design matrix with the new confounds
 if (strcmp(SPM.xVi.form, 'i.i.d'))  % changed name is used in spm_fmri_spm_ui.
       SPM.xVi.form = 'none';
 end
SPM = spm_fmri_spm_ui(SPM); 
    

% Write the amended SPM.mat file with added confounds.
disp('The SPM.mat file has been modified and saved to disk.');
cd(SPM.swd);
save SPM SPM;


% Already saved contrast definitions, before deletion by spm_spm.
SPM = spm_spm(SPM); 

% Recover the contrasts and run them.  
SPM.xCon = saveCon;  % explicitly sets up structure for SPM8, BUT MAY FILL IN TOO MUCH.
% Augment the existing contrasts with zeros for the new confounds
% The new confounds are located after the design and original confounds for each session, 
% and the constant terms for all sessions are at the very end.
% The number of sessions is num_sess. length(SPM.Sess).
% The number of design elements in session N is SPM.Sess(N).U   (MAYBE ??)
% Define the new contrast ordering when mixed with confounds.
%  first : saveCon(1).c(1:length(SPM.Sess(1).U).  original design
%  next: : saveCon(1).c(1:length(SPM.Sess(1).C).  original and new confounds
%  next:   Nconf(1)  of zeros                     new confound
%  next:  saveCon(1).c(1:length(SPM.Sess(2).U).   original design
%  next: : saveCon(1).c(1:length(SPM.Sess(2).C).  original and new confounds
%  next:   Nconf(2)  of zeros
% Assemble the new contrast vectors

%  BUG BUG BUG-----------------------------
for j = 1:consize     % BUG, BUG, BUG
    ind = 0;     % to specify locations in the new contrast vector
    indold = 0;  % to recall locations in the original contrast vector
    for isess = 1:num_sess
        lensess = length(SPM.Sess(isess).U); 
        vect(j,ind+1:ind+lensess) = saveCon(j).c(indold+1:indold+lensess);
        ind = ind + lensess;
        indold = indold + length(saveSess(isess).U) + length(saveSess(isess).C);
        lenconf = length(SPM.Sess(isess).C);  % includes new and original confounds
        vect(j,ind+1:ind+lenconf) = zeros(1,lenconf);
        ind = ind + lenconf;
    end
    ns = num_sess;
    vect(j,ind+1:ind+ns) = zeros(1,ns);   % for the constant terms
end
% BUG BUG BUG------------------------------

disp('Original contrast vector size')
size(saveCon(1).c)
disp('New confounds added')
sum(Nconf)
disp('New contrast vector size')
size(vect)

for j = 1:consize
    temp(j).c = vect(j,:);
    %Ntotal = sum(Nconf);
    %temp(j).c = [ saveCon(j).c; zeros(Ntotal,1) ];  % BUG, Puts 0's in wrong place.
    spmtemp = spm_FcUtil('Set', temp(j).name, temp(j).STAT, 'c', temp(j).c, SPM.xX.xKXs);
    SPM.xCon(j) = spmtemp;
end
if consize > 0
    spm_contrasts(SPM);
end

disp('Done. New estimates have been created.');
disp('Compare new and old estimates with Global Quality metric.');


