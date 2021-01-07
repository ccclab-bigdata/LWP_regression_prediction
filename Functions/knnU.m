function [knnIdx, u] = knnU(Xtr, Xq, k, nonuniform)
% Finds nearest neighbors and calculates u for the kernel (or just gives weight vector of ones, if kernel is uniform)
n = size(Xtr, 1);
nq = size(Xq, 1);
if nonuniform
    % For all kernels except uniform
    knnIdx = zeros(k-1, nq);
    u = zeros(k-1, nq);
    farthest = zeros(1, nq);
    for i = 1 : nq
        dist = sum((repmat(Xq(i,:), n, 1) - Xtr).^2, 2);
        [sortedDist, sortedIdx] = sort(dist, 'ascend');
        knnIdx(:,i) = sortedIdx(1:(k-1)); % ties broken arbitrarily. not important because all farthest get 0 weight anyway
        u(:,i) = sortedDist(1:(k-1));
        farthest(i) = sortedDist(k);
    end
    u = sqrt(u) ./ repmat(sqrt(farthest),k-1,1); % divided by the farthest
else
    % For uniform kernel
    knnIdx = zeros(k, nq);
    for i = 1 : nq
        dist = sum((repmat(Xq(i,:), n, 1) - Xtr).^2, 2);
        [~, sortedIdx] = sort(dist, 'ascend');
        knnIdx(:,i) = sortedIdx(1:k); % ties broken arbitrarily
    end
    u = ones(k, nq); % weights
end
return

