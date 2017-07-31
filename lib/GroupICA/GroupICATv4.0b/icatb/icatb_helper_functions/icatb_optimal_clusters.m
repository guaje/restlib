function results = icatb_optimal_clusters(data, num_clusters, varargin)
%% Get optimal number of clusters using gap statistic or silhouette
%
% Inputs:
% 1. data - Observations of dimensions N x M
% 2. num_clusters - Number of clusters to evaluate
% Arguments passed in pairs
%   a. method - Options are gap and silhoutte
%   b. num_tests - Number of times data is generated when using gap method
%
% Outputs:
% 1. results.K - Optimal number of clusters
% 2. results.values - Gap statistic or Silhouette values
% 3. results.sem - Standard error of mean (gap stat only)
%

%% Parse inputs
Nt = 10;
method = 'gap';
for nV = 1:length(varargin)
    if (strcmpi(varargin{nV}, 'num_tests'))
        Nt = varargin{nV + 1};
    elseif (strcmpi(varargin{nV}, 'method'))
        method = varargin{nV + 1};
    end
end

% Run in parallel if parpool exists
run_parallel = 0;
try
    pool = gcp;
    if (~isempty(pool))
        run_parallel = 1;
    end
catch
end

if (strcmpi(method, 'gap'))
    % Gap stat
    [K, values, sem] = computeGap(data, num_clusters, Nt, run_parallel);
    results.K = K;
    results.values = values;
    results.sem = sem;
    results.klist = (1:num_clusters);
else
    % Silhouette
    [K, values] = computeSilh(data, num_clusters, run_parallel);
    results.K = K;
    results.values = values;
    results.klist = (2:num_clusters);
end

function [optimal_clusters, gapvalues, sem] = computeGap(data, num_clusters, Nt, run_parallel)
%% Compute gap stat
%

%% Get expected value of logW
[pcaX, V] = doPCA(data);

rlogW = zeros(Nt, num_clusters);
for n = 1:Nt
    X = getdata(pcaX, V);
    if (~run_parallel)
        for k = 1:num_clusters
            [dd, pp, sumd] = doKmeans(X, k);
            rlogW(n, k) = log(sum(sumd(:)));
        end
    else
        parfor k = 1:num_clusters
            [dd, pp, sumd] = doKmeans(X, k);
            rlogW(n, k) = log(sum(sumd(:)));
        end
    end
end

ElogW = mean(rlogW);
sem = std(rlogW, 1, 1)*sqrt(1 + (1/Nt));


%% Gap statistic and determine no. of optimal clusters
gapvalues = zeros(1, num_clusters);
if (~run_parallel)
    for j = 1:num_clusters
        [dd, pp, sumd] = doKmeans(data, j);
        logW = log(sum(sumd(:)));
        gapvalues(j) = ElogW(j) - logW;
    end
else
    parfor j = 1:num_clusters
        [dd, pp, sumd] = doKmeans(data, j);
        logW = log(sum(sumd(:)));
        gapvalues(j) = ElogW(j) - logW;
    end
end

chk = diff(gapvalues)./sem(2:end);
inds = find(chk <= 1);
optimal_clusters = min([num_clusters, inds(:)']);



function [pcaX, V] = doPCA(data)
%% PCA
%

data = bsxfun(@minus, data, mean(data));
[U, S, V] = svd(data, 0);
pcaX = data*V;


function X = getdata(pcaX, V)
%% Generate uniform distribution
%
mn = min(pcaX);
mx = max(pcaX);
r = (mx - mn);
[rows, cols] = size(pcaX);

X = bsxfun(@plus, mn, bsxfun(@times, r, rand(rows, cols)));
X = X*V';


function  [dd, pp, sumd] = doKmeans(X, k)
%% Kmeans
%

try
    [dd, pp, sumd] = kmeans(X, k, 'rep', 5, 'empty', 'singleton', 'MaxIter', 150);
catch
    
    if (k == 1)
        dd = ones(size(X, 1), 1);
        pp = mean(X);
        X = bsxfun(@minus, X, pp);
        sumd = sum(sum(X.^2));
    else
        [dd, pp, sumd] = icatb_kmeans(X, k, 'rep', 5, 'empty', 'singleton', 'MaxIter', 150);
    end
    
end


function [optimal_clusters, values] = computeSilh(data, num_clusters, run_parallel)
%% Compute Silhouette
%

values = zeros(1, num_clusters);
values(1) = -Inf;

if (~run_parallel)
    
    for n = 2:num_clusters
        [idx, cx, sumd] = doKmeans(data, n);
        silh = getsilh(data, idx, run_parallel);
        silh(isfinite(silh) == 0) = [];
        values(n) = mean(silh);
    end
    
else
    
    parfor n = 2:num_clusters
        [idx, cx, sumd] = doKmeans(data, n);
        silh = getsilh(data, idx, run_parallel);
        silh(isfinite(silh) == 0) = [];
        values(n) = mean(silh);
    end
    
end

[dd, optimal_clusters] = max(values);
values(1) = [];


function silh = getsilh(X, idx, run_parallel)
%% Silhouette values using squared euclidean

k = length(unique(idx));
n = size(X, 1);
mbrs = (repmat(1:k, n, 1) == repmat(idx, 1, k));
count = histc(idx(:)', 1:k);
avgDWithin = repmat(NaN, n, 1);
avgDBetween = repmat(NaN, n, k);

if (~run_parallel)
    for j = 1:n
        mbrs_tmp = mbrs;
        count_tmp = count;
        distj = sum(bsxfun(@minus, X, X(j,:)).^2, 2);
        for i = 1:k
            if i == idx(j)
                avgDWithin(j) = sum(distj(mbrs_tmp(:,i))) ./ max(count_tmp(i)-1, 1);
            else
                avgDBetween(j, i) = sum(distj(mbrs_tmp(:,i))) ./ count_tmp(i);
            end
        end
    end
else
    parfor j = 1:n
        mbrs_tmp = mbrs;
        count_tmp = count;
        distj = sum(bsxfun(@minus, X, X(j,:)).^2, 2);
        for i = 1:k
            if i == idx(j)
                avgDWithin(j) = sum(distj(mbrs_tmp(:,i))) ./ max(count_tmp(i)-1, 1);
            else
                avgDBetween(j, i) = sum(distj(mbrs_tmp(:,i))) ./ count_tmp(i);
            end
        end
    end
end

% Calculate the silhouette values
minavgDBetween = min(avgDBetween, [], 2);
silh = (minavgDBetween - avgDWithin) ./ max(avgDWithin, minavgDBetween);