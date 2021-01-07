function [knnIdx, u] = knnUW(Xtr, Xq, k, wObs, knnSumWeights, nonuniform)
% Finds nearest neighbors and calculates u for the kernel (or weights, if
% kernel is uniform) for local regression with observation weights
n = size(Xtr, 1);
nq = size(Xq, 1);
wObs = wObs / sum(wObs) * n; % so that wObs sum to n
knnIdx = zeros(n, nq);
if knnSumWeights
    epsw = eps(max(wObs));
end
if nonuniform
    % For all kernels except uniform
    u = ones(n, nq);
    for i = 1 : nq
        dist = sum((repmat(Xq(i,:), n, 1) - Xtr).^2, 2);
        [sortedDist, knnIdx(:,i)] = sort(dist, 'ascend');
        % ties broken arbitrarily. not important because all farthest get 0 weight anyway
        s = 0;
        if knnSumWeights
            for j = 1 : n
                s = s + wObs(knnIdx(j,i));
                if (s >= k - epsw) || (j == n)
                    u(1:(j-1),i) = sqrt(sortedDist(1:(j-1))) ./ sqrt(sortedDist(j)); % divided by the farthest
                    break;
                end
            end
        else
            for j = 1 : n
                if wObs(knnIdx(j,i)) > 0
                    s = s + 1;
                else
                    continue;
                end
                if (s >= k) || (j == n)
                    u(1:(j-1),i) = sqrt(sortedDist(1:(j-1))) ./ sqrt(sortedDist(j)); % divided by the farthest
                    break;
                end
            end
        end
    end
else
    % For uniform kernel
    u = zeros(n, nq); % weights
    for i = 1 : nq
        dist = sum((repmat(Xq(i,:), n, 1) - Xtr).^2, 2);
        [~, knnIdx(:,i)] = sort(dist, 'ascend');
        % ties broken arbitrarily
        s = 0;
        if knnSumWeights
            for j = 1 : n
                s = s + wObs(knnIdx(j,i));
                if (s >= k - epsw) || (j == n)
                    if j > 1
                        u(1:(j-1),i) = ones(j-1,1);
                    end
                    u(j,i) = max(0, k - (s - wObs(knnIdx(j,i))));
                    break;
                end
            end
        else
            for j = 1 : n
                if wObs(knnIdx(j,i)) > 0
                    s = s + 1;
                else
                    continue;
                end
                if (s >= k) || (j == n)
                    if j > 1
                        u(1:(j-1),i) = ones(j-1,1);
                    end
                    u(j,i) = max(0, k - (s - wObs(knnIdx(j,i))));
                    break;
                end
            end
        end
    end
end
return
