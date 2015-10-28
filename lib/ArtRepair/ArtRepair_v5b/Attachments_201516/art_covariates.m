function X = art_covariates( SubjectDir , ImageDir, OutputDir )
% FUNCTION art_covariates  (GUI mode)  OR 
% FUNCTION art_covariates( SubjectDir, OutputDir )   (batch mode)
%
%  Builds null regressor files (Lemieux, 2007) that can be used as 
%  covariates in SPM designs. The scans marked for repair by ArtRepair 
%  are converted into null regressors.  
%  Two covariate files are produced, 
%  one with only the null regressors, and one with the six realignment
%  parameters plus the null regressors. Users may add either one to the
%  the SPM design. When the art_motionadjust method is used to suppress
%  motion effects, it is recommended to use the null regressors without
%  including the realignment parameters.
%
%  Assumes realignment rp*txt file and art_repaired.txt
%  are available in the images folder for each session.
%
%  GUI mode with no input will do one session of one subject; use the 
%  batch mode for multiple subjects and sessions, as is done by estiscript5.
%
%  INPUT
%    RealignmentFile = Full path name of realignment file as char string
%       For multiple sessions, cell array with one name per session.
%       GUI will ask for it, if not provided.
%    art_repaired.txt file.
%  OUTPUT
%    File of null regressors, art_covariates.txt, written to image folder.
%    File of realignment paramters and null regressors  art_covariatesB.txt
%    For GUI mode, makes a plot.
%
%  pkm  aug 2013. 

% Identify spm version
spmv = spm('Ver'); spm_ver = 'spm8';
if (strcmp(spmv,'SPM2')) spm_ver = 'spm2'; end

if nargin == 0   % Usual GUI from plotmove program
    if strcmp(spm_ver,'spm8')
        sub = spm_select(Inf,'^rp.*\.txt$','Select subject realignment file:');
        % try to find the art files automatically
        artrepfile = spm_select('FPList', fileparts(sub) , '^art_rep.*\.txt');
        %artdewfile = spm_select('FPList', fileparts(sub) , '^art_dew.*\.txt');
    else   % spm2
        sub = spm_get(1,'rp*.txt',' Select Subject realignment file:'); 
        % try to find the art files automatically
        artrepfile = spm_get('files', fileparts(sub), 'art_rep*.txt');
        %artdewfile = spm_get('files', fileparts(sub), 'art_dew*.txt');
        datarep = load(artrepfile);
        datadew = load(artdewfile);
    end
    makeplot =1;
    num_sess = 1;
    numsubj = 1;
    
    R{1}=load(sub);
    Ra{1}=load(artrepfile);
    [fpath,fname,fext] = fileparts(sub);
    % irritatingly, we run into trouble now if our filename has a dot in it,
    % because MATLAB tries to interpret that as a structure field reference.
    dot = findstr(fname, '.');
    if ~(isempty(dot))
        fname = fname(1:(dot - 1));
    end
    data1 = eval(fname);
    %nscans = size(data1,1);
    
elseif nargin > 0
    num_sess = size(ImageDir,1);
    makeplot = 0;
    % Handles input of multiple sessions below

    for ksession = 1:num_sess
    numsubj = length(SubjectDir);
    for i = 1:numsubj
        sjDir = [ SubjectDir{i} ImageDir(ksession,:) ];
        if strcmp(spm_ver,'spm5')
             %realname = [ '^' prefix{6} '.*\.img$'  ];
             %for i = 1:nsess
            mvfile = spm_select('FPList', sjDir , '^rp.*\.txt');
            %mvfile = [sjDir  '^rp_.*\.' '_001.txt'];  % same prefix as realignment.];
            % try to find the art files automatically
            artrepfile = spm_select('FPList', sjDir , '^art_rep.*\.txt');
        else   % spm2
            mvfile = spm_get('files', sjDir, 'rp*.txt');
            %mvfile = [sjDir  'rp*' '001.txt'];  % same prefix as realignment.];
            % try to find the art files automatically
            artrepfile = spm_get('files', sjDir, 'art_rep*.txt');
        end
        R{i} = load(mvfile);
        Ra{i} = load(artrepfile);
        Rb{i} = load(artdewfile);
    end
    end
end


if makeplot == 1
    page = figure('NumberTitle', 'off', 'PaperOrientation', 'landscape', 'PaperPosition', [0 0 11 8.5], 'Units', 'inches', 'Position', [0 0 11 8.5]);
    h1 = subplot(2,1,1), plot(data1(:,1:3));
    h2 = subplot(2,1,2), plot(data1(:,4:6));

    %plotline(14,'k:');
    %plotline(320,'k:');
    subplot(h1), ylabel('movement in mm');
    xlabel('scans');
    y_lim = get(gca, 'YLim');
    legend('x mvmt', 'y mvmt', 'z mvmt',0);
    %legend('x mvmt', 'y mvmt', 'z mvmt', ['max:' num2str(y_lim(2))], ['min:' num2str(y_lim(1))],0);

    subplot(h2);
    ylabel('movement in rad');
    xlabel('scans');
    y_lim = get(gca, 'YLim');
    %legend('pitch', 'roll', 'yaw',0);
    legend('pitch', 'roll', 'yaw', ['max:' num2str(y_lim(2))], ['min:' num2str(y_lim(1))],0);
    
    %  ADD OVERLAY OF REPAIRED SCANS

    set(h1,'Ygrid','on');
    set(h2,'Ygrid','on');
end

for ksession = 1:num_sess
    

% Let's make MOTION SUMMARIES and read the repair txt files

for isubj = 1:numsubj  
    disp('Writing art_covariates.txt file to image directory of subject')
    disp(SubjectDir{isubj});     
    if nargin > 0
        clear data1;
        data1 = R{isubj};  % realignment data
        datarep = Ra{isubj};
    end
    % Count the number of scans and the number of repairs
    X = [ data1(:,1) data1(:,2) data1(:,3) data1(:,4) data1(:,5) data1(:,6) ];
    nscans = size(data1,1);
    numrep = size(datarep);
 
    if numrep > 0
     Y = zeros(nscans, numrep);
     for j = 1:numrep
         Y(datarep(j),j) = 1;
     end
     X = [ X  Y ];
    else
     disp('No repairs in this session.')
    end
 
% Print out two art_covariate.txt files to the Image directory
    filen = ['art_covariates'.txt'];
    logname = fullfile(OutputDir,filen);
    logID = fopen(logname,'wt');
    filen2 = ['art_covariates2'.txt'];
    logname2 = fullfile(OutputDir,filen2);
    logID2 = fopen(logname2,'wt');
    fprintf(logID,'\n%4d %8.4f   %8.4f   %8.4f   %8.4f  %6d.0  %6d.0 %6d.0 %6d.0', X);    
    fclose(logID);
    fprintf(logID2,'\n%4d %8.4f   %8.4f   %8.4f   %8.4f  %6d.0  %6d.0 %6d.0 %6d.0', Y);    
    fclose(logID2);

end

end % THIS IS THE KSESSION OUTER LOOP

%save Xall Xall;