function fH = icatb_plot_connectogram(param_file, comp_network_names, varargin)
%% Functional network connectivity correlations are visualized as a connectogram plot.
%
% Inputs:
%
% 1. param_file - ICA parameter file (*ica*param*mat). By default, one sample t-test results of the FNC correlations are visualized. Also mean components are used for component maps.
% If you want to pass the user defined correlation matrix pass after
% parameter 'C' and nifti file name after 'image_file_names' parameter.
% 2. comp_network_names - Network names and values are defined in a cell
% array of size number of networks by 2. First column corresponds to
% network names and second one corresponds to component numbers in the
% nifti file. You could optionally provide color values (Say [1, 1, 1] for white color) for each network in
% column 3.
% 3. Variable arguments are passed in pairs:
%   a. 'C' - Correlation matrix of size N x N where N is the number of
%   components defined in comp_network_names.
%   b. 'image_file_names' - Nifti file name containing spatial maps.
%   c. 'convert_to_zscores' - Convert images to z-scores. Options are 'yes' and 'no'.
%   d. 'image_values' - Image values. Options are 'positive and negative',
%   'postive', 'absolute value' and 'negative'.
%   e. 'template_file' - Anatomical file name.
%   f. 'slice_plane' - Anatomical plane to view.
%   g. 'threshold' - Threshold value.
%   h. 'colorbar_label' - Colorbar label.
%   i. cmap - Colormap of length 64 like hot(64).
%
% Example is below:
%
%
% comp_network_names = {'BG', 21;                    % Basal ganglia 21st component
%     'AUD', 17;                   % Auditory 17th component
%     'SM', [7 23 24 29 38 56];    % Sensorimotor comps
%     'VIS', [39 46 48 59 64 67];  % Visual comps
%     'DMN', [25 50 53 68];        % DMN comps
%     'ATTN', [34 52 55 60 71 72]; % ATTN Comps
%     'FRONT', [20 42 47 49]};     % Frontal comps
%
% C = icatb_corr(rand(1000, 28)); C = C - eye(size(C)); C(abs(C) < 0.01) = 0;
% fname = 'F:\Example Subjects\mancova_sample_data\ica_output\rest_hcp_mean_component_ica_s_all_.nii';
% icatb_plot_connectogram([], comp_network_names, 'C', C, 'threshold', 1.5, 'image_file_names', fname, 'colorbar_label', 'Corr');
%

icatb_defaults;
global FONT_COLOR;
global CONNECTOGRAM_SM_WIDTH;

%% Parse params
threshold = 1.5;
convert_to_zscores = 'yes';
image_values = 'positive';
load icatb_colors coldhot;
cmap = coldhot(1:4:end, :);
template_file = fullfile(fileparts(which('groupica.m')), 'icatb_templates', 'ch2bet.nii');
slice_plane = 'sagittal';
colorbar_label = 'Corr';
imWidth = CONNECTOGRAM_SM_WIDTH;
titleStr = 'Connectogram';

for nF = 1:2:length(varargin)
    if (strcmpi(varargin{nF}, 'C'))
        C = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'image_file_names'))
        fileNames = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'convert_to_zscores') || strcmpi(varargin{nF}, 'convert_to_z'))
        convert_to_zscores = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'image_values'))
        image_values = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'cmap'))
        cmap = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'template_file'))
        template_file = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'slice_plane'))
        slice_plane = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'threshold'))
        threshold = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'colorbar_label'))
        colorbar_label = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'imwidth'))
        imWidth = varargin{nF + 1};
    elseif (strcmpi(varargin{nF}, 'title'))
        titleStr = varargin{nF + 1};
    end
end

if (~exist('param_file', 'var'))
    param_file = [];
end


if (~isempty(param_file))
    load(param_file);
    sesInfo.outputDir = fileparts(param_file);
    sesInfo.userInput.pwd = sesInfo.outputDir ;
end

%% Compute t-test if correlation pairs not present
if (~exist('C', 'var'))
    
    comps = [comp_network_names{:, 2}];
    comps = comps(:)';
    
    for nSub = 1:sesInfo.numOfSub
        TC = icatb_loadComp(sesInfo, comps, 'vars_to_load', 'tc', 'detrend_no', 3, 'subjects', nSub);
        cvals = icatb_corr(squeeze(TC));
        cpairs = icatb_mat2vec(cvals);
        if (nSub == 1)
            Ct = zeros(sesInfo.numOfSub, length(cpairs));
        end
        Ct(nSub, :) = cpairs;
    end
    
    alpha = 0.05;
    [pi, tstat] = icatb_ttest(Ct);
    tstat(pi > alpha) = 0;
    tstat(tstat == 0) = NaN;
    C = icatb_vec2mat(tstat);
    
end

C(C==0) = NaN;

[C, comp_network_names] = removeZeros(C, comp_network_names);

colorlims = max(abs(C(:)));
colorlims = [-colorlims, colorlims];



comps = [comp_network_names{:,2}];

newC = cell(1, length(comps));

frame_colors = [166, 206, 227; 31,120,180; 178,223,138; 51,160,44; 251,154,153;
    227,26,28; 253,191,111; 255,127,0; 202,178,214; 106,61,154; 255,255,153; 177,89,40];

frame_colors = frame_colors/256;
frame_colors = [frame_colors(1:2:end,:);frame_colors(2:2:end,:)];

e = 0;
for nC = 1:size(comp_network_names, 1)
    s = e + 1;
    e = e + length(comp_network_names{nC, 2});
    tmp = [];
    try
        tmp = comp_network_names{nC, 3};
    catch
    end
    if (isempty(tmp))
        if (nC <= 14)
            %tmp = colordg(nC);
            tmp = frame_colors(nC,:);
        else
            tmp = rand(1, 3);
        end
    end
    newC(s:e) = {tmp}; %color_values(nC);
end

clear tmp;

compStr = cellstr(strcat('', num2str(comps(:))));


if (~exist('fileNames', 'var'))
    fileNames = fullfile(sesInfo.outputDir, sesInfo.icaOutputFiles(1).ses(1).name);
end

fileNames = cellstr(icatb_rename_4d_file(fileNames));

I = cell(1, length(comps));

structVol = icatb_spm_vol(template_file);
structVol = structVol(1);
structDIM = structVol.dim(1:3);

returnValue = strmatch(lower(image_values), {'positive and negative', 'positive', 'absolute value', 'negative'}, 'exact');

imagesCmap = icatb_getColormap(1, returnValue, 1);

for nComp = 1:length(comps)
    
    fileName = fileNames{comps(nComp)};
    
    [tmpF, tmpN] = icatb_parseExtn(fileName);
    
    imageTmp = icatb_resizeImage(structVol, tmpF, 'axial', [], tmpN);
    
    structData = reshape(imageTmp(1, :, :, :), structVol.dim(1:3));
    imageTmp = reshape(imageTmp(end, :, :, :), structVol.dim(1:3));
    
    imageTmp = icatb_applyDispParameters_comp(imageTmp(:)', strcmpi(convert_to_zscores, 'yes'), returnValue, threshold);
    imageTmp = reshape(imageTmp, structDIM);
    
    [dd, tmp_inds] = max(abs(imageTmp(:)));
    [pixX, pixY, pixZ] = ind2sub(structDIM, tmp_inds);
    
    if (strcmpi(slice_plane, 'sagittal'))
        cdata = (rot90(squeeze(imageTmp(pixX,:,:))));
        structData = (rot90(squeeze(structData(pixX,:,:))));
    elseif (strcmpi(slice_plane, 'coronal'))
        cdata = (rot90(squeeze(imageTmp(:,pixY,:))));
        structData = (rot90(squeeze(structData(:,pixY,:))));
    else
        cdata = (rot90(squeeze(imageTmp(:,:,pixZ))));
        structData = (rot90(squeeze(structData(:,:,pixZ))));
    end
    
    cdata = makeCompositeMap(structData, cdata, returnValue);
    
    cdata = returnRGB(cdata, imagesCmap);
    
    I{nComp} = cdata;
end


[h, fH] = plot_connecto_gram(C, I, cmap, compStr, newC, comp_network_names, imWidth);
set(fH, 'name', titleStr);

colormap(cmap);

cbWidth = 0.12;
cbHeight = 0.025;
ch = colorbar('horiz');
cpos = get(ch, 'position');
cpos(1) = 0.75 - 0.5*cbWidth;
cpos(2) = 0.05;
cpos(3) = cbWidth;
cpos(4) = cbHeight;
set(ch, 'position', cpos);
xlims = get(ch,'xlim');
set(ch, 'xtick', [xlims(1), xlims(end)]);
set(ch, 'xticklabel', num2str(colorlims','%0.1f'));
xlabel(colorbar_label, 'parent', ch);
set(ch, 'XCOLOR', FONT_COLOR);
set(ch, 'YCOLOR', FONT_COLOR);


function [h, fH] = plot_connecto_gram(C, I, cmap_corr, compNames, colorFrames, comp_network_names, imWidth)

% comp_network_names = {'BG', 21;                    % Basal ganglia 21st component
%                       'AUD', 17;                   % Auditory 17th component
%                       'SM', [7 23 24 29 38 56];    % Sensorimotor comps
%                       'VIS', [39 46 48 59 64 67];  % Visual comps
%                       'DMN', [25 50 53 68];        % DMN comps
%                       'ATTN', [34 52 55 60 71 72]; % ATTN Comps
%                       'FRONT', [20 42 47 49]};     % Frontal comps

%load (param_file);


%comps = [network_vals{:}];

% if (max(abs(C(:))) > 1)
%     colorlim = [-max(abs(C(:))), max(abs(C(:)))];
C = C./(max(abs(C(:))) + eps);
C(C == 0) = NaN;
% else
%     colorlim = [-max(abs(C(:))), max(abs(C(:)))];
% end


if (~exist('compNames', 'var'))
    compNames = cellstr(num2str((1:size(C,1))'));
end


if (~exist('colorFrames', 'var'))
    colorFrames = repmat({[1, 1, 0]}, length(compNames), 1);
end

if (~exist('cmap_corr', 'var'))
    cmap_corr = hsv(64);
end

if (~exist('imWidth', 'var'))
    imWidth = [];
end

fig_color='k';
numSlices = size(C, 2);
fH = icatb_getGraphics('Fig', 'graphics', 'gg', 'on');
set(fH, 'resize', 'on');
set(fH,'menubar','none');
sz = get(0, 'ScreenSize');
figPos = [50, 50, sz(3) - 100, sz(4) - 100];
set(fH, 'position', figPos);
if (numSlices < 10)
    axesWidth = 0.4;
else
    axesWidth = 0.62;
end
axesPos = [0.5 - 0.5*axesWidth, 0.5 - 0.5*axesWidth, axesWidth, axesWidth];
aH = axes('units', 'normalized', 'position', axesPos, 'NextPlot','add', 'tag', 'main_axes');
set(aH,'color',fig_color);
pi_incr = 2*pi/numSlices;
rin = 1;
rout = 1.3;
% if (numSlices < 10)
%     rout = 1.3;
% else
%     rout = 1.5;
% end
startAngle = -pi/2;

mpX = zeros(1, numSlices);
mpY = zeros(1, numSlices);
for n = 1:numSlices
    tmpC = colorFrames{n};
    endAngle = startAngle + pi_incr;
    t2 = linspace(startAngle, endAngle, 100);
    th(n) = t2(ceil(length(t2)/2));
    startAngle = endAngle;
    xin = rin*cos(t2(end:-1:1));
    yin = rin*sin(t2(end:-1:1));
    xout = rout*cos(t2);
    yout = rout*sin(t2);
    
    patch([xout, xin],[yout, yin], tmpC, 'edgecolor', 'k');
    xx = (rin + rout)*cos(th(n))/2;
    yy = (rin + rout)*sin(th(n))/2;
    %trot(n) = 180/pi* (atan((newY(2) - newY(1)) / (newX(2) - newX(1))));
    %thA=text(xx,yy,compNames{n},'horizontalalignment','center','rotation',(180/pi)*th(n),'fontsize',11,'fontweight','bold', 'color', 'k', 'tag', ['text_', num2str(n)]);
    mpX(n) = xx;
    mpY(n) = yy;
    hold on;
end

mpX(end + 1) = mpX(1);
mpY(end + 1) = mpY(1);
axis equal;
axis off;


for n = 1:numSlices
    textDeg = 180/pi* (atan((mpY(n + 1) - mpY(n)) / ( mpX(n + 1) - mpX(n) )));
    thA=text(mpX(n),mpY(n),compNames{n},'horizontalalignment','center','rotation',textDeg,'fontsize',11,'fontweight','bold', 'color', 'k', 'tag', ['text_', num2str(n)]);
end

if (numSlices < 10)
    RText = 2.8;
else
    RText = 2;
end
[xtext,ytext]=pol2cart(th, RText);
e = 0;
for n = 1:size(comp_network_names, 1)
    nIn = length(comp_network_names{n, 2});
    s = e + ceil(nIn/2);
    e = e + nIn;
    inc = 0;
    textDeg = 180/pi* (atan((mpY(s + 1) - mpY(s)) / ( mpX(s + 1) - mpX(s) )));
    text(xtext(s) + inc, ytext(s) + inc, comp_network_names{n, 1}, 'parent', aH, 'color', colorFrames{s}, 'fontsize', 14, 'fontweight', 'bold', 'rotation', ...
        textDeg, 'tag', ['Label_', num2str(n)]);
end


if (numSlices < 10)
    R = 2;
else
    R = 1.7;
end
[Xna,Yna]= pol2cart(th, R);

[x0, y0] = getAxesPos(Xna, Yna, aH);

rL = axesPos(4)/(2*rout);

rL = max(abs([rL*cos(2*pi/numSlices), rL*sin(2*pi/numSlices)]));

if (isempty(imWidth))
    imWidth = (2*pi*rL/numSlices);
    imWidth = min([imWidth, 0.16]);
    
    if (imWidth < 0.04)
        imWidth = 0.04;
    end
end

imHeight = imWidth;
offset = 0.5*imWidth;

e = 0;
ahs = zeros(1, length(Xna));
for n = 1:length(Xna)
    
    xVals = cos(th(n));
    yVals = sin(th(n));
    
    xr = -offset;
    yr = -offset;
    ah = axes('position',[x0(n) + xr, y0(n) + yr, imWidth, imHeight]);
    
    imagesc(I{n});
    
    axis image;
    
    axis off;
    
    ahs(n) = ah;
    
end

e = 0;
for n = 1:size(comp_network_names, 1)
    nIn = length(comp_network_names{n, 2});
    s = e + ceil(nIn/2);
    e = e + nIn;
    txtAlign = 'left';
    if (th(s) < 0)
        txtDeg = 180 + ((180/pi)*th(s));
        xTextPos = -0.1;
        inc = 2;
    else
        txtAlign = 'right';
        txtDeg = ((180/pi)*th(s));
        xTextPos = 1.5;
        inc = 0.1;
    end
    %     tH = title(comp_network_names{n, 1}, 'parent', ahs(s), 'units', 'normalized', 'color', colorFrames{s}, 'fontsize', 11, 'fontweight', 'bold', ...
    %         'tag', ['Label_', num2str(n)], 'horizontalalignment', txtAlign);
    %     textPos = get(tH, 'position');
    %     textPos(3) = textPos(3) + inc;
    %     set(tH, 'position', textPos);
    %     text(xTextPos, -0.1, comp_network_names{n, 1}, 'parent', ahs(s), 'color', colorFrames{s}, 'fontsize', 11, 'fontweight', 'bold', ...
    %         'tag', ['Label_', num2str(n)]);
end


labels = cellstr(strcat('', num2str((1:size(C,1))')));
[h,X,Y,cmap_corr] = schemaball(C,labels,cmap_corr,[1,0,0], aH, th);



function [mx, my] = midpoint(x, y)

newX = [x(end), x];
newY = [y(end), y];

my = zeros(1, length(x));
mx = my;

for n = 2:length(newX)
    
    mx(n - 1) = mean([newX(n - 1), newX(n)]);
    my(n - 1) = mean([newY(n - 1), newY(n)]);
end



function [h,x,y,ccolor] = schemaball(r, lbls, ccolor, ncolor, gH, theta)

% SCHEMABALL Plots correlation matrix as a schemaball
%
%   SCHEMABALL(R) R is a square numeric matrix with values in [0,1].
%
%                 NOTE: only the off-diagonal lower triangular section of R is
%                       considered, i.e. tril(r,-1).
%
%   SCHEMABALL(..., LBLS, CCOLOR, NCOLOR) Plot schemaball with optional
%                                         arguments (accepts empty args).
%
%       - LBLS      Plot a schemaball with custom labels at each node.
%                   LBLS is either a cellstring of length M, where
%                   M = size(r,1), or a M by N char array, where each
%                   row is a label.
%
%       - CCOLOR    Supply an RGB triplet that specifies the color of
%                   the curves. CURVECOLOR can also be a 2 by 3 matrix
%                   with the color in the first row for negative
%                   correlations and the color in the second row for
%                   positive correlations.
%
%       - NCOLOR    Change color of the nodes with an RGB triplet.
%
%
%   H = SCHEMABALL(...) Returns a structure with handles to the graphic objects
%
%       h.l     handles to the curves (line objects), one per color shade.
%               If no curves fall into a color shade that handle will be NaN.
%       h.s     handle  to the nodes (scattergroup object)
%       h.t     handles to the node text labels (text objects)
%
%
% Examples
%
%   % Base demo
%   schemaball
%
%   % Supply your own correlation matrix (only lower off-diagonal triangular part is considered)
%   x = rand(10).^3;
%   x(:,3) = 1.3*mean(x,2);
%   schemaball(x)
%
%   % Supply custom labels as ['aa'; 'bb'; 'cc'; ...] or {'Hi','how','are',...}
%   schemaball(x, repmat(('a':'j')',1,2))
%   schemaball(x, {'Hi','how','is','your','day?', 'Do','you','like','schemaballs?','NO!!'})
%
%   % Customize curve colors
%   schemaball([],[],[1,0,1;1 1 0])
%
%   % Customize node color
%   schemaball([],[],[],[0,1,0])
%
%   % Customize manually other aspects
%   h   = schemaball;
%   set(h.l(~isnan(h.l)), 'LineWidth',1.2)
%   set(h.s, 'MarkerEdgeColor','red','LineWidth',2,'SizeData',100)
%
%
% Additional features:
% - <a href="matlab: web('http://www.mathworks.com/matlabcentral/fileexchange/42279-schemaball','-browser')">FEX schemaball page</a>
% - <a href="matlab: web('http://www.stackoverflow.com/questions/17038377/how-to-visualize-correlation-matrix-as-a-schemaball-in-matlab/17111675','-browser')">Origin: question on Stackoverflow.com</a>
% - <a href="matlab: web('https://github.com/GuntherStruyf/matlab-tools/blob/master/schemaball.m','-browser')">Schemaball by Gunther Struyf</a>
%
% See also: CORR, CORRPLOT

% Author: Oleg Komarov (oleg.komarov@hotmail.it)
% Tested on R2013a Win7 64 and Vista 32
% 15 jun 2013 - Created

% TODO
% - Add backward compatibility until R14SP3 (7.1)
% - Allow custom colormaps

%% Parameters
% Tweak these only

% Number of color shades/buckets (large N simply creates many perceptually indifferent color shades)
%N      = 20;
if (size(ccolor, 1) > 2)
    N = size(ccolor,1)/2;
else
    N = 20;
end
% Points in [0, 1] for bezier curves: leave space at the extremes to detach a bit the nodes.
% Smaller step will use more points to plot the curves.
t      = (0.025: 0.05 :1)';
% Nodes edge color
ecolor = [.25 .103922 .012745];
% Text color
tcolor = [.7 .7 .7];

%% Checks

% Ninput
%narginchk(0,5)

% Some defaults
if nargin < 1 || isempty(r);        r      = (rand(50)*2-1).^29;                                  end
sz = size(r);
if nargin < 2 || isempty(lbls);     lbls   = cellstr(reshape(sprintf('%-4d',1:sz(1)),4,sz(1))');  end
if nargin < 4 || isempty(ncolor);   ncolor = [0 0 1];                                             end

% R
if ~isnumeric(r) || any(abs(r(:)) > 1) || sz(1) ~= sz(2) || numel(sz) > 2 || sz(1) == 1
    error('schemaball:validR','R should be a square numeric matrix with values in [0, 1].')
end

% Lbls
if (~ischar(lbls) || size(lbls,1) ~= sz(1)) && (~iscellstr(lbls) || ~isvector(lbls) || length(lbls) ~= sz(1))
    error('schemaball:validLbls','LBLS should either be an M by N char array or a cellstring of length M, where M is size(R,1).')
end
if ischar(lbls)
    lbls = cellstr(lbls);
end

% Ccolor
if nargin < 3 || isempty(ccolor);
    ccolor = hsv2rgb([[linspace(.8333, .95, N); ones(1, N); linspace(1,0,N)],...
        [linspace(.03, .1666, N); ones(1, N); linspace(0,1,N)]]');
else
    %         szC = size(ccolor);
    %         if ~isnumeric(ccolor) || szC(2) ~= 3  || szC(1) > 2
    %            error('schemaball:validCcolor','CCOLOR should be a 1 by 3 or 2 by 3 numeric matrix with RGB colors.')
    %         elseif szC(1) == 1
    %             ccolor = [ccolor; ccolor];
    %         end
    %         ccolor = rgb2hsv(ccolor);
    %         ccolor = hsv2rgb([repmat(ccolor(1,1:2),N,1), linspace(ccolor(1,end),0,N)';
    %             repmat(ccolor(2,1:2),N,1), linspace(0,ccolor(2,end),N)']);
end

% Ncolor
szN = size(ncolor);
if ~isnumeric(ncolor) || szN(2) ~= 3  || szN(1) > 1
    error('schemaball:validNcolor','NCOLOR should be a single RGB color, i.e. a numeric row triplet.')
end
ncolor = rgb2hsv(ncolor);
%% Engine

% Create figure
if (~exist('gH', 'var'))
    figure('renderer','zbuffer','visible','off')
    axes('NextPlot','add')
else
    axes(gH);
end

% Index only low triangular matrix without main diag
tf        = tril(true(sz),-1);

% Index correlations into bucketed colormap to determine plotting order (darkest to brightest)
N2        = 2*N;
[n, isrt] = histc(r(tf), linspace(-1,1 + eps(100),N2 + 1));
plotorder = reshape([N:-1:1; N+1:N2],N2,1);

% Retrieve pairings of nodes
[row,col] = find(tf);

% Use tau http://tauday.com/tau-manifesto
tau   = 2*pi;
% Positions of nodes on the circle starting from (0,-1), useful later for label orientation
%step  = tau/sz(1);
%theta = -.25*tau : step : .75*tau - step;
% Get cartesian x-y coordinates of the nodes
x     = cos(theta);
y     = sin(theta);

% PLOT BEZIER CURVES
% Calculate Bx and By positions of quadratic Bezier curves with P1 at (0,0)
% B(t) = (1-t)^2*P0 + t^2*P2 where t is a vector of points in [0, 1] and determines, i.e.
% how many points are used for each curve, and P0-P2 is the node pair with (x,y) coordinates.
t2  = [1-t, t].^2;
s.l = NaN(N2,1);
% LOOP per color bucket
for c = 1:N2
    pos = plotorder(c);
    idx = isrt == pos;
    if nnz(idx)
        Bx     = [t2*[x(col(idx)); x(row(idx))]; NaN(1,n(pos))];
        By     = [t2*[y(col(idx)); y(row(idx))]; NaN(1,n(pos))];
        s.l(c) = plot(Bx(:),By(:),'Color',ccolor(pos,:),'LineWidth',1.5);
    end
end

h = s;

% % PLOT NODES
% % Do not rely that r is symmetric and base the mean on lower triangular part only
% [row,col]  = find(tf(end:-1:1,end:-1:1) | tf);
% subs       = col;
% iswap      = row < col;
% tmp        = row(iswap);
% row(iswap) = col(iswap);
% col(iswap) = tmp;
% % Plot in brighter color those nodes which on average are more absolutely correlated
% [Z,isrt]   = sort(accumarray(subs,abs(r( row + (col-1)*sz(1) )),[],@mean));
% Z          = (Z-min(Z)+0.01)/(max(Z)-min(Z)+0.01);
% ncolor     = hsv2rgb([repmat(ncolor(1:2), sz(1),1) Z*ncolor(3)]);
% s.s        = scatter(x(isrt),y(isrt),[], ncolor,'fill','MarkerEdgeColor',ecolor,'LineWidth',1);
% set(s.s, 'markerEdgeColor', 'r', 'markerFaceColor', 'r');
% %s.s        = scatter(x(isrt),y(isrt),[], ncolor,'fill','MarkerEdgeColor',ecolor,'LineWidth',1);
% %s.s        = scatter(x(isrt),y(isrt),[], ncolor,'fill','MarkerEdgeColor','none','LineWidth',1);
%
% % PLACE TEXT LABELS such that you always read 'left to right'
% ipos       = x > 0;
% s.t        = zeros(sz(1),1);
% s.t( ipos) = text(x( ipos)*1.08, y( ipos)*1.08, lbls( ipos),'Color',tcolor);
% set(s.t( ipos),{'Rotation'}, num2cell(theta(ipos)'/tau*360))
% s.t(~ipos) = text(x(~ipos)*1.08, y(~ipos)*1.08, lbls(~ipos),'Color',tcolor);
% set(s.t(~ipos),{'Rotation'}, num2cell(theta(~ipos)'/tau*360 - 180),'Horiz','right')
%
% % ADJUST FIGURE height width to fit text labels
% xtn        = cell2mat(get(s.t,'extent'));
% post       = cell2mat(get(s.t,'pos'));
% sg         = sign(post(:,2));
% posfa      = cell2mat(get([gcf gca],'pos'));
% % Calculate xlim and ylim in data units as x (y) position + extension along x (y)
% ylims      = post(:,2) + xtn(:,4).*sg;
% ylims      = [min(ylims), max(ylims)];
% xlims      = post(:,1) + xtn(:,3).*sg;
% xlims      = [min(xlims), max(xlims)];
% % Stretch figure
% posfa(1,3) = (( diff(xlims)/2 - 1)*posfa(2,3) + 1) * posfa(1,3);
% posfa(1,4) = (( diff(ylims)/2 - 1)*posfa(2,4) + 1) * posfa(1,4);
% % Position it a bit lower (movegui slow)
% posfa(1,2) = 100;
%
% % Axis settings
% set(gca, 'Xlim',xlims,'Ylim',ylims, 'layer','bottom', 'Xtick',[],'Ytick',[])
% set(gcf, 'pos' ,posfa(1,:),'Visible','on')
% axis equal
%
% %if nargout == 1
% h = s;
%end


function scaledData = scaleIm(tmin, tmax, imageData, returnValue, data_range)
%% Scale images
%

if (~exist('returnValue', 'var'))
    returnValue = 2;
end

if (~exist('data_range', 'var'))
    minVal = min(imageData);
    maxVal = max(imageData);
else
    minVal = min(data_range);
    maxVal = max(data_range);
end

if (returnValue == 1)
    maxVal = max(abs([minVal, maxVal]));
    minVal = -maxVal;
end

rangeVal = (maxVal-minVal) + eps;
trange = tmax-tmin;
if (rangeVal == 0)
    rangeVal = eps;
end
scaledData = (((imageData-minVal)./rangeVal)./(1/trange))+tmin;


function compositeMap = makeCompositeMap(structData, imageTmp, returnValue)
%% Make composite map
%
mask_inds = (abs(imageTmp) > eps);

compositeMap = scaleIm(65, 128, structData(:));
compositeMap(mask_inds) = scaleIm(1, 64, imageTmp(mask_inds), returnValue);

compositeMap = reshape(compositeMap, size(structData));

function RGB = returnRGB(compositeMap, cmap)
%% Get RGB values
%
RGB = zeros([size(compositeMap), 3]);

compositeMap = ceil(compositeMap);

for n1 = 1:size(compositeMap, 1)
    for n2 = 1:size(compositeMap, 2)
        tmp = squeeze(compositeMap(n1, n2));
        %if (tmp ~= 1)
        RGB(n1, n2, :) = cmap(tmp, :);
        %end
    end
end


function [x0, y0] = getAxesPos(Xna, Yna, aH)
%% Get axes position in figure units
%

xlim = get(aH, 'xlim');
ylim = get(aH, 'ylim');
pos = get(aH, 'position');

mn = min(xlim);
rn = range(xlim);
x0 = pos(1) + (pos(3))*(Xna - mn)./rn;

mn = min(ylim);
rn = range(ylim);
y0 = pos(2) + (pos(4) )*(Yna - mn)./rn;


function rangeVal = range(imageData)
%% Get range

minVal = min(imageData(:));
maxVal = max(imageData(:));
rangeVal = maxVal-minVal;



function [C, comp_network_names] = removeZeros(C, comp_network_names)
%% Cleanup the correlation matrix
%

C(eye(size(C)) == 1) = 0;
C(isfinite(C)==0) = 0;
rows = (1:size(C, 1));
inc = [];
for n = 1:size(C, 1)
    tmp = C(n, :);
    if length(find(abs(tmp) > eps)) > 0
        inc = [inc, n];
    end
end

C = C(inc, inc);

if (isempty(C))
    error('Correlation matrix has all zeros');
end

Nrows = size(comp_network_names, 1);
RowsToexclude = [];
endLen = 0;
for nC = 1:Nrows
    startLen = endLen + 1;
    tmpC = comp_network_names{nC, 2};
    endLen = endLen + length(tmpC);
    compN = (startLen:endLen); %comp_network_names{nC, 2};
    [chk, ia] = intersect(compN, inc);
    if (isempty(chk))
        comp_network_names{nC, 2} = [];
    else
        ia = sort(ia);
        comp_network_names{nC, 2} = tmpC(ia);
    end
    %if (isempty(chk))
    %RowsToexclude = [RowsToexclude, nC];
    %end
end

chk = cellfun('isempty', comp_network_names(:,2));
comp_network_names(chk, :) = [];
